import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:orqube_app/features/ai_launch/services/generated_kaia_wallet_service.dart';

void main() {
  test('short passwords cannot generate a wallet', () {
    expect(() => generateEncryptedKaiaWallet('short'), throwsArgumentError);
  });
  test('encrypted backup restores the generated address and rejects wrong passwords', () {
    const password = 'Backup-Only-2026!';
    final generated = generateEncryptedKaiaWallet(password);
    expect(generated['address'], matches(RegExp(r'^0x[0-9a-fA-F]{40}$')));
    final json = jsonDecode(generated['json']!) as Map;
    expect(json['version'], 3);
    expect(json.containsKey('privateKey'), isFalse);
    expect(recoverGeneratedKaiaWalletAddress({'json': generated['json']!, 'password': password}), generated['address']);
    expect(() => recoverGeneratedKaiaWalletAddress({'json': generated['json']!, 'password': 'wrong-password'}), throwsA(anything));
  });
}
