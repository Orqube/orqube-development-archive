import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendFinderPage extends StatefulWidget {
  const FriendFinderPage({super.key});

  @override
  State<FriendFinderPage> createState() => _FriendFinderPageState();
}

class _FriendFinderPageState extends State<FriendFinderPage> {
  static const _bg = Color(0xFF03040B);
  static const _panel = Color(0xFF0A0B18);
  static const _purple = Color(0xFF8B2CF6);
  static const _lime = Color(0xFFD7FF35);

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _searchController = TextEditingController();

  String _query = '';
  bool _working = false;

  User? get _user => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    _syncAcceptedRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _text(dynamic value, {String fallback = ''}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  Future<void> _syncAcceptedRequests() async {
    final user = _user;
    if (user == null) return;
    try {
      final accepted = await _db
          .collection('friend_requests')
          .where('fromUid', isEqualTo: user.uid)
          .where('status', isEqualTo: 'accepted')
          .limit(50)
          .get();
      for (final request in accepted.docs) {
        final data = request.data();
        final friendUid = _text(data['toUid']);
        if (friendUid.isEmpty) continue;
        await _db.collection('users').doc(user.uid).collection('friends').doc(friendUid).set({
          'uid': friendUid,
          'nickname': _text(data['toNickname'], fallback: 'ORQUBE USER'),
          'email': _text(data['toEmail']),
          'addedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {
      // 복합 색인이 아직 없는 환경에서도 화면 자체는 정상 작동하도록 둡니다.
    }
  }

  Future<void> _sendRequest(String uid, Map<String, dynamic> profile) async {
    final user = _user;
    if (user == null || uid == user.uid || _working) return;
    setState(() => _working = true);
    try {
      final ownDoc = await _db.collection('users').doc(user.uid).get();
      final own = ownDoc.data() ?? <String, dynamic>{};
      final requestId = '${user.uid}_$uid';
      await _db.collection('friend_requests').doc(requestId).set({
        'fromUid': user.uid,
        'fromNickname': _text(own['nickname'], fallback: user.displayName ?? 'ORQUBE USER'),
        'fromEmail': _text(own['email'], fallback: user.email ?? ''),
        'toUid': uid,
        'toNickname': _text(profile['nickname'], fallback: 'ORQUBE USER'),
        'toEmail': _text(profile['email']),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _message('친구 요청을 보냈습니다.');
    } catch (e) {
      _message('친구 요청 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _acceptRequest(DocumentSnapshot<Map<String, dynamic>> request) async {
    final user = _user;
    if (user == null || _working) return;
    setState(() => _working = true);
    try {
      final data = request.data() ?? <String, dynamic>{};
      final friendUid = _text(data['fromUid']);
      if (friendUid.isEmpty) return;
      await _db.runTransaction((transaction) async {
        transaction.update(request.reference, {
          'status': 'accepted',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.set(
          _db.collection('users').doc(user.uid).collection('friends').doc(friendUid),
          {
            'uid': friendUid,
            'nickname': _text(data['fromNickname'], fallback: 'ORQUBE USER'),
            'email': _text(data['fromEmail']),
            'addedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
      _message('친구 요청을 수락했습니다.');
    } catch (e) {
      _message('수락 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _rejectRequest(DocumentReference<Map<String, dynamic>> ref) async {
    try {
      await ref.delete();
      _message('친구 요청을 거절했습니다.');
    } catch (e) {
      _message('처리 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text('친구찾기', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: user == null
          ? const Center(child: Text('로그인 후 사용할 수 있습니다.', style: TextStyle(color: Colors.white70)))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: '닉네임, 이메일 또는 사용자 ID 검색',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search_rounded, color: _lime),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: _panel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('받은 친구 요청'),
                  _incomingRequests(user.uid),
                  const SizedBox(height: 18),
                  _sectionTitle('내 친구'),
                  _friends(user.uid),
                  const SizedBox(height: 18),
                  _sectionTitle('사용자 검색'),
                  _userSearch(user.uid),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
      );

  Widget _incomingRequests(String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('friend_requests').where('toUid', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _info('친구 요청을 불러오지 못했습니다.');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: _lime));
        final requests = snapshot.data!.docs.where((d) => _text(d.data()['status'], fallback: 'pending') == 'pending').toList();
        if (requests.isEmpty) return _info('새로운 친구 요청이 없습니다.');
        return Column(
          children: requests.map((request) {
            final data = request.data();
            return _tile(
              title: _text(data['fromNickname'], fallback: 'ORQUBE USER'),
              subtitle: _text(data['fromEmail'], fallback: _text(data['fromUid'])),
              trailing: Wrap(spacing: 4, children: [
                IconButton(onPressed: _working ? null : () => _acceptRequest(request), icon: const Icon(Icons.check_circle_rounded, color: _lime)),
                IconButton(onPressed: () => _rejectRequest(request.reference), icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent)),
              ]),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _friends(String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('users').doc(uid).collection('friends').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _info('친구 목록을 불러오지 못했습니다.');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: _lime));
        if (snapshot.data!.docs.isEmpty) return _info('아직 등록된 친구가 없습니다.');
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data();
            return _tile(
              title: _text(data['nickname'], fallback: 'ORQUBE USER'),
              subtitle: _text(data['email'], fallback: doc.id),
              trailing: const Icon(Icons.people_rounded, color: _purple),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _userSearch(String uid) {
    if (_query.length < 2) return _info('검색어를 두 글자 이상 입력해 주세요.');
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _db.collection('users').limit(100).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _info('사용자 검색에 실패했습니다.');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: _lime));
        final matches = snapshot.data!.docs.where((doc) {
          if (doc.id == uid) return false;
          final data = doc.data();
          final haystack = '${_text(data['nickname'])} ${_text(data['email'])} ${doc.id}'.toLowerCase();
          return haystack.contains(_query);
        }).take(30).toList();
        if (matches.isEmpty) return _info('검색 결과가 없습니다.');
        return Column(
          children: matches.map((doc) {
            final data = doc.data();
            return _tile(
              title: _text(data['nickname'], fallback: 'ORQUBE USER'),
              subtitle: _text(data['email'], fallback: doc.id),
              trailing: IconButton(
                tooltip: '친구 요청',
                onPressed: _working ? null : () => _sendRequest(doc.id, data),
                icon: const Icon(Icons.person_add_alt_1_rounded, color: _lime),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _tile({required String title, required String subtitle, required Widget trailing}) {
    return Card(
      color: _panel,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _purple.withOpacity(0.25),
          child: Text(title.isEmpty ? 'O' : title[0].toUpperCase(), style: const TextStyle(color: _lime, fontWeight: FontWeight.w900)),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54)),
        trailing: trailing,
      ),
    );
  }

  Widget _info(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(14)),
        child: Text(text, style: const TextStyle(color: Colors.white60)),
      );
}
