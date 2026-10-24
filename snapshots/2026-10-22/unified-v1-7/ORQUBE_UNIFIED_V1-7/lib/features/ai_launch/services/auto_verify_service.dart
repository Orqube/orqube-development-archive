import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'browser_wallet_bridge.dart';

enum AutoVerifyPaymentMethod { kai, orbs }

enum AutoVerifyWalletProvider { metamask, kaiaWallet }

class AutoVerifyPolicy {
  // TEMPORARY MAINNET TEST MODE:
  // Keep this true while validating 10 KAI payment end-to-end.
  // After MetaMask + Kaia Wallet tests pass, set false and restore/use 500 KAI.
  static const bool kaiMainnetTestMode = true;
  static const double kaiMainnetTestFee = 10;
  static const double defaultKaiFee = 500;
  static const double defaultOrbsFee = 100;

  const AutoVerifyPolicy({
    required this.enabled,
    required this.kaiFee,
    required this.orbsFee,
    required this.kaiEnabled,
    required this.orbsEnabled,
    required this.treasuryAddress,
    required this.orbsContractAddress,
    required this.orbsDecimals,
  });

  final bool enabled;
  final double kaiFee;
  final double orbsFee;
  final bool kaiEnabled;
  final bool orbsEnabled;
  final String treasuryAddress;
  final String orbsContractAddress;
  final int orbsDecimals;

  bool get paymentConfigured =>
      RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(treasuryAddress);

  factory AutoVerifyPolicy.fromMap(Map<String, dynamic>? data) {
    final d = data ?? const <String, dynamic>{};
    final configuredKaiFee = _num(d['kaiFee'], defaultKaiFee);
    return AutoVerifyPolicy(
      enabled: d['enabled'] is bool ? d['enabled'] as bool : false,
      kaiFee: kaiMainnetTestMode ? kaiMainnetTestFee : configuredKaiFee,
      orbsFee: _num(d['orbsFee'], defaultOrbsFee),
      kaiEnabled: d['kaiEnabled'] is bool ? d['kaiEnabled'] as bool : false,
      orbsEnabled: d['orbsEnabled'] is bool ? d['orbsEnabled'] as bool : false,
      treasuryAddress: (d['treasuryAddress'] ?? '').toString().trim(),
      orbsContractAddress: (d['orbsContractAddress'] ?? '').toString().trim(),
      orbsDecimals: (d['orbsDecimals'] is num)
          ? (d['orbsDecimals'] as num).toInt()
          : 18,
    );
  }

  static double _num(dynamic value, double fallback) {
    final parsed = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');
    return parsed != null && parsed.isFinite && parsed > 0 ? parsed : fallback;
  }
}

class AutoVerifyService {
  AutoVerifyService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    http.Client? client,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final http.Client _client;

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchArchive(String projectId) =>
      _db.collection('launch_deployment_archives').doc(projectId).snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchPolicy() =>
      _db.collection('launch_config').doc('auto_verify').snapshots();

  Future<AutoVerifyPolicy> loadPolicy() async {
    final snap = await _db.collection('launch_config').doc('auto_verify').get();
    return AutoVerifyPolicy.fromMap(snap.data());
  }

  Future<String> connectPaymentWallet({
    required String projectId,
    required AutoVerifyWalletProvider provider,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('AUTO VERIFY 결제에는 로그인이 필요합니다.');

    final project = await _db.collection('launch_projects').doc(projectId).get();
    final data = project.data();
    if (data == null || data['ownerUid'] != user.uid) {
      throw StateError('프로젝트 소유자만 AUTO VERIFY 지갑을 연결할 수 있습니다.');
    }
    if ((data['chain'] ?? '').toString() != 'Kaia') {
      throw StateError('AUTO VERIFY 1차 버전은 Kaia 계약만 지원합니다.');
    }
    final network = (data['deploymentNetwork'] ?? '').toString().toLowerCase();
    if (!network.contains('mainnet')) {
      throw StateError('AUTO VERIFY 결제 지갑은 Kaia Mainnet 프로젝트에서만 연결합니다.');
    }

    final wallet = await BrowserWalletBridge.connectKaiaMainnet(
      useKaiaWallet: provider == AutoVerifyWalletProvider.kaiaWallet,
    );
    final address = wallet.address.trim();
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address)) {
      throw StateError('연결된 지갑 주소를 확인할 수 없습니다.');
    }

