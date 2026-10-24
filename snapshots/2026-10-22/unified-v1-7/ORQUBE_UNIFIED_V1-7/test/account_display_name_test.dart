import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orqube_app/services/account_display_name.dart';

class TestUser implements User {
  TestUser(this.displayName);
  @override
  final String? displayName;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('signed out does not show an earlier member name', () {
    expect(accountDisplayName(null, {'nickname': '김명근'}), '로그인 필요');
  });
  test('legacy seed falls back to the current Google account name', () {
    expect(accountDisplayName(TestUser('홍길동'), {'nickname': '김명근'}), '홍길동');
  });
  test('SMS account without name does not inherit the founder name', () {
    expect(accountDisplayName(TestUser(null), {'nickname': '김명근'}), 'ORQUBE USER');
  });
  test('confirmed founder and deliberately saved nickname remain valid', () {
    expect(accountDisplayName(TestUser('김명근'), {'nickname': '김명근'}), '김명근');
    expect(accountDisplayName(TestUser(null), {'nickname': '김명근', 'profileUpdatedAt': 1}), '김명근');
  });
  test('other stored nicknames are preserved and missing names use auth', () {
    expect(accountDisplayName(TestUser('Google 이름'), {'nickname': '내 닉네임'}), '내 닉네임');
    expect(accountDisplayName(TestUser('홍길동'), {'nickname': ' '}), '홍길동');
  });
}
