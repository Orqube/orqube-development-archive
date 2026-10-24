import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/launch_ui.dart';
import 'qr_reward_setup_page.dart';

/// Per-token operating console.
///
/// Important: this screen stores operating preferences only. It never deploys a
/// contract, sends a token, unlocks mainnet, or changes the current deployment
/// stage. This lets an issuer finish policy/security setup before deployment.
class DeveloperCenterPage extends StatefulWidget {
  const DeveloperCenterPage({
    super.key,
    required this.projectId,
    required this.projectData,
  });

  final String projectId;
  final Map<String, dynamic> projectData;

  @override
  State<DeveloperCenterPage> createState() => _DeveloperCenterPageState();
}

class _DeveloperCenterPageState extends State<DeveloperCenterPage> {
  final _amount = TextEditingController(text: '10');
  final _dailyLimit = TextEditingController(text: '1');
  final _totalLimit = TextEditingController(text: '1000');
  final _validDays = TextEditingController(text: '30');
  final _repeatEveryDays = TextEditingController(text: '1');
  final _maxClaimsPerWallet = TextEditingController(text: '30');
  final _cooldownHours = TextEditingController(text: '24');

  bool _saving = false;
  bool _qrEnabled = false;
  bool _guestClaimAllowed = true;
  bool _allowMetaMask = true;
  bool _allowKaia = true;
  bool _autoWalletEnabled = true;
  bool _requireWalletChoice = true;
  bool _duplicateWalletGuard = true;
  bool _duplicateDeviceGuard = true;
  bool _issuerApprovalRequired = true;
  bool _mainnetSecondConfirm = true;
  bool _txLogRequired = true;
  bool _blockRepeatedRequests = true;
  String _repeatPolicy = 'daily';
  String _preferredNetwork = 'testnet';

