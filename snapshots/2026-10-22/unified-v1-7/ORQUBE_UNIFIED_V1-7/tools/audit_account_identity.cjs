// Read-only. Use an authorized local Firebase Admin credential; never bundle it.
const {initializeApp, applicationDefault} = require('firebase-admin/app');
const {getAuth} = require('firebase-admin/auth');
const {getFirestore} = require('firebase-admin/firestore');
const [email, phone] = process.argv.slice(2);
if (!email && !phone) throw new Error('Usage: node tools/audit_account_identity.cjs EMAIL [+82PHONE]');
initializeApp({credential: applicationDefault()});
(async () => {
  const accounts = new Map();
  for (const [kind, value] of [['email',email],['phone',phone]]) {
    if (!value) continue;
    try {
      const user = kind === 'email' ? await getAuth().getUserByEmail(value) : await getAuth().getUserByPhoneNumber(value);
      accounts.set(user.uid,user);
    } catch (e) { if (e.code === 'auth/user-not-found') console.log(`${kind}: account not found`); else throw e; }
  }
  for (const user of accounts.values()) {
    const snap = await getFirestore().collection('users').doc(user.uid).get();
    const data = snap.data() || {};
    console.log(JSON.stringify({uid:user.uid,email:user.email,emailVerified:user.emailVerified,
      providers:user.providerData.map(x=>x.providerId),profileExists:snap.exists,
      orbs:data.orbs ?? null,points:data.points ?? null,role:data.role ?? 'user'},null,2));
  }
  if (accounts.size > 1) console.log('Different UIDs: balances remain separate. No changes were made.');
})().catch(e=>{console.error(e.message);process.exitCode=1;});
