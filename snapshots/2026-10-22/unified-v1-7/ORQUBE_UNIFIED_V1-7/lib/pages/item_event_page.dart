import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/orqube_i18n.dart';

class ItemEventPage extends StatefulWidget {
  const ItemEventPage({super.key});

  @override
  State<ItemEventPage> createState() => _ItemEventPageState();
}

class _ItemEventPageState extends State<ItemEventPage> {
  static const _bg = Color(0xFF03040B);
  static const _panel = Color(0xFF0B0D1B);
  static const _lime = Color(0xFFD7FF35);
  static const _violet = Color(0xFFB85CFF);
  static const _items = <String, Map<String, dynamic>>{
    'helmet': {'name': 'HELMET', 'icon': Icons.sports_motorsports_rounded},
    'scope': {'name': 'SCOPE', 'icon': Icons.center_focus_strong_rounded},
    'radio': {'name': 'RADIO', 'icon': Icons.radio_rounded},
    'dogtag': {'name': 'DOG TAG', 'icon': Icons.badge_rounded},
    'drone': {'name': 'DRONE', 'icon': Icons.flight_rounded},
  };

  final _db = FirebaseFirestore.instance;
  bool _claiming = false;
  bool _creatingCollection = false;
  final Set<String> _joiningCollectionIds = <String>{};
  final Set<String> _claimingRewardIds = <String>{};

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration.zero, _removeExpiredCollections);
  }

  User? get _user => FirebaseAuth.instance.currentUser;
  DocumentReference<Map<String, dynamic>>? get _userRef =>
      _user == null ? null : _db.collection('users').doc(_user!.uid);

  String get _dayKey {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  DateTime? _dateFrom(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  bool _isExpired(Map<String, dynamic> data) {
    final expiresAt = _dateFrom(data['expiresAt']);
    if (expiresAt != null) return !expiresAt.isAfter(DateTime.now());
    final createdAt = _dateFrom(data['createdAt']);
    return createdAt != null &&
        !createdAt.add(const Duration(hours: 24)).isAfter(DateTime.now());
  }

  Future<void> _removeExpiredCollections() async {
    if (_user == null) return;
    try {
      final snap = await _db.collection('itemCollections').limit(100).get();
      final expired = snap.docs.where((doc) => _isExpired(doc.data())).toList();
      if (expired.isEmpty) return;
      final batch = _db.batch();
      for (final doc in expired) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {
      // 만료 항목은 화면에서도 즉시 제외되므로 삭제 실패가 다른 기능을 막지 않습니다.
    }
  }

  Future<void> _claimDailyItems() async {
    final user = _user;
    final userRef = _userRef;
    if (user == null || userRef == null || _claiming) return;
    setState(() => _claiming = true);
    final claimRef = userRef.collection('itemClaims').doc(_dayKey);
    try {
      final random = math.Random.secure();
      final count = 1 + random.nextInt(3);
      final awarded = <String>[];
      await _db.runTransaction((tx) async {
        final existing = await tx.get(claimRef);
        if (existing.exists) throw StateError('이미 아이템을 지급했습니다.');
        for (var i = 0; i < count; i++) {
          final id = _items.keys.elementAt(random.nextInt(_items.length));
          awarded.add(id);
          final itemRef = userRef.collection('items').doc(id);
          tx.set(itemRef, {
            'itemId': id,
            'name': _items[id]!['name'],
            'quantity': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        tx.set(claimRef, {
          'uid': user.uid,
          'dayKey': _dayKey,
          'items': awarded,
          'count': count,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
      _show('아이템 ${awarded.length}개가 지급되었습니다.');
    } catch (e) {
      _show(_friendlyError(e, fallback: '아이템 지급에 실패했습니다.'));
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  Future<void> _createCollection(String itemId) async {
    final user = _user;
    final userRef = _userRef;
    if (user == null || userRef == null || _creatingCollection) return;

    setState(() => _creatingCollection = true);
    try {
      final item = await userRef.collection('items').doc(itemId).get();
      if (!item.exists ||
          ((item.data()?['quantity'] as num?)?.toInt() ?? 0) < 1) {
        throw StateError('해당 아이템을 먼저 보유해야 합니다.');
      }

      // 한 사용자가 동일 아이템으로 모집 중인 수집소를 중복 생성하지 못하게 합니다.
      final existing = await _db
          .collection('itemCollections')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(30)
          .get();
      final hasActiveDuplicate = existing.docs.any((doc) {
        final data = doc.data();
        return data['itemId'] == itemId &&
            data['status'] == 'recruiting' &&
            !_isExpired(data);
      });
      if (hasActiveDuplicate) {
        throw StateError('이미 같은 아이템으로 모집 중인 수집소가 있습니다.');
      }

      final ref = _db.collection('itemCollections').doc();
      await ref.set({
        'itemId': itemId,
        'itemName': _items[itemId]!['name'],
        'ownerUid': user.uid,
        'memberUids': [user.uid],
        'memberCount': 1,
        'status': 'recruiting',
        'rewardRate': 0.15,
        'rewardClaimedUids': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
      });
      _show('수집소가 생성되었습니다. 텔레그램/X에서 같은 아이템 사용자 2명을 찾으세요.');
    } catch (e) {
      _show(_friendlyError(e, fallback: '수집소 생성에 실패했습니다.'));
    } finally {
      if (mounted) setState(() => _creatingCollection = false);
    }
  }

  Future<void> _joinCollection(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final user = _user;
    final userRef = _userRef;
    if (user == null || userRef == null) return;
    if (_joiningCollectionIds.contains(doc.id)) return;

    final data = doc.data() ?? <String, dynamic>{};
    final members = _stringList(data['memberUids']);
    if (members.contains(user.uid)) {
      _show(data['ownerUid'] == user.uid
          ? '본인이 만든 수집소입니다. 다른 사용자의 참여를 기다려 주세요.'
          : '이미 참여한 수집소입니다.');
      return;
    }

    final itemId = data['itemId']?.toString() ?? '';
    if (itemId.isEmpty) {
      _show('수집소 아이템 정보가 올바르지 않습니다.');
      return;
    }

    setState(() => _joiningCollectionIds.add(doc.id));
    try {
      final item = await userRef.collection('items').doc(itemId).get();
      if (!item.exists ||
          ((item.data()?['quantity'] as num?)?.toInt() ?? 0) < 1) {
        throw StateError('같은 아이템을 보유해야 참여할 수 있습니다.');
      }

      await _db.runTransaction((tx) async {
        final fresh = await tx.get(doc.reference);
        if (!fresh.exists) throw StateError('수집소가 삭제되었거나 존재하지 않습니다.');

        final d = fresh.data() ?? <String, dynamic>{};
        final freshMembers = _stringList(d['memberUids']);
        if (freshMembers.contains(user.uid)) {
          throw StateError('이미 참여한 수집소입니다.');
        }
        if (freshMembers.length >= 3 || d['status'] == 'completed') {
          throw StateError('이미 완료된 수집소입니다.');
        }

        freshMembers.add(user.uid);
        final completed = freshMembers.length >= 3;
        tx.update(doc.reference, {
          'memberUids': freshMembers,
          'memberCount': freshMembers.length,
          'status': completed ? 'completed' : 'recruiting',
          if (completed) 'completedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      _show('수집소 참여가 완료되었습니다. 3명이 모이면 완료 목록에서 보상을 받을 수 있습니다.');
    } catch (e) {
      _show(_friendlyError(e, fallback: '수집소 참여에 실패했습니다.'));
    } finally {
      if (mounted) {
        setState(() => _joiningCollectionIds.remove(doc.id));
      }
    }
  }

  Future<void> _enterCollection(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final user = _user;
    if (user == null) return;
    final data = doc.data() ?? <String, dynamic>{};
    final members = _stringList(data['memberUids']);
    if (!members.contains(user.uid)) {
      await _joinCollection(doc);
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _panel,
        title: Text(
          '${data['itemName'] ?? 'ITEM'} 수집소',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('현재 참여 인원: ${members.length}/3', style: const TextStyle(color: _lime, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              data['ownerUid'] == user.uid
                  ? '개설자로 입장했습니다. 같은 아이템 사용자 참여를 기다려 주세요.'
                  : '참여자로 입장했습니다. 3명이 모이면 수집소가 완료됩니다.',
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text('수집소는 개설 후 24시간이 지나면 자동 소멸합니다.', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('확인')),
        ],
      ),
    );
  }

  Future<void> _claimCollectionReward(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final user = _user;
    final userRef = _userRef;
    if (user == null || userRef == null) return;
    if (_claimingRewardIds.contains(doc.id)) return;

    setState(() => _claimingRewardIds.add(doc.id));
    try {
      await _db.runTransaction((tx) async {
        final collection = await tx.get(doc.reference);
        if (!collection.exists) throw StateError('완료된 수집소를 찾을 수 없습니다.');

        final data = collection.data() ?? <String, dynamic>{};
        final members = _stringList(data['memberUids']);
        final claimed = _stringList(data['rewardClaimedUids']);
        if (data['status'] != 'completed' || !members.contains(user.uid)) {
          throw StateError('보상 대상이 아닙니다.');
        }
        if (claimed.contains(user.uid)) throw StateError('이미 보상을 받았습니다.');

        final userSnap = await tx.get(userRef);
        final current =
            ((userSnap.data()?['miningRate'] as num?)?.toDouble() ?? 1.0);
        final next = double.parse(
          (math.max(1.0, current) + 0.15).toStringAsFixed(2),
        );
        claimed.add(user.uid);

        tx.set(userRef, {
          'miningRate': next,
          'miningRateUpdatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        tx.set(userRef.collection('miningRateHistory').doc(), {
          'uid': user.uid,
          'source': 'item_collection',
          'amount': 0.15,
          'rateBefore': current,
          'rateAfter': next,
          'collectionId': doc.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
        tx.update(doc.reference, {
          'rewardClaimedUids': claimed,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      _show('아이템 수집 보상으로 채굴률이 +0.15 상승했습니다.');
    } catch (e) {
      _show(_friendlyError(e, fallback: '보상 지급에 실패했습니다.'));
    } finally {
      if (mounted) {
        setState(() => _claimingRewardIds.remove(doc.id));
      }
    }
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.map((e) => e.toString()).toList();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _deduplicateCollections(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final seen = <String>{};
    final result = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final doc in docs) {
      final data = doc.data();
      final key = '${data['ownerUid'] ?? ''}_${data['itemId'] ?? ''}';
      if (seen.add(key)) result.add(doc);
    }
    return result;
  }

  String _friendlyError(Object error, {required String fallback}) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firestore 권한이 없습니다. 수정된 보안 규칙을 배포해 주세요.';
        case 'unavailable':
          return '네트워크 연결이 불안정합니다. 잠시 후 다시 시도해 주세요.';
        case 'failed-precondition':
          return '현재 수집소 상태에서는 처리할 수 없습니다.';
        case 'aborted':
          return '다른 사용자가 동시에 참여했습니다. 다시 시도해 주세요.';
        default:
          return '$fallback (${error.code})';
      }
    }

    final text = error.toString();
    const knownMessages = <String>[
      '이미 아이템을 지급했습니다.',
      '해당 아이템을 먼저 보유해야 합니다.',
      '이미 같은 아이템으로 모집 중인 수집소가 있습니다.',
      '같은 아이템을 보유해야 참여할 수 있습니다.',
      '이미 참여한 수집소입니다.',
      '이미 완료된 수집소입니다.',
      '수집소가 삭제되었거나 존재하지 않습니다.',
      '보상 대상이 아닙니다.',
      '이미 보상을 받았습니다.',
      '완료된 수집소를 찾을 수 없습니다.',
    ];
    for (final message in knownMessages) {
      if (text.contains(message)) return message;
    }
    return fallback;
  }

  void _show(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(backgroundColor: _bg, foregroundColor: Colors.white, title: Text(OrqubeI18n.currentPair('아이템 보관함 · 수집소', 'Item Vault · Collection'))),
      body: user == null
          ? const Center(child: Text('로그인이 필요합니다.', style: TextStyle(color: Colors.white)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(OrqubeI18n.currentPair('일일 랜덤 아이템', 'DAILY RANDOM ITEMS'), style: TextStyle(color: _lime, fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(OrqubeI18n.currentPair('로그인 후 하루 한 번 5종 아이템 중 1~3개를 랜덤 지급합니다.', 'Receive 1–3 random items once per day after signing in.'), style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _claiming ? null : _claimDailyItems, icon: const Icon(Icons.casino_rounded), label: Text(_claiming ? '지급 중...' : OrqubeI18n.currentPair('오늘의 아이템 받기', 'Claim Today’s Items')))),
                ])),
                const SizedBox(height: 14),
                Text(OrqubeI18n.currentPair('내 아이템', 'My Items'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _userRef!.collection('items').snapshots(),
                  builder: (_, snap) {
                    final docs = snap.data?.docs ?? const [];
                    if (docs.isEmpty) return const Text('아직 보유한 아이템이 없습니다.', style: TextStyle(color: Colors.white54));
                    return Column(children: docs.map((d) {
                      final id=d.id; final q=((d.data()['quantity'] as num?)?.toInt() ?? 0);
                      return Card(color: _panel, child: ListTile(leading: Icon(_items[id]?['icon'] as IconData? ?? Icons.inventory_2, color: _violet), title: Text('${_items[id]?['name'] ?? id}  ×$q', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), trailing: TextButton(onPressed: _creatingCollection ? null : () => _createCollection(id), child: Text(_creatingCollection ? OrqubeI18n.currentPair('처리 중', 'Processing') : OrqubeI18n.currentPair('수집소 만들기', 'Create Collection')))));
                    }).toList());
                  },
                ),
                const SizedBox(height: 14),
                Text(OrqubeI18n.currentPair('공개 아이템 수집소', 'Public Item Collections'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _db.collection('itemCollections').where('status', isEqualTo: 'recruiting').limit(30).snapshots(),
                  builder: (_, snap) {
                    final rawDocs = (snap.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                        .where((d) => !_isExpired(d.data()))
                        .toList();
                    final docs = _deduplicateCollections(rawDocs);
                    if (docs.isEmpty) return const Text('모집 중인 수집소가 없습니다.', style: TextStyle(color: Colors.white54));
                    return Column(children: docs.map((d) {
                      final x = d.data();
                      final isMine = _stringList(x['memberUids']).contains(user.uid);
                      final joining = _joiningCollectionIds.contains(d.id);
                      return Card(
                        color: _panel,
                        child: ListTile(
                          title: Text('${x['itemName']} · ${x['memberCount'] ?? 1}/3', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            isMine ? '내가 참여한 수집소 · 다른 참여자를 기다리는 중' : '텔레그램 또는 X에서 참여자를 찾은 뒤 같은 아이템으로 참여',
                            style: const TextStyle(color: Colors.white60),
                          ),
                          trailing: FilledButton(
                            onPressed: joining ? null : () => _enterCollection(d),
                            child: Text(isMine ? '입장' : (joining ? '처리중' : '참여')),
                          ),
                          onTap: joining ? null : () => _enterCollection(d),
                        ),
                      );
                    }).toList());
                  },
                ),

                const SizedBox(height: 14),
                const Text('완료된 수집소 보상', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _db.collection('itemCollections').where('status', isEqualTo: 'completed').limit(30).snapshots(),
                  builder: (_, snap) {
                    final uid = _user?.uid;
                    final docs = (snap.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                        .where((d) => !_isExpired(d.data()))
                        .where((d) => List<String>.from(d.data()['memberUids'] ?? const <String>[]).contains(uid))
                        .toList();
                    if (docs.isEmpty) return const Text('받을 수 있는 완료 보상이 없습니다.', style: TextStyle(color: Colors.white54));
                    return Column(children: docs.map((d) {
                      final x = d.data();
                      final claimed = List<String>.from(x['rewardClaimedUids'] ?? const <String>[]).contains(uid);
                      return Card(color: _panel, child: ListTile(
                        title: Text('${x['itemName']} · 3/3 완료', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(OrqubeI18n.currentPair('참여자별 채굴률 ×0.15 보상', 'Mining rate ×0.15 reward per participant'), style: TextStyle(color: Colors.white60)),
                        trailing: FilledButton(onPressed: claimed || _claimingRewardIds.contains(d.id) ? null : () => _claimCollectionReward(d), child: Text(claimed ? '지급완료' : (_claimingRewardIds.contains(d.id) ? '처리중' : '보상받기'))),
                      ));
                    }).toList());
                  },
                ),
              ],
            ),
    );
  }

  Widget _card(Widget child) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: _violet.withOpacity(.35))), child: child);
}
