import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/launch_wallet_repository.dart';
import '../services/browser_wallet_bridge.dart';
import '../models/launch_chain.dart';
import '../widgets/launch_ui.dart';
import '../widgets/orqube_ai_assistant.dart';

class LaunchWalletPage extends StatefulWidget {
  const LaunchWalletPage({super.key, required this.ownerUid});

  final String ownerUid;

  @override
  State<LaunchWalletPage> createState() => _LaunchWalletPageState();
}

class _LaunchWalletPageState extends State<LaunchWalletPage> {
  final _address = TextEditingController();
  final _repo = LaunchWalletRepository();
  bool _saving = false;
  bool _loading = true;
  bool _accountLoaded = false;
  bool _starterLoaded = false;
  bool _deployConfigLoaded = false;
  String? _accountError;
  String? _starterError;
  String? _deployConfigError;
  Map<String, dynamic> _account = const <String, dynamic>{};
  Map<String, dynamic> _starterRequest = const <String, dynamic>{};
  Map<String, dynamic> _deployConfig = const <String, dynamic>{};
  LaunchChain _chain = LaunchChain.kaia;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletAddress = (_account['walletAddress'] ?? '').toString();
    final storedChain = LaunchChainInfo.fromStored(
      (_account['chain'] ?? '').toString(),
    );
    final walletConnected = walletAddress.isNotEmpty;
    final balance = LaunchWalletRepository.numberAsDouble(
      _account['orbsBalance'],
    );
    final serverStarterStatus = (_account['starterStatus'] ?? '').toString();
    final requestStatus =
        (_starterRequest['status'] ?? 'not_requested').toString();
    final starterStatus =
        serverStarterStatus.isNotEmpty ? serverStarterStatus : requestStatus;
    final deployFee = LaunchWalletRepository.numberAsDouble(
      _deployConfig['deployFeeOrbs'],
    );
    final deployFeeConfigured = _deployConfigLoaded && deployFee > 0;
    final signedInUid = _repo.signedInUid;
    final loginMissing = widget.ownerUid.isNotEmpty && signedInUid.isEmpty;
    final uidMismatch = widget.ownerUid.isNotEmpty &&
        signedInUid.isNotEmpty &&
        widget.ownerUid != signedInUid;
    final hasReadError = loginMissing ||
        _accountError != null ||
        _starterError != null ||
        _deployConfigError != null ||
        uidMismatch;

