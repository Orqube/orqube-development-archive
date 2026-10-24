import 'dart:async';
import 'dart:convert';
import 'debate_effects.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class DebateRequestException implements Exception {
  DebateRequestException(this.message, {this.retryable = false});

  final String message;
  final bool retryable;

  @override
  String toString() => message;
}

class DebateApiService {
  // Optional override for a separately hosted development environment.
  // Never place the OpenAI key in this value or in the Flutter app.
  static const _override = String.fromEnvironment('DEBATE_API_URL');

  static Uri get endpoint {
    if (_override.isNotEmpty) return Uri.parse(_override);
    // Use the same deployed function on localhost, Hosting and custom domains.
    // An HTTPS origin alone does not guarantee a Firebase Hosting API rewrite.
    final project = Firebase.app().options.projectId;
    return Uri.parse(
      'https://asia-northeast3-$project.cloudfunctions.net/generateThreeWayDebate',
    );
  }

  static String _error(String code, int status) {
    switch (code) {
      case 'DEV_DEBATE_DISABLED':
        return '토론 서버가 비활성화되어 있습니다. DEBATE_ENABLED=true 설정 후 토론 함수를 재배포하세요.';
      case 'AUTH_REQUIRED':
      case 'AUTH_EXPIRED':
        return '로그인 인증이 만료되었습니다. 다시 로그인해 주세요.';
      case 'EMAIL_VERIFICATION_REQUIRED':
        return '이메일 인증 후 다시 로그인해 주세요.';
      case 'RATE_LIMIT':
        return '요청 간격 또는 일일 한도에 도달했습니다. 10초 이상 기다린 뒤 다시 시도해 주세요.';
      case 'AI_PROVIDER_ERROR':
        return 'AI 서비스 요청에 실패했습니다. 서버의 OPENAI_API_KEY와 API 크레딧·모델 설정을 확인하세요.';
      case 'INVALID_AI_OUTPUT':
      case 'AI_OUTPUT_INCOMPLETE':
        return 'AI 답변이 완성되지 않았습니다. 잠시 후 시민 질문을 다시 보내주세요.';
      case 'AI_REFUSED':
        return '이 질문에 대한 AI 답변을 생성하지 못했습니다. 질문 내용을 바꿔주세요.';
      case 'AI_TIMEOUT':
        return 'AI 응답 시간이 초과되었습니다. 잠시 후 다시 시도해 주세요.';
      case 'TOPIC_REQUIRED':
        return '토론 주제를 입력해 주세요.';
      default:
        if (status == 404)
          return '토론 서버를 찾을 수 없습니다. 토론 함수와 Hosting 연결 설정을 배포하세요.';
        if (status == 401 || status == 403)
          return '접근이 거부되었습니다. 로그인·이메일 인증 및 서버 호출 권한을 확인하세요.';
        if (status == 504) return '토론 서버 응답 시간이 초과되었습니다. 잠시 후 다시 시도하세요.';
        return '토론 서버 오류(HTTP $status, $code). Firebase 함수 로그를 확인하세요.';
    }
  }

  static Future<Map<String, dynamic>> generate(
    String topic,
    String question,
    List<Map<String, dynamic>> history, {
    bool summarize = false,
    bool presentation = false,
    List<Map<String, dynamic>> visuals = const [],
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('로그인 후 토론을 이용해 주세요.');
    await user.reload();
    final current = FirebaseAuth.instance.currentUser;
    if (current == null || current.uid != user.uid) {
      throw Exception('로그인 세션을 확인할 수 없습니다. 로그인 상태를 확인해 주세요.');
    }
    final token = await current.getIdToken(true);
    final http.Response response;
    try {
      response = await http
          .post(
            endpoint,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'topic': topic,
              'question': question,
              'history': history,
              'summarize': summarize,
              'comedy': !presentation && !summarize && DebateEffects.comedy,
              'presentation': presentation,
              'visuals': visuals,
            }),
          )
          .timeout(const Duration(seconds: 65));
    } on TimeoutException {
      throw DebateRequestException('토론 서버 응답 시간이 초과되었습니다.', retryable: true);
    } on http.ClientException {
      throw DebateRequestException('토론 서버 연결이 끊겼습니다.', retryable: true);
    }
    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) data = decoded;
    } on FormatException {
      // Undeployed Hosting routes may return index.html instead of JSON.
    }
    if (response.statusCode != 200) {
      final code = '${data?['error'] ?? 'NON_JSON_RESPONSE'}';
      throw DebateRequestException(
        _error(code, response.statusCode),
        retryable: response.statusCode >= 500 || code == 'RATE_LIMIT',
      );
    }
    if (data == null || data['data'] is! Map) {
      throw Exception(
        '토론 API 대신 웹 페이지 또는 잘못된 응답이 반환되었습니다. firebase.json의 API rewrite를 적용하고 Hosting을 다시 배포하세요.',
      );
    }
    final result = Map<String, dynamic>.from(data['data'] as Map);
    if (!presentation && !summarize && DebateEffects.comedy && result['comedyApplied'] != true) {
      throw DebateRequestException('서버에 풍자 패치가 반영되지 않았습니다. generateThreeWayDebate 함수를 재배포한 뒤 다시 시작하세요.');
    }
    if (presentation && result['presentationVersion'] != 1) {
      throw DebateRequestException('자료 동반형 서버 패치가 반영되지 않았습니다. generateThreeWayDebate 함수를 재배포해주세요.');
    }
    return result;
  }
}
