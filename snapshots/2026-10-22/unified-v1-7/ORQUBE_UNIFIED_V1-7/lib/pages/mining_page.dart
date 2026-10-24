import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MiningPage extends StatefulWidget {
  final String language;

  const MiningPage({super.key, this.language = 'ko'});

  @override
  State<MiningPage> createState() => _MiningPageState();
}

class _MiningPageState extends State<MiningPage> {
  bool loading = false;
  bool miningActive = false;

  String language = 'ko';

  int points = 0;
  int attendanceCount = 0;
  int referralCount = 0;
  double orbs = 0.0;

  String nickname = 'ORQUBE Player';
  String walletStatus = '지갑 미설정';
  String walletAddress = '미설정';

  Timer? miningTimer;

  final Map<String, Map<String, String>> t = {
    'ko': {
      'lang': '🇰🇷 한국어',
      'welcome': 'Welcome,',
      'level': 'LV.1 PIONEER',
      'balance': 'ORBS BALANCE',
      'mining': 'MINING',
      'todayMining': 'TODAY MINING',
      'completed': 'COMPLETED',
      'startMining': '오늘의 채굴 시작',
      'miningDone': '오늘의 채굴 완료!',
      'adReward': '광고 보고 보상 받기',
      'wallet': 'WALLET',
      'nft': 'NFT COLLECTION',
      'profile': 'PROFILE',
      'attendance': 'ATTENDANCE',
      'referral': 'REFERRAL',
      'ranking': 'RANKING',
      'news': 'ORQUBE NEWS',
    },
    'en': {
      'lang': '🇺🇸 English',
      'welcome': 'Welcome,',
      'level': 'LV.1 PIONEER',
      'balance': 'ORBS BALANCE',
      'mining': 'MINING',
      'todayMining': 'TODAY MINING',
      'completed': 'COMPLETED',
      'startMining': 'Start Today Mining',
      'miningDone': 'Today Mining Complete!',
      'adReward': 'Watch Ad Reward',
      'wallet': 'WALLET',
      'nft': 'NFT COLLECTION',
      'profile': 'PROFILE',
      'attendance': 'ATTENDANCE',
      'referral': 'REFERRAL',
      'ranking': 'RANKING',
      'news': 'ORQUBE NEWS',
    },
    'ja': {
      'lang': '🇯🇵 日本語',
      'welcome': 'ようこそ,',
      'level': 'LV.1 PIONEER',
      'balance': 'ORBS 残高',
      'mining': 'マイニング',
      'todayMining': '本日の採掘',
      'completed': '完了',
      'startMining': '今日の採掘開始',
      'miningDone': '本日の採掘完了!',
      'adReward': '広告を見て報酬',
      'wallet': 'ウォレット',
      'nft': 'NFT コレクション',
      'profile': 'プロフィール',
      'attendance': '出席',
      'referral': '紹介',
      'ranking': 'ランキング',
      'news': 'ORQUBE ニュース',
    },
    'zh': {
      'lang': '🇨🇳 中文',
      'welcome': '欢迎,',
      'level': 'LV.1 PIONEER',
      'balance': 'ORBS 余额',
      'mining': '挖矿',
      'todayMining': '今日挖矿',
      'completed': '完成',
      'startMining': '开始今日挖矿',
      'miningDone': '今日挖矿完成!',
      'adReward': '观看广告奖励',
      'wallet': '钱包',
      'nft': 'NFT 收藏',
      'profile': '个人资料',
      'attendance': '签到',
      'referral': '推荐',
      'ranking': '排名',
      'news': 'ORQUBE 新闻',
    },
    'vi': {
      'lang': '🇻🇳 Tiếng Việt',
      'welcome': 'Chào mừng,',
      'level': 'LV.1 PIONEER',
      'balance': 'SỐ DƯ ORBS',
      'mining': 'KHAI THÁC',
      'todayMining': 'HÔM NAY',
      'completed': 'HOÀN TẤT',
      'startMining': 'Bắt đầu khai thác',
      'miningDone': 'Đã khai thác hôm nay!',
      'adReward': 'Xem quảng cáo nhận thưởng',
      'wallet': 'VÍ',
      'nft': 'BỘ SƯU TẬP NFT',
      'profile': 'HỒ SƠ',
      'attendance': 'ĐIỂM DANH',
      'referral': 'GIỚI THIỆU',
      'ranking': 'XẾP HẠNG',
      'news': 'TIN ORQUBE',
    },
    'th': {
      'lang': '🇹🇭 ภาษาไทย',
      'welcome': 'ยินดีต้อนรับ,',
      'level': 'LV.1 PIONEER',
      'balance': 'ยอด ORBS',
      'mining': 'ขุด',
      'todayMining': 'วันนี้',
      'completed': 'เสร็จแล้ว',
      'startMining': 'เริ่มขุดวันนี้',
      'miningDone': 'ขุดวันนี้สำเร็จ!',
      'adReward': 'ดูโฆษณารับรางวัล',
      'wallet': 'กระเป๋า',
      'nft': 'คอลเลกชัน NFT',
      'profile': 'โปรไฟล์',
      'attendance': 'เช็คอิน',
      'referral': 'แนะนำ',
      'ranking': 'อันดับ',
      'news': 'ข่าว ORQUBE',
    },
  };

