const {onSchedule} = require('firebase-functions/v2/scheduler');
const {onRequest} = require('firebase-functions/v2/https');
const {defineSecret, defineString} = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const crypto = require('crypto');

admin.initializeApp();
const db = admin.firestore();

const NAVER_CLIENT_ID = defineSecret('NAVER_CLIENT_ID');
const NAVER_CLIENT_SECRET = defineSecret('NAVER_CLIENT_SECRET');
const NAVER_CAFE_SEARCH_QUERY = defineString('NAVER_CAFE_SEARCH_QUERY', {
  default: '특전사',
});
const NAVER_CAFE_SLUG = defineString('NAVER_CAFE_SLUG', {
  default: 'koreaspecialforces',
});

function cleanHtml(value) {
  return String(value || '')
    .replace(/<[^>]*>/g, '')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&')
    .replace(/\s+/g, ' ')
    .trim();
}

function normalizeCafeUrl(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/^https?:\/\//, '')
    .replace(/^m\./, '')
    .replace(/^cafe\.naver\.com\//, '')
    .replace(/\.cafe\/?$/, '')
    .replace(/\/$/, '')
    .trim();
}

async function fetchCafeArticles() {
  const query = NAVER_CAFE_SEARCH_QUERY.value().trim() || '특전사';
  const slug = NAVER_CAFE_SLUG.value().trim().toLowerCase();
  const url = new URL('https://openapi.naver.com/v1/search/cafearticle.json');
  url.searchParams.set('query', query);
  url.searchParams.set('display', '100');
  url.searchParams.set('start', '1');
  url.searchParams.set('sort', 'date');

  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'X-Naver-Client-Id': NAVER_CLIENT_ID.value(),
      'X-Naver-Client-Secret': NAVER_CLIENT_SECRET.value(),
      Accept: 'application/json',
    },
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`NAVER Cafe API ${response.status}: ${body.slice(0, 500)}`);
  }

  const payload = await response.json();
  const items = Array.isArray(payload.items) ? payload.items : [];

  return items
    .filter((item) => {
      const normalized = normalizeCafeUrl(item.cafeurl);
      return normalized === slug || normalized.endsWith(`/${slug}`);
    })
    .slice(0, 12);
}

exports.syncNaverCafePosts = onSchedule(
  {
    schedule: 'every 15 minutes',
    timeZone: 'Asia/Seoul',
    region: 'asia-northeast3',
    secrets: [NAVER_CLIENT_ID, NAVER_CLIENT_SECRET],
    retryCount: 1,
  },
  async () => {
    const items = await fetchCafeArticles();
    const collection = db.collection('home_cafe_posts');
    const existing = await collection.limit(100).get();
    const batch = db.batch();

    for (const doc of existing.docs) {
      batch.delete(doc.ref);
    }

    items.forEach((item, index) => {
      const link = String(item.link || '').trim();
      const id = crypto
        .createHash('sha1')
        .update(link || `${item.title || ''}-${index}`)
        .digest('hex');
      const ref = collection.doc(id);
      batch.set(ref, {
        enabled: true,
        title: cleanHtml(item.title),
        summary: cleanHtml(item.description),
        url: link,
        cafeName: cleanHtml(item.cafename),
        cafeUrl: String(item.cafeurl || '').trim(),
        sortOrder: index,
        discoveredAt: admin.firestore.FieldValue.serverTimestamp(),
        source: 'naver-search-api',
      });
    });

    await batch.commit();
    logger.info('NAVER Cafe homepage sync complete', {
      matchedPosts: items.length,
      query: NAVER_CAFE_SEARCH_QUERY.value(),
      cafeSlug: NAVER_CAFE_SLUG.value(),
    });
  },
);

// ============================================================================
// ORQUBE QR REWARD - public claim reservation + authenticated TX confirmation
// ============================================================================
const QR_REGION = 'asia-northeast3';

function qrCors(req, res) {
  const origin = req.get('origin') || '*';
  res.set('Access-Control-Allow-Origin', origin);
  res.set('Vary', 'Origin');
  res.set('Access-Control-Allow-Headers', 'Authorization, Content-Type');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return true;
  }
  return false;
}

function qrBody(req) {
  if (req.body && typeof req.body === 'object') return req.body;
  try {
    return JSON.parse(req.rawBody ? req.rawBody.toString('utf8') : '{}');
  } catch (_) {
    return {};
  }
}

function qrError(code, message, status = 400) {
  const error = new Error(message);
  error.code = code;
  error.status = status;
  return error;
}

function qrWallet(value) {
  const wallet = String(value || '').trim().toLowerCase();
  if (!/^0x[0-9a-f]{40}$/.test(wallet)) {
    throw qrError('INVALID_WALLET', '올바른 EVM 지갑 주소를 입력해 주세요.');
  }
  return wallet;
}

