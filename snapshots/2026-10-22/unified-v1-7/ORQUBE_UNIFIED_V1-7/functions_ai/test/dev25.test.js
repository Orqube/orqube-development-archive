'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const vm = require('node:vm');
const fs = require('node:fs');
const {isAdminIdentity} = require('../admin_access');
function load(name, token, initial = {}, overrides = {}) {
  const records = new Map(Object.entries(initial));
  const ref = path => ({path, id: path.split('/').pop(), collection: n => ({doc: (id='new') => ref(`${path}/${n}/${id}`)}),
    get: async () => ({exists: records.has(path), data: () => records.get(path)}), set: async value => records.set(path, value)});
  const db = {collection: name => ({doc: (id='new') => ref(`${name}/${id}`)}), runTransaction: async fn => fn({get: r => r.get(), set: (r,v) => records.set(r.path,v), update: (r,v) => records.set(r.path,{...records.get(r.path),...v}), create: (r,v) => records.set(r.path,v)})};
  const modules = {
    'firebase-functions/v2/https': {onRequest: (options, fn) => { fn.options = options; return fn; }},
    'firebase-functions/params': {defineSecret: () => ({value: () => 'test-key'}), defineBoolean: () => ({value: () => overrides.enabled !== false})},
    'firebase-admin/app': {getApps: () => [{}]},
    'firebase-admin/auth': {getAuth: () => ({verifyIdToken: async (value, revoked) => { assert.equal(revoked,true); if (overrides.authError) throw Object.assign(new Error('expired'), {code: overrides.authError}); return token; }})},
    'firebase-admin/firestore': {getFirestore: () => db, FieldValue: {serverTimestamp: () => 'timestamp'}, Timestamp: {now: () => ({toMillis: () => Date.now()})}},
    './admin_access': {isAdminIdentity},
    './debate_output': require('../debate_output'),
    './debate_comedy': require('../debate_comedy'),
    './debate_presentation': require('../debate_presentation'),
    './debate_speech_profiles': require('../debate_speech_profiles'),
    './debate_speech_access': require('../debate_speech_access'),
    './debate_speech': {},
    './live_debate_rooms': {},
  };
  const exports = {};
  vm.runInNewContext(fs.readFileSync(require.resolve(`../${name}`),'utf8'), {require: n => modules[n], exports, console: {error(){}}, Buffer, process: {env:{}}, Date, AbortSignal,
    fetch: async (url, options) => { if (overrides.requests) overrides.requests.push(JSON.parse(options.body)); if (overrides.speech) { overrides.speech.push(JSON.parse(options.body)); return {ok:true, arrayBuffer: async () => new Uint8Array([1,2,3]).buffer}; } if (overrides.fetchError) throw Object.assign(new Error('timeout'), {name: overrides.fetchError}); return ({ok:true, json: async () => ({output_text: JSON.stringify(overrides.output || {panelA:[{order:0,stage:'입론',text:'AI test'}],panelB:[{order:2,stage:'반박',text:'AI test'}],panelC:[{order:1,stage:'검토',text:'AI test'}],summary:'실제 토론 요약',checks:['출처 확인']})})}); }});
  return {exports, records};
}
async function request(fn, body, authenticated=true) {
  let status=200, data;
  const req = {method:'POST', body, get: n => n === 'authorization' && authenticated ? 'Bearer test' : ''};
  const res = {set(){},status(s){status=s;return this;},json(x){data=x;return this;},type(){return this;},send(x){data=x;}};
  await fn(req,res); return {status,data};
}
test('verified owner gets server admin without client role flag',()=>assert.equal(isAdminIdentity({email:'byd1009@naver.com',email_verified:true}),true));
test('unverified owner and unverified role admin denied',()=>{
  assert.equal(isAdminIdentity({email:'byd1009@naver.com',email_verified:false}),false);
  assert.equal(isAdminIdentity({email:'other@example.com',email_verified:false},{role:'admin'}),false);
});
test('ordinary verified user cannot impersonate admin',()=>assert.equal(isAdminIdentity({email:'other@example.com',email_verified:true}),false));
test('campaign owner submits, cannot approve, cannot publish before approval', async()=>{
  const {exports:e,records} = load('ai_token_marketing.js',{uid:'owner',email_verified:true,email:'owner@example.com'},{'marketing_campaigns/c':{ownerUid:'owner',status:'draft',channels:['X'],campaignType:'TOKEN_PROMOTION'}});
  assert.equal((await request(e.manageFusionMarketingCampaign,{campaignId:'c',action:'SUBMIT'})).status,200);
  assert.equal(records.get('marketing_campaigns/c').status,'pending');
  assert.equal((await request(e.manageFusionMarketingCampaign,{campaignId:'c',action:'APPROVE'})).status,403);
  assert.equal((await request(e.manageFusionMarketingCampaign,{campaignId:'c',action:'RECORD_PUBLISH',channel:'X',publishedUrl:'https://x.com/test'})).status,409);
});
test('verified designated admin approves and logs publication; HTTP/channel validation',async()=>{
  const {exports:e,records} = load('ai_token_marketing.js',{uid:'admin',email_verified:true,email:'byd1009@naver.com'},{'marketing_campaigns/c':{ownerUid:'owner',status:'pending',channels:['X'],campaignType:'TOKEN_PROMOTION'}});
  assert.equal((await request(e.manageFusionMarketingCampaign,{campaignId:'c',action:'APPROVE'})).status,200);
  assert.equal((await request(e.manageFusionMarketingCampaign,{campaignId:'c',action:'RECORD_PUBLISH',channel:'X',publishedUrl:'http://x.com/test'})).status,400);
  assert.equal((await request(e.manageFusionMarketingCampaign,{campaignId:'c',action:'RECORD_PUBLISH',channel:'X',publishedUrl:'https://x.com/test'})).status,200);
  assert.equal(records.get('marketing_campaigns/c/distribution_logs/new').recordedBy,'admin');
});
test('unverified owner-email cannot approve or generate official campaign',async()=>{
  const {exports:e} = load('ai_token_marketing.js',{uid:'a',email_verified:false,email:'byd1009@naver.com'},{'marketing_campaigns/c':{ownerUid:'x',status:'pending'}});
  assert.equal((await request(e.manageFusionMarketingCampaign,{campaignId:'c',action:'APPROVE'})).status,403);
  assert.equal((await request(e.createFusionMarketingCampaign,{campaignType:'ORQUBE_OFFICIAL'})).status,403);
});
test('missing auth denied; outsider cannot submit another campaign',async()=>{
  const {exports:e} = load('ai_token_marketing.js',{uid:'other',email_verified:true},{'marketing_campaigns/c':{ownerUid:'owner',status:'draft'}});
  assert.equal((await request(e.manageFusionMarketingCampaign,{campaignId:'c',action:'SUBMIT'},false)).status,401);
  assert.equal((await request(e.manageFusionMarketingCampaign,{campaignId:'c',action:'SUBMIT'})).status,403);
});
test('signed-in debate user does not need separate email verification',async()=>{
  const {exports:e} = load('ai_debate.js',{uid:'a',email_verified:false});
  assert.equal((await request(e.generateThreeWayDebate,{topic:'도시 교통 정책'})).status,200);
});
test('debate records distinct ABC panels and unverified status, repeated call rate limited',async()=>{
  const {exports:e,records} = load('ai_debate.js',{uid:'a',email_verified:true});
  const response = await request(e.generateThreeWayDebate,{topic:'도시 교통 정책',question:'비용 부담은?'});
  assert.equal(response.status,200);
  assert.deepEqual(Array.from(response.data.data.lines,x=>x.panel),[4,0,2,1]);
  assert.equal(response.data.data.lines[0].text, '시민패널입니다. 비용 부담은?');
  assert.equal(records.get('debate_sessions/new').verificationStatus,'UNVERIFIED');
  assert.equal((await request(e.generateThreeWayDebate,{topic:'도시 교통 정책'})).status,429);
});
test('invalid AI output missing B is rejected',async()=>{
  const {exports:e} = load('ai_debate.js',{uid:'a',email_verified:true},{},{output:{lines:[{panel:0,text:'x'}],summary:'x',checks:[]}});
  assert.equal((await request(e.generateThreeWayDebate,{topic:'도시 교통 정책'})).status,502);
});

