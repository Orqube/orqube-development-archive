import 'dart:math';
import 'package:web3dart/web3dart.dart';

// No persistence, RPC, logging, or server calls occur in this module.
Map<String, String> generateEncryptedKaiaWallet(String password) {
  if (password.length < 12) throw ArgumentError('Password must contain at least 12 characters.');
  final random = Random.secure();
  final key = EthPrivateKey.createRandom(random);
  final wallet = Wallet.createNew(key, password, random, scryptN: 32768);
  return {'address': key.address.hex, 'json': wallet.toJson()};
}

String recoverGeneratedKaiaWalletAddress(Map<String, String> input) =>
    Wallet.fromJson(input['json']!, input['password']!).privateKey.address.hex;
