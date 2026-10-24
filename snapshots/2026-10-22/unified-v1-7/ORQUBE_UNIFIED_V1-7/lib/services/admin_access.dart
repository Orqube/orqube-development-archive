import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAccess {
  static const ownerEmail = 'byd1009@naver.com';
  static Future<bool> allowed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    await user.reload();
    final current = FirebaseAuth.instance.currentUser;
    if (current == null || current.uid != user.uid || !current.emailVerified) return false;
    final token = await current.getIdTokenResult();
    if (token.claims?['email_verified'] != true) await current.getIdToken(true);
    final data = (await FirebaseFirestore.instance.collection('users').doc(current.uid).get()).data() ?? {};
    if (data['disabled'] == true) return false;
    if (current.email?.toLowerCase() == ownerEmail) return true;
    return data['role'] == 'admin' || data['isAdmin'] == true;
  }
}