  Map<String, dynamic> get _settings {
    final raw = widget.projectData['developerSettings'];
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Map<String, dynamic> get _qrSettings {
    final raw = _settings['qrReward'];
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  String get _symbol => (widget.projectData['symbol'] ?? 'TOKEN').toString();
  String get _campaignDocId => '${widget.projectId}_default';
  String get _ownerUid => FirebaseAuth.instance.currentUser?.uid ?? (widget.projectData['ownerUid'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    final dev = _settings;
    final qr = _qrSettings;
    final existing = widget.projectData['qrReward'];
    final currentQr = existing is Map
        ? Map<String, dynamic>.from(existing)
        : <String, dynamic>{};

    String value(Map<String, dynamic> source, String key, Object fallback) =>
        '${source[key] ?? fallback}';

    _amount.text = value(qr, 'rewardAmount', currentQr['amount'] ?? 10);
    _dailyLimit.text = value(qr, 'dailyLimit', currentQr['dailyLimit'] ?? 1);
    _totalLimit.text = value(qr, 'totalLimit', currentQr['totalLimit'] ?? 1000);
    _validDays.text = value(qr, 'validDays', currentQr['validDays'] ?? 30);
    _repeatEveryDays.text = value(qr, 'repeatEveryDays', 1);
    _maxClaimsPerWallet.text = value(qr, 'maxClaimsPerWallet', 30);
    _cooldownHours.text = value(qr, 'cooldownHours', 24);

    _qrEnabled = qr['enabled'] ?? currentQr['enabled'] ?? false;
    _guestClaimAllowed = qr['guestClaimAllowed'] ?? true;
    _allowMetaMask = qr['allowMetaMask'] ?? true;
    _allowKaia = qr['allowKaia'] ?? true;
    _autoWalletEnabled = qr['autoWalletEnabled'] ?? true;
    _requireWalletChoice = qr['requireWalletChoice'] ?? true;
    _duplicateWalletGuard = qr['duplicateWalletGuard'] ?? true;
    _duplicateDeviceGuard = qr['duplicateDeviceGuard'] ?? true;
    _issuerApprovalRequired = dev['issuerApprovalRequired'] ?? true;
    _mainnetSecondConfirm = dev['mainnetSecondConfirm'] ?? true;
    _txLogRequired = dev['txLogRequired'] ?? true;
    _blockRepeatedRequests = dev['blockRepeatedRequests'] ?? true;
    _repeatPolicy = (qr['repeatPolicy'] ?? 'daily').toString();
    _preferredNetwork = (dev['preferredNetwork'] ??
            widget.projectData['networkMode'] ??
            'testnet')
        .toString();
    if (!const {'testnet', 'mainnet'}.contains(_preferredNetwork)) {
      _preferredNetwork = 'testnet';
    }
    if (!const {
      'once',
      'daily',
      'every_n_days',
      'monthly',
      'unlimited',
    }.contains(_repeatPolicy)) {
      _repeatPolicy = 'daily';
    }
  }

  @override
  void dispose() {
    for (final c in [
      _amount,
      _dailyLimit,
      _totalLimit,
      _validDays,
      _repeatEveryDays,
      _maxClaimsPerWallet,
      _cooldownHours,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _positiveDouble(TextEditingController c) {
    final n = double.tryParse(c.text.trim());
    return n != null && n > 0 ? n : null;
  }

  int? _positiveInt(TextEditingController c) {
    final n = int.tryParse(c.text.trim());
    return n != null && n > 0 ? n : null;
  }

  Future<void> _save() async {
    final amount = _positiveDouble(_amount);
    final daily = _positiveInt(_dailyLimit);
    final total = _positiveDouble(_totalLimit);
    final days = _positiveInt(_validDays);
    final everyDays = _positiveInt(_repeatEveryDays);
    final maxClaims = _positiveInt(_maxClaimsPerWallet);
    final cooldown = _positiveInt(_cooldownHours);

    if (amount == null ||
        daily == null ||
        total == null ||
        days == null ||
        everyDays == null ||
        maxClaims == null ||
        cooldown == null) {
      _message('수량·횟수·기간 설정은 0보다 큰 숫자로 입력해 주세요.');
      return;
    }
    if (!_allowMetaMask && !_allowKaia && !_autoWalletEnabled) {
      _message('MetaMask, Kaia Wallet, 자동지갑 중 최소 한 가지 수령 방법이 필요합니다.');
      return;
    }

    setState(() => _saving = true);
    final qr = <String, dynamic>{
      'enabled': _qrEnabled,
      'rewardAmount': amount,
      'dailyLimit': daily,
      'totalLimit': total,
      'validDays': days,
      'repeatPolicy': _repeatPolicy,
      'repeatEveryDays': everyDays,
      'maxClaimsPerWallet': maxClaims,
      'cooldownHours': cooldown,
      'guestClaimAllowed': _guestClaimAllowed,
      'allowMetaMask': _allowMetaMask,
      'allowKaia': _allowKaia,
      'autoWalletEnabled': _autoWalletEnabled,
      'requireWalletChoice': _requireWalletChoice,
      'duplicateWalletGuard': _duplicateWalletGuard,
      'duplicateDeviceGuard': _duplicateDeviceGuard,
    };

    try {
      await FirebaseFirestore.instance
          .collection('launch_projects')
          .doc(widget.projectId)
          .set({
        'developerSettings': {
          'version': 1,
          // The user explicitly wants deployment deferred while setup is done.
          'deploymentDeferred': true,
          'executionLocked': true,
          'preferredNetwork': _preferredNetwork,
          'liveTransferEnabled': false,
          'issuerApprovalRequired': _issuerApprovalRequired,
          'mainnetSecondConfirm': _mainnetSecondConfirm,
          'txLogRequired': _txLogRequired,
          'blockRepeatedRequests': _blockRepeatedRequests,
          'qrReward': qr,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      _message('Developer Center 설정을 저장했습니다. 배포와 실제 전송은 잠금 상태입니다.');
    } catch (e) {
      final text = e.toString();
      if (text.contains('b815') || text.contains('INTERNAL ASSERTION FAILED')) {
        _message('Firestore 웹 연결 상태가 초기화되지 않았습니다. 앱을 완전히 다시 실행한 뒤 다시 저장해 주세요.');
      } else {
        _message('Developer Center 저장 실패: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _numberField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: LaunchPalette.text, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: LaunchPalette.muted),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: LaunchPalette.cyan),
        ),
      ),
    );
  }

  Widget _switch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(
          color: LaunchPalette.text,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: LaunchPalette.muted, height: 1.35),
      ),
    );
  }

  String get _repeatLabel {
    switch (_repeatPolicy) {
      case 'once':
        return '1인 1회만';
      case 'daily':
        return '매일 재수령 가능';
      case 'every_n_days':
        return '${_repeatEveryDays.text}일마다 재수령';
      case 'monthly':
        return '월 1회';
      case 'unlimited':
        return '횟수 제한 없음';
      default:
        return _repeatPolicy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LaunchBackground(
      appBar: launchAppBar('DEVELOPER CENTER'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 48),
        children: [
          const LaunchSectionTitle(
            title: 'DEVELOPER CENTER',
            subtitle: '배포 전에 QR 보상·지갑·네트워크·보안·TX 운영 정책을 먼저 정합니다.',
          ),
          LaunchGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OPERATING STATUS',
                  style: TextStyle(
                    color: LaunchPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const LaunchStatusPill(
                      label: 'DEPLOYMENT · HOLD',
                      icon: Icons.lock_clock_outlined,
                      active: true,
                    ),
                    const LaunchStatusPill(
                      label: 'LIVE TRANSFER · OFF',
                      icon: Icons.power_settings_new,
                    ),
                    LaunchStatusPill(
                      label: _preferredNetwork.toUpperCase(),
                      icon: Icons.hub_outlined,
                      active: _preferredNetwork == 'testnet',
                    ),
                    LaunchStatusPill(
                      label: 'QR · ${_qrEnabled ? 'ON' : 'OFF'}',
                      icon: Icons.qr_code_2,
                      active: _qrEnabled,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '이 화면에서 저장해도 컨트랙트 배포·Mainnet 전송·PAY/VERIFY 활성화는 실행되지 않습니다.',
                  style: TextStyle(
                    color: LaunchPalette.muted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LaunchGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QR REWARD POLICY',
                  style: TextStyle(
                    color: LaunchPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _switch(
                  'QR 보상 기능',
                  '운영 정책을 미리 설정합니다. 실제 지급 전송은 계속 잠겨 있습니다.',
                  _qrEnabled,
                  (v) => setState(() => _qrEnabled = v),
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, c) {
                    final narrow = c.maxWidth < 620;
                    final width = narrow ? c.maxWidth : (c.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: width,
                          child: _numberField(
                            _amount,
                            '1회 지급량 ($_symbol)',
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _numberField(_dailyLimit, '1인 하루 최대 횟수'),
                        ),
                        SizedBox(
                          width: width,
                          child: _numberField(
                            _totalLimit,
                            '캠페인 총 지급 한도 ($_symbol)',
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _numberField(_validDays, '캠페인 유효 기간 (일)'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _repeatPolicy,
                  dropdownColor: LaunchPalette.panel2,
                  style: const TextStyle(color: LaunchPalette.text),
                  decoration: const InputDecoration(
                    labelText: '재수령 정책',
                    labelStyle: TextStyle(color: LaunchPalette.muted),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'once', child: Text('1인 1회만')),
                    DropdownMenuItem(value: 'daily', child: Text('매일')),
                    DropdownMenuItem(value: 'every_n_days', child: Text('N일마다')),
                    DropdownMenuItem(value: 'monthly', child: Text('월 1회')),
                    DropdownMenuItem(value: 'unlimited', child: Text('제한 없음')),
                  ],
                  onChanged: (v) => setState(() => _repeatPolicy = v ?? 'daily'),
                ),
                if (_repeatPolicy == 'every_n_days') ...[
                  const SizedBox(height: 12),
                  _numberField(_repeatEveryDays, '재수령 간격 (일)'),
                ],
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, c) {
                    final narrow = c.maxWidth < 620;
                    final width = narrow ? c.maxWidth : (c.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: width,
                          child: _numberField(_maxClaimsPerWallet, '지갑당 최대 누적 수령 횟수'),
                        ),
                        SizedBox(
                          width: width,
                          child: _numberField(_cooldownHours, '비정상 반복요청 차단 간격 (시간)'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  '현재 정책: $_repeatLabel',
                  style: const TextStyle(
                    color: LaunchPalette.cyan,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LaunchGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WALLET & RECEIVER',
                  style: TextStyle(
                    color: LaunchPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                _switch(
                  '비회원 QR 수령 허용',
                  'ORQUBE에 로그인하지 않은 고객도 공개 QR 수령화면에 진입할 수 있습니다.',
                  _guestClaimAllowed,
                  (v) => setState(() => _guestClaimAllowed = v),
                ),
                _switch(
                  'MetaMask 주소 수령',
                  '고객이 자신의 MetaMask 주소로 직접 받을 수 있게 합니다.',
                  _allowMetaMask,
                  (v) => setState(() => _allowMetaMask = v),
                ),
                _switch(
                  'Kaia Wallet 주소 수령',
                  '고객이 자신의 Kaia Wallet 주소로 직접 받을 수 있게 합니다.',
                  _allowKaia,
                  (v) => setState(() => _allowKaia = v),
                ),
                _switch(
                  '지갑이 없으면 자동지갑 생성',
                  '지갑이 없는 고객을 위해 자동지갑 지급 흐름을 사용합니다.',
                  _autoWalletEnabled,
                  (v) => setState(() => _autoWalletEnabled = v),
                ),
                _switch(
                  '수령 방법을 한 번 선택',
                  '기존 지갑 사용 또는 자동지갑 생성 중 고객이 직접 선택하게 합니다.',
                  _requireWalletChoice,
                  (v) => setState(() => _requireWalletChoice = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LaunchGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NETWORK & EXECUTION',
                  style: TextStyle(
                    color: LaunchPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _preferredNetwork,
                  dropdownColor: LaunchPalette.panel2,
                  style: const TextStyle(color: LaunchPalette.text),
                  decoration: const InputDecoration(
                    labelText: '향후 실행 기본 네트워크',
                    labelStyle: TextStyle(color: LaunchPalette.muted),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'testnet', child: Text('TESTNET 우선')),
                    DropdownMenuItem(value: 'mainnet', child: Text('MAINNET 준비값')),
                  ],
                  onChanged: (v) => setState(() => _preferredNetwork = v ?? 'testnet'),
                ),
                const SizedBox(height: 12),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.lock_outline, color: LaunchPalette.cyan),
                  title: Text(
                    '실제 전송 잠금',
                    style: TextStyle(
                      color: LaunchPalette.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    '현재 Developer Center에서는 LIVE 전송을 켤 수 없습니다. 배포 보류 방침을 유지합니다.',
                    style: TextStyle(color: LaunchPalette.muted),
                  ),
                  trailing: LaunchStatusPill(label: 'LOCKED', active: true),
                ),
                _switch(
                  '발행자 지갑 최종 승인',
                  '고객 요청이 들어와도 발행자 지갑 승인 전에는 실제 전송하지 않습니다.',
                  _issuerApprovalRequired,
                  (v) => setState(() => _issuerApprovalRequired = v),
                ),
                _switch(
                  'Mainnet 2차 확인',
                  'Mainnet 실행 전 별도 확인 단계를 요구합니다.',
                  _mainnetSecondConfirm,
                  (v) => setState(() => _mainnetSecondConfirm = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LaunchGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SECURITY & DUPLICATE GUARD',
                  style: TextStyle(
                    color: LaunchPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                _switch(
                  '동일 지갑 중복수령 방지',
                  '재수령 정책과 지급 간격을 지갑 주소 기준으로 적용합니다.',
                  _duplicateWalletGuard,
                  (v) => setState(() => _duplicateWalletGuard = v),
                ),
                _switch(
                  '동일 기기 반복요청 방지',
                  '기기 단서가 사용 가능한 경우 반복 요청 탐지에 함께 사용하도록 설정합니다.',
                  _duplicateDeviceGuard,
                  (v) => setState(() => _duplicateDeviceGuard = v),
                ),
                _switch(
                  '비정상 반복요청 자동 차단',
                  '짧은 시간 내 반복 요청을 운영 정책상 차단 대상으로 표시합니다.',
                  _blockRepeatedRequests,
                  (v) => setState(() => _blockRepeatedRequests = v),
                ),
                _switch(
                  'TX 기록 필수',
                  '실제 지급 완료는 TX Hash가 기록된 경우에만 완료 상태로 처리합니다.',
                  _txLogRequired,
                  (v) => setState(() => _txLogRequired = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _txSummary(),
          const SizedBox(height: 16),
          LaunchGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'QR REWARD DETAIL',
                  style: TextStyle(
                    color: LaunchPalette.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'QR 이미지, 고객 지급 대기 목록, MetaMask/Kaia Wallet 실제 지급 버튼은 기존 QR REWARD 화면을 그대로 사용합니다.',
                  style: TextStyle(color: LaunchPalette.muted, height: 1.45),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QrRewardSetupPage(
                        projectId: widget.projectId,
                        projectData: {
                          ...widget.projectData,
                          'developerSettings': {
                            ..._settings,
                            'qrReward': {
                              ..._qrSettings,
                              'enabled': _qrEnabled,
                              'rewardAmount': double.tryParse(_amount.text),
                              'dailyLimit': int.tryParse(_dailyLimit.text),
                              'totalLimit': double.tryParse(_totalLimit.text),
                              'validDays': int.tryParse(_validDays.text),
                              'repeatPolicy': _repeatPolicy,
                              'repeatEveryDays': int.tryParse(_repeatEveryDays.text),
                              'maxClaimsPerWallet': int.tryParse(_maxClaimsPerWallet.text),
                              'cooldownHours': int.tryParse(_cooldownHours.text),
                              'duplicateWalletGuard': _duplicateWalletGuard,
                              'duplicateDeviceGuard': _duplicateDeviceGuard,
                            },
                          },
                        },
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('QR REWARD 상세 운영 화면 열기'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? '저장 중...' : 'Developer Center 설정 저장'),
          ),
        ],
      ),
    );
  }

  Widget _txSummary() {
    return LaunchGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TX / CLAIM LOG',
            style: TextStyle(
              color: LaunchPalette.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '현재 캠페인의 고객 요청·지급 완료·실패 상태를 확인합니다.',
            style: TextStyle(color: LaunchPalette.muted),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _ownerUid.isEmpty
                ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
                : FirebaseFirestore.instance
                    .collection('qr_reward_claims')
                    .where('ownerUid', isEqualTo: _ownerUid)
                    .limit(100)
                    .snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Text(
                  'TX LOG를 불러오지 못했습니다: ${snap.error}',
                  style: const TextStyle(color: Colors.orangeAccent),
                );
              }
              if (!snap.hasData) return const LinearProgressIndicator();
              var pending = 0;
              var paid = 0;
              var failed = 0;
              for (final doc in snap.data!.docs) {
                final data = doc.data();
                if ((data['campaignDocId'] ?? '').toString() != _campaignDocId) {
                  continue;
                }
                final status = (data['status'] ?? '').toString();
                if (status == 'paid') {
                  paid++;
                } else if (status == 'reserved') {
                  pending++;
                } else if (status == 'failed' || status == 'rejected') {
                  failed++;
                }
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  LaunchStatusPill(label: '대기 $pending', icon: Icons.schedule),
                  LaunchStatusPill(
                    label: '지급완료 $paid',
                    icon: Icons.check_circle_outline,
                    active: paid > 0,
                  ),
                  LaunchStatusPill(
                    label: '실패 $failed',
                    icon: Icons.error_outline,
                    active: failed > 0,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _recentTxLogs(),
        ],
      ),
    );
  }

  Widget _recentTxLogs() {
    if (_ownerUid.isEmpty) {
      return const Text('TX LOG 조회에는 로그인이 필요합니다.', style: TextStyle(color: Colors.orangeAccent));
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('qr_reward_tx_logs')
          .where('ownerUid', isEqualTo: _ownerUid)
          .limit(100)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Text('TX 상세 LOG를 불러오지 못했습니다: ${snap.error}', style: const TextStyle(color: Colors.orangeAccent));
        }
        if (!snap.hasData) return const LinearProgressIndicator();
        final logs = snap.data!.docs
            .where((d) => (d.data()['campaignDocId'] ?? '').toString() == _campaignDocId)
            .toList();
        logs.sort((a, b) {
          final at = a.data()['createdAt'];
          final bt = b.data()['createdAt'];
          final am = at is Timestamp ? at.millisecondsSinceEpoch : 0;
          final bm = bt is Timestamp ? bt.millisecondsSinceEpoch : 0;
          return bm.compareTo(am);
        });
        final recent = logs.take(8).toList();
        if (recent.isEmpty) {
          return const Text('아직 기록된 TX가 없습니다.', style: TextStyle(color: LaunchPalette.muted));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RECENT TX', style: TextStyle(color: LaunchPalette.text, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...recent.map((doc) {
              final d = doc.data();
              final hash = (d['txHash'] ?? '').toString();
              final wallet = (d['walletAddress'] ?? '').toString();
              String short(String v) => v.length <= 16 ? v : '${v.substring(0, 8)}…${v.substring(v.length - 6)}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${d['amount'] ?? 0} ${d['symbol'] ?? _symbol} · ${short(wallet)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      SelectableText('TX ${short(hash)}', style: const TextStyle(color: LaunchPalette.muted, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
