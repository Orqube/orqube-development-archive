import 'dart:convert';
import 'debate_effects.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class MixedDebateService {
  static Future<Map<String, dynamic>> call(
    String action,
    Map<String, dynamic> data, {
    String function = 'manageMixedDebateRoom',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('ORQUBE 로그인 후 입장하세요.');
    final token = await user.getIdToken();
    final project = Firebase.app().options.projectId;
    final response = await http
        .post(
          Uri.parse(
            'https://asia-northeast3-$project.cloudfunctions.net/$function',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'action': action, 'comedy': DebateEffects.comedy, ...data}),
        )
        .timeout(const Duration(seconds: 175));
    Map<String, dynamic> result;
    try {
      result = Map<String, dynamic>.from(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map,
      );
    } catch (_) {
      throw Exception('혼합 토론방 함수를 배포한 뒤 다시 시도하세요.');
    }
    if (response.statusCode != 200)
      throw Exception(result['error'] ?? '서버 오류 ${response.statusCode}');
    return result;
  }
}
