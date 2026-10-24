'use strict';
const test=require('node:test'),assert=require('node:assert/strict'),Module=require('node:module');
const store=new Map();let serial=0,user={uid:'host',name:'Host',email_verified:true}, aiInput,generateCalls=0;
const timestamp=ms=>({toMillis:()=>ms});
class Ref{
 constructor(path){this.path=path;this.id=path.split('/').at(-1);}
 collection(name){return new Collection(this.path+'/'+name);}
 async get(){return {exists:store.has(this.path),data:()=>store.get(this.path)};}
 async set(data){store.set(this.path,data);}
}
class Collection{
 constructor(path){this.path=path;this.filters=[];}
 doc(id='doc'+(++serial)){return new Ref(this.path+'/'+id);}
 where(field,op,value){this.filters.push([field,op,value]);return this;}
 orderBy(field,dir){this.sort=[field,dir];return this;}
 limit(n){this.n=n;return this;}
 async get(){let entries=[...store].filter(([path])=>path.startsWith(this.path+'/')&&path.slice(this.path.length+1).indexOf('/')<0).filter(([,r])=>this.filters.every(([f,op,v])=>op==='array-contains'?r[f]?.includes(v):r[f]===v));if(this.sort){const [f,dir]=this.sort;entries.sort((a,b)=>(a[1][f]-b[1][f])*(dir==='desc'?-1:1));}return {docs:entries.slice(0,this.n??100).map(([p,r])=>({id:p.split('/').at(-1),data:()=>r}))};}
}
const db={collection:p=>new Collection(p),runTransaction:async fn=>{let writes=[];const r=await fn({get:async ref=>{assert.equal(writes.length,0,'Firestore reads must precede writes');return ref.get();},set:(ref,d)=>writes.push(()=>store.set(ref.path,d)),update:(ref,d)=>writes.push(()=>store.set(ref.path,{...store.get(ref.path),...d}))});writes.forEach(f=>f());return r;}};
const load=Module._load;
Module._load=function(name,...args){if(name==='firebase-functions/v2/https')return {onRequest:(_,fn)=>fn};if(name==='firebase-functions/params')return {defineSecret:()=>({value:()=> 'test-key'}),defineBoolean:()=>({value:()=>true})};if(name==='firebase-admin/auth')return {getAuth:()=>({verifyIdToken:async()=>user})};if(name==='firebase-admin/firestore')return {getFirestore:()=>db,Timestamp:{now:()=>timestamp(Date.now()),fromMillis:timestamp}};return load.call(this,name,...args);};
const handlers=require('../mixed_debate_rooms');Module._load=load;
global.fetch=async(url,options)=>{generateCalls++;aiInput=JSON.parse(options.body);return {ok:true,json:async()=>({output:[{content:[{type:'output_text',text:JSON.stringify({lines:[{panel:0,text:'AI 반박',stage:'반박'},{panel:1,text:'가짜 사람 발언',stage:'발언'}],summary:'실제 기록 요약'})}]}]})};};
async function call(action,data={},fn='manageMixedDebateRoom'){for(const key of store.keys())if(key.startsWith('mixed_debate_usage/'))store.delete(key);let status=200,result;await handlers[fn]({method:'POST',get:()=> 'Bearer token',body:{action,...data}},{set(){},status(n){status=n;return this;},json(v){result=v;return this;}});return {status,result};}
const ps=()=>[0,1,2,3].map(i=>({name:'P'+i,type:i===1?'human':'ai',uid:i===1?'human':'',gender:i===0?'female':'male',appearance:'외모에만 쓰는 수염',personality:'직설적',speakingStyle:'짧은 반문',ideology:'개혁 관점'}));
test('room lifecycle and authorization with human/AI separation',async()=>{
 let r=await call('create',{name:'Test',topic:'정책 토론',minutes:1,visibility:'private',profiles:ps()});assert.equal(r.status,200);const roomId=r.result.roomId,ref='mixed_debate_rooms/'+roomId;const invite=store.get(ref).inviteToken;
 user={uid:'human',email_verified:true};assert.equal((await call('join',{roomId})).status,403);assert.equal((await call('join',{roomId,inviteToken:invite})).status,200);
 assert.equal((await call('configure',{roomId,profiles:ps()})).status,403);
 assert.equal((await call('start',{roomId})).status,403);
 user={uid:'host',email_verified:false};assert.equal((await call('configure',{roomId,profiles:ps()})).status,200);assert.equal((await call('start',{roomId})).status,200);
 user={uid:'observer',email_verified:true};assert.equal((await call('join',{roomId,inviteToken:invite})).status,200);assert.equal((await call('send',{roomId,text:'forged',requestId:'1'})).status,403);
 assert.equal((await call('question',{roomId,text:'시민 질문',requestId:'q'})).status,200);const before=store.get(ref).sequence;await call('question',{roomId,text:'시민 질문',requestId:'q'});assert.equal(store.get(ref).sequence,before,'request retry must not duplicate');
 user={uid:'human',email_verified:true};assert.equal((await call('send',{roomId,text:'실제 사람 발언',requestId:'h'})).status,200);
 user={uid:'host',email_verified:true};r=await call('generate',{roomId},'generateMixedDebate');assert.equal(r.status,200);assert.equal(store.get(ref).pending.length,1,'human AI fabrication removed');
 const input=JSON.parse(aiInput.input);assert.equal(input.profiles[0].personality,'직설적');assert.equal(input.profiles[0].ideology,'개혁 관점');assert.equal(input.profiles[0].appearance,undefined,'appearance excluded from speech prompt');assert.ok(input.history.some(m=>m.text==='실제 사람 발언'));
 const sequence=store.get(ref).sequence;await call('publish',{roomId,sequence});await call('publish',{roomId,sequence});assert.equal(store.get(ref).sequence,sequence+1,'publish cursor idempotence');
 user={uid:'observer',email_verified:true};assert.equal((await call('summary',{roomId,summarize:true},'generateMixedDebate')).status,403);
 user={uid:'host',email_verified:true};r=await call('summary',{roomId,summarize:true},'generateMixedDebate');assert.equal(r.status,200);assert.equal(store.get(ref).status,'ended');assert.equal(store.get(ref).summary,'실제 기록 요약');assert.equal((await call('send',{roomId,text:'after end',requestId:'2'})).status,409);
 assert.equal((await call('recording',{roomId,filename:'record.webm'})).status,200);assert.equal((await call('configure',{roomId,profiles:ps()})).status,409);
 const sid=store.get(ref).summarySessionId;assert.equal(store.get('debate_sessions/'+sid).profiles[0].gender,'female');
});
test('profile sanitizer requires four seats and preserves separate fields',()=>{const {profiles}=require('../mixed_debate_policy');assert.throws(()=>profiles([]));assert.throws(()=>profiles(ps().map(p=>({...p,imageBase64:'<html>'}))));const p=profiles(ps())[0];assert.equal(p.appearance,'외모에만 쓰는 수염');assert.equal(p.gender,'female');});

test('mixed rooms reject over 30 minutes and cap legacy waiting rooms at start',async()=>{
 user={uid:'host',email_verified:true};
 for(const minutes of [31,60,120])assert.equal((await call('create',{name:'Limit',topic:'시간 검증',minutes,profiles:ps()})).status,400);
 const seats=ps().map(p=>({...p,type:'ai',uid:''}));
 const r=await call('create',{name:'Limit',topic:'시간 검증',minutes:30,profiles:seats});
 assert.equal(r.status,200);const roomId=r.result.roomId,ref='mixed_debate_rooms/'+roomId;
 store.get(ref).minutes=120;const before=Date.now();
 assert.equal((await call('start',{roomId})).status,200);
 assert.equal(store.get(ref).minutes,30);
 assert.ok(store.get(ref).endAt.toMillis()-before<=1800100);
 store.get(ref).endAt=timestamp(Date.now()-1);
 assert.equal((await call('question',{roomId,text:'late',requestId:'late'})).status,409);
});
