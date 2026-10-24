'use strict';
const {onRequest} = require('firebase-functions/v2/https');
const {defineSecret, defineBoolean} = require('firebase-functions/params');
const {getAuth} = require('firebase-admin/auth');
const {getFirestore, Timestamp} = require('firebase-admin/firestore');
const KEY = defineSecret('OPENAI_API_KEY');
const ENABLED = defineBoolean('DEBATE_ENABLED', {default: false});
// Original synthetic voices. No real-person recordings or voice cloning.
const {speechProfile, SPEECH_VERSION} = require('./debate_speech_profiles');
const {canSpeak} = require('./debate_speech_access');
exports.generateDebateSpeech = onRequest({region: 'asia-northeast3', timeoutSeconds: 90, secrets: [KEY], cors: true, invoker: 'public'}, async (req, res) => {
  res.set('Cache-Control', 'no-store');
  res.set('Access-Control-Expose-Headers', 'X-Debate-Speech-Version, X-Debate-Voice');
  res.set('X-Debate-Speech-Version', SPEECH_VERSION);
  if (req.method === 'OPTIONS') return res.status(204).send('');
  if (req.method !== 'POST') return res.status(405).json({error: 'METHOD_NOT_ALLOWED'});
  if (!ENABLED.value()) return res.status(503).json({error: 'DEV_DEBATE_DISABLED'});
  try {
    const match = (req.get('authorization') || '').match(/^Bearer\s+(.+)$/i);
    if (!match) return res.status(401).json({error: 'AUTH_REQUIRED'});
    const user = await getAuth().verifyIdToken(match[1], true);
    const {sessionId, text, panelIndex} = req.body || {};
    if (typeof sessionId !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(sessionId) || !Number.isInteger(panelIndex) || panelIndex < 0 || panelIndex > 4 || typeof text !== 'string' || !text.trim() || text.length > 4096) return res.status(400).json({error: 'INVALID_SPEECH_REQUEST'});
    const db = getFirestore();
    const session = (await db.collection('debate_sessions').doc(sessionId).get()).data();
    let permitted = canSpeak(session, user.uid, panelIndex, text);
    if (session?.mixedRoomId) {
      const room = (await db.collection('mixed_debate_rooms').doc(session.mixedRoomId).get()).data();
      permitted = !!room && room.memberUids.includes(user.uid) &&
        ((panelIndex === 3 && session.summary === text) || (session.lines || []).some(x => x.panel === panelIndex && x.text === text));
    }
    if (!permitted) return res.status(403).json({error: 'SESSION_ACCESS_DENIED'});
    const guard = db.collection('ai_speech_limits').doc(user.uid);
    await db.runTransaction(async tx => {
      const d = (await tx.get(guard)).data() || {};
      const day = new Date().toISOString().slice(0,10);
      const count = d.day === day ? Number(d.count || 0) : 0;
      if (count >= 360 || (d.lastAt && Date.now() - d.lastAt.toMillis() < 1000)) throw Object.assign(new Error('RATE_LIMIT'), {status: 429});
      tx.set(guard, {day, count: count + 1, lastAt: Timestamp.now()});
    });
    const profile = speechProfile(panelIndex);
    if (session.mixedRoomId && panelIndex < 4) {
      const female = session.profiles?.[panelIndex]?.gender === 'female';
      profile.model = 'gpt-4o-mini-tts';
      profile.voice = female ? ['coral','nova','shimmer','coral'][panelIndex] : ['onyx','echo','ash','onyx'][panelIndex];
      profile.instructions = 'Natural Korean conversational debate, original '+(female?'female':'male')+' voice. Clear quick delivery and short breaths. Never imitate a real person.';
    }
    res.set('X-Debate-Voice', profile.voice);
    const response = await fetch('https://api.openai.com/v1/audio/speech', {
      method: 'POST', signal: AbortSignal.timeout(60000),
      headers: {Authorization: `Bearer ${KEY.value()}`, 'Content-Type': 'application/json'},
      body: JSON.stringify({input: text, response_format: 'mp3', ...profile}),
    });
    if (!response.ok) return res.status(502).json({error: 'AI_SPEECH_PROVIDER_ERROR'});
    return res.type('audio/mpeg').send(Buffer.from(await response.arrayBuffer()));
  } catch (e) {
    console.error('generateDebateSpeech', e.name, e.code || e.status || '');
    if (String(e.code || '').startsWith('auth/')) return res.status(401).json({error: 'AUTH_EXPIRED'});
    if (e.name === 'TimeoutError' || e.name === 'AbortError') return res.status(504).json({error: 'AI_TIMEOUT'});
    return res.status(e.status || 500).json({error: e.status ? e.message : 'SPEECH_ERROR'});
  }
});
