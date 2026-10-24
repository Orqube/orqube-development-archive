import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SocialService {
  SocialService._();
  static final SocialService instance = SocialService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? get _user => FirebaseAuth.instance.currentUser;

  Future<void> writeActivity({
    required String type,
    required String title,
    String? description,
    String? targetId,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _user;
    if (user == null) return;
    final profile = await _db.collection('users').doc(user.uid).get();
    final data = profile.data() ?? <String, dynamic>{};
    await _db.collection('activities').add({
      'uid': user.uid,
      'displayName': data['nickname'] ?? user.displayName ?? 'ORQUBE User',
      'photoUrl': data['profileImageUrl'] ?? user.photoURL,
      'type': type,
      'title': title,
      'description': description ?? '',
      'targetId': targetId,
      'metadata': metadata ?? <String, dynamic>{},
      'visibility': data['profileVisibility'] == 'private' ? 'private' : 'members',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createNotification({
    required String recipientUid,
    required String type,
    required String title,
    required String body,
    String? targetId,
  }) async {
    final sender = _user;
    if (sender == null || recipientUid.isEmpty) return;
    await _db.collection('users').doc(recipientUid).collection('notifications').add({
      'type': type,
      'title': title,
      'body': body,
      'targetId': targetId,
      'senderUid': sender.uid,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> follow(String targetUid) async {
    final user = _user;
    if (user == null || targetUid == user.uid) return;
    final batch = _db.batch();
    batch.set(_db.collection('users').doc(user.uid).collection('following').doc(targetUid), {
      'uid': targetUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection('users').doc(targetUid).collection('followers').doc(user.uid), {
      'uid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    await createNotification(recipientUid: targetUid, type: 'follow', title: '새 팔로워', body: '새로운 사용자가 회원님을 팔로우했습니다.');
  }

  Future<void> unfollow(String targetUid) async {
    final user = _user;
    if (user == null) return;
    final batch = _db.batch();
    batch.delete(_db.collection('users').doc(user.uid).collection('following').doc(targetUid));
    batch.delete(_db.collection('users').doc(targetUid).collection('followers').doc(user.uid));
    await batch.commit();
  }

  Future<void> sendFriendRequest(String targetUid) async {
    final user = _user;
    if (user == null || targetUid == user.uid) return;
    await _db.collection('friend_requests').doc('${user.uid}_$targetUid').set({
      'fromUid': user.uid,
      'toUid': targetUid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await createNotification(recipientUid: targetUid, type: 'friend_request', title: '친구 요청', body: '새 친구 요청이 도착했습니다.');
  }

  Future<void> respondFriendRequest(DocumentReference<Map<String, dynamic>> requestRef, bool accept) async {
    final user = _user;
    if (user == null) return;
    final snapshot = await requestRef.get();
    final data = snapshot.data();
    if (data == null || data['toUid'] != user.uid) return;
    final fromUid = (data['fromUid'] ?? '').toString();
    final batch = _db.batch();
    batch.update(requestRef, {'status': accept ? 'accepted' : 'declined', 'updatedAt': FieldValue.serverTimestamp()});
    if (accept && fromUid.isNotEmpty) {
      batch.set(_db.collection('users').doc(user.uid).collection('friends').doc(fromUid), {'uid': fromUid, 'createdAt': FieldValue.serverTimestamp()});
      batch.set(_db.collection('users').doc(fromUid).collection('friends').doc(user.uid), {'uid': user.uid, 'createdAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
    if (fromUid.isNotEmpty) {
      await createNotification(recipientUid: fromUid, type: 'friend_response', title: accept ? '친구 요청 수락' : '친구 요청 거절', body: accept ? '친구 요청이 수락되었습니다.' : '친구 요청이 거절되었습니다.');
    }
  }

  Future<void> applyToTeam(String teamId, String teamName, String ownerUid) async {
    final user = _user;
    if (user == null) return;
    await _db.collection('airsoft_teams').doc(teamId).collection('applications').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (ownerUid.isNotEmpty) {
      await createNotification(recipientUid: ownerUid, type: 'team_application', title: '팀 참가 신청', body: '$teamName 팀에 새로운 참가 신청이 있습니다.', targetId: teamId);
    }
    await writeActivity(type: 'team_application', title: '$teamName 팀에 참가 신청', targetId: teamId);
  }
}
