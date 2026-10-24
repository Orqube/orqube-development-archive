import 'package:flutter_test/flutter_test.dart';
import 'package:orqube_safe_hiking/utils/connection_invite.dart';

void main() {
  test('HTTPS QR round trip and app handoff preserve the same account', () {
    const invite = ConnectionInvite('test_UID-42');
    for (final language in ['ko','en','ja','zh','fr','pt']) {
      expect(ConnectionInvite.parse(invite.link(language))?.uid, invite.uid);
    }
    expect(ConnectionInvite.parse(invite.appLink)?.uid, invite.uid);
    for (final host in ['www.orqubic.com','orqubic.com','safe.orqubic.com','orqube-576e7.web.app','orqube-576e7.firebaseapp.com']) {
      expect(ConnectionInvite.parse('https://$host/?orqube_invite=test_UID-42')?.uid, invite.uid);
      expect(ConnectionInvite.parse('https://$host/#/?orqube_invite=test_UID-42')?.uid, invite.uid);
    }

  });
  test('scanner refuses foreign URLs, credentials, duplicates and invalid IDs', () {
    for (final value in [
      'https://evil.example/?orqube_invite=abc',
      'https://safe.orqubic.com.evil.example/?orqube_invite=abc',
      'http://safe.orqubic.com/?orqube_invite=abc',
      'https://user@safe.orqubic.com/?orqube_invite=abc',
      'https://safe.orqubic.com/?orqube_invite=a&orqube_invite=b',
      'https://safe.orqubic.com/?orqube_invite=..%2Fsecret',
      'https://safe.orqubic.com/?orqube_invite=',
      'orqubesafe://other?orqube_invite=abc',
      'https://safe.orqubic.com/path?orqube_invite=abc',
    ]) { expect(ConnectionInvite.parse(value), isNull, reason: value); }
    expect(ConnectionInvite.parse('abc'), isNull);
    expect(ConnectionInvite.parse('abc', allowId: true)?.uid, 'abc');
    expect(ConnectionInvite.parse('a' * 129, allowId: true), isNull);
  });
}
