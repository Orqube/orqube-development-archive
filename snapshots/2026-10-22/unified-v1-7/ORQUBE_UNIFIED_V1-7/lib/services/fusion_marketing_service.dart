import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class FusionMarketingException implements Exception {
  const FusionMarketingException(this.message);
  final String message;
  @override
  String toString() => message;
}

class FusionCampaignResult {
  const FusionCampaignResult({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;
}

class FusionMarketingService {
  FusionMarketingService({FirebaseAuth? auth, http.Client? client})
      : _auth = auth ?? FirebaseAuth.instance,
        _client = client ?? http.Client();

  final FirebaseAuth _auth;
  final http.Client _client;

  Future<FusionCampaignResult> generate({
    required String campaignType,
    required String campaignName,
    required String objective,
    required String coreMessage,
    required String audience,
    required String country,
    required String language,
    required List<String> channels,
    String projectId = '',
    String callToAction = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const FusionMarketingException('로그인 후 이용할 수 있습니다.');
    final token = await user.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw const FusionMarketingException('로그인 인증을 확인할 수 없습니다.');
    }
    final firebaseProject = Firebase.app().options.projectId.trim();
    final uri = Uri.parse(
      'https://asia-northeast3-$firebaseProject.cloudfunctions.net/createFusionMarketingCampaign',
    );
    try {
      final response = await _client.post(
        uri,
        headers: {
          'content-type': 'application/json; charset=utf-8',
          'authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'campaignType': campaignType,
          'campaignName': campaignName,
          'objective': objective,
          'coreMessage': coreMessage,
          'audience': audience,
          'country': country,
          'language': language,
          'channels': channels,
          'projectId': projectId,
          'callToAction': callToAction,
        }),
      ).timeout(const Duration(seconds: 110));
      final text = utf8.decode(response.bodyBytes);
      Map<String, dynamic> root = {};
      try {
        root = Map<String, dynamic>.from(jsonDecode(text) as Map);
      } catch (_) {}
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = (root['message'] ?? root['error'] ?? text).toString();
        throw FusionMarketingException('캠페인 생성 실패 (${response.statusCode}): $message');
      }
      final payload = root['data'] is Map
          ? Map<String, dynamic>.from(root['data'] as Map)
          : root;
      return FusionCampaignResult(
        id: (payload['id'] ?? '').toString(),
        data: payload,
      );
    } on TimeoutException {
      throw const FusionMarketingException('AI 생성 시간이 길어지고 있습니다. 잠시 후 다시 시도해 주세요.');
    } on FusionMarketingException {
      rethrow;
    } catch (e) {
      throw FusionMarketingException('AI Marketing 연결 실패: $e');
    }
  }

  Future<Map<String, dynamic>> workflow({
    required String campaignId,
    required String action,
    String channel = '',
    String publishedUrl = '',
    String note = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const FusionMarketingException('로그인 후 이용할 수 있습니다.');
    final token = await user.getIdToken(true);
    final firebaseProject = Firebase.app().options.projectId.trim();
    final uri = Uri.parse(
      'https://asia-northeast3-$firebaseProject.cloudfunctions.net/manageFusionMarketingCampaign',
    );
    try {
      final response = await _client.post(uri,
        headers: {'content-type': 'application/json; charset=utf-8', 'authorization': 'Bearer $token'},
        body: jsonEncode({'campaignId': campaignId, 'action': action, 'channel': channel, 'publishedUrl': publishedUrl, 'note': note}),
      ).timeout(const Duration(seconds: 30));
      final text = utf8.decode(response.bodyBytes);
      Map<String, dynamic> root = {};
      try { root = Map<String, dynamic>.from(jsonDecode(text) as Map); } catch (_) {}
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw FusionMarketingException((root['message'] ?? root['error'] ?? '처리 실패').toString());
      }
      return root['data'] is Map ? Map<String, dynamic>.from(root['data'] as Map) : root;
    } on TimeoutException {
      throw const FusionMarketingException('처리 시간이 길어지고 있습니다. 잠시 후 다시 시도해 주세요.');
    } on FusionMarketingException { rethrow; }
    catch (e) { throw FusionMarketingException('캠페인 처리 실패: $e'); }
  }
}
