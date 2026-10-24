import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'whitepaper_center_page.dart';

import '../web_link.dart';
import '../utils/orqube_i18n.dart';
import 'login_page.dart';
import 'orqube_v14_entry.dart';
import 'admin_dashboard_page.dart';
import 'airsoft_map_page.dart';
import 'airsoft_hub_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class V16WebHomePage extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;

  const V16WebHomePage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  State<V16WebHomePage> createState() => _V16WebHomePageState();
}

class _V16WebHomePageState extends State<V16WebHomePage>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF030611);
  static const _panel = Color(0xE6101325);
  static const _purple = Color(0xFF8B2CF6);
  static const _violet = Color(0xFFB85CFF);
  static const _lime = Color(0xFFD7FF35);
  static const _cyan = Color(0xFF55E6FF);

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _whyKey = GlobalKey();
  final GlobalKey _howKey = GlobalKey();
  final GlobalKey _ecosystemKey = GlobalKey();
  final GlobalKey _roadmapKey = GlobalKey();

  late final AnimationController _spaceController;
  late final AnimationController _introController;

  @override
  void initState() {
    super.initState();
    _spaceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _spaceController.dispose();
    _introController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _ko => widget.language == 'ko';

  String _t(String ko, String en) =>
      OrqubeI18n.pair(widget.language, ko, en);

  Future<void> _scrollTo(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) return;
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      alignment: 0.04,
    );
  }

  void _openDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrqubeV14Entry()),
    );
  }

  void _startMining() {
    if (FirebaseAuth.instance.currentUser != null) {
      _openDashboard();
      return;
    }
    _openLogin();
  }

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onLoginSuccess: () async {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OrqubeV14Entry()),
            );
          },
        ),
      ),
    );
  }

  void _openAdmin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
    );
  }

  void _openWhitepaper() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WhitepaperCenterPage()),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_t('로그아웃되었습니다.', 'You have been signed out.'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _spaceController,
                  builder: (_, __) => CustomPaint(
                    painter: _SpacePainter(progress: _spaceController.value),
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _hero(),
                _advertisingSection(),
                _storyIntro(),
                _whySection(),
                _howSection(),
                _rewardStory(),
                _airsoftStory(),
                _ecosystemSection(),
                _footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 1050;

    final heroHeight = math.max(MediaQuery.sizeOf(context).height, 780.0);

    return SizedBox(
      width: double.infinity,
      height: heroHeight,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF02040D),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xE802040D),
                Color(0x85040A18),
                Color(0x9E02040D),
              ],
              stops: [0, .48, 1],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 24 : 64,
                vertical: 18,
              ),
              child: Column(
                children: [
                  _topBar(compact),
                  if (compact) ...[
                    const SizedBox(height: 12),
                    _mobileQuickAccess(),
                  ],
                  Expanded(
                    child: Align(
                      alignment:
                          compact ? Alignment.center : Alignment.centerLeft,
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _introController,
                          curve: const Interval(0, .75, curve: Curves.easeOut),
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, .12),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _introController,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 850),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                                  compact
                                      ? CrossAxisAlignment.center
                                      : CrossAxisAlignment.start,
                              children: [
                                _eyebrow('ORQUBE GLOBAL REWARD ECOSYSTEM'),
                                const SizedBox(height: 24),
                                Text(
                                  'AI × Web3 × Airsoft',
                                  textAlign:
                                      compact
                                          ? TextAlign.center
                                          : TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: MediaQuery.sizeOf(context).width < 600 ? 32 : (compact ? 46 : 76),
                                    height: .98,
                                    letterSpacing: -2.4,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                ShaderMask(
                                  shaderCallback:
                                      (rect) => const LinearGradient(
                                        colors: [_lime, _cyan, _violet],
                                      ).createShader(rect),
                                  child: Text(
                                    _t(
                                      '하나로 연결되는 글로벌 리워드 생태계',
                                      'One connected global reward ecosystem',
                                    ),
                                    textAlign:
                                        compact
                                            ? TextAlign.center
                                            : TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.sizeOf(context).width < 600 ? 19 : (compact ? 27 : 42),
                                      height: 1.14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                Text(
                                  _t(
                                    'ORQUBE는 AI, 블록체인, 광고 리워드, 디지털 자산,\n그리고 글로벌 Airsoft 커뮤니티를 하나의 경험으로 연결합니다.',
                                    'ORQUBE connects AI, blockchain, advertising rewards,\ndigital assets and the global Airsoft community.',
                                  ),
                                  textAlign:
                                      compact
                                          ? TextAlign.center
                                          : TextAlign.left,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.76),
                                    fontSize: MediaQuery.sizeOf(context).width < 600 ? 14.5 : (compact ? 18 : 21),
                                    height: 1.7,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 34),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment:
                                      compact
                                          ? WrapAlignment.center
                                          : WrapAlignment.start,
                                  children: [
                                    _primaryButton(
                                      _t('채굴 시작하기', 'START MINING'),
                                      Icons.bolt_rounded,
                                      _startMining,
                                    ),
                                    _outlineButton(
                                      _t('백서 보기', 'WHITEPAPER'),
                                      Icons.description_outlined,
                                      _openWhitepaper,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(bool compact) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo/orqube_plane_logo.png',
          width: 52,
          height: 52,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.flight_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'ORQUBE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 24),
        if (!compact) ...[
          _topAirsoftHubButton(_t('에어소프트 허브', 'Airsoft Hub'), Icons.sports_mma_rounded),
          const SizedBox(width: 8),
          _topModeButton(_t('안심귀가', 'Safe Home'), Icons.shield_rounded, OrqubeMapMode.safeHome),
          const SizedBox(width: 8),
          _topModeButton(_t('안전산행', 'Safe Hiking'), Icons.terrain_rounded, OrqubeMapMode.safeHiking),
        ],
        const Spacer(),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.language,
            dropdownColor: const Color(0xFF111426),
            iconEnabledColor: Colors.white70,
            style: const TextStyle(color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'ko', child: Text('🇰🇷 KO')),
              DropdownMenuItem(value: 'en', child: Text('🇺🇸 EN')),
              DropdownMenuItem(value: 'ja', child: Text('🇯🇵 JA')),
              DropdownMenuItem(value: 'zh', child: Text('🇨🇳 ZH')),
              DropdownMenuItem(value: 'fr', child: Text('🇫🇷 FR')),
              DropdownMenuItem(value: 'pt', child: Text('🇵🇹 PT')),
            ],
            onChanged: (value) {
              if (value != null) widget.onLanguageChanged(value);
            },
          ),
        ),
        const SizedBox(width: 10),
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            if (user == null) {
              return FilledButton.icon(
                onPressed: _openLogin,
                icon: const Icon(Icons.login_rounded, size: 18),
                label: Text(_t('로그인', 'Login')),
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
              );
            }

            final displayName = (user.displayName?.trim().isNotEmpty ?? false)
                ? user.displayName!.trim()
                : (user.email?.split('@').first ?? 'ORQUBE USER');

            return PopupMenuButton<String>(
              tooltip: user.email ?? displayName,
              color: const Color(0xFF111426),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    _openProfile();
                    break;
                  case 'settings':
                    _openSettings();
                    break;
                  case 'logout':
                    _logout();
                    break;
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(
                    user.email ?? displayName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.person_rounded, color: _cyan),
                    title: Text(_t('프로필', 'Profile'), style: const TextStyle(color: Colors.white)),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.settings_rounded, color: _lime),
                    title: Text(_t('설정', 'Settings'), style: const TextStyle(color: Colors.white)),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: Text(_t('로그아웃', 'Logout'), style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.07),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(.16)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_circle_rounded, color: _lime, size: 23),
                    if (!compact) ...[
                      const SizedBox(width: 7),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 125),
                        child: Text(
                          displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                    const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _openProtectedAirsoftHub() async {
    void openHub() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AirsoftHubPage()),
      );
    }

    if (FirebaseAuth.instance.currentUser != null) {
      openHub();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onLoginSuccess: () async {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AirsoftHubPage()),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openProtectedMap(OrqubeMapMode mode) async {
    void openMap() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AirsoftMapPage(initialMode: mode)),
      );
    }

    if (FirebaseAuth.instance.currentUser != null) {
      openMap();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginPage(
          onLoginSuccess: () async {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AirsoftMapPage(initialMode: mode),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topModeButton(String label, IconData icon, OrqubeMapMode mode) {
    return OutlinedButton.icon(
      onPressed: () => _openProtectedMap(mode),
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: _cyan.withOpacity(.45)),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      ),
    );
  }

  Widget _topAirsoftHubButton(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: _openProtectedAirsoftHub,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: _cyan.withOpacity(.45)),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      ),
    );
  }

  Widget _mobileQuickAccess() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _topAirsoftHubButton(_t('에어소프트 허브', 'Airsoft Hub'), Icons.sports_mma_rounded),
          const SizedBox(width: 8),
          _topModeButton(_t('안심귀가', 'Safe Home'), Icons.shield_rounded, OrqubeMapMode.safeHome),
          const SizedBox(width: 8),
          _topModeButton(_t('안전산행', 'Safe Hiking'), Icons.terrain_rounded, OrqubeMapMode.safeHiking),
        ],
      ),
    );
  }

  Widget _advertisingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              _sectionHeader(
                'ADVERTISING',
                _t('ORQUBE 파트너 광고', 'ORQUBE Partner Advertising'),
                _t(
                  '승인된 에어소프트·캠핑·등산 관련 업체 광고가 표시되는 영역입니다.',
                  'Approved Airsoft, camping and hiking partner ads appear here.',
                ),
              ),
              const SizedBox(height: 28),
              _adPlaceholder(
                icon: Icons.campaign_outlined,
                title: _t('자체 업체 광고 영역', 'Partner banner area'),
                subtitle: _t('PC·모바일 반응형 배너', 'Responsive desktop and mobile banner'),
              ),
              const SizedBox(height: 20),
              _adPlaceholder(
                icon: Icons.ads_click_outlined,
                title: 'Google AdSense',
                subtitle: _t('운영 광고 코드 연결 전 안전한 대체 영역', 'Safe placeholder until production ad code is connected'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _lime, size: 34),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.62), fontSize: 15, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyIntro() {
    return _storyPanel(
      number: '01',
      eyebrow: 'THE STORY',
      title: _t(
        '우리는 단순한 채굴 앱을\n만들지 않습니다.',
        'We are not building\njust another mining app.',
      ),
      body: _t(
        '사용자의 참여, 커뮤니티 활동, 광고 경험과 디지털 자산이\n하나의 가치 흐름으로 이어지는 새로운 생태계를 만듭니다.',
        'We are creating an ecosystem where participation, community,\nadvertising experiences and digital assets become one value flow.',
      ),
      button: _t('왜 ORQUBE인가', 'WHY ORQUBE'),
      icon: Icons.public_rounded,
      onPressed: () => _scrollTo(_whyKey),
      reverse: false,
    );
  }

  Widget _whySection() {
    return Container(
      key: _whyKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              _sectionHeader(
                'WHY ORQUBE',
                _t('하나의 프로젝트.\n네 개의 핵심 가치.', 'One project.\nFour core values.'),
                _t(
                  '사용자가 무엇을 얻고, 왜 참여해야 하는지를 가장 먼저 보여줍니다.',
                  'The value of participation is clear from the very beginning.',
                ),
              ),
              const SizedBox(height: 46),
              LayoutBuilder(
                builder: (_, constraints) {
                  final itemWidth =
                      constraints.maxWidth >= 1000 ? 285.0 : 520.0;
                  return Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    alignment: WrapAlignment.center,
                    children:
                        [
                          _valueCard(
                            Icons.auto_awesome_rounded,
                            'AI MARKETING',
                            _t(
                              'AI가 다국어 콘텐츠 제작과 글로벌 홍보를 지원합니다.',
                              'AI supports multilingual content and global promotion.',
                            ),
                            _violet,
                          ),
                          _valueCard(
                            Icons.bolt_rounded,
                            'DAILY MINING',
                            _t(
                              '매일 참여하고 ORBS 리워드를 축적합니다.',
                              'Participate daily and build ORBS rewards.',
                            ),
                            _lime,
                          ),
                          _valueCard(
                            Icons.radar_rounded,
                            'AIRSOFT HUB',
                            _t(
                              '팀, 경기, 지도, 업체와 마켓을 하나로 연결합니다.',
                              'Connect teams, matches, maps, businesses and markets.',
                            ),
                            _cyan,
                          ),
                          _valueCard(
                            Icons.diamond_outlined,
                            'NFT & ASSETS',
                            _t(
                              '보상과 디지털 자산을 지갑에서 관리합니다.',
                              'Manage rewards and digital assets in one wallet.',
                            ),
                            Colors.pinkAccent,
                          ),
                        ].map((card) => SizedBox(width: itemWidth, child: card)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _howSection() {
    return Container(
      key: _howKey,
      width: double.infinity,
      color: Colors.black.withOpacity(.18),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              _sectionHeader(
                'HOW IT WORKS',
                _t(
                  '읽고, 참여하고,\n가치를 확장합니다.',
                  'Discover, participate,\nand grow value.',
                ),
                _t(
                  '복잡한 기술보다 사용자가 이해하기 쉬운 네 단계에 집중합니다.',
                  'Four simple steps turn technology into an understandable experience.',
                ),
              ),
              const SizedBox(height: 50),
              LayoutBuilder(
                builder: (_, constraints) {
                  final narrow = constraints.maxWidth < 800;
                  final steps = [
                    _step(
                      '01',
                      _t('가입', 'JOIN'),
                      _t(
                        '계정을 만들고 생태계에 입장합니다.',
                        'Create an account and enter the ecosystem.',
                      ),
                    ),
                    _step(
                      '02',
                      _t('참여', 'PARTICIPATE'),
                      _t(
                        '채굴, 광고, 출석과 커뮤니티에 참여합니다.',
                        'Mine, check in, view ads and join the community.',
                      ),
                    ),
                    _step(
                      '03',
                      _t('획득', 'EARN'),
                      _t(
                        'POINT와 ORBS 리워드를 축적합니다.',
                        'Accumulate POINT and ORBS rewards.',
                      ),
                    ),
                    _step(
                      '04',
                      _t('활용', 'USE'),
                      _t(
                        'Wallet, NFT, Airsoft와 Marketplace로 확장합니다.',
                        'Expand into Wallet, NFT, Airsoft and Marketplace.',
                      ),
                    ),
                  ];
                  return narrow
                      ? Column(
                        children:
                            steps
                                .expand((e) => [e, const SizedBox(height: 14)])
                                .toList(),
                      )
                      : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            steps
                                .map((e) => Expanded(child: e))
                                .expand((e) => [e, const SizedBox(width: 14)])
                                .toList()
                              ..removeLast(),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rewardStory() {
    return _storyPanel(
      number: '02',
      eyebrow: 'REWARD EXPERIENCE',
      title: _t('매일의 참여가\n리워드가 됩니다.', 'Daily participation\nbecomes a reward.'),
      body: _t(
        '채굴, 출석, 광고 참여와 커뮤니티 활동이 하나의 리워드 경험으로 연결됩니다.\n사용자는 복잡한 기술을 몰라도 자연스럽게 ORQUBE 생태계에 참여합니다.',
        'Mining, check-ins, advertising and community activity connect into one reward experience.',
      ),
      button: _t('채굴 화면 입장', 'ENTER MINING'),
      icon: Icons.auto_graph_rounded,
      onPressed: _openDashboard,
      reverse: true,
    );
  }

  Widget _airsoftStory() {
    return _storyPanel(
      number: '03',
      eyebrow: 'GLOBAL AIRSOFT HUB',
      title: _t(
        '팀과 경기,\n세계를 지도 위에서 연결합니다.',
        'Connect teams, matches\nand the world on one map.',
      ),
      body: _t(
        '팀 찾기, 경기 등록, 경기장 지도, 업체 입점과 안전한 마켓까지.\nORQUBE Airsoft Hub가 흩어진 경험을 하나의 글로벌 네트워크로 만듭니다.',
        'Teams, matches, venues, businesses and a safer marketplace become one global network.',
      ),
      button: _t('AIRSOFT HUB 입장', 'ENTER AIRSOFT HUB'),
      icon: Icons.radar_rounded,
      onPressed: _openDashboard,
      reverse: false,
    );
  }

  Widget _ecosystemSection() {
    final items = [
      (
        Icons.account_balance_wallet_outlined,
        'WALLET',
        _t('ORBS와 디지털 자산 관리', 'Manage ORBS and digital assets'),
      ),
      (
        Icons.bolt_rounded,
        'MINING',
        _t('24시간 참여형 리워드', '24-hour participation rewards'),
      ),
      (
        Icons.diamond_outlined,
        'NFT',
        _t(
          '등급과 혜택을 가진 디지털 컬렉션',
          'Digital collections with grades and benefits',
        ),
      ),
      (
        Icons.radar_rounded,
        'AIRSOFT',
        _t('팀·경기·지도·업체 통합 허브', 'Teams, matches, maps and businesses'),
      ),
      (
        Icons.forum_outlined,
        'COMMUNITY',
        _t('국내외 사용자가 연결되는 공간', 'A space connecting global users'),
      ),
      (
        Icons.storefront_outlined,
        'MARKET',
        _t('안전 품목 중심의 거래 공간', 'A marketplace focused on safer items'),
      ),
    ];

    return Container(
      key: _ecosystemKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              _sectionHeader(
                'ORQUBE ECOSYSTEM',
                _t(
                  '스토리를 이해했다면,\n이제 직접 선택하세요.',
                  'Now that you know the story,\nchoose your experience.',
                ),
                _t(
                  '모든 서비스는 하나의 계정과 리워드 흐름으로 이어집니다.',
                  'Every service connects through one account and reward flow.',
                ),
              ),
              const SizedBox(height: 44),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children:
                    items.map((item) {
                      return SizedBox(
                        width: 360,
                        child: InkWell(
                          onTap: _openDashboard,
                          borderRadius: BorderRadius.circular(24),
                          child: _glass(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: _purple.withOpacity(.16),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(item.$1, color: _lime, size: 28),
                                ),
                                const SizedBox(width: 17),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.$2,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.$3,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(.58),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white38,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roadmapSection() {
    final phases = [
      (
        '01',
        'MVP',
        _t('채굴·출석·지갑·커뮤니티 기반', 'Mining, attendance, wallet and community'),
      ),
      (
        '02',
        'AIRSOFT HUB',
        _t('팀·경기·지도·업체·마켓', 'Teams, matches, maps, businesses and market'),
      ),
      (
        '03',
        'AI MARKETING',
        _t('6개국어 글로벌 콘텐츠 확장', 'Six-language global content expansion'),
      ),
      (
        '04',
        'WEB3 EXPANSION',
        _t('Kaia·NFT·메인넷 단계 확장', 'Kaia, NFT and mainnet expansion'),
      ),
    ];

    return Container(
      key: _roadmapKey,
      width: double.infinity,
      color: Colors.black.withOpacity(.22),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            children: [
              _sectionHeader(
                'ROADMAP',
                _t(
                  '작은 기능을 쌓아\n큰 생태계로 확장합니다.',
                  'Build practical features,\nthen scale the ecosystem.',
                ),
                _t(
                  '각 단계는 실제 사용자 경험과 안정성을 확인하며 진행합니다.',
                  'Each phase grows through tested user experience and stability.',
                ),
              ),
              const SizedBox(height: 48),
              Column(
                children:
                    phases.map((phase) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _glass(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 22,
                          ),
                          child: Row(
                            children: [
                              Text(
                                phase.$1,
                                style: const TextStyle(
                                  color: _lime,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      phase.$2,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      phase.$3,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.58),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: _violet,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 18),
              _outlineButton(
                _t('백서에서 전체 계획 보기', 'VIEW FULL PLAN IN WHITEPAPER'),
                Icons.description_outlined,
                _openWhitepaper,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _finalCta() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 620),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _eyebrow('THE NEXT JOURNEY'),
              const SizedBox(height: 24),
              Text(
                _t(
                  'ORQUBE의 새로운 여정에\n함께하세요.',
                  'Join the next journey\nof ORQUBE.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 55,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.6,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                _t(
                  'AI와 Web3가 만나는 글로벌 리워드 플랫폼.',
                  'A global reward platform where AI meets Web3.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.6),
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 34),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _primaryButton(
                    _t('지금 시작하기', 'START NOW'),
                    Icons.rocket_launch_rounded,
                    _openLogin,
                  ),
                  _outlineButton(
                    _t('채굴 체험하기', 'EXPLORE MINING'),
                    Icons.bolt_rounded,
                    _openDashboard,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('© 2026 ORQUBE', style: TextStyle(color: Colors.white54)),
          TextButton(
            onPressed: () => openExternalUrl('https://t.me/orqubic7'),
            child: const Text('TELEGRAM'),
          ),
          TextButton(
            onPressed: () => openExternalUrl('https://x.com/orqubic'),
            child: const Text('X'),
          ),
          TextButton(
            onPressed: () => openExternalUrl('https://youtube.com/@orqube?si=B1nKawDECkxkLh8m'),
            child: const Text('YOUTUBE'),
          ),
          TextButton(onPressed: _openAdmin, child: const Text('ADMIN')),
          TextButton(onPressed: () {}, child: Text(_t('개인정보처리방침', 'PRIVACY'))),
          TextButton(onPressed: () {}, child: Text(_t('이용약관', 'TERMS'))),
        ],
      ),
    );
  }

  Widget _storyPanel({
    required String number,
    required String eyebrow,
    required String title,
    required String body,
    required String button,
    required IconData icon,
    required VoidCallback onPressed,
    required bool reverse,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 720),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 92),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (_, constraints) {
              final narrow = constraints.maxWidth < 840;
              final visual = _storyVisual(number, icon);
              final copy = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    narrow
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                children: [
                  _eyebrow(eyebrow),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    textAlign: narrow ? TextAlign.center : TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: narrow ? 39 : 54,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    body,
                    textAlign: narrow ? TextAlign.center : TextAlign.left,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.62),
                      fontSize: 18,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _primaryButton(
                    button,
                    Icons.arrow_forward_rounded,
                    onPressed,
                  ),
                ],
              );

              if (narrow) {
                return Column(
                  children: [visual, const SizedBox(height: 44), copy],
                );
              }
              return Row(
                children:
                    reverse
                        ? [
                          Expanded(child: copy),
                          const SizedBox(width: 70),
                          Expanded(child: visual),
                        ]
                        : [
                          Expanded(child: visual),
                          const SizedBox(width: 70),
                          Expanded(child: copy),
                        ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _storyVisual(String number, IconData icon) {
    return AspectRatio(
      aspectRatio: 1.05,
      child: _glass(
        padding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_purple.withOpacity(.55), _purple.withOpacity(.04)],
                ),
                border: Border.all(color: _violet.withOpacity(.75), width: 1.5),
                boxShadow: [
                  BoxShadow(color: _purple.withOpacity(.35), blurRadius: 60),
                ],
              ),
              child: Icon(icon, color: _lime, size: 82),
            ),
            Positioned(
              left: 24,
              top: 20,
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white.withOpacity(.14),
                  fontSize: 74,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Positioned(
              right: 22,
              bottom: 20,
              child: Text(
                'ORQUBE NETWORK',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String eyebrow, String title, String body) {
    return Column(
      children: [
        _eyebrow(eyebrow),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            height: 1.08,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 17),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(.58),
            fontSize: 17,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _valueCard(IconData icon, String title, String body, Color accent) {
    return _glass(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: accent.withOpacity(.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent.withOpacity(.38)),
            ),
            child: Icon(icon, color: accent, size: 29),
          ),
          const SizedBox(height: 23),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withOpacity(.58),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String number, String title, String body) {
    return _glass(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: _lime,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withOpacity(.56),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glass({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.32),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _eyebrow(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: _purple.withOpacity(.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _violet.withOpacity(.35)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _lime,
          letterSpacing: 1.7,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _nav(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: .6,
        ),
      ),
    );
  }

  Widget _primaryButton(String text, IconData icon, VoidCallback onPressed) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: .3,
          ),
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: _purple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        shadowColor: _purple.withOpacity(.5),
      ),
    );
  }

  Widget _outlineButton(String text, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(.24)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.black.withOpacity(.18),
      ),
    );
  }
}

class _SpacePainter extends CustomPainter {
  final double progress;

  _SpacePainter({required this.progress});

  static final List<_SpacePoint> _stars = _makePoints(92, 72026);
  static final List<_SpacePoint> _particles = _makePoints(28, 220726);

  static List<_SpacePoint> _makePoints(int count, int seed) {
    final random = math.Random(seed);
    return List.generate(
      count,
      (index) => _SpacePoint(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: .225 + random.nextDouble() * .875,
        phase: random.nextDouble() * math.pi * 2,
        speed: .45 + random.nextDouble() * 1.15,
      ),
      growable: false,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintNebula(canvas, size);
    _paintStars(canvas, size);
    _paintParticles(canvas, size);
    _paintShootingStars(canvas, size);
  }

  void _paintNebula(Canvas canvas, Size size) {
    final driftX = math.sin(progress * math.pi * 2) * size.width * .035;
    final driftY = math.cos(progress * math.pi * 2) * size.height * .025;

    final purpleCenter = Offset(size.width * .72 + driftX, size.height * .24 + driftY);
    final cyanCenter = Offset(size.width * .18 - driftX * .7, size.height * .68 - driftY * .6);

    final purple = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B2CF6).withOpacity(.18),
          const Color(0xFF4A1A86).withOpacity(.08),
          Colors.transparent,
        ],
        stops: const [0, .48, 1],
      ).createShader(Rect.fromCircle(center: purpleCenter, radius: size.shortestSide * .58));
    canvas.drawCircle(purpleCenter, size.shortestSide * .58, purple);

    final cyan = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF55E6FF).withOpacity(.10),
          const Color(0xFF12345A).withOpacity(.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: cyanCenter, radius: size.shortestSide * .42));
    canvas.drawCircle(cyanCenter, size.shortestSide * .42, cyan);
  }

  void _paintStars(Canvas canvas, Size size) {
    for (var i = 0; i < _stars.length; i++) {
      final star = _stars[i];
      final twinkle = .35 + .65 * ((math.sin(progress * math.pi * 2 * star.speed + star.phase) + 1) / 2);
      final point = Offset(star.x * size.width, star.y * size.height);
      final radius = star.radius * (.78 + twinkle * .34);

      if (i % 7 == 0) {
        canvas.drawCircle(
          point,
          radius * 2.8,
          Paint()
            ..color = Colors.white.withOpacity(.08 * twinkle)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 2.2),
        );
      }
      canvas.drawCircle(
        point,
        radius,
        Paint()..color = Colors.white.withOpacity(.28 + .62 * twinkle),
      );
    }
  }

  void _paintParticles(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < _particles.length; i++) {
      final particle = _particles[i];
      final y = (particle.y + progress * (.035 + particle.speed * .018)) % 1.0;
      final x = particle.x + math.sin(progress * math.pi * 2 + particle.phase) * .008;
      final point = Offset(x * size.width, y * size.height);
      paint.color = (i.isEven ? const Color(0xFF55E6FF) : const Color(0xFFB85CFF))
          .withOpacity(.12 + particle.radius * .06);
      canvas.drawCircle(point, .7 + particle.radius * .55, paint);
    }
  }

  void _paintShootingStars(Canvas canvas, Size size) {
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height);
    for (var i = 0; i < 2; i++) {
      final local = (progress + i * .53) % 1.0;
      if (local > .16) continue;
      final t = local / .16;
      final fade = math.sin(t * math.pi);
      final head = Offset(
        size.width * (.12 + i * .43) + diagonal * .22 * t,
        size.height * (.10 + i * .16) + diagonal * .09 * t,
      );
      final tail = Offset(head.dx - 105, head.dy - 44);
      final meteor = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF55E6FF).withOpacity(.55 * fade),
            Colors.white.withOpacity(.95 * fade),
          ],
        ).createShader(Rect.fromPoints(tail, head))
        ..strokeWidth = 2.1
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(tail, head, meteor);
    }
  }

  @override
  bool shouldRepaint(covariant _SpacePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SpacePoint {
  final double x;
  final double y;
  final double radius;
  final double phase;
  final double speed;

  const _SpacePoint({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.speed,
  });
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF8B2CF6).withOpacity(.16)
          ..strokeWidth = .8;
    const gap = 38.0;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
