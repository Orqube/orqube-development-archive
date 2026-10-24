const crypto = require("crypto");
const {onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {getApps, initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {getStorage} = require("firebase-admin/storage");

if (getApps().length === 0) initializeApp();

const db = getFirestore();
const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

const REGION = "asia-northeast3";
const TEXT_MODEL = process.env.OPENAI_TEXT_MODEL || "gpt-5-mini";
const IMAGE_MODEL = process.env.OPENAI_IMAGE_MODEL || "gpt-image-1-mini";
const TEXT_LIMIT_PER_DAY = Number(process.env.AI_TEXT_LIMIT_PER_DAY || 30);
const CHAT_LIMIT_PER_DAY = Number(process.env.AI_CHAT_LIMIT_PER_DAY || 10);
const LOGO_LIMIT_PER_DAY = Number(process.env.AI_LOGO_LIMIT_PER_DAY || 12);

function setCors(req, res) {
  const origin = req.get("origin") || "*";
  res.set("Access-Control-Allow-Origin", origin);
  res.set("Vary", "Origin");
  res.set("Access-Control-Allow-Headers", "Authorization, Content-Type");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Max-Age", "3600");
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return true;
  }
  return false;
}

async function requireUser(req) {
  const authHeader = req.get("authorization") || "";
  const match = authHeader.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    const error = new Error("AUTH_REQUIRED");
    error.status = 401;
    throw error;
  }
  try {
    return await getAuth().verifyIdToken(match[1]);
  } catch (_) {
    const error = new Error("INVALID_AUTH");
    error.status = 401;
    throw error;
  }
}

function todayKey() {
  return new Date().toISOString().slice(0, 10);
}

async function checkDailyQuota(uid, kind, limit) {
  const ref = db.collection("ai_launch_usage").doc(uid);
  const snap = await ref.get();
  const current = snap.data() || {};
  const today = todayKey();
  const sameDay = current.day === today;
  const field = kind === "logo"
    ? "logoCount"
    : kind === "assistantBeta"
      ? "assistantBetaCount"
      : kind === "chat"
        ? "chatCount"
        : "textCount";
  const count = sameDay ? Number(current[field] || 0) : 0;
  if (count >= limit) {
    const error = new Error("DAILY_LIMIT");
    error.status = 429;
    throw error;
  }
  return {used: count, limit, remaining: Math.max(0, limit - count)};
}

async function useDailyQuota(uid, kind, limit) {
  const ref = db.collection("ai_launch_usage").doc(uid);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const current = snap.data() || {};
    const today = todayKey();
    const sameDay = current.day === today;
    const field = kind === "logo"
      ? "logoCount"
      : kind === "assistantBeta"
        ? "assistantBetaCount"
        : kind === "chat"
          ? "chatCount"
          : "textCount";
    const count = sameDay ? Number(current[field] || 0) : 0;
    if (count >= limit) {
      const error = new Error("DAILY_LIMIT");
      error.status = 429;
      throw error;
    }
    const nextCount = count + 1;
    tx.set(ref, {
      day: today,
      [field]: nextCount,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    if (!sameDay) {
      tx.set(ref, {
        textCount: kind === "text" ? 1 : 0,
        chatCount: kind === "chat" ? 1 : 0,
        assistantBetaCount: kind === "assistantBeta" ? 1 : 0,
        logoCount: kind === "logo" ? 1 : 0,
      }, {merge: true});
    }
    return {
      used: nextCount,
      limit,
      remaining: Math.max(0, limit - nextCount),
    };
  });
}

function cleanString(value, max = 500) {
  const text = String(value || "").replace(/[\u0000-\u001f]+/g, " ").trim();
  return text.length <= max ? text : text.slice(0, max).trim();
}

function cleanAssistantText(value, max = 5000) {
  const text = String(value || "")
    .replace(/\r\n?/g, "\n")
    .replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f]+/g, " ")
    .trim();
  return text.length <= max ? text : text.slice(0, max).trim();
}

function parseJsonBody(req) {
  if (req.body && typeof req.body === "object") return req.body;
  try {
    return JSON.parse(req.rawBody ? req.rawBody.toString("utf8") : "{}");
  } catch (_) {
    return {};
  }
}

