import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mining_page.dart';
import 'orqube_v14_entry.dart';

class WalletSetupPage extends StatefulWidget {
  final String language;
  final VoidCallback? onDashboard;

  const WalletSetupPage({super.key, this.language = 'ko', this.onDashboard});

  @override
  State<WalletSetupPage> createState() => _WalletSetupPageState();
}

class _WalletSetupPageState extends State<WalletSetupPage> {
  bool loading = false;

  String walletStatus = '지갑 미설정';
  String walletAddress = '미설정';
  String walletType = 'none';

  String createDemoWalletAddress() {
    final now = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    return '0xORQUBE${now.substring(now.length - 10).toUpperCase()}';
  }

  Future<void> saveWallet({
    required String status,
    required String address,
    required String type,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      loading = true;
      walletStatus = status;
      walletAddress = address;
      walletType = type;
    });

    try {
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'walletStatus': status,
          'walletAddress': address,
          'walletType': type,
          'walletUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$status 저장 완료')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('지갑 저장 오류: $e')));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> connectKaiaWallet() async {
    await saveWallet(
      status: '기존 Kaia 지갑 연결 완료',
      address: '0xKaiaWallet...8f3d',
      type: 'kaia',
    );
  }

  Future<void> createOrqubeWallet() async {
    final address = createDemoWalletAddress();

    await saveWallet(
      status: '새 ORQUBE 지갑 생성 완료',
      address: address,
      type: 'orqube',
    );
  }

  Future<void> importWallet() async {
    await saveWallet(
      status: 'Wallet 가져오기 준비 완료',
      address: '복구구문 입력 기능 예정',
      type: 'import',
    );
  }

  Future<void> skipWallet() async {
    await saveWallet(status: '나중에 설정', address: '미설정', type: 'skip');
  }

  void goDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OrqubeV14Entry()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        title: const Text('ORQUBE Wallet'),
        backgroundColor: const Color(0xFF2E1065),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: const Color(0xFF101024),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF8B2CF6).withOpacity(0.75),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B2CF6).withOpacity(0.25),
                      blurRadius: 34,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildWalletLogo(),
                    const SizedBox(height: 20),
                    const Text(
                      'ORQUBE Wallet Setup',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kaia Wallet 연결 또는 ORQUBE 지갑 생성을 선택하세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    walletActionButton(
                      icon: Icons.link,
                      title: '기존 Kaia Wallet 연결',
                      subtitle: '사용 중인 Kaia 지갑을 ORQUBE에 연결',
                      onPressed: connectKaiaWallet,
                    ),
                    const SizedBox(height: 12),

                    walletActionButton(
                      icon: Icons.add_circle_outline,
                      title: '새 ORQUBE Wallet 생성',
                      subtitle: '테스트용 ORQUBE 지갑 주소 생성',
                      onPressed: createOrqubeWallet,
                    ),
                    const SizedBox(height: 12),

                    walletActionButton(
                      icon: Icons.restore,
                      title: 'Wallet 가져오기',
                      subtitle: '복구구문 기반 가져오기 기능 예정',
                      onPressed: importWallet,
                    ),
                    const SizedBox(height: 12),

                    walletActionButton(
                      icon: Icons.skip_next,
                      title: '나중에 설정',
                      subtitle: '지갑 없이 먼저 대시보드로 이동',
                      onPressed: skipWallet,
                    ),

                    const SizedBox(height: 24),
                    walletStatusBox(),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : goDashboard,
                        icon:
                            loading
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.dashboard),
                        label: Text(
                          loading ? '저장 중...' : 'Dashboard 이동',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B2CF6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      '※ 현재 지갑 기능은 MVP 테스트 구조입니다. 실제 Kaia Wallet SDK 연동은 이후 단계에서 적용합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildWalletLogo() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B2CF6), Color(0xFF9B35FF), Color(0xFFD7FF35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B2CF6).withOpacity(0.45),
            blurRadius: 26,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.account_balance_wallet,
        color: Colors.white,
        size: 46,
      ),
    );
  }

  Widget walletActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: loading ? null : onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF070712),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFD7FF35), size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget walletStatusBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF070712),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8B2CF6).withOpacity(0.45)),
      ),
      child: Column(
        children: [
          const Text(
            'Wallet Status',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            walletStatus,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Address',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            walletAddress,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD7FF35),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Type: $walletType',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
