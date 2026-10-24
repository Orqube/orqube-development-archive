'use strict';
const {test}=require('node:test');
const assert=require('node:assert/strict');
const {publicRow,createHandlers}=require('../mobile_studio_bridge');
const address='0x'+'1'.repeat(40);
function response(){return {code:200,headers:{},set(k,v){this.headers[k]=v;return this},status(n){this.code=n;return this},json(body){this.body=body;return this},send(body){this.body=body;return this}}}
function fixture(owner='owner'){
 let policyCalls=0;
 const handlers=createHandlers({loadPolicy:async()=>{policyCalls++;return {enabled:true,kaiFee:10,orbsFee:100,treasuryAddress:address}},testMode:true,deps:{onRequest:(_,h)=>h,db:{collection:()=>({doc:()=>({get:async()=>({exists:true,data:()=>({ownerUid:owner})})})})},getAuth:()=>({verifyIdToken:async token=>{assert.equal(token,'valid');return {uid:'owner'}}})}});
 return {handlers,calls:()=>policyCalls};
}
const req=(body,authorization)=>({method:'POST',body,get:key=>key==='authorization'?authorization:undefined});
test('public feed excludes private drafts and invalid contract addresses',()=>{
 assert.equal(publicRow('secret',{status:'draft',contractAddress:address}),null);
 assert.equal(publicRow('bad',{status:'published',contractAddress:'fake'}),null);
 const row=publicRow('ok',{status:'published',contractAddress:address,privateKey:'DO_NOT_EXPOSE',ownerUid:'secret',logoSpec:{shape:'hexagon',palette:'green'}});
 assert.equal(row.privateKey,undefined);assert.equal(row.ownerUid,undefined);assert.deepEqual(row.logoSpec,{shape:'hexagon',palette:'green'});
});
test('verification cannot migrate from a different contract',()=>{
 const p={status:'published',contractAddress:address};
 assert.equal(publicRow('x',p,{contractAddress:'0x'+'2'.repeat(40),verificationStatus:'VERIFIED'}).sourceVerificationStatus,'UNCONFIRMED');
 assert.equal(publicRow('x',p,{contractAddress:address,verificationStatus:'VERIFIED'}).sourceVerificationStatus,'VERIFIED');
});
test('policy requires authentication and ownership before loading fee data',async()=>{
 const f=fixture();let res=response();await f.handlers.getMobileStudioPolicy(req({projectId:'p'}),res);assert.equal(res.code,401);assert.equal(f.calls(),0);
 const other=fixture('someone-else');res=response();await other.handlers.getMobileStudioPolicy(req({projectId:'p'},'Bearer valid'),res);assert.equal(res.code,403);assert.equal(other.calls(),0);
});
test('policy validates project ID and returns only selected fields',async()=>{
 const f=fixture();let res=response();await f.handlers.getMobileStudioPolicy(req({projectId:'p/secret'},'Bearer valid'),res);assert.equal(res.code,400);assert.equal(f.calls(),0);
 res=response();await f.handlers.getMobileStudioPolicy(req({projectId:'p'},'Bearer valid'),res);assert.equal(res.code,200);assert.equal(res.body.data.effectiveKaiFee,10);assert.equal(res.body.data.treasuryAddress,address);
});
