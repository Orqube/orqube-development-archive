import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'referral_service.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static User? get currentUser => auth.currentUser;

  static Future<void> createUserProfileIfNeeded() async {
    final user = auth.currentUser;
    if (user == null) return;

    final ref = db.collection('users').doc(user.uid);
    await db.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (auth.currentUser?.uid != user.uid) return;
      if (!doc.exists) {
        transaction.set(ref, {
          'uid': user.uid,
          'email': user.email ?? '',
          'nickname': user.displayName ?? 'OrqubeUser',
          'level': 15,
          'points': 1260,
          'orbs': 126.0,
          'attendance': 12,
          // 기존 ORQUBE 필드를 유지하면서 친구초대용 카운트도 함께 둡니다.
          'referral': 5,
          'referralCount': 0,
          'walletAddress': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
    if (auth.currentUser?.uid != user.uid) return;

    // 아래 세 작업은 친구초대 기능의 부가 초기화입니다.
    // Firestore rules가 아직 배포되지 않았거나 일시적인 네트워크 오류가 있어도
    // 사용자의 정상 로그인/대시보드 진입은 절대 막지 않습니다.
    try {
      await ReferralService.instance.ensureInviteIdentity(user);
    } catch (error, stackTrace) {
      debugPrint('[ORQUBE ensureInviteIdentity] $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    // URL에 ?ref=초대코드가 있으면 기존 사용자 문서가 이미 있어도 1회 연결을
    // 다시 시도합니다. registerReferral 내부에서 자기 추천/중복 추천을 차단합니다.
    if (auth.currentUser?.uid != user.uid) return;
    try {
      await ReferralService.instance.applyReferralFromCurrentUri(user);
    } catch (error, stackTrace) {
      debugPrint('[ORQUBE applyReferral] $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (auth.currentUser?.uid != user.uid) return;
    try {
      await ReferralService.instance.claimPendingRewards(user);
    } catch (error, stackTrace) {
      debugPrint('[ORQUBE claimReferralRewards] $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<void> addDailyMiningReward() async {
    final user = auth.currentUser;
    if (user == null) return;

    final ref = db.collection('users').doc(user.uid);

    await ref.set({
      'points': FieldValue.increment(10),
      'orbs': FieldValue.increment(1.0),
      'lastMiningAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    return db.collection('users').doc(user.uid).snapshots();
  }
}
