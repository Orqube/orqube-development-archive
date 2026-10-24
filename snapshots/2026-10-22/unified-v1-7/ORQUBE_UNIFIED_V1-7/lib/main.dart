import 'pages/mixed_debate_rooms_page.dart';
import 'services/firebase_service.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/orqube_v14_entry.dart';
import 'pages/mobile_dashboard_page.dart';
import 'pages/v17_web_home_page.dart';
import 'web_link.dart';
import 'utils/orqube_i18n.dart';
import 'services/visitor_analytics_service.dart';
import 'features/ai_launch/screens/qr_reward_claim_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  // Load the Korean-capable font before the first frame so Hangul is not
  // rendered as missing-glyph boxes while the web font is still loading.
  await GoogleFonts.pendingFonts(<TextStyle>[
    GoogleFonts.notoSansKr(),
    GoogleFonts.notoSansKr(fontWeight: FontWeight.w700),
    GoogleFonts.notoSansKr(fontWeight: FontWeight.w800),
    GoogleFonts.notoSansKr(fontWeight: FontWeight.w900),
  ]);

  unawaited(VisitorAnalyticsService.instance.start());

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

  static const miningBg = Color(0xFF050510);
  static const panel = Color(0xFF0A0B18);
  static const panel2 = Color(0xFF101124);
  static const violet = Color(0xFFA855F7);
  static const violet2 = Color(0xFF7C3AED);
  static const lime = Color(0xFFD7FF35);
  static const gold = Color(0xFFFFD447);
  static const emerald = Color(0xFF80FF4D);
}