    return LaunchBackground(
      floatingActionButton: OrqubeAiAssistantButton(
        screen: 'MULTICHAIN WALLET',
        projectData: <String, dynamic>{
          'walletAddress': walletAddress,
          'chain': (_account['chain'] ?? '').toString(),
          if (_accountLoaded) 'orbsBalance': balance,
          if (_accountLoaded || _starterLoaded) 'starterStatus': starterStatus,
          'walletStatus': (_account['walletStatus'] ?? '').toString(),
          'firestoreAccountLoaded': _accountLoaded,
        },
      ),
      appBar: launchAppBar('MULTICHAIN WALLET · ORBS'),
      child: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 48),
          children: [
            LaunchGlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LaunchStatusPill(
                    label: 'WALLET → ORBS → DEPLOY',
                    icon: Icons.account_balance_wallet_outlined,
                    active: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '토큰 배포에 사용할\n멀티체인 지갑과 ORBS',
                    style: TextStyle(
                      color: LaunchPalette.text,
                      fontSize: 27,
                      height: 1.18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    '개인키는 ORQUBE Firestore에 저장하지 않습니다. 현재 단계는 지갑 주소 연결과 ORBS Launch 잔액/Starter 상태를 준비합니다.',
                    style: TextStyle(color: LaunchPalette.muted, height: 1.5),
                  ),
                ],
              ),
            ),
            if (_loading) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(minHeight: 2),
            ],
            if (hasReadError) ...[
              const SizedBox(height: 14),
              LaunchGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firestore 읽기 상태를 확인해 주세요.',
                      style: TextStyle(
                        color: LaunchPalette.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (loginMissing)
                      const Text(
                        '로그인 세션을 확인할 수 없습니다. 다시 로그인한 뒤 이 화면을 열어 주세요.',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          height: 1.45,
                        ),
                      ),
                    if (uidMismatch)
                      Text(
                        '로그인 UID와 이 화면의 ownerUid가 다릅니다. 다시 로그인한 뒤 토큰 화면에서 지갑 메뉴를 열어 주세요.',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          height: 1.45,
                        ),
                      ),
                    if (_accountError != null)
                      _ReadStatusLine(
                        label: 'ORBS 잔액 · 지갑',
                        message: _friendlyFirestoreError(_accountError!),
                        ok: false,
                      )
                    else if (_accountLoaded)
                      const _ReadStatusLine(
                        label: 'ORBS 잔액 · 지갑',
                        message: '정상',
                        ok: true,
                      ),
                    if (_starterError != null)
                      _ReadStatusLine(
                        label: 'Starter 지급기록',
                        message: _friendlyFirestoreError(_starterError!),
                        ok: false,
                      )
                    else if (_starterLoaded)
                      const _ReadStatusLine(
                        label: 'Starter 지급기록',
                        message: '정상',
                        ok: true,
                      ),
                    if (_deployConfigError != null)
                      _ReadStatusLine(
                        label: 'Deploy 설정',
                        message: _friendlyFirestoreError(_deployConfigError!),
                        ok: false,
                      )
                    else if (_deployConfigLoaded)
                      const _ReadStatusLine(
                        label: 'Deploy 설정',
                        message: '정상',
                        ok: true,
                      ),
                    const SizedBox(height: 10),
                    const Text(
                      '읽기 실패 상태에서는 ORBS를 0으로 확정 표시하지 않습니다. Firestore 서버에 저장된 값과 화면 표시를 분리해 안전하게 처리합니다.',
                      style: TextStyle(
                        color: LaunchPalette.muted,
                        height: 1.45,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 불러오기'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const LaunchSectionTitle(
              title: 'ORBS LAUNCH BALANCE',
              subtitle: 'Kaia 지갑 연결 후 Starter 10 ORBS를 서버에서 1회 지급합니다.',
            ),
            LaunchGlassCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.blur_circular,
                    color: LaunchPalette.cyan,
                    size: 34,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AVAILABLE ORBS',
                          style: TextStyle(
                            color: LaunchPalette.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _accountLoaded
                              ? _formatOrbs(balance)
                              : _loading
                                  ? '불러오는 중…'
                                  : '확인 필요',
                          style: TextStyle(
                            color: _accountLoaded
                                ? LaunchPalette.text
                                : LaunchPalette.muted,
                            fontSize: _accountLoaded ? 26 : 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _accountLoaded
                              ? 'Firestore 서버 원장 확인됨'
                              : '읽기 실패를 실제 0 ORBS로 처리하지 않습니다.',
                          style: const TextStyle(
                            color: LaunchPalette.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  LaunchStatusPill(
                    label: !_accountLoaded && !_starterLoaded
                        ? 'STATUS UNKNOWN'
                        : _starterLabel(starterStatus),
                    active: (_accountLoaded || _starterLoaded) &&
                        (starterStatus == 'credited' ||
                            starterStatus == 'approved'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!_accountLoaded || !_starterLoaded)
              const LaunchGlassCard(
                child: Text(
                  '잔액과 Starter 지급기록 확인이 끝나기 전에는 중복 요청 방지를 위해 지급 버튼을 잠급니다.',
                  style: TextStyle(
                    color: LaunchPalette.muted,
                    height: 1.45,
                  ),
                ),
              )
            else if (starterStatus == 'not_requested' ||
                starterStatus == 'rejected')
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: const Color(0x99FFFFFF),
                ),
                onPressed: widget.ownerUid.isEmpty || _saving || uidMismatch
                    ? null
                    : _requestStarter,
                icon: const Icon(Icons.card_giftcard_outlined),
                label: Text(_saving ? '처리 중...' : 'Starter 10 ORBS 받기'),
              )
            else
              LaunchGlassCard(
                child: Text(
                  starterStatus == 'pending'
                      ? 'Starter ORBS 지급 요청을 처리 중입니다.'
                      : 'ORBS Starter 상태: ${_starterLabel(starterStatus)}',
                  style: const TextStyle(
                    color: LaunchPalette.muted,
                    height: 1.45,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const LaunchSectionTitle(
              title: 'MULTICHAIN WALLET',
              subtitle: 'MetaMask 연결 또는 주소 등록. 개인키는 ORQUBE가 보관하지 않습니다.',
            ),
            LaunchGlassCard(
              child:
                  walletConnected
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LaunchStatusPill(
                            label: '${storedChain.label} · CONNECTED',
                            icon: Icons.verified_outlined,
                            active: true,
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            walletAddress,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 9,
                            runSpacing: 9,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0x66FFFFFF),
                                  ),
                                ),
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: walletAddress),
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('지갑 주소를 복사했습니다.'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 17),
                                label: const Text('주소 복사'),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _saving ? null : _disconnect,
                                child: const Text('연결 해제'),
                              ),
                            ],
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<LaunchChain>(
                            value: _chain,
                            dropdownColor: const Color(0xFF171A28),
                            decoration: const InputDecoration(
                              labelText: 'Blockchain',
                            ),
                            items:
                                LaunchChain.values
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          '${c.label} · ${c.testnetLabel}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) => setState(
                                  () => _chain = v ?? LaunchChain.kaia,
                                ),
                          ),
                          if (_chain.isEvm &&
                              BrowserWalletBridge.isSupported) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _saving ? null : _connectMetaMask,
                                icon: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                ),
                                label: Text('MetaMask로 ${_chain.label} 연결'),
                              ),
                            ),
                          ],
                          if (_chain == LaunchChain.solana) ...[
                            const SizedBox(height: 10),
                            if (BrowserWalletBridge.isSolanaSupported)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _saving ? null : _connectSolana,
                                  icon: const Icon(
                                    Icons.account_balance_wallet_outlined,
                                  ),
                                  label: const Text('Solana Devnet 지갑 연결'),
                                ),
                              ),
                            const SizedBox(height: 8),
                            const Text(
                              'Phantom 등 호환 브라우저 지갑을 Devnet에 연결합니다. 개인키/복구문구는 ORQUBE가 저장하지 않습니다.',
                              style: TextStyle(
                                color: LaunchPalette.muted,
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          TextField(
                            controller: _address,
                            autocorrect: false,
                            enableSuggestions: false,
                            cursorColor: LaunchPalette.cyan,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              labelText: '기존 지갑 주소',
                              hintText:
                                  _chain == LaunchChain.solana
                                      ? 'Solana address'
                                      : '0x...',
                              labelStyle: TextStyle(
                                color: Color(0xFFCDD3E1),
                                fontWeight: FontWeight.w700,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              hintStyle: TextStyle(color: Color(0x99FFFFFF)),
                              filled: true,
                              fillColor: Color(0x0FFFFFFF),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x66FFFFFF),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: LaunchPalette.cyan,
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                foregroundColor: Colors.white,
                                disabledForegroundColor: const Color(
                                  0x99FFFFFF,
                                ),
                              ),
                              onPressed: _saving ? null : _connect,
                              icon: const Icon(Icons.link),
                              label: Text(
                                _saving ? '연결 중...' : '${_chain.label} 주소 연결',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0x66FFFFFF),
                                ),
                              ),
                              onPressed: _showNewWalletGuide,
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('새 지갑 만들기 안내'),
                            ),
                          ),
                        ],
                      ),
            ),
            const SizedBox(height: 20),
            const LaunchSectionTitle(
              title: 'TOKEN DEPLOY COST',
              subtitle: 'ORBS 비용은 운영 정책에서 설정하고 사용자 화면에 동일하게 표시합니다.',
            ),
            LaunchGlassCard(
              child: Column(
                children: [
                  _CostLine(
                    label: 'DEPLOY FEE',
                    value: !_deployConfigLoaded
                        ? '확인 필요'
                        : deployFeeConfigured
                            ? '${_formatOrbs(deployFee)} ORBS'
                            : '관리자 설정 필요',
                  ),
                  const Divider(height: 26, color: LaunchPalette.line),
                  _CostLine(
                    label: 'YOUR BALANCE',
                    value: _accountLoaded
                        ? '${_formatOrbs(balance)} ORBS'
                        : '확인 필요',
                  ),
                  const Divider(height: 26, color: LaunchPalette.line),
                  _CostLine(
                    label: 'STATUS',
                    value: !_accountLoaded || !_deployConfigLoaded
                        ? 'Firestore 확인 필요'
                        : !deployFeeConfigured
                            ? '비용 미설정'
                            : balance >= deployFee
                                ? '배포 비용 충족'
                                : 'ORBS 부족',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '※ 이 화면의 ORBS 잔액은 Launch용 서버 원장 값입니다. 실제 ORBS 온체인 전송/차감과 Token Deploy는 다음 Cloud Function 단계에서 트랜잭션 검증 후 실행합니다.',
              style: TextStyle(
                color: LaunchPalette.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _accountLoaded = false;
      _starterLoaded = false;
      _deployConfigLoaded = false;
      _accountError = null;
      _starterError = null;
      _deployConfigError = null;
    });

    // 중요한 잔액/지갑을 먼저 순차적으로 읽습니다. 한 개의 보조 문서가
    // 실패해도 Future.wait 전체가 실패하면서 잔액이 0처럼 보이지 않게 합니다.
    try {
      final account = await _repo.loadAccount(widget.ownerUid);
      if (!mounted) return;
      setState(() {
        _account = account;
        _accountLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _accountError = e.toString());
    }

    try {
      final starter = await _repo.loadStarterRequest(widget.ownerUid);
      if (!mounted) return;
      setState(() {
        _starterRequest = starter;
        _starterLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _starterError = e.toString());
    }

    try {
      final config = await _repo.loadDeployConfig();
      if (!mounted) return;
      setState(() {
        _deployConfig = config;
        _deployConfigLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _deployConfigError = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _connect() async {
    final value = _address.text.trim();
    if (!LaunchWalletRepository.isValidAddress(value, _chain.key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_chain.label} 지갑 주소를 확인해 주세요.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _repo.connectWallet(
        ownerUid: widget.ownerUid,
        walletAddress: value,
        chain: _chain.key,
      );
      try {
        await _repo.requestStarter(ownerUid: widget.ownerUid);
      } catch (_) {
        // 지갑 연결 자체는 유지하고 Starter는 화면의 재시도 버튼으로 복구합니다.
      }
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('지갑 연결 실패: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _connectMetaMask() async {
    if (!_chain.isEvm || _saving) return;
    setState(() => _saving = true);
    try {
      final result = await BrowserWalletBridge.connectEvm(chain: _chain.key);
      await _repo.connectWallet(
        ownerUid: widget.ownerUid,
        walletAddress: result.address,
        chain: result.chain,
      );
      try {
        await _repo.requestStarter(ownerUid: widget.ownerUid);
      } catch (_) {}
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('MetaMask 연결 실패: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _connectSolana() async {
    if (_chain != LaunchChain.solana || _saving) return;
    setState(() => _saving = true);
    try {
      final result = await BrowserWalletBridge.connectSolana();
      await _repo.connectWallet(
        ownerUid: widget.ownerUid,
        walletAddress: result.address,
        chain: result.chain,
      );
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Solana 지갑 연결 실패: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _saving = true);
    try {
      await _repo.disconnectWallet(ownerUid: widget.ownerUid);
      await _reload();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _requestStarter() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final amount = await _repo.requestStarter(ownerUid: widget.ownerUid);
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starter ${amount.toStringAsFixed(0)} ORBS가 지급되었습니다.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Starter 요청 실패: ${_friendlyFirestoreError(e.toString())}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showNewWalletGuide() {
    return showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('새 지갑 만들기'),
            content: const Text(
              'ORQUBE는 개인키나 복구문구를 저장하지 않습니다. KAIA/Polygon은 MetaMask에서 지갑 생성·서명을 진행하고, Solana는 MetaMask Connect 멀티체인 어댑터 또는 호환 지갑 서명 방식으로 연결합니다.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  static String _friendlyFirestoreError(String raw) {
    final text = raw.toLowerCase();
    if (text.contains('permission-denied') ||
        text.contains('permission_denied')) {
      return 'Firestore 권한 규칙을 확인해야 합니다.';
    }
    if (text.contains('unavailable') || text.contains('network')) {
      return '네트워크 또는 Firestore 연결 상태를 확인한 뒤 다시 시도해 주세요.';
    }
    if (text.contains('internal assertion failed') ||
        text.contains('unexpected state')) {
      return '브라우저 Firestore 내부 연결 오류입니다. 서버 직접 읽기와 재시도를 수행했지만 실패했습니다. 새로고침 후 다시 시도해 주세요.';
    }
    return raw.length > 180 ? '${raw.substring(0, 180)}…' : raw;
  }

  static String _formatOrbs(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(4);
  }

  static String _starterLabel(String status) {
    switch (status) {
      case 'pending':
        return 'STARTER PENDING';
      case 'approved':
        return 'STARTER APPROVED';
      case 'credited':
        return 'STARTER CREDITED';
      case 'rejected':
        return 'STARTER RETRY';
      default:
        return 'STARTER READY';
    }
  }
}

class _ReadStatusLine extends StatelessWidget {
  const _ReadStatusLine({
    required this.label,
    required this.message,
    required this.ok,
  });

  final String label;
  final String message;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: 16,
            color: ok ? LaunchPalette.green : Colors.orangeAccent,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '$label · $message',
              style: TextStyle(
                color: ok ? LaunchPalette.muted : Colors.orangeAccent,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostLine extends StatelessWidget {
  const _CostLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCDD3E1),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