test('debate transport accepts browser preflight and health GET without spending credits', async()=>{
  const {exports:e, records} = load('ai_debate.js', null);
  assert.equal(e.generateThreeWayDebate.options.invoker, 'public');
  assert.equal(e.generateThreeWayDebate.options.cors, true);
  for (const method of ['OPTIONS', 'GET']) {
    let status=200, data;
    const res={set(){}, status(x){status=x;return this;}, send(){}, json(x){data=x;return this;}};
    await e.generateThreeWayDebate({method}, res);
    assert.equal(status, method==='OPTIONS' ? 204 : 200);
    if (method==='GET') assert.equal(data.enabled, true);
  }
  assert.equal(records.size, 0);
});
test('disabled debate, expired token and provider timeout return distinct errors', async()=>{
  const cases=[
    [{enabled:false},503,'DEV_DEBATE_DISABLED'],
    [{authError:'auth/id-token-expired'},401,'AUTH_EXPIRED'],
    [{fetchError:'TimeoutError'},504,'AI_TIMEOUT'],
  ];
  for (const [override,status,error] of cases) {
    const {exports:e}=load('ai_debate.js',{uid:'a',email_verified:true},{},override);
    const result=await request(e.generateThreeWayDebate,{topic:'교통 정책'});
    assert.equal(result.status,status);
    assert.equal(result.data.error,error);
  }
});