  String tr(String key) => t[language]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    language = widget.language;
    loadUserData();
  }

  String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    setState(() {
      nickname = data['nickname'] ?? 'ORQUBE Player';
      points = data['points'] ?? 0;
      attendanceCount = data['attendanceCount'] ?? 0;
      referralCount = data['referralCount'] ?? 0;
      walletStatus = data['walletStatus'] ?? '지갑 미설정';
      walletAddress = data['walletAddress'] ?? '미설정';
      orbs = points / 10;
    });
  }

  Future<void> startMining() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => loading = true);

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final doc = await userRef.get();
    final data = doc.data() ?? {};
    final lastMiningDate = data['lastMiningDate'] ?? '';

    if (lastMiningDate == todayKey()) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('오늘은 이미 채굴했습니다.')));
      return;
    }

    final newPoints = points + 20;
    final newAttendance = attendanceCount + 1;

    await userRef.set({
      'points': newPoints,
      'orbs': newPoints / 10,
      'attendanceCount': newAttendance,
      'lastMiningDate': todayKey(),
      'lastMiningAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      points = newPoints;
      orbs = newPoints / 10;
      attendanceCount = newAttendance;
      miningActive = true;
      loading = false;
    });

    miningTimer?.cancel();
    miningTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
      if (!mounted) return;
      setState(() => orbs += 0.001);

      if (timer.tick >= 25) {
        timer.cancel();
        setState(() => miningActive = false);
      }
    });
  }

  Future<void> rewardAdTest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newPoints = points + 10;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'points': newPoints,
      'orbs': newPoints / 10,
      'lastAdRewardAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      points = newPoints;
      orbs = newPoints / 10;
    });
  }

  @override
  void dispose() {
    miningTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03030A),
      body: Stack(
        children: [
          galaxyBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
              child: Column(
                children: [
                  topBar(),
                  const SizedBox(height: 20),
                  userAndBalance(),
                  const SizedBox(height: 28),
                  miningCore(),
                  const SizedBox(height: 24),
                  actionButtons(),
                  const SizedBox(height: 20),
                  featureGrid(),
                  const SizedBox(height: 20),
                  newsSection(),
                ],
              ),
            ),
          ),
          bottomNav(),
        ],
      ),
    );
  }

  Widget galaxyBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.4,
          colors: [Color(0xFF321063), Color(0xFF090018), Color(0xFF03030A)],
        ),
      ),
      child: CustomPaint(painter: StarPainter(), child: Container()),
    );
  }

  Widget topBar() {
    return Row(
      children: [
        languageDropdown(),
        const Spacer(),
        logoHeader(),
        const Spacer(),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.notifications_none, color: Colors.white),
        ),
      ],
    );
  }

  Widget languageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8B2CF6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF111122),
          value: language,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items:
              t.keys.map((code) {
                return DropdownMenuItem(
                  value: code,
                  child: Text(t[code]!['lang']!),
                );
              }).toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() => language = v);
          },
        ),
      ),
    );
  }

  Widget logoHeader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/orqube_plane_logo.png',
            width: 62,
            height: 62,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B2CF6), Color(0xFFD7FF35)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'O',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ORQUBE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            Text(
              'AIRSOFT & WEB3 ECOSYSTEM',
              style: TextStyle(
                color: Color(0xFFD7FF35),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget userAndBalance() {
    return Row(
      children: [
        Expanded(
          child: glassCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFF8B2CF6),
                  child: Icon(
                    Icons.military_tech,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('welcome'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        nickname,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD7FF35),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        tr('level'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('balance'),
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.diamond,
                      color: Color(0xFFB56CFF),
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      orbs.toStringAsFixed(3),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Text(
                  '≈ $points Points',
                  style: const TextStyle(color: Color(0xFFD7FF35)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget miningCore() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: miningActive ? 330 : 300,
          height: miningActive ? 330 : 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFB56CFF), Color(0xFF7C2CFF), Color(0xFF120022)],
            ),
            border: Border.all(
              color: const Color(0xFFD7FF35),
              width: miningActive ? 6 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9B35FF).withOpacity(0.65),
                blurRadius: miningActive ? 80 : 45,
                spreadRadius: miningActive ? 16 : 8,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                top: 34,
                child: Text(
                  'ORQUBE MINING',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const Icon(
                Icons.flight_takeoff,
                color: Colors.white24,
                size: 130,
              ),
              const Text(
                'O',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 92,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Positioned(
                bottom: 58,
                child: Text(
                  tr('mining'),
                  style: const TextStyle(
                    color: Color(0xFFD7FF35),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget actionButtons() {
    return Row(
      children: [
        Expanded(
          child: glowButton(
            icon: Icons.flash_on,
            title: tr('startMining'),
            subtitle: '+20 Points',
            color: const Color(0xFF9B35FF),
            onTap: loading ? null : startMining,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: glowButton(
            icon: Icons.play_circle_outline,
            title: tr('adReward'),
            subtitle: '+10P',
            color: const Color(0xFFD7FF35),
            onTap: rewardAdTest,
          ),
        ),
      ],
    );
  }

  Widget featureGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: featureCard(
                Icons.account_balance_wallet,
                tr('wallet'),
                walletStatus,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: featureCard(Icons.hexagon_outlined, tr('nft'), '3 Items'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: featureCard(Icons.person, tr('profile'), tr('level')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: featureCard(
                Icons.event_available,
                tr('attendance'),
                '$attendanceCount Days',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: featureCard(
                Icons.groups,
                tr('referral'),
                '$referralCount Users',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: featureCard(Icons.emoji_events, tr('ranking'), '-'),
            ),
          ],
        ),
      ],
    );
  }

  Widget newsSection() {
    return glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('news'),
            style: const TextStyle(
              color: Color(0xFFB56CFF),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: newsCard('공지사항', 'ORQUBE 정식 서비스 오픈을 준비 중입니다.')),
              const SizedBox(width: 10),
              Expanded(child: newsCard('이벤트', '출석 이벤트와 광고 보상이 준비됩니다.')),
              const SizedBox(width: 10),
              Expanded(child: newsCard('AIRSOFT', '에어소프트 커뮤니티 업데이트 예정')),
            ],
          ),
        ],
      ),
    );
  }

  Widget glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101024).withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8B2CF6).withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B2CF6).withOpacity(0.18),
            blurRadius: 24,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget glowButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color, width: 1.4),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.28), blurRadius: 22),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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

  Widget featureCard(IconData icon, String title, String value) {
    return glassCard(
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB56CFF), size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFB56CFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }

  Widget newsCard(String tag, String text) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: const TextStyle(
              color: Color(0xFFD7FF35),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget bottomNav() {
    return Positioned(
      left: 18,
      right: 18,
      bottom: 16,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: const Color(0xFF070712).withOpacity(0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomItem(icon: Icons.home, label: 'HOME'),
            BottomItem(icon: Icons.radar, label: 'MINING', active: true),
            BottomItem(icon: Icons.account_balance_wallet, label: 'WALLET'),
            BottomItem(icon: Icons.groups, label: 'COMMUNITY'),
            BottomItem(icon: Icons.person, label: 'PROFILE'),
          ],
        ),
      ),
    );
  }
}

class BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const BottomItem({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? const Color(0xFFD7FF35) : Colors.white60),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFFD7FF35) : Colors.white60,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.35);

    for (int i = 0; i < 90; i++) {
      final x = (i * 47) % size.width;
      final y = (i * 83) % size.height;
      canvas.drawCircle(Offset(x, y), i % 3 == 0 ? 1.3 : 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
