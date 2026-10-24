import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class AppColors {
  static const bg = Color(0xFFF7FAFF);
  static const navy = Color(0xFF102A43);
  static const purple = Color(0xFF7C3AED);
  static const deepPurple = Color(0xFF2E1065);
  static const sky = Color(0xFFDDF4FF);
  static const pink = Color(0xFFFFD6E8);
  static const mint = Color(0xFFDDFCE7);
  static const yellow = Color(0xFFFFF3B0);

  // 채굴 화면 전용 색상
  static const miningBg = Color(0xFF050510);
  static const miningPurple = Color(0xFF9B35FF);
  static const miningDeepPurple = Color(0xFF5B12D6);
  static const miningLime = Color(0xFFD7FF35);
  static const miningGold = Color(0xFFFFD447);
}

class AppAssets {
  static const logo = 'assets/images/orqube_logo.png';

  // 선택 사항입니다. 이 이미지가 없으면 자동으로 검정/보라 배경으로 표시됩니다.
  // 올려주신 군인/나비 배경 이미지를 쓰려면 아래 파일명으로 저장하세요.
  static const miningBg = 'assets/images/mining_bg.png';

  static const nfts = [
    'assets/images/nft5.png',
    'assets/images/orqube_logo.png',
    'assets/images/orqube_logo2.png',
    'assets/images/orqube_logo3.png',
    'assets/images/nft5.png',
  ];
}

class UserProfile {
  String nickname;
  String country;
  String team;
  String role;
  String bio;
  int points;
  int orbs;
  int nftCount;
  String selectedNft;
  int attendanceCount;
  int referralCount;

  UserProfile({
    required this.nickname,
    required this.country,
    required this.team,
    required this.role,
    required this.bio,
    required this.selectedNft,
    this.points = 1250,
    this.orbs = 125,
    this.nftCount = 5,
    this.attendanceCount = 12,
    this.referralCount = 5,
  });
}

class T {
  static String get(String lang, String key) {
    final ko = {
      'join': '가입',
      'login': '로그인',
      'startMining': '채굴 시작하기',
      'heroTitle': 'Orqube Military Networking',
      'heroSub': 'NFT, 채굴, 에어소프트, 커뮤니티, 광고 보상을 연결하는 AI/Web3 플랫폼',
      'coreTitle': 'ORQUBE 핵심 기능',
      'coreSub': '채굴처럼 쉽고 보고 누르고, 참여할 수 있는 구조입니다.',
      'gallerySub': '저장된 Orqube NFT 이미지를 홈페이지 핵심 이미지로 사용합니다.',
      'walletTitle': 'ORQUBE 지갑 설정',
      'walletSub': '기존 Kaia 지갑을 연결하거나 새 ORQUBE 지갑을 생성하세요.',
      'connectWallet': '기존 Kaia 지갑 연결',
      'createWallet': '새 ORQUBE 지갑 생성',
      'later': '나중에 설정',
      'dashboard': '대시보드',
      'profile': '프로필',
      'community': '커뮤니티',
      'ranking': '랭킹',
      'convert': '포인트 → ORBS 전환',
    };

    final en = {
      'join': 'Join',
      'login': 'Login',
      'startMining': 'Start Mining',
      'heroTitle': 'Orqube Military Networking',
      'heroSub':
          'AI/Web3 platform connecting NFT, mining, airsoft, community, and ads rewards',
      'coreTitle': 'ORQUBE Core Features',
      'coreSub':
          'Simple structure for viewing, clicking, mining, and participating.',
      'gallerySub': 'Saved ORQUBE NFT images are used as core visuals.',
      'walletTitle': 'ORQUBE Wallet Setup',
      'walletSub': 'Connect Kaia Wallet or create ORQUBE Wallet.',
      'connectWallet': 'Connect Kaia Wallet',
      'createWallet': 'Create ORQUBE Wallet',
      'later': 'Later',
      'dashboard': 'Dashboard',
      'profile': 'Profile',
      'community': 'Community',
      'ranking': 'Ranking',
      'convert': 'Convert Points',
    };

    return (lang == 'ko' ? ko : en)[key] ?? key;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String language = 'ko';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ORQUBE',
      debugShowCheckedModeBanner: false,
      home: HomePage(
        language: language,
        onLanguageChanged: (v) => setState(() => language = v),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String language;
  final Function(String) onLanguageChanged;

  const HomePage({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  String tr(String key) => T.get(language, key);

  void goLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginPage(language: language)),
    );
  }

  // 홈 화면은 그대로 두고, 채굴 시작하기 버튼만 새 채굴 화면으로 연결합니다.
  void goMiningDemo(BuildContext context) {
    final profile = UserProfile(
      nickname: 'OrqubeUser',
      country: 'Korea',
      team: 'ORQUBE Alpha',
      role: 'Rifleman',
      bio: 'ORQUBE 초기 멤버입니다.',
      selectedNft: AppAssets.nfts[0],
      points: 1250,
      orbs: 125,
      attendanceCount: 12,
      referralCount: 5,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MiningPage(
          language: language,
          walletStatus: '기존 Kaia 지갑 연결 예정',
          walletAddress: '0xKaiaWallet...',
          profile: profile,
        ),
      ),
    );
  }

