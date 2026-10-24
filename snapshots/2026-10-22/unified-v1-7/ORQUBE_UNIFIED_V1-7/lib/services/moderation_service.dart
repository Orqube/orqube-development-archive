import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModerationResult {
  final bool allowed;
  final String sanitized;
  final String? reason;
  const ModerationResult({required this.allowed, required this.sanitized, this.reason});
}

class ModerationService {
  ModerationService._();
  static final ModerationService instance = ModerationService._();

  static const _blockedTerms = <String>{
    '씨발','시발','병신','개새끼','fuck','fucking','bitch','nigger','sex','porn'
  };

  ModerationResult inspect(String input) {
    final normalized = input.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    for (final term in _blockedTerms) {
      if (normalized.contains(term)) {
        return ModerationResult(
          allowed: false,
          sanitized: normalized.replaceAll(term, '***'),
          reason: '욕설·혐오·성적 표현이 감지되었습니다.',
        );
      }
    }
    return ModerationResult(allowed: true, sanitized: input.trim());
  }

  Future<Set<String>> blockedUserIds() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return <String>{};
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('blocked_users').get();
    return snap.docs.map((e) => e.id).toSet();
  }

  Future<void> blockUser(String targetUid) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || targetUid == uid) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('blocked_users').doc(targetUid).set({
      'blockedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> report({required String targetType, required String targetId, required String reason, String? targetUid}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('로그인이 필요합니다.');
    await FirebaseFirestore.instance.collection('reports').add({
      'reporterUid': user.uid,
      'reporterEmail': user.email,
      'targetType': targetType,
      'targetId': targetId,
      'targetUid': targetUid,
      'reason': reason,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
