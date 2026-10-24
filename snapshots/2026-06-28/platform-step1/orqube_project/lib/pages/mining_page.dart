import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/mining_service.dart';
import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../widgets/mining_circle.dart';
import '../widgets/neon_card.dart';
import 'home_page.dart';
import 'placeholder_pages.dart';

class MiningPage extends StatefulWidget {
  final String language;
  final String walletStatus;
  final String walletAddress;
  final UserProfile profile;
  const MiningPage({super.key, required this.language, required this.profile, this.walletStatus = '미설정', this.walletAddress = ''});
  @override State<MiningPage> createState() => _MiningPageState();
}

class _MiningPageState extends State<MiningPage> {
  int selectedIndex = 0;
  late UserProfile profile = widget.profile;
  final mining = MiningService();
  final store = FirestoreService();
  Timer? timer;
  double liveOrbs = 3.2478;

  @override void initState() { super.initState(); timer = Timer.periodic(const Duration(seconds: 1), (_) { if(mounted) setState(() { liveOrbs += mining.orbsPerHour(profile) / 3600; }); }); }
  @override void dispose() { timer?.cancel(); super.dispose(); }

  String remainText() {
    final d = mining.remaining(profile);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> save() async { final u = FirebaseAuth.instance.currentUser; if(u != null) await store.saveProfile(u.uid, profile); }
  void doMining() { setState(() { mining.mine(profile); liveOrbs += 0.1; }); save(); }
  void addReward(String type, int amount) { setState(() { profile.points += amount; profile.orbs = profile.points ~/ 10; if(type=='attendance') profile.attendanceCount++; if(type=='referral') profile.referralCount++; }); save(); }

  Widget dashboard() {
    final boost = mining.boostRate(profile);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(26),
      child: Column(children: [
        LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth > 900;
          final left = _leftHero();
          final center = MiningCircle(points: profile.points, orbs: liveOrbs, orbsPerHour: mining.orbsPerHour(profile), mining: !mining.canMine(profile), onMine: doMining);
          final right = _rewardPanel();
          return wide ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: left), Expanded(child: center), Expanded(child: right)]) : Column(children: [left, const SizedBox(height: 20), center, const SizedBox(height: 20), right]);
        }),
        const SizedBox(height: 24),
        NeonCard(child: Wrap(alignment: WrapAlignment.spaceAround, runSpacing: 16, children: [
          _stat('총 채굴량 (오늘)', '4.8000 ORBS'), _stat('예상 일일 채굴량', '4.8000 ORBS'), _stat('채굴 시작 시간', '2024-06-01 09:15'), _stat('다음 채굴 가능', remainText(), purple: true),
        ])),
        const SizedBox(height: 22),
        LayoutBuilder(builder: (_, c) => c.maxWidth > 850 ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _boostCard(boost)), const SizedBox(width: 18), Expanded(child: _teamCard())]) : Column(children: [_boostCard(boost), const SizedBox(height: 18), _teamCard()])),
        const SizedBox(height: 22),
        Wrap(spacing: 18, runSpacing: 18, alignment: WrapAlignment.center, children: [
          _action(Icons.group_add, '친구 초대', '보너스 받기', () => addReward('referral', 20)),
          _action(Icons.event_available, '출석 체크', '보너스 받기', () => addReward('attendance', 10)),
          _action(Icons.card_giftcard, '보너스 센터', '다양한 혜택', () {}),
          _action(Icons.assignment, '채굴 기록', '내역 확인', () {}),
        ]),
        const SizedBox(height: 22),
        LayoutBuilder(builder: (_, c) => c.maxWidth > 850 ? Row(children: [Expanded(child: _walletCard()), const SizedBox(width: 18), Expanded(child: _myInfo())]) : Column(children: [_walletCard(), const SizedBox(height: 18), _myInfo()])),
      ]),
    );
  }

  Widget _leftHero() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Image.asset(AppAssets.logo, width: 86, height: 86, errorBuilder: (_,__,___)=>const Icon(Icons.hexagon, color: Colors.white, size: 70)), const SizedBox(width: 16), const Text('ORQUBE', style: TextStyle(color: Colors.white, fontSize: 43, fontWeight: FontWeight.w900))]),
    const SizedBox(height: 48),
    const Text('DAILY MINING', style: TextStyle(color: AppColors.purple, fontSize: 18, fontWeight: FontWeight.w900)),
    const SizedBox(height: 16),
    const Text('하루 한 번,\nORQUBE 채굴', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, height: 1.25)),
    const SizedBox(height: 18),
    const Text('매일 1회 채굴을 통해\nORQUBE 포인트를 획득하세요.', style: TextStyle(color: Colors.white, fontSize: 18, height: 1.5)),
    const SizedBox(height: 26),
    NeonCard(child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.calendar_month, color: AppColors.purple, size: 42), const SizedBox(width: 16), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('다음 채굴 가능 시간', style: TextStyle(color: Colors.white)), Text(remainText(), style: const TextStyle(color: AppColors.purple, fontSize: 28, fontWeight: FontWeight.w900))])])),
  ]);

  Widget _rewardPanel() => NeonCard(child: Column(children: const [
    _RewardRow(icon: Icons.flash_on, color: AppColors.yellow, title: 'DAILY REWARD', body: '+10P'),
    Divider(color: AppColors.line), _RewardRow(icon: Icons.sync, color: AppColors.purple, title: 'MINING CYCLE', body: '24 HOURS'),
    Divider(color: AppColors.line), _RewardRow(icon: Icons.image, color: AppColors.purple, title: 'NFT PROFILE', body: 'COMING SOON'),
    Divider(color: AppColors.line), _RewardRow(icon: Icons.autorenew, color: AppColors.lime, title: 'ORBS CONVERT', body: 'SOON'),
  ]));

  Widget _stat(String a, String b, {bool purple=false}) => SizedBox(width: 210, child: Column(children: [Text(a, style: const TextStyle(color: AppColors.muted)), const SizedBox(height: 8), Text(b, style: TextStyle(color: purple ? AppColors.purple : Colors.white, fontSize: 20, fontWeight: FontWeight.w900))]));

  Widget _boostCard(int boost) => NeonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('내 채굴 부스트  ⓘ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
    const SizedBox(height: 18),
    Row(children: [Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.purple, width: 12)), child: Center(child: Text('$boost%\n채굴률', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.purple, fontSize: 27, fontWeight: FontWeight.w900)))), const SizedBox(width: 28), Expanded(child: Column(children: const [_BoostLine('기본 채굴률', '100%'), _BoostLine('추천 활성 회원 (5명)', '50%'), _BoostLine('팀 조합 보너스 (완성)', '30%'), _BoostLine('출석 연속 (7일)', '20%')]))]),
    const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('최종 채굴률', style: TextStyle(color: AppColors.purple, fontSize: 20, fontWeight: FontWeight.bold)), Text('$boost%', style: const TextStyle(color: AppColors.purple, fontSize: 24, fontWeight: FontWeight.w900))])
  ]));

  Widget _teamCard() => NeonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: const [Text('내 팀 현황  ⓘ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), Spacer(), Text('자세히 보기 〉', style: TextStyle(color: AppColors.purple))]),
    const SizedBox(height: 24),
    Row(children: List.generate(5, (i) => Padding(padding: const EdgeInsets.only(right: 12), child: CircleAvatar(radius: 28, backgroundColor: i < profile.teamActiveCount ? AppColors.purple : AppColors.line, child: Icon(Icons.person, color: i < profile.teamActiveCount ? Colors.white : AppColors.muted))))),
    const SizedBox(height: 12), Text('활성 회원  ${profile.teamActiveCount} / 5', style: const TextStyle(color: Colors.white)),
    const SizedBox(height: 20), LinearProgressIndicator(value: profile.teamActiveCount / 5, color: AppColors.purple, backgroundColor: AppColors.line),
    const SizedBox(height: 14), const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('3명\n10%', style: TextStyle(color: Colors.white)), Text('5명\n30%', style: TextStyle(color: AppColors.purple)), Text('10명\n50%', style: TextStyle(color: AppColors.muted)), Text('20명\n100%', style: TextStyle(color: AppColors.muted))]),
  ]));

  Widget _action(IconData icon, String title, String sub, VoidCallback onTap) => SizedBox(width: 230, height: 110, child: NeonCard(child: InkWell(onTap: onTap, child: Row(children: [Icon(icon, color: AppColors.purple, size: 46), const SizedBox(width: 14), Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(color: AppColors.muted))])]))));

  Widget _walletCard() => NeonCard(borderColor: AppColors.lime, child: Row(children: [const Icon(Icons.account_balance_wallet, color: AppColors.lime, size: 50), const SizedBox(width: 18), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('KAIA WALLET', style: TextStyle(color: AppColors.lime, fontSize: 18, fontWeight: FontWeight.w900)), Text(widget.walletStatus, style: const TextStyle(color: Colors.white, fontSize: 18)), Text(widget.walletAddress.isEmpty ? '0xKaiaWallet...' : widget.walletAddress, style: const TextStyle(color: AppColors.muted))])), const Icon(Icons.chevron_right, color: AppColors.muted, size: 34)]));

  Widget _myInfo() => NeonCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('내 정보', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 14), Wrap(spacing: 24, runSpacing: 14, children: [_mini(Icons.stars, '포인트', '${profile.points}P'), _mini(Icons.hexagon, 'ORBS', '${profile.orbs}'), _mini(Icons.calendar_month, '출석체크', '${profile.attendanceCount}회'), _mini(Icons.groups, '친구초대', '${profile.referralCount}명')])])) ;
  Widget _mini(IconData i, String a, String b) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, color: AppColors.purple, size: 34), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a, style: const TextStyle(color: AppColors.muted)), Text(b, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))])]);

  Future<void> logout() async { await AuthService().logout(); if(!mounted) return; Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage(language: widget.language, onLanguageChanged: (_){})), (_) => false); }

  @override Widget build(BuildContext context) {
    final pages = [dashboard(), const SimplePage(title: 'Profile', icon: Icons.person), const SimplePage(title: 'Community', icon: Icons.groups), const SimplePage(title: 'Ranking', icon: Icons.emoji_events)];
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(backgroundColor: AppColors.dark, foregroundColor: Colors.white, title: Text('내 포인트  ${profile.points}P'), actions: [Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [CircleAvatar(backgroundImage: AssetImage(profile.selectedNft)), const SizedBox(width: 8), Text(profile.nickname), IconButton(onPressed: logout, icon: const Icon(Icons.logout))]))]),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(backgroundColor: AppColors.card, indicatorColor: AppColors.deepPurple, selectedIndex: selectedIndex, onDestinationSelected: (v)=>setState(()=>selectedIndex=v), destinations: const [NavigationDestination(icon: Icon(Icons.home), label: '대시보드'), NavigationDestination(icon: Icon(Icons.person), label: '프로필'), NavigationDestination(icon: Icon(Icons.groups), label: '커뮤니티'), NavigationDestination(icon: Icon(Icons.emoji_events), label: '랭킹')]),
    );
  }
}

class _RewardRow extends StatelessWidget { final IconData icon; final Color color; final String title; final String body; const _RewardRow({required this.icon, required this.color, required this.title, required this.body}); @override Widget build(BuildContext context)=>Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [Icon(icon, color: color, size: 38), const SizedBox(width: 18), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(body, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]) ])); }
class _BoostLine extends StatelessWidget { final String a; final String b; const _BoostLine(this.a, this.b); @override Widget build(BuildContext context)=>Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(a, style: const TextStyle(color: Colors.white))), Text(b, style: const TextStyle(color: Colors.white, fontSize: 18))])); }
