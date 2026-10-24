import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirestoreService firestore = FirestoreService();

  Future<UserProfile> emailSignUp(String email, String password) async {
    final result = await auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
    return firestore.loadOrCreateProfile(result.user!);
  }

  Future<UserProfile> emailLogin(String email, String password) async {
    final result = await auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
    return firestore.loadOrCreateProfile(result.user!);
  }

  Future<UserProfile?> googleLogin() async {
    final gUser = await GoogleSignIn().signIn();
    if (gUser == null) return null;
    final gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);
    final result = await auth.signInWithCredential(credential);
    return firestore.loadOrCreateProfile(result.user!);
  }

  Future<void> logout() async {
    await auth.signOut();
    await GoogleSignIn().signOut();
  }
}
