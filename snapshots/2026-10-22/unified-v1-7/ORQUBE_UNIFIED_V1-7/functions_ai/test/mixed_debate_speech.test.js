'use strict';
const {test} = require('node:test');
const assert = require('node:assert/strict');
const vm = require('node:vm');
const fs = require('node:fs');
const path = require('node:path');
const {speechProfile, SPEECH_VERSION} = require('../debate_speech_profiles');
function harness({uid = 'member', verified = true, providerOK = true, female = true} = {}) {
  let payload;
  const session = {ownerUid: 'owner', mixedRoomId: 'room', profiles: [0,1,2,3].map(() => ({gender: female ? 'female' : 'male'})), summary: '최종 요약입니다.', lines: [{panel: 3, text: '쟁점부터 짚죠.'}, {panel: 0, text: '그 근거가 뭐죠?'}]};
  const db = {collection: name => ({doc: () => ({get: async () => ({data: () => name === 'debate_sessions' ? session : name === 'mixed_debate_rooms' ? {memberUids:['owner','member']} : {}})})}),
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
test('mixed room member receives female moderator and summary voice', async () => {
  for (const text of ['쟁점부터 짚죠.', '최종 요약입니다.']) {
    const {res,payload} = await harness().request(3,text);
    assert.equal(res.statusCode,200); assert.equal(payload.voice,'coral');
    assert.equal(payload.model,'gpt-4o-mini-tts'); assert.match(payload.instructions,/female/);
  }
});
test('mixed male panel receives configured male voice', async () => {
  const {res,payload}=await harness({female:false}).request(0,'그 근거가 뭐죠?');
  assert.equal(res.statusCode,200); assert.equal(payload.voice,'onyx'); assert.match(payload.instructions,/male/);
});
test('mixed outsider and forged text cannot spend speech credits', async () => {
  for (const [settings,text] of [[{uid:'outsider'},'최종 요약입니다.'],[{},'가짜 발언']]) {
    const {res,payload}=await harness(settings).request(3,text);
    assert.equal(res.statusCode,403);assert.equal(payload,undefined);
  }
});
