// Creates Firebase custom tokens for the trusted ORQUBE session bridge.
// Firebase Admin verifies the caller's real ID token, including revocation.
const {onRequest} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
exports.sharedAuthToken = onRequest({region:'asia-northeast3',maxInstances:5,timeoutSeconds:30},async(req,res)=>{
 res.set('Cache-Control','no-store');
 if(req.method!=='POST')return res.status(405).json({error:'METHOD'});
 const token=(req.get('Authorization')||'').match(/^Bearer (.+)$/)?.[1];
 if(!token||token.length>8192)return res.status(401).json({error:'AUTH_REQUIRED'});
 try{const decoded=await admin.auth().verifyIdToken(token,true);const user=await admin.auth().getUser(decoded.uid);if(user.disabled)return res.status(401).json({error:'ACCOUNT_DISABLED'});const customToken=await admin.auth().createCustomToken(user.uid);return res.json({customToken});}
 catch(e){console.error('Shared sign-in error:',e.code||'AUTH_FAILED');return res.status(e.code==='auth/insufficient-permission'||e.code==='iam.serviceAccounts.signBlob'?503:401).json({error:'AUTH_FAILED'});}
});
