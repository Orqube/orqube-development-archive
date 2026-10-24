import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'browser_wallet_bridge.dart';
import 'token_use_progress.dart';

class TokenDropRecipient {
  const TokenDropRecipient({required this.address, required this.amount});
  final String address;
  final String amount;
}

class TokenDropTransfer {
  const TokenDropTransfer({required this.address, required this.amount, required this.txHash});
  final String address;
  final String amount;
  final String txHash;

  Map<String, dynamic> toMap() => {
    'address': address,
    'amount': amount,
    'txHash': txHash,
  };
}

class TokenDropResult {
  const TokenDropResult({required this.transfers, required this.totalUnits});
  final List<TokenDropTransfer> transfers;
  final BigInt totalUnits;
}

class TokenDropService {
  TokenDropService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  static final RegExp _evmAddress = RegExp(r'^0x[0-9a-fA-F]{40}$');

  static List<TokenDropRecipient> parseRecipients(String raw) {
    final recipients = <TokenDropRecipient>[];
    final seen = <String>{};
    for (final sourceLine in raw.split(RegExp(r'[\r\n]+'))) {
      final line = sourceLine.trim();
      if (line.isEmpty) continue;
      final parts = line.split(RegExp(r'[,;\s]+'));
      if (parts.length < 2) {
        throw FormatException('각 줄은 지갑주소와 수량을 입력해야 합니다.');
      }
      final address = parts[0].trim();
      final amount = parts[1].trim();
      if (!_evmAddress.hasMatch(address)) {
        throw FormatException('잘못된 EVM 주소: $address');
      }
      final key = address.toLowerCase();
      if (!seen.add(key)) {
        throw FormatException('중복 지갑 주소가 있습니다: $address');
      }
      if (amount.isEmpty || amount.startsWith('-') || amount == '0') {
        throw FormatException('드롭 수량은 0보다 커야 합니다: $amount');
      }
      recipients.add(TokenDropRecipient(address: address, amount: amount));
    }
    if (recipients.isEmpty) throw FormatException('드롭 대상 지갑을 1개 이상 입력해 주세요.');
    if (recipients.length > 20) {
      throw FormatException('브라우저 안전 실행은 한 번에 최대 20개 지갑까지 지원합니다.');
    }
    return recipients;
  }

