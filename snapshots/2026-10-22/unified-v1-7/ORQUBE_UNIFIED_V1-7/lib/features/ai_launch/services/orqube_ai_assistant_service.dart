import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class OrqubeAiChatTurn {
  const OrqubeAiChatTurn({required this.role, required this.text});

  final String role;
  final String text;

  Map<String, String> toJson() => <String, String>{
        'role': role,
        'text': text,
      };
}

class OrqubeAiAssistantReply {
  const OrqubeAiAssistantReply({
    required this.text,
    required this.remoteAi,
    this.betaFreeDailyLimit,
    this.betaFreeRemaining,
    this.orbsCharged = 0,
  });

  final String text;
  final bool remoteAi;
  final int? betaFreeDailyLimit;
  final int? betaFreeRemaining;
  final num orbsCharged;
}

class OrqubeAiAssistantService {
  OrqubeAiAssistantService({
    FirebaseAuth? auth,
    http.Client? client,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  final FirebaseAuth _auth;
  final http.Client _client;

  Future<OrqubeAiAssistantReply> ask({
    required String message,
    required String screen,
    Map<String, dynamic>? projectData,
    List<OrqubeAiChatTurn> history = const <OrqubeAiChatTurn>[],
  }) async {
    final cleanMessage = message.trim();
    if (cleanMessage.isEmpty) {
      return const OrqubeAiAssistantReply(
        text: '궁금한 내용을 입력해 주세요.',
        remoteAi: false,
      );
    }

    final user = _auth.currentUser;
    if (user == null) {
      return OrqubeAiAssistantReply(
        text: _localGuide(cleanMessage, screen, projectData, loginRequired: true),
        remoteAi: false,
      );
    }

    try {
      final endpoint = _defaultFunctionUrl('orqubeAiAssistant');
      if (endpoint.isEmpty) {
        return OrqubeAiAssistantReply(
          text: _localGuide(cleanMessage, screen, projectData),
          remoteAi: false,
        );
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        return OrqubeAiAssistantReply(
          text: _localGuide(cleanMessage, screen, projectData, loginRequired: true),
          remoteAi: false,
        );
      }

      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: <String, String>{
              'content-type': 'application/json; charset=utf-8',
              'authorization': 'Bearer $token',
            },
            body: jsonEncode(<String, dynamic>{
              'message': cleanMessage,
              'screen': screen,
              'language': _containsHangul(cleanMessage) ? 'ko' : 'auto',
              'project': _safeProjectContext(projectData),
              'history': history
                  .takeLast(8)
                  .map((turn) => turn.toJson())
                  .toList(growable: false),
            }),
          )
          .timeout(const Duration(seconds: 40));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        try {
          final errorDecoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (response.statusCode == 429 &&
              errorDecoded is Map &&
              errorDecoded['error'] == 'DAILY_LIMIT') {
            return const OrqubeAiAssistantReply(
              text:
                  '오늘의 BETA AI 심층분석 무료 사용량을 모두 사용했습니다.\n\n'
                  '기본 안내와 가이드라인은 계속 무료로 이용할 수 있습니다. '
                  '고급 프로젝트 분석의 ORBS 선택 결제는 아직 준비 단계이며, 현재는 ORBS가 자동 차감되지 않습니다.',
              remoteAi: false,
              betaFreeDailyLimit: 10,
              betaFreeRemaining: 0,
              orbsCharged: 0,
            );
          }
        } catch (_) {
          // Fall through to the local guide below.
        }
        return OrqubeAiAssistantReply(
          text: _localGuide(cleanMessage, screen, projectData),
          remoteAi: false,
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) {
        return OrqubeAiAssistantReply(
          text: _localGuide(cleanMessage, screen, projectData),
          remoteAi: false,
        );
      }
      final root = Map<String, dynamic>.from(decoded);
      final payload = root['data'] is Map
          ? Map<String, dynamic>.from(root['data'] as Map)
          : root;
      final answer = (payload['answer'] ?? '').toString().trim();
      if (answer.isEmpty) {
        return OrqubeAiAssistantReply(
          text: _localGuide(cleanMessage, screen, projectData),
          remoteAi: false,
        );
      }
      final limit = _asInt(payload['betaFreeDailyLimit']);
      final remaining = _asInt(payload['betaFreeRemaining']);
      final orbsCharged = payload['orbsCharged'] is num
          ? payload['orbsCharged'] as num
          : num.tryParse('${payload['orbsCharged'] ?? 0}') ?? 0;
      return OrqubeAiAssistantReply(
        text: answer,
        remoteAi: true,
        betaFreeDailyLimit: limit,
        betaFreeRemaining: remaining,
        orbsCharged: orbsCharged,
      );
    } catch (_) {
      return OrqubeAiAssistantReply(
        text: _localGuide(cleanMessage, screen, projectData),
        remoteAi: false,
      );
    }
  }


  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String _defaultFunctionUrl(String functionName) {
    final projectId = Firebase.app().options.projectId.trim();
    if (projectId.isEmpty) return '';
    return 'https://asia-northeast3-$projectId.cloudfunctions.net/$functionName';
  }

  static Map<String, dynamic> _safeProjectContext(
    Map<String, dynamic>? data,
  ) {
    if (data == null || data.isEmpty) return const <String, dynamic>{};
    const allowed = <String>{
      'name',
      'symbol',
      'status',
      'chain',
      'deploymentNetwork',
      'totalSupply',
      'walletAddress',
      'testnetVerifiedWallet',
      'contractAddress',
      'txHash',
      'verificationStatus',
      'assetMode',
      'category',
      'orbsBalance',
      'starterStatus',
      'walletStatus',
      'firestoreAccountLoaded',
      'paymentStatus',
      'verificationTxHash',
      'launchWalletAddress',
      'networkMode',
    };
    final result = <String, dynamic>{};
    for (final key in allowed) {
      final value = data[key];
      if (value == null) continue;
      if (value is String || value is num || value is bool) {
        result[key] = value;
      }
    }
    return result;
  }

  static bool _containsHangul(String value) =>
      RegExp(r'[가-힣]').hasMatch(value);

  static String stateSummary(
    Map<String, dynamic>? data, {
    String screen = '',
  }) {
    if (data == null || data.isEmpty) {
      return '현재 화면: $screen\n프로젝트 정보가 아직 없어 일반 안내 모드입니다. 토큰 초안을 만들거나 내 토큰을 선택하면 단계별 상태를 인식합니다.';
    }

    String value(String key) => (data[key] ?? '').toString().trim();
    final name = value('name');
    final symbol = value('symbol');
    final wallet = value('testnetVerifiedWallet').isNotEmpty
        ? value('testnetVerifiedWallet')
        : (value('walletAddress').isNotEmpty
            ? value('walletAddress')
            : value('launchWalletAddress'));
    final contract = value('contractAddress');
    final payment = value('paymentStatus').toUpperCase();
    final verification = value('verificationStatus').toUpperCase();
    final network = value('deploymentNetwork').isNotEmpty
        ? value('deploymentNetwork')
        : value('networkMode');
    final supplyRaw = data['totalSupply'];
    final supply = supplyRaw is num
        ? supplyRaw.toInt()
        : int.tryParse('$supplyRaw'.replaceAll(',', '')) ?? 0;
    final created = name.isNotEmpty && symbol.isNotEmpty && supply > 0;
    final deployed = contract.isNotEmpty;
    final verified = verification == 'VERIFIED';
    final paid = payment == 'PAYMENT_CONFIRMED';
    final mainnet = value('chain').toLowerCase() == 'kaia' &&
        network.toLowerCase().contains('mainnet');

    final lifecycle = verified
        ? 'VERIFIED · 온체인 배포 + 소스검증 완료'
        : deployed
            ? 'DEPLOYED · 온체인 배포 완료 / 소스검증 전'
            : created
                ? 'INTERNAL · ORQUBE 내부 토큰 / 배포 없이 사용 가능'
                : 'DRAFT · 토큰 초안 작성 전 또는 미완성';

    String next;
    if (!created) {
      next = 'CREATE: 토큰명·심볼·발행량을 확인하고 초안을 완성하세요.';
    } else if (wallet.isEmpty) {
      next = 'WALLET: 사용할 지갑 주소를 연결·확인하세요.';
    } else if (!deployed) {
      next = '현재 내부 토큰으로 USE를 시작할 수 있습니다. 온체인이 필요하면 TEST 후 DEPLOY를 사용자가 선택하세요.';
    } else if (mainnet && !paid) {
      next = 'PAY: AUTO VERIFY를 원할 때 결제수단과 지갑을 확인한 뒤 사용자가 직접 승인하세요.';
    } else if (mainnet && paid && !verified) {
      next = 'VERIFY: 결제 확인 후 저장된 Deployment Archive로 소스검증을 진행하세요.';
    } else if (!verified) {
      next = '현재 배포 토큰을 USE할 수 있습니다. 소스검증은 네트워크/정책에 따라 선택해 진행하세요.';
    } else {
      next = 'USE: Reward·Membership·Campaign·Drops 등 사용 기능을 구성할 수 있습니다.';
    }

    final tokenLabel = name.isEmpty ? '미지정' : '$name${symbol.isEmpty ? '' : ' ($symbol)'}';
    final walletLabel = wallet.isEmpty
        ? '미연결'
        : wallet.length > 14
            ? '${wallet.substring(0, 8)}…${wallet.substring(wallet.length - 6)}'
            : wallet;
    final networkLabel = network.isEmpty ? '미선택' : network;
    return '토큰: $tokenLabel\n상태: $lifecycle\n네트워크: $networkLabel · 지갑: $walletLabel\n다음 안내: $next';
  }

  static String _localGuide(
    String message,
    String screen,
    Map<String, dynamic>? projectData, {
    bool loginRequired = false,
  }) {
    final q = message.toLowerCase();
    final projectWallet =
        (projectData?['testnetVerifiedWallet'] ?? projectData?['walletAddress'] ?? '')
            .toString()
            .trim();
    final contract = (projectData?['contractAddress'] ?? '').toString().trim();
    final chain = (projectData?['chain'] ?? '').toString().trim();
    final network = (projectData?['deploymentNetwork'] ?? '').toString().trim();

    String prefix = loginRequired
        ? '현재는 로그인 전 안내 모드입니다. 로그인하면 서버 AI와 대화할 수 있습니다.\n\n'
        : '현재 서버 AI 연결이 원활하지 않아 ORQUBE 안내 모드로 답변합니다.\n\n';

    if (q.contains('지갑') || q.contains('주소') || q.contains('metamask') || q.contains('kaia')) {
      final orbsBalance = projectData?['orbsBalance'];
      final starterStatus = (projectData?['starterStatus'] ?? '').toString();
      final firestoreLoaded = projectData?['firestoreAccountLoaded'] == true;
      return '${prefix}프로젝트 기준 지갑은 토큰 배포에 사용된 주소입니다.'
          '${projectWallet.isEmpty ? '' : '\n현재 프로젝트 주소: $projectWallet'}'
          '${firestoreLoaded && orbsBalance != null ? '\n현재 Launch ORBS 원장 잔액: $orbsBalance ORBS' : ''}'
          '${starterStatus.isNotEmpty ? '\nStarter 상태: $starterStatus' : ''}\n'
          'MetaMask와 Kaia Wallet은 각각 “주소 확인”을 눌러 현재 선택 계정을 비교하세요. '
          '주소가 다르면 결제·검증 전에 프로젝트 배포 계정과 같은 계정을 선택해야 합니다. '
          '비밀키·시드 문구·12단어 복구문구는 ORQUBE나 AI 채팅에 절대 입력하지 마세요.';
    }

    if (q.contains('배포') || q.contains('deploy') || q.contains('컨트랙트')) {
      return '${prefix}ORQUBE의 권장 흐름은 DESCRIBE → BUILD → TEST → DEPLOY → VERIFY → USE 입니다.\n'
          '${chain.isEmpty ? '' : '현재 체인: $chain${network.isEmpty ? '' : ' · $network'}\n'}'
          '${contract.isEmpty ? '현재 화면 정보상 컨트랙트 주소가 아직 없습니다. TEST 단계와 지갑 계정을 먼저 확인한 뒤 사용자가 직접 배포 승인하세요.' : '현재 컨트랙트 주소: $contract\n배포 후에는 Deployment Archive와 소스검증 상태를 확인하세요.'}';
    }

    if (q.contains('verify') || q.contains('검증') || q.contains('auto')) {
      return '${prefix}AUTO VERIFY는 배포 기록을 준비한 뒤 사용자가 결제수단과 지갑을 직접 선택하고 승인하는 구조입니다. '
          'AI가 결제나 지갑 서명을 대신 실행하지 않습니다. 결제 전 프로젝트 지갑과 현재 지갑 주소가 같은지 확인하세요.';
    }

    if (q.contains('다음') || q.contains('단계') || q.contains('뭘') || q.contains('무엇') || q.contains('상태')) {
      return '$prefix${stateSummary(projectData, screen: screen)}\n\n'
          'ORQUBE 기본 흐름은 DESCRIBE → BUILD → TEST → DEPLOY → VERIFY → USE이며, 배포 없이 내부 토큰으로 USE하는 선택도 가능합니다.';
    }

    return '${prefix}저는 ORQUBE AI Assistant입니다. 토큰 이름·발행량·지갑·테스트넷·배포·소스검증·사용처를 쉬운 말로 설명합니다. '
        '다만 지갑 서명, 토큰 배포, 결제, 공개, 외부 게시를 임의로 실행하지 않으며 사용자의 확인을 우선합니다. '
        '궁금한 기능이나 현재 보이는 오류 문구를 그대로 적어 주세요.';
  }
}

extension _TakeLastExtension<T> on Iterable<T> {
  Iterable<T> takeLast(int count) {
    final list = toList(growable: false);
    if (list.length <= count) return list;
    return list.sublist(list.length - count);
  }
}
