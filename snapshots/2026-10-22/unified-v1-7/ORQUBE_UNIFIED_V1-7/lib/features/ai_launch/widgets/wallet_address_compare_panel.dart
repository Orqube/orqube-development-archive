import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/browser_wallet_bridge.dart';
import 'launch_ui.dart';

class WalletAddressComparePanel extends StatefulWidget {
  const WalletAddressComparePanel({
    super.key,
    required this.projectWalletAddress,
    required this.projectId,
    required this.ownerUid,
  });

  final String projectWalletAddress;
  final String projectId;
  final String ownerUid;

  @override
  State<WalletAddressComparePanel> createState() =>
      _WalletAddressComparePanelState();
}

class _WalletAddressComparePanelState extends State<WalletAddressComparePanel> {
  String _metamaskAddress = '';
  String _kaiaWalletAddress = '';
  String _resolvedProjectWallet = '';
  String _projectWalletSource = '';
  bool _loadingMetamask = false;
  bool _loadingKaia = false;
  bool _loadingProjectWallet = false;

  @override
  void initState() {
    super.initState();
    _resolvedProjectWallet = widget.projectWalletAddress.trim();
    _projectWalletSource = _resolvedProjectWallet.isEmpty ? '' : 'TOKEN PROFILE';
    _resolveProjectWallet();
  }

