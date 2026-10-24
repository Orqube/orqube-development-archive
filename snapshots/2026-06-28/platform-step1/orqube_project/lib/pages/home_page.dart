import 'package:flutter/material.dart';
import '../utils/app_assets.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final String language;
  final Function(String) onLanguageChanged;
  const HomePage({super.key, required this.language, required this.onLanguageChanged});
  String tr(String key) => T.get(language, key);

  void goLogin(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(language: language)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF5E8FF), Color(0xFFB56CFF), Color(0xFF7C3AED)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Column(children: [
              Row(children: [
                Image.asset(AppAssets.logo, width: 46, height: 46, errorBuilder: (_,__,___)=>const Icon(Icons.hexagon, color: AppColors.deepPurple, size: 40)),
                const SizedBox(width: 10),
                const Text('ORQUBE', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.white)),
                const Spacer(),
                DropdownButton<String>(value: language, dropdownColor: Colors.white, items: const [
                  DropdownMenuItem(value:'ko', child:Text('🇰🇷 한국어')), DropdownMenuItem(value:'en', child:Text('🇺🇸 English')),
                  DropdownMenuItem(value:'fr', child:Text('🇫🇷 Français')), DropdownMenuItem(value:'ja', child:Text('🇯🇵 日本語')),
                  DropdownMenuItem(value:'zh', child:Text('🇨🇳 中文')), DropdownMenuItem(value:'pt', child:Text('🇵🇹 Português')),
                ], onChanged: (v){ if(v!=null) onLanguageChanged(v);}),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: ()=>goLogin(context), child: Text(tr('login'))),
              ]),
              const SizedBox(height: 70),
              const Text('Orqube Military Networking', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              const Text('NFT, ORBS Mining, Kaia Wallet, Airsoft Community', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 24),
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 16)), onPressed: ()=>goLogin(context), child: Text(tr('startMining'))),
              const SizedBox(height: 60),
            ]),
          ),
          const SizedBox(height: 38),
          const Text('ORQUBE Core Features', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.deepPurple)),
          const SizedBox(height: 18),
          Wrap(alignment: WrapAlignment.center, children: const [
            _Feature(icon: Icons.generating_tokens, title: 'ORBS Mining', body: '채굴 / 출석 / 추천 / 팀 보너스'),
            _Feature(icon: Icons.account_balance_wallet, title: 'Kaia Wallet', body: '지갑 연결 / ORBS / NFT'),
            _Feature(icon: Icons.image, title: 'NFT Profile', body: 'NFT 프로필 / 희귀도 / 랭킹'),
            _Feature(icon: Icons.groups, title: 'Community', body: '팀 / 국가 / 에어소프트 리그'),
          ]),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon; final String title; final String body;
  const _Feature({required this.icon, required this.title, required this.body});
  @override Widget build(BuildContext context) => Container(width: 250, margin: const EdgeInsets.all(10), padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 14)]), child: Column(children: [Icon(icon, color: AppColors.purple, size: 42), const SizedBox(height: 12), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(body, textAlign: TextAlign.center)]));
}
