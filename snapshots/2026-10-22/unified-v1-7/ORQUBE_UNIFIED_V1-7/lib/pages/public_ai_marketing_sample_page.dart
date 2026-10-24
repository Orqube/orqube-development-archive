import 'package:flutter/material.dart';

class PublicAiMarketingSamplePage extends StatefulWidget {
  const PublicAiMarketingSamplePage({super.key});

  @override
  State<PublicAiMarketingSamplePage> createState() =>
      _PublicAiMarketingSamplePageState();
}

class _PublicAiMarketingSamplePageState
    extends State<PublicAiMarketingSamplePage> {
  final TextEditingController _topicController = TextEditingController();
  String _mode = 'official';
  Map<String, String>? _result;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _generate() {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('홍보할 내용을 한 문장으로 입력해 주세요.')),
      );
      return;
    }
    final subject = _mode == 'official' ? 'ORQUBE 공식 캠페인' : '내 토큰 캠페인';
    setState(() {
      _result = {
        '핵심 메시지': '$subject — $topic. 참여와 실사용 가치를 쉽고 투명하게 연결합니다.',
        'Facebook': '새로운 가능성을 함께 만들어 보세요. $topic\nORQUBE가 커뮤니티·안전·디지털 보상을 하나의 경험으로 연결합니다. #ORQUBE #Web3',
        'X': '$topic 🚀 참여에서 실사용까지, ORQUBE와 함께 시작하세요. #ORQUBE #AI #Token',
        'YouTube': '$topic | ORQUBE가 만드는 AI·안전·커뮤니티 기반 보상 생태계를 영상으로 소개합니다.',
        'NAVER CAFE': '[ORQUBE 소식] $topic\n서비스 목적과 이용 방법, 현재 개발 단계를 누구나 이해하기 쉽게 안내합니다.',
        'Telegram · Discord': '📢 $subject\n$topic\n공식 안내를 확인하고 의견을 남겨 주세요.',
        'QR 콘텐츠': '$topic\nQR을 스캔하여 ORQUBE 공개 체험과 최신 진행 상황을 확인하세요.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 680;
    return Scaffold(
      backgroundColor: const Color(0xFF030611),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1020),
        foregroundColor: Colors.white,
        title: const Text('ORQUBE AI MARKETING · SAMPLE'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(mobile ? 14 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('공개용 AI 마케팅 체험', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('실제 AI 호출이나 SNS 자동 게시는 하지 않습니다. 입력한 주제를 채널별 샘플 홍보문으로 구성합니다.', style: TextStyle(color: Colors.white70, height: 1.55)),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ChoiceChip(label: const Text('ORQUBE 공식 홍보'), selected: _mode == 'official', onSelected: (_) => setState(() => _mode = 'official')),
                    ChoiceChip(label: const Text('내 토큰 홍보'), selected: _mode == 'token', onSelected: (_) => setState(() => _mode = 'token')),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _topicController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '예: 누구나 한 문장으로 토큰을 설계하는 ORQUBE 공개 체험',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF0D1325),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(onPressed: _generate, icon: const Icon(Icons.auto_awesome_rounded), label: const Text('샘플 캠페인 만들기')),
                const SizedBox(height: 20),
                _weightPanel(),
                if (_result != null) ...[
                  const SizedBox(height: 20),
                  ..._result!.entries.map((entry) => _resultCard(entry.key, entry.value)),
                ],
                const SizedBox(height: 18),
                const Text('실제 AI 생성, 크레딧 차감, 계정 연결 및 게시 기능은 보안 검증 후 서버 방식으로 제공할 예정입니다. API Key와 SNS 인증정보는 공개본에 포함되지 않습니다.', style: TextStyle(color: Colors.white54, height: 1.55)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _weightPanel() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFF0D1325), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF8254E8))),
        child: const Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text('토큰 생성 40%', style: TextStyle(color: Color(0xFFD7FF35), fontWeight: FontWeight.w800)),
            Text('AIRSOFT 20%', style: TextStyle(color: Colors.white70)),
            Text('안전산행 15%', style: TextStyle(color: Colors.white70)),
            Text('채굴 15%', style: TextStyle(color: Colors.white70)),
            Text('안심귀가 10%', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );

  Widget _resultCard(String title, String body) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFF10172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Color(0xFF55E6FF), fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          SelectableText(body, style: const TextStyle(color: Colors.white, height: 1.55)),
        ]),
      );
}
