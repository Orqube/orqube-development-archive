import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/orqube_i18n.dart';

import 'business_registration_page.dart';
import 'airsoft_map_page.dart';
import 'marketplace_page.dart';
import 'match_registration_page.dart';
import 'team_registration_page.dart';

class AirsoftHubPage extends StatefulWidget {
  const AirsoftHubPage({super.key});

  @override
  State<AirsoftHubPage> createState() => _AirsoftHubPageState();
}

class _AirsoftHubPageState extends State<AirsoftHubPage> {
  static const _bg = Color(0xFF03040B);
  static const _panel = Color(0xFF0A0B18);
  static const _purple = Color(0xFF8B2CF6);
  static const _lime = Color(0xFFD7FF35);
  static const _cyan = Color(0xFF39D9FF);
  static const _muted = Color(0xFF98A0B8);

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  int _index = 0;
  String _lang = OrqubeI18n.currentLanguage;

  static const _labels = <String, Map<String, String>>{
    'ko': {
      'title': '에어소프트 허브',
      'home': '홈',
      'map': '경기 지도',
      'match': '경기',
      'team': '팀',
      'chat': '채팅',
      'place': '장소·업체',
      'market': '마켓',
      'profile': '프로필',
      'register': '등록',
      'join': '참가 신청',
      'apply': '가입 신청',
      'empty': '등록된 항목이 없습니다.',
      'login': '로그인이 필요합니다.',
      'saved': '처리되었습니다.',
      'report': '신고',
      'domestic': '국내 채팅',
      'global': '글로벌 채팅',
    },
    'en': {
      'title': 'AIRSOFT HUB',
      'home': 'Home',
      'map': 'Map',
      'match': 'Matches',
      'team': 'Teams',
      'chat': 'Chat',
      'place': 'Places',
      'market': 'Market',
      'profile': 'Profile',
      'register': 'Register',
      'join': 'Join',
      'apply': 'Apply',
      'empty': 'No items yet.',
      'login': 'Sign in required.',
      'saved': 'Completed.',
      'report': 'Report',
      'domestic': 'Korea Chat',
      'global': 'Global Chat',
    },
    'ja': {
      'title': 'エアソフトハブ',
      'home': 'ホーム',
      'map': '試合マップ',
      'match': '試合',
      'team': 'チーム',
      'chat': 'チャット',
      'place': '場所・業者',
      'market': 'マーケット',
      'profile': 'プロフィール',
      'register': '登録',
      'join': '参加申請',
      'apply': '加入申請',
      'empty': '登録された項目がありません。',
      'login': 'ログインが必要です。',
      'saved': '完了しました。',
      'report': '通報',
      'domestic': '韓国チャット',
      'global': 'グローバルチャット',
    },
    'zh': {
      'title': 'AIRSOFT 中心',
      'home': '首页',
      'map': '比赛地图',
      'match': '比赛',
      'team': '战队',
      'chat': '聊天',
      'place': '场地·商家',
      'market': '市场',
      'profile': '个人资料',
      'register': '登记',
      'join': '申请参加',
      'apply': '申请加入',
      'empty': '暂无内容。',
      'login': '需要登录。',
      'saved': '已完成。',
      'report': '举报',
      'domestic': '韩国聊天',
      'global': '全球聊天',
    },
    'fr': {
      'title': 'AIRSOFT HUB',
      'home': 'Accueil',
      'map': 'Carte',
      'match': 'Matchs',
      'team': 'Équipes',
      'chat': 'Chat',
      'place': 'Lieux',
      'market': 'Marché',
      'profile': 'Profil',
      'register': 'Ajouter',
      'join': 'Participer',
      'apply': 'Rejoindre',
      'empty': 'Aucun élément.',
      'login': 'Connexion requise.',
      'saved': 'Terminé.',
      'report': 'Signaler',
      'domestic': 'Chat Corée',
      'global': 'Chat mondial',
    },
    'pt': {
      'title': 'AIRSOFT HUB',
      'home': 'Início',
      'map': 'Mapa',
      'match': 'Jogos',
      'team': 'Equipes',
      'chat': 'Chat',
      'place': 'Locais',
      'market': 'Mercado',
      'profile': 'Perfil',
      'register': 'Cadastrar',
      'join': 'Participar',
      'apply': 'Entrar',
      'empty': 'Nenhum item.',
      'login': 'Login necessário.',
      'saved': 'Concluído.',
      'report': 'Denunciar',
      'domestic': 'Chat Coreia',
      'global': 'Chat global',
    },
  };