    final projectWallet = (data['walletAddress'] ?? '').toString().trim();
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(projectWallet)) {
      throw StateError('프로젝트의 Mainnet 배포 지갑 주소가 없습니다.');
    }
    if (projectWallet.toLowerCase() != address.toLowerCase()) {
      throw StateError(
        '선택한 지갑의 현재 계정이 프로젝트 배포 지갑과 다릅니다. '
        '결제 전송을 막았습니다. 같은 계정($projectWallet)을 선택해 주세요.',
      );
    }
    return address;
  }

  Future<String> pay({
    required String projectId,
    required AutoVerifyPaymentMethod method,
    required AutoVerifyWalletProvider provider,
    required String connectedWalletAddress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('AUTO VERIFY 결제에는 로그인이 필요합니다.');
    final policy = await loadPolicy();
    if (!policy.enabled) throw StateError('AUTO VERIFY 서비스가 현재 비활성화되어 있습니다.');
    if (!policy.paymentConfigured) {
      throw StateError('관리자가 AUTO VERIFY 운영지갑 주소를 아직 설정하지 않았습니다.');
    }

    final project = await _db.collection('launch_projects').doc(projectId).get();
    final data = project.data();
    if (data == null || data['ownerUid'] != user.uid) {
      throw StateError('프로젝트 소유자만 AUTO VERIFY를 신청할 수 있습니다.');
    }
    if ((data['chain'] ?? '').toString() != 'Kaia') {
      throw StateError('AUTO VERIFY 1차 버전은 Kaia 계약만 지원합니다.');
    }
    final network = (data['deploymentNetwork'] ?? '').toString().toLowerCase();
    if (!network.contains('mainnet')) {
      throw StateError('유료 AUTO VERIFY는 Kaia Mainnet 배포 계약에 적용됩니다.');
    }

    final payer = connectedWalletAddress.trim();
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(payer)) {
      throw StateError('CONNECT WALLET을 먼저 실행해 주세요.');
    }
    final projectWallet = (data['walletAddress'] ?? '').toString().trim();
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(projectWallet) ||
        projectWallet.toLowerCase() != payer.toLowerCase()) {
      throw StateError('연결 지갑이 프로젝트 Mainnet 배포 지갑과 다릅니다. 결제를 중단했습니다.');
    }

    final useKaiaWallet = provider == AutoVerifyWalletProvider.kaiaWallet;
    String txHash;
    if (method == AutoVerifyPaymentMethod.kai) {
      if (!policy.kaiEnabled) throw StateError('KAI 결제가 비활성화되어 있습니다.');
      final requiredWei = _decimalUnits(policy.kaiFee, 18);
      final balance = await BrowserWalletBridge.kaiaMainnetNativeBalance(
        walletAddress: payer,
        useKaiaWallet: useKaiaWallet,
      );
      if (balance <= requiredWei) {
        throw StateError(
          'KAI 잔액이 부족합니다. 결제 ${_amountText(policy.kaiFee)} KAI와 가스비가 추가로 필요합니다.',
        );
      }
      txHash = await BrowserWalletBridge.sendKaiaMainnetNative(
        toAddress: policy.treasuryAddress,
        amountKai: policy.kaiFee,
        useKaiaWallet: useKaiaWallet,
        expectedFrom: payer,
      );
    } else {
      if (!policy.orbsEnabled) throw StateError('ORBS 결제가 비활성화되어 있습니다.');
      if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(policy.orbsContractAddress)) {
        throw StateError('관리자가 ORBS 컨트랙트 주소를 아직 설정하지 않았습니다.');
      }
      final requiredOrbs = _decimalUnits(policy.orbsFee, policy.orbsDecimals);
      final orbsBalance = await BrowserWalletBridge.kaiaMainnetErc20Balance(
        contractAddress: policy.orbsContractAddress,
        walletAddress: payer,
        useKaiaWallet: useKaiaWallet,
      );
      if (orbsBalance < requiredOrbs) {
        throw StateError('ORBS 잔액이 부족합니다. ${_amountText(policy.orbsFee)} ORBS가 필요합니다.');
      }
      final gasBalance = await BrowserWalletBridge.kaiaMainnetNativeBalance(
        walletAddress: payer,
        useKaiaWallet: useKaiaWallet,
      );
      if (gasBalance <= BigInt.zero) {
        throw StateError('ORBS 전송 가스비로 사용할 KAI 잔액이 없습니다.');
      }
      txHash = await BrowserWalletBridge.sendKaiaMainnetErc20(
        contractAddress: policy.orbsContractAddress,
        toAddress: policy.treasuryAddress,
        amountUnits: requiredOrbs,
        useKaiaWallet: useKaiaWallet,
        expectedFrom: payer,
      );
    }

    await _call('confirmAutoVerifyPayment', {
      'projectId': projectId,
      'paymentMethod': method == AutoVerifyPaymentMethod.kai ? 'KAI' : 'ORBS',
      'walletProvider': provider == AutoVerifyWalletProvider.kaiaWallet
          ? 'KAIA_WALLET'
          : 'METAMASK',
      'txHash': txHash,
    });
    return txHash;
  }

  Future<void> requestVerify({required String projectId}) async {
    await _call('requestAutoVerify', {'projectId': projectId});
  }

  Future<void> retryVerify({required String projectId}) async {
    await _call('requestAutoVerify', {'projectId': projectId, 'retry': true});
  }

  Future<Map<String, dynamic>> _call(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('로그인이 필요합니다.');
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) throw StateError('로그인 인증 토큰이 없습니다.');
    final firebaseProjectId = Firebase.app().options.projectId.trim();
    final uri = Uri.parse(
      'https://asia-northeast3-$firebaseProjectId.cloudfunctions.net/$functionName',
    );
    final response = await _client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = decoded is Map ? (decoded['error'] ?? '').toString() : '';
      throw StateError(
        '$functionName 실패 (${response.statusCode})${code.isEmpty ? '' : ' · $code'}',
      );
    }
    if (decoded is Map && decoded['data'] is Map) {
      return Map<String, dynamic>.from(decoded['data'] as Map);
    }
    return <String, dynamic>{};
  }

  static BigInt _decimalUnits(double amount, int decimals) {
    final safeDecimals = decimals.clamp(0, 18).toInt();
    final fixed = amount.toStringAsFixed(safeDecimals);
    final parts = fixed.split('.');
    final whole = parts.first;
    final fraction = parts.length > 1
        ? parts[1].padRight(safeDecimals, '0')
        : ''.padRight(safeDecimals, '0');
    final text = '$whole$fraction'.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    return BigInt.parse(text.isEmpty ? '0' : text);
  }

  static String _amountText(double value) =>
      value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
}