function qrKey(parts) {
  return crypto.createHash('sha256').update(parts.join('|')).digest('hex');
}

function qrUtcDay(date) {
  return date.toISOString().slice(0, 10);
}

function qrUtcMonth(date) {
  return date.toISOString().slice(0, 7);
}

function qrTimestampToDate(value) {
  return value && typeof value.toDate === 'function' ? value.toDate() : null;
}

function qrPositiveNumber(value, fallback = 0) {
  const n = Number(value);
  return Number.isFinite(n) && n > 0 ? n : fallback;
}

function qrPositiveInt(value, fallback = 0) {
  const n = Number(value);
  return Number.isInteger(n) && n > 0 ? n : fallback;
}

exports.qrRewardClaim = onRequest(
  {region: QR_REGION, cors: false, timeoutSeconds: 30},
  async (req, res) => {
    if (qrCors(req, res)) return;
    if (req.method !== 'POST') {
      res.status(405).json({ok: false, code: 'METHOD_NOT_ALLOWED', message: 'POST 요청만 지원합니다.'});
      return;
    }

    try {
      const body = qrBody(req);
      const projectId = String(body.projectId || '').trim();
      const campaignId = String(body.campaignId || 'default').trim();
      const walletAddress = qrWallet(body.walletAddress);
      if (!projectId || !/^[A-Za-z0-9_-]{1,160}$/.test(campaignId)) {
        throw qrError('INVALID_CAMPAIGN', 'QR 보상 캠페인 정보가 올바르지 않습니다.');
      }

      const campaignDocId = `${projectId}_${campaignId}`;
      const campaignRef = db.collection('qr_reward_campaigns').doc(campaignDocId);
      const guardRef = db.collection('qr_reward_claim_guards').doc(qrKey([campaignDocId, walletAddress]));
      const claimRef = db.collection('qr_reward_claims').doc();
      const now = new Date();
      const nowTs = admin.firestore.Timestamp.fromDate(now);
      const today = qrUtcDay(now);
      const month = qrUtcMonth(now);

      let responseData = null;

      await db.runTransaction(async (tx) => {
        const [campaignSnap, guardSnap] = await Promise.all([
          tx.get(campaignRef),
          tx.get(guardRef),
        ]);
        if (!campaignSnap.exists) {
          throw qrError('CAMPAIGN_NOT_FOUND', '이 QR 보상 캠페인을 찾을 수 없습니다.', 404);
        }

        const campaign = campaignSnap.data() || {};
        if (campaign.status !== 'active' || campaign.claimEnabled !== true) {
          throw qrError('CAMPAIGN_DISABLED', '현재 이 QR 보상은 지급이 활성화되어 있지 않습니다.', 409);
        }

        const amount = qrPositiveNumber(campaign.amount);
        const totalLimit = qrPositiveNumber(campaign.totalLimit);
        const dailyLimit = qrPositiveInt(campaign.dailyLimit, 1);
        const validDays = qrPositiveInt(campaign.validDays, 30);
        if (!amount || !totalLimit) {
          throw qrError('INVALID_CAMPAIGN', '보상 수량 또는 총 지급 한도 설정이 올바르지 않습니다.', 409);
        }

        const activated = qrTimestampToDate(campaign.activatedAt) || qrTimestampToDate(campaign.updatedAt);
        if (activated) {
          const expiresAt = new Date(activated.getTime() + validDays * 86400000);
          if (now >= expiresAt) {
            throw qrError('CAMPAIGN_EXPIRED', '이 QR 보상 캠페인의 유효기간이 종료되었습니다.', 409);
          }
        }

        const paidAmount = Number(campaign.paidAmount || 0);
        const reservedAmount = Number(campaign.reservedAmount || 0);
        // Public claims do not consume the financial total limit permanently.
        // This prevents anonymous callers from exhausting a campaign by creating
        // many unpaid reservations. The paid total is checked again at TX confirm.
        if (paidAmount + amount > totalLimit + 1e-9) {
          throw qrError('CAMPAIGN_LIMIT', '캠페인 총 지급 한도에 도달했습니다.', 409);
        }

        const guard = guardSnap.exists ? (guardSnap.data() || {}) : {};
        const claimCount = Number(guard.claimCount || 0);
        const dayCount = guard.dayKey === today ? Number(guard.dayCount || 0) : 0;
        const monthCount = guard.monthKey === month ? Number(guard.monthCount || 0) : 0;
        const repeatPolicy = String(campaign.repeatPolicy || 'daily');
        const repeatEveryDays = qrPositiveInt(campaign.repeatEveryDays, 1);
        const maxClaimsPerWallet = qrPositiveInt(campaign.maxClaimsPerWallet, 0);
        const cooldownHours = qrPositiveNumber(campaign.cooldownHours, 0);
        const lastClaimAt = qrTimestampToDate(guard.lastClaimAt);

        if (maxClaimsPerWallet > 0 && claimCount >= maxClaimsPerWallet) {
          throw qrError('WALLET_LIMIT', '이 지갑은 설정된 최대 수령 횟수에 도달했습니다.', 409);
        }
        if (dayCount >= dailyLimit) {
          throw qrError('DAILY_LIMIT', '이 지갑은 오늘 받을 수 있는 횟수를 모두 사용했습니다.', 409);
        }
        if (repeatPolicy === 'once' && claimCount >= 1) {
          throw qrError('ALREADY_CLAIMED', '이 QR 보상은 지갑당 1회만 받을 수 있습니다.', 409);
        }
        if (repeatPolicy === 'monthly' && monthCount >= 1) {
          throw qrError('MONTHLY_LIMIT', '이 QR 보상은 월 1회만 받을 수 있습니다.', 409);
        }
        if (repeatPolicy === 'every_n_days' && lastClaimAt) {
          const next = lastClaimAt.getTime() + repeatEveryDays * 86400000;
          if (now.getTime() < next) {
            throw qrError('REPEAT_WAIT', `${repeatEveryDays}일 재수령 간격이 아직 지나지 않았습니다.`, 409);
          }
        }
        if (cooldownHours > 0 && lastClaimAt) {
          const next = lastClaimAt.getTime() + cooldownHours * 3600000;
          if (now.getTime() < next) {
            throw qrError('COOLDOWN', '설정된 재수령 대기시간이 아직 지나지 않았습니다.', 409);
          }
        }

        const ownerUid = String(campaign.ownerUid || '');
        if (!ownerUid) {
          throw qrError('INVALID_OWNER', '캠페인 발행자 정보가 없습니다.', 409);
        }

        tx.create(claimRef, {
          claimId: claimRef.id,
          projectId,
          campaignId,
          campaignDocId,
          ownerUid,
          walletAddress,
          amount,
          symbol: String(campaign.symbol || 'TOKEN'),
          contractAddress: campaign.contractAddress || null,
          chainId: Number(campaign.chainId || 0),
          network: String(campaign.network || ''),
          status: 'reserved',
          claimedDay: today,
          claimedMonth: month,
          createdAt: nowTs,
          updatedAt: nowTs,
        });

        tx.set(guardRef, {
          campaignDocId,
          walletAddress,
          ownerUid,
          claimCount: claimCount + 1,
          dayKey: today,
          dayCount: dayCount + 1,
          monthKey: month,
          monthCount: monthCount + 1,
          lastClaimId: claimRef.id,
          lastClaimAt: nowTs,
          updatedAt: nowTs,
        }, {merge: true});

        tx.update(campaignRef, {
          reservedAmount: reservedAmount + amount,
          reservedCount: Number(campaign.reservedCount || 0) + 1,
          updatedAt: nowTs,
        });

        responseData = {
          ok: true,
          claimId: claimRef.id,
          status: 'reserved',
          amount,
          symbol: String(campaign.symbol || 'TOKEN'),
          message: '보상 요청이 접수되었습니다. 발행자 지갑의 실제 전송 승인을 기다립니다.',
        };
      });

      res.status(200).json(responseData);
    } catch (error) {
      logger.warn('qrRewardClaim failed', {code: error.code, message: error.message});
      res.status(error.status || 500).json({
        ok: false,
        code: error.code || 'CLAIM_FAILED',
        message: error.status ? error.message : '보상 요청 처리 중 서버 오류가 발생했습니다.',
      });
    }
  },
);

