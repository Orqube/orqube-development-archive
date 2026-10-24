const {isAdminIdentity} = require('./admin_access');
const {onRequest} = require('firebase-functions/v2/https');
const {defineSecret} = require('firebase-functions/params');
const {getApps, initializeApp} = require('firebase-admin/app');
const {getAuth} = require('firebase-admin/auth');
const {getFirestore, FieldValue} = require('firebase-admin/firestore');

if (getApps().length === 0) initializeApp();
const db = getFirestore();
const OPENAI_API_KEY = defineSecret('OPENAI_API_KEY');
const REGION = 'asia-northeast3';
const MODEL = process.env.OPENAI_MARKETING_MODEL || 'gpt-4.1-mini';
const FIELD = 'AI_TOKEN_LAUNCH';

function cors(req, res) {
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

function clean(value, max = 1000) {
  const text = String(value || '').replace(/[\u0000-\u001f]+/g, ' ').replace(/\s+/g, ' ').trim();
  return text.length <= max ? text : text.slice(0, max).trim();
}

function bodyOf(req) {
  if (req.body && typeof req.body === 'object') return req.body;
  try { return JSON.parse(req.rawBody ? req.rawBody.toString('utf8') : '{}'); } catch (_) { return {}; }
}

async function requireAdmin(req) {
  const header = req.get('authorization') || '';
  const match = header.match(/^Bearer\s+(.+)$/i);
  if (!match) throw Object.assign(new Error('AUTH_REQUIRED'), {status: 401});
  const user = await getAuth().verifyIdToken(match[1], true);
  const snap = await db.collection('users').doc(user.uid).get();
  const profile = snap.data() || {};
  if (!isAdminIdentity(user, profile)) {
    throw Object.assign(new Error('ADMIN_REQUIRED'), {status: 403});
  }
  return user;
}

async function callOpenAI(body) {
  const response = await fetch('https://api.openai.com/v1/responses', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${OPENAI_API_KEY.value()}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  const json = await response.json().catch(() => ({}));
  if (!response.ok) {
    const detail = json?.error?.message || `OpenAI HTTP ${response.status}`;
    throw Object.assign(new Error(detail), {status: 502});
  }
  return json;
}

function outputText(response) {
  if (typeof response.output_text === 'string' && response.output_text.trim()) return response.output_text.trim();
  for (const item of response.output || []) {
    for (const content of item.content || []) {
      if (content.type === 'output_text' && typeof content.text === 'string') return content.text.trim();
    }
  }
  return '';
}

function schema() {
  return {
    type: 'object',
    additionalProperties: false,
    required: ['allowed','policyReason','tokenFitScore','fitReason','tokenUseCases','promoHeadline','promoCopy','outreachAngle','recommendedLanguage'],
    properties: {
      allowed: {type: 'boolean'},
      policyReason: {type: 'string'},
      tokenFitScore: {type: 'integer', minimum: 0, maximum: 100},
      fitReason: {type: 'string'},
      tokenUseCases: {type: 'array', minItems: 1, maxItems: 5, items: {type: 'string'}},
      promoHeadline: {type: 'string'},
      promoCopy: {type: 'string'},
      outreachAngle: {type: 'string'},
      recommendedLanguage: {type: 'string'},
    },
  };
}

function instructions() {
  return [
    'You are ORQUBE AI MARKETING V4.1 token-launch fit analyst.',
    'Evaluate whether a discovered public organization, creator, community, local business, professional, event organizer, or project is a plausible prospect for ORQUBE AI TOKEN LAUNCH / TOKEN CREATOR.',
    'Score 0-100 using observable fit: identifiable community or customers (25), repeat engagement/member relationship (20), practical non-investment token utility (25), digital/community reach (15), realistic contactability and legitimacy (15).',
    'High scores require concrete practical token uses such as membership, access, event participation, loyalty, contribution recognition, community badges, creator fan participation, or local-business rewards.',
    'Do not score based on expected token price, investment return, speculation, exchange listing, or fundraising promises.',
    'Reject political/election campaigning, gambling/betting, illegal or regulated commerce, impersonation/public-figure deception, and profit-guarantee investment schemes by setting allowed=false.',
    'Generate concise, factual promotional copy that presents token creation as a community/product tool, never as guaranteed profit.',
    'Use the candidate language when supplied; otherwise choose the most appropriate language from country/context.',
    'This analysis is only for a HUMAN APPROVAL QUEUE. Never instruct automatic posting, messaging, email sending, paid ads, or autonomous outreach.',
  ].join('\n');
}

function candidateInput(b) {
  return {
    organizationName: clean(b.organization_name || b.organizationName, 160),
    url: clean(b.url || b.source_url || b.sourceUrl, 500),
    country: clean(b.country, 80),
    language: clean(b.language, 40),
    platform: clean(b.platform, 80),
    originalField: clean(b.field || b.verified_field || b.originalField, 100),
    description: clean(b.description || b.summary || b.evidence, 1600),
    audienceSignals: clean(b.audience_signals || b.audienceSignals, 1200),
    contactPath: clean(b.contact_path || b.contactPath || b.approach_method, 600),
  };
}

exports.analyzeAiTokenMarketingCandidate = onRequest({
  region: REGION,
  timeoutSeconds: 90,
  memory: '512MiB',
  secrets: [OPENAI_API_KEY],
}, async (req, res) => {
  if (cors(req, res)) return;
  if (req.method !== 'POST') return res.status(405).json({error: 'METHOD_NOT_ALLOWED'});

  try {
    const adminUser = await requireAdmin(req);
    const body = bodyOf(req);
    const candidate = candidateInput(body);
    if (candidate.organizationName.length < 2 || candidate.url.length < 8) {
      return res.status(400).json({error: 'INVALID_CANDIDATE'});
    }

    const response = await callOpenAI({
      model: MODEL,
      instructions: instructions(),
      input: `DISCOVERED PUBLIC TARGET\n${JSON.stringify(candidate, null, 2)}`,
      text: {format: {type: 'json_schema', name: 'orqube_ai_token_marketing_fit', strict: true, schema: schema()}},
    });
    const text = outputText(response);
    if (!text) throw new Error('EMPTY_AI_OUTPUT');
    const result = JSON.parse(text);
    if (result.allowed !== true) {
      return res.status(400).json({error: 'POLICY_BLOCKED', message: clean(result.policyReason, 400)});
    }

    const score = Math.max(0, Math.min(100, Number(result.tokenFitScore || 0)));
    const tokenUseCases = Array.isArray(result.tokenUseCases)
      ? result.tokenUseCases.map((x) => clean(x, 240)).filter(Boolean).slice(0, 5)
      : [];

    const ref = db.collection('marketing_approval_queue').doc();
    const record = {
      organization_name: candidate.organizationName,
      url: candidate.url,
      country: candidate.country,
      language: candidate.language || clean(result.recommendedLanguage, 40),
      platform: candidate.platform,
      source_field: candidate.originalField,
      field: FIELD,
      verified_field: FIELD,
      marketing_field_number: 9,
      marketing_field_label: 'AI TOKEN LAUNCH / TOKEN CREATOR',
      fit_score: score,
      verified_fit_score: score,
      token_fit_score: score,
      token_fit_reason: clean(result.fitReason, 700),
      token_use_cases: tokenUseCases,
      promo_headline: clean(result.promoHeadline, 180),
      promo_copy: clean(result.promoCopy, 1200),
      outreach_angle: clean(result.outreachAngle, 600),
      approach_method: candidate.contactPath,
      evidence: candidate.description,
      approval_status: 'PENDING',
      human_approval_required: true,
      execution_enabled: 'NO',
      email_send: 'OFF',
      external_posting: 'OFF',
      paid_ads: 'OFF',
      ai_analysis_provider: 'openai',
      ai_analysis_model: MODEL,
      created_by: adminUser.uid,
      created_at: FieldValue.serverTimestamp(),
      updated_at: FieldValue.serverTimestamp(),
    };
    await ref.set(record);
    return res.json({data: {id: ref.id, ...record, created_at: null, updated_at: null}});
  } catch (error) {
    console.error('analyzeAiTokenMarketingCandidate', error);
    return res.status(Number(error.status || 500)).json({error: error.message || 'AI_MARKETING_ERROR'});
  }
});

// A token owner can seed Field #9 directly from the Token Creator UI.
// This creates a HUMAN-APPROVAL campaign brief. It never posts or sends externally.
exports.startTokenLaunchMarketing = onRequest({
  region: REGION,
  timeoutSeconds: 90,
  memory: '512MiB',
  secrets: [OPENAI_API_KEY],
}, async (req, res) => {
  if (cors(req, res)) return;
  if (req.method !== 'POST') return res.status(405).json({error: 'METHOD_NOT_ALLOWED'});

  try {
    const header = req.get('authorization') || '';
    const match = header.match(/^Bearer\s+(.+)$/i);
    if (!match) return res.status(401).json({error: 'AUTH_REQUIRED'});
    const user = await requireAdmin(req);
    const body = bodyOf(req);
    const projectId = clean(body.projectId, 160);
    if (!projectId) return res.status(400).json({error: 'PROJECT_ID_REQUIRED'});

    const projectSnap = await db.collection('launch_projects').doc(projectId).get();
    if (!projectSnap.exists) return res.status(404).json({error: 'PROJECT_NOT_FOUND'});
    const project = projectSnap.data() || {};
    if (String(project.ownerUid || '') !== user.uid) {
      return res.status(403).json({error: 'PROJECT_OWNER_REQUIRED'});
    }

    const tokenInput = {
      projectId,
      name: clean(project.name, 100),
      symbol: clean(project.symbol, 20),
      category: clean(project.category, 80),
      tagline: clean(project.tagline, 240),
      description: clean(project.description, 1400),
      vision: clean(project.vision, 900),
      utility: clean(project.utility, 900),
      totalSupply: Number(project.totalSupply || 0),
    };

    const campaignSchema = {
      type: 'object',
      additionalProperties: false,
      required: ['tokenFitScore','fitReason','targetCountry','targetLanguage','targetPlatform','targetAudience','tokenUseCases','promoHeadline','promoCopy','outreachAngle'],
      properties: {
        tokenFitScore: {type: 'integer', minimum: 0, maximum: 100},
        fitReason: {type: 'string'},
        targetCountry: {type: 'string'},
        targetLanguage: {type: 'string'},
        targetPlatform: {type: 'string'},
        targetAudience: {type: 'string'},
        tokenUseCases: {type: 'array', minItems: 1, maxItems: 5, items: {type: 'string'}},
        promoHeadline: {type: 'string'},
        promoCopy: {type: 'string'},
        outreachAngle: {type: 'string'},
      },
    };

    const response = await callOpenAI({
      model: MODEL,
      instructions: [
        'You are ORQUBE AI MARKETING V4.1 Field #9 campaign planner.',
        'Analyze the supplied ORQUBE Token Creator project and prepare a HUMAN-APPROVAL marketing brief.',
        'TOKEN_FIT_SCORE means readiness/fit for practical community/product marketing, not investment quality or expected price.',
        'Recommend an initial country, language, platform and audience based on the token purpose. Global is allowed.',
        'Focus on practical token utility, community participation, loyalty, access, events, contribution recognition or creator engagement.',
        'Never promise price appreciation, investment returns, exchange listing or fundraising success.',
        'No automatic posting, messaging, email or paid advertising. This output only enters the approval queue.',
      ].join('\n'),
      input: `TOKEN PROJECT\n${JSON.stringify(tokenInput, null, 2)}`,
      text: {format: {type: 'json_schema', name: 'orqube_token_campaign_seed', strict: true, schema: campaignSchema}},
    });

    const output = outputText(response);
    if (!output) throw new Error('EMPTY_AI_OUTPUT');
    const result = JSON.parse(output);
    const score = Math.max(0, Math.min(100, Number(result.tokenFitScore || 0)));
    const ref = db.collection('marketing_approval_queue').doc();
    const record = {
      project_id: projectId,
      project_owner_uid: user.uid,
      organization_name: tokenInput.name || projectId,
      token_symbol: tokenInput.symbol,
      field: FIELD,
      verified_field: FIELD,
      marketing_field_number: 9,
      marketing_field_label: 'AI TOKEN LAUNCH / TOKEN CREATOR',
      queue_kind: 'TOKEN_CAMPAIGN_REQUEST',
      country: clean(result.targetCountry, 80),
      language: clean(result.targetLanguage, 40),
      platform: clean(result.targetPlatform, 80),
      target_audience: clean(result.targetAudience, 700),
      fit_score: score,
      verified_fit_score: score,
      token_fit_score: score,
      token_fit_reason: clean(result.fitReason, 700),
      token_use_cases: Array.isArray(result.tokenUseCases)
        ? result.tokenUseCases.map((x) => clean(x, 240)).filter(Boolean).slice(0, 5)
        : [],
      promo_headline: clean(result.promoHeadline, 180),
      promo_copy: clean(result.promoCopy, 1200),
      outreach_angle: clean(result.outreachAngle, 600),
      approval_status: 'PENDING',
      human_approval_required: true,
      execution_enabled: 'NO',
      email_send: 'OFF',
      external_posting: 'OFF',
      paid_ads: 'OFF',
      ai_analysis_provider: 'openai',
      ai_analysis_model: MODEL,
      created_by: user.uid,
      created_at: FieldValue.serverTimestamp(),
      updated_at: FieldValue.serverTimestamp(),
    };
    await ref.set(record);
    return res.json({data: {id: ref.id, ...record, created_at: null, updated_at: null}});
  } catch (error) {
    console.error('startTokenLaunchMarketing', error);
    return res.status(Number(error.status || 500)).json({error: error.message || 'TOKEN_MARKETING_ERROR'});
  }
});

// One campaign nucleus expands into coordinated, human-approved channel assets.
exports.createFusionMarketingCampaign = onRequest({
  region: REGION,
  timeoutSeconds: 120,
  memory: '512MiB',
  secrets: [OPENAI_API_KEY],
}, async (req, res) => {
  if (cors(req, res)) return;
  if (req.method !== 'POST') return res.status(405).json({error: 'METHOD_NOT_ALLOWED'});
  try {
    const header = req.get('authorization') || '';
    const match = header.match(/^Bearer\s+(.+)$/i);
    if (!match) return res.status(401).json({error: 'AUTH_REQUIRED'});
    const user = await requireAdmin(req);
    const body = bodyOf(req);
    const type = clean(body.campaignType, 40).toUpperCase();
    if (!['ORQUBE_OFFICIAL', 'TOKEN_PROMOTION'].includes(type)) {
      return res.status(400).json({error: 'INVALID_CAMPAIGN_TYPE'});
    }
    const profileSnap = await db.collection('users').doc(user.uid).get();
    const profile = profileSnap.data() || {};
    const isAdmin = isAdminIdentity(user, profile);
    if (type === 'ORQUBE_OFFICIAL' && !isAdmin) {
      return res.status(403).json({error: 'ADMIN_REQUIRED'});
    }
    const projectId = clean(body.projectId, 160);
    let project = null;
    if (type === 'TOKEN_PROMOTION') {
      if (!projectId) return res.status(400).json({error: 'PROJECT_ID_REQUIRED'});
      const snap = await db.collection('launch_projects').doc(projectId).get();
      if (!snap.exists) return res.status(404).json({error: 'PROJECT_NOT_FOUND'});
      project = snap.data() || {};
      if (String(project.ownerUid || '') !== user.uid && !isAdmin) {
        return res.status(403).json({error: 'PROJECT_OWNER_REQUIRED'});
      }
    }
    const channels = Array.isArray(body.channels)
      ? body.channels.map((x) => clean(x, 40)).filter(Boolean).slice(0, 8)
      : [];
    if (!channels.length) return res.status(400).json({error: 'CHANNEL_REQUIRED'});
    const input = {
      campaignType: type,
      campaignName: clean(body.campaignName, 120),
      objective: clean(body.objective, 500),
      coreMessage: clean(body.coreMessage, 1200),
      audience: clean(body.audience, 500),
      country: clean(body.country, 80),
      language: clean(body.language, 40),
      callToAction: clean(body.callToAction, 300),
      channels,
      token: project ? {
        id: projectId,
        name: clean(project.name, 100),
        symbol: clean(project.symbol, 20),
        vision: clean(project.vision, 700),
        utility: clean(project.utility, 700),
        category: clean(project.category, 80),
      } : null,
    };
    if (input.campaignName.length < 2 || input.objective.length < 5 || input.coreMessage.length < 10) {
      return res.status(400).json({error: 'CAMPAIGN_INPUT_REQUIRED'});
    }
    const assetSchema = {
      type: 'object', additionalProperties: false,
      required: ['channel','headline','body','callToAction','hashtags','visualDirection'],
      properties: {
        channel: {type: 'string'}, headline: {type: 'string'}, body: {type: 'string'},
        callToAction: {type: 'string'},
        hashtags: {type: 'array', maxItems: 8, items: {type: 'string'}},
        visualDirection: {type: 'string'},
      },
    };
    const campaignSchema = {
      type: 'object', additionalProperties: false,
      required: ['campaignTitle','nucleus','slogan','audienceInsight','contentPillars','channelAssets','sevenDaySequence','riskChecks'],
      properties: {
        campaignTitle: {type: 'string'}, nucleus: {type: 'string'}, slogan: {type: 'string'},
        audienceInsight: {type: 'string'},
        contentPillars: {type: 'array', minItems: 3, maxItems: 5, items: {type: 'string'}},
        channelAssets: {type: 'array', minItems: 1, maxItems: 8, items: assetSchema},
        sevenDaySequence: {type: 'array', minItems: 3, maxItems: 7, items: {type: 'string'}},
        riskChecks: {type: 'array', minItems: 1, maxItems: 6, items: {type: 'string'}},
      },
    };
    const response = await callOpenAI({
      model: MODEL,
      instructions: [
        'You are the ORQUBE Fusion Campaign Engine.',
        'Use one campaign nucleus as the source of truth, then expand it into mutually reinforcing channel assets.',
        'Keep the same promise, facts and call-to-action across channels while adapting format and length.',
        'ORQUBE_OFFICIAL promotes the ORQUBE platform and ecosystem. TOKEN_PROMOTION promotes only the supplied creator token and its practical utility.',
        'Never mix official ORQUBE authority with a creator token. Clearly preserve who is speaking.',
        'Never promise token price, investment returns, guaranteed rewards, listing, or fundraising results.',
        'Reject or neutralize election persuasion, gambling, adult/sexual services, illegal activity, impersonation and deceptive claims.',
        'Generate drafts only. Every external publication requires human approval.',
        'Write in the requested language. Make each channel asset immediately editable and usable.',
      ].join('\n'),
      input: `FUSION CAMPAIGN BRIEF\n${JSON.stringify(input, null, 2)}`,
      text: {format: {type: 'json_schema', name: 'orqube_fusion_campaign', strict: true, schema: campaignSchema}},
    });
    const output = outputText(response);
    if (!output) throw new Error('EMPTY_AI_OUTPUT');
    const result = JSON.parse(output);
    const ref = db.collection('marketing_campaigns').doc();
    const record = {
      ownerUid: user.uid,
      ownerEmail: user.email || '',
      campaignType: type,
      campaignEngine: 'FUSION_V1',
      projectId: type === 'TOKEN_PROMOTION' ? projectId : '',
      tokenName: project ? clean(project.name, 100) : '',
      tokenSymbol: project ? clean(project.symbol, 20) : '',
      campaignName: input.campaignName,
      objective: input.objective,
      coreMessage: input.coreMessage,
      audience: input.audience,
      country: input.country,
      language: input.language,
      channels,
      nucleus: clean(result.nucleus, 1200),
      campaignTitle: clean(result.campaignTitle, 180),
      slogan: clean(result.slogan, 240),
      audienceInsight: clean(result.audienceInsight, 800),
      contentPillars: result.contentPillars || [],
      channelAssets: result.channelAssets || [],
      sevenDaySequence: result.sevenDaySequence || [],
      riskChecks: result.riskChecks || [],
      status: 'draft',
      approvalStatus: 'PENDING',
      humanApprovalRequired: true,
      externalPosting: 'OFF',
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    };
    await ref.set(record);
    return res.json({data: {id: ref.id, ...record, createdAt: null, updatedAt: null}});
  } catch (error) {
    console.error('createFusionMarketingCampaign', error);
    return res.status(Number(error.status || 500)).json({error: error.message || 'FUSION_MARKETING_ERROR'});
  }
});
