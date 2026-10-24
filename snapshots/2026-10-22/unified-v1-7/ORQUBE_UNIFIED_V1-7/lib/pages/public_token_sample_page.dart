import 'package:flutter/material.dart';

class PublicFeatureNoticePage extends StatelessWidget {
  const PublicFeatureNoticePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF030611),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B1020),
          foregroundColor: Colors.white,
          title: Text(title),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              '현재 안정화와 보안 검증 중인 기능입니다. 공개 안정본에서는 지갑 생성, 개인키 처리와 실제 토큰 전송을 실행하지 않습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.65),
            ),
          ),
        ),
      );
}

/// A read-only, sign-in-free token design preview.
///
/// This page deliberately contains no wallet creation, private key handling,
/// contract compilation, deployment, payment, or server-side AI calls.
class PublicTokenSamplePage extends StatelessWidget {
  const PublicTokenSamplePage({super.key, required this.idea});

  final String idea;

  String get _symbol {
    final words = idea
        .replaceAll(RegExp(r'[^A-Za-z0-9가-힣 ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'SAMPLE';
    final ascii = words
        .map((word) => word.replaceAll(RegExp(r'[^A-Za-z0-9]'), ''))
        .where((word) => word.isNotEmpty)
        .take(4)
        .map((word) => word[0])
        .join()
        .toUpperCase();
    return ascii.length >= 2 ? ascii : 'ORBS';
  }

  @override
  Widget build(BuildContext context) {
    final fields = <(String, String)>[
      ('아이디어', idea),
      ('샘플 심볼', _symbol),
      ('네트워크', 'Kaia (정식 생성 전 선택 가능)'),
      ('샘플 공급량', '100,000,000'),
      ('권장 구조', 'Fixed supply · Burnable · Mintable OFF'),
      ('상태', '체험용 미리보기 · 블록체인에 배포되지 않음'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF030611),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: const Text('ORQUBE AI TOKEN SAMPLE'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1325),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF9B5CFF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '로그인 없는 샘플 설계 결과',
                    style: TextStyle(
                      color: Color(0xFFD7FF35),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '입력한 아이디어가 토큰 설계 항목으로 어떻게 정리되는지 확인하는 안전한 체험입니다.',
                    style: TextStyle(color: Colors.white70, height: 1.55),
                  ),
                  const SizedBox(height: 24),
                  ...fields.map(
                    (field) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 112,
                            child: Text(
                              field.$1,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              field.$2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 32),
                  const Text(
                    '실제 생성·지갑 연결·배포·결제는 로그인과 최종 확인이 필요하며, 이 체험에서는 어떠한 키나 자산도 생성 또는 전송하지 않습니다.',
                    style: TextStyle(color: Colors.white60, height: 1.55),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('아이디어 다시 입력'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
