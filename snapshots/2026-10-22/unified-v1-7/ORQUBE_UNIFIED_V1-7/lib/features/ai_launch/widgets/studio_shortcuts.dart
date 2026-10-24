import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/launch_create_wizard_page.dart';
import '../screens/generated_kaia_wallet_page.dart';
import '../screens/my_launch_page.dart';
import 'launch_ui.dart';

class StudioShortcuts extends StatefulWidget {
  const StudioShortcuts({super.key, required this.ownerUid});
  final String ownerUid;
  @override
  State<StudioShortcuts> createState() => _StudioShortcutsState();
}

class _StudioShortcutsState extends State<StudioShortcuts> {
  final _idea = TextEditingController();
  @override
  void dispose() { _idea.dispose(); super.dispose(); }

  void _start() {
    final idea = _idea.text.trim();
    if (idea.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('만들고 싶은 토큰을 세 글자 이상 적어주세요.')));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LaunchCreateWizardPage(ownerUid: widget.ownerUid, initialIdea: idea)));
  }

  Future<void> _staking() async {
    try {
      if (!await launchUrl(Uri.parse('https://staking.orqubic.com'), mode: LaunchMode.externalApplication)) {
        throw StateError('open failed');
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('스테이킹 사이트를 열지 못했습니다. https://staking.orqubic.com 으로 접속해주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) => LaunchGlassCard(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const LaunchSectionTitle(title: '무슨 토큰을 만들까요?', subtitle: '아이디어 입력 → 초안 수정 → 발행량 입력 → 테스트넷 배포·전송 → 결제·소스검증'),
      TextField(controller: _idea, minLines: 1, maxLines: 3, maxLength: 700,
        textInputAction: TextInputAction.done, onSubmitted: (_) => _start(),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: '예: 우리 카페 단골 손님을 위한 리워드 토큰', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        FilledButton.icon(onPressed: _start, icon: const Icon(Icons.auto_awesome), label: const Text('초안 만들기')),
        OutlinedButton.icon(onPressed: widget.ownerUid.isEmpty ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GeneratedKaiaWalletPage(ownerUid: widget.ownerUid))), icon: const Icon(Icons.add_card), label: const Text('KAIA 지갑주소 생성')),
        OutlinedButton.icon(onPressed: _staking, icon: const Icon(Icons.savings_outlined), label: const Text('스테이킹 사이트')),
        TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MyLaunchPage(ownerUid: widget.ownerUid))), child: const Text('웹·앱에서 만든 내 토큰')),
      ]),
      if (widget.ownerUid.isEmpty) const Text('지갑 생성과 내 토큰 저장은 로그인 후 이용하세요.', style: TextStyle(color: LaunchPalette.muted)),
    ],
  ));
}
