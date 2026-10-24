import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class LaunchWalletRepository {
  LaunchWalletRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    http.Client? client,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final http.Client _client;

  DocumentReference<Map<String, dynamic>> _account(String ownerUid) =>
      _db.collection('launch_wallets').doc(ownerUid);

  String get signedInUid => _auth.currentUser?.uid ?? '';

  Future<Map<String, dynamic>> loadAccount(String ownerUid) async {
    if (ownerUid.isEmpty) return const <String, dynamic>{};
    return _readFresh(_account(ownerUid), label: 'launch_wallets/$ownerUid');
  }

  Future<Map<String, dynamic>> loadStarterRequest(String ownerUid) async {
    if (ownerUid.isEmpty) return const <String, dynamic>{};
    return _readFresh(
      _db.collection('launch_starter_requests').doc(ownerUid),
      label: 'launch_starter_requests/$ownerUid',
    );
  }

  Future<Map<String, dynamic>> loadDeployConfig() async {
    return _readFresh(
      _db.collection('launch_config').doc('token_deploy'),
      label: 'launch_config/token_deploy',
    );
  }

  /// Firestore Web can occasionally leave the local client in an internal
  /// assertion/unexpected-state condition after a long-running browser tab.
  /// For wallet balances we prefer an authoritative server read first and
  /// retry once using the normal SDK source. This avoids showing a false 0
  /// just because one local-cache read failed.
  Future<Map<String, dynamic>> _readFresh(
    DocumentReference<Map<String, dynamic>> ref, {
    required String label,
  }) async {
    Object? firstError;
    try {
      final snapshot = await ref
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 12));
      return snapshot.data() ?? const <String, dynamic>{};
    } catch (e) {
      firstError = e;
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
    try {
      final snapshot = await ref.get().timeout(const Duration(seconds: 12));
      return snapshot.data() ?? const <String, dynamic>{};
    } catch (e) {
      throw StateError(
        '$label 읽기 실패. server=$firstError / retry=$e',
      );
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchAccount(String ownerUid) {
    return _account(ownerUid).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDeployConfig() {
    return _db.collection('launch_config').doc('token_deploy').snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchStarterRequest(String ownerUid) {
    return _db.collection('launch_starter_requests').doc(ownerUid).snapshots();
  }

  Future<void> connectWallet({
    required String ownerUid,
    required String walletAddress,
    String chain = 'Kaia',
  }) async {
    final address = walletAddress.trim();
    if (!isValidAddress(address, chain)) {
      throw ArgumentError('선택한 체인의 올바른 지갑 주소가 아닙니다.');
    }

    await _account(ownerUid).set({
      'ownerUid': ownerUid,
      'walletAddress': address,
      'chain': chain,
      'walletStatus': 'connected',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> disconnectWallet({required String ownerUid}) {
    return _account(ownerUid).set({
      'walletAddress': null,
      'walletStatus': 'disconnected',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<double> requestStarter({required String ownerUid}) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != ownerUid) {
      throw StateError('Starter ORBS 지급에는 로그인이 필요합니다.');
    }
    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw StateError('로그인 인증 토큰을 확인할 수 없습니다.');
    }
    final projectId = Firebase.app().options.projectId.trim();
    if (projectId.isEmpty) {
      throw StateError('Firebase Project ID를 확인할 수 없습니다.');
    }
    final uri = Uri.parse(
      'https://asia-northeast3-$projectId.cloudfunctions.net/claimLaunchStarter',
    );
    final response = await _client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'authorization': 'Bearer $idToken',
      },
      body: jsonEncode(const <String, dynamic>{}),
    );
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = decoded is Map ? (decoded['error'] ?? '').toString() : '';
      if (code == 'WALLET_REQUIRED') {
        throw StateError('Kaia 지갑을 먼저 연결해 주세요.');
      }
      throw StateError('Starter ORBS 서버 처리 실패 (${response.statusCode})');
    }
    if (decoded is! Map) return 0;
    final root = Map<String, dynamic>.from(decoded);
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    return numberAsDouble(data['starterOrbs']);
  }

  static bool isValidAddress(String value, String chain) {
    if (chain == 'Solana') {
      return RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$').hasMatch(value.trim());
    }
    return isValidKaiaAddress(value);
  }

  static bool isValidKaiaAddress(String value) {
    return RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(value.trim());
  }

  static double numberAsDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
