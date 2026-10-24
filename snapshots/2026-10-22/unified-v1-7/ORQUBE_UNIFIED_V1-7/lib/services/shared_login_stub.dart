import 'package:firebase_auth/firebase_auth.dart';
// Firebase native authentication already persists across app restarts.
// Browser cookie sharing is initialized only by the web implementation.
Future<void> startSharedLogin() async {}

Future<void> sharedSignOut() => FirebaseAuth.instance.signOut();