  @override
  void didUpdateWidget(covariant WalletAddressComparePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectWalletAddress != widget.projectWalletAddress ||
        oldWidget.projectId != widget.projectId ||
        oldWidget.ownerUid != widget.ownerUid) {
      _resolvedProjectWallet = widget.projectWalletAddress.trim();
      _projectWalletSource = _resolvedProjectWallet.isEmpty ? '' : 'TOKEN PROFILE';
      _resolveProjectWallet();
    }
  }

  bool _isEvmAddress(String value) =>
      RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(value.trim());

  Future<void> _resolveProjectWallet() async {
    final direct = widget.projectWalletAddress.trim();
    if (_isEvmAddress(direct)) {
      if (mounted) {
        setState(() {
          _resolvedProjectWallet = direct;
          _projectWalletSource = 'TOKEN PROFILE';
          _loadingProjectWallet = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _loadingProjectWallet = true);
    String resolved = '';
    String source = '';

    try {
      if (widget.projectId.trim().isNotEmpty) {
        final project = await FirebaseFirestore.instance
            .collection('launch_projects')
            .doc(widget.projectId.trim())
            .get();
        final projectData = project.data() ?? const <String, dynamic>{};
        for (final key in const ['testnetVerifiedWallet', 'walletAddress']) {
          final candidate = (projectData[key] ?? '').toString().trim();
          if (_isEvmAddress(candidate)) {
            resolved = candidate;
            source = key == 'testnetVerifiedWallet'
                ? 'PROJECT VERIFIED WALLET'
                : 'TOKEN PROFILE';
            break;
          }
        }
      }

      if (!_isEvmAddress(resolved) && widget.projectId.trim().isNotEmpty) {
        final archive = await FirebaseFirestore.instance
            .collection('launch_deployment_archives')
            .doc(widget.projectId.trim())
            .get();
        final candidate =
            (archive.data()?['walletAddress'] ?? '').toString().trim();
        if (_isEvmAddress(candidate)) {
          resolved = candidate;
          source = 'DEPLOYMENT ARCHIVE';
        }
      }

      if (!_isEvmAddress(resolved) && widget.ownerUid.trim().isNotEmpty) {
        final wallet = await FirebaseFirestore.instance
            .collection('launch_wallets')
            .doc(widget.ownerUid.trim())
            .get();
        final candidate =
            (wallet.data()?['walletAddress'] ?? '').toString().trim();
        if (_isEvmAddress(candidate)) {
          resolved = candidate;
          source = 'ACCOUNT WALLET';
        }
      }
    } catch (_) {
      // Keep the panel usable even when one Firestore source is unavailable.
    }

    if (!mounted) return;
    setState(() {
      _resolvedProjectWallet = resolved;
      _projectWalletSource = source;
      _loadingProjectWallet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectWallet = _isEvmAddress(widget.projectWalletAddress)
        ? widget.projectWalletAddress.trim()
        : _resolvedProjectWallet.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LaunchSectionTitle(
          title: 'WALLET ADDRESS CHECK',
          subtitle:
              '프로젝트 배포 지갑 · MetaMask · Kaia Wallet 주소를 전체 값으로 비교합니다.',
        ),
        LaunchGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AddressRow(
                title: 'PROJECT WALLET',
                subtitle: _projectWalletSource.isEmpty
                    ? 'TOKEN PROFILE → Deployment Archive → Account Wallet 순서로 확인'
                    : '주소 출처: $_projectWalletSource',
                address: projectWallet,
                emptyText: _loadingProjectWallet
                    ? '프로젝트 지갑 주소를 확인하는 중입니다...'
                    : '프로젝트/배포 기록에서 지갑 주소를 찾지 못했습니다.',
                reference: projectWallet,
                loading: _loadingProjectWallet,
              ),
              const Divider(height: 28, color: LaunchPalette.line),
              _AddressRow(
                title: 'METAMASK',
                subtitle: '현재 MetaMask에서 선택된 계정 주소',
                address: _metamaskAddress,
                emptyText: '아직 확인하지 않았습니다.',
                reference: projectWallet,
                loading: _loadingMetamask,
                actionLabel: 'MetaMask 주소 확인',
                onAction: _loadingMetamask ? null : () => _connect(false),
              ),
              const Divider(height: 28, color: LaunchPalette.line),
              _AddressRow(
                title: 'KAIA WALLET',
                subtitle: '현재 Kaia Wallet에서 선택된 계정 주소',
                address: _kaiaWalletAddress,
                emptyText: '아직 확인하지 않았습니다.',
                reference: projectWallet,
                loading: _loadingKaia,
                actionLabel: 'Kaia Wallet 주소 확인',
                onAction: _loadingKaia ? null : () => _connect(true),
              ),
              if (_projectWalletSource == 'ACCOUNT WALLET') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orangeAccent.withOpacity(.22),
                    ),
                  ),
                  child: const Text(
                    'TOKEN PROFILE/Deployment Archive에 배포 지갑이 없어 계정에 연결된 Kaia 지갑을 참고값으로 표시합니다. '
                    '실제 배포·결제 전에는 현재 지갑 주소를 다시 확인하세요.',
                    style: TextStyle(
                      color: LaunchPalette.muted,
                      height: 1.45,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LaunchPalette.cyan.withOpacity(.065),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LaunchPalette.cyan.withOpacity(.20)),
                ),
                child: const Text(
                  '주소 확인은 계정 주소만 읽습니다. 네트워크를 강제로 바꾸거나 전송·서명을 실행하지 않습니다. '
                  '비밀키·시드 문구·12단어 복구문구는 입력하지 마세요.',
                  style: TextStyle(
                    color: LaunchPalette.muted,
                    height: 1.45,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _connect(bool useKaiaWallet) async {
    setState(() {
      if (useKaiaWallet) {
        _loadingKaia = true;
      } else {
        _loadingMetamask = true;
      }
    });

    try {
      final result = await BrowserWalletBridge.connectAddressOnly(
        useKaiaWallet: useKaiaWallet,
      );
      if (!mounted) return;
      setState(() {
        if (useKaiaWallet) {
          _kaiaWalletAddress = result.address.trim();
        } else {
          _metamaskAddress = result.address.trim();
        }
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${useKaiaWallet ? 'Kaia Wallet' : 'MetaMask'} 주소를 확인했습니다.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('지갑 주소 확인 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          if (useKaiaWallet) {
            _loadingKaia = false;
          } else {
            _loadingMetamask = false;
          }
        });
      }
    }
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.title,
    required this.subtitle,
    required this.address,
    required this.emptyText,
    required this.reference,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String address;
  final String emptyText;
  final String reference;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final validAddress = RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address.trim());
    final validReference =
        RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(reference.trim());
    final same = validAddress &&
        validReference &&
        address.trim().toLowerCase() == reference.trim().toLowerCase();
    final different = validAddress && validReference && !same;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: LaunchPalette.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: LaunchPalette.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 9),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(.07)),
          ),
          child: SelectableText(
            address.trim().isEmpty ? emptyText : address.trim(),
            style: TextStyle(
              color: address.trim().isEmpty
                  ? LaunchPalette.muted
                  : LaunchPalette.text,
              fontFamily: 'monospace',
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ),
        if (same || different) ...[
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(
                same ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                size: 16,
                color: same ? LaunchPalette.green : Colors.orangeAccent,
              ),
              const SizedBox(width: 6),
              Text(
                same ? '프로젝트 배포 지갑과 일치합니다.' : '프로젝트 배포 지갑과 다른 주소입니다.',
                style: TextStyle(
                  color: same ? LaunchPalette.green : Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (address.trim().isNotEmpty)
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: address.trim()));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('지갑 주소를 복사했습니다.')),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 17),
                label: const Text('전체 주소 복사'),
              ),
            if (actionLabel != null)
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.account_balance_wallet_outlined, size: 17),
                label: Text(actionLabel!),
              ),
          ],
        ),
      ],
    );
  }
}
