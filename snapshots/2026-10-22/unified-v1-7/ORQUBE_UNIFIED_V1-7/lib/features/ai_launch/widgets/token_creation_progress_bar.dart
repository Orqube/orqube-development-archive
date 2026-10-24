import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auto_verify_service.dart';
import '../services/token_creation_i18n.dart';
import 'launch_ui.dart';

enum TokenCreationStage {
  wallet,
  create,
  test,
  deploy,
  pay,
  verify,
  use,
  aiMarketing,
}

enum TokenCreationStepState { completed, current, locked }

extension TokenCreationStageUi on TokenCreationStage {
  String get label => switch (this) {
        TokenCreationStage.wallet => 'WALLET',
        TokenCreationStage.create => 'CREATE',
        TokenCreationStage.test => 'TEST',
        TokenCreationStage.deploy => 'DEPLOY',
        TokenCreationStage.pay => 'PAY',
        TokenCreationStage.verify => 'VERIFY',
        TokenCreationStage.use => 'USE',
        TokenCreationStage.aiMarketing => 'AI MARKETING',
      };

  String get helpKey => switch (this) {
        TokenCreationStage.wallet => 'help_wallet',
        TokenCreationStage.create => 'help_create',
        TokenCreationStage.test => 'help_test',
        TokenCreationStage.deploy => 'help_deploy',
        TokenCreationStage.pay => 'help_pay',
        TokenCreationStage.verify => 'help_verify',
        TokenCreationStage.use => 'help_use',
        TokenCreationStage.aiMarketing => 'help_aiMarketing',
      };
}

class TokenCreationProgressBar extends StatefulWidget {
  const TokenCreationProgressBar({
    super.key,
    required this.projectId,
    required this.ownerUid,
    required this.projectData,
    required this.onNavigate,
  });

  final String projectId;
  final String ownerUid;
  final Map<String, dynamic> projectData;
  final ValueChanged<TokenCreationStage> onNavigate;

  @override
  State<TokenCreationProgressBar> createState() =>
      _TokenCreationProgressBarState();
}

