import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'airsoft_hub_page.dart';

class MobileDashboardPage extends StatefulWidget {
  const MobileDashboardPage({super.key});

  @override
  State<MobileDashboardPage> createState() => _MobileDashboardPageState();
}

class _MobileDashboardPageState extends State<MobileDashboardPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  static const Color _bg = Color(0xFF03040B);
  static const Color _panel = Color(0xFF0A0B18);
  static const Color _panel2 = Color(0xFF111329);
  static const Color _purple = Color(0xFF8B2CF6);
  static const Color _lime = Color(0xFFD7FF35);
  static const Color _cyan = Color(0xFF39D9FF);
  static const Color _muted = Color(0xFF98A0B8);

  /// 광고 확인용 테스트 모드입니다.
  /// true  = 1분 채굴 + 초기화 버튼 표시
  /// false = 실제 24시간 채굴 + 초기화 버튼 숨김
  static const bool _adMiningTestMode = true;

  static const Duration _productionMiningDuration = Duration(hours: 24);
  static const Duration _testMiningDuration = Duration(minutes: 1);
  static const double _orbsPerHour = 0.5;

  Duration get _miningDuration =>
      _adMiningTestMode ? _testMiningDuration : _productionMiningDuration;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final AnimationController _ringController;
  late final AnimationController _pulseController;
  late final AnimationController _logoController;

  Timer? _clockTimer;
  Timer? _saveTimer;
  RewardedAd? _rewardedAd;

  bool _rewardedAdReady = false;
  bool _rewardedAdLoading = false;
  bool _loading = true;
  bool _saving = false;
  bool _miningActive = false;
  bool _dailyClaimed = false;
  bool _resettingTest = false;

  int _selectedIndex = 0;
  int _points = 1260;
  int _attendance = 12;
  int _referralCount = 5;
  int _nftCount = 3;
  int _level = 15;

  String _nickname = '김명근';
  String _rank = 'PIONEER';
  String _walletAddress = '0xKaia...8f3d';

  double _storedOrbs = 125.0000;
  DateTime? _miningStartedAt;
  DateTime? _miningEndsAt;
  DateTime? _lastDailyRewardAt;
  DateTime _now = DateTime.now();

  User? get _user => _auth.currentUser;

  String get _miningPeriodLabel => _adMiningTestMode ? '1분 테스트' : '24시간';

  double get _sessionMinedOrbs {
    if (!_miningActive || _miningStartedAt == null || _miningEndsAt == null) {
      return 0;
    }
    final effectiveNow = _now.isAfter(_miningEndsAt!) ? _miningEndsAt! : _now;
    final elapsed = effectiveNow.difference(_miningStartedAt!);
    if (elapsed.isNegative) return 0;
    return elapsed.inMilliseconds /
        const Duration(hours: 1).inMilliseconds *
        _orbsPerHour;
  }

  double get _displayOrbs => _storedOrbs + _sessionMinedOrbs;

  Duration get _remaining {
    if (!_miningActive || _miningEndsAt == null) return Duration.zero;
    final value = _miningEndsAt!.difference(_now);
    return value.isNegative ? Duration.zero : value;
  }

  double get _progress {
    if (!_miningActive || _miningStartedAt == null) return 0;
    final elapsed = _now.difference(_miningStartedAt!);
    return (elapsed.inMilliseconds / _miningDuration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    _startTimers();
    if (!kIsWeb) {
      await MobileAds.instance.initialize();
      _loadRewardedAd();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _startTimers() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());

      if (_miningActive &&
          _miningEndsAt != null &&
          !_now.isBefore(_miningEndsAt!)) {
        _completeMining();
      }
    });

    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveUserData(),
    );
  }

  Future<void> _loadUserData() async {
    final user = _user;
    if (user == null) return;

    try {
      final ref = _firestore.collection('users').doc(user.uid);
      final snapshot = await ref.get();

      if (!snapshot.exists) {
        await ref.set({
          'email': user.email,
          'nickname':
              user.displayName?.trim().isNotEmpty == true
                  ? user.displayName
                  : _nickname,
          'level': _level,
          'rank': _rank,
          'points': _points,
          'orbs': _storedOrbs,
          'attendance': _attendance,
          'referralCount': _referralCount,
          'nftCount': _nftCount,
          'walletAddress': _walletAddress,
          'miningActive': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }

      final data = snapshot.data() ?? <String, dynamic>{};
      final startedAt = _toDateTime(data['miningStartedAt']);
      final endsAt = _toDateTime(data['miningEndsAt']);
      final lastDaily = _toDateTime(data['lastDailyRewardAt']);

      _nickname =
          (data['nickname'] as String?)?.trim().isNotEmpty == true
              ? data['nickname'] as String
              : (user.displayName ?? _nickname);
      _rank = data['rank'] as String? ?? _rank;
      _walletAddress = data['walletAddress'] as String? ?? _walletAddress;
      _level = _asInt(data['level'], _level);
      _points = _asInt(data['points'], _points);
      _attendance = _asInt(data['attendance'], _attendance);
      _referralCount = _asInt(data['referralCount'], _referralCount);
      _nftCount = _asInt(data['nftCount'], _nftCount);
      _storedOrbs = _asDouble(data['orbs'], _storedOrbs);
      _lastDailyRewardAt = lastDaily;
      _dailyClaimed = _isSameDay(lastDaily, DateTime.now());

      final wasActive = data['miningActive'] == true;
      if (wasActive && startedAt != null && endsAt != null) {
        if (DateTime.now().isBefore(endsAt)) {
          _miningActive = true;
          _miningStartedAt = startedAt;
          _miningEndsAt = endsAt;
        } else {
          final elapsed = endsAt.difference(startedAt);
          if (!elapsed.isNegative) {
            _storedOrbs +=
                elapsed.inMilliseconds /
                const Duration(hours: 1).inMilliseconds *
                _orbsPerHour;
          }
          _miningActive = false;
          _miningStartedAt = null;
          _miningEndsAt = null;
          await _saveUserData();
        }
      }
    } catch (e) {
      debugPrint('Load user data error: $e');
    }
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  double _asDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return fallback;
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _saveUserData() async {
    if (_saving) return;
    final user = _user;
    if (user == null) return;

    _saving = true;
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'nickname': _nickname,
        'level': _level,
        'rank': _rank,
        'points': _points,
        'orbs': _storedOrbs,
        'attendance': _attendance,
        'referralCount': _referralCount,
        'nftCount': _nftCount,
        'walletAddress': _walletAddress,
        'miningActive': _miningActive,
        'miningStartedAt':
            _miningStartedAt == null
                ? null
                : Timestamp.fromDate(_miningStartedAt!),
        'miningEndsAt':
            _miningEndsAt == null ? null : Timestamp.fromDate(_miningEndsAt!),
        'lastDailyRewardAt':
            _lastDailyRewardAt == null
                ? null
                : Timestamp.fromDate(_lastDailyRewardAt!),
        'miningTestMode': _adMiningTestMode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Save user data error: $e');
    } finally {
      _saving = false;
    }
  }

  Future<void> _completeMining() async {
    if (!_miningActive) return;

    final earned = _sessionMinedOrbs;
    setState(() {
      _storedOrbs += earned;
      _miningActive = false;
      _miningStartedAt = null;
      _miningEndsAt = null;
    });

    await _saveUserData();
    _showSnack('$_miningPeriodLabel 채굴 완료: +${earned.toStringAsFixed(4)} ORBS');
  }

  void _loadRewardedAd() {
    if (kIsWeb || _rewardedAdLoading || _rewardedAdReady) return;

    _rewardedAdLoading = true;
    RewardedAd.load(
      adUnitId:
          defaultTargetPlatform == TargetPlatform.iOS
              ? 'ca-app-pub-3940256099942544/1712485313'
              : 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd?.dispose();
          _rewardedAd = ad;
          _rewardedAdReady = true;
          _rewardedAdLoading = false;
          if (mounted) setState(() {});
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad load failed: $error');
          _rewardedAd = null;
          _rewardedAdReady = false;
          _rewardedAdLoading = false;
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Future<void> _handleMiningButton() async {
    if (_miningActive) {
      _showSnack('현재 $_miningPeriodLabel 채굴 중입니다.');
      return;
    }

    if (kIsWeb) {
      _showSnack('Chrome에서는 AdMob 대신 채굴 흐름만 테스트합니다.');
      _startMining();
      return;
    }

    if (!_rewardedAdReady || _rewardedAd == null) {
      _showSnack('광고를 준비 중입니다. 잠시 후 다시 눌러주세요.');
      _loadRewardedAd();
      return;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;
    _rewardedAdReady = false;
    bool rewardGranted = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (rewardGranted) {
          _startMining();
        } else {
          _showSnack('광고를 끝까지 시청해야 채굴이 시작됩니다.');
        }
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _showSnack('광고 실행에 실패했습니다.');
        _loadRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: (_, reward) {
        rewardGranted = true;
      },
    );
  }

  void _startMining() {
    final now = DateTime.now();
    setState(() {
      _now = now;
      _miningActive = true;
      _miningStartedAt = now;
      _miningEndsAt = now.add(_miningDuration);
    });
    _saveUserData();
    _showSnack('$_miningPeriodLabel 채굴을 시작했습니다.');
  }

  Future<void> _resetMiningForAdTest() async {
    if (!_adMiningTestMode || _resettingTest) return;

    setState(() => _resettingTest = true);
    try {
      final earned = _sessionMinedOrbs;

      setState(() {
        // 이미 발생한 테스트 채굴량은 잃지 않도록 잔액에 반영합니다.
        _storedOrbs += earned;
        _miningActive = false;
        _miningStartedAt = null;
        _miningEndsAt = null;
        _now = DateTime.now();
      });

      await _saveUserData();

      if (!kIsWeb && !_rewardedAdReady) {
        _loadRewardedAd();
      }

      _showSnack('채굴 테스트 초기화 완료. 채굴 시작을 눌러 광고를 확인하세요.');
    } finally {
      if (mounted) setState(() => _resettingTest = false);
    }
  }

  Future<void> _claimDailyReward() async {
    if (_dailyClaimed) {
      _showSnack('오늘의 보상은 이미 받았습니다.');
      return;
    }

    setState(() {
      _dailyClaimed = true;
      _lastDailyRewardAt = DateTime.now();
      _points += 20;
      _storedOrbs += 0.0200;
      _attendance += 1;
    });

    await _saveUserData();
    _showSnack('일일 보상: +20P, +0.0200 ORBS');
  }

  Future<void> _logout() async {
    await _saveUserData();
    await _auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _panel2,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _saveUserData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    _saveTimer?.cancel();
    _rewardedAd?.dispose();
    _ringController.dispose();
    _pulseController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _lime)),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(),
            _buildSimplePage(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Wallet',
              description: 'Kaia 지갑 연결 및 ORBS 보유량 관리',
            ),
            _buildSimplePage(
              icon: Icons.groups_rounded,
              title: 'Community',
              description: 'ORQUBE 커뮤니티 기능 준비 중',
            ),
            AirsoftHubPage(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      color: _lime,
      backgroundColor: _panel,
      onRefresh: _loadUserData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildUserSummary(),
                const SizedBox(height: 16),
                _buildMiningCard(),
                const SizedBox(height: 16),
                _buildRewardButtons(),
                const SizedBox(height: 16),
                _buildStatsGrid(),
                const SizedBox(height: 16),
                _buildAirsoftHubCard(),
                const SizedBox(height: 16),
                _buildTeaserCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
      child: Row(
        children: [
          RotationTransition(
            turns: _logoController,
            child: _buildPlaneLogo(size: 46),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ORQUBE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  _adMiningTestMode
                      ? 'V14 AD TEST · 1 MIN'
                      : 'V14 MOBILE MINING',
                  style: const TextStyle(
                    color: _lime,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaneLogo({double size = 56}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_purple, Color(0xFF4318A8)],
        ),
        border: Border.all(color: _lime.withOpacity(0.7), width: 1.5),
      ),
      child: Icon(Icons.flight_rounded, color: Colors.white, size: size * 0.52),
    );
  }

  Widget _buildUserSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: _purple.withOpacity(0.22),
            child: Text(
              _nickname.isNotEmpty ? _nickname.substring(0, 1) : 'O',
              style: const TextStyle(
                color: _lime,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $_nickname',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LV.$_level  ·  $_rank',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: _lime.withOpacity(0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _lime.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'ORBS BALANCE',
                  style: TextStyle(color: _muted, fontSize: 9),
                ),
                const SizedBox(height: 3),
                Text(
                  _displayOrbs.toStringAsFixed(4),
                  style: const TextStyle(
                    color: _lime,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiningCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: _panelDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111329), Color(0xFF090A16)],
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: AnimatedBuilder(
              animation: Listenable.merge([_ringController, _pulseController]),
              builder: (context, _) {
                return CustomPaint(
                  painter: _MiningRingPainter(
                    progress: _progress,
                    rotation: _ringController.value,
                    pulse: _pulseController.value,
                    active: _miningActive,
                    purple: _purple,
                    lime: _lime,
                    cyan: _cyan,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 1 + (_pulseController.value * 0.04),
                          child: _buildPlaneLogo(size: 70),
                        ),
                        const SizedBox(height: 13),
                        Text(
                          _miningActive ? 'MINING ACTIVE' : 'READY TO MINE',
                          style: TextStyle(
                            color: _miningActive ? _lime : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDuration(_remaining),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${_sessionMinedOrbs.toStringAsFixed(4)} ORBS',
                          style: const TextStyle(
                            color: _cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _handleMiningButton,
              icon: Icon(
                _miningActive
                    ? Icons.hourglass_top_rounded
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                _miningActive
                    ? '$_miningPeriodLabel MINING IN PROGRESS'
                    : kIsWeb
                    ? 'START TEST MINING'
                    : _rewardedAdReady
                    ? 'WATCH AD & START MINING'
                    : 'PREPARING REWARD AD...',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _miningActive ? _panel2 : _lime,
                foregroundColor:
                    _miningActive ? Colors.white70 : const Color(0xFF10120A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (_adMiningTestMode) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: _resettingTest ? null : _resetMiningForAdTest,
                icon:
                    _resettingTest
                        ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.restart_alt_rounded),
                label: const Text('광고 테스트용 채굴 초기화'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _cyan,
                  side: const BorderSide(color: _cyan),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            _adMiningTestMode
                ? '테스트 모드: 1분 후 자동 종료됩니다. 초기화 버튼으로 즉시 광고를 다시 확인할 수 있습니다.'
                : '채굴은 24시간 후 자동 종료되며 다시 시작 버튼을 눌러야 합니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.card_giftcard_rounded,
            title: _dailyClaimed ? 'Claimed Today' : 'Daily Reward',
            subtitle: '+20P · +0.0200',
            onTap: _claimDailyReward,
            accent: _lime,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: Icons.ondemand_video_rounded,
            title: 'Teaser Video',
            subtitle: 'ORQUBE Story',
            onTap: () => _showSnack('티저 영상 연결 준비 중입니다.'),
            accent: _cyan,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: _panelDecoration(),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _muted, fontSize: 10),
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

  Widget _buildStatsGrid() {
    final items = [
      (Icons.bolt_rounded, 'Points', '$_points', _lime),
      (Icons.calendar_month_rounded, 'Attendance', '$_attendance days', _cyan),
      (Icons.group_add_rounded, 'Referral', '$_referralCount friends', _purple),
      (
        Icons.collections_rounded,
        'NFT',
        '$_nftCount items',
        Colors.orangeAccent,
      ),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 98,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: _panelDecoration(),
          child: Row(
            children: [
              Icon(item.$1, color: item.$4, size: 26),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$2,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.$3,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAirsoftHubCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AirsoftHubPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _panelDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF25114A), Color(0xFF0C1730)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _lime.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _lime.withOpacity(0.35)),
              ),
              child: const Icon(
                Icons.sports_martial_arts_rounded,
                color: _lime,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AIRSOFT HUB',
                    style: TextStyle(
                      color: _lime,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '경기 · 지도 · 팀 · 업체 · 마켓',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '글로벌 에어소프트 대시보드로 이동',
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white54,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeaserCard() {
    return Container(
      height: 155,
      padding: const EdgeInsets.all(20),
      decoration: _panelDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF28105D), Color(0xFF0C1027)],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUILD THE ORQUBE',
            style: TextStyle(
              color: _lime,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'Airsoft · Community\nWeb3 · AI · Game',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Spacer(),
          Text(
            'www.orqubic.com',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePage({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: _panelDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _lime, size: 58),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, height: 1.5),
              ),
              const SizedBox(height: 18),
              Text(
                _walletAddress,
                style: const TextStyle(color: _cyan, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 120),
      children: [
        Center(child: _buildPlaneLogo(size: 84)),
        const SizedBox(height: 18),
        Center(
          child: Text(
            _nickname,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            _user?.email ?? '',
            style: const TextStyle(color: _muted),
          ),
        ),
        const SizedBox(height: 28),
        ListTile(
          tileColor: _panel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
          onTap: _logout,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (value) => setState(() => _selectedIndex = value),
      backgroundColor: _panel,
      indicatorColor: _purple.withOpacity(0.25),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_rounded, color: _muted),
          selectedIcon: Icon(Icons.home_rounded, color: _lime),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_rounded, color: _muted),
          selectedIcon: Icon(
            Icons.account_balance_wallet_rounded,
            color: _lime,
          ),
          label: 'Wallet',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_rounded, color: _muted),
          selectedIcon: Icon(Icons.groups_rounded, color: _lime),
          label: 'Community',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_rounded, color: _muted),
          selectedIcon: Icon(Icons.person_rounded, color: _lime),
          label: 'Profile',
        ),
      ],
    );
  }

  BoxDecoration _panelDecoration({Gradient? gradient}) {
    return BoxDecoration(
      color: gradient == null ? _panel : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _MiningRingPainter extends CustomPainter {
  const _MiningRingPainter({
    required this.progress,
    required this.rotation,
    required this.pulse,
    required this.active,
    required this.purple,
    required this.lime,
    required this.cyan,
  });

  final double progress;
  final double rotation;
  final double pulse;
  final bool active;
  final Color purple;
  final Color lime;
  final Color cyan;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 14;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = Colors.white.withOpacity(0.08),
    );

    final glowPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 11 + pulse * 1.5
          ..shader = SweepGradient(
            colors: [purple, cyan, lime, purple],
            transform: GradientRotation(rotation * math.pi * 2),
          ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweep =
        active ? math.pi * 2 * math.max(progress, 0.04) : math.pi * 0.48;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiningRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.pulse != pulse ||
        oldDelegate.active != active;
  }
}
