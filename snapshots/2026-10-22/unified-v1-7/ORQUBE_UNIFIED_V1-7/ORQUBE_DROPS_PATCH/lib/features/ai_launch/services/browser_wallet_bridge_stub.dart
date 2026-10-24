class BrowserWalletResult {
  const BrowserWalletResult({required this.address, required this.chain});
  final String address;
  final String chain;
}

class BrowserDeploymentResult {
  const BrowserDeploymentResult({required this.address, required this.txHash, required this.chain});
  final String address;
  final String txHash;
  final String chain;
}

class BrowserWalletBridge {
  static bool get isSupported => false;
  static bool get isSolanaSupported => false;

  static Future<BrowserWalletResult> connectEvm({required String chain}) {
    throw UnsupportedError('MetaMask 자동 연결은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BrowserWalletResult> connectSolana() {
    throw UnsupportedError('Solana 브라우저 지갑 연결은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BigInt> erc20BalanceOf({
    required String chain,
    required String contractAddress,
    required String walletAddress,
  }) {
    throw UnsupportedError('EVM 토큰 잔액 조회는 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<String> sendErc20Transfer({
    required String chain,
    required String contractAddress,
    required String toAddress,
    required BigInt amountUnits,
  }) {
    throw UnsupportedError('EVM DROPS 전송은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BrowserDeploymentResult> deployEvm({required String chain, required String bytecode}) {
    throw UnsupportedError('EVM 테스트 배포는 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BrowserDeploymentResult> deploySolana({required int decimals, required int totalSupply}) {
    throw UnsupportedError('Solana Devnet 테스트 배포는 ORQUBE 웹에서 사용할 수 있습니다.');
  }
}
