import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class LaunchAiLogoOption {
  const LaunchAiLogoOption({
    required this.url,
    required this.style,
  });

  final String url;
  final String style;
}

class LaunchAiLogoException implements Exception {
  const LaunchAiLogoException(this.message);
  final String message;

  @override
  String toString() => message;
}

class LaunchAiLogoService {
  LaunchAiLogoService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    http.Client? client,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final http.Client _client;

  Future<List<LaunchAiLogoOption>> generate({
    required String idea,
    required String name,
    required String symbol,
    required String category,
    required String tagline,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const LaunchAiLogoException('AI 로고 생성은 로그인 후 사용할 수 있습니다.');
    }

    final config = await _readConfig();
    if (config.enabled == false) {
      throw const LaunchAiLogoException('AI 로고 생성이 현재 비활성화되어 있습니다.');
    }

    final endpoint = config.logoEndpointUrl.isNotEmpty
        ? config.logoEndpointUrl
        : _defaultFunctionUrl('generateLaunchLogoOptions');

    final uri = Uri.tryParse(endpoint);
    if (uri == null) {
      throw const LaunchAiLogoException('AI 로고 서버 주소를 확인할 수 없습니다.');
    }

    final localHttp = uri.scheme == 'http' &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1');
    if (uri.scheme != 'https' && !localHttp) {
      throw const LaunchAiLogoException('AI 로고 서버는 HTTPS 연결이 필요합니다.');
    }

    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw const LaunchAiLogoException('로그인 인증 토큰을 확인할 수 없습니다.');
    }

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'content-type': 'application/json; charset=utf-8',
              'authorization': 'Bearer $idToken',
            },
            body: jsonEncode({
              'idea': idea.trim(),
              'name': name.trim(),
              'symbol': symbol.trim().toUpperCase(),
              'category': category.trim(),
              'tagline': tagline.trim(),
              'chain': 'multichain',
              'count': 1,
            }),
          )
          .timeout(const Duration(seconds: 175));

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const LaunchAiLogoException('AI 로고 생성에는 로그인이 필요합니다.');
      }
      if (response.statusCode == 402) {
        try {
          final body = jsonDecode(utf8.decode(response.bodyBytes));
          final required = body is Map ? body['requiredOrbs'] : 3;
          final balance = body is Map ? body['balance'] : 0;
          throw LaunchAiLogoException(
            '첫 무료 로고를 이미 사용했습니다. 추가 로고는 1개당 ${required ?? 3} ORBS가 필요합니다. 현재 잔액: ${balance ?? 0} ORBS',
          );
        } on LaunchAiLogoException {
          rethrow;
        } catch (_) {
          throw const LaunchAiLogoException('추가 AI 로고 생성에는 3 ORBS가 필요합니다.');
        }
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw LaunchAiLogoException(
          'AI 로고 서버 응답 오류 (${response.statusCode}): ${utf8.decode(response.bodyBytes)}',
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) {
        throw const LaunchAiLogoException('AI 로고 응답 형식을 확인할 수 없습니다.');
      }
      final root = Map<String, dynamic>.from(decoded);
      final payload = root['data'] is Map
          ? Map<String, dynamic>.from(root['data'] as Map)
          : root;
      final rawLogos = payload['logos'];
      if (rawLogos is! List) {
        throw const LaunchAiLogoException('AI 로고 후보가 반환되지 않았습니다.');
      }

      final result = <LaunchAiLogoOption>[];
      for (final item in rawLogos) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final url = (map['url'] ?? '').toString().trim();
        if (!url.startsWith('https://') &&
            !url.startsWith('http://localhost') &&
            !url.startsWith('http://127.0.0.1')) {
          continue;
        }
        result.add(
          LaunchAiLogoOption(
            url: url,
            style: (map['style'] ?? 'AI LOGO').toString().trim(),
          ),
        );
      }

      if (result.isEmpty) {
        throw const LaunchAiLogoException('사용 가능한 AI 로고 후보가 없습니다.');
      }
      return result.take(1).toList(growable: false);
    } on TimeoutException {
      throw const LaunchAiLogoException('AI 로고 생성 시간이 길어지고 있습니다. 잠시 후 다시 시도해 주세요.');
    } on LaunchAiLogoException {
      rethrow;
    } on http.ClientException catch (e) {
      throw LaunchAiLogoException(
        'AI 로고 서버에 연결하지 못했습니다. AI 전용 Functions(codebase: ai)의 generateLaunchLogoOptions 배포, CORS, OPENAI_API_KEY를 확인하세요. [$endpoint] · $e',
      );
    } catch (e) {
      throw LaunchAiLogoException('AI 로고 생성 실패: $e');
    }
  }

  Future<_AiGenerationConfig> _readConfig() async {
    try {
      final snap = await _db.collection('launch_config').doc('ai_generation').get();
      final data = snap.data();
      if (data == null) return const _AiGenerationConfig();
      return _AiGenerationConfig(
        enabled: data['enabled'] != false,
        logoEndpointUrl: (data['logoEndpointUrl'] ?? '').toString().trim(),
      );
    } catch (_) {
      return const _AiGenerationConfig();
    }
  }

  String _defaultFunctionUrl(String functionName) {
    final projectId = Firebase.app().options.projectId.trim();
    if (projectId.isEmpty) return '';
    return 'https://asia-northeast3-$projectId.cloudfunctions.net/$functionName';
  }
}

class _AiGenerationConfig {
  const _AiGenerationConfig({
    this.enabled = true,
    this.logoEndpointUrl = '',
  });

  final bool enabled;
  final String logoEndpointUrl;
}
