import 'debate_hub_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            _circleLogo(),
            const SizedBox(width: 10),
            const Text(
              'ORQUBE',
              style: TextStyle(
                color: Color(0xFF102A43),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Text(
              user?.email ?? 'Guest',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Color(0xFF102A43)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _heroSection(context),
            ListTile(leading: const Icon(Icons.forum), title: const Text('개발용 토론 3종'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DebateHubPage()))),
            _featureSection(),
            _miningPreview(),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _circleLogo() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF7C3AED), width: 2),
        color: const Color(0xFFEDE9FE),
      ),
      child: const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF7C3AED)),
    );
  }

  Widget _heroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 70),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEDE9FE), Color(0xFFDDF4FF), Color(0xFFF7FAFF)],
        ),
      ),
      child: Column(
        children: [
          _circleLogoLarge(),
          const SizedBox(height: 24),
          const Text(
            'ORQUBE Web Dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Airsoft Community · ORBS Mining · Kaia Wallet · NFT Ecosystem',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Start ORQUBE Mining'),
          ),
        ],
      ),
    );
  }

  Widget _circleLogoLarge() {
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF7C3AED), width: 4),
        gradient: const RadialGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFEDE9FE), Color(0xFFDDF4FF)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x337C3AED), blurRadius: 28, spreadRadius: 4),
        ],
      ),
      child: const Icon(
        Icons.flight_takeoff_rounded,
        size: 58,
        color: Color(0xFF7C3AED),
      ),
    );
  }

  Widget _featureSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 50),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: const [
          _FeatureCard(
            icon: Icons.token_rounded,
            title: 'ORBS Mining',
            text: 'Daily mining and reward system.',
          ),
          _FeatureCard(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Kaia Wallet',
            text: 'Wallet connection and token balance.',
          ),
          _FeatureCard(
            icon: Icons.image_rounded,
            title: 'NFT Profile',
            text: 'NFT-based user identity system.',
          ),
          _FeatureCard(
            icon: Icons.groups_rounded,
            title: 'Airsoft Community',
            text: 'Teams, fields, events and rankings.',
          ),
        ],
      ),
    );
  }

  Widget _miningPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      padding: const EdgeInsets.all(28),
      constraints: const BoxConstraints(maxWidth: 920),
      decoration: BoxDecoration(
        color: const Color(0xFF050510),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Text(
            'Mining Preview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD7FF35), width: 5),
              gradient: const RadialGradient(
                colors: [
                  Color(0xFF211142),
                  Color(0xFF090914),
                  Color(0xFF050510),
                ],
              ),
            ),
            child: const Center(
              child: Text(
                '125.0000\nORBS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Mobile mining engine will be connected separately.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34),
      color: const Color(0xFF102A43),
      child: const Column(
        children: [
          Text(
            '회사소개  ·  이용약관  ·  개인정보처리방침  ·  문의하기',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 10),
          Text(
            '© 2026 ORQUBE Project. All rights reserved.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFF7C3AED)),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF102A43),
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
