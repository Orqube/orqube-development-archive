import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class WhitepaperCenterPage extends StatelessWidget {
  const WhitepaperCenterPage({super.key});

  static const _krAsset = 'assets/docs/ORQUBE_Official_Whitepaper_KR_2026.pdf';
  static const _enAsset = 'assets/docs/ORQUBE_Official_Whitepaper_EN_2026.pdf';

  void _open(BuildContext context, {required bool korean}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => WhitepaperViewerPage(
              title:
                  korean
                      ? 'ORQUBE 공식 백서 · 한국어'
                      : 'ORQUBE Official Whitepaper · English',
              assetPath: korean ? _krAsset : _enAsset,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03040B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080816),
        foregroundColor: Colors.white,
        title: const Text('ORQUBE WHITEPAPER'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tablet = constraints.maxWidth >= 700;
            final cards = [
              _WhitepaperCard(
                flag: 'KR',
                title: 'ORQUBE 공식 백서',
                subtitle: 'Official Whitepaper v5.0 · 2026 Edition',
                button: '한국어 백서 열기',
                onTap: () => _open(context, korean: true),
              ),
              _WhitepaperCard(
                flag: 'EN',
                title: 'ORQUBE Official Whitepaper',
                subtitle: 'Official Whitepaper v5.0 · 2026 Edition',
                button: 'Open English Edition',
                onTap: () => _open(context, korean: false),
              ),
            ];
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: tablet ? 48 : 20,
                vertical: 30,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_stories_rounded,
                        size: 64,
                        color: Color(0xFFD7FF35),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'FROM PARTICIPATION TO POSSIBILITY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Airsoft · Blockchain · AI · Community · Digital Ownership',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      tablet
                          ? Row(
                            children: [
                              Expanded(child: cards[0]),
                              const SizedBox(width: 22),
                              Expanded(child: cards[1]),
                            ],
                          )
                          : Column(
                            children: [
                              cards[0],
                              const SizedBox(height: 18),
                              cards[1],
                            ],
                          ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0B18),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Text(
                          'ADVERTISEMENT / PARTNER AREA\n모바일은 하단 배너, 태블릿·PC는 넓은 파트너 배너 영역으로 사용할 수 있습니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class WhitepaperViewerPage extends StatelessWidget {
  final String title;
  final String assetPath;
  const WhitepaperViewerPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03040B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080816),
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: PdfViewer.asset(assetPath),
    );
  }
}

class _WhitepaperCard extends StatelessWidget {
  final String flag, title, subtitle, button;
  final VoidCallback onTap;
  const _WhitepaperCard({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15102A), Color(0xFF090A16)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x558B2CF6)),
        boxShadow: const [BoxShadow(color: Color(0x338B2CF6), blurRadius: 24)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFD7FF35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              flag,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white60, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(button),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B2CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
