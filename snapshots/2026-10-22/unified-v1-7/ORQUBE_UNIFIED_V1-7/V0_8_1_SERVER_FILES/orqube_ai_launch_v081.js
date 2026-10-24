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
const TEXT_MODEL = process.env.OPENAI_TEXT_MODEL || "gpt-5.6-luna";
const IMAGE_MODEL = process.env.OPENAI_IMAGE_MODEL || "gpt-image-1-mini";
const TEXT_LIMIT_PER_DAY = Number(process.env.AI_TEXT_LIMIT_PER_DAY || 30);
const LOGO_LIMIT_PER_DAY = Number(process.env.AI_LOGO_LIMIT_PER_DAY || 12);

function setCors(req, res) {
  const origin = req.get("origin") || "*";
  res.set("Access-Control-Allow-Origin", origin);
  res.set("Vary", "Origin");
  res.set("Access-Control-Allow-Headers", "Authorization, Content-Type");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
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

async function useDailyQuota(uid, kind, limit) {
  const ref = db.collection("ai_launch_usage").doc(uid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const current = snap.data() || {};
    const today = todayKey();
    const sameDay = current.day === today;
    const field = kind === "logo" ? "logoCount" : "textCount";
    const count = sameDay ? Number(current[field] || 0) : 0;
    if (count >= limit) {
      const error = new Error("DAILY_LIMIT");
      error.status = 429;
      throw error;
    }
    tx.set(ref, {
      day: today,
      [field]: count + 1,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    if (!sameDay) {
      tx.set(ref, {
        textCount: kind === "text" ? 1 : 0,
        logoCount: kind === "logo" ? 1 : 0,
      }, {merge: true});
    }
  });
}

function cleanString(value, max = 500) {
  const text = String(value || "").replace(/[\u0000-\u001f]+/g, " ").trim();
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

exports.generateLaunchLogoOptions = onRequest({
  region: REGION,
  timeoutSeconds: 180,
  memory: "1GiB",
  secrets: [OPENAI_API_KEY],
}, async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== "POST") return res.status(405).json({error: "METHOD_NOT_ALLOWED"});

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

    const styles = [
      "minimal geometric mark, crisp and modern",
      "premium emblem, symbolic but not literal, balanced negative space",
      "friendly abstract community symbol, distinctive and memorable",
    ];

    const buffers = await Promise.all(styles.map((style) => generateOneLogo(input, style)));
    const urls = [];
    for (let i = 0; i < buffers.length; i += 1) {
      urls.push(await saveLogo(user.uid, buffers[i], i + 1));
    }

    return res.json({
      data: {
        logos: urls.map((url, index) => ({
          url,
          style: ["MINIMAL", "EMBLEM", "COMMUNITY"][index],
        })),
        provider: "openai",
        model: IMAGE_MODEL,
      },
    });
  } catch (error) {
    console.error("generateLaunchLogoOptions", error);
    const status = Number(error.status || 500);
    const code = error.message === "DAILY_LIMIT" ? "DAILY_LIMIT" : "LOGO_SERVER_ERROR";
    return res.status(status).json({error: code});
  }
});
