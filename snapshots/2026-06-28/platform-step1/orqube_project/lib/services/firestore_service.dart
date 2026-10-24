import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> userRef(String uid) => _db.collection('users').doc(uid);

  Future<UserProfile> loadOrCreateProfile(User user) async {
    final ref = userRef(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      final profile = UserProfile.defaultProfile(nickname: user.email?.split('@').first ?? 'OrqubeUser');
      await ref.set({...profile.toMap(), 'email': user.email ?? '', 'createdAt': FieldValue.serverTimestamp()});
      return profile;
    }
    return UserProfile.fromMap(snap.data()!);
  }

  Future<void> saveProfile(String uid, UserProfile profile) async {
    await userRef(uid).set({...profile.toMap(), 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
}
