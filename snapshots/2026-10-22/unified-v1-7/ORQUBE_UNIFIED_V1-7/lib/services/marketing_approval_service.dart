import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarketingApprovalService {
  MarketingApprovalService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _queue =>
      _db.collection('marketing_approval_queue');

  Stream<QuerySnapshot<Map<String, dynamic>>> pending() => _queue
      .where('approval_status', isEqualTo: 'PENDING')
      .orderBy('verified_fit_score', descending: true)
      .snapshots()
      .timeout(
        const Duration(seconds: 12),
        onTimeout: (sink) {
          sink.addError(
            TimeoutException('Firestore 승인목록 응답 시간이 초과되었습니다.'),
          );
        },
      );

  Future<void> decide(String id, String status, {String note = ''}) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Admin login required');
    if (!const {'APPROVED','REJECTED','HOLD'}.contains(status)) {
      throw ArgumentError('Invalid approval status');
    }
    await _queue.doc(id).update({
      'approval_status': status,
      'decision_note': note,
      'approved_by': user.uid,
      'approved_at': FieldValue.serverTimestamp(),
      // Deliberately do not enable external posting here.
      'execution_enabled': 'NO',
      'email_send': 'OFF',
      'external_posting': 'OFF',
      'paid_ads': 'OFF',
    });
  }
}