test('moderator and citizen speech are authorized only against the owner session text', async()=>{
  for (const panel of [3,4]) {
    const sent=[];
    const text=panel===4 ? '시민패널입니다. 비용은?' : '핵심 질문으로 돌아가죠.';
    const {exports:e}=load('debate_speech.js',{uid:'owner',email_verified:true},{'debate_sessions/session':{ownerUid:'owner',lines:[{panel,text}],summary:'최종 요약'}},{speech:sent});
    const body={sessionId:'session',panelIndex:panel,text};
    assert.equal((await request(e.generateDebateSpeech,{...body,text:'임의의 다른 텍스트'})).status,403);
    assert.equal((await request(e.generateDebateSpeech,body)).status,200);
    assert.equal(sent[0].voice,panel===4?'coral':'onyx');
    assert.equal(sent[0].input,text);
    const outsider=load('debate_speech.js',{uid:'other',email_verified:true},{'debate_sessions/session':{ownerUid:'owner',lines:[{panel,text}]}},{speech:[]});
    assert.equal((await request(outsider.exports.generateDebateSpeech,body)).status,403);
  }
});

test('comedy request uses dedicated comedy instructions and returns deployed version', async()=>{
 const requests=[];
 const {exports:e}=load('ai_debate.js',{uid:'a',email_verified:true},{},{requests});
 const response=await request(e.generateThreeWayDebate,{topic:'엘리베이터 수리',comedy:true});
 assert.equal(response.status,200);
 assert.match(requests[0].instructions,/설정→되받기→반전/);
 assert.doesNotMatch(requests[0].instructions,/과장된 추임새, 유행어/);
 assert.equal(response.data.data.comedyApplied,true);
 assert.equal(response.data.data.comedyVersion,'dev34-comedy-v2');
});
test('normal debate and final summary do not use comedy scene prompt',async()=>{
 for(const summarize of [false,true]){
  const requests=[];
  const {exports:e}=load('ai_debate.js',{uid:'a',email_verified:true},{},{requests});
  const response=await request(e.generateThreeWayDebate,{topic:'교통 정책',comedy:summarize,summarize});
  assert.equal(response.status,200);
  assert.doesNotMatch(requests[0].instructions,/설정→되받기→반전/);
  assert.equal(response.data.data.comedyApplied,false);
 }
});

test('presentation endpoint selects its own prompt and schema and preserves speaker-linked visuals', async () => {
  const requests=[];
  const output={panelA:[{order:0,stage:'가치',text:'설계부터 확인하죠',visualId:'token'}],
    panelB:[{order:1,stage:'조건',text:'상태 확인이 필요하죠',visualId:'token'}],
    panelC:[{order:2,stage:'사례',text:'현장 검증은요?',visualId:'qr'}],
    moderator:[],summary:'확인할 과제가 있습니다',checks:['구현 상태']};
  const {exports:e,records}=load('ai_debate.js',{uid:'owner',email_verified:true},{},{requests,output});
  const response=await request(e.generateThreeWayDebate,{topic:'ORQUBE 미래',presentation:true,comedy:true,
    visuals:[{id:'token',title:'토큰 생성',status:'개발 중'},{id:'qr',title:'QR 보상'}]});
  assert.equal(response.status,200); assert.equal(response.data.data.presentationVersion,1);
  assert.equal(response.data.data.comedyApplied,false);
  assert.equal(response.data.data.lines[2].visualId,'qr');
  assert.match(requests[0].instructions,/자료 동반형/);
  assert.deepEqual(Array.from(requests[0].text.format.schema.properties.panelA.items.properties.visualId.enum),['','token','qr']);
  assert.equal(records.get('debate_sessions/new').visuals[0].status,'개발 중');
});
test('presentation rejects missing materials before charging usage and keeps summary grounded', async () => {
  const requests=[];
  const {exports:e,records}=load('ai_debate.js',{uid:'owner',email_verified:true},{},{requests});
  assert.equal((await request(e.generateThreeWayDebate,{topic:'ORQUBE',presentation:true})).status,400);
  assert.equal(records.has('ai_usage_limits/owner'),false);
  const response=await request(e.generateThreeWayDebate,{topic:'ORQUBE',presentation:true,summarize:true,
    visuals:[{id:'token',title:'토큰'}],history:[{panel:'A',text:'확인이 필요해요'}]});
  assert.equal(response.status,200); assert.equal(response.data.data.presentationVersion,1);
  assert.match(requests[0].instructions,/실제.*발언/);
  assert.doesNotMatch(requests[0].instructions,/진보적 개혁/);
});
