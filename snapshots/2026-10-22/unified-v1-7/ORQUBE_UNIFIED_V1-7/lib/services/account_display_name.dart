import 'package:firebase_auth/firebase_auth.dart';

/// Ignore the old dashboard's seeded name unless confirmed in a saved profile
/// or by the current authentication provider. Never modifies server balances.
String accountDisplayName(User? user, Map<String, dynamic> data) {
  if (user == null) return '로그인 필요';
  final nickname = (data['nickname'] ?? '').toString().trim();
  final authName = (user.displayName ?? '').trim();
  final legacySeed = nickname == '김명근' &&
      authName != '김명근' && data['profileUpdatedAt'] == null;
  if (nickname.isNotEmpty && !legacySeed) return nickname;
  if (authName.isNotEmpty) return authName;
  return 'ORQUBE USER';
}