  String t(String key) => _labels[_lang]?[key] ?? _labels['ko']![key]!;
  User? get user => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _home(),
      _matches(),
      _teams(),
      _chat(),
      _places(),
      _market(),
      _profile(),
    ];
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: Text(
          t('title'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _lang,
            icon: const Icon(Icons.language_rounded),
            onSelected: (v) { OrqubeI18n.setLanguage(v); setState(() => _lang = v); },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'ko', child: Text('한국어')),
                  PopupMenuItem(value: 'en', child: Text('English')),
                  PopupMenuItem(value: 'ja', child: Text('日本語')),
                  PopupMenuItem(value: 'zh', child: Text('中文')),
                  PopupMenuItem(value: 'fr', child: Text('Français')),
                  PopupMenuItem(value: 'pt', child: Text('Português')),
                ],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: _panel,
        indicatorColor: _purple.withOpacity(.35),
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_rounded),
            label: t('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.sports_rounded),
            label: t('match'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_rounded),
            label: t('team'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_rounded),
            label: t('chat'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_rounded),
            label: t('place'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_rounded),
            label: t('market'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_rounded),
            label: t('profile'),
          ),
        ],
      ),
    );
  }

  Widget _home() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: _box(
          gradient: const LinearGradient(
            colors: [Color(0xFF25114A), Color(0xFF0C1730)],
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GLOBAL AIRSOFT NETWORK',
              style: TextStyle(
                color: _lime,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '팀 · 경기 · 채팅 · 경기장 · 업체 · 마켓',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ORQUBE 계정 하나로 에어소프트 활동을 관리합니다.',
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.25,
        children: [
          _quickOpen(
            Icons.map_rounded,
            '에어소프트 경기 · 안심귀가 · 안전산행',
            Colors.greenAccent,
            () => _open(const AirsoftMapPage()),
          ),
          _quick(Icons.sports_rounded, t('match'), _cyan, 1),
          _quick(Icons.groups_rounded, t('team'), _purple, 2),
          _quick(Icons.forum_rounded, t('chat'), Colors.orangeAccent, 3),
          _quick(Icons.map_rounded, t('place'), Colors.greenAccent, 4),
          _quick(Icons.shopping_bag_rounded, t('market'), Colors.pinkAccent, 5),
          _quick(Icons.person_rounded, t('profile'), _lime, 6),
        ],
      ),
      const SizedBox(height: 14),
      _sectionTitle('최근 경기'),
      _streamList('airsoft_matches', limit: 3, builder: _matchCard),
      const SizedBox(height: 14),
      _sectionTitle('최근 팀'),
      _streamList('airsoft_teams', limit: 3, builder: _teamCard),
    ],
  );

  Widget _quickOpen(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: Ink(
      decoration: _box(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          Text(
            label,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '경기장 · 집결지 · 길찾기 · SOS',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _muted, fontSize: 11),
          ),
        ],
      ),
    ),
  );

  Widget _quick(IconData icon, String label, Color color, int index) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () => setState(() => _index = index),
    child: Ink(
      decoration: _box(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _matches() => _listPage(
    title: t('match'),
    icon: Icons.add_rounded,
    onAdd: () => _open(const MatchRegistrationPage()),
    child: _streamList(
      'airsoft_matches',
      builder: _matchCard,
      fallbackCollection: 'airsoft_events',
    ),
  );

  Widget _matchCard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return _card(
      title: (d['title'] ?? '경기').toString(),
      subtitle:
          '${d['venue'] ?? d['place'] ?? '-'}  ·  ${d['schedule'] ?? d['date'] ?? '-'}',
      body: (d['description'] ?? '').toString(),
      trailing: FilledButton(
        onPressed: () => _joinMatch(doc),
        child: Text(t('join')),
      ),
      onLongPress: () => _ownerMenu(doc, 'airsoft_matches'),
    );
  }

  Future<void> _joinMatch(DocumentSnapshot<Map<String, dynamic>> doc) async {
    if (!_requireLogin()) return;
    await doc.reference.collection('applications').doc(user!.uid).set({
      'uid': user!.uid,
      'email': user!.email ?? '',
      'displayName': user!.displayName ?? '',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _msg(t('saved'));
  }

  Widget _teams() => _listPage(
    title: t('team'),
    icon: Icons.group_add_rounded,
    onAdd: () => _open(const TeamRegistrationPage()),
    child: _streamList('airsoft_teams', builder: _teamCard),
  );

  Widget _teamCard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return _card(
      title: (d['name'] ?? 'TEAM').toString(),
      subtitle: '${d['region'] ?? '-'} · ${d['status'] ?? 'pending'}',
      body: (d['description'] ?? '').toString(),
      trailing: FilledButton(
        onPressed: () => _applyTeam(doc),
        child: Text(t('apply')),
      ),
      onLongPress: () => _ownerMenu(doc, 'airsoft_teams'),
    );
  }

  Future<void> _applyTeam(DocumentSnapshot<Map<String, dynamic>> doc) async {
    if (!_requireLogin()) return;
    await doc.reference.collection('applications').doc(user!.uid).set({
      'uid': user!.uid,
      'email': user!.email ?? '',
      'displayName': user!.displayName ?? '',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _msg(t('saved'));
  }

  Widget _chat() => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        TabBar(
          labelColor: _lime,
          unselectedLabelColor: _muted,
          tabs: [Tab(text: t('domestic')), Tab(text: t('global'))],
        ),
        Expanded(
          child: TabBarView(
            children: [_chatRoom('airsoft_kr'), _chatRoom('airsoft_global')],
          ),
        ),
      ],
    ),
  );

  Widget _chatRoom(String room) {
    final controller = TextEditingController();
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                _db
                    .collection('airsoft_chats')
                    .doc(room)
                    .collection('messages')
                    .orderBy('createdAt', descending: true)
                    .limit(100)
                    .snapshots(),
            builder: (context, s) {
              if (s.hasError) return _error(s.error);
              if (!s.hasData)
                return const Center(child: CircularProgressIndicator());
              final docs = s.data!.docs;
              if (docs.isEmpty) return _empty();
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data();
                  final mine = d['uid'] == user?.uid;
                  return Align(
                    alignment:
                        mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: GestureDetector(
                      onLongPress:
                          () =>
                              _report('chat', docs[i].id, d['uid']?.toString()),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 310),
                        decoration: BoxDecoration(
                          color: mine ? _purple : _panel,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (d['displayName'] ?? d['email'] ?? 'USER')
                                  .toString(),
                              style: const TextStyle(
                                color: _lime,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              (d['text'] ?? '').toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: _input('Message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: _lime),
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isEmpty || !_requireLogin()) return;
                    controller.clear();
                    await _db
                        .collection('airsoft_chats')
                        .doc(room)
                        .collection('messages')
                        .add({
                          'uid': user!.uid,
                          'email': user!.email ?? '',
                          'displayName': user!.displayName ?? '',
                          'text': text,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _places() => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        TabBar(
          labelColor: _lime,
          unselectedLabelColor: _muted,
          tabs: const [Tab(text: '경기장·장소'), Tab(text: '업체·단체')],
        ),
        Expanded(
          child: TabBarView(
            children: [
              _listPage(
                title: '경기장·장소',
                compact: true,
                onAdd: () => _createPlace(),
                child: _streamList('airsoft_places', builder: _placeCard),
              ),
              _listPage(
                title: '업체·단체',
                compact: true,
                onAdd: () => _open(const BusinessRegistrationPage()),
                child: _streamList(
                  'airsoft_businesses',
                  builder: _businessCard,
                  fallbackCollection: 'airsoft_business_applications',
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _placeCard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return _card(
      title: (d['name'] ?? 'PLACE').toString(),
      subtitle: (d['address'] ?? d['region'] ?? '-').toString(),
      body: (d['description'] ?? '').toString(),
      trailing: const Icon(Icons.location_on_rounded, color: _cyan),
      onLongPress: () => _ownerMenu(doc, 'airsoft_places'),
    );
  }

  Widget _businessCard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return _card(
      title: (d['name'] ?? d['businessName'] ?? 'BUSINESS').toString(),
      subtitle: '${d['category'] ?? '-'} · ${d['status'] ?? 'pending'}',
      body: (d['description'] ?? '').toString(),
      trailing: const Icon(Icons.storefront_rounded, color: Colors.greenAccent),
      onLongPress: () => _ownerMenu(doc, 'airsoft_businesses'),
    );
  }

  Future<void> _createPlace() async {
    final values = await _formDialog('경기장·장소 등록', [
      'name',
      'address',
      'contact',
      'description',
    ]);
    if (values == null || !_requireLogin()) return;
    await _db.collection('airsoft_places').add({
      ...values,
      'ownerUid': user!.uid,
      'ownerEmail': user!.email ?? '',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _msg(t('saved'));
  }

  Widget _market() => _listPage(
    title: t('market'),
    icon: Icons.add_shopping_cart_rounded,
    onAdd: () => _open(const MarketplacePage()),
    child: _streamList('airsoft_market_posts', builder: _marketCard),
  );

  Widget _marketCard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return _card(
      title: (d['title'] ?? 'ITEM').toString(),
      subtitle: '${d['price'] ?? '-'} · ${d['status'] ?? 'pending'}',
      body: (d['description'] ?? '').toString(),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _like(doc),
            icon: const Icon(Icons.favorite_border, color: Colors.pinkAccent),
          ),
          IconButton(
            onPressed:
                () => _report('market', doc.id, d['ownerUid']?.toString()),
            icon: const Icon(Icons.flag_outlined, color: _muted),
          ),
        ],
      ),
      onLongPress: () => _ownerMenu(doc, 'airsoft_market_posts'),
    );
  }

  Future<void> _like(DocumentSnapshot<Map<String, dynamic>> doc) async {
    if (!_requireLogin()) return;
    final ref = doc.reference.collection('likes').doc(user!.uid);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'uid': user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    _msg(t('saved'));
  }

  Widget _profile() {
    if (user == null)
      return Center(
        child: Text(t('login'), style: const TextStyle(color: Colors.white)),
      );
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _db.collection('airsoft_profiles').doc(user!.uid).snapshots(),
      builder: (context, s) {
        final d = s.data?.data() ?? {};
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _card(
              title:
                  (d['nickname'] ?? user!.displayName ?? 'AIRSOFT USER')
                      .toString(),
              subtitle: (d['region'] ?? '').toString(),
              body: (d['bio'] ?? 'Airsoft profile').toString(),
              trailing: CircleAvatar(
                backgroundColor: _purple,
                child: Text(
                  (d['nickname'] ?? user!.displayName ?? 'A')
                      .toString()
                      .characters
                      .first
                      .toUpperCase(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('프로필 수정'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _showMyApplications(),
              icon: const Icon(Icons.assignment_rounded),
              label: const Text('나의 신청 내역'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProfile() async {
    final current =
        (await _db.collection('airsoft_profiles').doc(user!.uid).get())
            .data() ??
        {};
    final values = await _formDialog('Airsoft 프로필', [
      'nickname',
      'region',
      'teamName',
      'bio',
    ], initial: current);
    if (values == null) return;
    await _db.collection('airsoft_profiles').doc(user!.uid).set({
      ...values,
      'uid': user!.uid,
      'email': user!.email ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': current['createdAt'] ?? FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _msg(t('saved'));
  }

  Future<void> _showMyApplications() async {
    final team =
        await _db
            .collectionGroup('applications')
            .where('uid', isEqualTo: user!.uid)
            .limit(50)
            .get();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: _panel,
      builder:
          (_) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '나의 신청 내역',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (team.docs.isEmpty)
                  _empty()
                else
                  ...team.docs.map(
                    (e) => ListTile(
                      title: Text(
                        e.reference.parent.parent?.id ?? '-',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        (e.data()['status'] ?? 'pending').toString(),
                        style: const TextStyle(color: _muted),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  Widget _listPage({
    required String title,
    required Widget child,
    VoidCallback? onAdd,
    IconData icon = Icons.add_rounded,
    bool compact = false,
  }) => Column(
    children: [
      if (!compact)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              if (onAdd != null)
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: Icon(icon),
                  label: Text(t('register')),
                ),
            ],
          ),
        ),
      if (compact && onAdd != null)
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: Icon(icon),
              label: Text(t('register')),
            ),
          ),
        ),
      Expanded(child: child),
    ],
  );

  Widget _streamList(
    String collection, {
    required Widget Function(DocumentSnapshot<Map<String, dynamic>>) builder,
    int limit = 50,
    String? fallbackCollection,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          _db
              .collection(collection)
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .snapshots(),
      builder: (context, s) {
        if (s.hasError && fallbackCollection != null) {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                _db
                    .collection(fallbackCollection)
                    .orderBy('createdAt', descending: true)
                    .limit(limit)
                    .snapshots(),
            builder: (c, x) => _snapshotList(x, builder),
          );
        }
        return _snapshotList(s, builder);
      },
    );
  }

  Widget _snapshotList(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> s,
    Widget Function(DocumentSnapshot<Map<String, dynamic>>) builder,
  ) {
    if (s.hasError) return _error(s.error);
    if (!s.hasData) return const Center(child: CircularProgressIndicator());
    if (s.data!.docs.isEmpty) return _empty();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 120),
      itemCount: s.data!.docs.length,
      itemBuilder: (_, i) => builder(s.data!.docs[i]),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    String body = '',
    Widget? trailing,
    VoidCallback? onLongPress,
  }) => GestureDetector(
    onLongPress: onLongPress,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: _box(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(color: _cyan, fontSize: 12),
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    ),
  );

  Future<void> _ownerMenu(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String collection,
  ) async {
    final d = doc.data() ?? {};
    if (user == null) return;
    if (d['ownerUid'] == user!.uid) {
      final action = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: _panel,
        builder:
            (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.redAccent),
                    title: const Text(
                      '삭제',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.pop(context, 'delete'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.close, color: Colors.white),
                    title: const Text(
                      '취소',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
      );
      if (action == 'delete') await doc.reference.delete();
    } else {
      await _report(collection, doc.id, d['ownerUid']?.toString());
    }
  }

  Future<void> _report(String type, String targetId, String? targetUid) async {
    if (!_requireLogin()) return;
    await _db.collection('airsoft_reports').add({
      'type': type,
      'targetId': targetId,
      'targetUid': targetUid ?? '',
      'reporterUid': user!.uid,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
    _msg(t('saved'));
  }

  Future<Map<String, String>?> _formDialog(
    String title,
    List<String> fields, {
    Map<String, dynamic> initial = const {},
  }) async {
    final cs = {
      for (final f in fields)
        f: TextEditingController(text: (initial[f] ?? '').toString()),
    };
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: _panel,
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      fields
                          .map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TextField(
                                controller: cs[f],
                                maxLines:
                                    f == 'description' || f == 'bio' ? 4 : 1,
                                style: const TextStyle(color: Colors.white),
                                decoration: _input(f),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.pop(context, {
                      for (final e in cs.entries) e.key: e.value.text.trim(),
                    }),
                child: const Text('저장'),
              ),
            ],
          ),
    );
    for (final c in cs.values) c.dispose();
    return result;
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  bool _requireLogin() {
    if (user != null) return true;
    _msg(t('login'));
    return false;
  }

  void _msg(String m) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
      );
  }

  Widget _empty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(t('empty'), style: const TextStyle(color: _muted)),
    ),
  );
  Widget _error(Object? e) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Firestore: $e',
        style: const TextStyle(color: Colors.redAccent),
      ),
    ),
  );
  Widget _sectionTitle(String s) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      s,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _muted),
    filled: true,
    fillColor: _panel,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.white12),
    ),
  );
  BoxDecoration _box({Gradient? gradient}) => BoxDecoration(
    color: gradient == null ? _panel : null,
    gradient: gradient,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.white.withOpacity(.08)),
  );
}
