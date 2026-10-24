import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'browser_wallet_bridge.dart';
import 'token_drop_service.dart';
import 'token_use_progress.dart';

class TokenLiquidityResult {
  const TokenLiquidityResult({
    required this.approveTxHash,
    required this.liquidityTxHash,
    required this.routerAddress,
    required this.wrappedNativeAddress,
  });

  final String approveTxHash;
  final String liquidityTxHash;
  final String routerAddress;
  final String wrappedNativeAddress;
}

class TokenLiquidityService {
  TokenLiquidityService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  static final RegExp _evmAddress = RegExp(r'^0x[0-9a-fA-F]{40}$');

  Future<TokenLiquidityResult> execute({
    required String projectId,
    required Map<String, dynamic> projectData,
    required String routerAddress,
    required String tokenAmount,
    required String nativeAmount,
    required double slippagePercent,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != (projectData['ownerUid'] ?? '').toString()) {
      throw StateError('토큰 소유자 로그인 상태를 확인해 주세요.');
    }

    final core = TokenUseProgress.fromData(projectData);
    final market = TokenMarketProgress.fromData(projectData);
    if (!core.isComplete || market.next != TokenMarketStage.liquidity) {
      throw StateError('DROPS 완료 후 LIQUIDITY를 진행해야 합니다.');
    }

    final chain = (projectData['chain'] ?? '').toString();
    if (chain != 'Kaia' && chain != 'Polygon') {
      throw UnsupportedError('현재 실제 LIQUIDITY 연결은 Kaia/Polygon EVM 테스트넷을 지원합니다.');
    }
    if (!_evmAddress.hasMatch(routerAddress)) {
      throw FormatException('올바른 Uniswap V2 호환 Router 주소를 입력해 주세요.');
    }
    if (slippagePercent <= 0 || slippagePercent > 20) {
      throw FormatException('Slippage는 0% 초과 20% 이하로 입력해 주세요.');
    }

    final contract = (projectData['contractAddress'] ?? '').toString();
    if (!_evmAddress.hasMatch(contract)) {
      throw StateError('배포된 EVM 토큰 컨트랙트 주소를 확인해 주세요.');
    }
    final decimals = (projectData['decimals'] as num?)?.toInt() ?? 18;
    final tokenUnits = TokenDropService.decimalToUnits(tokenAmount, decimals);
    final nativeUnits = TokenDropService.decimalToUnits(nativeAmount, 18);

    final wallet = await BrowserWalletBridge.connectEvm(chain: chain);
    final verifiedChainId = await BrowserWalletBridge.ensureEvmTestnet(chain: chain);
    final savedWallet = (projectData['walletAddress'] ?? '').toString();
    if (savedWallet.isNotEmpty && savedWallet.toLowerCase() != wallet.address.toLowerCase()) {
      throw StateError('현재 MetaMask 계정이 이 프로젝트에 연결된 지갑과 다릅니다.');
    }

    if (!await BrowserWalletBridge.hasContractCode(chain: chain, address: routerAddress)) {
      throw StateError('입력한 Router 주소에서 스마트컨트랙트 코드를 찾지 못했습니다.');
    }
    final wrappedNative = await BrowserWalletBridge.uniswapV2WrappedNative(
      chain: chain,
      routerAddress: routerAddress,
    );
    if (!_evmAddress.hasMatch(wrappedNative)) {
      throw StateError('Router의 WETH/Wrapped Native 주소를 확인할 수 없습니다.');
    }

    final tokenBalance = await BrowserWalletBridge.erc20BalanceOf(
      chain: chain,
      contractAddress: contract,
      walletAddress: wallet.address,
    );
    if (tokenBalance < tokenUnits) {
      throw StateError('현재 지갑의 토큰 잔액이 추가할 유동성 수량보다 부족합니다.');
    }
    final nativeBalance = await BrowserWalletBridge.nativeBalance(
      chain: chain,
      walletAddress: wallet.address,
    );
    if (nativeBalance <= nativeUnits) {
      throw StateError('가스비를 포함하면 현재 지갑의 ${chain == 'Kaia' ? 'KAIA' : 'POL'} 잔액이 부족합니다.');
    }

    final ref = _db.collection('launch_projects').doc(projectId);
    final runId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    await ref.set({
      'liquidityRun': {
        'id': runId,
        'status': 'executing',
        'routerAddress': routerAddress,
        'wrappedNativeAddress': wrappedNative,
        'tokenAmount': tokenAmount,
        'nativeAmount': nativeAmount,
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

    String approveTx = '';
    try {
      final allowance = await BrowserWalletBridge.erc20Allowance(
        chain: chain,
        contractAddress: contract,
        ownerAddress: wallet.address,
        spenderAddress: routerAddress,
      );
      if (allowance < tokenUnits) {
        approveTx = await BrowserWalletBridge.approveErc20(
          chain: chain,
          contractAddress: contract,
          spenderAddress: routerAddress,
          amountUnits: tokenUnits,
        );
        await ref.set({
          'liquidityRun': {'id': runId, 'status': 'approved', 'approveTxHash': approveTx},
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final liquidityTx = await BrowserWalletBridge.addUniswapV2LiquidityNative(
        chain: chain,
        routerAddress: routerAddress,
        tokenAddress: contract,
        tokenAmountUnits: tokenUnits,
        nativeAmountUnits: nativeUnits,
        slippagePercent: slippagePercent,
        recipientAddress: wallet.address,
      );

      await ref.set({
        'liquidityRun': {
          'id': runId,
          'status': 'completed',
          'approveTxHash': approveTx,
          'liquidityTxHash': liquidityTx,
          'completedAt': FieldValue.serverTimestamp(),
        },
        'marketStageIndex': 1,
        'marketStage': TokenMarketStage.liquidity.id,
        'marketStages': {'drops': true, 'market_liquidity': true},
        'marketActivatedAt': {'market_liquidity': FieldValue.serverTimestamp()},
        'marketExpansion': {
          'drops': true,
          'liquidity': true,
          'swap': false,
          'gate': 'sequential_market_stage',
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return TokenLiquidityResult(
        approveTxHash: approveTx,
        liquidityTxHash: liquidityTx,
        routerAddress: routerAddress,
        wrappedNativeAddress: wrappedNative,
      );
    } catch (e) {
      await ref.set({
        'liquidityRun': {
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
