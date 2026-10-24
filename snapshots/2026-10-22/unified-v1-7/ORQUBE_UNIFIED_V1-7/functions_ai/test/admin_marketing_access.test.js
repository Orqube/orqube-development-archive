'use strict';
const test=require('node:test'),assert=require('node:assert/strict'),fs=require('node:fs'),vm=require('node:vm');
const {isAdminIdentity}=require('../admin_access');
function harness(identity,profile={}){
 const exports={};
 const db={collection:()=>({doc:()=>({get:async()=>({exists:true,data:()=>profile})})})};
 const requireStub=n=>({
  './admin_access':{isAdminIdentity},'firebase-functions/v2/https':{onRequest:(o,f)=>f},
  'firebase-functions/params':{defineSecret:()=>({value:()=>''})},
  'firebase-admin/app':{getApps:()=>[{}],initializeApp(){}},
  'firebase-admin/auth':{getAuth:()=>({verifyIdToken:async()=>identity})},
  'firebase-admin/firestore':{getFirestore:()=>db,FieldValue:{serverTimestamp:()=>0}},
 }[n]||(()=>{throw Error(n)})());
 vm.runInNewContext(fs.readFileSync(require.resolve('../ai_token_marketing'),'utf8'),{require:requireStub,exports,process:{env:{}},console:{error(){}},fetch:()=>{throw Error('AI must not be called');}});
 return async name=>{const res={code:200,set(){},status(c){this.code=c;return this;},json(b){this.body=b;return this;},send(){}};await exports[name]({method:'POST',get:k=>k==='authorization'?'Bearer token':null,body:{}},res);return res;};
}
for(const name of ['startTokenLaunchMarketing','createFusionMarketingCampaign','manageFusionMarketingCampaign']){
 test(name+' blocks ordinary verified members before reading payload or calling AI',async()=>{const r=await harness({uid:'member',email:'member@example.com',email_verified:true})(name);assert.equal(r.code,403);assert.equal(r.body.error,'ADMIN_REQUIRED');});
 test(name+' blocks unverified owner',async()=>{const r=await harness({uid:'owner',email:'byd1009@naver.com',email_verified:false})(name);assert.equal(r.code,403);});
 test(name+' accepts verified owner identity then validates input',async()=>{const r=await harness({uid:'owner',email:'byd1009@naver.com',email_verified:true})(name);assert.equal(r.code,400);assert.notEqual(r.body.error,'ADMIN_REQUIRED');});
}
test('disabled administrator cannot authorize',()=>assert.equal(isAdminIdentity({email:'byd1009@naver.com',email_verified:true},{disabled:true}),false));
