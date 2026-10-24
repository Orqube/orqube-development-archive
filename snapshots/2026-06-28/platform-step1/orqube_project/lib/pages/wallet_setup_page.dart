import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../utils/app_colors.dart';
import '../utils/translations.dart';
import 'mining_page.dart';

class WalletSetupPage extends StatefulWidget {
  final String language;
  const WalletSetupPage({super.key, required this.language});
  @override State<WalletSetupPage> createState() => _WalletSetupPageState();
}

class _WalletSetupPageState extends State<WalletSetupPage> {
  String walletStatus = '미설정';
  String walletAddress = '';
  String tr(String key) => T.get(widget.language, key);

  void goDashboard() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MiningPage(language: widget.language, walletStatus: walletStatus, walletAddress: walletAddress, profile: UserProfile.defaultProfile())));
  }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bgLight,
    appBar: AppBar(title: Text(tr('walletTitle')), backgroundColor: AppColors.deepPurple, foregroundColor: Colors.white),
    body: Center(child: Container(width: 560, padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.account_balance_wallet, size: 82, color: AppColors.purple),
      const SizedBox(height: 18),
      Text(tr('walletTitle'), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10), Text(tr('walletSub'), textAlign: TextAlign.center),
      const SizedBox(height: 26),
      ElevatedButton.icon(onPressed: () => setState(() { walletStatus='기존 Kaia 지갑 연결 예정'; walletAddress='0xKaiaWallet...'; }), icon: const Icon(Icons.link), label: Text(tr('connectWallet'))),
      const SizedBox(height: 12),
      ElevatedButton.icon(onPressed: () => setState(() { walletStatus='새 ORQUBE 지갑 생성 예정'; walletAddress='0xOrqubeWallet...'; }), icon: const Icon(Icons.add), label: Text(tr('createWallet'))),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: goDashboard, icon: const Icon(Icons.skip_next), label: Text(tr('later'))),
      const SizedBox(height: 20), Text('Wallet Status: $walletStatus'), Text('Address: $walletAddress'),
      const SizedBox(height: 20), ElevatedButton(onPressed: goDashboard, child: const Text('Dashboard 이동')),
    ]))),
  );
}
