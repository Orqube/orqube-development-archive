'use strict';
const {test} = require('node:test');
const assert = require('node:assert/strict');
const vm = require('node:vm');
const fs = require('node:fs');
const path = require('node:path');
const {speechProfile, SPEECH_VERSION} = require('../debate_speech_profiles');
function harness({uid = 'owner', verified = true, providerOK = true} = {}) {
  let payload;
  const session = {ownerUid: 'owner', summary: '최종 요약입니다.', lines: [{panel: 3, text: '쟁점부터 짚죠.'}, {panel: 0, text: '그 근거가 뭐죠?'}]};
  const db = {collection: name => ({doc: () => ({get: async () => ({data: () => name === 'debate_sessions' ? session : {}})})}),
    runTransaction: async fn => fn({get: async () => ({data: () => ({})}), set: () => {}})};
  const context = {exports: {}, Buffer, AbortSignal, Date, console: {error() {}},
    fetch: async (_, args) => {payload = JSON.parse(args.body); return {ok: providerOK, arrayBuffer: async () => new Uint8Array([1, 2, 3]).buffer};},
    require: name => {
      if (name === 'firebase-functions/v2/https') return {onRequest: (_, handler) => handler};
      if (name === 'firebase-functions/params') return {defineSecret: () => ({value: () => 'test-key'}), defineBoolean: () => ({value: () => true})};
      if (name === 'firebase-admin/auth') return {getAuth: () => ({verifyIdToken: async () => ({uid, email_verified: verified})})};
      if (name === 'firebase-admin/firestore') return {getFirestore: () => db, Timestamp: {now: () => 0}};
      return require(path.resolve(__dirname, '..', name));
    }};
  vm.runInNewContext(fs.readFileSync(path.resolve(__dirname, '../debate_speech.js'), 'utf8'), context);
  const res = {statusCode: 200, headers: {}, set(k,v) {this.headers[k]=v; return this;}, status(n) {this.statusCode=n;return this;}, json(x) {this.body=x;return this;}, type(x) {this.contentType=x;return this;}, send(x) {this.body=x;return this;}};
  return {async request(panelIndex,text) {await context.exports.generateDebateSpeech({method: 'POST', get: () => 'Bearer token', body: {sessionId: 'session', panelIndex, text}}, res); return {res,payload};}};
}
test('moderator and final summary actually send fixed Onyx requests without unsupported instructions', async () => {
  for (const text of ['쟁점부터 짚죠.', '최종 요약입니다.']) {
    const {res,payload} = await harness().request(3, text);
    assert.equal(res.statusCode, 200);
    assert.equal(payload.model, 'tts-1-hd'); assert.equal(payload.voice, 'onyx');
    assert.equal(payload.input, text); assert.equal(payload.speed, 1.12);
    assert.equal(payload.instructions, undefined);
    assert.equal(res.headers['X-Debate-Speech-Version'], SPEECH_VERSION);
    assert.match(res.headers['Access-Control-Expose-Headers'], /X-Debate-Speech-Version/);
  }
});
test('expressive panel request includes faster pace and acting instructions', async () => {
  const {payload} = await harness().request(0, '그 근거가 뭐죠?');
  assert.equal(payload.model, 'gpt-4o-mini-tts'); assert.equal(payload.speed, 1.18);
  assert.match(payload.instructions, /rebuttals/);
  for (let i=0;i<5;i++) assert(speechProfile(i).speed > 1);
});
test('foreign owner and invented speech cannot call speech provider', async () => {
  for (const [settings, panel, text, status] of [[{uid:'other'},3,'최종 요약입니다.',403], [{},3,'가짜 발언',403], [{},4,'최종 요약입니다.',403]]) {
    const {res,payload}=await harness(settings).request(panel,text);
    assert.equal(res.statusCode,status); assert.equal(payload,undefined);
  }
});
test('provider failure stays an error rather than being returned as audio', async () => {
  const {res}=await harness({providerOK:false}).request(3,'쟁점부터 짚죠.');
  assert.equal(res.statusCode,502); assert.equal(res.body.error,'AI_SPEECH_PROVIDER_ERROR');
});

test('signed-in owner without email verification can play recorded speech', async () => { const {res,payload} = await harness({verified:false}).request(3, '쟁점부터 짚죠.'); assert.equal(res.statusCode,200); assert(payload); });
