import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/orqube_ai_assistant_service.dart';
import 'launch_ui.dart';

class OrqubeAiAssistantButton extends StatelessWidget {
  const OrqubeAiAssistantButton({
    super.key,
    required this.screen,
    this.projectId = '',
    this.projectData,
    this.onNavigateToStage,
  });

  final String screen;
  final String projectId;
  final Map<String, dynamic>? projectData;
  /// Optional host navigation hook. Existing callers remain compatible.
  /// Expected stage values: USE, TEST, DEPLOY, PAY, VERIFY.
  final Future<void> Function(String stage)? onNavigateToStage;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'orqube-ai-$screen',
      backgroundColor: LaunchPalette.purple,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.smart_toy_outlined),
      label: const Text(
        'AI 도움',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      onPressed: () => _open(context),
    );
  }

  Future<void> _open(BuildContext context) async {
    var contextData = projectData;
    if (projectId.trim().isNotEmpty) {
      try {
        final db = FirebaseFirestore.instance;
        final snap = await db
            .collection('launch_projects')
            .doc(projectId.trim())
            .get();
        if (snap.data() != null) {
          contextData = Map<String, dynamic>.from(snap.data()!);
          // 상태인식 AI: 프로젝트뿐 아니라 AUTO VERIFY/지갑 상태까지 한 번에 읽습니다.
          // 읽기 전용이며 배포·결제·서명은 절대 자동 실행하지 않습니다.
          try {
            final archive = await db
                .collection('launch_deployment_archives')
                .doc(projectId.trim())
                .get();
            final a = archive.data();
            if (a != null) {
              contextData!['paymentStatus'] = a['paymentStatus'];
              contextData!['verificationStatus'] =
                  a['verificationStatus'] ?? contextData!['verificationStatus'];
              contextData!['verificationTxHash'] = a['verificationTxHash'];
            }
          } catch (_) {}
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          if (uid.isNotEmpty) {
            try {
              final wallet = await db.collection('launch_wallets').doc(uid).get();
              final w = wallet.data();
              if (w != null) {
                contextData!['launchWalletAddress'] = w['walletAddress'];
                contextData!['walletStatus'] = w['walletStatus'];
              }
            } catch (_) {}
          }
        }
      } catch (_) {
        // The assistant can still open in generic guidance mode.
      }
    }
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: LaunchPalette.bg,
      builder: (context) => FractionallySizedBox(
        heightFactor: .88,
        child: _OrqubeAiAssistantSheet(
          screen: screen,
          projectData: contextData,
          onNavigateToStage: onNavigateToStage,
        ),
      ),
    );
  }
}

class _OrqubeAiAssistantSheet extends StatefulWidget {
  const _OrqubeAiAssistantSheet({
    required this.screen,
    this.projectData,
    this.onNavigateToStage,
  });

  final String screen;
  final Map<String, dynamic>? projectData;
  final Future<void> Function(String stage)? onNavigateToStage;

  @override
  State<_OrqubeAiAssistantSheet> createState() =>
      _OrqubeAiAssistantSheetState();
}