class _TokenCreationProgressBarState extends State<TokenCreationProgressBar> {
  TokenCreationStage? _expanded;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: AutoVerifyService().watchArchive(widget.projectId),
      builder: (context, snapshot) {
        final archive = snapshot.data?.data() ?? const <String, dynamic>{};
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: widget.ownerUid.isEmpty
              ? null
              : FirebaseFirestore.instance
                  .collection('launch_wallets')
                  .doc(widget.ownerUid)
                  .snapshots(),
          builder: (context, walletSnapshot) {
            final walletData =
                walletSnapshot.data?.data() ?? const <String, dynamic>{};
            final states = _states(widget.projectData, archive, walletData);
            final isTestnet = _isTestnet(widget.projectData);

            return LaunchGlassCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TokenCreationI18n.t('progressTitle'),
                style: const TextStyle(
                  color: LaunchPalette.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                TokenCreationI18n.t('progressSubtitle'),
                style: const TextStyle(
                  color: LaunchPalette.muted,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < TokenCreationStage.values.length - 1; i++) ...[
                      _StepChip(
                        stage: TokenCreationStage.values[i],
                        state: states[TokenCreationStage.values[i]]!,
                        selected: _expanded == TokenCreationStage.values[i],
                        onTap: () => setState(() {
                          final stage = TokenCreationStage.values[i];
                          _expanded = _expanded == stage ? null : stage;
                        }),
                      ),
                      if (i != TokenCreationStage.values.length - 2)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: LaunchPalette.muted,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              if (_expanded != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.045),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: LaunchPalette.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _expanded!.label,
                              style: const TextStyle(
                                color: LaunchPalette.cyan,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _StateBadge(state: states[_expanded!]!),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        TokenCreationI18n.t(_expanded!.helpKey),
                        style: const TextStyle(
                          color: LaunchPalette.text,
                          fontSize: 12.5,
                          height: 1.55,
                        ),
                      ),
                      if (isTestnet &&
                          (_expanded == TokenCreationStage.pay ||
                              _expanded == TokenCreationStage.verify)) ...[
                        const SizedBox(height: 8),
                        Text(
                          TokenCreationI18n.t('testnetPayNote'),
                          style: const TextStyle(
                            color: LaunchPalette.muted,
                            fontSize: 11.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onNavigate(_expanded!),
                          icon: const Icon(Icons.open_in_new_rounded, size: 17),
                          label: Text(TokenCreationI18n.t('goToStep')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
            );
          },
        );
      },
    );
  }

  Map<TokenCreationStage, TokenCreationStepState> _states(
    Map<String, dynamic> data,
    Map<String, dynamic> archive,
    Map<String, dynamic> walletData,
  ) {
    final walletDone =
        (data['walletAddress'] ?? '').toString().trim().isNotEmpty ||
            (data['testnetVerifiedWallet'] ?? '').toString().trim().isNotEmpty ||
            (walletData['walletAddress'] ?? '').toString().trim().isNotEmpty;
    final createDone = (data['name'] ?? '').toString().trim().isNotEmpty &&
        (data['symbol'] ?? '').toString().trim().isNotEmpty &&
        _positiveInt(data['totalSupply']) > 0;
    final deployDone =
        (data['contractAddress'] ?? '').toString().trim().isNotEmpty;
    final testDone = deployDone ||
        (data['testnetVerifiedWallet'] ?? '').toString().trim().isNotEmpty ||
        data['testnetVerifiedAt'] != null;
    final payDone =
        (archive['paymentStatus'] ?? '').toString() == 'PAYMENT_CONFIRMED';
    final verifyDone =
        (archive['verificationStatus'] ?? '').toString() == 'VERIFIED';
    final useDone = _hasConfiguredUse(data);
    final marketingDone =
        (data['aiMarketingQueueId'] ?? '').toString().trim().isNotEmpty ||
            data['aiMarketingStartedAt'] != null;
    final mainnet = _isMainnet(data);

    final completed = <TokenCreationStage>{
      if (walletDone) TokenCreationStage.wallet,
      if (createDone) TokenCreationStage.create,
      if (testDone) TokenCreationStage.test,
      if (deployDone) TokenCreationStage.deploy,
      if (payDone) TokenCreationStage.pay,
      if (verifyDone) TokenCreationStage.verify,
      if (useDone) TokenCreationStage.use,
      if (marketingDone) TokenCreationStage.aiMarketing,
    };

    TokenCreationStage? current;
    if (!walletDone) {
      current = TokenCreationStage.wallet;
    } else if (!createDone) {
      current = TokenCreationStage.create;
    } else if (!testDone && !deployDone) {
      current = TokenCreationStage.test;
    } else if (!deployDone) {
      current = TokenCreationStage.deploy;
    } else if (mainnet && !payDone) {
      current = TokenCreationStage.pay;
    } else if (mainnet && payDone && !verifyDone) {
      current = TokenCreationStage.verify;
    } else if (!useDone) {
      current = TokenCreationStage.use;
    } else if (!marketingDone) {
      current = TokenCreationStage.aiMarketing;
    }

    return {
      for (final stage in TokenCreationStage.values)
        stage: completed.contains(stage)
            ? TokenCreationStepState.completed
            : stage == current
                ? TokenCreationStepState.current
                : TokenCreationStepState.locked,
    };
  }

  bool _hasConfiguredUse(Map<String, dynamic> data) {
    final root = data['tokenUseConfig'];
    if (root is Map) {
      for (final value in root.values) {
        if (value is Map && value['configured'] == true) return true;
      }
    }
    final market = data['marketExpansion'];
    if (market is Map && market.values.any((value) => value == true)) return true;
    return (data['utilityStageIndex'] is num) || (data['marketStageIndex'] is num);
  }

  bool _isMainnet(Map<String, dynamic> data) {
    final network = (data['deploymentNetwork'] ?? '').toString().toLowerCase();
    return (data['chain'] ?? '').toString() == 'Kaia' &&
        network.contains('mainnet');
  }

  bool _isTestnet(Map<String, dynamic> data) => !_isMainnet(data) &&
      ((data['contractAddress'] ?? '').toString().trim().isNotEmpty ||
          (data['networkMode'] ?? '').toString().toLowerCase() == 'testnet');

  int _positiveInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.stage,
    required this.state,
    required this.selected,
    required this.onTap,
  });

  final TokenCreationStage stage;
  final TokenCreationStepState state;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      TokenCreationStepState.completed => LaunchPalette.green,
      TokenCreationStepState.current => LaunchPalette.cyan,
      TokenCreationStepState.locked => LaunchPalette.muted,
    };
    final icon = switch (state) {
      TokenCreationStepState.completed => Icons.check_circle_rounded,
      TokenCreationStepState.current => Icons.radio_button_checked_rounded,
      TokenCreationStepState.locked => Icons.lock_rounded,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(
            minWidth: stage == TokenCreationStage.aiMarketing ? 124 : 82,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: color.withOpacity(selected ? .16 : .08),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: color.withOpacity(selected ? .85 : .38),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 5),
              Text(
                stage.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});
  final TokenCreationStepState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      TokenCreationStepState.completed => LaunchPalette.green,
      TokenCreationStepState.current => LaunchPalette.cyan,
      TokenCreationStepState.locked => LaunchPalette.muted,
    };
    final text = switch (state) {
      TokenCreationStepState.completed => TokenCreationI18n.t('completed'),
      TokenCreationStepState.current => TokenCreationI18n.t('current'),
      TokenCreationStepState.locked => TokenCreationI18n.t('locked'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}
