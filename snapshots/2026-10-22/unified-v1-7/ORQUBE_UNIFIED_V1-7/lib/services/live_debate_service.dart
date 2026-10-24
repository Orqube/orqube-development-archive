import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
class LiveDebateService {
  static Future<String> call(String action, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('로그인 후 이용해 주세요.');
    final token = await user.getIdToken();
    final project = Firebase.app().options.projectId;
    final response = await http.post(Uri.parse('https://asia-northeast3-$project.cloudfunctions.net/manageLiveDebateRoom'),
      headers: {'Content-Type':'application/json','Authorization':'Bearer $token'},
      body: jsonEncode({'action':action,...data})).timeout(const Duration(seconds:35));
    Map<String,dynamic> result;
    try { result = Map<String,dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)) as Map); }
    catch (_) { throw Exception('토론방 서버 배포와 연결을 확인하세요.'); }
    if (response.statusCode != 200) throw Exception(result['error'] ?? '요청 실패');
    return '${result['roomId'] ?? ''}';
  }
}
