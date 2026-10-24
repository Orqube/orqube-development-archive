import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class TokenMarketingException implements Exception {
  const TokenMarketingException(this.message);
  final String message;

  @override
  String toString() => message;
}

class TokenMarketingResult {
  const TokenMarketingResult({
    required this.queueId,
    required this.tokenFitScore,
    required this.language,
    required this.platform,
    required this.headline,
  });

  final String queueId;
  final int tokenFitScore;
  final String language;
  final String platform;
  final String headline;
}

class TokenMarketingService {
  TokenMarketingService({FirebaseAuth? auth, http.Client? client})
      : _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  final FirebaseAuth _auth;
  final http.Client _client;

  Future<TokenMarketingResult> start({required String projectId}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const TokenMarketingException('AI Marketing은 로그인 후 시작할 수 있습니다.');
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw const TokenMarketingException('로그인 인증 토큰을 확인할 수 없습니다.');
    }

    final projectIdValue = Firebase.app().options.projectId.trim();
    if (projectIdValue.isEmpty) {
      throw const TokenMarketingException('Firebase 프로젝트 정보를 확인할 수 없습니다.');
    }
    final uri = Uri.parse(
      'https://asia-northeast3-$projectIdValue.cloudfunctions.net/startTokenLaunchMarketing',
    );

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              'content-type': 'application/json; charset=utf-8',
              'authorization': 'Bearer $idToken',
            },
            body: jsonEncode({'projectId': projectId}),
          )
          .timeout(const Duration(seconds: 95));

      final text = utf8.decode(response.bodyBytes);
      Map<String, dynamic> root = const {};
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map) root = Map<String, dynamic>.from(decoded);
      } catch (_) {}

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const TokenMarketingException('이 토큰의 AI Marketing을 시작할 권한이 없습니다.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = (root['message'] ?? root['error'] ?? text).toString();
        throw TokenMarketingException('AI Marketing 서버 오류 (${response.statusCode}): $message');
      }

      final payload = root['data'] is Map
          ? Map<String, dynamic>.from(root['data'] as Map)
          : root;
      return TokenMarketingResult(
        queueId: (payload['id'] ?? '').toString(),
        tokenFitScore: (payload['token_fit_score'] as num?)?.toInt() ?? 0,
        language: (payload['language'] ?? '').toString(),
        platform: (payload['platform'] ?? '').toString(),
        headline: (payload['promo_headline'] ?? '').toString(),
      );
    } on TimeoutException {
      throw const TokenMarketingException('AI Marketing 분석 시간이 길어지고 있습니다. 잠시 후 다시 시도해 주세요.');
    } on TokenMarketingException {
      rethrow;
    } catch (e) {
      throw TokenMarketingException('AI Marketing 연결 실패: $e');
    }
  }
}
