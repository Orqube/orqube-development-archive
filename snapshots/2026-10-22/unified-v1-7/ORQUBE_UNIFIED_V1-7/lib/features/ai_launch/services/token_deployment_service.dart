import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../models/launch_chain.dart';
import 'browser_wallet_bridge.dart';

class TokenDeploymentResult {
  const TokenDeploymentResult({
    required this.chain,
    required this.network,
    required this.address,
    required this.txHash,
  });

  final String chain;
  final String network;
  final String address;
  final String txHash;
}

class TokenDeploymentService {
  TokenDeploymentService({
    FirebaseAuth? auth,
    http.Client? client,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _client = client ?? http.Client();

  final FirebaseAuth _auth;
  final http.Client _client;

  Future<TokenDeploymentResult> deploy({
    required String projectId,
    required String ownerUid,
    required Map<String, dynamic> projectData,
    required LaunchChain chain,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != ownerUid) {
      throw StateError('토큰 배포에는 소유자 로그인이 필요합니다.');
    }

    final totalSupply = _asPositiveInt(projectData['totalSupply']);
    final name = (projectData['name'] ?? '').toString().trim();
    final symbol = (projectData['symbol'] ?? '').toString().trim().toUpperCase();
    final rawFeatures = projectData['tokenFeatures'];
    final tokenFeatures = rawFeatures is Map
        ? Map<String, dynamic>.from(rawFeatures)
        : <String, dynamic>{};
    final burnable = tokenFeatures['burnable'] == true;
    final mintable = tokenFeatures['mintable'] == true;
    final pausable = tokenFeatures['pausable'] == true;
    final capSupply = mintable ? _asPositiveInt(tokenFeatures['capSupply']) : 0;
    if (name.isEmpty || symbol.isEmpty || totalSupply <= 0) {
      throw StateError('토큰 이름·심볼·발행량을 확인해 주세요.');
    }
    if (mintable && capSupply < totalSupply) {
      throw StateError('최대 발행량(Cap)은 최초 발행량보다 작을 수 없습니다.');
    }

    BrowserDeploymentResult browserResult;
    Map<String, dynamic> archive = <String, dynamic>{};

    if (chain.isEvm) {
      final compiled = await _compileEvmToken(
        name: name,
        symbol: symbol,
        totalSupply: totalSupply,
        burnable: burnable,
        mintable: mintable,
        pausable: pausable,
        capSupply: capSupply,
      );
      final bytecode = (compiled['bytecode'] ?? '').toString();
      if (!bytecode.startsWith('0x') || bytecode.length < 10) {
        throw StateError('EVM 배포 바이트코드를 만들지 못했습니다.');
      }
      browserResult = await BrowserWalletBridge.deployEvm(
        chain: chain.key,
        bytecode: bytecode,
      );
      archive = {
        'source': compiled['source'],
        'abi': compiled['abi'],
        'compilerVersion': compiled['compilerVersion'],
        'optimizer': compiled['optimizer'],
        'optimizerRuns': compiled['optimizerRuns'],
        'contractName': compiled['contractName'],
        'creationBytecode': compiled['creationBytecode'],
        'deployedBytecode': compiled['deployedBytecode'],
        'constructorArguments': compiled['constructorArguments'],
        'standardJsonInput': compiled['standardJsonInput'],
        'standardJsonOutput': compiled['standardJsonOutput'],
        'dependencyVersion': compiled['dependencyVersion'],
        'tokenFeatures': compiled['tokenFeatures'] ?? tokenFeatures,
      };
    } else {
      // Standard SPL Token mint. Name/symbol remain in ORQUBE project metadata;
      // on-chain metadata can be added as a separate Token Metadata step later.
      browserResult = await BrowserWalletBridge.deploySolana(
        decimals: 9,
        totalSupply: totalSupply,
      );
      archive = {
        'program': 'SPL Token Program',
        'decimals': 9,
        'metadataStatus': 'orqube_profile_only',
      };
    }

    final network = chain.testnetLabel;
    final actualWalletAddress =
        browserResult.walletAddress.trim().isNotEmpty
            ? browserResult.walletAddress.trim()
            : (projectData['testnetVerifiedWallet'] ??
                    projectData['walletAddress'] ??
                    '')
                .toString()
                .trim();
    if (actualWalletAddress.isEmpty) {
      throw StateError('실제 배포에 사용된 지갑 주소를 확인할 수 없습니다.');
    }
    await _finalizeDeployment(
      projectId: projectId,
      ownerUid: ownerUid,
      chain: chain,
      network: network,
      walletAddress: actualWalletAddress,
      name: name,
      symbol: symbol,
      totalSupply: totalSupply,
      address: browserResult.address,
      txHash: browserResult.txHash,
      archive: archive,
    );

    return TokenDeploymentResult(
      chain: chain.key,
      network: network,
      address: browserResult.address,
      txHash: browserResult.txHash,
    );
  }

  Future<void> _finalizeDeployment({
    required String projectId,
    required String ownerUid,
    required LaunchChain chain,
    required String network,
    required String walletAddress,
    required String name,
    required String symbol,
    required int totalSupply,
    required String address,
    required String txHash,
    required Map<String, dynamic> archive,
  }) async {
    final user = _auth.currentUser!;
    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) throw StateError('로그인 인증 토큰이 없습니다.');
    final firebaseProjectId = Firebase.app().options.projectId.trim();
    final uri = Uri.parse(
      'https://asia-northeast3-$firebaseProjectId.cloudfunctions.net/finalizeLaunchTestDeployment',
    );
    final response = await _client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'projectId': projectId,
        'ownerUid': ownerUid,
        'chain': chain.key,
        'network': network,
        'walletAddress': walletAddress,
        'name': name,
        'symbol': symbol,
        'totalSupply': totalSupply,
        'contractAddress': address,
        'txHash': txHash,
        'archive': archive,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      var code = '';
      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map) code = (decoded['error'] ?? '').toString();
      } catch (_) {}
      throw StateError('배포 결과 저장 실패 (${response.statusCode}) ${code.isEmpty ? '' : '· $code'}');
    }
  }

  Future<Map<String, dynamic>> _compileEvmToken({
    required String name,
    required String symbol,
    required int totalSupply,
    required bool burnable,
    required bool mintable,
    required bool pausable,
    required int capSupply,
  }) async {
    final user = _auth.currentUser!;
    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) throw StateError('로그인 인증 토큰이 없습니다.');
    final projectId = Firebase.app().options.projectId.trim();
    final uri = Uri.parse(
      'https://asia-northeast3-$projectId.cloudfunctions.net/compileLaunchEvmToken',
    );
    final response = await _client.post(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'name': name,
        'symbol': symbol,
        'totalSupply': totalSupply.toString(),
        'burnable': burnable,
        'mintable': mintable,
        'pausable': pausable,
        'capSupply': mintable ? capSupply.toString() : null,
      }),
    );
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final code = decoded is Map ? (decoded['error'] ?? '').toString() : '';
      throw StateError('EVM 토큰 컴파일 실패 (${response.statusCode}) ${code.isEmpty ? '' : '· $code'}');
    }
    if (decoded is! Map) throw StateError('컴파일 서버 응답 형식이 올바르지 않습니다.');
    final root = Map<String, dynamic>.from(decoded);
    final data = root['data'];
    if (data is! Map) throw StateError('컴파일 결과가 비어 있습니다.');
    return Map<String, dynamic>.from(data);
  }

  static int _asPositiveInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
  }
}