async function openaiJson(path, body) {
  const response = await fetch(`https://api.openai.com${path}`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${OPENAI_API_KEY.value()}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  const json = await response.json().catch(() => ({}));
  if (!response.ok) {
    const detail = json && json.error && json.error.message
      ? json.error.message
      : `OpenAI HTTP ${response.status}`;
    const error = new Error(detail);
    error.status = 502;
    throw error;
  }
  return json;
}

function extractResponseText(response) {
  if (typeof response.output_text === "string" && response.output_text.trim()) {
    return response.output_text.trim();
  }
  for (const item of response.output || []) {
    for (const content of item.content || []) {
      if (content.type === "output_text" && typeof content.text === "string") {
        return content.text.trim();
      }
    }
  }
  return "";
}

function tokenDraftSchema() {
  return {
    type: "object",
    additionalProperties: false,
    required: [
      "allowed", "policyReason", "name", "symbol", "category",
      "description", "vision", "utility", "tagline"
    ],
    properties: {
      allowed: {type: "boolean"},
      policyReason: {type: "string"},
      name: {type: "string"},
      symbol: {type: "string"},
      category: {
        type: "string",
        enum: [
          "dailyLife", "hobby", "work", "localBusiness",
          "professional", "creator", "community", "event", "meme"
        ]
      },
      description: {type: "string"},
      vision: {type: "string"},
      utility: {type: "string"},
      tagline: {type: "string"}
    }
  };
}

function draftInstructions(language) {
  return [
    "You are ORQUBE AI Launch, a product assistant that turns a user's idea into a safe public token draft on Kaia.",
    "The result is a product/community token concept, not financial advice or a promise of profit.",
    "Reject political/election campaigning tokens, profit-guarantee investment products, gambling/betting, illegal or regulated commerce, impersonation, and deceptive public-figure tokens by setting allowed=false and policyReason.",
    "Never promise investment returns, price appreciation, guaranteed rewards, or exchange listing.",
    "Create an original concise token identity. Symbols must be uppercase A-Z/0-9 only, 2-10 characters, without a dollar sign.",
    "Utility should describe practical participation, membership, event, access, contribution, or community uses.",
    language === "ko"
      ? "Write description, vision, utility, tagline naturally in Korean. Token name may be English or Korean when suitable."
      : "Use the user's language when obvious; otherwise use clear English.",
  ].join("\n");
}

exports.generateLaunchAiDraft = onRequest({
  region: REGION,
  timeoutSeconds: 60,
  memory: "512MiB",
  secrets: [OPENAI_API_KEY],
}, async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== "POST") return res.status(405).json({error: "METHOD_NOT_ALLOWED"});

  try {
    const user = await requireUser(req);
    await useDailyQuota(user.uid, "text", TEXT_LIMIT_PER_DAY);

    const body = parseJsonBody(req);
    const idea = cleanString(body.idea, 700);
    const language = cleanString(body.language, 12) || "auto";
    if (idea.length < 3) return res.status(400).json({error: "IDEA_TOO_SHORT"});

    const response = await openaiJson("/v1/responses", {
      model: TEXT_MODEL,
      instructions: draftInstructions(language),
      input: `USER TOKEN IDEA:\n${idea}`,
      text: {
        format: {
          type: "json_schema",
          name: "orqube_launch_token_draft",
          strict: true,
          schema: tokenDraftSchema(),
        },
      },
    });

    const outputText = extractResponseText(response);
    if (!outputText) throw new Error("EMPTY_AI_OUTPUT");
    const draft = JSON.parse(outputText);

    if (draft.allowed !== true) {
      return res.status(400).json({
        error: "POLICY_BLOCKED",
        message: cleanString(draft.policyReason, 300) || "This token idea is not supported.",
      });
    }

    return res.json({
      data: {
        name: cleanString(draft.name, 80),
        symbol: cleanString(draft.symbol, 10).toUpperCase().replace(/[^A-Z0-9]/g, ""),
        category: cleanString(draft.category, 40),
        description: cleanString(draft.description, 500),
        vision: cleanString(draft.vision, 500),
        utility: cleanString(draft.utility, 500),
        tagline: cleanString(draft.tagline, 140),
        provider: "openai",
        model: TEXT_MODEL,
      },
    });
  } catch (error) {
    console.error("generateLaunchAiDraft", error);
    const status = Number(error.status || 500);
    const code = error.message === "DAILY_LIMIT" ? "DAILY_LIMIT" : "AI_SERVER_ERROR";
    return res.status(status).json({error: code});
  }
});


function assistantInstructions(language) {
  return [
    "You are ORQUBE AI Assistant inside the ORQUBE Token Launch product.",
    "ORQUBE is built around Human + AI collaboration: a person decides the goal and approves consequential actions; AI explains, reviews, drafts, tests, and assists.",
    "Use the workflow DESCRIBE -> BUILD -> TEST -> DEPLOY -> VERIFY -> USE whenever it helps orient the user.",
    "Be practical and beginner-friendly. Explain what the current screen means, what is already known from provided context, and the safest next action.",
    "Never claim a transaction, token deployment, payment, source verification, wallet connection, publication, or external post succeeded unless the supplied context explicitly proves it.",
    "Never invent wallet addresses, contract addresses, transaction hashes, balances, prices, or verification results.",
    "Never ask for or store a private key, seed phrase, recovery words, password, OTP, or authentication code. If the user offers one, tell them not to share it.",
    "Wallet signatures, token deployment, payments, publishing, paid ads, and external posting require explicit human approval. Do not describe them as autonomous AI actions.",
    "Current AI billing policy is BETA: basic guidance is free, remote AI deep analysis is free up to the configured daily limit, and ORBS is NOT automatically charged. Future ORBS paid advanced analysis is planned but not active yet.",
    "Clearly distinguish PROJECT WALLET, MetaMask current account, and Kaia Wallet current account. Public wallet addresses may be explained, but secrets must never be requested.",
    "Do not promise token price appreciation, investment returns, exchange listing, or guaranteed rewards. Do not help evade financial, legal, tax, securities, VASP, KYC, or platform rules.",
    "Do not assist in creating political/election campaigning tokens, deceptive public-figure tokens, gambling/betting products, illegal commerce, or impersonation schemes.",
    "For legal or financial questions, provide general product information and recommend qualified local professional review when a decision depends on law or regulation.",
    "Keep answers concise unless the user asks for detailed steps. Prefer numbered steps only when procedural clarity requires them.",
    language === "ko"
      ? "Answer naturally in Korean unless the user clearly asks for another language."
      : "Answer in the user's apparent language; use clear English if uncertain.",
  ].join("\n");
}

function sanitizeProjectContext(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return {};
  const allowed = [
    "name", "symbol", "status", "chain", "deploymentNetwork", "totalSupply",
    "walletAddress", "testnetVerifiedWallet", "contractAddress", "txHash",
    "verificationStatus", "assetMode", "category", "orbsBalance", "starterStatus",
    "walletStatus", "firestoreAccountLoaded"
  ];
  const result = {};
  for (const key of allowed) {
    const raw = value[key];
    if (typeof raw === "string") result[key] = cleanString(raw, 300);
    if (typeof raw === "number" && Number.isFinite(raw)) result[key] = raw;
    if (typeof raw === "boolean") result[key] = raw;
  }
  return result;
}

function sanitizeChatHistory(value) {
  if (!Array.isArray(value)) return [];
  return value.slice(-8).map((item) => {
    const role = item && item.role === "user" ? "user" : "assistant";
    return {role, text: cleanString(item && item.text, 900)};
  }).filter((item) => item.text.length > 0);
}

