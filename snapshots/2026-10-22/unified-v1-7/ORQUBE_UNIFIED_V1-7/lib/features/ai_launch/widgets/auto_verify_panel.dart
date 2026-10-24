import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auto_verify_service.dart';
import 'launch_ui.dart';

class AutoVerifyPanel extends StatefulWidget {
  const AutoVerifyPanel({
    super.key,
    required this.projectId,
    required this.projectData,
    required this.isOwner,
  });

  final String projectId;
  final Map<String, dynamic> projectData;
  final bool isOwner;

  @override
  State<AutoVerifyPanel> createState() => _AutoVerifyPanelState();
}

class _AutoVerifyPanelState extends State<AutoVerifyPanel> {
  AutoVerifyPaymentMethod _selectedPaymentMethod = AutoVerifyPaymentMethod.kai;
  AutoVerifyWalletProvider _selectedWalletProvider =
      AutoVerifyWalletProvider.metamask;
  AutoVerifyWalletProvider? _connectedWalletProvider;
  String _connectedWalletAddress = '';
  bool _connectingWallet = false;
  bool _paying = false;

  @override
  Widget build(BuildContext context) {
    final service = AutoVerifyService();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: service.watchPolicy(),
      builder: (context, policySnap) {
        final policy = AutoVerifyPolicy.fromMap(policySnap.data?.data());
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: service.watchArchive(widget.projectId),
          builder: (context, archiveSnap) {
            final archive =
                archiveSnap.data?.data() ?? const <String, dynamic>{};
            final contract =
                (widget.projectData['contractAddress'] ?? '').toString();
            final deploymentNetwork = (widget.projectData['deploymentNetwork'] ??
                    archive['network'] ??
                    '')
                .toString();
            final paymentStatus =
                (archive['paymentStatus'] ?? 'NOT_PAID').toString();
            final verifyStatus =
                (archive['verificationStatus'] ?? 'NOT_VERIFIED').toString();
            final paymentTx = (archive['paymentTxHash'] ?? '').toString();
            final paymentProvider =
                (archive['paymentProvider'] ?? '').toString();
            final archiveSaved = archive.isNotEmpty;
            final isMainnet =
                deploymentNetwork.toLowerCase().contains('mainnet') &&
                    (widget.projectData['chain'] ?? archive['chain'] ?? '')
                            .toString() ==
                        'Kaia';
            final canPay = widget.isOwner &&
                contract.isNotEmpty &&
                archiveSaved &&
                isMainnet &&
                policy.enabled &&
                policy.paymentConfigured;
            final kaiAvailable = canPay && policy.kaiEnabled;
            final orbsAvailable = canPay &&
                policy.orbsEnabled &&
                policy.orbsContractAddress.isNotEmpty;
            final selectedAvailable =
                _selectedPaymentMethod == AutoVerifyPaymentMethod.kai
                    ? kaiAvailable
                    : orbsAvailable;
            final walletConnectedForSelection =
                _connectedWalletAddress.isNotEmpty &&
                    _connectedWalletProvider == _selectedWalletProvider;
            final selectedFeeText =
                _selectedPaymentMethod == AutoVerifyPaymentMethod.kai
                    ? '${_feeText(policy.kaiFee)} KAI'
                    : '${_feeText(policy.orbsFee)} ORBS';
            final paid = paymentStatus == 'PAYMENT_CONFIRMED';
            final failed = verifyStatus == 'VERIFY_FAILED';
            final verified = verifyStatus == 'VERIFIED';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LaunchSectionTitle(
                  title: 'ORQUBE AUTO VERIFY',
                  subtitle:
                      'Deploy → Archive → Pay → Verify → Save · Developer Center 유료 서비스',
                ),
                LaunchGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusLine(
                        label: 'Deployment',
                        value: contract.isEmpty ? 'NOT DEPLOYED' : 'DEPLOYED',
                        ok: contract.isNotEmpty,
                      ),
                      _StatusLine(
                        label: 'Deployment Archive',
                        value: archiveSaved ? 'SAVED' : 'NOT SAVED',
                        ok: archiveSaved,
                      ),
                      _StatusLine(
                        label: 'Payment',
                        value: paymentStatus,
                        ok: paid,
                      ),
                      if (paymentProvider.isNotEmpty)
                        _StatusLine(
                          label: 'Payment Wallet',
                          value: paymentProvider,
                          ok: paid,
                        ),
                      if (paymentTx.isNotEmpty)
                        _StatusLine(
                          label: 'Payment TX',
                          value: _short(paymentTx),
                          ok: paid,
                          copyValue: paymentTx,
                          copyMessage: '결제 TX Hash를 복사했습니다.',
                        ),
                      _StatusLine(
                        label: 'Source Verification',
                        value: verifyStatus,
                        ok: verified,
                      ),
                      const Divider(height: 26, color: LaunchPalette.line),
                      if (AutoVerifyPolicy.kaiMainnetTestMode) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: LaunchPalette.cyan.withOpacity(.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: LaunchPalette.cyan.withOpacity(.35),
                            ),
                          ),
                          child: const Text(
                            'MAINNET TEST MODE · KAI 결제는 현재 10 KAI로 고정 테스트합니다. MetaMask / Kaia Wallet 검증 완료 후 500 KAI 정책으로 복귀합니다.',
                            style: TextStyle(
                              color: LaunchPalette.cyan,
                              fontWeight: FontWeight.w800,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        '${_feeText(policy.kaiFee)} KAI  또는  ${_feeText(policy.orbsFee)} ORBS',
                        style: const TextStyle(
                          color: LaunchPalette.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '둘 중 하나만 선택하여 결제합니다. 본 비용은 KaiaScan이 부과하는 공식 소스검증 수수료가 아니라 ORQUBE의 소스관리·자동검증·Deployment Archive 서비스 이용료입니다.',
                        style: TextStyle(
                          color: LaunchPalette.muted,
                          height: 1.45,
                        ),
                      ),
                      if (!isMainnet) ...[
                        const SizedBox(height: 12),
                        const Text(
                          '현재 프로젝트는 Testnet 배포입니다. 유료 AUTO VERIFY 결제는 비활성화되어 있으며, Kaia Mainnet 배포·연결 후 활성화됩니다.',
                          style: TextStyle(
                            color: LaunchPalette.cyan,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                        ),
                      ] else if (!policy.paymentConfigured) ...[
                        const SizedBox(height: 12),
                        const Text(
                          '관리자 Economy Policy에서 AUTO VERIFY 운영지갑 주소를 설정하면 결제가 활성화됩니다.',
                          style: TextStyle(
                            color: LaunchPalette.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (widget.isOwner && !paid && !verified) ...[
                        const SizedBox(height: 18),
                        const Text(
                          '결제수단',
                          style: TextStyle(
                            color: LaunchPalette.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _PaymentOption(
                          value: AutoVerifyPaymentMethod.kai,
                          groupValue: _selectedPaymentMethod,
                          title: '${_feeText(policy.kaiFee)} KAI',
                          subtitle: AutoVerifyPolicy.kaiMainnetTestMode
                              ? 'Kaia Mainnet 실제 전송 · 현재 테스트 금액'
                              : 'Kaia Mainnet KAI 결제',
                          enabled: kaiAvailable,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedPaymentMethod = value);
                          },
                        ),
                        const SizedBox(height: 8),
                        _PaymentOption(
                          value: AutoVerifyPaymentMethod.orbs,
                          groupValue: _selectedPaymentMethod,
                          title: '${_feeText(policy.orbsFee)} ORBS',
                          subtitle: 'ORQUBE Utility Token 실제 전송',
                          enabled: orbsAvailable,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedPaymentMethod = value);
                          },
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          '지갑',
                          style: TextStyle(
                            color: LaunchPalette.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _WalletOption(
                          value: AutoVerifyWalletProvider.metamask,
                          groupValue: _selectedWalletProvider,
                          title: 'MetaMask',
                          subtitle: 'window.ethereum · Kaia Mainnet',
                          enabled: canPay,
                          onChanged: _selectWalletProvider,
                        ),
                        const SizedBox(height: 8),
                        _WalletOption(
                          value: AutoVerifyWalletProvider.kaiaWallet,
                          groupValue: _selectedWalletProvider,
                          title: 'Kaia Wallet',
                          subtitle: 'window.klaytn · Kaia Mainnet',
                          enabled: canPay,
                          onChanged: _selectWalletProvider,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '안전상 결제 지갑 계정은 이 Mainnet 프로젝트를 배포한 지갑 주소와 같아야 합니다. 서로 다른 확장지갑을 시험할 때는 같은 계정을 선택하거나 가져와 사용하세요.',
                          style: TextStyle(
                            color: LaunchPalette.muted,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: canPay && !_connectingWallet && !_paying
                                ? () => _connectWallet(
                                      context,
                                      service,
                                      _selectedWalletProvider,
                                    )
                                : null,
                            icon: _connectingWallet
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.account_balance_wallet_outlined),
                            label: Text(
                              walletConnectedForSelection
                                  ? 'CONNECTED · ${_walletLabel(_selectedWalletProvider)} · ${_short(_connectedWalletAddress)}'
                                  : 'CONNECT WALLET · ${_walletLabel(_selectedWalletProvider)}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: selectedAvailable &&
                                    walletConnectedForSelection &&
                                    !_paying &&
                                    !_connectingWallet
                                ? () => _payAndVerify(
                                      context,
                                      service,
                                      _selectedPaymentMethod,
                                      _selectedWalletProvider,
                                      _connectedWalletAddress,
                                    )
                                : null,
                            icon: _paying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.payments_outlined),
                            label: Text(
                              _paying
                                  ? 'PAYMENT / VERIFY 처리 중...'
                                  : 'PAY & VERIFY · $selectedFeeText',
                            ),
                          ),
                        ),
                      ],
                      if (widget.isOwner && paid && !verified) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _paying
                                ? null
                                : () => failed
                                    ? _retry(context, service)
                                    : _verify(context, service),
                            icon: Icon(
                              failed ? Icons.refresh : Icons.verified_outlined,
                            ),
                            label: Text(
                              failed
                                  ? 'RETRY VERIFY · 재결제 없음'
                                  : 'VERIFY NOW · 재결제 없음',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectWalletProvider(AutoVerifyWalletProvider? value) {
    if (value == null) return;
    setState(() {
      _selectedWalletProvider = value;
      _connectedWalletProvider = null;
      _connectedWalletAddress = '';
    });
  }

  Future<void> _connectWallet(
    BuildContext context,
    AutoVerifyService service,
    AutoVerifyWalletProvider provider,
  ) async {
    setState(() => _connectingWallet = true);
    try {
      final address = await service.connectPaymentWallet(
        projectId: widget.projectId,
        provider: provider,
      );
      if (!mounted) return;
      setState(() {
        _connectedWalletProvider = provider;
        _connectedWalletAddress = address;
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_walletLabel(provider)} 연결 완료 · Kaia Mainnet · ${_short(address)}',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('지갑 연결 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _connectingWallet = false);
    }
  }

  Future<void> _payAndVerify(
    BuildContext context,
    AutoVerifyService service,
    AutoVerifyPaymentMethod method,
    AutoVerifyWalletProvider provider,
    String connectedWalletAddress,
  ) async {
    setState(() => _paying = true);
    String? tx;
    try {
      tx = await service.pay(
        projectId: widget.projectId,
        method: method,
        provider: provider,
        connectedWalletAddress: connectedWalletAddress,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PAYMENT_CONFIRMED · ${_walletLabel(provider)} · ${_short(tx)} · Source Verification 시작',
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AUTO VERIFY 결제 실패 · 전송/확인 단계 중단: $e')),
        );
      }
      if (mounted) setState(() => _paying = false);
      return;
    }

    try {
      await service.requestVerify(projectId: widget.projectId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PAY & VERIFY 완료 · ${_short(tx)} · VERIFIED'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '결제는 PAYMENT_CONFIRMED로 유지됩니다. Source Verification 실패: $e · RETRY VERIFY는 재결제하지 않습니다.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _verify(
    BuildContext context,
    AutoVerifyService service,
  ) async {
    setState(() => _paying = true);
    try {
      await service.requestVerify(projectId: widget.projectId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KaiaScan 소스검증이 완료되었습니다.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('소스검증 실패: $e · 결제는 유지되며 RETRY할 수 있습니다.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _retry(
    BuildContext context,
    AutoVerifyService service,
  ) async =>
      _verify(context, service);

  static String _walletLabel(AutoVerifyWalletProvider provider) =>
      provider == AutoVerifyWalletProvider.kaiaWallet
          ? 'Kaia Wallet'
          : 'MetaMask';

  static String _short(String value) => value.length <= 18
      ? value
      : '${value.substring(0, 10)}…${value.substring(value.length - 6)}';

  static String _feeText(double value) =>
      value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onChanged,
  });

  final AutoVerifyPaymentMethod value;
  final AutoVerifyPaymentMethod groupValue;
  final String title;
  final String subtitle;
  final bool enabled;
  final ValueChanged<AutoVerifyPaymentMethod?> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = value == groupValue
        ? LaunchPalette.cyan.withOpacity(enabled ? .85 : .35)
        : Colors.white.withOpacity(enabled ? .16 : .07);

    return Container(
      decoration: BoxDecoration(
        color: value == groupValue
            ? LaunchPalette.cyan.withOpacity(enabled ? .10 : .04)
            : Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: RadioListTile<AutoVerifyPaymentMethod>(
        value: value,
        groupValue: groupValue,
        onChanged: enabled ? onChanged : null,
        activeColor: LaunchPalette.cyan,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        title: Text(
          title,
          style: TextStyle(
            color: enabled ? LaunchPalette.text : LaunchPalette.muted,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: enabled
                ? LaunchPalette.muted
                : LaunchPalette.muted.withOpacity(.65),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _WalletOption extends StatelessWidget {
  const _WalletOption({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onChanged,
  });

  final AutoVerifyWalletProvider value;
  final AutoVerifyWalletProvider groupValue;
  final String title;
  final String subtitle;
  final bool enabled;
  final ValueChanged<AutoVerifyWalletProvider?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Container(
      decoration: BoxDecoration(
        color: selected
            ? LaunchPalette.cyan.withOpacity(enabled ? .10 : .04)
            : Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? LaunchPalette.cyan.withOpacity(enabled ? .85 : .35)
              : Colors.white.withOpacity(enabled ? .16 : .07),
        ),
      ),
      child: RadioListTile<AutoVerifyWalletProvider>(
        value: value,
        groupValue: groupValue,
        onChanged: enabled ? onChanged : null,
        activeColor: LaunchPalette.cyan,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        title: Text(
          title,
          style: TextStyle(
            color: enabled ? LaunchPalette.text : LaunchPalette.muted,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: enabled
                ? LaunchPalette.muted
                : LaunchPalette.muted.withOpacity(.65),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.label,
    required this.value,
    required this.ok,
    this.copyValue,
    this.copyMessage = '복사했습니다.',
  });

  final String label;
  final String value;
  final bool ok;
  final String? copyValue;
  final String copyMessage;

  @override
  Widget build(BuildContext context) {
    final canCopy = (copyValue ?? '').trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.hourglass_top_rounded,
            size: 18,
            color: ok ? LaunchPalette.green : LaunchPalette.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: LaunchPalette.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: LaunchPalette.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (canCopy) ...[
            const SizedBox(width: 4),
            IconButton(
              tooltip: '복사',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: copyValue!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(copyMessage)),
                );
              },
              icon: const Icon(
                Icons.copy_rounded,
                size: 17,
                color: LaunchPalette.cyan,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
