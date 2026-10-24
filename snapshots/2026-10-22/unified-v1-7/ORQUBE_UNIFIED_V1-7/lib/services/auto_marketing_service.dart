import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class AutoMarketingService {
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('로그인 후 이용하세요.');
    final token = await user.getIdToken(true);
    final project = Firebase.app().options.projectId;
    final response = await http
        .post(
          Uri.parse(
            'https://asia-northeast3-$project.cloudfunctions.net/manageAutoMarketing',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'action': action, ...values}),
        )
        .timeout(const Duration(seconds: 350));
    Map<String, dynamic> data;
    try {
      data = Map<String, dynamic>.from(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map,
      );
    } catch (_) {
      throw Exception(
        '서버 응답을 확인할 수 없습니다 (${response.statusCode}). 자동 발굴 서버 배포를 확인하세요.',
      );
    }
    if (response.statusCode != 200)
      throw Exception(data['error'] ?? '처리에 실패했습니다.');
    return Map<String, dynamic>.from(data['data'] as Map);
  }
}