exports.orqubeAiAssistant = onRequest({
  region: REGION,
  timeoutSeconds: 60,
  memory: "512MiB",
  secrets: [OPENAI_API_KEY],
}, async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== "POST") return res.status(405).json({error: "METHOD_NOT_ALLOWED"});

  try {
    const user = await requireUser(req);
    await checkDailyQuota(user.uid, "assistantBeta", CHAT_LIMIT_PER_DAY);

    const body = parseJsonBody(req);
    const message = cleanString(body.message, 2000);
    const screen = cleanString(body.screen, 80) || "ORQUBE TOKEN LAUNCH";
    const language = cleanString(body.language, 12) || "auto";
    const project = sanitizeProjectContext(body.project);
    const history = sanitizeChatHistory(body.history);
    if (!message) return res.status(400).json({error: "MESSAGE_REQUIRED"});

    const recentChat = history.length === 0
      ? "(none)"
      : history.map((item) => `${item.role.toUpperCase()}: ${item.text}`).join("\n");

    const input = [
      `CURRENT SCREEN: ${screen}`,
      `PROJECT CONTEXT (only facts supplied by ORQUBE):\n${JSON.stringify(project, null, 2)}`,
      `RECENT CHAT:\n${recentChat}`,
      `USER QUESTION:\n${message}`,
    ].join("\n\n");

    const response = await openaiJson("/v1/responses", {
      model: TEXT_MODEL,
      instructions: assistantInstructions(language),
      input,
      max_output_tokens: 700,
    });

    const answer = cleanAssistantText(extractResponseText(response), 5000);
    if (!answer) throw new Error("EMPTY_AI_OUTPUT");

    // Only a successful remote AI answer consumes the BETA free allowance.
    const chatUsage = await useDailyQuota(user.uid, "assistantBeta", CHAT_LIMIT_PER_DAY);

    return res.json({
      data: {
        answer,
        provider: "openai",
        model: TEXT_MODEL,
        workflow: "DESCRIBE_BUILD_TEST_DEPLOY_VERIFY_USE",
        billingMode: "BETA_FREE",
        betaFreeDailyLimit: chatUsage.limit,
        betaFreeUsed: chatUsage.used,
        betaFreeRemaining: chatUsage.remaining,
        orbsCharged: 0,
      },
    });
  } catch (error) {
    console.error("orqubeAiAssistant", error);
    const status = Number(error.status || 500);
    const code = error.message === "DAILY_LIMIT" ? "DAILY_LIMIT" : "AI_ASSISTANT_ERROR";
    return res.status(status).json({error: code});
  }
});

function logoPrompt({idea, name, symbol, category, tagline, style}) {
  return [
    `Create one original token/community logo icon for ORQUBE AI Launch.`,
    `Token name: ${name}. Symbol reference: ${symbol}. Category: ${category}.`,
    `Idea: ${idea}. Tagline: ${tagline}.`,
    `Visual direction: ${style}.`,
    "Icon only. Do not render words, letters, ticker symbols, numbers, watermarks, charts, coins with currency signs, exchange logos, or existing brand marks.",
    "Centered simple silhouette, strong geometry, high legibility at 48px, premium Web3 product identity, transparent background, square 1:1 composition.",
    "Make it distinct from Bitcoin, Ethereum, Kaia, and existing crypto/project logos. No public figure likenesses.",
  ].join("\n");
}

async function generateOneLogo(input, style) {
  const response = await openaiJson("/v1/images/generations", {
    model: IMAGE_MODEL,
    prompt: logoPrompt({...input, style}),
    size: "1024x1024",
    quality: "medium",
    background: "transparent",
    output_format: "png",
  });
  const first = Array.isArray(response.data) ? response.data[0] : null;
  if (!first) throw new Error("EMPTY_IMAGE_OUTPUT");
  if (first.b64_json) return Buffer.from(first.b64_json, "base64");
  if (first.url) {
    const imageResponse = await fetch(first.url);
    if (!imageResponse.ok) throw new Error("IMAGE_DOWNLOAD_FAILED");
    return Buffer.from(await imageResponse.arrayBuffer());
  }
  throw new Error("UNSUPPORTED_IMAGE_OUTPUT");
}

async function saveLogo(uid, buffer, index) {
  const bucket = getStorage().bucket();
  const token = crypto.randomUUID();
  const id = crypto.randomUUID();
  const objectPath = `ai_launch_logos/${uid}/${Date.now()}_${index}_${id}.png`;
  const file = bucket.file(objectPath);
  await file.save(buffer, {
    resumable: false,
    contentType: "image/png",
    metadata: {
      cacheControl: "public,max-age=31536000,immutable",
      metadata: {
        firebaseStorageDownloadTokens: token,
        generatedBy: "ORQUBE_AI_LAUNCH_V0_8_1",
      },
    },
  });
  return `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(objectPath)}?alt=media&token=${token}`;
}

const FREE_LOGO_COUNT = 1;
const DEFAULT_ADDITIONAL_LOGO_COST_ORBS = 3;

