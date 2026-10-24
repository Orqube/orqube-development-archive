class BrowserWalletResult {
  const BrowserWalletResult({required this.address, required this.chain});
  final String address;
  final String chain;
}

class BrowserDeploymentResult {
  const BrowserDeploymentResult({
    required this.address,
    required this.txHash,
    required this.chain,
    this.walletAddress = '',
  });
  final String address;
  final String txHash;
  final String chain;
  final String walletAddress;
}

class BrowserWalletBridge {
  static bool get isSupported => false;
  static bool get isMetaMaskSupported => false;
  static bool get isKaiaWalletSupported => false;
  static bool get isSolanaSupported => false;

  static Map<String, String> networkInfo(String chain) {
    if (chain == 'Polygon') {
      return const {
        'chainId': '0x13882',
        'chainName': 'Polygon Amoy Testnet',
        'nativeCurrencyName': 'POL',
        'nativeCurrencySymbol': 'POL',
        'rpcUrl': 'https://polygon-amoy.drpc.org',
        'explorerUrl': 'https://amoy.polygonscan.com',
      };
    }
    return const {
      'chainId': '0x3E9',
      'chainName': 'Kaia Kairos Testnet',
      'nativeCurrencyName': 'KAIA',
      'nativeCurrencySymbol': 'KAIA',
      'rpcUrl': 'https://public-en-kairos.node.kaia.io',
      'explorerUrl': 'https://kairos.kaiascan.io',
    };
  }

  static Future<String> currentEvmChainId() {
    throw UnsupportedError('EVM 네트워크 확인은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<String> ensureEvmTestnet({required String chain}) {
    throw UnsupportedError('EVM 테스트넷 전환은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BrowserWalletResult> connectEvm({required String chain}) {
    throw UnsupportedError('MetaMask 자동 연결은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BrowserWalletResult> connectAddressOnly({
    required bool useKaiaWallet,
  }) {
    throw UnsupportedError('브라우저 지갑 주소 확인은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<String> sendErc20TransferFromSelectedWallet({required bool useKaiaWallet, required String contractAddress, required String toAddress, required BigInt amountUnits, required int expectedChainId}) {
    throw UnsupportedError('브라우저 지갑 전송은 Web에서만 지원됩니다.');
  }

  static Future<BrowserWalletResult> connectSolana() {
    throw UnsupportedError('Solana 브라우저 지갑 연결은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<String> evmTransactionFrom({required String chain, required String txHash}) {
    throw UnsupportedError('EVM 트랜잭션 조회는 ORQUBE 웹에서 사용할 수 있습니다.');
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


  static Future<BigInt> nativeBalance({required String chain, required String walletAddress}) {
    throw UnsupportedError('EVM Native 잔액 조회는 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<bool> hasContractCode({required String chain, required String address}) {
    throw UnsupportedError('EVM 컨트랙트 검증은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BigInt> erc20Allowance({required String chain, required String contractAddress, required String ownerAddress, required String spenderAddress}) {
    throw UnsupportedError('ERC-20 allowance 조회는 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<String> approveErc20({required String chain, required String contractAddress, required String spenderAddress, required BigInt amountUnits}) {
    throw UnsupportedError('ERC-20 승인은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<String> uniswapV2WrappedNative({required String chain, required String routerAddress}) {
    throw UnsupportedError('DEX Router 검증은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BigInt> uniswapV2GetAmountOut({required String chain, required String routerAddress, required BigInt amountInUnits, required List<String> path}) {
    throw UnsupportedError('DEX Swap 견적은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<String> addUniswapV2LiquidityNative({required String chain, required String routerAddress, required String tokenAddress, required BigInt tokenAmountUnits, required BigInt nativeAmountUnits, required double slippagePercent, required String recipientAddress}) {
    throw UnsupportedError('DEX LIQUIDITY 연결은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<String> swapUniswapV2NativePair({required String chain, required String routerAddress, required String tokenAddress, required String wrappedNativeAddress, required BigInt amountInUnits, required BigInt minimumOutUnits, required String recipientAddress, required bool tokenToNative}) {
    throw UnsupportedError('DEX SWAP은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BrowserWalletResult> connectKaiaMainnet({required bool useKaiaWallet}) {
    throw UnsupportedError('AUTO VERIFY Mainnet 지갑 연결은 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BigInt> kaiaMainnetNativeBalance({required String walletAddress, required bool useKaiaWallet}) {
    throw UnsupportedError('AUTO VERIFY KAI 잔액 조회는 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BigInt> kaiaMainnetErc20Balance({required String contractAddress, required String walletAddress, required bool useKaiaWallet}) {
    throw UnsupportedError('AUTO VERIFY ORBS 잔액 조회는 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<String> sendKaiaMainnetNative({
    required String toAddress,
    required double amountKai,
    required bool useKaiaWallet,
    String expectedFrom = '',
  }) {
    throw UnsupportedError('AUTO VERIFY 온체인 결제는 ORQUBE 웹/브라우저 지갑에서 사용할 수 있습니다.');
  }

  static Future<String> sendKaiaMainnetErc20({
    required String contractAddress,
    required String toAddress,
    required BigInt amountUnits,
    required bool useKaiaWallet,
    String expectedFrom = '',
  }) {
    throw UnsupportedError('AUTO VERIFY 온체인 결제는 ORQUBE 웹/브라우저 지갑에서 사용할 수 있습니다.');
  }

  static Future<BrowserDeploymentResult> deployEvm({required String chain, required String bytecode}) {
    throw UnsupportedError('EVM 테스트 배포는 ORQUBE 웹에서 사용할 수 있습니다.');
  }

  static Future<BrowserDeploymentResult> deploySolana({required int decimals, required int totalSupply}) {
    throw UnsupportedError('Solana Devnet 테스트 배포는 ORQUBE 웹에서 사용할 수 있습니다.');
  }
}