exports.qrRewardConfirmPaid = onRequest(
  {region: QR_REGION, cors: false, timeoutSeconds: 30},
  async (req, res) => {
    if (qrCors(req, res)) return;
    if (req.method !== 'POST') {
      res.status(405).json({ok: false, code: 'METHOD_NOT_ALLOWED', message: 'POST 요청만 지원합니다.'});
      return;
    }

    try {
      const authHeader = req.get('authorization') || '';
      const match = authHeader.match(/^Bearer\s+(.+)$/i);
      if (!match) throw qrError('AUTH_REQUIRED', '발행자 로그인이 필요합니다.', 401);
      const user = await admin.auth().verifyIdToken(match[1]);

      const body = qrBody(req);
      const claimId = String(body.claimId || '').trim();
      const txHash = String(body.txHash || '').trim();
      if (!claimId) throw qrError('INVALID_CLAIM', 'CLAIM ID가 없습니다.');
      if (!/^0x[0-9a-fA-F]{64}$/.test(txHash)) {
        throw qrError('INVALID_TX', '올바른 EVM TX Hash가 아닙니다.');
      }

      const claimRef = db.collection('qr_reward_claims').doc(claimId);
      const txGuardRef = db.collection('qr_reward_tx_guards').doc(qrKey([txHash.toLowerCase()]));
      const txLogRef = db.collection('qr_reward_tx_logs').doc(claimId);
      const nowTs = admin.firestore.Timestamp.now();
      let result = null;

      await db.runTransaction(async (tx) => {
        const claimSnap = await tx.get(claimRef);
        if (!claimSnap.exists) throw qrError('CLAIM_NOT_FOUND', '보상 요청을 찾을 수 없습니다.', 404);
        const claim = claimSnap.data() || {};
        if (claim.ownerUid !== user.uid) throw qrError('FORBIDDEN', '이 보상 요청을 처리할 권한이 없습니다.', 403);

        if (claim.status === 'paid') {
          if (String(claim.txHash || '').toLowerCase() !== txHash.toLowerCase()) {
            throw qrError('ALREADY_PAID', '이미 다른 TX Hash로 지급 완료된 요청입니다.', 409);
          }
          result = {ok: true, status: 'paid', claimId, txHash, alreadyConfirmed: true};
          return;
        }
        if (claim.status !== 'reserved') {
          throw qrError('INVALID_STATE', '현재 지급 완료 처리할 수 없는 요청 상태입니다.', 409);
        }

        const txGuardSnap = await tx.get(txGuardRef);
        if (txGuardSnap.exists && txGuardSnap.data()?.claimId !== claimId) {
          throw qrError('TX_ALREADY_USED', '이 TX Hash는 다른 보상 요청에 이미 기록되어 있습니다.', 409);
        }

        const campaignRef = db.collection('qr_reward_campaigns').doc(String(claim.campaignDocId || ''));
        const campaignSnap = await tx.get(campaignRef);
        if (!campaignSnap.exists) throw qrError('CAMPAIGN_NOT_FOUND', '캠페인 정보를 찾을 수 없습니다.', 404);
        const campaign = campaignSnap.data() || {};
        if (campaign.ownerUid !== user.uid) throw qrError('FORBIDDEN', '캠페인 발행자 권한이 일치하지 않습니다.', 403);

        const amount = Number(claim.amount || 0);
        const totalLimit = Number(campaign.totalLimit || 0);
        const currentPaidAmount = Number(campaign.paidAmount || 0);
        if (totalLimit > 0 && currentPaidAmount + amount > totalLimit + 1e-9) {
          throw qrError('CAMPAIGN_LIMIT', '캠페인 총 지급 한도를 초과하여 TX를 기록할 수 없습니다.', 409);
        }
        const reservedAmount = Math.max(0, Number(campaign.reservedAmount || 0) - amount);
        const reservedCount = Math.max(0, Number(campaign.reservedCount || 0) - 1);
        const paidAmount = currentPaidAmount + amount;
        const paidCount = Number(campaign.paidCount || 0) + 1;

        tx.update(claimRef, {
          status: 'paid',
          txHash,
          paidAt: nowTs,
          updatedAt: nowTs,
        });
        tx.update(campaignRef, {
          reservedAmount,
          reservedCount,
          paidAmount,
          paidCount,
          updatedAt: nowTs,
        });
        tx.set(txGuardRef, {claimId, ownerUid: user.uid, txHash, createdAt: nowTs});
        tx.set(txLogRef, {
          claimId,
          projectId: String(claim.projectId || ''),
          campaignId: String(claim.campaignId || ''),
          campaignDocId: String(claim.campaignDocId || ''),
          ownerUid: user.uid,
          walletAddress: String(claim.walletAddress || ''),
          amount,
          symbol: String(claim.symbol || ''),
          contractAddress: claim.contractAddress || campaign.contractAddress || null,
          chainId: Number(claim.chainId || campaign.chainId || 0),
          network: String(claim.network || campaign.network || ''),
          txHash,
          status: 'paid',
          createdAt: nowTs,
        });

        result = {ok: true, status: 'paid', claimId, txHash};
      });

      res.status(200).json(result);
    } catch (error) {
      logger.warn('qrRewardConfirmPaid failed', {code: error.code, message: error.message});
      res.status(error.status || 500).json({
        ok: false,
        code: error.code || 'CONFIRM_FAILED',
        message: error.status ? error.message : 'TX 기록 처리 중 서버 오류가 발생했습니다.',
      });
    }
  },
);