async function reserveLogoGeneration(uid) {
  const entitlementRef = db.collection("ai_launch_entitlements").doc(uid);
  const walletRef = db.collection("launch_wallets").doc(uid);
  const configRef = db.collection("launch_config").doc("economy");
  const ledgerRef = db.collection("orbs_service_ledger").doc();

  return db.runTransaction(async (tx) => {
    const [entitlementSnap, walletSnap, configSnap] = await Promise.all([
      tx.get(entitlementRef),
      tx.get(walletRef),
      tx.get(configRef),
    ]);
    const entitlement = entitlementSnap.data() || {};
    const wallet = walletSnap.data() || {};
    const config = configSnap.data() || {};
    const generatedCount = Math.max(0, Number(entitlement.aiLogoGeneratedCount || 0));
    const configuredCost = Number(config.logoAdditionalCostOrbs);
    const additionalCost = Number.isFinite(configuredCost) && configuredCost >= 0
      ? configuredCost
      : DEFAULT_ADDITIONAL_LOGO_COST_ORBS;
    const isFree = generatedCount < FREE_LOGO_COUNT;
    const charge = isFree ? 0 : additionalCost;
    const balance = Number(wallet.orbsBalance || 0);

    if (charge > 0 && balance < charge) {
      const error = new Error("INSUFFICIENT_ORBS");
      error.status = 402;
      error.requiredOrbs = charge;
      error.balance = balance;
      throw error;
    }

    const reservationId = ledgerRef.id;
    tx.set(entitlementRef, {
      aiLogoGeneratedCount: generatedCount + 1,
      lastLogoReservationId: reservationId,
      lastLogoReservedAt: FieldValue.serverTimestamp(),
    }, {merge: true});

    if (charge > 0) {
      tx.set(walletRef, {
        orbsBalance: balance - charge,
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
    }
    tx.set(ledgerRef, {
      uid,
      type: "AI_LOGO_GENERATION",
      amountOrbs: charge,
      free: isFree,
      status: "RESERVED",
      sequence: generatedCount + 1,
      createdAt: FieldValue.serverTimestamp(),
    });
    return {reservationId, ledgerRef, entitlementRef, walletRef, isFree, charge, previousCount: generatedCount};
  });
}

async function finalizeLogoReservation(reservation, success) {
  if (!reservation) return;
  if (success) {
    await reservation.ledgerRef.set({
      status: "COMPLETED",
      completedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    return;
  }

  await db.runTransaction(async (tx) => {
    const [entSnap, walletSnap, ledgerSnap] = await Promise.all([
      tx.get(reservation.entitlementRef),
      tx.get(reservation.walletRef),
      tx.get(reservation.ledgerRef),
    ]);
    const ledger = ledgerSnap.data() || {};
    if (ledger.status !== "RESERVED") return;
    const ent = entSnap.data() || {};
    const wallet = walletSnap.data() || {};
    if (ent.lastLogoReservationId === reservation.reservationId) {
      tx.set(reservation.entitlementRef, {
        aiLogoGeneratedCount: reservation.previousCount,
        lastLogoReservationId: FieldValue.delete(),
      }, {merge: true});
    }
    if (reservation.charge > 0) {
      tx.set(reservation.walletRef, {
        orbsBalance: Number(wallet.orbsBalance || 0) + reservation.charge,
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
    }
    tx.set(reservation.ledgerRef, {
      status: "REFUNDED",
      refundedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
  });
}

exports.generateLaunchLogoOptions = onRequest({
  region: REGION,
  timeoutSeconds: 180,
  memory: "1GiB",
  secrets: [OPENAI_API_KEY],
}, async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== "POST") return res.status(405).json({error: "METHOD_NOT_ALLOWED"});

  let reservation = null;
  try {
    const user = await requireUser(req);
    await useDailyQuota(user.uid, "logo", LOGO_LIMIT_PER_DAY);

    const body = parseJsonBody(req);
    const input = {
      idea: cleanString(body.idea, 700),
      name: cleanString(body.name, 80),
      symbol: cleanString(body.symbol, 10).toUpperCase(),
      category: cleanString(body.category, 40),
      tagline: cleanString(body.tagline, 140),
    };
    if (input.idea.length < 3 || input.name.length < 2 || input.symbol.length < 2) {
      return res.status(400).json({error: "INVALID_TOKEN_DRAFT"});
    }

    reservation = await reserveLogoGeneration(user.uid);
    const buffer = await generateOneLogo(input, "premium minimal geometric mark, distinctive, memorable, balanced negative space");
    const url = await saveLogo(user.uid, buffer, 1);
    await finalizeLogoReservation(reservation, true);

    const walletSnap = await db.collection("launch_wallets").doc(user.uid).get();
    const nextBalance = Number((walletSnap.data() || {}).orbsBalance || 0);
    return res.json({
      data: {
        logos: [{url, style: "ORQUBE AI LOGO"}],
        provider: "openai",
        model: IMAGE_MODEL,
        pricing: {
          free: reservation.isFree,
          chargedOrbs: reservation.charge,
          additionalLogoCostOrbs: DEFAULT_ADDITIONAL_LOGO_COST_ORBS,
          remainingOrbs: nextBalance,
        },
      },
    });
  } catch (error) {
    if (reservation) {
      try { await finalizeLogoReservation(reservation, false); } catch (refundError) {
        console.error("logo reservation refund failed", refundError);
      }
    }
    console.error("generateLaunchLogoOptions", error);
    if (error.message === "INSUFFICIENT_ORBS") {
      return res.status(402).json({
        error: "INSUFFICIENT_ORBS",
        requiredOrbs: Number(error.requiredOrbs || DEFAULT_ADDITIONAL_LOGO_COST_ORBS),
        balance: Number(error.balance || 0),
      });
    }
    const status = Number(error.status || 500);
    const code = error.message === "DAILY_LIMIT" ? "DAILY_LIMIT" : "LOGO_SERVER_ERROR";
    return res.status(status).json({error: code});
  }
});

// One-time Starter ORBS credit after a Kaia wallet has been connected.
exports.claimLaunchStarter = onRequest({
  region: REGION,
  timeoutSeconds: 30,
  memory: "256MiB",
}, async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== "POST") return res.status(405).json({error: "METHOD_NOT_ALLOWED"});

  try {
    const user = await requireUser(req);
    const walletRef = db.collection("launch_wallets").doc(user.uid);
    const requestRef = db.collection("launch_starter_requests").doc(user.uid);
    const starterOrbs = 10.0;

    const result = await db.runTransaction(async (tx) => {
      const walletSnap = await tx.get(walletRef);
      const wallet = walletSnap.data() || {};
      const address = cleanString(wallet.walletAddress, 80);
      if (!/^0x[0-9a-fA-F]{40}$/.test(address) || wallet.walletStatus !== "connected") {
        const error = new Error("WALLET_REQUIRED");
        error.status = 400;
        throw error;
      }

      const status = cleanString(wallet.starterStatus, 32);
      if (status === "credited") {
        return {alreadyCredited: true, balance: Number(wallet.orbsBalance || 0)};
      }

      const currentBalance = Number(wallet.orbsBalance || 0);
      const nextBalance = currentBalance + starterOrbs;
      tx.set(walletRef, {
        orbsBalance: nextBalance,
        starterStatus: "credited",
        starterOrbs,
        starterCreditedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
      tx.set(requestRef, {
        ownerUid: user.uid,
        status: "credited",
        amountOrbs: starterOrbs,
        creditedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
      return {alreadyCredited: false, balance: nextBalance};
    });

    return res.json({data: {starterOrbs, ...result}});
  } catch (error) {
    console.error("claimLaunchStarter", error);
    const status = Number(error.status || 500);
    return res.status(status).json({error: error.message || "STARTER_SERVER_ERROR"});
  }
});


function solidityString(value) {
  return JSON.stringify(cleanString(value, 80));
}

// Compile a self-contained ERC-20 style test token. The returned bytecode is
// deployed by the user's MetaMask; ORQUBE never receives a private key.
exports.compileLaunchEvmToken = onRequest({
  region: REGION,
  timeoutSeconds: 30,
  memory: "512MiB",
}, async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== "POST") return res.status(405).json({error: "METHOD_NOT_ALLOWED"});

  try {
    await requireUser(req);
    const body = parseJsonBody(req);
    const name = cleanString(body.name, 80);
    const symbol = cleanString(body.symbol, 10).toUpperCase().replace(/[^A-Z0-9]/g, "");
    const supplyText = String(body.totalSupply || "").trim();
    if (!name || symbol.length < 2 || !/^\d+$/.test(supplyText)) {
      return res.status(400).json({error: "INVALID_TOKEN_INPUT"});
    }
    const supply = BigInt(supplyText);
    if (supply <= 0n || supply > 1000000000000000000n) {
      return res.status(400).json({error: "INVALID_SUPPLY"});
    }

    const source = `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract ORQUBETestToken {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    constructor() {
        name = ${solidityString(name)};
        symbol = ${solidityString(symbol)};
        totalSupply = ${supplyText} * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount); return true;
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount); return true;
    }
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "ALLOWANCE");
        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;
        _transfer(from, to, amount); return true;
    }
    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "ZERO_ADDRESS");
        uint256 bal = balanceOf[from];
        require(bal >= amount, "BALANCE");
        unchecked { balanceOf[from] = bal - amount; }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}`;

    const input = {
      language: "Solidity",
      sources: {"ORQUBETestToken.sol": {content: source}},
      settings: {
        optimizer: {enabled: true, runs: 200},
        outputSelection: {"*": {"*": ["abi", "evm.bytecode.object", "evm.deployedBytecode.object"]}},
      },
    };
    // Lazy-load solc only when this endpoint is invoked.
    // Loading solc at module startup can exceed Firebase CLI's function-discovery timeout
    // on slower development machines.
    const solc = require("solc");
    const output = JSON.parse(solc.compile(JSON.stringify(input)));
    const errors = (output.errors || []).filter((e) => e.severity === "error");
    if (errors.length) {
      console.error("compileLaunchEvmToken", errors);
      return res.status(500).json({error: "SOLIDITY_COMPILE_FAILED"});
    }
    const artifact = output.contracts?.["ORQUBETestToken.sol"]?.ORQUBETestToken;
    const object = artifact?.evm?.bytecode?.object || "";
    if (!object) return res.status(500).json({error: "EMPTY_BYTECODE"});
    return res.json({data: {
      bytecode: `0x${object}`,
      abi: artifact.abi || [],
      source,
      compilerVersion: solc.version(),
      optimizer: true,
      optimizerRuns: 200,
      contractName: "ORQUBETestToken",
      creationBytecode: `0x${object}`,
      deployedBytecode: artifact?.evm?.deployedBytecode?.object ? `0x${artifact.evm.deployedBytecode.object}` : "",
      constructorArguments: "",
      standardJsonInput: input,
      standardJsonOutput: output,
      dependencyVersion: "self-contained:no-external-dependencies",
    }});
  } catch (error) {
    console.error("compileLaunchEvmToken", error);
    const status = Number(error.status || 500);
    return res.status(status).json({error: error.message || "COMPILE_SERVER_ERROR"});
  }
});

exports.finalizeLaunchTestDeployment = onRequest({
  region: REGION,
  timeoutSeconds: 30,
  memory: "256MiB",
}, async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== "POST") return res.status(405).json({error: "METHOD_NOT_ALLOWED"});

  try {
    const user = await requireUser(req);
    const body = parseJsonBody(req);
    const projectId = cleanString(body.projectId, 128);
    const ownerUid = cleanString(body.ownerUid, 128);
    const chain = cleanString(body.chain, 16);
    const walletAddress = cleanString(body.walletAddress, 80);
    const contractAddress = cleanString(body.contractAddress, 80);
    const txHash = cleanString(body.txHash, 160);
    const name = cleanString(body.name, 80);
    const symbol = cleanString(body.symbol, 16);
    const totalSupply = Number(body.totalSupply || 0);
    const network = chain === "Kaia" ? "Kairos Testnet" : chain === "Polygon" ? "Amoy Testnet" : "Devnet";

    if (!projectId || ownerUid !== user.uid || !["Kaia", "Polygon", "Solana"].includes(chain)) {
      return res.status(400).json({error: "INVALID_DEPLOYMENT_INPUT"});
    }
    const evmAddress = /^0x[0-9a-fA-F]{40}$/;
    const solAddress = /^[1-9A-HJ-NP-Za-km-z]{32,44}$/;
    if ((chain === "Solana" && (!solAddress.test(walletAddress) || !solAddress.test(contractAddress))) ||
        (chain !== "Solana" && (!evmAddress.test(walletAddress) || !evmAddress.test(contractAddress)))) {
      return res.status(400).json({error: "INVALID_DEPLOYMENT_ADDRESS"});
    }
    if (!txHash || !Number.isSafeInteger(totalSupply) || totalSupply <= 0) {
      return res.status(400).json({error: "INVALID_DEPLOYMENT_RESULT"});
    }

    const projectRef = db.collection("launch_projects").doc(projectId);
    const projectSnap = await projectRef.get();
    const project = projectSnap.data();
    if (!project || project.ownerUid !== user.uid) {
      return res.status(403).json({error: "PROJECT_OWNER_REQUIRED"});
    }
    if (project.contractAddress) {
      return res.status(409).json({error: "ALREADY_DEPLOYED"});
    }

    const requestRef = db.collection("launch_deployment_requests").doc();
    const archiveRef = db.collection("launch_deployment_archives").doc(projectId);
    const archive = body.archive && typeof body.archive === "object" ? body.archive : {};
    const safeArchive = {};
    for (const key of ["source", "abi", "compilerVersion", "optimizer", "optimizerRuns", "contractName", "creationBytecode", "deployedBytecode", "constructorArguments", "standardJsonInput", "standardJsonOutput", "dependencyVersion", "program", "decimals", "metadataStatus"]) {
      if (Object.prototype.hasOwnProperty.call(archive, key)) safeArchive[key] = archive[key];
    }

    const batch = db.batch();
    batch.set(requestRef, {
      projectId,
      ownerUid: user.uid,
      walletAddress,
      chain,
      network,
      status: "deployed",
      contractAddress,
      txHash,
      createdAt: FieldValue.serverTimestamp(),
      completedAt: FieldValue.serverTimestamp(),
    });
    batch.set(projectRef, {
      chain,
      walletAddress,
      contractAddress,
      txHash,
      deploymentStatus: "deployed_testnet",
      deploymentNetwork: network,
      deploymentRequestId: requestRef.id,
      decimals: chain === "Solana" ? 9 : 18,
      deployedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    batch.set(archiveRef, {
      projectId,
      ownerUid: user.uid,
      chain,
      network,
      name,
      symbol,
      totalSupply,
      contractAddress,
      txHash,
      archiveVersion: 2,
      chainId: chain === "Kaia" ? 1001 : chain === "Polygon" ? 80002 : null,
      walletAddress,
      verificationStatus: "NOT_VERIFIED",
      paymentStatus: "NOT_PAID",
      ...safeArchive,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    await batch.commit();

    return res.json({data: {projectId, chain, network, contractAddress, txHash}});
  } catch (error) {
    console.error("finalizeLaunchTestDeployment", error);
    const status = Number(error.status || 500);
    return res.status(status).json({error: error.message || "DEPLOYMENT_FINALIZE_ERROR"});
  }
});


// ============================================================================
// ORQUBE AUTO VERIFY v1
// Deploy -> Archive -> Pay -> Verify -> Save
// The service price is read from launch_config/auto_verify. If a fee is missing or invalid,
// the current ORQUBE policy defaults (500 KAI / 100 ORBS) are used. Payment still stays
// disabled until enabled flags and the treasury / ORBS contract settings are configured.
// ============================================================================
const KAIA_MAINNET_RPC = "https://public-en.node.kaia.io";
const KAIASCAN_MAINNET_VERIFY = "https://mainnet-api.kaiascan.io/hardhat-verify";
// TEMPORARY MAINNET TEST MODE. Set false after 10 KAI MetaMask/Kaia Wallet tests pass.
const AUTO_VERIFY_KAI_TEST_MODE = true;
const AUTO_VERIFY_KAI_TEST_FEE = 10;

function isEvmAddress(value) {
  return /^0x[0-9a-fA-F]{40}$/.test(String(value || ""));
}

function normalizeHexAddress(value) {
  return String(value || "").toLowerCase();
}

function bigIntFromHex(value) {
  const raw = String(value || "0x0");
  try { return BigInt(raw); } catch (_) { return 0n; }
}

function decimalToUnits(value, decimals) {
  const raw = String(value ?? "0").trim();
  const [wholeRaw, fractionRaw = ""] = raw.split(".");
  const whole = wholeRaw || "0";
  const fraction = (fractionRaw + "0".repeat(decimals)).slice(0, decimals);
  return BigInt(`${whole}${fraction}`.replace(/^0+(?=\d)/, "") || "0");
}

async function kaiaRpc(method, params) {
  const response = await fetch(KAIA_MAINNET_RPC, {
    method: "POST",
    headers: {"content-type": "application/json"},
    body: JSON.stringify({jsonrpc: "2.0", id: 1, method, params}),
  });
  const payload = await response.json();
  if (!response.ok || payload.error) {
    throw Object.assign(new Error("KAIA_RPC_ERROR"), {status: 502});
  }
  return payload.result;
}

async function loadAutoVerifyConfig() {
  const snap = await db.collection("launch_config").doc("auto_verify").get();
  const data = snap.data() || {};
  const parsedKaiFee = Number(data.kaiFee);
  const parsedOrbsFee = Number(data.orbsFee);
  return {
    enabled: data.enabled === true,
    kaiFee: AUTO_VERIFY_KAI_TEST_MODE
      ? AUTO_VERIFY_KAI_TEST_FEE
      : (Number.isFinite(parsedKaiFee) && parsedKaiFee > 0 ? parsedKaiFee : 500),
    orbsFee: Number.isFinite(parsedOrbsFee) && parsedOrbsFee > 0 ? parsedOrbsFee : 100,
    kaiEnabled: data.kaiEnabled === true,
    orbsEnabled: data.orbsEnabled === true,
    treasuryAddress: cleanString(data.treasuryAddress, 80),
    orbsContractAddress: cleanString(data.orbsContractAddress, 80),
    orbsDecimals: Number(data.orbsDecimals ?? 18),
  };
}

async function verifyNativeKaiPayment({tx, receipt, config, expectedFrom}) {
  if (!config.kaiEnabled) throw Object.assign(new Error("KAI_PAYMENT_DISABLED"), {status: 409});
  if (!isEvmAddress(config.treasuryAddress)) throw Object.assign(new Error("AUTO_VERIFY_TREASURY_NOT_CONFIGURED"), {status: 503});
  if (normalizeHexAddress(tx.from) !== normalizeHexAddress(expectedFrom)) return false;
  if (normalizeHexAddress(tx.to) !== normalizeHexAddress(config.treasuryAddress)) return false;
  if (String(receipt.status).toLowerCase() !== "0x1") return false;
  const expectedWei = decimalToUnits(config.kaiFee, 18);
  return bigIntFromHex(tx.value) >= expectedWei;
}

async function verifyOrbsPayment({tx, receipt, config, expectedFrom}) {
  if (!config.orbsEnabled) throw Object.assign(new Error("ORBS_PAYMENT_DISABLED"), {status: 409});
  if (!isEvmAddress(config.treasuryAddress) || !isEvmAddress(config.orbsContractAddress)) {
    throw Object.assign(new Error("AUTO_VERIFY_ORBS_NOT_CONFIGURED"), {status: 503});
  }
  if (normalizeHexAddress(tx.from) !== normalizeHexAddress(expectedFrom)) return false;
  if (normalizeHexAddress(tx.to) !== normalizeHexAddress(config.orbsContractAddress)) return false;
  if (String(receipt.status).toLowerCase() !== "0x1") return false;
  const input = String(tx.input || tx.data || "").toLowerCase();
  if (!input.startsWith("0xa9059cbb") || input.length < 138) return false;
  const toWord = input.slice(10, 74);
  const amountWord = input.slice(74, 138);
  const encodedTo = `0x${toWord.slice(24)}`;
  const amount = BigInt(`0x${amountWord}`);
  const expected = decimalToUnits(config.orbsFee, config.orbsDecimals);
  return normalizeHexAddress(encodedTo) === normalizeHexAddress(config.treasuryAddress) && amount >= expected;
}

exports.confirmAutoVerifyPayment = onRequest({region: REGION, timeoutSeconds: 30, memory: "256MiB"}, async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== "POST") return res.status(405).json({error: "METHOD_NOT_ALLOWED"});
  try {
    const user = await requireUser(req);
    const body = parseJsonBody(req);
    const projectId = cleanString(body.projectId, 128);
    const paymentMethod = cleanString(body.paymentMethod, 16).toUpperCase();
    const walletProvider = cleanString(body.walletProvider, 24).toUpperCase();
    const txHash = cleanString(body.txHash, 160);
    if (!projectId || !["KAI", "ORBS"].includes(paymentMethod) ||
        (walletProvider && !["METAMASK", "KAIA_WALLET"].includes(walletProvider)) ||
        !/^0x[0-9a-fA-F]{64}$/.test(txHash)) {
      return res.status(400).json({error: "INVALID_PAYMENT_INPUT"});
    }

    const [projectSnap, archiveSnap, config] = await Promise.all([
      db.collection("launch_projects").doc(projectId).get(),
      db.collection("launch_deployment_archives").doc(projectId).get(),
      loadAutoVerifyConfig(),
    ]);
    const project = projectSnap.data();
    const archive = archiveSnap.data();
    if (!project || project.ownerUid !== user.uid || !archive || archive.ownerUid !== user.uid) {
      return res.status(403).json({error: "PROJECT_OWNER_REQUIRED"});
    }
    if (!config.enabled || config.kaiFee <= 0 || config.orbsFee <= 0) return res.status(409).json({error: "AUTO_VERIFY_POLICY_NOT_CONFIGURED"});
    if (project.chain !== "Kaia" || Number(archive.chainId) !== 8217) {
      return res.status(409).json({error: "AUTO_VERIFY_MAINNET_ONLY"});
    }

    const existing = await db.collection("launch_auto_verify_payments").where("txHash", "==", txHash).limit(1).get();
    if (!existing.empty && existing.docs[0].data().projectId !== projectId) {
      return res.status(409).json({error: "PAYMENT_TX_ALREADY_USED"});
    }

    const [tx, receipt] = await Promise.all([
      kaiaRpc("eth_getTransactionByHash", [txHash]),
      kaiaRpc("eth_getTransactionReceipt", [txHash]),
    ]);
    if (!tx || !receipt) return res.status(409).json({error: "PAYMENT_TX_NOT_CONFIRMED"});
    const walletAddress = cleanString(project.walletAddress || archive.walletAddress, 80);
    const valid = paymentMethod === "KAI"
      ? await verifyNativeKaiPayment({tx, receipt, config, expectedFrom: walletAddress})
      : await verifyOrbsPayment({tx, receipt, config, expectedFrom: walletAddress});
    if (!valid) return res.status(409).json({error: "PAYMENT_ONCHAIN_MISMATCH"});

    const paymentRef = existing.empty ? db.collection("launch_auto_verify_payments").doc() : existing.docs[0].ref;
    const archiveRef = db.collection("launch_deployment_archives").doc(projectId);
    const amount = paymentMethod === "KAI" ? config.kaiFee : config.orbsFee;
    const batch = db.batch();
    batch.set(paymentRef, {
      projectId,
      ownerUid: user.uid,
      contractAddress: archive.contractAddress,
      paymentMethod,
      paymentProvider: walletProvider || "LEGACY",
      paymentAmount: amount,
      txHash,
      paymentWallet: walletAddress,
      paymentNetwork: "KAIA MAINNET",
      chainId: 8217,
      status: "PAYMENT_CONFIRMED",
      confirmedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    batch.set(archiveRef, {
      paymentMethod,
      paymentProvider: walletProvider || "LEGACY",
      paymentAmount: amount,
      paymentTxHash: txHash,
      paymentStatus: "PAYMENT_CONFIRMED",
      paymentWallet: walletAddress,
      paymentNetwork: "KAIA MAINNET",
      verificationStatus: archive.verificationStatus === "VERIFIED" ? "VERIFIED" : "PAYMENT_CONFIRMED",
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    await batch.commit();
    return res.json({data: {paymentStatus: "PAYMENT_CONFIRMED", txHash}});
  } catch (error) {
    console.error("confirmAutoVerifyPayment", error);
    return res.status(Number(error.status || 500)).json({error: error.message || "AUTO_VERIFY_PAYMENT_ERROR"});
  }
});

function normalizeCompilerVersion(value) {
  const raw = String(value || "").trim();
  if (!raw) return "";
  return raw.startsWith("v") ? raw : `v${raw}`;
}

async function kaiascanSubmitVerification(archive) {
  const sourceInput = archive.standardJsonInput;
  if (!sourceInput || typeof sourceInput !== "object") throw new Error("ARCHIVE_STANDARD_JSON_MISSING");
  const form = new URLSearchParams();
  form.set("module", "contract");
  form.set("action", "verifysourcecode");
  form.set("apikey", "unnecessary");
  form.set("contractaddress", archive.contractAddress);
  form.set("sourceCode", JSON.stringify(sourceInput));
  form.set("codeformat", "solidity-standard-json-input");
  form.set("contractname", `ORQUBETestToken.sol:${archive.contractName || "ORQUBETestToken"}`);
  form.set("compilerversion", normalizeCompilerVersion(archive.compilerVersion));
  form.set("constructorArguements", String(archive.constructorArguments || "").replace(/^0x/, ""));
  form.set("constructorArguments", String(archive.constructorArguments || "").replace(/^0x/, ""));
  const response = await fetch(KAIASCAN_MAINNET_VERIFY, {
    method: "POST",
    headers: {"content-type": "application/x-www-form-urlencoded;charset=UTF-8"},
    body: form.toString(),
  });
  const text = await response.text();
  let payload;
  try { payload = JSON.parse(text); } catch (_) { payload = {status: "0", message: text, result: text}; }
  if (!response.ok) throw new Error(`KAIASCAN_HTTP_${response.status}`);
  return payload;
}

async function kaiascanCheckStatus(guid) {
  const url = new URL(KAIASCAN_MAINNET_VERIFY);
  url.searchParams.set("module", "contract");
  url.searchParams.set("action", "checkverifystatus");
  url.searchParams.set("guid", guid);
  url.searchParams.set("apikey", "unnecessary");
  const response = await fetch(url);
  const text = await response.text();
  try { return JSON.parse(text); } catch (_) { return {status: "0", message: text, result: text}; }
}

function verificationSucceeded(payload) {
  const text = `${payload?.message || ""} ${payload?.result || ""}`.toLowerCase();
  return payload?.status === "1" && (text.includes("pass") || text.includes("verified") || text.includes("already"));
}

exports.requestAutoVerify = onRequest({region: REGION, timeoutSeconds: 120, memory: "256MiB"}, async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== "POST") return res.status(405).json({error: "METHOD_NOT_ALLOWED"});
  const archiveRefForFailure = {ref: null};
  try {
    const user = await requireUser(req);
    const body = parseJsonBody(req);
    const projectId = cleanString(body.projectId, 128);
    if (!projectId) return res.status(400).json({error: "INVALID_PROJECT_ID"});
    const archiveRef = db.collection("launch_deployment_archives").doc(projectId);
    archiveRefForFailure.ref = archiveRef;
    const archiveSnap = await archiveRef.get();
    const archive = archiveSnap.data();
    if (!archive || archive.ownerUid !== user.uid) return res.status(403).json({error: "PROJECT_OWNER_REQUIRED"});
    if (Number(archive.chainId) !== 8217 || archive.chain !== "Kaia") return res.status(409).json({error: "AUTO_VERIFY_MAINNET_ONLY"});
    if (archive.paymentStatus !== "PAYMENT_CONFIRMED") return res.status(402).json({error: "PAYMENT_REQUIRED"});
    if (archive.verificationStatus === "VERIFIED") return res.json({data: {verificationStatus: "VERIFIED", alreadyVerified: true}});

    await archiveRef.set({
      verificationStatus: "VERIFY_QUEUED",
      verificationRequestTime: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    await archiveRef.set({verificationStatus: "VERIFYING", updatedAt: FieldValue.serverTimestamp()}, {merge: true});

    const submitted = await kaiascanSubmitVerification(archive);
    let finalPayload = submitted;
    let success = verificationSucceeded(submitted);
    const guid = String(submitted?.result || "").trim();
    if (!success && submitted?.status === "1" && guid && guid.length < 200) {
      for (let i = 0; i < 5; i++) {
        await new Promise((resolve) => setTimeout(resolve, 2500));
        finalPayload = await kaiascanCheckStatus(guid);
        if (verificationSucceeded(finalPayload)) { success = true; break; }
        const resultText = String(finalPayload?.result || "").toLowerCase();
        if (!resultText.includes("pending") && !resultText.includes("queue")) break;
      }
    }

    if (!success) {
      const resultText = `${finalPayload?.message || ""} ${finalPayload?.result || ""}`.toLowerCase();
      if (resultText.includes("already verified")) success = true;
    }
    if (!success) throw Object.assign(new Error("KAIASCAN_VERIFICATION_FAILED"), {detail: finalPayload, status: 502});

    await archiveRef.set({
      verificationStatus: "VERIFIED",
      verificationResult: finalPayload,
      verifiedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    await db.collection("launch_projects").doc(projectId).set({
      sourceVerificationStatus: "VERIFIED",
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    return res.json({data: {verificationStatus: "VERIFIED", result: finalPayload}});
  } catch (error) {
    console.error("requestAutoVerify", error);
    if (archiveRefForFailure.ref) {
      try {
        await archiveRefForFailure.ref.set({
          verificationStatus: "VERIFY_FAILED",
          verificationResult: {error: error.message || "VERIFY_ERROR", detail: error.detail || null},
          updatedAt: FieldValue.serverTimestamp(),
        }, {merge: true});
      } catch (_) {}
    }
    return res.status(Number(error.status || 500)).json({error: error.message || "AUTO_VERIFY_ERROR"});
  }
});

// MOBILE_STUDIO_BRIDGE_V1
Object.assign(exports, require('./mobile_studio_bridge').createHandlers({loadPolicy:loadAutoVerifyConfig,testMode:AUTO_VERIFY_KAI_TEST_MODE,testFee:AUTO_VERIFY_KAI_TEST_FEE}));