class AppAssets {
  static const logo = 'assets/images/logo/orqube_plane_logo.png';
  static const logo2 = 'assets/images/orqube_logo2.png';
  static const logo3 = 'assets/images/orqube_logo3.png';

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
  static final Map<String, Map<String, String>> data = {
    'ko': {
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
      'mining': '채굴',
      'wallet': '지갑',
      'nft': 'NFT',
      'team': '팀',
      'profile': '프로필',
      'community': '커뮤니티',
      'bonus': '보너스',
      'history': '기록',
      'settings': '설정',
      'ranking': '랭킹',
      'dailyMining': 'DAILY MINING',
      'miningTitle': '하루 한 번,\nORQUBE 채굴',
      'miningSub': '매일 1회 채굴을 통해\nORQUBE 포인트를 획득하세요.',
      'myPoints': '내 포인트',
      'nextMiningTime': '다음 채굴 가능 시간',
      'miningNow': '채굴 중...',
      'startDailyMining': '오늘의 채굴 시작',
      'dailyReward': 'DAILY REWARD',
      'miningCycle': 'MINING CYCLE',
      'hours24': '24 HOURS',
      'nftProfile': 'NFT PROFILE',
      'comingSoon': 'COMING SOON',
      'orbsConvert': 'ORBS CONVERT',
      'soon': 'SOON',
      'totalMinedToday': '총 채굴량 (오늘)',
      'estimatedDailyMining': '예상 일일 채굴량',
      'miningStartTime': '채굴 시작 시간',
      'nextMiningAvailable': '다음 채굴 가능',
      'myMiningBoost': '내 채굴 부스트',
      'miningRate': '채굴률',
      'baseMiningRate': '기본 채굴률',
      'activeReferrals': '추천 활성 회원 (5명)',
      'teamBonus': '팀 조합 보너스 (완성)',
      'attendanceStreak': '출석 연속 (7일)',
      'finalMiningRate': '최종 채굴률',
      'myTeamStatus': '내 팀 현황',
      'viewDetails': '자세히 보기 〉',
      'activeMembers': '활성 회원   5 / 5',
      'inviteFriends': '친구 초대',
      'dailyCheckin': '출석 체크',
      'getBonus': '보너스 받기',
      'bonusCenter': '보너스 센터',
      'variousBenefits': '다양한 혜택',
      'miningHistory': '채굴 기록',
      'viewHistory': '내역 확인',
      'kaiaWallet': 'KAIA WALLET',
      'connected': '연결됨',
      'manageWallet': '지갑 관리',
      'adReward': '광고 시청 보상',
      'watchAd': '광고 보기',
      'topMiners': 'TOP MINERS',
      'more': '더 보기 〉',
      'whitepaper': 'ORQUBE\nWhitepaper',
      'viewNow': 'View Now  →',
      'kaiaWalletPlanned': '기존 Kaia 지갑 연결 예정',
      'orqubeWalletPlanned': '새 ORQUBE 지갑 생성 예정',
      'myInfo': '내 정보',
      'points': '포인트',
      'checkin': '출석체크',
      'invites': '친구초대',
      'logout': '로그아웃',
      'alreadyMined': '오늘은 이미 채굴했습니다. 내일 다시 시도하세요.',
      'miningComplete': '채굴 완료! +10P 지급되었습니다.',
      'featureSoon': '기능은 곧 연결됩니다.',
      'bonusGiven': '보상 지급',
      'earlyMember': 'ORQUBE 초기 멤버입니다.',
      'demoEnter': '테스트용 바로 입장',
      'goDashboard': 'Dashboard 이동',
    },
    'en': {
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
      'mining': 'Mining',
      'wallet': 'Wallet',
      'nft': 'NFT',
      'team': 'Team',
      'profile': 'Profile',
      'community': 'Community',
      'bonus': 'Bonus',
      'history': 'History',
      'settings': 'Settings',
      'ranking': 'Ranking',
      'dailyMining': 'DAILY MINING',
      'miningTitle': 'Once a Day,\nORQUBE Mining',
      'miningSub': 'Earn ORQUBE points\nthrough daily mining.',
      'myPoints': 'My Points',
      'nextMiningTime': 'Next Mining Time',
      'miningNow': 'Mining...',
      'startDailyMining': 'Start Daily Mining',
      'dailyReward': 'DAILY REWARD',
      'miningCycle': 'MINING CYCLE',
      'hours24': '24 HOURS',
      'nftProfile': 'NFT PROFILE',
      'comingSoon': 'COMING SOON',
      'orbsConvert': 'ORBS CONVERT',
      'soon': 'SOON',
      'totalMinedToday': 'Total Mined Today',
      'estimatedDailyMining': 'Estimated Daily Mining',
      'miningStartTime': 'Mining Start Time',
      'nextMiningAvailable': 'Next Mining Available',
      'myMiningBoost': 'My Mining Boost',
      'miningRate': 'Mining Rate',
      'baseMiningRate': 'Base Mining Rate',
      'activeReferrals': 'Active Referrals (5)',
      'teamBonus': 'Team Bonus (Completed)',
      'attendanceStreak': '7-Day Attendance Streak',
      'finalMiningRate': 'Final Mining Rate',
      'myTeamStatus': 'My Team Status',
      'viewDetails': 'View Details 〉',
      'activeMembers': 'Active Members   5 / 5',
      'inviteFriends': 'Invite Friends',
      'dailyCheckin': 'Daily Check-in',
      'getBonus': 'Get Bonus',
      'bonusCenter': 'Bonus Center',
      'variousBenefits': 'Various Benefits',
      'miningHistory': 'Mining History',
      'viewHistory': 'View History',
      'kaiaWallet': 'KAIA WALLET',
      'connected': 'Connected',
      'manageWallet': 'Manage Wallet',
      'adReward': 'Ad Watch Reward',
      'watchAd': 'Watch Ad',
      'topMiners': 'TOP MINERS',
      'more': 'More 〉',
      'whitepaper': 'ORQUBE\nWhitepaper',
      'viewNow': 'View Now  →',
      'kaiaWalletPlanned': 'Kaia Wallet connection planned',
      'orqubeWalletPlanned': 'New ORQUBE Wallet creation planned',
      'myInfo': 'My Info',
      'points': 'Points',
      'checkin': 'Check-in',
      'invites': 'Invites',
      'logout': 'Logout',
      'alreadyMined':
          'You have already mined today. Please try again tomorrow.',
      'miningComplete': 'Mining completed! +10P has been rewarded.',
      'featureSoon': 'feature will be connected soon.',
      'bonusGiven': 'rewarded',
      'earlyMember': 'ORQUBE early member.',
      'demoEnter': 'Enter Demo Mode',
      'goDashboard': 'Go to Dashboard',
    },
    'ja': {
      'join': '登録',
      'login': 'ログイン',
      'startMining': 'マイニング開始',
      'heroTitle': 'Orqube Military Networking',
      'heroSub': 'NFT、マイニング、エアソフト、コミュニティ、広告報酬をつなぐAI/Web3プラットフォーム',
      'coreTitle': 'ORQUBE 主な機能',
      'coreSub': '見る・押す・採掘する・参加する、シンプルな構造です。',
      'gallerySub': '保存されたORQUBE NFT画像を主要ビジュアルとして使用します。',
      'walletTitle': 'ORQUBE ウォレット設定',
      'walletSub': 'Kaiaウォレットを接続するか、新しいORQUBEウォレットを作成してください。',
      'connectWallet': 'Kaiaウォレット接続',
      'createWallet': 'ORQUBEウォレット作成',
      'later': '後で設定',
      'dashboard': 'ダッシュボード',
      'mining': '採掘',
      'wallet': 'ウォレット',
      'nft': 'NFT',
      'team': 'チーム',
      'profile': 'プロフィール',
      'community': 'コミュニティ',
      'bonus': 'ボーナス',
      'history': '履歴',
      'settings': '設定',
      'ranking': 'ランキング',
      'dailyMining': 'DAILY MINING',
      'miningTitle': '1日1回、\nORQUBE マイニング',
      'miningSub': '毎日1回のマイニングで\nORQUBEポイントを獲得しましょう。',
      'myPoints': 'マイポイント',
      'nextMiningTime': '次の採掘可能時間',
      'miningNow': '採掘中...',
      'startDailyMining': '今日の採掘開始',
      'dailyReward': 'DAILY REWARD',
      'miningCycle': 'MINING CYCLE',
      'hours24': '24 HOURS',
      'nftProfile': 'NFT PROFILE',
      'comingSoon': 'COMING SOON',
      'orbsConvert': 'ORBS CONVERT',
      'soon': 'SOON',
      'totalMinedToday': '本日の総採掘量',
      'estimatedDailyMining': '予想日次採掘量',
      'miningStartTime': '採掘開始時間',
      'nextMiningAvailable': '次回採掘可能',
      'myMiningBoost': 'マイ採掘ブースト',
      'miningRate': '採掘率',
      'baseMiningRate': '基本採掘率',
      'activeReferrals': '有効紹介メンバー（5名）',
      'teamBonus': 'チームボーナス（完成）',
      'attendanceStreak': '7日連続出席',
      'finalMiningRate': '最終採掘率',
      'myTeamStatus': 'マイチーム状況',
      'viewDetails': '詳細を見る 〉',
      'activeMembers': 'アクティブメンバー   5 / 5',
      'inviteFriends': '友達招待',
      'dailyCheckin': '出席チェック',
      'getBonus': 'ボーナス獲得',
      'bonusCenter': 'ボーナスセンター',
      'variousBenefits': '多様な特典',
      'miningHistory': '採掘履歴',
      'viewHistory': '履歴確認',
      'kaiaWallet': 'KAIA WALLET',
      'connected': '接続済み',
      'manageWallet': 'ウォレット管理',
      'adReward': '広告視聴報酬',
      'watchAd': '広告を見る',
      'topMiners': 'TOP MINERS',
      'more': 'もっと見る 〉',
      'whitepaper': 'ORQUBE\nWhitepaper',
      'viewNow': 'View Now  →',
      'kaiaWalletPlanned': 'Kaiaウォレット接続予定',
      'orqubeWalletPlanned': '新しいORQUBEウォレット作成予定',
      'myInfo': 'マイ情報',
      'points': 'ポイント',
      'checkin': '出席',
      'invites': '招待',
      'logout': 'ログアウト',
      'alreadyMined': '本日はすでに採掘しました。明日またお試しください。',
      'miningComplete': '採掘完了！+10Pが付与されました。',
      'featureSoon': '機能は近日接続予定です。',
      'bonusGiven': '報酬付与',
      'earlyMember': 'ORQUBE初期メンバーです。',
      'demoEnter': 'デモモードで入場',
      'goDashboard': 'ダッシュボードへ',
    },
    'zh': {
      'join': '注册',
      'login': '登录',
      'startMining': '开始挖矿',
      'heroTitle': 'Orqube Military Networking',
      'heroSub': '连接NFT、挖矿、Airsoft社区与广告奖励的AI/Web3平台',
      'coreTitle': 'ORQUBE 核心功能',
      'coreSub': '简单的浏览、点击、挖矿和参与结构。',
      'gallerySub': '保存的ORQUBE NFT图像将作为核心视觉使用。',
      'walletTitle': 'ORQUBE 钱包设置',
      'walletSub': '连接Kaia钱包或创建新的ORQUBE钱包。',
      'connectWallet': '连接Kaia钱包',
      'createWallet': '创建ORQUBE钱包',
      'later': '稍后设置',
      'dashboard': '仪表板',
      'mining': '挖矿',
      'wallet': '钱包',
      'nft': 'NFT',
      'team': '团队',
      'profile': '个人资料',
      'community': '社区',
      'bonus': '奖励',
      'history': '记录',
      'settings': '设置',
      'ranking': '排行榜',
      'dailyMining': 'DAILY MINING',
      'miningTitle': '每天一次，\nORQUBE 挖矿',
      'miningSub': '通过每日挖矿\n获得ORQUBE积分。',
      'myPoints': '我的积分',
      'nextMiningTime': '下次可挖矿时间',
      'miningNow': '挖矿中...',
      'startDailyMining': '开始今日挖矿',
      'dailyReward': 'DAILY REWARD',
      'miningCycle': 'MINING CYCLE',
      'hours24': '24 HOURS',
      'nftProfile': 'NFT PROFILE',
      'comingSoon': 'COMING SOON',
      'orbsConvert': 'ORBS CONVERT',
      'soon': 'SOON',
      'totalMinedToday': '今日总挖矿量',
      'estimatedDailyMining': '预计每日挖矿量',
      'miningStartTime': '挖矿开始时间',
      'nextMiningAvailable': '下次可挖矿',
      'myMiningBoost': '我的挖矿加成',
      'miningRate': '挖矿率',
      'baseMiningRate': '基础挖矿率',
      'activeReferrals': '有效推荐成员（5人）',
      'teamBonus': '团队组合奖励（完成）',
      'attendanceStreak': '连续签到（7天）',
      'finalMiningRate': '最终挖矿率',
      'myTeamStatus': '我的团队状态',
      'viewDetails': '查看详情 〉',
      'activeMembers': '活跃成员   5 / 5',
      'inviteFriends': '邀请好友',
      'dailyCheckin': '每日签到',
      'getBonus': '领取奖励',
      'bonusCenter': '奖励中心',
      'variousBenefits': '多种福利',
      'miningHistory': '挖矿记录',
      'viewHistory': '查看记录',
      'kaiaWallet': 'KAIA WALLET',
      'connected': '已连接',
      'manageWallet': '管理钱包',
      'adReward': '观看广告奖励',
      'watchAd': '观看广告',
      'topMiners': 'TOP MINERS',
      'more': '更多 〉',
      'whitepaper': 'ORQUBE\nWhitepaper',
      'viewNow': 'View Now  →',
      'kaiaWalletPlanned': '计划连接Kaia钱包',
      'orqubeWalletPlanned': '计划创建新ORQUBE钱包',
      'myInfo': '我的信息',
      'points': '积分',
      'checkin': '签到',
      'invites': '邀请',
      'logout': '退出',
      'alreadyMined': '今天已经挖矿。请明天再试。',
      'miningComplete': '挖矿完成！已获得+10P。',
      'featureSoon': '功能即将连接。',
      'bonusGiven': '奖励已发放',
      'earlyMember': 'ORQUBE早期成员。',
      'demoEnter': '进入演示模式',
      'goDashboard': '前往仪表板',
    },
    'fr': {
      'join': 'S’inscrire',
      'login': 'Connexion',
      'startMining': 'Démarrer le minage',
      'heroTitle': 'Orqube Military Networking',
      'heroSub':
          'Plateforme AI/Web3 reliant NFT, minage, airsoft, communauté et récompenses publicitaires',
      'coreTitle': 'Fonctions clés ORQUBE',
      'coreSub':
          'Une structure simple pour regarder, cliquer, miner et participer.',
      'gallerySub':
          'Les images NFT ORQUBE sauvegardées sont utilisées comme visuels principaux.',
      'walletTitle': 'Configuration du portefeuille ORQUBE',
      'walletSub': 'Connectez Kaia Wallet ou créez un portefeuille ORQUBE.',
      'connectWallet': 'Connecter Kaia Wallet',
      'createWallet': 'Créer un portefeuille ORQUBE',
      'later': 'Plus tard',
      'dashboard': 'Tableau',
      'mining': 'Minage',
      'wallet': 'Wallet',
      'nft': 'NFT',
      'team': 'Équipe',
      'profile': 'Profil',
      'community': 'Communauté',
      'bonus': 'Bonus',
      'history': 'Historique',
      'settings': 'Réglages',
      'ranking': 'Classement',
      'dailyMining': 'DAILY MINING',
      'miningTitle': 'Une fois par jour,\nminage ORQUBE',
      'miningSub': 'Gagnez des points ORQUBE\ngrâce au minage quotidien.',
      'myPoints': 'Mes points',
      'nextMiningTime': 'Prochain minage',
      'miningNow': 'Minage...',
      'startDailyMining': 'Démarrer le minage',
      'dailyReward': 'DAILY REWARD',
      'miningCycle': 'MINING CYCLE',
      'hours24': '24 HOURS',
      'nftProfile': 'NFT PROFILE',
      'comingSoon': 'COMING SOON',
      'orbsConvert': 'ORBS CONVERT',
      'soon': 'SOON',
      'totalMinedToday': 'Total miné aujourd’hui',
      'estimatedDailyMining': 'Minage quotidien estimé',
      'miningStartTime': 'Heure de début',
      'nextMiningAvailable': 'Prochain minage',
      'myMiningBoost': 'Mon boost',
      'miningRate': 'Taux de minage',
      'baseMiningRate': 'Taux de base',
      'activeReferrals': 'Parrainages actifs (5)',
      'teamBonus': 'Bonus équipe',
      'attendanceStreak': 'Série 7 jours',
      'finalMiningRate': 'Taux final',
      'myTeamStatus': 'Mon équipe',
      'viewDetails': 'Voir détails 〉',
      'activeMembers': 'Membres actifs   5 / 5',
      'inviteFriends': 'Inviter',
      'dailyCheckin': 'Check-in',
      'getBonus': 'Recevoir bonus',
      'bonusCenter': 'Centre bonus',
      'variousBenefits': 'Avantages',
      'miningHistory': 'Historique minage',
      'viewHistory': 'Voir historique',
      'kaiaWallet': 'KAIA WALLET',
      'connected': 'Connecté',
      'manageWallet': 'Gérer Wallet',
      'adReward': 'Récompense pub',
      'watchAd': 'Voir pub',
      'topMiners': 'TOP MINERS',
      'more': 'Plus 〉',
      'whitepaper': 'ORQUBE\nWhitepaper',
      'viewNow': 'View Now  →',
      'kaiaWalletPlanned': 'Connexion Kaia Wallet prévue',
      'orqubeWalletPlanned': 'Création ORQUBE Wallet prévue',
      'myInfo': 'Mes infos',
      'points': 'Points',
      'checkin': 'Check-in',
      'invites': 'Invitations',
      'logout': 'Déconnexion',
      'alreadyMined': 'Vous avez déjà miné aujourd’hui. Réessayez demain.',
      'miningComplete': 'Minage terminé ! +10P attribués.',
      'featureSoon': 'fonction bientôt disponible.',
      'bonusGiven': 'récompense attribuée',
      'earlyMember': 'Membre initial ORQUBE.',
      'demoEnter': 'Mode démo',
      'goDashboard': 'Aller au tableau',
    },
    'es': {
      'join': 'Unirse',
      'login': 'Iniciar sesión',
      'startMining': 'Comenzar minería',
      'heroTitle': 'Orqube Military Networking',
      'heroSub':
          'Plataforma AI/Web3 que conecta NFT, minería, airsoft, comunidad y recompensas por anuncios',
      'coreTitle': 'Funciones principales de ORQUBE',
      'coreSub':
          'Una estructura simple para ver, hacer clic, minar y participar.',
      'gallerySub':
          'Las imágenes NFT de ORQUBE guardadas se usan como elementos visuales principales.',
      'walletTitle': 'Configuración de ORQUBE Wallet',
      'walletSub': 'Conecta Kaia Wallet o crea una ORQUBE Wallet.',
      'connectWallet': 'Conectar Kaia Wallet',
      'createWallet': 'Crear ORQUBE Wallet',
      'later': 'Más tarde',
      'dashboard': 'Panel',
      'mining': 'Minería',
      'wallet': 'Wallet',
      'nft': 'NFT',
      'team': 'Equipo',
      'profile': 'Perfil',
      'community': 'Comunidad',
      'bonus': 'Bono',
      'history': 'Historial',
      'settings': 'Ajustes',
      'ranking': 'Ranking',
      'dailyMining': 'DAILY MINING',
      'miningTitle': 'Una vez al día,\nminería ORQUBE',
      'miningSub': 'Gana puntos ORQUBE\ncon la minería diaria.',
      'myPoints': 'Mis puntos',
      'nextMiningTime': 'Próxima minería',
      'miningNow': 'Minando...',
      'startDailyMining': 'Iniciar minería',
      'dailyReward': 'DAILY REWARD',
      'miningCycle': 'MINING CYCLE',
      'hours24': '24 HOURS',
      'nftProfile': 'NFT PROFILE',
      'comingSoon': 'COMING SOON',
      'orbsConvert': 'ORBS CONVERT',
      'soon': 'SOON',
      'totalMinedToday': 'Total minado hoy',
      'estimatedDailyMining': 'Minería diaria estimada',
      'miningStartTime': 'Hora de inicio',
      'nextMiningAvailable': 'Próxima minería',
      'myMiningBoost': 'Mi boost',
      'miningRate': 'Tasa de minería',
      'baseMiningRate': 'Tasa base',
      'activeReferrals': 'Referidos activos (5)',
      'teamBonus': 'Bono de equipo',
      'attendanceStreak': 'Racha 7 días',
      'finalMiningRate': 'Tasa final',
      'myTeamStatus': 'Mi equipo',
      'viewDetails': 'Ver detalles 〉',
      'activeMembers': 'Miembros activos   5 / 5',
      'inviteFriends': 'Invitar amigos',
      'dailyCheckin': 'Check-in diario',
      'getBonus': 'Recibir bono',
      'bonusCenter': 'Centro de bonos',
      'variousBenefits': 'Beneficios',
      'miningHistory': 'Historial',
      'viewHistory': 'Ver historial',
      'kaiaWallet': 'KAIA WALLET',
      'connected': 'Conectado',
      'manageWallet': 'Gestionar Wallet',
      'adReward': 'Recompensa anuncio',
      'watchAd': 'Ver anuncio',
      'topMiners': 'TOP MINERS',
      'more': 'Más 〉',
      'whitepaper': 'ORQUBE\nWhitepaper',
      'viewNow': 'View Now  →',
      'kaiaWalletPlanned': 'Conexión de Kaia Wallet planificada',
      'orqubeWalletPlanned': 'Creación de ORQUBE Wallet planificada',
      'myInfo': 'Mi información',
      'points': 'Puntos',
      'checkin': 'Check-in',
      'invites': 'Invitados',
      'logout': 'Cerrar sesión',
      'alreadyMined': 'Ya minaste hoy. Inténtalo de nuevo mañana.',
      'miningComplete': '¡Minería completada! +10P recompensados.',
      'featureSoon': 'función estará disponible pronto.',
      'bonusGiven': 'recompensa otorgada',
      'earlyMember': 'Miembro inicial de ORQUBE.',
      'demoEnter': 'Modo demo',
      'goDashboard': 'Ir al panel',
    },
  };