  Widget languageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButton<String>(
        value: language,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(value: 'ko', child: Text('🇰🇷 한국어')),
          DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
          DropdownMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
          DropdownMenuItem(value: 'ja', child: Text('🇯🇵 日本語')),
          DropdownMenuItem(value: 'zh', child: Text('🇨🇳 中文')),
          DropdownMenuItem(value: 'pt', child: Text('🇵🇹 Português')),
        ],
        onChanged: (v) {
          if (v != null) onLanguageChanged(v);
        },
      ),
    );
  }

  Widget assetImage(String path, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: width,
          height: height,
          color: Colors.white.withOpacity(0.35),
          child: const Icon(Icons.image, size: 55, color: AppColors.deepPurple),
        ),
      ),
    );
  }

  Widget teaserVideoBox() {
    return Container(
      width: 620,
      height: 230,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(0.18),
        border: Border.all(color: Colors.white.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.purple,
            child: Icon(Icons.play_arrow, color: Colors.white, size: 44),
          ),
          SizedBox(height: 18),
          Text(
            '45초 티저 영상 자리',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '추후 Canva, CapCut, Clipchamp 영상 삽입 예정',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget featureCard(IconData icon, String title, String body, Color color) {
    return Container(
      width: 260,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: AppColors.navy),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget nftGallery() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (int i = 0; i < AppAssets.nfts.length; i++)
          Container(
            width: 150,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                assetImage(AppAssets.nfts[i], 130, 145),
                const SizedBox(height: 8),
                Text(
                  'ORQUBE NFT #${i + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget sectionTitle(String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 20),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.navy),
          ),
        ],
      ),
    );
  }

  Widget footerColumn(String title, List<String> items) {
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $item'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = [
      'Blockchain',
      'Mining',
      'NFT',
      'Kaia Wallet',
      'Airsoft League',
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF5E8FF),
                    Color(0xFFE7C8FF),
                    Color(0xFFB56CFF),
                    Color(0xFF7C3AED),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppAssets.logo,
                          width: 36,
                          height: 36,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.hexagon,
                            color: AppColors.purple,
                            size: 34,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Orqube',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'serif',
                          ),
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 16,
                          children: [
                            for (final item in menu)
                              InkWell(
                                onTap: () {
                                  if (item == 'Mining') goMiningDemo(context);
                                },
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        languageDropdown(),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => goLogin(context),
                          child: Text(tr('join')),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => goLogin(context),
                          child: Text(tr('login')),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 55),
                  Text(
                    tr('heroTitle'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr('heroSub'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.navy, fontSize: 18),
                  ),
                  const SizedBox(height: 26),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 34,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () => goMiningDemo(context),
                    child: Text(
                      tr('startMining'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 28),
                  teaserVideoBox(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
            sectionTitle(tr('coreTitle'), tr('coreSub')),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                featureCard(
                  Icons.generating_tokens,
                  'ORBS Mining',
                  'Mining / Attendance / Referral / Ads',
                  AppColors.sky,
                ),
                featureCard(
                  Icons.image,
                  'NFT Profile',
                  'NFT Profile / Player Card / Ranking',
                  AppColors.pink,
                ),
                featureCard(
                  Icons.sports_esports,
                  'Airsoft League',
                  'Team Matching / League / National Match',
                  AppColors.mint,
                ),
                featureCard(
                  Icons.account_balance_wallet,
                  'Kaia Wallet',
                  'Wallet / ORBS / NFT Storage',
                  AppColors.yellow,
                ),
              ],
            ),
            sectionTitle('ORQUBE NFT Gallery', tr('gallerySub')),
            nftGallery(),
            sectionTitle('확장 예정 공간', '게임, 토론장, 후원 광고 기능을 단계적으로 연결합니다.'),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                featureCard(
                  Icons.sports_esports,
                  'Game Introduction',
                  'Future TPS airsoft game introduction area',
                  AppColors.sky,
                ),
                featureCard(
                  Icons.forum,
                  'Debate Forum',
                  'Country / Region / Policy Community',
                  AppColors.pink,
                ),
                featureCard(
                  Icons.handshake,
                  'Sponsors',
                  'Sponsors / Partners / Advertisers',
                  AppColors.mint,
                ),
              ],
            ),
            const SizedBox(height: 55),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 90,
                runSpacing: 30,
                children: [
                  footerColumn('기능', [
                    '회원가입',
                    'ORBS 채굴',
                    'NFT 프로필',
                    '에어소프트 리그',
                    '팀 매칭',
                    '광고 보상',
                  ]),
                  footerColumn('회사 소개', [
                    'Orqube 소개',
                    '뉴스룸',
                    '이벤트',
                    '파트너십',
                    '사회적 영향',
                  ]),
                  footerColumn('도움말', [
                    '고객센터',
                    '보안',
                    'Kaia Wallet',
                    'OpenSea NFT',
                    '사이트맵',
                  ]),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              color: AppColors.deepPurple,
              child: const Text(
                'ORBS / ORQUBE © 2026\nAirsoft Web3 Community Platform',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final String language;

  const LoginPage({super.key, required this.language});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final smsController = TextEditingController();

  String verificationId = '';
  bool get isKo => widget.language == 'ko';

  void message(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void goWalletSetup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WalletSetupPage(language: widget.language),
      ),
    );
  }

  Future<void> createUserProfile(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'email': user.email ?? '',
        'nickname': user.email?.split('@').first ?? 'ORQUBE Player',
        'country': 'Korea',
        'team': 'ORQUBE Alpha',
        'role': 'Rifleman',
        'bio': 'ORQUBE 초기 멤버입니다.',
        'points': 1250,
        'orbs': 125,
        'nftCount': 5,
        'selectedNft': AppAssets.nfts[0],
        'attendanceCount': 12,
        'referralCount': 5,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> emailSignUp() async {
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = result.user;
      if (user != null) await createUserProfile(user);
      goWalletSetup();
    } catch (e) {
      message('회원가입 오류: $e');
    }
  }

  Future<void> emailLogin() async {
    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = result.user;
      if (user != null) await createUserProfile(user);
      goWalletSetup();
    } catch (e) {
      message('로그인 오류: $e');
    }
  }

  Future<void> googleLogin() async {
    try {
      final user = await GoogleSignIn().signIn();
      if (user == null) return;

      final auth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = result.user;

      if (firebaseUser != null) await createUserProfile(firebaseUser);
      goWalletSetup();
    } catch (e) {
      message('구글 로그인 오류: $e');
    }
  }

  Future<void> sendSmsCode() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneController.text.trim(),
        verificationCompleted: (credential) async {
          final result = await FirebaseAuth.instance.signInWithCredential(
            credential,
          );
          final user = result.user;
          if (user != null) await createUserProfile(user);
          goWalletSetup();
        },
        verificationFailed: (e) => message('SMS 오류: ${e.message}'),
        codeSent: (verId, token) {
          setState(() => verificationId = verId);
          message('SMS 코드가 전송되었습니다.');
        },
        codeAutoRetrievalTimeout: (verId) => verificationId = verId,
      );
    } catch (e) {
      message('SMS 전송 오류: $e');
    }
  }

  Future<void> verifySmsCode() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsController.text.trim(),
      );
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = result.user;

      if (user != null) await createUserProfile(user);
      goWalletSetup();
    } catch (e) {
      message('SMS 인증 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('ORQUBE')),
      body: Center(
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, color: AppColors.purple, size: 64),
              const SizedBox(height: 12),
              Text(
                isKo ? 'ORQUBE 회원가입 / 로그인' : 'ORQUBE Sign Up / Login',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: emailSignUp,
                      child: Text(isKo ? '이메일 가입' : 'Sign Up'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: emailLogin,
                      child: Text(isKo ? '이메일 로그인' : 'Login'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: googleLogin,
                icon: const Icon(Icons.g_mobiledata),
                label: Text(isKo ? '구글 계정으로 계속하기' : 'Continue with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletSetupPage extends StatefulWidget {
  final String language;

  const WalletSetupPage({super.key, required this.language});

  @override
  State<WalletSetupPage> createState() => _WalletSetupPageState();
}

class _WalletSetupPageState extends State<WalletSetupPage> {
  String walletStatus = '미설정';
  String walletAddress = '';

  String tr(String key) => T.get(widget.language, key);

  void goDashboard() {
    final profile = UserProfile(
      nickname: FirebaseAuth.instance.currentUser?.email?.split('@').first ??
          'ORQUBE Player',
      country: 'Korea',
      team: 'ORQUBE Alpha',
      role: 'Rifleman',
      bio: 'ORQUBE 초기 멤버입니다.',
      selectedNft: AppAssets.nfts[0],
      points: 1250,
      orbs: 125,
      attendanceCount: 12,
      referralCount: 5,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MiningPage(
          language: widget.language,
          walletStatus: walletStatus,
          walletAddress: walletAddress,
          profile: profile,
        ),
      ),
    );
  }

  void connectKaiaWallet() {
    setState(() {
      walletStatus = '기존 Kaia 지갑 연결 예정';
      walletAddress = '0xKaiaWallet...';
    });
  }

  void createOrqubeWallet() {
    setState(() {
      walletStatus = '새 ORQUBE 지갑 생성 예정';
      walletAddress = '0xOrqubeWallet...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(tr('walletTitle')),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 560,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: AppColors.purple,
              ),
              const SizedBox(height: 18),
              Text(
                tr('walletTitle'),
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(tr('walletSub'), textAlign: TextAlign.center),
              const SizedBox(height: 26),
              ElevatedButton.icon(
                onPressed: connectKaiaWallet,
                icon: const Icon(Icons.link),
                label: Text(tr('connectWallet')),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: createOrqubeWallet,
                icon: const Icon(Icons.add),
                label: Text(tr('createWallet')),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: goDashboard,
                icon: const Icon(Icons.skip_next),
                label: Text(tr('later')),
              ),
              const SizedBox(height: 20),
              Text('Wallet Status: $walletStatus'),
              Text('Address: $walletAddress'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: goDashboard,
                child: const Text('Dashboard 이동'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiningPage extends StatefulWidget {
  final String language;
  final String walletStatus;
  final String walletAddress;
  final UserProfile profile;

  const MiningPage({
    super.key,
    required this.language,
    required this.profile,
    this.walletStatus = '미설정',
    this.walletAddress = '',
  });

  @override
  State<MiningPage> createState() => _MiningPageState();
}

class _MiningPageState extends State<MiningPage> {
  int selectedIndex = 0;
  bool minedToday = false;

  String tr(String key) => T.get(widget.language, key);

  String get pointText {
    return '${widget.profile.points.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
        )}P';
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void dailyMining() {
    if (minedToday) {
      showMessage('오늘은 이미 채굴했습니다. 내일 다시 시도하세요.');
      return;
    }

    setState(() {
      widget.profile.points += 10;
      widget.profile.orbs = widget.profile.points ~/ 10;
      widget.profile.attendanceCount += 1;
      minedToday = true;
    });

    showMessage('채굴 완료! +10P 지급되었습니다.');
  }

  void reward(String name, int amount) {
    setState(() {
      widget.profile.points += amount;
      widget.profile.orbs = widget.profile.points ~/ 10;
      if (name.contains('출석')) widget.profile.attendanceCount++;
      if (name.contains('친구')) widget.profile.referralCount++;
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    if (!mounted) return;
    Navigator.pop(context);
  }

  BoxDecoration glassBox({double radius = 20}) {
    return BoxDecoration(
      color: Colors.black.withOpacity(0.42),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withOpacity(0.14)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget logoImage(double size) {
    return Image.asset(
      AppAssets.logo,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Icon(
        Icons.flight_takeoff,
        color: Colors.white,
        size: size * 0.75,
      ),
    );
  }

  Widget backgroundLayer() {
    return Positioned.fill(
      child: Image.asset(
        AppAssets.miningBg,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF050510),
                Color(0xFF090018),
                Color(0xFF160032),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget topProfileCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: glassBox(radius: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '내 포인트',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                pointText,
                style: const TextStyle(
                  color: AppColors.miningPurple,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.black54,
            child: ClipOval(child: logoImage(48)),
          ),
          const SizedBox(width: 8),
          Text(
            widget.profile.nickname.isEmpty ? 'OrqubeUser' : widget.profile.nickname,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        ],
      ),
    );
  }

  Widget topBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoImage(82),
        const SizedBox(width: 14),
        const Text(
          'ORQUBE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        topProfileCard(),
        IconButton(
          tooltip: '로그아웃',
          onPressed: logout,
          icon: const Icon(Icons.logout, color: Colors.white70),
        ),
      ],
    );
  }

  Widget heroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'DAILY MINING',
          style: TextStyle(
            color: AppColors.miningPurple,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 18),
        Text(
          '하루 한 번,\nORQUBE 채굴',
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
        ),
        SizedBox(height: 18),
        Text(
          '매일 1회 채굴을 통해\nORQUBE 포인트를 획득하세요.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget timeCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: glassBox(),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppColors.miningPurple, size: 48),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '다음 채굴 가능 시간',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  minedToday ? '내일 00:00 가능' : '지금 채굴 가능',
                  style: const TextStyle(
                    color: AppColors.miningPurple,
                    fontSize: 25,
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

  Widget miningCircle() {
    return GestureDetector(
      onTap: dailyMining,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xFF1A102A), Color(0xFF030308)],
          ),
          border: Border.all(color: AppColors.miningPurple, width: 7),
          boxShadow: [
            BoxShadow(
              color: AppColors.miningPurple.withOpacity(0.75),
              blurRadius: 32,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logoImage(82),
            const SizedBox(height: 8),
            const Text(
              'ORBS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 54,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              minedToday ? 'MINED TODAY' : 'START MINING',
              style: const TextStyle(
                color: AppColors.miningPurple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget startMiningButton() {
    return SizedBox(
      width: 410,
      height: 76,
      child: ElevatedButton.icon(
        onPressed: dailyMining,
        icon: const Icon(Icons.generating_tokens, size: 34),
        label: Text(
          minedToday ? '오늘 채굴 완료' : '오늘의 채굴 시작',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: minedToday ? Colors.grey.shade800 : AppColors.miningDeepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.miningPurple),
          ),
        ),
      ),
    );
  }

  Widget rewardItem(IconData icon, Color color, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget rewardPanel() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: glassBox(),
      child: Column(
        children: [
          rewardItem(Icons.flash_on, AppColors.miningGold, 'DAILY REWARD', '+10P'),
          divider(),
          rewardItem(Icons.sync, AppColors.miningPurple, 'MINING CYCLE', '24 HOURS'),
          divider(),
          InkWell(
            onTap: () => showMessage('NFT PROFILE 기능은 곧 연결됩니다.'),
            child: rewardItem(Icons.image, AppColors.miningPurple, 'NFT PROFILE', 'COMING SOON'),
          ),
          divider(),
          InkWell(
            onTap: () => showMessage('ORBS 전환 기능은 곧 연결됩니다.'),
            child: rewardItem(Icons.autorenew, AppColors.miningLime, 'ORBS CONVERT', 'SOON'),
          ),
        ],
      ),
    );
  }

  Widget miningContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 850;

        final center = Column(
          children: [
            miningCircle(),
            const SizedBox(height: 24),
            startMiningButton(),
            const SizedBox(height: 12),
            const Text(
              '매일 00:00 (KST)에 채굴 상태가 초기화됩니다.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: timeCard()),
              const SizedBox(width: 28),
              Expanded(flex: 2, child: center),
              const SizedBox(width: 28),
              Expanded(child: rewardPanel()),
            ],
          );
        }

        return Column(
          children: [
            timeCard(),
            const SizedBox(height: 22),
            center,
            const SizedBox(height: 22),
            rewardPanel(),
          ],
        );
      },
    );
  }

  Widget walletCard() {
    final status = widget.walletStatus == '미설정' ? '기존 Kaia 지갑 연결 예정' : widget.walletStatus;
    final address = widget.walletAddress.isEmpty ? '0xKaiaWallet...' : widget.walletAddress;

    return InkWell(
      onTap: () => showMessage('Kaia Wallet 연결 기능은 곧 연결됩니다.'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.42),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.miningLime.withOpacity(0.85)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: AppColors.miningLime,
              size: 56,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KAIA WALLET',
                    style: TextStyle(
                      color: AppColors.miningLime,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status,
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    address,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.miningLime, size: 46),
          ],
        ),
      ),
    );
  }

  Widget infoBox(IconData icon, Color color, String title, String value) {
    return InkWell(
      onTap: () => showMessage('$title 기능은 곧 연결됩니다.'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: glassBox(),
        child: Row(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
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

  Widget infoPanel() {
    final items = [
      infoBox(Icons.stars, AppColors.miningGold, '포인트', pointText),
      infoBox(Icons.hexagon, AppColors.miningPurple, 'ORBS', '${widget.profile.orbs} ORBS'),
      infoBox(Icons.calendar_month, AppColors.miningPurple, '출석체크', '${widget.profile.attendanceCount} 회'),
      infoBox(Icons.groups, AppColors.miningPurple, '친구초대', '${widget.profile.referralCount} 명'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: glassBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('내 정보', style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;

              if (isWide) {
                return Row(
                  children: items
                      .map(
                        (e) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: e,
                          ),
                        ),
                      )
                      .toList(),
                );
              }

              return Column(
                children: items
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: e,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget bottomNav() {
    final items = [
      {'label': tr('dashboard'), 'icon': Icons.home},
      {'label': tr('profile'), 'icon': Icons.person_outline},
      {'label': tr('community'), 'icon': Icons.groups_outlined},
      {'label': tr('ranking'), 'icon': Icons.emoji_events_outlined},
    ];

    return Container(
      decoration: glassBox(),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = selectedIndex == index;
          final label = items[index]['label'] as String;
          final icon = items[index]['icon'] as IconData;

          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() => selectedIndex = index);
                if (index != 0) showMessage('$label 기능은 곧 연결됩니다.');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: selected ? AppColors.miningPurple.withOpacity(0.18) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: selected ? AppColors.miningPurple : Colors.white60,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? AppColors.miningPurple : Colors.white70,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget divider() {
    return Divider(color: Colors.white.withOpacity(0.16), height: 18);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.miningBg,
      body: SafeArea(
        child: Stack(
          children: [
            backgroundLayer(),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.62))),
            SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  topBar(),
                  const SizedBox(height: 42),
                  heroText(),
                  const SizedBox(height: 34),
                  miningContent(),
                  const SizedBox(height: 28),
                  walletCard(),
                  const SizedBox(height: 28),
                  infoPanel(),
                  const SizedBox(height: 28),
                  bottomNav(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
