import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'browser_wallet_bridge.dart';
import 'token_drop_service.dart';
import 'token_use_progress.dart';

class TokenSwapQuote {
  const TokenSwapQuote({required this.amountOutUnits, required this.direction});
  final BigInt amountOutUnits;
  final String direction;
}

class TokenSwapResult {
  const TokenSwapResult({required this.txHash, required this.quote});
  final String txHash;
  final TokenSwapQuote quote;
}

class TokenSwapService {
  TokenSwapService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Future<TokenSwapQuote> quote({
    required Map<String, dynamic> projectData,
    required bool tokenToNative,
    required String amountIn,
  }) async {
    final liquidity = projectData['liquidityRun'];
    if (liquidity is! Map || (liquidity['status'] ?? '').toString() != 'completed') {
      throw StateError('완료된 LIQUIDITY 기록이 필요합니다.');
    }
    final router = (liquidity['routerAddress'] ?? '').toString();
    final wrapped = (liquidity['wrappedNativeAddress'] ?? '').toString();
    final token = (projectData['contractAddress'] ?? '').toString();
    final chain = (projectData['chain'] ?? '').toString();
    final decimals = (projectData['decimals'] as num?)?.toInt() ?? 18;
    final inputUnits = TokenDropService.decimalToUnits(amountIn, tokenToNative ? decimals : 18);
    final amountOut = await BrowserWalletBridge.uniswapV2GetAmountOut(
      chain: chain,
      routerAddress: router,
      amountInUnits: inputUnits,
      path: tokenToNative ? [token, wrapped] : [wrapped, token],
    );
    return TokenSwapQuote(
      amountOutUnits: amountOut,
      direction: tokenToNative ? 'TOKEN_TO_NATIVE' : 'NATIVE_TO_TOKEN',
    );
  }

  Future<TokenSwapResult> execute({
    required String projectId,
    required Map<String, dynamic> projectData,
    required bool tokenToNative,
    required String amountIn,
    required double slippagePercent,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != (projectData['ownerUid'] ?? '').toString()) {
      throw StateError('토큰 소유자 로그인 상태를 확인해 주세요.');
    }
    final market = TokenMarketProgress.fromData(projectData);
    if (market.next != TokenMarketStage.swap) {
      throw StateError('LIQUIDITY 완료 후 SWAP을 진행해야 합니다.');
    }
    if (slippagePercent <= 0 || slippagePercent > 20) {
      throw FormatException('Slippage는 0% 초과 20% 이하로 입력해 주세요.');
    }

    final liquidity = Map<String, dynamic>.from(projectData['liquidityRun'] as Map);
    final router = (liquidity['routerAddress'] ?? '').toString();
    final wrapped = (liquidity['wrappedNativeAddress'] ?? '').toString();
    final token = (projectData['contractAddress'] ?? '').toString();
    final chain = (projectData['chain'] ?? '').toString();
    final decimals = (projectData['decimals'] as num?)?.toInt() ?? 18;
    final inputUnits = TokenDropService.decimalToUnits(amountIn, tokenToNative ? decimals : 18);

    final wallet = await BrowserWalletBridge.connectEvm(chain: chain);
    final verifiedChainId = await BrowserWalletBridge.ensureEvmTestnet(chain: chain);
    final savedWallet = (projectData['walletAddress'] ?? '').toString();
    if (savedWallet.isNotEmpty && savedWallet.toLowerCase() != wallet.address.toLowerCase()) {
      throw StateError('현재 MetaMask 계정이 이 프로젝트에 연결된 지갑과 다릅니다.');
    }

    final quoteResult = await quote(
      projectData: projectData,
      tokenToNative: tokenToNative,
      amountIn: amountIn,
    );
    final minOut = (quoteResult.amountOutUnits * BigInt.from(((100 - slippagePercent) * 100).floor())) ~/ BigInt.from(10000);
    if (minOut <= BigInt.zero) throw StateError('Swap 예상 수령량이 너무 작습니다.');

    final ref = _db.collection('launch_projects').doc(projectId);
    final runId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    String approveTx = '';
    await ref.set({
      'swapRun': {
        'id': runId,
        'status': 'executing',
        'direction': quoteResult.direction,
        'amountIn': amountIn,
        'quotedOutUnits': quoteResult.amountOutUnits.toString(),
        'minimumOutUnits': minOut.toString(),
        'slippagePercent': slippagePercent,
        'chain': chain,
        'networkMode': 'testnet',
        'chainId': verifiedChainId,
        'networkName': BrowserWalletBridge.networkInfo(chain)['chainName'],
        'walletAddress': wallet.address,
        'startedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    try {
      if (tokenToNative) {
        final tokenBalance = await BrowserWalletBridge.erc20BalanceOf(
          chain: chain,
          contractAddress: token,
          walletAddress: wallet.address,
        );
        if (tokenBalance < inputUnits) throw StateError('Swap에 사용할 토큰 잔액이 부족합니다.');
        final allowance = await BrowserWalletBridge.erc20Allowance(
          chain: chain,
          contractAddress: token,
          ownerAddress: wallet.address,
          spenderAddress: router,
        );
        if (allowance < inputUnits) {
          approveTx = await BrowserWalletBridge.approveErc20(
            chain: chain,
            contractAddress: token,
            spenderAddress: router,
            amountUnits: inputUnits,
          );
        }
      } else {
        final nativeBalance = await BrowserWalletBridge.nativeBalance(chain: chain, walletAddress: wallet.address);
        if (nativeBalance <= inputUnits) throw StateError('가스비를 포함하면 Native 잔액이 부족합니다.');
      }

      final txHash = await BrowserWalletBridge.swapUniswapV2NativePair(
        chain: chain,
        routerAddress: router,
        tokenAddress: token,
        wrappedNativeAddress: wrapped,
        amountInUnits: inputUnits,
        minimumOutUnits: minOut,
        recipientAddress: wallet.address,
        tokenToNative: tokenToNative,
      );

      await ref.set({
        'swapRun': {
          'id': runId,
          'status': 'completed',
          'approveTxHash': approveTx,
          'txHash': txHash,
          'completedAt': FieldValue.serverTimestamp(),
        },
        'marketStageIndex': 2,
        'marketStage': TokenMarketStage.swap.id,
        'marketStages': {'drops': true, 'market_liquidity': true, 'swap': true},
        'marketActivatedAt': {'swap': FieldValue.serverTimestamp()},
        'marketExpansion': {
          'drops': true,
          'liquidity': true,
          'swap': true,
          'gate': 'sequential_market_stage',
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return TokenSwapResult(txHash: txHash, quote: quoteResult);
    } catch (e) {
      await ref.set({
        'swapRun': {
          'id': runId,
          'status': e.toString().contains('확인 시간이 초과') ? 'verification_required' : 'failed',
          'approveTxHash': approveTx,
          'error': e.toString(),
          'failedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      rethrow;
    }
  }
}