  static String get(String lang, String key) {
    return data[lang]?[key] ?? data['ko']?[key] ?? key;
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
      theme: ThemeData(
        useMaterial3: true,
        // Noto Sans KR contains Hangul glyphs. Only the font family is changed;
        // existing colors, sizes, weights, layout, functions, and routing remain intact.
        fontFamily: GoogleFonts.notoSansKr().fontFamily,
      ),
      // main.dart는 웹 전용 진입점입니다. V16 웹 홈을 실제 시작 화면으로 연결합니다.
      // 모바일 앱은 main_mobile.dart로 실행합니다.
      home: _initialHome(),
    );
  }

  Widget _initialHome() {
    // QR REWARD is a public deep-link entry. Resolve it before the normal web
    // home/login flow so a customer can claim without an ORQUBE sign-in.
    //
    // Supported forms:
    //   /reward?project=...&campaign=...              (existing printed QR)
    //   /?qr=reward&project=...&campaign=...          (preferred/new QR)
    //   /#/reward?project=...&campaign=...            (hash-style fallback)
    final debateRoom = kIsWeb ? Uri.base.queryParameters['debateRoom'] : null;
    if (debateRoom != null &&
        RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(debateRoom)) {
      return MixedDebateRoomsPage(
        initialRoomId: debateRoom,
        inviteToken: Uri.base.queryParameters['invite'],
      );
    }
    final qrTarget = kIsWeb ? _qrRewardTarget(Uri.base) : null;
    if (qrTarget != null) {
      return QrRewardClaimPage(projectId: qrTarget.$1, campaignId: qrTarget.$2);
    }

    return V17WebHomePage(
      language: language,
      onLanguageChanged: (v) {
        OrqubeI18n.setLanguage(v);
        setState(() => language = v);
      },
    );
  }

  (String, String)? _qrRewardTarget(Uri uri) {
    String normalizePath(String path) {
      if (path.length > 1 && path.endsWith('/')) {
        return path.substring(0, path.length - 1);
      }
      return path;
    }

    (String, String)? fromParts(String path, Map<String, String> query) {
      final normalizedPath = normalizePath(path);
      final project = (query['project'] ?? '').trim();
      if (project.isEmpty) return null;

      final isRewardPath = normalizedPath == '/reward';
      final isRewardQuery =
          (query['qr'] ?? '').toLowerCase() == 'reward' ||
          (query['qrReward'] ?? '').toLowerCase() == 'true' ||
          query.containsKey('campaign');
      if (!isRewardPath && !isRewardQuery) return null;

      final campaign = (query['campaign'] ?? 'default').trim();
      return (project, campaign.isEmpty ? 'default' : campaign);
    }

    final direct = fromParts(uri.path, uri.queryParameters);
    if (direct != null) return direct;

    // Some web hosts / scanners preserve Flutter-style deep links in #fragment.
    // Parse that form as well so old or externally transformed QR links do not
    // silently fall through to the ORQUBE home page.
    final fragment = uri.fragment.trim();
    if (fragment.isNotEmpty) {
      var value = fragment.startsWith('/') ? fragment : '/$fragment';
      try {
        final fragmentUri = Uri.parse(value);
        final parsed = fromParts(fragmentUri.path, fragmentUri.queryParameters);
        if (parsed != null) return parsed;
      } catch (_) {
        // Invalid fragments are ignored and normal home routing continues.
      }
    }

    return null;
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

  void goLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => LoginPage(
              onLoginSuccess: () async {
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OrqubeV14Entry()),
                );
              },
            ),
      ),
    );
  }

  void goDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrqubeV14Entry()),
    );
  }

  Widget glass({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xCC0B1020),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6D4AFF).withOpacity(.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget navButton(String text, VoidCallback onTap) => TextButton(
    onPressed: onTap,
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget feature(
    IconData icon,
    String title,
    String body,
    Color accent,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: 290,
      child: glass(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: accent.withOpacity(.18),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(color: Colors.white60, height: 1.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTap,
                child: const Text('Explore'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget adSlot(String label, {double height = 90}) => Container(
    height: height,
    width: double.infinity,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0x8011162A),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white12),
    ),
    child: Text(
      'AD  •  $label',
      style: const TextStyle(color: Colors.white38, letterSpacing: 1.4),
    ),
  );

  Widget social(String label, IconData icon, String url) => OutlinedButton.icon(
    onPressed: () => openExternalUrl(url),
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white70,
      side: const BorderSide(color: Colors.white24),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030611),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 760),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/background/orqube_dark_soldier.jpg',
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xE6030611),
                      Color(0xA8050715),
                      Color(0xE6030611),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 44,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            AppAssets.logo,
                            width: 54,
                            height: 54,
                            errorBuilder:
                                (_, __, ___) => const Icon(
                                  Icons.flight,
                                  color: Colors.white,
                                  size: 42,
                                ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'ORQUBE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          navButton('Home', () {}),
                          navButton('Services', () {}),
                          navButton('Airsoft Hub', () => goDashboard(context)),
                          navButton('NFT', () => goDashboard(context)),
                          navButton(
                            'Whitepaper',
                            () => openExternalUrl(
                              'assets/assets/docs/ORQUBE_Whitepaper_EN_2026.pdf',
                            ),
                          ),
                          navButton(
                            'Community',
                            () => openExternalUrl('https://t.me/orqubic7'),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: language,
                            dropdownColor: const Color(0xFF111827),
                            style: const TextStyle(color: Colors.white),
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'ko',
                                child: Text('🇰🇷 한국어'),
                              ),
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('🇺🇸 English'),
                              ),
                              DropdownMenuItem(
                                value: 'ja',
                                child: Text('🇯🇵 日本語'),
                              ),
                              DropdownMenuItem(
                                value: 'zh',
                                child: Text('🇨🇳 中文'),
                              ),
                              DropdownMenuItem(
                                value: 'fr',
                                child: Text('🇫🇷 Français'),
                              ),
                              DropdownMenuItem(
                                value: 'es',
                                child: Text('🇵🇹 Português'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) onLanguageChanged(v);
                            },
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () => goLogin(context),
                            child: const Text('Login'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => goLogin(context),
                            child: const Text('Join'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 95),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 690),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ORQUBE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 72,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const Text(
                                'AIRSOFT × BLOCKCHAIN × AI',
                                style: TextStyle(
                                  color: Color(0xFFB56BFF),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'A future-ready community and reward platform',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'ORQUBE connects community participation, digital identity, rewards, airsoft services and Web3 infrastructure in one coherent ecosystem.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Wrap(
                                spacing: 14,
                                runSpacing: 12,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => goLogin(context),
                                    icon: const Icon(Icons.rocket_launch),
                                    label: const Text('Get Started'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 17,
                                      ),
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed:
                                        () => openExternalUrl(
                                          'assets/assets/docs/ORQUBE_Whitepaper_EN_2026.pdf',
                                        ),
                                    icon: const Icon(Icons.menu_book),
                                    label: const Text(
                                      'Read 50-page Whitepaper',
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 17,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 42),
                              Wrap(
                                spacing: 28,
                                runSpacing: 16,
                                children: const [
                                  _Metric('50,000+', 'Target members'),
                                  _Metric('15,000+', 'Target MAU'),
                                  _Metric('1.2B', 'ORBS supply'),
                                  _Metric('24H', 'Mining cycle'),
                                  _Metric('6', 'Languages'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 64),
                      adSlot('Responsive leaderboard 970×90 / 728×90'),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 50),
              child: Column(
                children: [
                  const Text(
                    'One ecosystem. Web and mobile together.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Login on the website, configure your wallet, then enter the premium mobile mining dashboard.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  glass(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Connected onboarding flow',
                                style: TextStyle(
                                  color: Color(0xFFD7FF35),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '1. Login or create an account\n2. Connect Kaia Wallet or create an ORQUBE test wallet\n3. Select “Dashboard”\n4. Continue to the premium mining experience',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  height: 1.8,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () => goLogin(context),
                                icon: const Icon(Icons.account_balance_wallet),
                                label: const Text('Start wallet setup'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Container(
                            height: 340,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF160D35), Color(0xFF070A18)],
                              ),
                              border: Border.all(
                                color: const Color(0xFF8B2CF6),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.phone_android,
                                color: Color(0xFFB56BFF),
                                size: 150,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 45),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      feature(
                        Icons.currency_bitcoin,
                        'Mining',
                        'Daily participation, attendance, referrals and reward tracking.',
                        const Color(0xFFB56BFF),
                        () => goDashboard(context),
                      ),
                      feature(
                        Icons.collections,
                        'NFT Identity',
                        'Collectible profiles, rarity levels and future portable benefits.',
                        const Color(0xFFFF5C9A),
                        () => goDashboard(context),
                      ),
                      feature(
                        Icons.groups,
                        'Airsoft Hub',
                        'Teams, matches, venues, businesses, marketplace and chat.',
                        const Color(0xFF69E37D),
                        () => goDashboard(context),
                      ),
                      feature(
                        Icons.account_balance_wallet,
                        'Wallet',
                        'Kaia connection, ORQUBE wallet roadmap and asset overview.',
                        const Color(0xFFFFB13B),
                        () => goLogin(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 45),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: glass(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ORQUBE Official Whitepaper',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'A 50-page English document covering vision, user value, product architecture, rewards, token principles, wallet strategy, NFT identity, security, governance, global expansion and the 2026–2028 roadmap.',
                                style: TextStyle(
                                  color: Colors.white60,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 12,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed:
                                        () => openExternalUrl(
                                          'assets/assets/docs/ORQUBE_Whitepaper_EN_2026.pdf',
                                        ),
                                    icon: const Icon(Icons.download),
                                    label: const Text(
                                      'Open English Whitepaper',
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed:
                                        () => openExternalUrl(
                                          'https://x.com/orqubic',
                                        ),
                                    child: const Text('Project updates'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: glass(
                          child: Column(
                            children: const [
                              Icon(
                                Icons.menu_book,
                                color: Color(0xFFD7FF35),
                                size: 76,
                              ),
                              SizedBox(height: 18),
                              Text(
                                '50 PAGES',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'English Edition 2026',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  Row(
                    children: [
                      Expanded(
                        child: adSlot(
                          'In-content responsive display ad',
                          height: 250,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: glass(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Official teaser area',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'This space is reserved for ORQUBE teaser films, product walkthroughs and founder messages.',
                                style: TextStyle(
                                  color: Colors.white60,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: IconButton(
                                  onPressed:
                                      () => openExternalUrl(
                                        'https://youtube.com/@orqube?si=B1nKawDECkxkLh8m',
                                      ),
                                  icon: const Icon(
                                    Icons.play_circle_fill,
                                    size: 90,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 45),
                  const Text(
                    'Connect with ORQUBE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      social('Telegram', Icons.send, 'https://t.me/orqubic7'),
                      social(
                        'X',
                        Icons.alternate_email,
                        'https://x.com/orqubic',
                      ),
                      social(
                        'YouTube',
                        Icons.play_arrow,
                        'https://youtube.com/@orqube?si=B1nKawDECkxkLh8m',
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  adSlot('Footer responsive banner'),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 28),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  Image.asset(AppAssets.logo, width: 38, height: 38),
                  const SizedBox(width: 10),
                  const Text(
                    'ORQUBE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '© 2026 ORQUBE. Community, reward and digital ownership platform.',
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  const _Metric(this.value, this.label);
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 120,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFD7FF35),
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    ),
  );
}

class OldLoginPage extends StatefulWidget {
  final String language;

  const OldLoginPage({super.key, required this.language});

  @override
  State<OldLoginPage> createState() => _OldLoginPageState();
}

class _OldLoginPageState extends State<OldLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String tr(String key) => T.get(widget.language, key);
  bool get isKo => widget.language == 'ko';

  void message(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void goWalletSetup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  Future<void> createUserProfile(User user) async {
    if (FirebaseAuth.instance.currentUser?.uid != user.uid) return;
    await FirebaseService.createUserProfileIfNeeded();
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
      message('Sign-up error: $e');
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
      message('Login error: $e');
    }
  }

  Future<void> googleLogin() async {
    try {
      final UserCredential result;
      if (kIsWeb) {
        final provider =
            GoogleAuthProvider()
              ..setCustomParameters({'prompt': 'select_account'});
        result = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final google = GoogleSignIn();
        await google.signOut();
        final googleUser = await google.signIn();
        if (googleUser == null) return;
        final auth = await googleUser.authentication;
        result = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: auth.accessToken,
            idToken: auth.idToken,
          ),
        );
      }
      final firebaseUser = result.user;

      if (firebaseUser != null) await createUserProfile(firebaseUser);
      goWalletSetup();
    } catch (e) {
      message('Google login error: $e');
    }
  }

  void demoLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => MiningDashboardV2(
              language: widget.language,
              walletStatus: tr('kaiaWalletPlanned'),
              walletAddress: '0xKaiaWallet...8f3d',
              profile: UserProfile(
                nickname: 'OrqubeUser',
                country: 'Korea',
                team: 'ORQUBE Alpha',
                role: 'Rifleman',
                bio: tr('earlyMember'),
                selectedNft: AppAssets.logo,
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isKo ? 'ORQUBE 회원가입 / 로그인' : 'ORQUBE Sign Up / Login';

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
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
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
                      child: Text(isKo ? '이메일 가입' : 'Email Sign Up'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: emailLogin,
                      child: Text(isKo ? '이메일 로그인' : 'Email Login'),
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: demoLogin,
                icon: const Icon(Icons.play_arrow),
                label: Text(tr('demoEnter')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OldWalletSetupPage extends StatefulWidget {
  final String language;

  const OldWalletSetupPage({super.key, required this.language});

  @override
  State<OldWalletSetupPage> createState() => _OldWalletSetupPageState();
}

class _OldWalletSetupPageState extends State<OldWalletSetupPage> {
  String walletStatus = '';
  String walletAddress = '';

  String tr(String key) => T.get(widget.language, key);

  @override
  void initState() {
    super.initState();
    walletStatus = tr('kaiaWalletPlanned');
    walletAddress = '0xKaiaWallet...8f3d';
  }

  void goDashboard() {
    final profile = UserProfile(
      nickname:
          FirebaseAuth.instance.currentUser?.email?.split('@').first ??
          'ORQUBE Player',
      country: 'Korea',
      team: 'ORQUBE Alpha',
      role: 'Rifleman',
      bio: tr('earlyMember'),
      selectedNft: AppAssets.logo,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => MiningDashboardV2(
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
      walletStatus = tr('kaiaWalletPlanned');
      walletAddress = '0xKaiaWallet...8f3d';
    });
  }

  void createOrqubeWallet() {
    setState(() {
      walletStatus = tr('orqubeWalletPlanned');
      walletAddress = '0xOrqubeWallet...8f3d';
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
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
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
                child: Text(tr('goDashboard')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiningDashboardV2 extends StatefulWidget {
  final String language;
  final String walletStatus;
  final String walletAddress;
  final UserProfile profile;

  const MiningDashboardV2({
    super.key,
    required this.language,
    required this.profile,
    this.walletStatus = '',
    this.walletAddress = '',
  });

  @override
  State<MiningDashboardV2> createState() => _MiningDashboardV2State();
}

class _MiningDashboardV2State extends State<MiningDashboardV2> {
  int selectedIndex = 0;
  bool minedToday = false;
  bool isMining = true;

  Timer? timer;
  Duration remaining = const Duration(hours: 23, minutes: 12, seconds: 45);
  double minedOrbs = 3.2478;
  final double dailyOrbs = 4.8;
  final double orbsPerHour = 0.20;
  final DateTime miningStart = DateTime(2024, 6, 1, 9, 15);

  String tr(String key) => T.get(widget.language, key);

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (remaining.inSeconds > 0) {
          remaining = Duration(seconds: remaining.inSeconds - 1);
          if (isMining) minedOrbs += orbsPerHour / 3600;
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get pointText =>
      '${widget.profile.points.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}P';

  String durationText(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void dailyMining() {
    if (minedToday) {
      showMessage(tr('alreadyMined'));
      return;
    }
    setState(() {
      widget.profile.points += 10;
      widget.profile.orbs = widget.profile.points ~/ 10;
      widget.profile.attendanceCount += 1;
      minedToday = true;
      isMining = true;
    });
    showMessage(tr('miningComplete'));
  }

  void addBonus(String kind, int amount) {
    setState(() {
      widget.profile.points += amount;
      widget.profile.orbs = widget.profile.points ~/ 10;
      if (kind == 'checkin') widget.profile.attendanceCount++;
      if (kind == 'invite') widget.profile.referralCount++;
    });
    showMessage('+$amount P ${tr('bonusGiven')}');
  }

  void watchAdReward() {
    setState(() {
      widget.profile.points += 30;
      widget.profile.orbs = widget.profile.points ~/ 10;
    });
    showMessage('+30P ${tr('bonusGiven')}');
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    if (!mounted) return;
    Navigator.pop(context);
  }

  BoxDecoration glassBox({
    double radius = 18,
    Color? borderColor,
    bool glow = false,
  }) {
    return BoxDecoration(
      color: Colors.black.withOpacity(0.42),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.13)),
      boxShadow: [
        BoxShadow(
          color:
              glow
                  ? AppColors.violet.withOpacity(0.35)
                  : Colors.black.withOpacity(0.38),
          blurRadius: glow ? 24 : 18,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget roundLogo(double size, {String? asset}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.24), width: 2),
        boxShadow: [
          BoxShadow(color: AppColors.violet.withOpacity(0.22), blurRadius: 18),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          asset ?? AppAssets.logo,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Container(
                color: AppColors.violet2,
                child: Icon(
                  Icons.flight_takeoff,
                  color: Colors.white,
                  size: size * 0.55,
                ),
              ),
        ),
      ),
    );
  }

  Widget backgroundLayer() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.2, -0.3),
            radius: 1.25,
            colors: [Color(0xFF1D0B3A), Color(0xFF080818), Color(0xFF03040B)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 40,
              left: 340,
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violet.withOpacity(0.04),
                  border: Border.all(color: AppColors.violet.withOpacity(0.08)),
                ),
              ),
            ),
            Positioned(
              top: 160,
              right: 180,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.03),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget languageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: glassBox(radius: 40),
      child: DropdownButton<String>(
        value: widget.language,
        dropdownColor: const Color(0xFF111126),
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white),
        items: const [
          DropdownMenuItem(value: 'ko', child: Text('🌐 한국어')),
          DropdownMenuItem(value: 'en', child: Text('🌐 English')),
          DropdownMenuItem(value: 'ja', child: Text('🌐 日本語')),
          DropdownMenuItem(value: 'zh', child: Text('🌐 中文')),
          DropdownMenuItem(value: 'fr', child: Text('🌐 Français')),
          DropdownMenuItem(value: 'es', child: Text('🌐 Español')),
        ],
        onChanged: (v) {
          if (v == null || v == widget.language) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => MiningDashboardV2(
                    language: v,
                    walletStatus: widget.walletStatus,
                    walletAddress: widget.walletAddress,
                    profile: widget.profile,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget sidebar() {
    final items = [
      [Icons.home, tr('dashboard')],
      [Icons.track_changes, tr('mining')],
      [Icons.account_balance_wallet, tr('wallet')],
      [Icons.hexagon_outlined, tr('nft')],
      [Icons.groups, tr('team')],
      [Icons.forum, tr('community')],
      [Icons.card_giftcard, tr('bonus')],
      [Icons.receipt_long, tr('history')],
      [Icons.settings, tr('settings')],
    ];

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.26),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              roundLogo(100),
              const SizedBox(width: 18),
              const Text(
                'ORQUBE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 38),
          for (int i = 0; i < items.length; i++)
            sidebarItem(
              items[i][0] as IconData,
              items[i][1] as String,
              i == selectedIndex,
              () {
                setState(() => selectedIndex = i);
                if (i != 0) showMessage('${items[i][1]} ${tr('featureSoon')}');
              },
            ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: glassBox(
              radius: 16,
              borderColor: AppColors.violet.withOpacity(0.45),
              glow: true,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tr('whitepaper'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
                const Icon(
                  Icons.article_outlined,
                  color: AppColors.violet,
                  size: 42,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(tr('viewNow'), style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          const Text(
            '© 2026 ORQUBE\nAll rights reserved.',
            style: TextStyle(color: Colors.white38, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget sidebarItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration:
              active
                  ? BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C2FEF), Color(0xFF2A0B69)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.violet.withOpacity(0.65),
                    ),
                  )
                  : null,
          child: Row(
            children: [
              Icon(
                icon,
                color: active ? Colors.white : Colors.white70,
                size: 26,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white70,
                  fontSize: 17,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget topStatusBar() {
    return Row(
      children: [
        const Spacer(),
        languageDropdown(),
        const SizedBox(width: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: glassBox(radius: 16),
          child: Row(
            children: [
              topMetric(tr('myPoints'), pointText, AppColors.violet),
              smallDivider(),
              topMetric(
                'ORBS',
                '${widget.profile.orbs}',
                Colors.white,
                icon: Icons.hexagon,
              ),
              smallDivider(),
              topMetric(
                tr('checkin'),
                '${widget.profile.attendanceCount}',
                Colors.white,
                icon: Icons.calendar_month,
              ),
              smallDivider(),
              roundLogo(50),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.profile.nickname,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Lv.15',
                    style: TextStyle(
                      color: AppColors.violet,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
              IconButton(
                tooltip: tr('logout'),
                onPressed: logout,
                icon: const Icon(Icons.logout, color: Colors.white54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget topMetric(
    String title,
    String value,
    Color valueColor, {
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) Icon(icon, color: AppColors.violet, size: 32),
        if (icon != null) const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget smallDivider() => Container(
    width: 1,
    height: 42,
    margin: const EdgeInsets.symmetric(horizontal: 22),
    color: Colors.white.withOpacity(0.10),
  );

  Widget heroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('dailyMining'),
          style: const TextStyle(
            color: AppColors.violet,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          tr('miningTitle'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          tr('miningSub'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 17,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        timeCard(),
      ],
    );
  }

  Widget timeCard() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: glassBox(radius: 15),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppColors.violet, size: 44),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('nextMiningTime'),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                durationText(remaining),
                style: const TextStyle(
                  color: AppColors.violet,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget miningCircle() {
    return GestureDetector(
      onTap: dailyMining,
      child: SizedBox(
        width: 380,
        height: 380,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 365,
              height: 365,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withOpacity(0.42),
                    blurRadius: 56,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            CustomPaint(
              size: const Size(365, 365),
              painter: MiningRingPainter(progress: 0.82),
            ),
            Container(
              width: 272,
              height: 272,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF1A1235), Color(0xFF050610)],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                roundLogo(78),
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
                  tr('miningNow'),
                  style: const TextStyle(
                    color: AppColors.violet,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  minedOrbs.toStringAsFixed(4),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'ORBS',
                  style: TextStyle(
                    color: AppColors.violet,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '0.20 ORBS / hour  ⓘ',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget miningButton() {
    return SizedBox(
      width: 340,
      height: 62,
      child: ElevatedButton.icon(
        onPressed: dailyMining,
        icon: const Icon(Icons.flash_on, size: 28),
        label: Text(
          tr('miningNow'),
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet2,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: AppColors.violet),
          ),
        ),
      ),
    );
  }

  Widget rewardPanel() {
    return panel(
      child: Column(
        children: [
          rewardItem(Icons.flash_on, AppColors.gold, tr('dailyReward'), '+10P'),
          divider(),
          rewardItem(
            Icons.sync,
            AppColors.violet,
            tr('miningCycle'),
            tr('hours24'),
          ),
          divider(),
          rewardItem(
            Icons.image_outlined,
            AppColors.violet,
            tr('nftProfile'),
            tr('comingSoon'),
          ),
          divider(),
          rewardItem(
            Icons.autorenew,
            AppColors.lime,
            tr('orbsConvert'),
            tr('soon'),
          ),
        ],
      ),
    );
  }

  Widget rewardItem(IconData icon, Color color, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 38),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
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

  Widget walletBox() {
    return panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tr('kaiaWallet'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.circle, color: AppColors.emerald, size: 10),
              const SizedBox(width: 6),
              Text(
                tr('connected'),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Center(child: roundLogo(96)),
          const SizedBox(height: 20),
          Center(
            child: Text(
              widget.walletAddress.isEmpty
                  ? '0xKaiaWallet...8f3d'
                  : widget.walletAddress,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Kaia Mainnet',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.violet,
                side: const BorderSide(color: AppColors.violet),
              ),
              onPressed:
                  () => showMessage('${tr('wallet')} ${tr('featureSoon')}'),
              child: Text(tr('manageWallet')),
            ),
          ),
        ],
      ),
    );
  }

  Widget adRewardBox() {
    return panel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('adReward'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '광고를 시청하고\n추가 보상을 받으세요!',
                  style: TextStyle(color: Colors.white70, height: 1.45),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: watchAdReward,
                    icon: const Icon(Icons.play_circle),
                    label: Text(tr('watchAd')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violet2,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.movie_creation_outlined,
            color: AppColors.violet,
            size: 64,
          ),
        ],
      ),
    );
  }

  Widget statsStrip() {
    return panel(
      child: Row(
        children: [
          expandedStat(
            tr('totalMinedToday'),
            '${dailyOrbs.toStringAsFixed(4)} ORBS',
          ),
          verticalDivider(),
          expandedStat(
            tr('estimatedDailyMining'),
            '${dailyOrbs.toStringAsFixed(4)} ORBS',
          ),
          verticalDivider(),
          expandedStat(tr('miningStartTime'), '2024-06-01 09:15'),
          verticalDivider(),
          expandedStat(
            tr('nextMiningAvailable'),
            durationText(remaining),
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget expandedStat(String title, String value, {bool highlight = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: highlight ? AppColors.violet : Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget boostPanel() {
    return panel(
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(150, 150),
                  painter: BoostRingPainter(),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '200%',
                      style: TextStyle(
                        color: AppColors.violet,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      tr('miningRate'),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      tr('myMiningBoost'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.violet,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                boostLine(Icons.person_outline, tr('baseMiningRate'), '100%'),
                boostLine(Icons.groups_outlined, tr('activeReferrals'), '50%'),
                boostLine(Icons.card_giftcard, tr('teamBonus'), '30%'),
                boostLine(Icons.calendar_month, tr('attendanceStreak'), '20%'),
                divider(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr('finalMiningRate'),
                        style: const TextStyle(
                          color: AppColors.violet,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Text(
                      '200%',
                      style: TextStyle(
                        color: AppColors.violet,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget boostLine(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.violet, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ],
      ),
    );
  }

  Widget teamPanel() {
    return panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tr('myTeamStatus'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.info_outline, color: AppColors.violet, size: 18),
              const Spacer(),
              Text(
                tr('viewDetails'),
                style: const TextStyle(color: AppColors.violet),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: i == 0 ? AppColors.violet : Colors.white12,
                  child: Icon(
                    Icons.person,
                    color: i == 0 ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            tr('activeMembers'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              milestone('3', '10%', true),
              progressLine(true),
              milestone('5', '30%', true),
              progressLine(false),
              milestone('10', '50%', false),
              progressLine(false),
              milestone('20', '100%', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget milestone(String top, String bottom, bool active) {
    return Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          color: active ? AppColors.violet : Colors.white24,
          size: 22,
        ),
        const SizedBox(height: 6),
        Text(top, style: const TextStyle(color: Colors.white, fontSize: 14)),
        Text(
          bottom,
          style: TextStyle(
            color: active ? AppColors.violet : Colors.white60,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget progressLine(bool active) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.only(bottom: 44),
        color: active ? AppColors.violet : Colors.white12,
      ),
    );
  }

  Widget topMinersPanel() {
    final miners = [
      ['👑', 'OrqubeMaster', '9.2456 ORBS'],
      ['♛', 'AirsoftKing', '8.2158 ORBS'],
      ['♜', 'TacticalPro', '6.9872 ORBS'],
      ['4', 'OrqubeUser', '3.2478 ORBS'],
      ['5', 'ShooterOne', '2.8451 ORBS'],
    ];

    return panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tr('topMiners'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(tr('more'), style: const TextStyle(color: AppColors.violet)),
            ],
          ),
          const SizedBox(height: 12),
          for (final m in miners)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              margin: const EdgeInsets.only(bottom: 4),
              decoration:
                  m[1] == 'OrqubeUser'
                      ? BoxDecoration(
                        color: AppColors.violet.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      )
                      : null,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      m[0],
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  roundLogo(32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m[1],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Text(m[2], style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget actionButton(
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(16),
          decoration: glassBox(radius: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.violet, size: 42),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
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

  Widget actionButtonsRow() {
    return Row(
      children: [
        actionButton(
          Icons.event_available,
          tr('dailyCheckin'),
          tr('getBonus'),
          () => addBonus('checkin', 10),
        ),
        actionButton(
          Icons.group_add,
          tr('inviteFriends'),
          tr('getBonus'),
          () => addBonus('invite', 20),
        ),
        actionButton(
          Icons.security,
          tr('team'),
          tr('teamBonus'),
          () => showMessage('${tr('team')} ${tr('featureSoon')}'),
        ),
        actionButton(
          Icons.card_giftcard,
          tr('bonusCenter'),
          tr('variousBenefits'),
          () => showMessage('${tr('bonusCenter')} ${tr('featureSoon')}'),
        ),
        actionButton(
          Icons.receipt_long,
          tr('miningHistory'),
          tr('viewHistory'),
          () => showMessage('${tr('miningHistory')} ${tr('featureSoon')}'),
        ),
      ],
    );
  }

  Widget myInfoPanel() {
    return panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('myInfo'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              miniInfo(Icons.stars, AppColors.gold, tr('points'), pointText),
              miniInfo(
                Icons.hexagon,
                AppColors.violet,
                'ORBS',
                '${widget.profile.orbs}',
              ),
              miniInfo(
                Icons.calendar_month,
                AppColors.violet,
                tr('checkin'),
                '${widget.profile.attendanceCount}',
              ),
              miniInfo(
                Icons.groups,
                AppColors.violet,
                tr('invites'),
                '${widget.profile.referralCount}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget miniInfo(IconData icon, Color color, String title, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
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

  Widget mobileBottomNav() {
    final items = [
      [Icons.home_outlined, tr('dashboard')],
      [Icons.person_outline, tr('profile')],
      [Icons.groups_outlined, tr('community')],
      [Icons.emoji_events_outlined, tr('ranking')],
    ];

    return Container(
      decoration: glassBox(radius: 16),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = selectedIndex == index;
          final icon = items[index][0] as IconData;
          final label = items[index][1] as String;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() => selectedIndex = index);
                if (index != 0) showMessage('$label ${tr('featureSoon')}');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:
                      selected
                          ? AppColors.violet.withOpacity(0.13)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: selected ? AppColors.violet : Colors.white60,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? AppColors.violet : Colors.white70,
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

  Widget mainGridContent(double width) {
    final wide = width >= 1180;
    final medium = width >= 900;

    final leftCenter = Column(
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: heroText()),
              Expanded(
                flex: 2,
                child: Column(children: [miningCircle(), miningButton()]),
              ),
              Expanded(child: rewardPanel()),
            ],
          )
        else
          Column(
            children: [
              heroText(),
              const SizedBox(height: 22),
              miningCircle(),
              miningButton(),
              const SizedBox(height: 22),
              rewardPanel(),
            ],
          ),
        const SizedBox(height: 22),
        statsStrip(),
        const SizedBox(height: 16),
        if (medium)
          Row(
            children: [
              Expanded(child: boostPanel()),
              const SizedBox(width: 14),
              Expanded(child: teamPanel()),
            ],
          )
        else
          Column(
            children: [boostPanel(), const SizedBox(height: 14), teamPanel()],
          ),
        const SizedBox(height: 16),
        actionButtonsRow(),
      ],
    );

    final rightCol = Column(
      children: [
        walletBox(),
        const SizedBox(height: 14),
        adRewardBox(),
        const SizedBox(height: 14),
        topMinersPanel(),
      ],
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: leftCenter),
          const SizedBox(width: 16),
          SizedBox(width: 320, child: rightCol),
        ],
      );
    }

    return Column(children: [leftCenter, const SizedBox(height: 16), rightCol]);
  }

  Widget panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: glassBox(radius: 18),
      child: child,
    );
  }

  Widget verticalDivider() =>
      Container(width: 1, height: 52, color: Colors.white.withOpacity(0.12));
  Widget divider() =>
      Divider(color: Colors.white.withOpacity(0.12), height: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.miningBg,
      body: SafeArea(
        child: Stack(
          children: [
            backgroundLayer(),
            LayoutBuilder(
              builder: (context, constraints) {
                final showSidebar = constraints.maxWidth >= 1050;
                return Row(
                  children: [
                    if (showSidebar) sidebar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(showSidebar ? 24 : 16),
                        child: Column(
                          children: [
                            topStatusBar(),
                            const SizedBox(height: 22),
                            mainGridContent(
                              constraints.maxWidth - (showSidebar ? 348 : 32),
                            ),
                            const SizedBox(height: 16),
                            myInfoPanel(),
                            const SizedBox(height: 16),
                            if (!showSidebar) mobileBottomNav(),
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
    );
  }
}

class MiningRingPainter extends CustomPainter {
  final double progress;
  MiningRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2 - 16);

    final base =
        Paint()
          ..color = Colors.white.withOpacity(0.07)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round;

    final ring =
        Paint()
          ..shader = const SweepGradient(
            colors: [
              AppColors.violet,
              Color(0xFFE9D5FF),
              AppColors.violet2,
              AppColors.violet,
            ],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi * 0.80, math.pi * 1.45, false, base);
    canvas.drawArc(
      rect,
      math.pi * 0.80,
      math.pi * 1.45 * progress,
      false,
      ring,
    );

    final ring2 =
        Paint()
          ..color = AppColors.violet.withOpacity(0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2 - 42),
      math.pi * 1.75,
      math.pi * 0.35,
      false,
      ring2,
    );
  }

  @override
  bool shouldRepaint(covariant MiningRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class BoostRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2 - 10,
    );
    final base =
        Paint()
          ..color = Colors.white.withOpacity(0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13;

    final ring =
        Paint()
          ..shader = const SweepGradient(
            colors: [
              AppColors.violet,
              Color(0xFFE9D5FF),
              AppColors.violet2,
              AppColors.violet,
            ],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 10, base);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * 0.90, false, ring);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
