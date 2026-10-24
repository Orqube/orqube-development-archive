import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReferralIdentity {
  final String code;
  final String link;

  const ReferralIdentity({required this.code, required this.link});
}

class ReferralService {
  ReferralService._();

  static final ReferralService instance = ReferralService._();

  static const String inviteBaseUrl = 'https://www.orqubic.com/';
  static const int rewardPoints = 20;
  static const double rewardOrbs = 0.02;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? referralCodeFromCurrentUri() {
    final value = Uri.base.queryParameters['ref']?.trim().toUpperCase();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String inviteLinkFor(String code) {
    final uri = Uri.parse(inviteBaseUrl).replace(queryParameters: {'ref': code});
    return uri.toString();
  }

  String _displayName(User user, Map<String, dynamic> data) {
    final nickname = '${data['nickname'] ?? data['displayName'] ?? ''}'.trim();
    if (nickname.isNotEmpty) return nickname;
    final authName = (user.displayName ?? '').trim();
    if (authName.isNotEmpty) return authName;
    final email = (user.email ?? '').trim();
    if (email.contains('@')) return email.split('@').first;
    return 'ORQUBE User';
  }

  List<String> _candidateCodes(String uid) {
    final normalized = uid.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (normalized.isEmpty) {
      throw StateError('초대코드를 만들 수 없는 사용자 UID입니다.');
    }

    final lengths = <int>[8, 10, 12, 16, normalized.length];
    final result = <String>[];
    for (final length in lengths) {
      final safeLength = length > normalized.length ? normalized.length : length;
      final code = 'ORQ${normalized.substring(0, safeLength)}';
      if (!result.contains(code)) result.add(code);
    }
    return result;
  }

  Future<ReferralIdentity> ensureInviteIdentity(User user) async {
    final userRef = _db.collection('users').doc(user.uid);

    return _db.runTransaction<ReferralIdentity>((tx) async {
      final userSnap = await tx.get(userRef);
      final data = userSnap.data() ?? <String, dynamic>{};
      final existing = '${data['inviteCode'] ?? ''}'.trim().toUpperCase();
      final candidates = <String>[
        if (existing.isNotEmpty) existing,
        ..._candidateCodes(user.uid),
      ];

      String? selected;
      DocumentReference<Map<String, dynamic>>? selectedRef;

      for (final code in candidates) {
        final ref = _db.collection('referral_codes').doc(code);
        final snap = await tx.get(ref);
        if (!snap.exists || snap.data()?['ownerUid'] == user.uid) {
          selected = code;
          selectedRef = ref;
          break;
        }
      }

      if (selected == null || selectedRef == null) {
        throw StateError('고유 초대코드를 생성하지 못했습니다.');
      }

      final link = inviteLinkFor(selected);
      final ownerName = _displayName(user, data);

      tx.set(
        selectedRef,
        {
          'code': selected,
          'ownerUid': user.uid,
          'ownerName': ownerName,
          'ownerEmail': user.email ?? data['email'] ?? '',
          'active': true,
          'updatedAt': FieldValue.serverTimestamp(),
          'createdByUid': user.uid,
        },
        SetOptions(merge: true),
      );

      final updates = <String, dynamic>{
        'inviteCode': selected,
        'inviteLink': link,
        'inviteUpdatedAt': FieldValue.serverTimestamp(),
      };
      if (!data.containsKey('referralCount')) updates['referralCount'] = 0;
      if (!data.containsKey('referralRewardPoints')) updates['referralRewardPoints'] = 0;
      if (!data.containsKey('referralRewardOrbs')) updates['referralRewardOrbs'] = 0.0;

      tx.set(userRef, updates, SetOptions(merge: true));
      return ReferralIdentity(code: selected, link: link);
    });
  }

  Future<bool> applyReferralFromCurrentUri(User invitee) async {
    final code = referralCodeFromCurrentUri();
    if (code == null) return false;
    return registerReferral(invitee: invitee, inviteCode: code);
  }

  Future<bool> registerReferral({
    required User invitee,
    required String inviteCode,
  }) async {
    final code = inviteCode.trim().toUpperCase();
    if (code.isEmpty) return false;

    final inviteeRef = _db.collection('users').doc(invitee.uid);
    final codeRef = _db.collection('referral_codes').doc(code);
    final referralRef = _db.collection('referrals').doc(invitee.uid);
    final rewardRef = _db.collection('referral_rewards').doc(invitee.uid);

    return _db.runTransaction<bool>((tx) async {
      final inviteeSnap = await tx.get(inviteeRef);
      final inviteeData = inviteeSnap.data() ?? <String, dynamic>{};
      final currentReferrer = '${inviteeData['referrerUid'] ?? ''}'.trim();
      if (currentReferrer.isNotEmpty) return false;

      final existingReferral = await tx.get(referralRef);
      if (existingReferral.exists) return false;

      final codeSnap = await tx.get(codeRef);
      if (!codeSnap.exists) {
        throw StateError('유효하지 않은 ORQUBE 초대코드입니다.');
      }
      final codeData = codeSnap.data() ?? <String, dynamic>{};
      if (codeData['active'] == false) {
        throw StateError('현재 사용할 수 없는 ORQUBE 초대코드입니다.');
      }

      final referrerUid = '${codeData['ownerUid'] ?? ''}'.trim();
      if (referrerUid.isEmpty) {
        throw StateError('초대코드의 추천인 정보를 찾을 수 없습니다.');
      }
      if (referrerUid == invitee.uid) {
        throw StateError('본인의 초대코드는 사용할 수 없습니다.');
      }

      final existingReward = await tx.get(rewardRef);
      if (existingReward.exists) return false;

      final inviteeName = _displayName(invitee, inviteeData);
      final referrerName = '${codeData['ownerName'] ?? ''}'.trim();

      tx.set(
        inviteeRef,
        {
          'referrerUid': referrerUid,
          'referrerInviteCode': code,
          'referredAt': FieldValue.serverTimestamp(),
          'referralStatus': 'joined',
        },
        SetOptions(merge: true),
      );

      tx.set(referralRef, {
        'inviteeUid': invitee.uid,
        'inviteeName': inviteeName,
        'inviteeEmail': invitee.email ?? inviteeData['email'] ?? '',
        'referrerUid': referrerUid,
        'referrerName': referrerName,
        'inviteCode': code,
        'status': 'joined',
        'rewardPoints': rewardPoints,
        'rewardOrbs': rewardOrbs,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      tx.set(rewardRef, {
        'inviteeUid': invitee.uid,
        'inviteeName': inviteeName,
        'referrerUid': referrerUid,
        'inviteCode': code,
        'rewardPoints': rewardPoints,
        'rewardOrbs': rewardOrbs,
        'claimed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  Future<int> claimPendingRewards(User user) async {
    final rewards = await _db
        .collection('referral_rewards')
        .where('referrerUid', isEqualTo: user.uid)
        .get();

    var claimedCount = 0;
    for (final reward in rewards.docs) {
      final data = reward.data();
      if (data['claimed'] == true) continue;

      final claimed = await _db.runTransaction<bool>((tx) async {
        final freshReward = await tx.get(reward.reference);
        final rewardData = freshReward.data() ?? <String, dynamic>{};
        if (rewardData['claimed'] == true) return false;
        if ('${rewardData['referrerUid'] ?? ''}' != user.uid) return false;

        final points = (rewardData['rewardPoints'] as num?)?.toInt() ?? rewardPoints;
        final orbs = (rewardData['rewardOrbs'] as num?)?.toDouble() ?? rewardOrbs;
        final userRef = _db.collection('users').doc(user.uid);

        tx.set(
          userRef,
          {
            'points': FieldValue.increment(points),
            'orbs': FieldValue.increment(orbs),
            'referralCount': FieldValue.increment(1),
            'referralRewardPoints': FieldValue.increment(points),
            'referralRewardOrbs': FieldValue.increment(orbs),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        tx.update(reward.reference, {
          'claimed': true,
          'claimedAt': FieldValue.serverTimestamp(),
        });
        return true;
      });

      if (claimed) claimedCount++;
    }
    return claimedCount;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> referralsFor(String uid) {
    return _db.collection('referrals').where('referrerUid', isEqualTo: uid).snapshots();
  }
}
