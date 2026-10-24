import 'package:flutter/material.dart';

class CompanyAboutPage extends StatelessWidget {
  const CompanyAboutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF070B18),
    appBar: AppBar(backgroundColor: const Color(0xFF101426), foregroundColor: Colors.white,
      title: const Text('회사소개 · ORQUBE')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 820),
      child: ListView(padding: const EdgeInsets.all(24), children: [
        Image.asset('assets/images/logo/orqube_plane_logo.png', height: 100),
        const SizedBox(height: 24),
        const Text('ORQUBE', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('AI와 Web3 기술을 일상의 참여로 연결합니다.\n'
          'ORQUBE는 에어소프트 커뮤니티, 안전산행·안심귀가, 토큰 생성과 보상, '
          'AI 마케팅을 함께 발전시키는 플랫폼입니다. 기능을 단계적으로 구현하고 사용자 경험을 통해 개선합니다.',
          style: TextStyle(color: Colors.white70, height: 1.7)),
        const SizedBox(height: 28),
        Container(padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF101A2F), borderRadius: BorderRadius.circular(20)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('개발자 소개', style: TextStyle(color: Color(0xFFD7FF35), fontSize: 16)),
            SizedBox(height: 12),
            Text('김명근 · Kim Myoung Keun', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('ORQUBE 플랫폼 기획·개발\nAI · AutoLISP · CAD 소프트웨어 개발자',
              style: TextStyle(color: Colors.white, height: 1.6)),
            SizedBox(height: 16),
            Text('AutoLISP와 LISP 기반 프로그래밍, 기계·건축 분야 CAD 응용 프로그램 개발, '
              '컴퓨터 그래픽 분야의 경험을 바탕으로 ORQUBE를 기획하고 개발하고 있습니다. '
              'AI와 블록체인을 사용자가 이해하고 활용할 수 있는 서비스로 구현하는 데 집중합니다.',
              style: TextStyle(color: Colors.white70, height: 1.7)),
            SizedBox(height: 16),
            Text('개발 분야\n• AutoLISP 및 LISP 기반 AI 프로그래밍\n'
              '• 기계·건축 CAD 서드파티 프로그램\n• 컴퓨터 그래픽(CG)\n\n'
              '저서\n시집 『아침의 아가페는 끝났다』',
              style: TextStyle(color: Colors.white70, height: 1.8)),
          ])),
        const SizedBox(height: 24),
        const SelectableText('www.orqubic.com', style: TextStyle(color: Colors.white)),
      ]))),
  );
}