  static BigInt decimalToUnits(String amount, int decimals) {
    final value = amount.trim();
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      throw FormatException('잘못된 토큰 수량: $amount');
    }
    final parts = value.split('.');
    final whole = BigInt.parse(parts[0]);
    final fractionRaw = parts.length == 2 ? parts[1] : '';
    if (fractionRaw.length > decimals) {
      throw FormatException('소수점은 최대 $decimals자리까지 입력할 수 있습니다: $amount');
    }
    final scale = BigInt.from(10).pow(decimals);
    final padded = fractionRaw.padRight(decimals, '0');
    final fraction = padded.isEmpty ? BigInt.zero : BigInt.parse(padded);
    final units = whole * scale + fraction;
    if (units <= BigInt.zero) throw FormatException('드롭 수량은 0보다 커야 합니다.');
    return units;
  }

  Future<TokenDropResult> execute({
    required String projectId,
    required Map<String, dynamic> projectData,
    required String title,
    required List<TokenDropRecipient> recipients,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != (projectData['ownerUid'] ?? '').toString()) {
      throw StateError('토큰 소유자 로그인 상태를 확인해 주세요.');
    }

    final core = TokenUseProgress.fromData(projectData);
    final market = TokenMarketProgress.fromData(projectData);
    if (!core.isComplete || market.next != TokenMarketStage.drops) {
      throw StateError('LIQUIDITY READY 완료 후 DROPS를 첫 시장 단계로 실행해야 합니다.');
    }

    final chain = (projectData['chain'] ?? '').toString();
    if (chain != 'Kaia' && chain != 'Polygon') {
      throw UnsupportedError('현재 실제 DROPS 전송은 Kaia/Polygon EVM 테스트넷부터 지원합니다.');
    }
    final contract = (projectData['contractAddress'] ?? '').toString();
    if (!_evmAddress.hasMatch(contract)) {
      throw StateError('배포된 EVM 토큰 컨트랙트 주소를 확인해 주세요.');
    }
    final decimals = (projectData['decimals'] as num?)?.toInt() ?? 18;

    final previousRaw = projectData['dropRun'];
    if (previousRaw is Map) {
      final previous = Map<String, dynamic>.from(previousRaw);
      final previousStatus = (previous['status'] ?? '').toString();
      if (previousStatus == 'executing' || previousStatus == 'verification_required') {
        throw StateError('이전 DROPS의 온체인 확인이 끝나지 않았습니다. Tx 상태를 확인한 뒤 다시 진행해 주세요.');
      }
      if (previousStatus == 'partial') {
        final completedAddresses = <String>{};
        final previousTransfers = previous['transfers'];
        if (previousTransfers is List) {
          for (final item in previousTransfers) {
            if (item is Map) {
              completedAddresses.add((item['address'] ?? '').toString().toLowerCase());
            }
          }
        }
        for (final recipient in recipients) {
          if (completedAddresses.contains(recipient.address.toLowerCase())) {
            throw StateError('이전 PARTIAL DROPS에서 이미 전송된 주소가 포함되어 있습니다: ${recipient.address}');
          }
        }
      }
    }

    var totalUnits = BigInt.zero;
    final units = <BigInt>[];
    for (final recipient in recipients) {
      final parsed = decimalToUnits(recipient.amount, decimals);
      units.add(parsed);
      totalUnits += parsed;
    }

    final wallet = await BrowserWalletBridge.connectEvm(chain: chain);
    final savedWallet = (projectData['walletAddress'] ?? '').toString();
    if (savedWallet.isNotEmpty && savedWallet.toLowerCase() != wallet.address.toLowerCase()) {
      throw StateError('현재 MetaMask 계정이 이 프로젝트에 연결된 지갑과 다릅니다.');
    }

    final balance = await BrowserWalletBridge.erc20BalanceOf(
      chain: chain,
      contractAddress: contract,
      walletAddress: wallet.address,
    );
    if (balance < totalUnits) {
      throw StateError('현재 지갑의 토큰 잔액이 DROPS 총수량보다 부족합니다.');
    }

    final projectRef = _db.collection('launch_projects').doc(projectId);
    final runId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    await projectRef.set({
      'dropRun': {
        'id': runId,
        'title': title.trim().isEmpty ? 'ORQUBE TOKEN DROP' : title.trim(),
        'status': 'executing',
        'recipientCount': recipients.length,
        'completedCount': 0,
        'totalUnits': totalUnits.toString(),
        'decimals': decimals,
        'startedAt': FieldValue.serverTimestamp(),
        'requested': recipients.map((e) => {'address': e.address, 'amount': e.amount}).toList(),
        'transfers': <Map<String, dynamic>>[],
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final completed = <TokenDropTransfer>[];
    try {
      for (var i = 0; i < recipients.length; i++) {
        final recipient = recipients[i];
        final txHash = await BrowserWalletBridge.sendErc20Transfer(
          chain: chain,
          contractAddress: contract,
          toAddress: recipient.address,
          amountUnits: units[i],
        );
        completed.add(TokenDropTransfer(
          address: recipient.address,
          amount: recipient.amount,
          txHash: txHash,
        ));
        await projectRef.set({
          'dropRun': {
            'id': runId,
            'status': 'executing',
            'completedCount': completed.length,
            'transfers': completed.map((e) => e.toMap()).toList(),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await projectRef.set({
        'dropRun': {
          'id': runId,
          'status': 'completed',
          'completedCount': completed.length,
          'completedAt': FieldValue.serverTimestamp(),
          'transfers': completed.map((e) => e.toMap()).toList(),
        },
        'marketStageIndex': 0,
        'marketStage': TokenMarketStage.drops.id,
        'marketStages': {'drops': true},
        'marketActivatedAt': {'drops': FieldValue.serverTimestamp()},
        'marketExpansion': {
          'drops': true,
          'liquidity': false,
          'swap': false,
          'gate': 'sequential_market_stage',
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return TokenDropResult(transfers: completed, totalUnits: totalUnits);
    } catch (e) {
      final errorText = e.toString();
      final needsVerification = errorText.contains('확인 시간이 초과');
      await projectRef.set({
        'dropRun': {
          'id': runId,
          'status': needsVerification ? 'verification_required' : (completed.isEmpty ? 'failed' : 'partial'),
          'completedCount': completed.length,
          'failedAt': FieldValue.serverTimestamp(),
          'transfers': completed.map((e) => e.toMap()).toList(),
          'error': errorText,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      rethrow;
    }
  }
}