class _OrqubeAiAssistantSheetState extends State<_OrqubeAiAssistantSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_UiMessage>[
    const _UiMessage(
      fromUser: false,
      text:
          '안녕하세요. 저는 ORQUBE AI Assistant입니다.\n'
          '토큰을 대신 발행하거나 지갑을 조작하는 로봇이 아니라, 현재 단계와 다음 작업을 설명하고 오류 해결을 돕는 AI 가이드입니다.\n\n'
          '중요: 비밀키·시드 문구·12단어 복구문구·비밀번호·인증번호는 절대 입력하지 마세요.',
      remoteAi: false,
    ),
  ];
  bool _sending = false;

  static const _quickQuestions = <String>[
    '현재 단계 설명해줘',
    '다음에 무엇을 해야 하나요?',
    '지갑 주소 차이를 설명해줘',
    '배포 전에 무엇을 확인하나요?',
    'AUTO VERIFY를 설명해줘',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              children: [
                _guidelines(),
                const SizedBox(height: 10),
                _betaPolicyCard(),
                const SizedBox(height: 10),
                _stateAwarenessCard(),
                const SizedBox(height: 10),
                _nextActionCard(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final question in _quickQuestions)
                      _QuickQuestionButton(
                        label: question,
                        enabled: !_sending,
                        onTap: () => _send(question),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final message in _messages) ...[
                  _MessageBubble(message: message),
                  const SizedBox(height: 10),
                ],
                if (_sending)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 9),
                          Text(
                            'AI가 설명을 준비하고 있습니다...',
                            style: TextStyle(color: LaunchPalette.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _composer(),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: LaunchPalette.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: LaunchPalette.purple.withOpacity(.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LaunchPalette.purple.withOpacity(.45)),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: LaunchPalette.cyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'ORQUBE AI ASSISTANT',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: LaunchPalette.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: LaunchPalette.green.withOpacity(.13),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: LaunchPalette.green.withOpacity(.35),
                        ),
                      ),
                      child: const Text(
                        'BETA · FREE',
                        style: TextStyle(
                          color: LaunchPalette.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Human + AI · 설명과 안내 중심',
                  style: TextStyle(
                    color: LaunchPalette.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '닫기',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: LaunchPalette.text),
          ),
        ],
      ),
    );
  }

  Widget _guidelines() {
    return Material(
      color: LaunchPalette.panel.withOpacity(.78),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: LaunchPalette.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: const ExpansionTile(
          leading: Icon(Icons.verified_user_outlined, color: LaunchPalette.green),
          iconColor: LaunchPalette.cyan,
          collapsedIconColor: LaunchPalette.muted,
          title: Text(
            'AI 이용 가이드라인',
            style: TextStyle(
              color: LaunchPalette.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            '사람이 결정하고 AI가 설명·검토·개발을 돕습니다.',
            style: TextStyle(color: LaunchPalette.muted, fontSize: 12),
          ),
          childrenPadding: EdgeInsets.fromLTRB(18, 0, 18, 16),
          children: [
            _GuideLine('1', 'DESCRIBE → BUILD → TEST → DEPLOY → VERIFY → USE 순서로 안내합니다.'),
            _GuideLine('2', '배포·결제·지갑 서명·프로필 공개는 사용자가 직접 확인하고 승인합니다.'),
            _GuideLine('3', '비밀키·시드 문구·복구문구·비밀번호·인증번호를 요청하거나 저장하지 않습니다.'),
            _GuideLine('4', '가격 상승·수익·상장 등을 보장하지 않으며 위험과 제한을 함께 설명합니다.'),
            _GuideLine('5', '확인되지 않은 TX·주소·검증 성공을 사실처럼 말하지 않습니다.'),
          ],
        ),
      ),
    );
  }

  Widget _betaPolicyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LaunchPalette.purple.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LaunchPalette.purple.withOpacity(.24)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined,
                  size: 18, color: LaunchPalette.cyan),
              SizedBox(width: 8),
              Text(
                'BETA 이용 정책',
                style: TextStyle(
                  color: LaunchPalette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 9),
          Text(
            '• 기본 안내·가이드라인: 무료\n'
            '• AI 심층분석: 하루 10회 무료(BETA)\n'
            '• 향후 고급 프로젝트 분석: ORBS 선택 결제 예정\n'
            '• 현재 BETA에서는 ORBS를 자동 차감하지 않습니다.',
            style: TextStyle(
              color: LaunchPalette.muted,
              height: 1.5,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stateAwarenessCard() {
    final summary = OrqubeAiAssistantService.stateSummary(
      widget.projectData,
      screen: widget.screen,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LaunchPalette.cyan.withOpacity(.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LaunchPalette.cyan.withOpacity(.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.radar_rounded, size: 18, color: LaunchPalette.cyan),
              SizedBox(width: 8),
              Text(
                '상태인식 AI',
                style: TextStyle(
                  color: LaunchPalette.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(
              color: LaunchPalette.text,
              height: 1.5,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '※ 현재 저장 상태를 읽어 안내만 하며 배포·결제·지갑 서명은 자동 실행하지 않습니다.',
            style: TextStyle(color: LaunchPalette.muted, fontSize: 11.5),
          ),
        ],
      ),
    );
  }


  Widget _nextActionCard() {
    final actions = _recommendedActions(widget.projectData);
    if (actions.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LaunchPalette.purple.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LaunchPalette.purple.withOpacity(.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.alt_route_rounded, size: 18, color: LaunchPalette.cyan),
              SizedBox(width: 8),
              Text('다음 작업', style: TextStyle(color: LaunchPalette.text, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            '현재 토큰 상태에 맞는 선택지만 표시합니다. 이동 후에도 배포·결제·지갑 서명은 사용자가 직접 승인합니다.',
            style: TextStyle(color: LaunchPalette.muted, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final action in actions)
                OutlinedButton.icon(
                  onPressed: _sending ? null : () => _navigateToStage(action.$1),
                  icon: Icon(action.$3, size: 17),
                  label: Text(action.$2),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LaunchPalette.text,
                    side: BorderSide(color: LaunchPalette.purple.withOpacity(.55)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<(String, String, IconData)> _recommendedActions(Map<String, dynamic>? data) {
    final d = data ?? const <String, dynamic>{};
    String value(String key) => (d[key] ?? '').toString().trim().toUpperCase();
    final contract = (d['contractAddress'] ?? '').toString().trim();
    final verification = value('verificationStatus');
    final payment = value('paymentStatus');
    final status = value('status');

    final deployed = contract.isNotEmpty || status.contains('DEPLOY');
    final verified = verification.contains('VERIFIED') || verification.contains('SUCCESS');
    final paid = payment.contains('CONFIRMED') || payment.contains('PAID') || payment.contains('SUCCESS');

    if (!deployed) {
      return const [
        ('USE', 'USE로 이동', Icons.apps_rounded),
        ('TEST', 'TEST로 이동', Icons.science_outlined),
        ('DEPLOY', 'DEPLOY 준비', Icons.rocket_launch_outlined),
      ];
    }
    if (!paid && !verified) {
      return const [
        ('USE', 'USE로 이동', Icons.apps_rounded),
        ('PAY', 'PAY 확인', Icons.payments_outlined),
        ('VERIFY', 'VERIFY 안내', Icons.verified_outlined),
      ];
    }
    if (!verified) {
      return const [
        ('VERIFY', 'VERIFY로 이동', Icons.verified_outlined),
        ('USE', 'USE로 이동', Icons.apps_rounded),
      ];
    }
    return const [('USE', 'USE로 이동', Icons.apps_rounded)];
  }

  Future<void> _navigateToStage(String stage) async {
    final callback = widget.onNavigateToStage;
    if (callback == null) {
      await _send('$stage 단계로 이동하려면 무엇을 확인해야 하나요?');
      return;
    }
    Navigator.of(context).pop();
    await callback(stage);
  }

  Widget _composer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: LaunchPalette.bg2,
        border: Border(top: BorderSide(color: LaunchPalette.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              enabled: !_sending,
              style: const TextStyle(color: LaunchPalette.text),
              decoration: InputDecoration(
                hintText: '현재 화면이나 오류를 물어보세요.',
                hintStyle: const TextStyle(color: LaunchPalette.muted),
                filled: true,
                fillColor: Colors.white.withOpacity(.055),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(.10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(.10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: LaunchPalette.purple),
                ),
              ),
              onSubmitted: _sending ? null : (_) => _sendFromField(),
            ),
          ),
          const SizedBox(width: 9),
          IconButton.filled(
            tooltip: '보내기',
            onPressed: _sending ? null : _sendFromField,
            style: IconButton.styleFrom(
              backgroundColor: LaunchPalette.purple,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_upward_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFromField() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _send(text);
  }

  Future<void> _send(String text) async {
    final clean = text.trim();
    if (clean.isEmpty || _sending) return;

    final history = _messages
        .where((m) => m.text.trim().isNotEmpty)
        .map(
          (m) => OrqubeAiChatTurn(
            role: m.fromUser ? 'user' : 'assistant',
            text: m.text,
          ),
        )
        .toList(growable: false);

    setState(() {
      _messages.add(_UiMessage(fromUser: true, text: clean, remoteAi: false));
      _sending = true;
    });
    _scrollToBottom();

    final reply = await OrqubeAiAssistantService().ask(
      message: clean,
      screen: widget.screen,
      projectData: widget.projectData,
      history: history,
    );

    if (!mounted) return;
    setState(() {
      _messages.add(
        _UiMessage(
          fromUser: false,
          text: reply.text,
          remoteAi: reply.remoteAi,
          betaFreeDailyLimit: reply.betaFreeDailyLimit,
          betaFreeRemaining: reply.betaFreeRemaining,
        ),
      );
      _sending = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }
}

class _UiMessage {
  const _UiMessage({
    required this.fromUser,
    required this.text,
    required this.remoteAi,
    this.betaFreeDailyLimit,
    this.betaFreeRemaining,
  });

  final bool fromUser;
  final String text;
  final bool remoteAi;
  final int? betaFreeDailyLimit;
  final int? betaFreeRemaining;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _UiMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .82,
        ),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: fromUser
                ? LaunchPalette.purple.withOpacity(.25)
                : LaunchPalette.panel2.withOpacity(.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: fromUser
                  ? LaunchPalette.purple.withOpacity(.50)
                  : Colors.white.withOpacity(.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!fromUser) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.smart_toy_outlined,
                      size: 15,
                      color: LaunchPalette.cyan,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      message.remoteAi
                          ? (message.betaFreeRemaining != null &&
                                  message.betaFreeDailyLimit != null
                              ? 'AI 답변 · 오늘 무료 ${message.betaFreeRemaining}/${message.betaFreeDailyLimit}회 남음'
                              : 'AI 답변')
                          : 'ORQUBE 안내',
                      style: const TextStyle(
                        color: LaunchPalette.cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
              ],
              SelectableText(
                message.text,
                style: const TextStyle(
                  color: LaunchPalette.text,
                  height: 1.48,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickQuestionButton extends StatelessWidget {
  const _QuickQuestionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? LaunchPalette.panel2.withOpacity(.96)
          : LaunchPalette.panel2.withOpacity(.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: Colors.white.withOpacity(.12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? LaunchPalette.text : LaunchPalette.muted,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideLine extends StatelessWidget {
  const _GuideLine(this.number, this.text);

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LaunchPalette.purple.withOpacity(.16),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: LaunchPalette.cyan,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: LaunchPalette.muted,
                height: 1.42,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
