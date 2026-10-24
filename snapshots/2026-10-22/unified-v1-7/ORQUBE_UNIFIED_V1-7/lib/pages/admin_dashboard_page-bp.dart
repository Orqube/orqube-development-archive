import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  static const _bg = Color(0xFF03040B);
  static const _panel = Color(0xFF0B0D1B);
  static const _panel2 = Color(0xFF111426);
  static const _lime = Color(0xFFD7FF35);
  static const _purple = Color(0xFF8B2CF6);
  static const _cyan = Color(0xFF55E6FF);
  static const _muted = Color(0xFFAAB0C5);

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  int _section = 0;
  bool _loading = true;
  bool _saving = false;
  bool _isAdmin = false;
  String? _error;
  Map<String, dynamic> _config = {};

  final _miningHours = TextEditingController(text: '24');
  final _miningRate = TextEditingController(text: '0.5');
  final _dailyPoints = TextEditingController(text: '20');
  final _dailyOrbs = TextEditingController(text: '0.02');
  final _adPoints = TextEditingController(text: '10');
  final _adOrbs = TextEditingController(text: '0.01');
  final _androidAdUnit = TextEditingController();
  final _iosAdUnit = TextEditingController();
  final _androidBannerAdUnit = TextEditingController();
  final _iosBannerAdUnit = TextEditingController();
  final _noticeTitle = TextEditingController();
  final _noticeBody = TextEditingController();
  String _contentType = 'notice';
  final _whitepaperUrl = TextEditingController(
    text: 'assets/docs/ORQUBE_Whitepaper_EN_2026.pdf',
  );

  bool _miningEnabled = true;
  bool _adEnabled = true;
  bool _webAdSenseEnabled = true;
  bool _adTestMode = true;
  bool _attendanceEnabled = true;
  bool _maintenanceMode = false;
  bool _popupEnabled = false;
  bool _airsoftEnabled = true;
  bool _nftEnabled = true;
  bool _registrationEnabled = true;

  final _sections = const [
    (Icons.dashboard_rounded, '운영 대시보드'),
    (Icons.people_alt_rounded, '회원 관리'),
    (Icons.bolt_rounded, '채굴 · 보상'),
    (Icons.ads_click_rounded, '광고 설정'),
    (Icons.auto_awesome_motion_rounded, 'AI 마케팅 센터'),
    (Icons.campaign_rounded, '공지 · 콘텐츠'),
    (Icons.sports_mma_rounded, 'Airsoft Hub'),
    (Icons.auto_awesome_rounded, 'NFT · 백서'),
    (Icons.language_rounded, '다국어 · 서비스'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _miningHours,
      _miningRate,
      _dailyPoints,
      _dailyOrbs,
      _adPoints,
      _adOrbs,
      _androidAdUnit,
      _iosAdUnit,
      _androidBannerAdUnit,
      _iosBannerAdUnit,
      _noticeTitle,
      _noticeBody,
      _whitepaperUrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = '관리자 페이지를 사용하려면 먼저 로그인해야 합니다.';
      });
      return;
    }
    try {
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final data = userDoc.data() ?? const <String, dynamic>{};
      final admin = data['isAdmin'] == true || data['role'] == 'admin';
      if (!admin) {
        setState(() {
          _loading = false;
          _isAdmin = false;
          _error =
              '관리자 권한이 없습니다. users/${user.uid} 문서에 isAdmin: true 또는 role: admin이 필요합니다.';
        });
        return;
      }
      final configDoc =
          await _db.collection('admin_config').doc('global').get();
      _config = configDoc.data() ?? <String, dynamic>{};
      _applyConfig(_config);
      setState(() {
        _loading = false;
        _isAdmin = true;
      });
    } on FirebaseException catch (e) {
      setState(() {
        _loading = false;
        _error = 'Firestore 확인 실패: ${e.message ?? e.code}';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '관리자 설정을 불러오지 못했습니다: $e';
      });
    }
  }

  void _applyConfig(Map<String, dynamic> d) {
    String value(String key, Object fallback) => '${d[key] ?? fallback}';
    _miningHours.text = value('miningDurationHours', 24);
    _miningRate.text = value('miningRatePerHour', 0.5);
    _dailyPoints.text = value('attendancePoints', 20);
    _dailyOrbs.text = value('attendanceOrbs', 0.02);
    _adPoints.text = value('adRewardPoints', 10);
    _adOrbs.text = value('adRewardOrbs', 0.01);
    _androidAdUnit.text = value('androidRewardedAdUnitId', '');
    _iosAdUnit.text = value('iosRewardedAdUnitId', '');
    _androidBannerAdUnit.text = value('androidBannerAdUnitId', '');
    _iosBannerAdUnit.text = value('iosBannerAdUnitId', '');
    _noticeTitle.text = value('popupTitle', '');
    _noticeBody.text = value('popupBody', '');
    _whitepaperUrl.text = value(
      'whitepaperUrl',
      'assets/docs/ORQUBE_Whitepaper_EN_2026.pdf',
    );
    _miningEnabled = d['miningEnabled'] ?? true;
    _adEnabled = d['adEnabled'] ?? true;
    _webAdSenseEnabled = d['webAdSenseEnabled'] ?? true;
    _adTestMode = d['adTestMode'] ?? true;
    _attendanceEnabled = d['attendanceEnabled'] ?? true;
    _maintenanceMode = d['maintenanceMode'] ?? false;
    _popupEnabled = d['popupEnabled'] ?? false;
    _airsoftEnabled = d['airsoftEnabled'] ?? true;
    _nftEnabled = d['nftEnabled'] ?? true;
    _registrationEnabled = d['registrationEnabled'] ?? true;
  }

  num _number(TextEditingController c, num fallback) =>
      num.tryParse(c.text.trim()) ?? fallback;

  Future<void> _save() async {
    if (!_isAdmin || _saving) return;
    setState(() => _saving = true);
    final data = <String, dynamic>{
      'miningEnabled': _miningEnabled,
      'miningDurationHours': _number(_miningHours, 24),
      'miningRatePerHour': _number(_miningRate, 0.5),
      'attendanceEnabled': _attendanceEnabled,
      'attendancePoints': _number(_dailyPoints, 20),
      'attendanceOrbs': _number(_dailyOrbs, 0.02),
      'adEnabled': _adEnabled,
      'webAdSenseEnabled': _webAdSenseEnabled,
      'adTestMode': _adTestMode,
      'adRewardPoints': _number(_adPoints, 10),
      'adRewardOrbs': _number(_adOrbs, 0.01),
      'androidRewardedAdUnitId': _androidAdUnit.text.trim(),
      'iosRewardedAdUnitId': _iosAdUnit.text.trim(),
      'androidBannerAdUnitId': _androidBannerAdUnit.text.trim(),
      'iosBannerAdUnitId': _iosBannerAdUnit.text.trim(),
      'popupEnabled': _popupEnabled,
      'popupTitle': _noticeTitle.text.trim(),
      'popupBody': _noticeBody.text.trim(),
      'whitepaperUrl': _whitepaperUrl.text.trim(),
      'airsoftEnabled': _airsoftEnabled,
      'nftEnabled': _nftEnabled,
      'registrationEnabled': _registrationEnabled,
      'maintenanceMode': _maintenanceMode,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': _auth.currentUser?.uid,
    };

    try {
      await _db
          .collection('admin_config')
          .doc('global')
          .set(data, SetOptions(merge: true));

      final title = _noticeTitle.text.trim();
      final body = _noticeBody.text.trim();

      if (title.isNotEmpty && body.isNotEmpty) {
        await _db.collection('community_posts').add({
          'title': title,
          'content': body,
          'body': body,
          'category': '공지',
          'type': 'notice',
          'isActive': true,
          'published': true,
          'createdAt': FieldValue.serverTimestamp(),
          'publishedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'createdBy': _auth.currentUser?.uid,
          'authorUid': _auth.currentUser?.uid,
          'authorName': '관리자',
          'uid': _auth.currentUser?.uid,
          'status': 'active',
          'visible': true,
          'isPinned': true,
        });
      }

      _config = {..._config, ...data};
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('관리자 설정이 저장되었습니다.')));
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: ${e.message ?? e.code}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _lime)),
      );
    }
    if (_error != null || !_isAdmin) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          foregroundColor: Colors.white,
          title: const Text('ORQUBE ADMIN'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_person_rounded, color: _lime, size: 64),
                  const SizedBox(height: 18),
                  const Text(
                    '관리자 접근 확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error ?? '관리자 권한이 없습니다.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final compact = MediaQuery.sizeOf(context).width < 920;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: _lime),
            SizedBox(width: 10),
            Text(
              'ORQUBE ADMIN CONTROL CENTER',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon:
                _saving
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.save_rounded),
            label: const Text('전체 설정 저장'),
            style: TextButton.styleFrom(foregroundColor: _lime),
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: compact ? Drawer(backgroundColor: _panel, child: _menu()) : null,
      body: Row(
        children: [
          if (!compact) SizedBox(width: 250, child: _menu()),
          Expanded(
            child: SelectionArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(compact ? 16 : 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: _content(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu() {
    return Container(
      color: _panel,
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: _purple,
            child: Icon(Icons.flight_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            'ORQUBE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const Text(
            'ADMINISTRATOR',
            style: TextStyle(color: _lime, fontSize: 11, letterSpacing: 1.6),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _sections.length,
              itemBuilder: (_, i) {
                final selected = _section == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    selected: selected,
                    selectedTileColor: _purple.withOpacity(.22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      _sections[i].$1,
                      color: selected ? _lime : _muted,
                    ),
                    title: Text(
                      _sections[i].$2,
                      style: TextStyle(
                        color: selected ? Colors.white : _muted,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      setState(() => _section = i);
                      if (MediaQuery.sizeOf(context).width < 920) {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Text(
            _auth.currentUser?.email ?? 'admin',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    switch (_section) {
      case 1:
        return _members();
      case 2:
        return _miningRewards();
      case 3:
        return _ads();
      case 4:
        return _aiMarketing();
      case 5:
        return _contentSettings();
      case 6:
        return _airsoft();
      case 7:
        return _nftWhitepaper();
      case 8:
        return _service();
      default:
        return _overview();
    }
  }

  Widget _heading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 29,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(color: _muted, height: 1.5)),
      const SizedBox(height: 24),
    ],
  );

  Widget _overview() {
    const collections = [
      ('users', '전체 회원', Icons.people_alt_rounded),
      ('airsoft_teams', 'Airsoft 팀', Icons.groups_rounded),
      ('airsoft_events', '등록 경기', Icons.event_rounded),
      ('airsoft_businesses', '입점 업체', Icons.store_rounded),
      ('airsoft_market_posts', '마켓 게시물', Icons.shopping_bag_rounded),
      ('community_posts', '커뮤니티 글', Icons.forum_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('운영 대시보드', 'ORQUBE 서비스의 핵심 운영 지표와 활성 기능을 확인합니다.'),
        LayoutBuilder(
          builder: (_, c) {
            final w = c.maxWidth < 700 ? c.maxWidth : (c.maxWidth - 36) / 3;
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children:
                  collections
                      .map(
                        (x) => SizedBox(
                          width: w,
                          child: _countCard(x.$1, x.$2, x.$3),
                        ),
                      )
                      .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '서비스 상태',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _status('채굴', _miningEnabled),
                  _status('광고 보상', _adEnabled),
                  _status('출석', _attendanceEnabled),
                  _status('Airsoft', _airsoftEnabled),
                  _status('NFT', _nftEnabled),
                  _status('회원가입', _registrationEnabled),
                  _status('점검 모드', _maintenanceMode, danger: true),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _countCard(String collection, String label, IconData icon) {
    return FutureBuilder<AggregateQuerySnapshot>(
      future: _db.collection(collection).count().get(),
      builder:
          (_, s) => _card(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _purple.withOpacity(.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: _lime),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.hasData ? '${s.data!.count ?? 0}' : '…',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _members() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('회원 관리', '최근 가입 회원을 확인하고 관리자 권한 및 계정 상태를 점검합니다.'),
        _referralAdminSummary(),
        const SizedBox(height: 18),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              _db
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .limit(50)
                  .snapshots(),
          builder: (_, s) {
            if (s.hasError)
              return _errorCard(
                '회원 목록을 읽지 못했습니다. createdAt 인덱스 또는 Firestore 규칙을 확인하세요.\n${s.error}',
              );
            if (!s.hasData)
              return const Center(
                child: CircularProgressIndicator(color: _lime),
              );
            final docs = s.data!.docs;
            if (docs.isEmpty) return _errorCard('등록된 회원이 없습니다.');
            return _card(
              child: Column(
                children:
                    docs.map((doc) {
                      final d = doc.data();
                      final name =
                          '${d['nickname'] ?? d['displayName'] ?? '이름 없음'}';
                      final email = '${d['email'] ?? ''}';
                      final admin =
                          d['isAdmin'] == true || d['role'] == 'admin';
                      final disabled = d['disabled'] == true;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                        leading: CircleAvatar(
                          backgroundColor: admin ? _purple : _panel2,
                          child: Icon(
                            admin
                                ? Icons.admin_panel_settings_rounded
                                : Icons.person_rounded,
                            color: admin ? _lime : Colors.white70,
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '$email\nUID: ${doc.id}',
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 6,
                          children: [
                            IconButton(
                              tooltip: admin ? '관리자 해제' : '관리자 지정',
                              onPressed:
                                  () => _setUser(doc.id, {
                                    'isAdmin': !admin,
                                    'role': !admin ? 'admin' : 'user',
                                  }),
                              icon: Icon(
                                Icons.admin_panel_settings_rounded,
                                color: admin ? _lime : Colors.white38,
                              ),
                            ),
                            IconButton(
                              tooltip: disabled ? '계정 활성 표시' : '계정 정지 표시',
                              onPressed:
                                  () =>
                                      _setUser(doc.id, {'disabled': !disabled}),
                              icon: Icon(
                                disabled
                                    ? Icons.lock_open_rounded
                                    : Icons.block_rounded,
                                color:
                                    disabled
                                        ? Colors.orangeAccent
                                        : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<List<int>> _referralAdminCounts() async {
    final results = await Future.wait<AggregateQuerySnapshot>([
      _db.collection('referrals').count().get(),
      _db.collection('referral_rewards').count().get(),
      _db.collection('referral_rewards').where('claimed', isEqualTo: true).count().get(),
    ]);
    return [
      results[0].count ?? 0,
      results[1].count ?? 0,
      results[2].count ?? 0,
    ];
  }

  Widget _referralAdminSummary() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.group_add_rounded, color: _lime),
              SizedBox(width: 10),
              Text(
                '친구초대 · 추천 통계',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<int>>(
            future: _referralAdminCounts(),
            builder: (_, snapshot) {
              final values = snapshot.data ?? const [0, 0, 0];
              final total = values[0];
              final rewardRecords = values[1];
              final claimed = values[2];
              final pending = rewardRecords - claimed;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _adminReferralMetric('추천 가입', '$total명', Icons.person_add_alt_1_rounded, _lime),
                  _adminReferralMetric('보상 수령', '$claimed건', Icons.verified_rounded, _cyan),
                  _adminReferralMetric('보상 대기', '${pending < 0 ? 0 : pending}건', Icons.hourglass_bottom_rounded, Colors.orangeAccent),
                  _adminReferralMetric('기준 보상', '20P + 0.02 ORBS', Icons.stars_rounded, Colors.amber),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          const Text('추천 상위 회원', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _db.collection('users').orderBy('referralCount', descending: true).limit(10).snapshots(),
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                return Text('추천 순위를 읽지 못했습니다. ${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 12));
              }
              if (!snapshot.hasData) {
                return const LinearProgressIndicator(color: _lime, backgroundColor: Colors.white10);
              }
              final docs = snapshot.data!.docs.where((d) => ((d.data()['referralCount'] as num?)?.toInt() ?? 0) > 0).toList();
              if (docs.isEmpty) {
                return const Text('아직 추천 가입 실적이 없습니다.', style: TextStyle(color: _muted));
              }
              return Column(
                children: docs.asMap().entries.map((entry) {
                  final d = entry.value.data();
                  final name = '${d['nickname'] ?? d['displayName'] ?? d['email'] ?? entry.value.id}';
                  final count = (d['referralCount'] as num?)?.toInt() ?? 0;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 17,
                      backgroundColor: _purple.withOpacity(.24),
                      child: Text('${entry.key + 1}', style: const TextStyle(color: _lime, fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                    title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    trailing: Text('$count명', style: const TextStyle(color: _lime, fontWeight: FontWeight.w900)),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _adminReferralMetric(String label, String value, IconData icon, Color color) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setUser(String uid, Map<String, dynamic> values) async {
    await _db.collection('users').doc(uid).set({
      ...values,
      'adminUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Widget _miningRewards() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('채굴 · ORBS · 출석 보상', '기존 24시간 채굴 구조를 유지하면서 운영 정책 값을 관리합니다.'),
      _card(
        child: Column(
          children: [
            _switchTile(
              '채굴 기능 사용',
              '전체 채굴 시작 기능을 운영합니다.',
              _miningEnabled,
              (v) => setState(() => _miningEnabled = v),
            ),
            const Divider(color: Colors.white12),
            _switchTile(
              '출석 보상 사용',
              '일일 출석 체크와 보상 지급을 운영합니다.',
              _attendanceEnabled,
              (v) => setState(() => _attendanceEnabled = v),
            ),
            const SizedBox(height: 12),
            _fields([
              ('채굴 주기(시간)', _miningHours),
              ('시간당 ORBS', _miningRate),
              ('출석 포인트', _dailyPoints),
              ('출석 ORBS', _dailyOrbs),
            ]),
          ],
        ),
      ),
      const SizedBox(height: 18),
      _saveBar(),
    ],
  );

  Widget _ads() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('광고 설정', '모바일 AdMob 보상형 광고와 웹 Google AdSense 표시 여부를 관리합니다.'),
      _card(
        child: Column(
          children: [
            _switchTile(
              '보상형 광고 사용',
              '광고 시청 후 포인트와 ORBS를 지급합니다.',
              _adEnabled,
              (v) => setState(() => _adEnabled = v),
            ),
            const Divider(color: Colors.white12),
            _switchTile(
              '웹 AdSense 표시',
              '홈페이지와 웹 채굴 화면의 반응형 AdSense 영역을 표시하거나 숨깁니다.',
              _webAdSenseEnabled,
              (v) => setState(() => _webAdSenseEnabled = v),
            ),
            const Divider(color: Colors.white12),
            _switchTile(
              '광고 테스트 모드',
              '출시 전에는 반드시 켜두세요. 끄면 아래 실제 광고 단위 ID를 사용합니다.',
              _adTestMode,
              (v) => setState(() => _adTestMode = v),
            ),
            const SizedBox(height: 12),
            _fields([('광고 보상 포인트', _adPoints), ('광고 보상 ORBS', _adOrbs)]),
            const SizedBox(height: 12),
            _field('Android Rewarded Ad Unit ID', _androidAdUnit),
            const SizedBox(height: 12),
            _field('iOS Rewarded Ad Unit ID', _iosAdUnit),
            const SizedBox(height: 12),
            _field('Android Banner Ad Unit ID', _androidBannerAdUnit),
            const SizedBox(height: 12),
            _field('iOS Banner Ad Unit ID', _iosBannerAdUnit),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '※ AdSense 게시자 ID와 웹 광고 단위 ID는 lib/adsense/adsense_config.dart에서 교체합니다. AdMob 앱 ID는 AndroidManifest.xml / Info.plist에 별도로 등록합니다.',
                style: TextStyle(color: _muted, height: 1.45),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      _saveBar(),
    ],
  );

  Widget _aiMarketing() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('AI 마케팅 센터', '외부 광고주의 광고 접수를 검토하고 승인·반려·노출 상태를 관리합니다.'),
      _card(
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SNS 자동 배포 원칙',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'ORQUBE 웹·앱 노출은 관리자 승인 후 가능합니다. Facebook 페이지, X, Telegram 등 외부 채널은 각 공식 API와 계정 권한이 연결된 경우에만 활성화해야 합니다. 네이버 카페와 개인 Facebook 그룹에는 임의 자동 게시하지 않습니다.',
              style: TextStyle(color: _muted, height: 1.55),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            _db
                .collection('marketing_campaigns')
                .orderBy('createdAt', descending: true)
                .limit(100)
                .snapshots(),
        builder: (_, s) {
          if (s.hasError)
            return _errorCard(
              '광고 접수 목록을 읽지 못했습니다. Firestore 규칙 또는 인덱스를 확인하세요.\n${s.error}',
            );
          if (!s.hasData)
            return const Center(child: CircularProgressIndicator(color: _lime));
          final docs = s.data!.docs;
          if (docs.isEmpty) return _errorCard('접수된 광고가 없습니다.');
          return Column(
            children:
                docs.map((doc) {
                  final d = doc.data();
                  final status = '${d['status'] ?? 'pending'}';
                  final statusColor =
                      status == 'approved'
                          ? _lime
                          : (status == 'rejected'
                              ? Colors.redAccent
                              : Colors.orangeAccent);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${d['title'] ?? '제목 없음'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${d['company'] ?? ''} · ${d['category'] ?? ''} · ${d['country'] ?? ''}',
                            style: const TextStyle(color: _cyan),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${d['description'] ?? ''}',
                            style: const TextStyle(color: _muted, height: 1.45),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            '${d['targetUrl'] ?? ''}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed:
                                    () =>
                                        _setCampaignStatus(doc.id, 'approved'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _purple,
                                ),
                                icon: const Icon(Icons.check_circle_rounded),
                                label: const Text('승인'),
                              ),
                              OutlinedButton.icon(
                                onPressed:
                                    () =>
                                        _setCampaignStatus(doc.id, 'rejected'),
                                icon: const Icon(Icons.cancel_rounded),
                                label: const Text('반려'),
                              ),
                              OutlinedButton.icon(
                                onPressed:
                                    () => _setCampaignStatus(doc.id, 'paused'),
                                icon: const Icon(Icons.pause_circle_rounded),
                                label: const Text('일시중지'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    ],
  );

  Future<void> _setCampaignStatus(String id, String status) async {
    await _db.collection('marketing_campaigns').doc(id).set({
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': _auth.currentUser?.uid,
    }, SetOptions(merge: true));
    if (mounted)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('광고 상태가 $status(으)로 변경되었습니다.')));
  }

  Widget _contentSettings() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('공지 · 이벤트 · 뉴스 · 팝업', '웹과 앱에 표시할 긴급 공지 및 팝업 내용을 관리합니다.'),
      _card(
        child: Column(
          children: [
            _switchTile(
              '팝업 공지 표시',
              '사용자 접속 시 중요 공지를 표시하도록 설정합니다.',
              _popupEnabled,
              (v) => setState(() => _popupEnabled = v),
            ),
            const SizedBox(height: 12),
            _field('팝업 제목', _noticeTitle),
            const SizedBox(height: 12),
            _field('팝업 내용', _noticeBody, lines: 5),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _contentType,
              dropdownColor: _panel2,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                labelText: '채굴화면 게시판 선택',
                labelStyle: const TextStyle(color: _muted),
                filled: true,
                fillColor: _panel2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'notice', child: Text('공지사항')),
                DropdownMenuItem(value: 'event', child: Text('이벤트')),
                DropdownMenuItem(value: 'airsoft', child: Text('AIRSOFT 소식')),
              ],
              onChanged:
                  (value) => setState(() => _contentType = value ?? 'notice'),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _publishNews,
                icon: const Icon(Icons.post_add_rounded),
                label: const Text('선택한 게시판에 실제 등록'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      _saveBar(),
    ],
  );

  Future<void> _publishNews() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final title = _noticeTitle.text.trim();
      final content = _noticeBody.text.trim();

      if (title.isEmpty || content.isEmpty) {
        throw Exception('제목과 내용을 입력하세요.');
      }

      final category =
          _contentType == 'event'
              ? '이벤트'
              : (_contentType == 'airsoft' ? 'AIRSOFT' : '공지');

      await _db.collection('orqube_news').add({
        'title': title,
        'content': content,
        'body': content,
        'category': category,
        'type': _contentType,
        'isActive': true,
        'published': true,
        'createdAt': FieldValue.serverTimestamp(),
        'publishedAt': FieldValue.serverTimestamp(),
        'authorUid': _auth.currentUser?.uid,
        'authorName': '관리자',
      });

      _noticeTitle.clear();
      _noticeBody.clear();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('공지가 저장되었습니다.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Widget _airsoft() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('Airsoft Hub 관리', '팀, 경기, 업체, 마켓 기능의 운영 상태와 등록 현황을 관리합니다.'),
      _card(
        child: _switchTile(
          'Airsoft Hub 사용',
          'Airsoft 메뉴와 관련 기능을 활성화합니다.',
          _airsoftEnabled,
          (v) => setState(() => _airsoftEnabled = v),
        ),
      ),
      const SizedBox(height: 18),
      LayoutBuilder(
        builder: (_, c) {
          final w = c.maxWidth < 700 ? c.maxWidth : (c.maxWidth - 18) / 2;
          return Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              SizedBox(
                width: w,
                child: _countCard(
                  'airsoft_teams',
                  '등록 팀',
                  Icons.groups_rounded,
                ),
              ),
              SizedBox(
                width: w,
                child: _countCard(
                  'airsoft_events',
                  '경기·이벤트',
                  Icons.event_rounded,
                ),
              ),
              SizedBox(
                width: w,
                child: _countCard(
                  'airsoft_businesses',
                  '입점 업체',
                  Icons.storefront_rounded,
                ),
              ),
              SizedBox(
                width: w,
                child: _countCard(
                  'airsoft_market_posts',
                  '마켓 글',
                  Icons.shopping_cart_rounded,
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 18),
      _saveBar(),
    ],
  );

  Widget _nftWhitepaper() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('NFT · 백서 관리', 'NFT 기능 활성화 상태와 웹 홈페이지 백서 연결 경로를 관리합니다.'),
      _card(
        child: Column(
          children: [
            _switchTile(
              'NFT 기능 사용',
              'NFT 대시보드 및 컬렉션 기능을 활성화합니다.',
              _nftEnabled,
              (v) => setState(() => _nftEnabled = v),
            ),
            const SizedBox(height: 12),
            _field('백서 PDF 또는 외부 URL', _whitepaperUrl),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '기본값: assets/docs/ORQUBE_Whitepaper_EN_2026.pdf',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      _saveBar(),
    ],
  );

  Widget _service() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('다국어 · 서비스 운영', '6개국어 서비스, 신규 회원가입 및 점검 모드를 제어합니다.'),
      _card(
        child: Column(
          children: [
            _switchTile(
              '신규 회원가입 허용',
              'Email/Google/Phone 가입 진입을 허용합니다.',
              _registrationEnabled,
              (v) => setState(() => _registrationEnabled = v),
            ),
            const Divider(color: Colors.white12),
            _switchTile(
              '서비스 점검 모드',
              '긴급 유지보수 시 사용자 기능 제한용 운영 플래그입니다.',
              _maintenanceMode,
              (v) => setState(() => _maintenanceMode = v),
              danger: true,
            ),
            const SizedBox(height: 18),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '지원 언어',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('🇰🇷 한국어')),
                Chip(label: Text('🇺🇸 English')),
                Chip(label: Text('🇯🇵 日本語')),
                Chip(label: Text('🇨🇳 中文')),
                Chip(label: Text('🇫🇷 Français')),
                Chip(label: Text('🇵🇹 Português')),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      _saveBar(),
    ],
  );

  Widget _fields(List<(String, TextEditingController)> fields) => LayoutBuilder(
    builder: (_, c) {
      final w = c.maxWidth < 650 ? c.maxWidth : (c.maxWidth - 14) / 2;
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children:
            fields
                .map((f) => SizedBox(width: w, child: _field(f.$1, f.$2)))
                .toList(),
      );
    },
  );

  Widget _field(
    String label,
    TextEditingController controller, {
    int lines = 1,
  }) => TextField(
    controller: controller,
    maxLines: lines,
    keyboardType: lines == 1 ? TextInputType.text : TextInputType.multiline,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted),
      filled: true,
      fillColor: _panel2,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lime),
      ),
    ),
  );

  Widget _switchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool danger = false,
  }) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    title: Text(
      title,
      style: TextStyle(
        color: danger ? Colors.orangeAccent : Colors.white,
        fontWeight: FontWeight.w800,
      ),
    ),
    subtitle: Text(subtitle, style: const TextStyle(color: _muted)),
    value: value,
    activeColor: danger ? Colors.orangeAccent : _lime,
    onChanged: onChanged,
  );

  Widget _saveBar() => Align(
    alignment: Alignment.centerRight,
    child: FilledButton.icon(
      onPressed: _saving ? null : _save,
      icon:
          _saving
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.save_rounded),
      label: const Text('설정 저장'),
      style: FilledButton.styleFrom(
        backgroundColor: _purple,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      ),
    ),
  );

  Widget _status(
    String label,
    bool enabled, {
    bool danger = false,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
    decoration: BoxDecoration(
      color: (enabled ? (danger ? Colors.orangeAccent : _lime) : Colors.white24)
          .withOpacity(.13),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color:
            enabled ? (danger ? Colors.orangeAccent : _lime) : Colors.white24,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          enabled ? Icons.check_circle_rounded : Icons.remove_circle_outline,
          color:
              enabled ? (danger ? Colors.orangeAccent : _lime) : Colors.white38,
          size: 16,
        ),
        const SizedBox(width: 7),
        Text(
          '$label ${enabled ? 'ON' : 'OFF'}',
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white54,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white10),
      boxShadow: [BoxShadow(color: _purple.withOpacity(.06), blurRadius: 24)],
    ),
    child: child,
  );

  Widget _errorCard(String text) => _card(
    child: Text(
      text,
      style: const TextStyle(color: Colors.orangeAccent, height: 1.5),
    ),
  );
}
