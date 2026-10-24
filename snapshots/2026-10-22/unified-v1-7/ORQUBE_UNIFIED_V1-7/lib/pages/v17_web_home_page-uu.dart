import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'whitepaper_center_page.dart';
import 'public_reward_guide_page.dart';
import 'public_help_center_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../web_link.dart';
import 'login_page.dart';
import 'admin_dashboard_page.dart';
import 'ai_marketing_center_page.dart';
import 'orqube_v14_entry.dart';
import 'airsoft_map_page.dart';
import 'airsoft_hub_page.dart';
import 'community_hub_page.dart';
import '../adsense/adsense_ad.dart';
import '../orqube_public_content_config.dart';

class _FeaturedVideoBadge extends StatelessWidget {
  const _FeaturedVideoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.68),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: const Text(
        'YOUTUBE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: .7,
        ),
      ),
    );
  }
}

class V17WebHomePage extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;

  const V17WebHomePage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  State<V17WebHomePage> createState() => _V17WebHomePageState();
}

class _V17WebHomePageState extends State<V17WebHomePage>
    with TickerProviderStateMixin {
  static const Color _bg = Color(0xFF02040B);
  static const Color _panel = Color(0xD90C1020);
  static const Color _purple = Color(0xFF8B2CF6);
  static const Color _violet = Color(0xFFB85CFF);
  static const Color _lime = Color(0xFFD7FF35);
  static const Color _cyan = Color(0xFF55E6FF);

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _whyKey = GlobalKey();
  final GlobalKey _howKey = GlobalKey();
  final GlobalKey _ecosystemKey = GlobalKey();
  final GlobalKey _roadmapKey = GlobalKey();

  late final AnimationController _backgroundController;
  late final AnimationController _heroController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _heroController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _t({
    required String ko,
    required String en,
    required String ja,
    required String zh,
    required String fr,
    required String pt,
  }) {
    switch (widget.language) {
      case 'en':
        return en;
      case 'ja':
        return ja;
      case 'zh':
        return zh;
      case 'fr':
        return fr;
      case 'pt':
        return pt;
      case 'ko':
      default:
        return ko;
    }
  }

  double _mobileTitleSize(double desktopSize, {double ratio = .68}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 380) return desktopSize * .62;
    if (width < 600) return desktopSize * ratio;
    return desktopSize;
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final target = key.currentContext;
    if (target == null) return;

    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOutCubic,
      alignment: 0.02,
    );
  }

  void _openDashboard() {
    // 비회원도 채굴 대시보드 화면 자체는 체험할 수 있습니다.
    // 실제 채굴 시작·보상 저장·자산 기능은 대시보드 내부에서 인증합니다.
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OrqubeV14Entry()));
  }

  void _openMarketingCenter() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AiMarketingCenterPage()));
  }

  void _openAdmin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
  }

  Future<void> _openProtectedAirsoftHub() async {
    // 둘러보기는 공개. 참가·등록·채팅 같은 기록 동작은 Hub 내부에서 인증합니다.
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AirsoftHubPage()));
  }

  Future<void> _openProtectedMap(OrqubeMapMode mode) async {
    // 지도·GPS·안전산행 오프라인 지도는 공개. 공유·SOS 서버전송 등은 지도 내부에서 인증합니다.
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AirsoftMapPage(initialMode: mode)),
    );
  }

  void _openCommunity() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CommunityHubPage()));
  }

  Future<void> _requireLoginThen(WidgetBuilder destination) async {
    if (FirebaseAuth.instance.currentUser != null) {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: destination));
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => LoginPage(
              onLoginSuccess: () async {
                if (!mounted) return;
                Navigator.of(
                  context,
                ).pushReplacement(MaterialPageRoute(builder: destination));
              },
            ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _showLanguageMenu() async {
    final selected = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => SimpleDialog(
            backgroundColor: const Color(0xFF101426),
            title: Text(
              _t(
                ko: '언어 선택',
                en: 'Language',
                ja: '言語選択',
                zh: '选择语言',
                fr: 'Langue',
                pt: 'Idioma',
              ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, 'ko'),
                child: Text('한국어', style: const TextStyle(color: Colors.white)),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, 'en'),
                child: Text(
                  'English',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, 'ja'),
                child: Text('日本語', style: const TextStyle(color: Colors.white)),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, 'zh'),
                child: Text('中文', style: const TextStyle(color: Colors.white)),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, 'fr'),
                child: Text(
                  'Français',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, 'pt'),
                child: Text(
                  'Português',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
    if (selected != null) widget.onLanguageChanged(selected);
  }

  void _openLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => LoginPage(
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

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              ko: '로그아웃되었습니다.',
              en: 'You have been signed out.',
              ja: 'ログアウトしました。',
              zh: '已退出登录。',
              fr: 'Vous êtes déconnecté.',
              pt: 'Sessão encerrada.',
            ),
          ),
        ),
      );
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $error')));
    }
  }

  void _openWhitepaper() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const WhitepaperCenterPage()));
  }

  void _openRewardGuide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicRewardGuidePage(language: widget.language),
      ),
    );
  }

  void _openHelpCenter() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicHelpCenterPage(language: widget.language),
      ),
    );
  }

  void _openTelegram() {
    openExternalUrl('https://t.me/orqubic7');
  }

  void _downloadAndroidApp() {
    // Public APK download: no ORQUBE sign-in is required.
    final apkUrl = Uri.base.resolve('/apk/orqube-latest.apk').toString();
    openExternalUrl(apkUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: DefaultTextStyle.merge(
        // Keep the existing design intact while allowing Flutter/Web to
        // fall back to system fonts that contain Korean glyphs.
        style: const TextStyle(
          fontFamilyFallback: <String>[
            'Noto Sans KR',
            'Noto Sans CJK KR',
            'Malgun Gothic',
            'Apple SD Gothic Neo',
            'sans-serif',
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder:
                      (_, __) => CustomPaint(
                        painter: _AnimatedSpacePainter(
                          progress: _backgroundController.value,
                        ),
                      ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.55, -0.40),
                      radius: 1.15,
                      colors: [
                        _purple.withOpacity(.16),
                        Colors.transparent,
                        Colors.black.withOpacity(.28),
                      ],
                      stops: const [0, .48, 1],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 12,
                radius: const Radius.circular(12),
                interactive: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      _hero(),
                      _itemEventBanner(),
                      _guestAccessPanel(),
                      _platformGuide(),
                      _adsenseReviewContent(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: OrqubeAdSenseAd(placement: 'home'),
                      ),
                      _airsoftMapGuide(),
                      _finalCta(),
                      // IMPORTANT: Keep the public content hub between the final CTA
                      // and the legacy footer. This is the visible MEDIA/SNS/CAFE/ORBS area.
                      _orqubePublicContentHub(),
                      _footer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    final size = MediaQuery.sizeOf(context);
    final mobile = size.width < 600;
    final compact =
        size.width <
        1280; // Prevent top navigation overflow on narrower desktop/tablet widths and longer translations.
    final heroHeight = math.max(size.height - 12, mobile ? 620.0 : 760.0);

    return SizedBox(
      width: double.infinity,
      height: heroHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 16 : (compact ? 22 : 62),
          vertical: 14,
        ),
        child: Column(
          children: [
            _topBar(compact),
            const SizedBox(height: 16),
            Expanded(
              child: Align(
                alignment: compact ? Alignment.center : Alignment.centerLeft,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _heroController,
                    curve: const Interval(0, .78, curve: Curves.easeOut),
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, .10),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _heroController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:
                            compact
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                        children: [
                          _eyebrow('ORQUBE GLOBAL REWARD ECOSYSTEM'),
                          SizedBox(height: mobile ? 14 : 24),
                          Text(
                            'AI × Web3 × Airsoft',
                            textAlign:
                                compact ? TextAlign.center : TextAlign.left,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.sizeOf(context).width < 380
                                      ? 25
                                      : (MediaQuery.sizeOf(context).width < 600
                                          ? 29
                                          : (compact ? 49 : 78)),
                              height: .98,
                              letterSpacing: -2.6,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: mobile ? 12 : 18),
                          ShaderMask(
                            shaderCallback:
                                (rect) => const LinearGradient(
                                  colors: [_cyan, _lime, _violet],
                                ).createShader(rect),
                            child: Text(
                              _t(
                                ko: '하나로 연결되는 글로벌 리워드 생태계',
                                en: 'One connected global reward ecosystem',
                                ja: 'ひとつにつながるグローバル報酬エコシステム',
                                zh: '连接为一体的全球奖励生态系统',
                                fr:
                                    'Un écosystème mondial de récompenses connecté',
                                pt:
                                    'Um ecossistema global de recompensas conectado',
                              ),
                              textAlign:
                                  compact ? TextAlign.center : TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.sizeOf(context).width < 380
                                        ? 16
                                        : (MediaQuery.sizeOf(context).width <
                                                600
                                            ? 18
                                            : (compact ? 28 : 43)),
                                height: 1.13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          SizedBox(height: mobile ? 16 : 27),
                          Text(
                            _t(
                              ko:
                                  'ORQUBE는 커뮤니티 활동, 광고 참여, 디지털 자산과\n글로벌 Airsoft 생태계를 하나의 경험으로 연결합니다.',
                              en:
                                  'ORQUBE connects community activity, advertising rewards,\ndigital assets and the global Airsoft ecosystem.',
                              ja:
                                  'ORQUBEはコミュニティ活動、広告参加、デジタル資産、\n世界のAirsoftエコシステムをひとつの体験につなげます。',
                              zh:
                                  'ORQUBE将社区活动、广告参与、数字资产与\n全球Airsoft生态系统连接为一种统一体验。',
                              fr:
                                  'ORQUBE relie les activités communautaires, la publicité, les actifs numériques\net l’écosystème Airsoft mondial dans une expérience unique.',
                              pt:
                                  'A ORQUBE conecta atividades da comunidade, participação em anúncios, ativos digitais\ne o ecossistema global de Airsoft em uma experiência única.',
                            ).replaceAll('\n', mobile ? ' ' : '\n'),
                            textAlign:
                                compact ? TextAlign.center : TextAlign.left,
                            style: TextStyle(
                              color: Colors.white.withOpacity(.70),
                              fontSize:
                                  MediaQuery.sizeOf(context).width < 600
                                      ? 13.5
                                      : (compact ? 18 : 21),
                              height:
                                  MediaQuery.sizeOf(context).width < 600
                                      ? 1.42
                                      : 1.7,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: mobile ? 22 : 34),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment:
                                compact
                                    ? WrapAlignment.center
                                    : WrapAlignment.start,
                            children: [
                              _primaryButton(
                                _t(
                                  ko: '채굴 시작하기',
                                  en: 'START MINING',
                                  ja: 'マイニング開始',
                                  zh: '开始挖矿',
                                  fr: 'COMMENCER LE MINAGE',
                                  pt: 'INICIAR MINERAÇÃO',
                                ),
                                Icons.rocket_launch_rounded,
                                _openDashboard,
                              ),
                              _outlineButton(
                                _t(
                                  ko: '보상 안내',
                                  en: 'REWARD GUIDE',
                                  ja: '報酬ガイド',
                                  zh: '奖励说明',
                                  fr: 'GUIDE DES RÉCOMPENSES',
                                  pt: 'GUIA DE RECOMPENSAS',
                                ),
                                Icons.card_giftcard_rounded,
                                _openRewardGuide,
                              ),
                              _outlineButton(
                                _t(
                                  ko: 'FAQ & 도움말',
                                  en: 'FAQ & HELP',
                                  ja: 'FAQ・ヘルプ',
                                  zh: '常见问题与帮助',
                                  fr: 'FAQ ET AIDE',
                                  pt: 'FAQ E AJUDA',
                                ),
                                Icons.help_outline_rounded,
                                _openHelpCenter,
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
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                final offset = 5 * _pulseController.value;
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: InkWell(
                    onTap: () => _scrollTo(_whyKey),
                    borderRadius: BorderRadius.circular(32),
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: Column(
                        children: [
                          Text(
                            _t(
                              ko: '아래로 스크롤',
                              en: 'SCROLL TO EXPLORE',
                              ja: 'スクロールして見る',
                              zh: '向下滚动探索',
                              fr: 'FAIRE DÉFILER',
                              pt: 'ROLE PARA EXPLORAR',
                            ),
                            style: TextStyle(
                              color: Colors.white.withOpacity(.54),
                              letterSpacing: 2.1,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _lime,
                            size: 31,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemEventBanner() {
    final compact = MediaQuery.sizeOf(context).width < 900;

    final explanation = Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        _eyebrow('ORQUBE ITEM COLLECTION EVENT'),
        const SizedBox(height: 14),
        Text(
          _t(
            ko: '채굴하고, 아이템을 모으고,\n같은 아이템 보유자를 찾아보세요.',
            en: 'Mine, collect items,\nand find users holding the same item.',
            ja: 'マイニングしてアイテムを集め、\n同じアイテムの保有者を探しましょう。',
            zh: '参与挖矿并收集道具，\n寻找持有相同道具的用户。',
            fr:
                'Minez, collectionnez des objets\net trouvez les détenteurs du même objet.',
            pt: 'Minere, colecione itens\ne encontre usuários com o mesmo item.',
          ),
          textAlign: compact ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: _mobileTitleSize(26, ratio: .68),
            height: 1.15,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _t(
            ko:
                '로그인 후 하루 한 번 HELMET, SCOPE, RADIO, DOG TAG, DRONE 중 1~3개를 랜덤으로 받습니다. 같은 아이템 사용자 3명이 수집소를 완성하면 참여자마다 채굴률이 ×0.15 상승합니다.',
            en:
                'After login, receive 1–3 random items once per day from HELMET, SCOPE, RADIO, DOG TAG and DRONE. When three users holding the same item complete a collection, each participant receives a +0.15 mining-rate boost.',
            ja:
                'ログイン後、1日1回、5種類のアイテムから1〜3個をランダムで獲得します。同じアイテムを持つ3人が収集所を完成すると、各参加者の採掘率が×0.15上昇します。',
            zh: '登录后每天可随机领取1至3个道具。三名持有相同道具的用户完成收集后，每位参与者的挖矿倍率提高×0.15。',
            fr:
                'Après connexion, recevez chaque jour 1 à 3 objets aléatoires. Lorsque trois détenteurs du même objet terminent une collection, chacun obtient un bonus de minage de ×0,15.',
            pt:
                'Após entrar, receba diariamente de 1 a 3 itens aleatórios. Quando três usuários com o mesmo item concluírem uma coleção, cada participante recebe +0,15 na taxa de mineração.',
          ),
          textAlign: compact ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: Colors.white.withOpacity(.72),
            fontSize: compact ? 16 : 18,
            height: 1.65,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 11,
          runSpacing: 11,
          alignment: compact ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _primaryButton(
              _t(
                ko: '채굴·아이템 이벤트 참여',
                en: 'JOIN MINING & ITEM EVENT',
                ja: '採掘・アイテムイベント参加',
                zh: '参加挖矿与道具活动',
                fr: 'PARTICIPER À L’ÉVÉNEMENT',
                pt: 'PARTICIPAR DO EVENTO',
              ),
              Icons.inventory_2_rounded,
              _openDashboard,
            ),
            _outlineButton(
              _t(
                ko: '텔레그램에서 동료 찾기',
                en: 'FIND PARTNERS ON TELEGRAM',
                ja: 'Telegramで仲間を探す',
                zh: '在 Telegram 寻找伙伴',
                fr: 'TROUVER DES PARTENAIRES',
                pt: 'ENCONTRAR PARCEIROS',
              ),
              Icons.send_rounded,
              _openTelegram,
            ),
          ],
        ),
      ],
    );

    final rewardPanel = Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _lime.withOpacity(.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EVENT REWARD FLOW',
            style: TextStyle(
              color: _lime,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          _eventStep(
            Icons.auto_graph_rounded,
            '1',
            _t(
              ko: '채굴 및 로그인',
              en: 'Mine and sign in',
              ja: '採掘・ログイン',
              zh: '挖矿并登录',
              fr: 'Miner et se connecter',
              pt: 'Minerar e entrar',
            ),
          ),
          _eventStep(
            Icons.casino_rounded,
            '2',
            _t(
              ko: '오늘의 랜덤 아이템 받기',
              en: 'Claim today’s random items',
              ja: '本日のランダムアイテム獲得',
              zh: '领取今日随机道具',
              fr: 'Recevoir les objets du jour',
              pt: 'Receber itens do dia',
            ),
          ),
          _eventStep(
            Icons.groups_rounded,
            '3',
            _t(
              ko: '같은 아이템 사용자 3명 모으기',
              en: 'Form a group of three matching holders',
              ja: '同じアイテムの3人を集める',
              zh: '集齐三名相同道具持有者',
              fr: 'Former un groupe de trois détenteurs',
              pt: 'Reunir três portadores iguais',
            ),
          ),
          _eventStep(
            Icons.bolt_rounded,
            '4',
            _t(
              ko: '채굴률 ×0.15 보상',
              en: '+0.15 mining-rate reward',
              ja: '採掘率×0.15報酬',
              zh: '挖矿倍率×0.15奖励',
              fr: 'Bonus de minage ×0,15',
              pt: 'Recompensa de mineração ×0,15',
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 18 : 62, 8, compact ? 18 : 62, 34),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 24 : 34),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_purple.withOpacity(.24), _panel, _cyan.withOpacity(.10)],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _violet.withOpacity(.34)),
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(.12),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child:
            compact
                ? Column(
                  children: [
                    explanation,
                    const SizedBox(height: 24),
                    rewardPanel,
                  ],
                )
                : Row(
                  children: [
                    Expanded(flex: 6, child: explanation),
                    const SizedBox(width: 32),
                    Expanded(flex: 4, child: rewardPanel),
                  ],
                ),
      ),
    );
  }

  Widget _eventStep(IconData icon, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _lime.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _lime.withOpacity(.28)),
            ),
            child: Icon(icon, size: 18, color: _lime),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '$number. $text',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topAccessButton(String label, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: _cyan.withOpacity(.42)),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _topBar(bool compact) {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo/orqube_plane_logo.png',
          width: 48,
          height: 48,
          errorBuilder:
              (_, __, ___) => const Icon(
                Icons.flight_rounded,
                color: Colors.white,
                size: 40,
              ),
        ),
        const SizedBox(width: 11),
        const Text(
          'ORQUBE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 24),
        if (!compact) ...[
          _topAccessButton(
            _t(
              ko: '에어소프트',
              en: 'AIRSOFT',
              ja: 'エアソフト',
              zh: 'Airsoft',
              fr: 'AIRSOFT',
              pt: 'AIRSOFT',
            ),
            Icons.sports_mma_rounded,
            _openProtectedAirsoftHub,
          ),
          const SizedBox(width: 8),
          _topAccessButton(
            _t(
              ko: '안심귀가',
              en: 'SAFE HOME',
              ja: '安心帰宅',
              zh: '安心回家',
              fr: 'RETOUR SÛR',
              pt: 'VOLTA SEGURA',
            ),
            Icons.shield_rounded,
            () => _openProtectedMap(OrqubeMapMode.safeHome),
          ),
          const SizedBox(width: 8),
          _topAccessButton(
            _t(
              ko: '안전산행',
              en: 'SAFE HIKING',
              ja: '安全登山',
              zh: '安全徒步',
              fr: 'RANDONNÉE SÛRE',
              pt: 'TRILHA SEGURA',
            ),
            Icons.terrain_rounded,
            () => _openProtectedMap(OrqubeMapMode.safeHiking),
          ),
        ],
        const Spacer(),
        if (!compact) ...[
          _nav(
            _t(
              ko: '이유',
              en: 'WHY',
              ja: '理由',
              zh: '原因',
              fr: 'POURQUOI',
              pt: 'POR QUÊ',
            ),
            () => _scrollTo(_whyKey),
          ),
          _nav(
            _t(
              ko: '이용 방법',
              en: 'HOW',
              ja: '仕組み',
              zh: '方式',
              fr: 'COMMENT',
              pt: 'COMO',
            ),
            () => _scrollTo(_howKey),
          ),
          _nav(
            _t(
              ko: '생태계',
              en: 'ECOSYSTEM',
              ja: 'エコシステム',
              zh: '生态系统',
              fr: 'ÉCOSYSTÈME',
              pt: 'ECOSSISTEMA',
            ),
            () => _scrollTo(_ecosystemKey),
          ),
          _nav(
            _t(
              ko: '로드맵',
              en: 'ROADMAP',
              ja: 'ロードマップ',
              zh: '路线图',
              fr: 'FEUILLE DE ROUTE',
              pt: 'ROADMAP',
            ),
            () => _scrollTo(_roadmapKey),
          ),
        ],
        const SizedBox(width: 8),
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            if (user == null) {
              return TextButton.icon(
                onPressed: _openLogin,
                icon: const Icon(Icons.login_rounded, size: 18),
                label: Text(
                  _t(
                    ko: '로그인',
                    en: 'LOGIN',
                    ja: 'ログイン',
                    zh: '登录',
                    fr: 'CONNEXION',
                    pt: 'ENTRAR',
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: _lime),
              );
            }

            return PopupMenuButton<String>(
              tooltip: user.email ?? 'Account',
              color: const Color(0xFF101426),
              onSelected: (value) {
                switch (value) {
                  case 'wallet':
                    _openDashboard();
                    break;
                  case 'admin':
                    _openAdmin();
                    break;
                  case 'logout':
                    _logout();
                    break;
                }
              },
              itemBuilder:
                  (_) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Text(
                        user.email ?? 'ORQUBE USER',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'wallet',
                      child: ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: _cyan,
                        ),
                        title: Text(
                          _t(
                            ko: '지갑 설정',
                            en: 'Wallet Setup',
                            ja: 'ウォレット設定',
                            zh: '钱包设置',
                            fr: 'Configuration du portefeuille',
                            pt: 'Configurar carteira',
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'admin',
                      child: ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: _lime,
                        ),
                        title: Text(
                          _t(
                            ko: '관리자 설정',
                            en: 'Admin Settings',
                            ja: '管理者設定',
                            zh: '管理员设置',
                            fr: 'Paramètres administrateur',
                            pt: 'Configurações do administrador',
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          _t(
                            ko: '로그아웃',
                            en: 'Logout',
                            ja: 'ログアウト',
                            zh: '退出登录',
                            fr: 'Déconnexion',
                            pt: 'Sair',
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_circle_rounded,
                      color: _lime,
                      size: 22,
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 7),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          user.email ?? 'ORQUBE USER',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.language,
            dropdownColor: const Color(0xFF101426),
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
      ],
    );
  }

  Widget _guestAccessPanel() {
    final mobile = MediaQuery.sizeOf(context).width < 650;
    final user = FirebaseAuth.instance.currentUser;

    Widget menuTile({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      bool locked = false,
      bool wallet = false,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: BoxConstraints(minHeight: mobile ? 58 : 64),
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 10 : 13,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.045),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  wallet
                      ? _violet.withOpacity(.34)
                      : locked
                      ? _cyan.withOpacity(.24)
                      : _purple.withOpacity(.26),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    wallet
                        ? _violet
                        : locked
                        ? _cyan
                        : _lime,
                size: mobile ? 20 : 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: mobile ? 11.8 : 13.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (locked || wallet)
                Icon(
                  wallet ? Icons.lock_rounded : Icons.lock_outline_rounded,
                  color: Colors.white38,
                  size: 14,
                ),
            ],
          ),
        ),
      );
    }

    Widget section({
      required String title,
      required String subtitle,
      required List<Widget> children,
      required Color accent,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accent,
              fontSize: mobile ? 15 : 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white54,
              fontSize: mobile ? 10.8 : 12.5,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, c) {
              final columns = c.maxWidth >= 900 ? 4 : 2;
              const gap = 9.0;
              final w = (c.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final child in children)
                    SizedBox(width: w, child: child),
                ],
              );
            },
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 24, 4, mobile ? 12 : 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: _glass(
            padding: EdgeInsets.all(mobile ? 14 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t(
                              ko: 'ORQUBE 전체 메뉴',
                              en: 'ORQUBE MENU',
                              ja: 'ORQUBE メニュー',
                              zh: 'ORQUBE 菜单',
                              fr: 'MENU ORQUBE',
                              pt: 'MENU ORQUBE',
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: mobile ? 20 : 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _t(
                              ko: '필요한 기능을 바로 선택하세요.',
                              en: 'Choose what you need.',
                              ja: '必要な機能を選択してください。',
                              zh: '选择您需要的功能。',
                              fr: 'Choisissez une fonction.',
                              pt: 'Escolha uma função.',
                            ),
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: mobile ? 11.5 : 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: user == null ? _openLogin : _logout,
                      icon: Icon(
                        user == null
                            ? Icons.person_outline_rounded
                            : Icons.verified_user_rounded,
                        size: 18,
                      ),
                      label: Text(
                        user == null
                            ? _t(
                              ko: '둘러보는 중 · 로그인',
                              en: 'Guest · Sign in',
                              ja: 'ゲスト · ログイン',
                              zh: '访客 · 登录',
                              fr: 'Invité · Connexion',
                              pt: 'Visitante · Entrar',
                            )
                            : _t(
                              ko: '로그인됨 · 로그아웃',
                              en: 'Signed in · Sign out',
                              ja: 'ログイン中 · ログアウト',
                              zh: '已登录 · 退出',
                              fr: 'Connecté · Déconnexion',
                              pt: 'Conectado · Sair',
                            ),
                        style: TextStyle(
                          fontSize: mobile ? 10.8 : 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                section(
                  title: _t(
                    ko: '바로 사용',
                    en: 'OPEN ACCESS',
                    ja: 'すぐ利用',
                    zh: '直接使用',
                    fr: 'ACCÈS LIBRE',
                    pt: 'ACESSO LIVRE',
                  ),
                  subtitle: _t(
                    ko: '회원가입 없이 이용',
                    en: 'No sign-up required',
                    ja: '登録不要',
                    zh: '无需注册',
                    fr: 'Sans inscription',
                    pt: 'Sem cadastro',
                  ),
                  accent: _lime,
                  children: [
                    menuTile(
                      icon: Icons.sports_martial_arts_rounded,
                      label: 'AIRSOFT HUB',
                      onTap: () => _openProtectedAirsoftHub(),
                    ),
                    menuTile(
                      icon: Icons.map_rounded,
                      label: _t(
                        ko: '지도',
                        en: 'Map',
                        ja: '地図',
                        zh: '地图',
                        fr: 'Carte',
                        pt: 'Mapa',
                      ),
                      onTap: () => _openProtectedMap(OrqubeMapMode.airsoft),
                    ),
                    menuTile(
                      icon: Icons.my_location_rounded,
                      label: 'GPS',
                      onTap: () => _openProtectedMap(OrqubeMapMode.safeHome),
                    ),
                    menuTile(
                      icon: Icons.offline_pin_rounded,
                      label: _t(
                        ko: '안전산행',
                        en: 'Safe Hiking',
                        ja: '安全登山',
                        zh: '安全登山',
                        fr: 'Randonnée sûre',
                        pt: 'Caminhada segura',
                      ),
                      onTap: () => _openProtectedMap(OrqubeMapMode.safeHiking),
                    ),
                    menuTile(
                      icon: Icons.shield_outlined,
                      label: _t(
                        ko: '안심귀가',
                        en: 'Safe Return',
                        ja: '安心帰宅',
                        zh: '安心回家',
                        fr: 'Retour sûr',
                        pt: 'Retorno seguro',
                      ),
                      onTap: () => _openProtectedMap(OrqubeMapMode.safeHome),
                    ),
                    menuTile(
                      icon: Icons.menu_book_rounded,
                      label: _t(
                        ko: '사용설명서',
                        en: 'Guide',
                        ja: 'ガイド',
                        zh: '指南',
                        fr: 'Guide',
                        pt: 'Guia',
                      ),
                      onTap: _openHelpCenter,
                    ),
                    menuTile(
                      icon: Icons.file_download_rounded,
                      label: _t(
                        ko: 'Android 앱 다운로드',
                        en: 'Download Android app',
                        ja: 'Androidアプリをダウンロード',
                        zh: '下载 Android 应用',
                        fr: 'Télécharger l’app Android',
                        pt: 'Baixar app Android',
                      ),
                      onTap: _downloadAndroidApp,
                    ),
                    menuTile(
                      icon: Icons.forum_outlined,
                      label: _t(
                        ko: '공지·커뮤니티',
                        en: 'Community',
                        ja: 'コミュニティ',
                        zh: '社区',
                        fr: 'Communauté',
                        pt: 'Comunidade',
                      ),
                      onTap: _openCommunity,
                    ),
                    menuTile(
                      icon: Icons.bolt_rounded,
                      label: _t(
                        ko: '채굴 체험',
                        en: 'Mining preview',
                        ja: 'マイニング体験',
                        zh: '挖矿体验',
                        fr: 'Aperçu minage',
                        pt: 'Teste de mineração',
                      ),
                      onTap: _openDashboard,
                    ),
                    menuTile(
                      icon: Icons.auto_awesome_outlined,
                      label: _t(
                        ko: 'ORQUBE 소개',
                        en: 'About ORQUBE',
                        ja: 'ORQUBE紹介',
                        zh: 'ORQUBE介绍',
                        fr: 'À propos',
                        pt: 'Sobre ORQUBE',
                      ),
                      onTap: () => _scrollTo(_whyKey),
                    ),
                    menuTile(
                      icon: Icons.language_rounded,
                      label: _t(
                        ko: '다국어',
                        en: 'Language',
                        ja: '言語',
                        zh: '语言',
                        fr: 'Langue',
                        pt: 'Idioma',
                      ),
                      onTap: _showLanguageMenu,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                section(
                  title: _t(
                    ko: '로그인 후 이용',
                    en: 'SIGN IN TO PARTICIPATE',
                    ja: 'ログイン後に利用',
                    zh: '登录后使用',
                    fr: 'CONNEXION REQUISE',
                    pt: 'LOGIN NECESSÁRIO',
                  ),
                  subtitle: _t(
                    ko: '기록 · 연결 · 공유 · 보상',
                    en: 'Save · connect · share · rewards',
                    ja: '記録・接続・共有・報酬',
                    zh: '记录·连接·分享·奖励',
                    fr: 'Enregistrer · connecter · partager · récompenses',
                    pt: 'Salvar · conectar · compartilhar · recompensas',
                  ),
                  accent: _cyan,
                  children: [
                    menuTile(
                      icon: Icons.sports_score_rounded,
                      label: _t(
                        ko: '경기 등록·참가',
                        en: 'Match join',
                        ja: '試合登録・参加',
                        zh: '比赛注册·参加',
                        fr: 'Match',
                        pt: 'Partida',
                      ),
                      locked: true,
                      onTap:
                          () =>
                              _requireLoginThen((_) => const AirsoftHubPage()),
                    ),
                    menuTile(
                      icon: Icons.edit_note_rounded,
                      label: _t(
                        ko: '글·댓글 작성',
                        en: 'Post · comment',
                        ja: '投稿・コメント',
                        zh: '发帖·评论',
                        fr: 'Publier · commenter',
                        pt: 'Postar · comentar',
                      ),
                      locked: true,
                      onTap:
                          () => _requireLoginThen(
                            (_) => const CommunityHubPage(),
                          ),
                    ),
                    menuTile(
                      icon: Icons.person_add_alt_1_rounded,
                      label: _t(
                        ko: '친구초대',
                        en: 'Invite friends',
                        ja: '友達招待',
                        zh: '邀请好友',
                        fr: 'Inviter',
                        pt: 'Convidar',
                      ),
                      locked: true,
                      onTap:
                          () =>
                              _requireLoginThen((_) => const OrqubeV14Entry()),
                    ),
                    menuTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: _t(
                        ko: '채팅',
                        en: 'Chat',
                        ja: 'チャット',
                        zh: '聊天',
                        fr: 'Chat',
                        pt: 'Chat',
                      ),
                      locked: true,
                      onTap:
                          () =>
                              _requireLoginThen((_) => const AirsoftHubPage()),
                    ),
                    menuTile(
                      icon: Icons.share_location_rounded,
                      label: _t(
                        ko: '보호자 위치 공유',
                        en: 'Guardian sharing',
                        ja: '保護者位置共有',
                        zh: '监护人位置共享',
                        fr: 'Partage gardien',
                        pt: 'Compartilhar localização',
                      ),
                      locked: true,
                      onTap:
                          () => _requireLoginThen(
                            (_) => AirsoftMapPage(
                              initialMode: OrqubeMapMode.safeHiking,
                            ),
                          ),
                    ),
                    menuTile(
                      icon: Icons.sos_rounded,
                      label: 'SOS',
                      locked: true,
                      onTap:
                          () => _requireLoginThen(
                            (_) => AirsoftMapPage(
                              initialMode: OrqubeMapMode.safeHiking,
                            ),
                          ),
                    ),
                    menuTile(
                      icon: Icons.save_alt_rounded,
                      label: _t(
                        ko: '채굴 보상 저장',
                        en: 'Save mining reward',
                        ja: '採掘報酬保存',
                        zh: '保存挖矿奖励',
                        fr: 'Sauver récompense',
                        pt: 'Salvar recompensa',
                      ),
                      locked: true,
                      onTap:
                          () =>
                              _requireLoginThen((_) => const OrqubeV14Entry()),
                    ),
                    menuTile(
                      icon: Icons.stars_rounded,
                      label: _t(
                        ko: '포인트·ORBS 적립',
                        en: 'Points · ORBS',
                        ja: 'ポイント・ORBS',
                        zh: '积分·ORBS',
                        fr: 'Points · ORBS',
                        pt: 'Pontos · ORBS',
                      ),
                      locked: true,
                      onTap:
                          () =>
                              _requireLoginThen((_) => const OrqubeV14Entry()),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                section(
                  title: _t(
                    ko: '지갑·자산',
                    en: 'WALLET · ASSETS',
                    ja: 'ウォレット・資産',
                    zh: '钱包·资产',
                    fr: 'PORTEFEUILLE · ACTIFS',
                    pt: 'CARTEIRA · ATIVOS',
                  ),
                  subtitle: _t(
                    ko: '정식 회원·지갑 인증 영역',
                    en: 'Member and wallet verification',
                    ja: '会員・ウォレット認証',
                    zh: '会员与钱包认证',
                    fr: 'Vérification membre et portefeuille',
                    pt: 'Verificação de membro e carteira',
                  ),
                  accent: _violet,
                  children: [
                    menuTile(
                      icon: Icons.lock_clock_rounded,
                      label: _t(
                        ko: '스테이킹',
                        en: 'Staking',
                        ja: 'ステーキング',
                        zh: '质押',
                        fr: 'Staking',
                        pt: 'Staking',
                      ),
                      wallet: true,
                      onTap:
                          () =>
                              _requireLoginThen((_) => const OrqubeV14Entry()),
                    ),
                    menuTile(
                      icon: Icons.swap_horiz_rounded,
                      label: _t(
                        ko: 'ORBS 전송·출금',
                        en: 'ORBS transfer',
                        ja: 'ORBS送金・出金',
                        zh: 'ORBS转账·提现',
                        fr: 'Transfert ORBS',
                        pt: 'Transferir ORBS',
                      ),
                      wallet: true,
                      onTap:
                          () =>
                              _requireLoginThen((_) => const OrqubeV14Entry()),
                    ),
                    menuTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: _t(
                        ko: '지갑 연결',
                        en: 'Connect wallet',
                        ja: 'ウォレット接続',
                        zh: '连接钱包',
                        fr: 'Connecter portefeuille',
                        pt: 'Conectar carteira',
                      ),
                      wallet: true,
                      onTap:
                          () =>
                              _requireLoginThen((_) => const OrqubeV14Entry()),
                    ),
                    menuTile(
                      icon: Icons.redeem_rounded,
                      label: _t(
                        ko: '추천 보상 확정',
                        en: 'Referral reward',
                        ja: '紹介報酬確定',
                        zh: '推荐奖励确认',
                        fr: 'Récompense parrainage',
                        pt: 'Recompensa de indicação',
                      ),
                      wallet: true,
                      onTap:
                          () =>
                              _requireLoginThen((_) => const OrqubeV14Entry()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _platformGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 52),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            decoration: BoxDecoration(
              color: const Color(0xE6101426),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _violet.withOpacity(.42)),
              boxShadow: [
                BoxShadow(
                  color: _purple.withOpacity(.12),
                  blurRadius: 28,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final icon = Container(
                  width: compact ? 64 : 78,
                  height: compact ? 64 : 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _purple.withOpacity(.18),
                    border: Border.all(color: _lime.withOpacity(.65)),
                  ),
                  child: Icon(
                    Icons.hub_rounded,
                    color: _lime,
                    size: compact ? 31 : 38,
                  ),
                );
                final copy = Column(
                  crossAxisAlignment:
                      compact
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t(
                        ko: 'ORQUBE 플랫폼 안내',
                        en: 'ABOUT THE ORQUBE PLATFORM',
                        ja: 'ORQUBEプラットフォーム案内',
                        zh: 'ORQUBE 平台介绍',
                        fr: 'PRÉSENTATION DE LA PLATEFORME ORQUBE',
                        pt: 'SOBRE A PLATAFORMA ORQUBE',
                      ),
                      textAlign: compact ? TextAlign.center : TextAlign.left,
                      style: const TextStyle(
                        color: _lime,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _t(
                        ko:
                            'ORQUBE는 에어소프트 허브를 오프라인과 온라인으로 연결하는 참여형 플랫폼입니다. 앞으로 간편하게 즐길 수 있는 에어소프트 게임을 선보이고, 팀별·국가별 경쟁과 교류를 지원하며, 추후 온라인 장비 판매 기능까지 확장할 예정입니다. 사용자는 일일 채굴에 꾸준히 참여하고, 군번줄 및 해시태그 이벤트를 통해 채굴률과 보상을 높일 수 있습니다.',
                        en:
                            'ORQUBE is a participation platform connecting the Airsoft Hub across offline and online experiences. It will introduce simple airsoft games, support team and country-based competition and community activity, and later expand into online equipment sales. Users can focus on daily mining and improve mining rates and rewards through dog-tag and hashtag events.',
                        ja:
                            'ORQUBEは、エアソフトハブをオフラインとオンラインでつなぐ参加型プラットフォームです。今後は気軽に楽しめるエアソフトゲーム、チーム別・国別の競争と交流、さらにオンライン装備販売へと拡張する予定です。ユーザーは毎日のマイニングに参加し、ドッグタグやハッシュタグイベントを通じて採掘率と報酬を高められます。',
                        zh:
                            'ORQUBE 是连接线下与线上 Airsoft Hub 的参与型平台。未来将推出简单易玩的气枪竞技游戏，支持团队和国家之间的竞赛与交流，并逐步扩展到线上装备销售。用户可持续参与每日挖矿，并通过身份牌和主题标签活动提高挖矿效率与奖励。',
                        fr:
                            'ORQUBE relie l’Airsoft Hub hors ligne et en ligne. La plateforme proposera des jeux d’airsoft simples, des compétitions et échanges par équipe et par pays, puis la vente d’équipements en ligne. Les utilisateurs peuvent se concentrer sur le minage quotidien et améliorer leur taux de minage et leurs récompenses grâce aux événements dog tag et hashtag.',
                        pt:
                            'A ORQUBE conecta o Airsoft Hub em experiências offline e online. A plataforma lançará jogos simples de airsoft, competições e interação por equipes e países e, futuramente, vendas online de equipamentos. Os usuários podem se dedicar à mineração diária e aumentar a taxa e as recompensas com eventos de dog tag e hashtag.',
                      ),
                      textAlign: compact ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.78),
                        fontSize: compact ? 15 : 17,
                        height: 1.72,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
                if (compact) {
                  return Column(
                    children: [icon, const SizedBox(height: 20), copy],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 26),
                    Expanded(child: copy),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickStartGuide() {
    final steps = <({IconData icon, String title, String body})>[
      (
        icon: Icons.login_rounded,
        title: _t(
          ko: '1. 먼저 둘러보기',
          en: '1. Explore first',
          ja: '1. まず閲覧',
          zh: '1. 先浏览',
          fr: '1. Explorer d’abord',
          pt: '1. Explore primeiro',
        ),
        body: _t(
          ko: '회원가입 없이 지도·가이드·커뮤니티와 주요 화면을 먼저 둘러봅니다.',
          en: 'Browse maps, guides, community and key screens before signing up.',
          ja: '無料登録後、ORQUBEにログインします。',
          zh: '免费注册后登录 ORQUBE。',
          fr: 'Créez un compte gratuit puis connectez-vous à ORQUBE.',
          pt: 'Crie uma conta gratuita e entre na ORQUBE.',
        ),
      ),
      (
        icon: Icons.account_balance_wallet_rounded,
        title: _t(
          ko: '2. 지갑 설정',
          en: '2. Set up wallet',
          ja: '2. ウォレット設定',
          zh: '2. 设置钱包',
          fr: '2. Configurer le portefeuille',
          pt: '2. Configurar carteira',
        ),
        body: _t(
          ko: '지갑을 생성하거나 연결해 보상과 자산을 관리합니다.',
          en: 'Create or connect a wallet to manage rewards and assets.',
          ja: 'ウォレットを作成・接続して報酬と資産を管理します。',
          zh: '创建或连接钱包以管理奖励和资产。',
          fr:
              'Créez ou connectez un portefeuille pour gérer récompenses et actifs.',
          pt: 'Crie ou conecte uma carteira para gerenciar recompensas e ativos.',
        ),
      ),
      (
        icon: Icons.event_available_rounded,
        title: _t(
          ko: '3. 출석체크',
          en: '3. Daily check-in',
          ja: '3. デイリーチェックイン',
          zh: '3. 每日签到',
          fr: '3. Présence quotidienne',
          pt: '3. Check-in diário',
        ),
        body: _t(
          ko: '매일 출석해 포인트와 ORBS 보상을 획득합니다.',
          en: 'Check in every day to earn points and ORBS rewards.',
          ja: '毎日チェックインしてポイントとORBS報酬を獲得します。',
          zh: '每日签到以获得积分和 ORBS 奖励。',
          fr: 'Connectez-vous chaque jour pour gagner des points et des ORBS.',
          pt: 'Faça check-in todos os dias para ganhar pontos e ORBS.',
        ),
      ),
      (
        icon: Icons.bolt_rounded,
        title: _t(
          ko: '4. 광고 시청 후 채굴',
          en: '4. Watch ad & mine',
          ja: '4. 広告視聴後にマイニング',
          zh: '4. 观看广告后挖矿',
          fr: '4. Regarder une pub et miner',
          pt: '4. Assistir anúncio e minerar',
        ),
        body: _t(
          ko: '광고를 끝까지 시청한 뒤 일일 채굴을 시작합니다.',
          en: 'Watch the rewarded ad to the end, then start daily mining.',
          ja: 'リワード広告を最後まで視聴してデイリーマイニングを開始します。',
          zh: '完整观看奖励广告后开始每日挖矿。',
          fr:
              'Regardez la publicité récompensée jusqu’au bout puis lancez le minage.',
          pt:
              'Assista ao anúncio recompensado até o fim e inicie a mineração diária.',
        ),
      ),
      (
        icon: Icons.sports_martial_arts_rounded,
        title: _t(
          ko: '5. Airsoft Hub 이용',
          en: '5. Use Airsoft Hub',
          ja: '5. Airsoft Hubを利用',
          zh: '5. 使用 Airsoft Hub',
          fr: '5. Utiliser Airsoft Hub',
          pt: '5. Usar o Airsoft Hub',
        ),
        body: _t(
          ko: '경기·팀·업체 정보를 확인하고 참가 또는 등록합니다.',
          en: 'Browse matches, teams and businesses, then join or register.',
          ja: '試合・チーム・事業者情報を確認し、参加または登録します。',
          zh: '查看比赛、战队和商家信息，并参加或注册。',
          fr:
              'Consultez matchs, équipes et entreprises, puis participez ou inscrivez-vous.',
          pt: 'Veja partidas, equipes e empresas e participe ou cadastre-se.',
        ),
      ),
      (
        icon: Icons.map_rounded,
        title: _t(
          ko: '6. 경기 지도와 안전 기능',
          en: '6. Match map & safety',
          ja: '6. 試合マップ・安全機能',
          zh: '6. 比赛地图与安全功能',
          fr: '6. Carte des matchs et sécurité',
          pt: '6. Mapa de partidas e segurança',
        ),
        body: _t(
          ko: '내 위치·경기장·길찾기를 확인하고 필요할 때 위치 공유 또는 SOS를 사용합니다.',
          en:
              'Use current location, field markers and directions, plus sharing or SOS when needed.',
          ja: '現在地・フィールド・経路を確認し、必要時に位置共有やSOSを利用します。',
          zh: '查看当前位置、场地和导航，并在需要时使用位置共享或 SOS。',
          fr:
              'Consultez position, terrains et itinéraires, puis utilisez partage ou SOS si nécessaire.',
          pt:
              'Consulte localização, campos e rotas e use compartilhamento ou SOS quando necessário.',
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xD90C1020),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _lime.withOpacity(.30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(
                    ko: 'ORQUBE 처음 이용하시나요?',
                    en: 'NEW TO ORQUBE?',
                    ja: 'ORQUBEを初めて利用しますか？',
                    zh: '第一次使用 ORQUBE？',
                    fr: 'VOUS DÉCOUVREZ ORQUBE ?',
                    pt: 'NOVO NA ORQUBE?',
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _mobileTitleSize(28, ratio: .88),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _t(
                    ko: '먼저 자유롭게 둘러보고, 기록·공유·보상 기능이 필요할 때 로그인하면 됩니다.',
                    en:
                        'Explore first, then sign in only when you need save, sharing or reward features.',
                    ja: '次の順番で進めると、マイニングとAirsoft Hubを簡単に利用できます。',
                    zh: '按照以下步骤即可轻松开始挖矿并使用 Airsoft Hub。',
                    fr:
                        'Suivez ces étapes pour commencer le minage et utiliser Airsoft Hub.',
                    pt:
                        'Siga estas etapas para começar a minerar e usar o Airsoft Hub.',
                  ),
                  style: TextStyle(
                    color: Colors.white.withOpacity(.68),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns =
                        constraints.maxWidth >= 960
                            ? 3
                            : constraints.maxWidth >= 620
                            ? 2
                            : 1;
                    final spacing = 14.0;
                    final cardWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final step in steps)
                          SizedBox(
                            width: cardWidth,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 150),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xB30B0F1D),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _violet.withOpacity(.23),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(step.icon, color: _lime, size: 27),
                                  const SizedBox(height: 12),
                                  Text(
                                    step.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    step.body,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(.66),
                                      height: 1.55,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // AdSense 재심사: 로그인 없이 읽을 수 있는 ORQUBE 고유 게시자 콘텐츠.
  Widget _adsenseReviewContent() {
    final mobile = MediaQuery.sizeOf(context).width < 700;

    Widget card(IconData icon, String title, String body) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xD9101426),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _lime, size: 24),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withOpacity(.76),
              fontSize: 13.2,
              height: 1.45,
            ),
          ),
        ],
      ),
    );

    final items = <Widget>[
      card(
        Icons.shield_outlined,
        _t(
          ko: '안심귀가 · 현재 위치 확인',
          en: 'Safe Return & Current Location',
          ja: '安心帰宅・現在地確認',
          zh: '安心回家与当前位置',
          fr: 'Retour sûr et position actuelle',
          pt: 'Retorno seguro e localização atual',
        ),
        _t(
          ko:
              '방문자는 회원가입 없이 지도와 GPS 현재 위치 확인 기능을 둘러볼 수 있습니다. 실제 위치 공유처럼 기록이나 다른 사람과의 연결이 필요한 기능은 필요한 시점에 인증하도록 설계하여 처음 방문한 사용자도 서비스의 목적을 먼저 이해할 수 있도록 합니다.',
          en:
              'Visitors can explore the map and check their current GPS position without creating an account. Features that create records or connect with another person request authentication only when needed.',
          ja:
              '訪問者は会員登録なしで地図とGPSによる現在地確認を試せます。位置共有など記録や他者との接続が必要な機能では必要な時点で認証します。',
          zh: '访客无需注册即可查看地图并确认GPS当前位置。需要记录或与他人连接的功能仅在实际需要时要求认证。',
          fr:
              'Les visiteurs peuvent consulter la carte et leur position GPS sans créer de compte. Les fonctions de partage demandent une authentification uniquement lorsque cela devient nécessaire.',
          pt:
              'Os visitantes podem explorar o mapa e verificar a posição GPS sem criar uma conta. Recursos de compartilhamento pedem autenticação somente quando necessário.',
        ),
      ),
      card(
        Icons.hiking_rounded,
        _t(
          ko: '안전산행 · 오프라인 보호',
          en: 'Safe Hiking & Offline Protection',
          ja: '安全登山・オフライン保護',
          zh: '安全登山与离线保护',
          fr: 'Randonnée sûre et protection hors ligne',
          pt: 'Caminhada segura e proteção offline',
        ),
        _t(
          ko:
              '산행 전에 필요한 지도를 기기에 저장하면 이동통신이 일시적으로 끊긴 환경에서도 기기 GPS를 이용해 현재 위치, 출발점과 이동 경로를 확인할 수 있도록 개발하고 있습니다. 통신이 복구되면 보호자 공유와 미전송 기록의 동기화를 이어가는 것이 핵심 방향입니다.',
          en:
              'Safe Hiking is being developed so a map can be stored before departure and device GPS can continue showing the current position, starting point and movement route when mobile data is temporarily unavailable. Sharing and pending-record synchronization can resume after reconnection.',
          ja:
              '出発前に地図を端末へ保存し、通信が途切れても端末GPSで現在地、出発点、移動経路を確認できることを目指します。通信復旧後は共有と同期を再開します。',
          zh: '出发前可将地图保存到设备，在网络暂时中断时仍利用GPS确认当前位置、出发点和移动路线。网络恢复后继续共享与同步。',
          fr:
              'La carte peut être enregistrée avant le départ afin que le GPS continue d’indiquer la position, le point de départ et le trajet lors d’une coupure temporaire. Le partage reprend après reconnexion.',
          pt:
              'O mapa pode ser salvo antes da saída para que o GPS continue mostrando a posição, o ponto de partida e a rota durante uma interrupção temporária. O compartilhamento retoma após a reconexão.',
        ),
      ),
      card(
        Icons.sports_martial_arts_rounded,
        'AIRSOFT HUB',
        _t(
          ko:
              'AIRSOFT HUB는 경기, 팀, 필드와 커뮤니티 정보를 한곳에서 연결하기 위한 공간입니다. 공개 정보를 먼저 둘러보고 경기 등록·참가 신청·채팅처럼 실제 참여가 필요한 기능에서 인증하도록 구성해 글로벌 커뮤니티의 진입 장벽을 낮추는 것을 목표로 합니다.',
          en:
              'AIRSOFT HUB connects match, team, field and community information. Users can browse public information first and authenticate when taking actions such as registering a match, requesting participation or using chat.',
          ja:
              'AIRSOFT HUBはゲーム、チーム、フィールド、コミュニティ情報を一か所でつなぎます。公開情報を先に閲覧し、実際の参加時に認証します。',
          zh: 'AIRSOFT HUB用于连接比赛、团队、场地和社区信息。用户可先浏览公开信息，在实际参与时再认证。',
          fr:
              'AIRSOFT HUB réunit les informations sur les parties, équipes, terrains et communautés. Le contenu public est consultable avant authentification.',
          pt:
              'O AIRSOFT HUB reúne informações de partidas, equipes, campos e comunidade. O conteúdo público pode ser explorado antes da autenticação.',
        ),
      ),
      card(
        Icons.auto_awesome_rounded,
        _t(
          ko: 'AI 기반 안전 서비스 방향',
          en: 'AI-Assisted Safety Direction',
          ja: 'AI安全支援の方向性',
          zh: 'AI辅助安全服务方向',
          fr: 'Sécurité assistée par IA',
          pt: 'Segurança assistida por IA',
        ),
        _t(
          ko:
              'ORQUBE는 위치 기반 안전정보에 AI 위험분석을 단계적으로 결합하는 것을 목표로 합니다. 향후 경로 이탈, 장시간 정지, 귀환 예정시간 초과와 같은 여러 신호를 함께 분석해 필요한 확인이나 경고를 지원하며 AI는 공식 구조기관의 판단을 대체하지 않고 사용자의 안전 판단을 보조합니다.',
          en:
              'ORQUBE aims to progressively combine location-based safety information with AI-assisted risk analysis. Future development can evaluate route deviation, prolonged inactivity and overdue return signals together to support checks or warnings. AI assists safety decisions rather than replacing emergency authorities.',
          ja:
              'ORQUBEは位置情報とAIリスク分析を段階的に組み合わせ、経路逸脱、長時間停止、帰還予定超過などを分析して確認や警告を支援することを目指します。',
          zh: 'ORQUBE计划逐步把位置安全信息与AI风险分析结合，综合分析路线偏离、长时间静止和超过预计返回时间等信号。',
          fr:
              'ORQUBE vise à associer progressivement les informations géolocalisées à une analyse de risque assistée par IA afin d’aider aux vérifications et alertes.',
          pt:
              'A ORQUBE pretende combinar progressivamente informações de localização com análise de risco assistida por IA para apoiar verificações e alertas.',
        ),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(mobile ? 16 : 24, 12, mobile ? 16 : 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t(
                  ko: 'ORQUBE 서비스와 안전 기술',
                  en: 'ORQUBE SERVICES & SAFETY TECHNOLOGY',
                  ja: 'ORQUBEのサービスと安全技術',
                  zh: 'ORQUBE服务与安全技术',
                  fr: 'SERVICES ORQUBE ET TECHNOLOGIE DE SÉCURITÉ',
                  pt: 'SERVIÇOS ORQUBE E TECNOLOGIA DE SEGURANÇA',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _t(
                  ko:
                      'ORQUBE가 제공하는 주요 기능과 개발 방향을 로그인 없이 읽어보세요. 각 서비스가 해결하려는 문제와 사용 방식을 설명합니다.',
                  en:
                      'Read about ORQUBE’s core functions and development direction without signing in. Each section explains the problem the service addresses and how it is intended to be used.',
                  ja: 'ログインせずにORQUBEの主要機能と開発方針を確認できます。',
                  zh: '无需登录即可了解ORQUBE的主要功能与开发方向。',
                  fr:
                      'Découvrez sans connexion les principales fonctions d’ORQUBE et leur orientation.',
                  pt:
                      'Conheça sem login as principais funções da ORQUBE e sua direção de desenvolvimento.',
                ),
                style: TextStyle(
                  color: Colors.white.withOpacity(.68),
                  fontSize: 15,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: mobile ? 1 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: mobile ? 1.34 : 1.55,
                children: items,
              ),
              const SizedBox(height: 12),
              Text(
                _t(
                  ko:
                      '안전 안내: GPS 정확도와 통신 상태는 지형, 기기, 날씨와 네트워크 환경에 따라 달라질 수 있습니다. ORQUBE의 안전 기능은 사용자의 판단과 공식 구조·긴급 서비스를 대체하지 않습니다.',
                  en:
                      'Safety notice: GPS accuracy and connectivity can vary with terrain, device, weather and network conditions. ORQUBE safety functions do not replace user judgment or official rescue and emergency services.',
                  ja:
                      '安全上の注意：GPS精度や通信状態は環境により変化します。ORQUBEは公的な救助・緊急サービスに代わるものではありません。',
                  zh: '安全提示：GPS精度和通信状态会因环境而变化。ORQUBE不能替代用户判断或官方救援与紧急服务。',
                  fr:
                      'Avis de sécurité : la précision GPS et la connectivité varient selon l’environnement. ORQUBE ne remplace pas les services officiels de secours.',
                  pt:
                      'Aviso de segurança: a precisão do GPS e a conectividade variam conforme o ambiente. A ORQUBE não substitui serviços oficiais de emergência.',
                ),
                style: TextStyle(
                  color: Colors.white.withOpacity(.52),
                  fontSize: 12.5,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _airsoftMapGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xE6101426),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _cyan.withOpacity(.38)),
                  boxShadow: [
                    BoxShadow(color: _cyan.withOpacity(.08), blurRadius: 24),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 760;
                    final icon = Container(
                      width: compact ? 64 : 78,
                      height: compact ? 64 : 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _cyan.withOpacity(.13),
                        border: Border.all(color: _cyan.withOpacity(.55)),
                      ),
                      child: Icon(
                        Icons.map_rounded,
                        color: _cyan,
                        size: compact ? 31 : 38,
                      ),
                    );
                    final copy = Column(
                      crossAxisAlignment:
                          compact
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t(
                            ko: 'AIRSOFT 지도 서비스 안내',
                            en: 'AIRSOFT MAP SERVICE',
                            ja: 'AIRSOFTマップサービス案内',
                            zh: 'AIRSOFT 地图服务说明',
                            fr: 'SERVICE DE CARTE AIRSOFT',
                            pt: 'SERVIÇO DE MAPA AIRSOFT',
                          ),
                          textAlign:
                              compact ? TextAlign.center : TextAlign.left,
                          style: const TextStyle(
                            color: _cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _t(
                            ko:
                                '주변 경기장과 예정 경기를 지도에서 찾고, 경기 정보·집결지·안전구역을 확인한 뒤 길찾기를 이용할 수 있습니다. 로그인 사용자는 본인이 직접 동의한 경우에만 30분 안전 위치 공유와 긴급 SOS를 사용할 수 있습니다.',
                            en:
                                'Find nearby fields and upcoming matches, check meeting and safety zones, and open directions. Signed-in users may use 30-minute safety location sharing and emergency SOS only after explicit consent.',
                            ja:
                                '周辺のフィールドや予定試合を地図で探し、集合場所・安全区域・ルート案内を確認できます。ログインユーザーは明示的に同意した場合のみ、30分間の安全位置共有と緊急SOSを利用できます。',
                            zh:
                                '可在地图中查找附近场地和预定比赛，确认集合点、安全区域并使用导航。登录用户仅在明确同意后，才能使用30分钟安全位置共享和紧急SOS。',
                            fr:
                                'Trouvez les terrains et matchs à proximité, consultez les points de rassemblement et zones de sécurité, puis ouvrez l’itinéraire. Les utilisateurs connectés peuvent partager leur position pendant 30 minutes et utiliser le SOS uniquement après consentement explicite.',
                            pt:
                                'Encontre campos e partidas próximas, confira pontos de encontro e zonas de segurança e abra a navegação. Usuários conectados podem compartilhar a localização por 30 minutos e usar SOS somente após consentimento explícito.',
                          ),
                          textAlign:
                              compact ? TextAlign.center : TextAlign.left,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.78),
                            fontSize: compact ? 15 : 17,
                            height: 1.75,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                    return compact
                        ? Column(
                          children: [icon, const SizedBox(height: 18), copy],
                        )
                        : Row(
                          children: [
                            icon,
                            const SizedBox(width: 24),
                            Expanded(child: copy),
                          ],
                        );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  collapsedBackgroundColor: const Color(0xB30B0F1D),
                  backgroundColor: const Color(0xD90B0F1D),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: _violet.withOpacity(.24)),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: _violet.withOpacity(.38)),
                  ),
                  leading: const Icon(Icons.privacy_tip_rounded, color: _lime),
                  iconColor: _lime,
                  collapsedIconColor: Colors.white54,
                  title: Text(
                    _t(
                      ko: '개인정보 및 위치정보 보호 기준',
                      en: 'PRIVACY & LOCATION PROTECTION',
                      ja: '個人情報・位置情報保護基準',
                      zh: '隐私与位置信息保护标准',
                      fr: 'PROTECTION DE LA VIE PRIVÉE ET DE LA LOCALISATION',
                      pt: 'PROTEÇÃO DE PRIVACIDADE E LOCALIZAÇÃO',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                  children: [
                    Text(
                      _t(
                        ko:
                            '위치 공유는 기본적으로 꺼져 있으며 사용자가 직접 동의해야 시작됩니다. 공유 대상과 시간을 제한하고, 경기 진행 중에는 상대 팀 추적 목적으로 사용할 수 없습니다. 긴급 SOS 위치는 지정된 운영자·안전 담당자에게만 전달하며, 공유 종료 또는 만료 후 위치 데이터는 삭제하도록 운영합니다.',
                        en:
                            'Location sharing is off by default and starts only with user consent. Access and duration are limited, and it must never be used to track opponents during a match. Emergency SOS location is shared only with designated organizers or safety staff and is deleted after sharing ends or expires.',
                        ja:
                            '位置共有は初期状態でオフで、ユーザーの同意後にのみ開始されます。共有相手と時間を制限し、試合中の相手チーム追跡には使用できません。緊急SOS位置は指定された運営者・安全担当者のみに共有され、終了または期限切れ後に削除されます。',
                        zh:
                            '位置共享默认关闭，仅在用户同意后启动。共享对象和时间受到限制，比赛中不得用于追踪对手。紧急SOS位置仅发送给指定组织者或安全人员，并在共享结束或到期后删除。',
                        fr:
                            'Le partage de localisation est désactivé par défaut et ne démarre qu’avec le consentement de l’utilisateur. Les destinataires et la durée sont limités; il ne peut pas servir à suivre l’équipe adverse. La position SOS est transmise uniquement aux organisateurs ou responsables de sécurité désignés, puis supprimée à la fin ou à l’expiration.',
                        pt:
                            'O compartilhamento de localização fica desativado por padrão e só começa com consentimento. Destinatários e duração são limitados, e o recurso não pode rastrear adversários durante a partida. A localização SOS é enviada apenas a organizadores ou responsáveis de segurança designados e apagada ao final ou expiração.',
                      ),
                      style: TextStyle(
                        color: Colors.white.withOpacity(.68),
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storyOpening() {
    return _storyBlock(
      number: '01',
      eyebrow: 'THE STORY',
      title: _t(
        ko: '우리는 단순한 채굴 앱을\n만들지 않습니다.',
        en: 'We are not building\njust another mining app.',
        ja: '私たちは単なるマイニングアプリを\n作っているのではありません。',
        zh: '我们打造的不只是\n又一个挖矿应用。',
        fr: 'Nous ne construisons pas\nune simple application de minage.',
        pt: 'Não estamos criando\napenas mais um aplicativo de mineração.',
      ),
      body: _t(
        ko: '사용자의 참여, 커뮤니티 활동, 광고 경험과 디지털 자산이\n하나의 가치 흐름으로 이어지는 새로운 생태계를 만듭니다.',
        en:
            'Participation, community, advertising and digital assets\nbecome one connected flow of value.',
        ja: 'ユーザー参加、コミュニティ活動、広告体験、デジタル資産を\nひとつの価値の流れにつなぐ新しいエコシステムを作ります。',
        zh: '用户参与、社区活动、广告体验和数字资产\n共同形成一个连贯的价值流。',
        fr:
            'La participation, la communauté, la publicité et les actifs numériques\nforment un flux de valeur connecté.',
        pt:
            'Participação, comunidade, publicidade e ativos digitais\nformam um fluxo de valor conectado.',
      ),
      button: _t(
        ko: '왜 ORQUBE인가',
        en: 'WHY ORQUBE',
        ja: 'ORQUBEを選ぶ理由',
        zh: '为什么选择 ORQUBE',
        fr: 'POURQUOI ORQUBE',
        pt: 'POR QUE ORQUBE',
      ),
      icon: Icons.public_rounded,
      onPressed: () => _scrollTo(_whyKey),
      reverse: false,
    );
  }

  Widget _whySection() {
    return _section(
      key: _whyKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Column(
          children: [
            _sectionHeader(
              'WHY ORQUBE',
              _t(
                ko: '하나의 프로젝트.\n네 개의 핵심 가치.',
                en: 'One project.\nFour core values.',
                ja: 'ひとつのプロジェクト。\n4つの中核価値。',
                zh: '一个项目。\n四项核心价值。',
                fr: 'Un projet.\nQuatre valeurs essentielles.',
                pt: 'Um projeto.\nQuatro valores centrais.',
              ),
              _t(
                ko: '사용자가 무엇을 얻고, 왜 참여해야 하는지를 먼저 보여줍니다.',
                en: 'The value of participation is clear from the beginning.',
                ja: 'ユーザーが何を得て、なぜ参加するのかを最初に明確にします。',
                zh: '从一开始就清楚展示用户能获得什么以及为何参与。',
                fr: 'La valeur de la participation est claire dès le départ.',
                pt: 'O valor da participação fica claro desde o início.',
              ),
            ),
            const SizedBox(height: 46),
            LayoutBuilder(
              builder: (_, constraints) {
                final cardWidth = constraints.maxWidth >= 1100 ? 284.0 : 500.0;

                final cards = [
                  _valueCard(
                    Icons.auto_awesome_rounded,
                    'AI MARKETING',
                    _t(
                      ko: 'AI가 다국어 콘텐츠와 글로벌 홍보를 지원합니다.',
                      en:
                          'AI supports multilingual content and global promotion.',
                      ja: 'AIが多言語コンテンツとグローバルプロモーションを支援します。',
                      zh: 'AI支持多语言内容与全球推广。',
                      fr:
                          'L’IA soutient le contenu multilingue et la promotion mondiale.',
                      pt: 'A IA apoia conteúdo multilíngue e promoção global.',
                    ),
                    _violet,
                  ),
                  _valueCard(
                    Icons.bolt_rounded,
                    'DAILY MINING',
                    _t(
                      ko: '매일 참여하고 ORBS 리워드를 축적합니다.',
                      en: 'Participate daily and build ORBS rewards.',
                      ja: '毎日参加してORBS報酬を積み上げます。',
                      zh: '每日参与并积累ORBS奖励。',
                      fr:
                          'Participez chaque jour et accumulez des récompenses ORBS.',
                      pt: 'Participe diariamente e acumule recompensas ORBS.',
                    ),
                    _lime,
                  ),
                  _valueCard(
                    Icons.radar_rounded,
                    'AIRSOFT HUB',
                    _t(
                      ko: '팀, 경기, 지도, 업체와 마켓을 연결합니다.',
                      en: 'Connect teams, matches, maps, businesses and markets.',
                      ja: 'チーム、試合、地図、事業者、マーケットをつなぎます。',
                      zh: '连接战队、比赛、地图、商家与市场。',
                      fr:
                          'Connectez équipes, matchs, cartes, entreprises et marchés.',
                      pt:
                          'Conecte equipes, partidas, mapas, empresas e mercados.',
                    ),
                    _cyan,
                  ),
                  _valueCard(
                    Icons.diamond_outlined,
                    'NFT & ASSETS',
                    _t(
                      ko: '리워드와 디지털 자산을 하나의 지갑에서 관리합니다.',
                      en: 'Manage rewards and digital assets in one wallet.',
                      ja: '報酬とデジタル資産をひとつのウォレットで管理します。',
                      zh: '在一个钱包中管理奖励与数字资产。',
                      fr:
                          'Gérez récompenses et actifs numériques dans un seul portefeuille.',
                      pt:
                          'Gerencie recompensas e ativos digitais em uma única carteira.',
                    ),
                    Colors.pinkAccent,
                  ),
                ];

                return Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  alignment: WrapAlignment.center,
                  children:
                      cards
                          .map(
                            (card) => SizedBox(width: cardWidth, child: card),
                          )
                          .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _howSection() {
    return _section(
      key: _howKey,
      darker: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(
          children: [
            _sectionHeader(
              'HOW IT WORKS',
              _t(
                ko: '읽고, 참여하고,\n가치를 확장합니다.',
                en: 'Discover, participate,\nand grow value.',
                ja: '知り、参加し、\n価値を広げます。',
                zh: '了解、参与，\n并扩大价值。',
                fr: 'Découvrez, participez\net développez la valeur.',
                pt: 'Descubra, participe\ne amplie o valor.',
              ),
              _t(
                ko: '복잡한 기술보다 사용자가 이해하기 쉬운 네 단계에 집중합니다.',
                en:
                    'Four simple steps turn technology into an understandable experience.',
                ja: '複雑な技術ではなく、理解しやすい4つのステップに集中します。',
                zh: '通过四个简单步骤，让技术变成易于理解的体验。',
                fr:
                    'Quatre étapes simples rendent la technologie facile à comprendre.',
                pt:
                    'Quatro etapas simples tornam a tecnologia fácil de entender.',
              ),
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (_, constraints) {
                final narrow = constraints.maxWidth < 830;

                final steps = [
                  _step(
                    '01',
                    _t(
                      ko: '가입',
                      en: 'JOIN',
                      ja: '登録',
                      zh: '加入',
                      fr: 'REJOINDRE',
                      pt: 'ENTRAR',
                    ),
                    _t(
                      ko: '계정을 만들고 생태계에 입장합니다.',
                      en: 'Create an account and enter the ecosystem.',
                      ja: 'アカウントを作成してエコシステムに参加します。',
                      zh: '创建账户并进入生态系统。',
                      fr: 'Créez un compte et entrez dans l’écosystème.',
                      pt: 'Crie uma conta e entre no ecossistema.',
                    ),
                  ),
                  _step(
                    '02',
                    _t(
                      ko: '참여',
                      en: 'PARTICIPATE',
                      ja: '参加',
                      zh: '参与',
                      fr: 'PARTICIPER',
                      pt: 'PARTICIPAR',
                    ),
                    _t(
                      ko: '채굴, 광고, 출석과 커뮤니티에 참여합니다.',
                      en: 'Mine, check in, view ads and join the community.',
                      ja: 'マイニング、広告、出席、コミュニティに参加します。',
                      zh: '参与挖矿、广告、签到和社区活动。',
                      fr:
                          'Minez, pointez, regardez des publicités et rejoignez la communauté.',
                      pt:
                          'Minere, faça check-in, veja anúncios e participe da comunidade.',
                    ),
                  ),
                  _step(
                    '03',
                    _t(
                      ko: '획득',
                      en: 'EARN',
                      ja: '獲得',
                      zh: '获取',
                      fr: 'GAGNER',
                      pt: 'GANHAR',
                    ),
                    _t(
                      ko: 'POINT와 ORBS 리워드를 축적합니다.',
                      en: 'Accumulate POINT and ORBS rewards.',
                      ja: 'POINTとORBS報酬を積み上げます。',
                      zh: '积累POINT和ORBS奖励。',
                      fr: 'Accumulez des récompenses POINT et ORBS.',
                      pt: 'Acumule recompensas POINT e ORBS.',
                    ),
                  ),
                  _step(
                    '04',
                    _t(
                      ko: '활용',
                      en: 'USE',
                      ja: '活用',
                      zh: '使用',
                      fr: 'UTILISER',
                      pt: 'USAR',
                    ),
                    _t(
                      ko: 'Wallet, NFT, Airsoft와 Marketplace로 확장합니다.',
                      en: 'Expand into Wallet, NFT, Airsoft and Marketplace.',
                      ja: 'Wallet、NFT、Airsoft、Marketplaceへ広げます。',
                      zh: '扩展到Wallet、NFT、Airsoft和Marketplace。',
                      fr:
                          'Étendez l’expérience au Wallet, NFT, Airsoft et Marketplace.',
                      pt: 'Expanda para Wallet, NFT, Airsoft e Marketplace.',
                    ),
                  ),
                ];

                if (narrow) {
                  return Column(
                    children: [
                      for (final step in steps) ...[
                        step,
                        const SizedBox(height: 14),
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < steps.length; i++) ...[
                      Expanded(child: steps[i]),
                      if (i != steps.length - 1) const SizedBox(width: 14),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardStory() {
    return _storyBlock(
      number: '02',
      eyebrow: 'REWARD EXPERIENCE',
      title: _t(
        ko: '매일의 참여가\n리워드가 됩니다.',
        en: 'Daily participation\nbecomes a reward.',
        ja: '毎日の参加が\n報酬になります。',
        zh: '每日参与\n都会转化为奖励。',
        fr: 'La participation quotidienne\ndevient une récompense.',
        pt: 'A participação diária\nse transforma em recompensa.',
      ),
      body: _t(
        ko:
            '채굴, 출석, 광고 참여와 커뮤니티 활동이 하나의 리워드 경험으로 연결됩니다.\n사용자는 복잡한 기술을 몰라도 자연스럽게 ORQUBE 생태계에 참여합니다.',
        en:
            'Mining, check-ins, advertising and community activity connect into one reward experience.',
        ja: 'マイニング、出席、広告参加、コミュニティ活動がひとつの報酬体験につながります。',
        zh: '挖矿、签到、广告参与和社区活动共同构成统一的奖励体验。',
        fr:
            'Minage, présence, publicité et activité communautaire forment une expérience de récompense unique.',
        pt:
            'Mineração, check-ins, anúncios e atividade comunitária formam uma única experiência de recompensa.',
      ),
      button: _t(
        ko: '채굴 화면 입장',
        en: 'ENTER MINING',
        ja: 'マイニング画面へ',
        zh: '进入挖矿页面',
        fr: 'ENTRER DANS LE MINAGE',
        pt: 'ENTRAR NA MINERAÇÃO',
      ),
      icon: Icons.auto_graph_rounded,
      onPressed: _openDashboard,
      reverse: true,
    );
  }

  Widget _airsoftStory() {
    return _storyBlock(
      number: '03',
      eyebrow: 'GLOBAL AIRSOFT HUB',
      title: _t(
        ko: '팀과 경기,\n세계를 지도 위에서 연결합니다.',
        en: 'Connect teams, matches\nand the world on one map.',
        ja: 'チームと試合、\n世界を地図上でつなぎます。',
        zh: '将战队、比赛与世界\n连接在一张地图上。',
        fr: 'Reliez équipes, matchs\net le monde sur une seule carte.',
        pt: 'Conecte equipes, partidas\ne o mundo em um único mapa.',
      ),
      body: _t(
        ko:
            '팀 찾기, 경기 등록, 경기장 지도, 업체 입점과 안전한 마켓까지.\nAirsoft Hub가 흩어진 경험을 하나의 글로벌 네트워크로 만듭니다.',
        en:
            'Teams, matches, venues, businesses and a safer marketplace become one network.',
        ja: 'チーム、試合、会場、事業者、安全なマーケットをひとつのネットワークにつなぎます。',
        zh: '战队、比赛、场地、商家与更安全的市场共同组成一个网络。',
        fr:
            'Équipes, matchs, lieux, entreprises et marché plus sûr deviennent un seul réseau.',
        pt:
            'Equipes, partidas, locais, empresas e um mercado mais seguro formam uma única rede.',
      ),
      button: _t(
        ko: 'AIRSOFT HUB 입장',
        en: 'ENTER AIRSOFT HUB',
        ja: 'AIRSOFT HUBへ',
        zh: '进入 AIRSOFT HUB',
        fr: 'ENTRER DANS AIRSOFT HUB',
        pt: 'ENTRAR NO AIRSOFT HUB',
      ),
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
        _t(
          ko: 'ORBS와 디지털 자산 관리',
          en: 'Manage ORBS and digital assets',
          ja: 'ORBSとデジタル資産を管理',
          zh: '管理ORBS与数字资产',
          fr: 'Gérer ORBS et actifs numériques',
          pt: 'Gerenciar ORBS e ativos digitais',
        ),
      ),
      (
        Icons.bolt_rounded,
        'MINING',
        _t(
          ko: '24시간 참여형 리워드',
          en: '24-hour participation rewards',
          ja: '24時間参加型報酬',
          zh: '24小时参与奖励',
          fr: 'Récompenses de participation sur 24 h',
          pt: 'Recompensas de participação por 24 horas',
        ),
      ),
      (
        Icons.diamond_outlined,
        'NFT',
        _t(
          ko: '등급과 혜택을 가진 디지털 컬렉션',
          en: 'Digital collections with benefits',
          ja: 'ランクと特典を持つデジタルコレクション',
          zh: '具有等级与权益的数字藏品',
          fr: 'Collections numériques avec rangs et avantages',
          pt: 'Coleções digitais com níveis e benefícios',
        ),
      ),
      (
        Icons.radar_rounded,
        'AIRSOFT',
        _t(
          ko: '팀·경기·지도·업체 통합 허브',
          en: 'Teams, matches, maps and businesses',
          ja: 'チーム・試合・地図・事業者の統合ハブ',
          zh: '战队·比赛·地图·商家一体化中心',
          fr: 'Hub pour équipes, matchs, cartes et entreprises',
          pt: 'Hub de equipes, partidas, mapas e empresas',
        ),
      ),
      (
        Icons.forum_outlined,
        'COMMUNITY',
        _t(
          ko: '국내외 사용자가 연결되는 공간',
          en: 'A space connecting global users',
          ja: '国内外ユーザーをつなぐ空間',
          zh: '连接全球用户的空间',
          fr: 'Un espace reliant les utilisateurs du monde entier',
          pt: 'Um espaço que conecta usuários globais',
        ),
      ),
      (
        Icons.storefront_outlined,
        'MARKET',
        _t(
          ko: '안전 품목 중심의 거래 공간',
          en: 'A marketplace focused on safer items',
          ja: '安全な品目を中心とした取引空間',
          zh: '以安全品类为中心的交易空间',
          fr: 'Un marché axé sur des articles plus sûrs',
          pt: 'Um mercado focado em itens mais seguros',
        ),
      ),
    ];

    return _section(
      key: _ecosystemKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(
          children: [
            _sectionHeader(
              'ORQUBE ECOSYSTEM',
              _t(
                ko: '스토리를 이해했다면,\n이제 직접 선택하세요.',
                en: 'Now that you know the story,\nchoose your experience.',
                ja: 'ストーリーを理解したら、\n次は体験を選んでください。',
                zh: '了解故事之后，\n现在选择您的体验。',
                fr:
                    'Maintenant que vous connaissez l’histoire,\nchoisissez votre expérience.',
                pt:
                    'Agora que você conhece a história,\nescolha sua experiência.',
              ),
              _t(
                ko: '모든 서비스는 하나의 계정과 리워드 흐름으로 이어집니다.',
                en: 'Every service connects through one account and reward flow.',
                ja: 'すべてのサービスはひとつのアカウントと報酬フローでつながります。',
                zh: '所有服务都通过一个账户与奖励流连接。',
                fr:
                    'Tous les services sont reliés par un compte et un flux de récompenses.',
                pt:
                    'Todos os serviços se conectam por uma conta e um fluxo de recompensas.',
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
                          padding: const EdgeInsets.all(23),
                          child: Row(
                            children: [
                              Container(
                                width: 57,
                                height: 57,
                                decoration: BoxDecoration(
                                  color: _purple.withOpacity(.16),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(item.$1, color: _lime, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        color: Colors.white.withOpacity(.57),
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
    );
  }

  Widget _roadmapSection() {
    final phases = [
      (
        '01',
        'MVP',
        _t(
          ko: '채굴·출석·지갑·커뮤니티 기반',
          en: 'Mining, attendance, wallet and community',
          ja: 'マイニング・出席・ウォレット・コミュニティ基盤',
          zh: '挖矿、签到、钱包与社区基础',
          fr: 'Base de minage, présence, portefeuille et communauté',
          pt: 'Base de mineração, presença, carteira e comunidade',
        ),
      ),
      (
        '02',
        'AIRSOFT HUB',
        _t(
          ko: '팀·경기·지도·업체·마켓',
          en: 'Teams, matches, maps, businesses and market',
          ja: 'チーム・試合・地図・事業者・マーケット',
          zh: '战队、比赛、地图、商家与市场',
          fr: 'Équipes, matchs, cartes, entreprises et marché',
          pt: 'Equipes, partidas, mapas, empresas e mercado',
        ),
      ),
      (
        '03',
        'AI MARKETING',
        _t(
          ko: '6개국어 글로벌 콘텐츠 확장',
          en: 'Six-language global content expansion',
          ja: '6言語によるグローバルコンテンツ拡張',
          zh: '六种语言的全球内容扩展',
          fr: 'Expansion mondiale du contenu en six langues',
          pt: 'Expansão global de conteúdo em seis idiomas',
        ),
      ),
      (
        '04',
        'WEB3 EXPANSION',
        _t(
          ko: 'Kaia·NFT·메인넷 단계 확장',
          en: 'Kaia, NFT and mainnet expansion',
          ja: 'Kaia・NFT・メインネット段階拡張',
          zh: 'Kaia、NFT与主网阶段扩展',
          fr: 'Expansion progressive de Kaia, NFT et du mainnet',
          pt: 'Expansão gradual de Kaia, NFT e mainnet',
        ),
      ),
    ];

    return _section(
      key: _roadmapKey,
      darker: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Column(
          children: [
            _sectionHeader(
              'ROADMAP',
              _t(
                ko: '작은 기능을 쌓아\n큰 생태계로 확장합니다.',
                en: 'Build practical features,\nthen scale the ecosystem.',
                ja: '実用的な機能を積み重ね、\n大きなエコシステムへ拡張します。',
                zh: '从实用功能开始，\n逐步扩展为大型生态系统。',
                fr:
                    'Construisez des fonctions utiles,\npuis développez l’écosystème.',
                pt: 'Construa recursos práticos\ne depois amplie o ecossistema.',
              ),
              _t(
                ko: '각 단계는 실제 사용자 경험과 안정성을 확인하며 진행합니다.',
                en:
                    'Each phase grows through tested user experience and stability.',
                ja: '各段階は実際のユーザー体験と安定性を確認しながら進めます。',
                zh: '每个阶段都会在验证真实用户体验与稳定性后推进。',
                fr:
                    'Chaque phase progresse après validation de l’expérience et de la stabilité.',
                pt:
                    'Cada fase avança após validar a experiência e a estabilidade.',
              ),
            ),
            const SizedBox(height: 48),
            for (final phase in phases) ...[
              _glass(
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
                    const Icon(Icons.arrow_forward_rounded, color: _violet),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 8),
            _outlineButton(
              _t(
                ko: '백서에서 전체 계획 보기',
                en: 'VIEW FULL PLAN IN WHITEPAPER',
                ja: 'ホワイトペーパーで全計画を見る',
                zh: '在白皮书中查看完整计划',
                fr: 'VOIR LE PLAN COMPLET DANS LE LIVRE BLANC',
                pt: 'VER PLANO COMPLETO NO WHITEPAPER',
              ),
              Icons.description_outlined,
              _openWhitepaper,
            ),
          ],
        ),
      ),
    );
  }

  Widget _finalCta() {
    return SizedBox(
      width: double.infinity,
      height: 610,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _eyebrow(
                  _t(
                    ko: '다음 여정',
                    en: 'THE NEXT JOURNEY',
                    ja: '次の旅',
                    zh: '下一段旅程',
                    fr: 'LA PROCHAINE AVENTURE',
                    pt: 'A PRÓXIMA JORNADA',
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _t(
                    ko: 'ORQUBE의 새로운 여정에\n함께하세요.',
                    en: 'Join the next journey\nof ORQUBE.',
                    ja: 'ORQUBEの新しい旅に\n参加してください。',
                    zh: '加入ORQUBE的\n全新旅程。',
                    fr: 'Rejoignez la nouvelle aventure\nd’ORQUBE.',
                    pt: 'Participe da nova jornada\nda ORQUBE.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _mobileTitleSize(28, ratio: .68),
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.6,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _t(
                    ko: 'AI와 Web3가 만나는 글로벌 리워드 플랫폼.',
                    en: 'A global reward platform where AI meets Web3.',
                    ja: 'AIとWeb3が出会うグローバル報酬プラットフォーム。',
                    zh: 'AI与Web3相遇的全球奖励平台。',
                    fr:
                        'Une plateforme mondiale de récompenses où l’IA rencontre le Web3.',
                    pt:
                        'Uma plataforma global de recompensas onde IA encontra Web3.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.60),
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
                      _t(
                        ko: '지금 시작하기',
                        en: 'START NOW',
                        ja: '今すぐ始める',
                        zh: '立即开始',
                        fr: 'COMMENCER',
                        pt: 'COMEÇAR AGORA',
                      ),
                      Icons.rocket_launch_rounded,
                      _openDashboard,
                    ),
                    _outlineButton(
                      _t(
                        ko: '채굴 체험하기',
                        en: 'EXPLORE MINING',
                        ja: 'マイニングを体験',
                        zh: '体验挖矿',
                        fr: 'DÉCOUVRIR LE MINAGE',
                        pt: 'EXPLORAR MINERAÇÃO',
                      ),
                      Icons.bolt_rounded,
                      _openDashboard,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _orqubePublicContentHub() {
    return Container(
      key: const ValueKey<String>('orqube-public-content-hub-v2026-08-17'),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
        14,
        MediaQuery.sizeOf(context).width < 600 ? 16 : 24,
        42,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _lime.withOpacity(.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _lime.withOpacity(.28)),
                  ),
                  child: const Text(
                    'ORQUBE CONTENT HUB · 2026.08.17',
                    style: TextStyle(
                      color: _lime,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _publicSectionTitle(
                'ORQUBE MEDIA',
                _t(
                  ko:
                      '이미지와 동영상으로 ORQUBE의 활동과 기능을 확인하세요. 운영자가 등록한 새 콘텐츠는 이 공간에 자동으로 추가됩니다.',
                  en:
                      'Explore ORQUBE through images and videos. New media registered by the operator appears here automatically.',
                  ja: '画像と動画でORQUBEの活動や機能をご覧ください。',
                  zh: '通过图片和视频了解ORQUBE的活动与功能。',
                  fr: 'Découvrez ORQUBE en images et en vidéos.',
                  pt: 'Conheça a ORQUBE por imagens e vídeos.',
                ),
              ),
              const SizedBox(height: 12),
              _featuredYoutubeVideo(),
              const SizedBox(height: 12),
              _mediaGallery(),
              const SizedBox(height: 34),
              _publicSectionTitle(
                'OFFICIAL CHANNELS',
                _t(
                  ko: '공식 채널은 외부 타임라인 전체를 강제로 불러오지 않고 빠르고 안정적으로 연결합니다.',
                  en:
                      'Official channels use lightweight, stable links rather than loading full external timelines.',
                  ja: '外部タイムライン全体を読み込まず、公式チャンネルへ安定して接続します。',
                  zh: '不加载完整外部时间线，以轻量稳定的方式连接官方频道。',
                  fr:
                      'Les canaux officiels utilisent des liens légers et stables.',
                  pt: 'Os canais oficiais usam links leves e estáveis.',
                ),
              ),
              const SizedBox(height: 18),
              _socialCommunityCards(),
              const SizedBox(height: 34),
              _publicSectionTitle(
                'NAVER CAFE · LATEST',
                _t(
                  ko: '대한민국 특전사 네이버 카페의 최신 커뮤니티 글을 ORQUBE에서 확인하세요.',
                  en:
                      'See the latest posts from the ORQUBE NAVER Cafe community.',
                  ja: 'ORQUBE NAVER Cafeコミュニティの最新投稿をご覧ください。',
                  zh: '查看 ORQUBE NAVER Cafe 社区的最新帖子。',
                  fr:
                      'Consultez les dernières publications de la communauté NAVER Cafe.',
                  pt:
                      'Veja as publicações mais recentes da comunidade NAVER Cafe.',
                ),
              ),
              const SizedBox(height: 18),
              _naverCafeLatestPosts(),
              const SizedBox(height: 30),
              _publicSectionTitle(
                'ORQUBE BLOCKCHAIN',
                _t(
                  ko:
                      'ORBS 핵심 정보를 한눈에 확인할 수 있습니다. 홀더와 전송 수는 공개 설정 데이터와 연결할 수 있습니다.',
                  en:
                      'View essential ORBS information at a glance. Holder and transfer counts can be connected to public data updates.',
                  ja: 'ORBSの主要情報を一覧で確認できます。',
                  zh: '一览查看ORBS核心信息。',
                  fr: 'Consultez les informations essentielles sur ORBS.',
                  pt: 'Veja as informações essenciais do ORBS.',
                ),
              ),
              const SizedBox(height: 18),
              _blockchainInfoPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _publicSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(.62),
            height: 1.6,
            fontSize: 14.5,
          ),
        ),
      ],
    );
  }

  Widget _featuredYoutubeVideo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 680;
        return InkWell(
          onTap:
              () => openExternalUrl(
                OrqubePublicContentConfig.youtubeFeaturedVideoUrl,
              ),
          borderRadius: BorderRadius.circular(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: mobile ? 360 : 250),
            child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _violet.withOpacity(.34)),
            ),
            child:
                mobile
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _featuredYoutubeVisual(aspectRatio: 16 / 9),
                        _featuredYoutubeCopy(),
                      ],
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: _featuredYoutubeVisual(aspectRatio: 16 / 9),
                        ),
                        Expanded(flex: 4, child: _featuredYoutubeCopy()),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _featuredYoutubeVisual({required double aspectRatio}) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            OrqubePublicContentConfig.youtubeFeaturedThumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _purple.withOpacity(.52),
                        const Color(0xFF071424),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.ondemand_video_rounded,
                      color: Colors.white,
                      size: 72,
                    ),
                  ),
                ),
          ),
          Container(color: Colors.black.withOpacity(.12)),
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.64),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 1.4),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
          const Positioned(left: 14, top: 14, child: _FeaturedVideoBadge()),
        ],
      ),
    );
  }

  Widget _featuredYoutubeCopy() {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORQUBE FEATURED VIDEO',
            style: TextStyle(
              color: _lime,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _t(
              ko: 'ORQUBE 공식 대표 영상',
              en: 'Official ORQUBE Featured Video',
              ja: 'ORQUBE公式注目動画',
              zh: 'ORQUBE 官方精选视频',
              fr: 'Vidéo officielle ORQUBE',
              pt: 'Vídeo oficial em destaque da ORQUBE',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _t(
              ko: '영상을 누르면 YouTube에서 바로 재생됩니다.',
              en: 'Tap the video to play it on YouTube.',
              ja: '動画をタップするとYouTubeで再生されます。',
              zh: '点击视频即可在 YouTube 播放。',
              fr: 'Touchez la vidéo pour la lire sur YouTube.',
              pt: 'Toque no vídeo para reproduzi-lo no YouTube.',
            ),
            style: const TextStyle(
              color: Colors.white60,
              height: 1.5,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                color: _lime,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'YouTube  @orqube',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mediaGallery() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection(OrqubePublicContentConfig.mediaCollection)
              .snapshots(),
      builder: (context, snapshot) {
        final docs =
            (snapshot.data?.docs ?? const [])
                .where((d) => d.data()['enabled'] != false)
                .toList()
              ..sort((a, b) {
                final av = (a.data()['sortOrder'] as num?)?.toInt() ?? 999;
                final bv = (b.data()['sortOrder'] as num?)?.toInt() ?? 999;
                return av.compareTo(bv);
              });

        if (docs.isEmpty) {
          return _mediaFallbackCards();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 680;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length > 6 ? 6 : docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mobile ? 1 : 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: mobile ? 1.45 : 1.05,
              ),
              itemBuilder: (_, index) => _mediaCard(docs[index].data()),
            );
          },
        );
      },
    );
  }

  Widget _mediaFallbackCards() {
    final cards = <Widget>[
      _contentInfoCard(
        Icons.hiking_rounded,
        'SAFE HIKING',
        _t(
          ko: '오프라인 지도와 GPS 기반 안전산행 흐름을 소개합니다.',
          en: 'Offline maps and GPS-supported safe hiking workflow.',
          ja: 'オフライン地図とGPSを活用した安全登山。',
          zh: '离线地图与GPS安全登山流程。',
          fr: 'Randonnée sûre avec cartes hors ligne et GPS.',
          pt: 'Caminhada segura com mapas offline e GPS.',
        ),
      ),
      _contentInfoCard(
        Icons.sports_mma_rounded,
        'AIRSOFT HUB',
        _t(
          ko: '경기·팀·필드 정보를 연결하는 글로벌 AIRSOFT 커뮤니티입니다.',
          en: 'A global AIRSOFT community connecting games, teams and fields.',
          ja: 'ゲーム・チーム・フィールドをつなぐAIRSOFTコミュニティ。',
          zh: '连接比赛、团队和场地的AIRSOFT社区。',
          fr: 'Communauté AIRSOFT reliant parties, équipes et terrains.',
          pt: 'Comunidade AIRSOFT conectando jogos, equipes e campos.',
        ),
      ),
      _contentInfoCard(
        Icons.play_circle_outline_rounded,
        'ORQUBE VIDEO',
        _t(
          ko: '공식 YouTube에서 ORQUBE 영상과 업데이트를 바로 확인할 수 있습니다.',
          en: 'Watch ORQUBE videos and updates on the official YouTube channel.',
          ja: '公式YouTubeでORQUBE動画をご覧いただけます。',
          zh: '在官方YouTube查看ORQUBE视频。',
          fr: 'Regardez les vidéos ORQUBE sur YouTube.',
          pt: 'Veja vídeos da ORQUBE no YouTube.',
        ),
        onTap:
            () => openExternalUrl(OrqubePublicContentConfig.youtubeChannelUrl),
      ),
    ];
    return LayoutBuilder(
      builder: (_, constraints) {
        final mobile = constraints.maxWidth < 680;
        return GridView.count(
          crossAxisCount: mobile ? 1 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: mobile ? 2.0 : 1.35,
          children: cards,
        );
      },
    );
  }

  Widget _mediaCard(Map<String, dynamic> data) {
    final type = '${data['type'] ?? 'image'}'.toLowerCase();
    final title = '${data['title'] ?? 'ORQUBE MEDIA'}'.trim();
    final description = '${data['description'] ?? ''}'.trim();
    final thumbnail =
        '${data['thumbnailUrl'] ?? data['imageUrl'] ?? ''}'.trim();
    final mediaUrl =
        '${data['mediaUrl'] ?? data['videoUrl'] ?? thumbnail}'.trim();

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: mediaUrl.isEmpty ? null : () => openExternalUrl(mediaUrl),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumbnail.isNotEmpty)
                    Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _mediaVisualFallback(type),
                    )
                  else
                    _mediaVisualFallback(type),
                  if (type == 'video')
                    const Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 58,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaVisualFallback(String type) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_purple.withOpacity(.45), const Color(0xFF071424)],
        ),
      ),
      child: Icon(
        type == 'video' ? Icons.videocam_rounded : Icons.photo_library_rounded,
        color: _lime,
        size: 48,
      ),
    );
  }

  Widget _contentInfoCard(
    IconData icon,
    String title,
    String body, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _violet.withOpacity(.28)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _lime, size: 34),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialCommunityCards() {
    final cards = <Widget>[
      _channelCard(
        Icons.play_circle_fill_rounded,
        'YouTube',
        '@orqube',
        () => openExternalUrl(OrqubePublicContentConfig.youtubeChannelUrl),
      ),
      _channelCard(
        Icons.alternate_email_rounded,
        'X',
        '@orqubic',
        () => openExternalUrl(OrqubePublicContentConfig.xProfileUrl),
      ),
      _channelCard(
        Icons.groups_2_rounded,
        'NAVER CAFE',
        OrqubePublicContentConfig.naverCafeUrl.isEmpty
            ? _t(
              ko: '공식 커뮤니티',
              en: 'Official community',
              ja: '公式コミュニティ',
              zh: '官方社区',
              fr: 'Communauté officielle',
              pt: 'Comunidade oficial',
            )
            : OrqubePublicContentConfig.naverCafeUrl,
        OrqubePublicContentConfig.naverCafeUrl.isEmpty
            ? null
            : () => openExternalUrl(OrqubePublicContentConfig.naverCafeUrl),
      ),
    ];
    return LayoutBuilder(
      builder: (_, constraints) {
        final mobile = constraints.maxWidth < 680;
        return GridView.count(
          crossAxisCount: mobile ? 1 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: mobile ? 3.1 : 2.0,
          children: cards,
        );
      },
    );
  }

  Widget _naverCafeLatestPosts() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection(OrqubePublicContentConfig.cafePostsCollection)
              .snapshots(),
      builder: (context, snapshot) {
        final docs =
            (snapshot.data?.docs ?? const [])
                .where((d) => d.data()['enabled'] != false)
                .toList()
              ..sort((a, b) {
                final aData = a.data();
                final bData = b.data();

                final aOrder = (aData['sortOrder'] as num?)?.toInt();
                final bOrder = (bData['sortOrder'] as num?)?.toInt();
                if (aOrder != null && bOrder != null && aOrder != bOrder) {
                  return aOrder.compareTo(bOrder);
                }
                if (aOrder != null && bOrder == null) return -1;
                if (aOrder == null && bOrder != null) return 1;

                DateTime? readTime(Map<String, dynamic> data) {
                  final raw = data['publishedAt'] ?? data['discoveredAt'];
                  if (raw is Timestamp) return raw.toDate();
                  return null;
                }

                final aTime = readTime(aData);
                final bTime = readTime(bData);
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });

        if (docs.isEmpty) return _cafeFeedFallback();
        final visible = docs.take(6).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 680;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mobile ? 1 : 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: mobile ? 2.35 : 2.6,
              ),
              itemBuilder: (context, index) {
                final data = visible[index].data();
                final title = '${data['title'] ?? ''}'.trim();
                final summary = '${data['summary'] ?? ''}'.trim();
                final url = '${data['url'] ?? ''}'.trim();
                return InkWell(
                  onTap: url.isEmpty ? null : () => openExternalUrl(url),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xCC0B1020),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.forum_rounded, color: _lime, size: 19),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'NAVER CAFE',
                                style: TextStyle(
                                  color: _lime,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.open_in_new_rounded,
                              color: Colors.white38,
                              size: 17,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title.isEmpty ? 'NAVER CAFE' : title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (summary.isNotEmpty) ...[
                          const SizedBox(height: 7),
                          Expanded(
                            child: Text(
                              summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ] else
                          const Spacer(),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _cafeFeedFallback() {
    return InkWell(
      onTap: () => openExternalUrl(OrqubePublicContentConfig.naverCafeUrl),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xCC0B1020),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _violet.withOpacity(.28)),
        ),
        child: const Row(
          children: [
            Icon(Icons.groups_2_rounded, color: _lime, size: 36),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '대한민국 특전사 NAVER CAFE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '최신 글 연동 전에도 카페로 바로 이동할 수 있습니다.',
                    style: TextStyle(color: Colors.white60, height: 1.4),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: _lime),
          ],
        ),
      ),
    );
  }

  Widget _channelCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xCC0B1020),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _purple.withOpacity(.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _lime),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              onTap == null
                  ? Icons.settings_rounded
                  : Icons.open_in_new_rounded,
              color: Colors.white38,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  Widget _blockchainInfoPanel() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection(OrqubePublicContentConfig.publicConfigCollection)
              .doc(OrqubePublicContentConfig.blockchainDocument)
              .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? const <String, dynamic>{};
        final holders = '${data['holderCount'] ?? '--'}';
        final transfers = '${data['transferCount'] ?? '--'}';
        final network =
            '${data['network'] ?? OrqubePublicContentConfig.network}'.trim();
        final contract =
            '${data['contractAddress'] ?? OrqubePublicContentConfig.tokenContractAddress}'
                .trim();
        final explorer =
            '${data['explorerUrl'] ?? OrqubePublicContentConfig.blockExplorerBaseUrl}'
                .trim();

        final items = <Widget>[
          _chainMetric('Token Name', OrqubePublicContentConfig.tokenName),
          _chainMetric(
            'Maximum Supply',
            OrqubePublicContentConfig.maximumSupply,
          ),
          _chainMetric('Holders', holders),
          _chainMetric('Transfers', transfers),
          _chainMetric('Network', network.isEmpty ? '--' : network),
          _chainMetric(
            'Block Explorer',
            explorer.isEmpty ? '--' : explorer,
            onTap: explorer.isEmpty ? null : () => openExternalUrl(explorer),
          ),
        ];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xDD08101B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _cyan.withOpacity(.28)),
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (_, constraints) {
                  final mobile = constraints.maxWidth < 680;
                  return GridView.count(
                    crossAxisCount: mobile ? 2 : 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: mobile ? 1.65 : 2.7,
                    children: items,
                  );
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final mobile = constraints.maxWidth < 620;
                    final addressText = Text(
                      contract.isEmpty
                          ? 'Contract Address: --'
                          : 'Contract Address: $contract',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                      ),
                    );
                    final copyButton = OutlinedButton.icon(
                      onPressed:
                          contract.isEmpty
                              ? null
                              : () async {
                                await Clipboard.setData(
                                  ClipboardData(text: contract),
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Contract address copied.'),
                                  ),
                                );
                              },
                      icon: const Icon(Icons.copy_rounded, size: 17),
                      label: const Text('COPY'),
                    );
                    return mobile
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            addressText,
                            const SizedBox(height: 10),
                            copyButton,
                          ],
                        )
                        : Row(
                          children: [
                            Expanded(child: addressText),
                            const SizedBox(width: 12),
                            copyButton,
                          ],
                        );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chainMetric(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.035),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
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
            onPressed: _openHelpCenter,
            child: const Text('FAQ & HELP'),
          ),
          TextButton(onPressed: _openDashboard, child: const Text('DASHBOARD')),
          TextButton(
            onPressed: _openMarketingCenter,
            child: const Text('ADVERTISE'),
          ),
          TextButton(onPressed: _openAdmin, child: const Text('ADMIN')),
          TextButton(
            onPressed: _openWhitepaper,
            child: const Text('WHITEPAPER'),
          ),
        ],
      ),
    );
  }

  Widget _section({Key? key, required Widget child, bool darker = false}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 108),
      color: darker ? Colors.black.withOpacity(.16) : Colors.transparent,
      child: Center(child: child),
    );
  }

  Widget _storyBlock({
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
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width < 600 ? 20 : 24,
        vertical: MediaQuery.sizeOf(context).width < 600 ? 68 : 104,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: LayoutBuilder(
            builder: (_, constraints) {
              final narrow = constraints.maxWidth < 860;
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
                      fontSize: narrow ? _mobileTitleSize(39, ratio: .76) : 54,
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
                      fontSize:
                          MediaQuery.sizeOf(context).width < 600 ? 15.5 : 18,
                      height:
                          MediaQuery.sizeOf(context).width < 600 ? 1.55 : 1.75,
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                final scale = 1 + (_pulseController.value * .055);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 206,
                    height: 206,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _purple.withOpacity(.56),
                          _purple.withOpacity(.035),
                        ],
                      ),
                      border: Border.all(
                        color: _violet.withOpacity(.72),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withOpacity(.35),
                          blurRadius: 62,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: _lime, size: 80),
                  ),
                );
              },
            ),
            Positioned(
              left: 24,
              top: 20,
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white.withOpacity(.13),
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
          style: TextStyle(
            color: Colors.white,
            fontSize: _mobileTitleSize(48, ratio: .68),
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
            fontSize: MediaQuery.sizeOf(context).width < 600 ? 15.5 : 17,
            height: MediaQuery.sizeOf(context).width < 600 ? 1.5 : 1.6,
          ),
        ),
      ],
    );
  }

  Widget _valueCard(IconData icon, String title, String body, Color accent) {
    return _glass(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 21 : 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width < 600 ? 52 : 58,
            height: MediaQuery.sizeOf(context).width < 600 ? 52 : 58,
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
              fontSize: 18,
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
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 21 : 24),
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
          const SizedBox(height: 27),
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
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.30),
            blurRadius: 30,
            offset: const Offset(0, 17),
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

class _AnimatedSpacePainter extends CustomPainter {
  final double progress;

  _AnimatedSpacePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final isMobile = size.width <= 600;
    final center = Offset(size.width * .5, size.height * .5);
    final diagonal = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    void paintLayer({
      required int seed,
      required int count,
      required double rotationTurns,
      required double minRadius,
      required double maxRadius,
      required double opacity,
      required double drift,
    }) {
      final random = math.Random(seed);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(progress * math.pi * 2 * rotationTurns);
      canvas.translate(-center.dx, -center.dy);

      for (var i = 0; i < count; i++) {
        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;
        final phase = random.nextDouble() * math.pi * 2;
        final twinkle =
            .25 +
            .75 *
                ((math.sin(
                          progress * math.pi * 2 * (1.1 + i % 4 * .25) + phase,
                        ) +
                        1) /
                    2);
        final pulse = .82 + .38 * twinkle;
        // V22.15: keep the same star animation while reducing visible star size by 65%.
        final r =
            (minRadius + random.nextDouble() * (maxRadius - minRadius)) *
            pulse *
            .35;
        final dx = math.sin(progress * math.pi * 2 + phase) * drift;
        final dy = math.cos(progress * math.pi * 2 * .7 + phase) * drift;
        final point = Offset(x + dx, y + dy);

        final glow =
            Paint()
              ..color = Colors.white.withOpacity(
                opacity * twinkle * (isMobile ? .12 : .24),
              )
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                r * (isMobile ? 1.25 : 2.4),
              );
        canvas.drawCircle(point, r * (isMobile ? 1.25 : 1.85), glow);

        final core =
            Paint()
              ..color = Colors.white.withOpacity(
                opacity * (.45 + .55 * twinkle),
              );
        canvas.drawCircle(point, r, core);

        if (!isMobile && r > 2.15 && i % 3 == 0) {
          final sparkle =
              Paint()
                ..color = const Color(
                  0xFFD7FF35,
                ).withOpacity(.30 + .60 * twinkle)
                ..strokeWidth = math.max(.75, r * .34)
                ..strokeCap = StrokeCap.round;
          canvas.drawLine(
            Offset(point.dx - r * 3.0, point.dy),
            Offset(point.dx + r * 3.0, point.dy),
            sparkle,
          );
          canvas.drawLine(
            Offset(point.dx, point.dy - r * 3.0),
            Offset(point.dx, point.dy + r * 3.0),
            sparkle,
          );
        }
      }
      canvas.restore();
    }

    paintLayer(
      seed: 17072026,
      count: isMobile ? 82 : 128,
      rotationTurns: .20,
      minRadius: isMobile ? .42 : 1.05,
      maxRadius: isMobile ? .95 : 2.35,
      opacity: isMobile ? .54 : .72,
      drift: isMobile ? 3.5 : 7.0,
    );
    paintLayer(
      seed: 19072026,
      count: isMobile ? 42 : 72,
      rotationTurns: -.31,
      minRadius: isMobile ? .58 : 1.45,
      maxRadius: isMobile ? 1.25 : 3.15,
      opacity: isMobile ? .62 : .86,
      drift: isMobile ? 5.0 : 11.0,
    );
    paintLayer(
      seed: 23072026,
      count: isMobile ? 12 : 30,
      rotationTurns: .48,
      minRadius: isMobile ? .78 : 2.05,
      maxRadius: isMobile ? 1.65 : 4.25,
      opacity: isMobile ? .68 : .96,
      drift: isMobile ? 7.0 : 16.0,
    );

    // Occasional meteor streaks add motion without overwhelming the hero copy.
    for (var i = 0; i < (isMobile ? 2 : 3); i++) {
      final local = (progress + i * .37) % 1.0;
      if (local < .22) {
        final t = local / .22;
        final startX = size.width * (.12 + i * .31);
        final startY = size.height * (.10 + i * .13);
        final head = Offset(
          startX + diagonal * .26 * t,
          startY + diagonal * .12 * t,
        );
        final tail = Offset(
          head.dx - (isMobile ? 62 : 95),
          head.dy - (isMobile ? 28 : 42),
        );
        final meteor =
            Paint()
              ..shader = LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF55E6FF).withOpacity(.72 * (1 - t * .45)),
                  Colors.white.withOpacity(.96 * (1 - t * .55)),
                ],
              ).createShader(Rect.fromPoints(tail, head))
              ..strokeWidth = isMobile ? 1.25 : 2.2
              ..strokeCap = StrokeCap.round;
        canvas.drawLine(tail, head, meteor);
      }
    }

    final glowPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF8B2CF6).withOpacity(.13),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .72, size.height * .24),
              radius: size.width * .34,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * .72, size.height * .24),
      size.width * .34,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AnimatedSpacePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF8B2CF6).withOpacity(.14)
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
