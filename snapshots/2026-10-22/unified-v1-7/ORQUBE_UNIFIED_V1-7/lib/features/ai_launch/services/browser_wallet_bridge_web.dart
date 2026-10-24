// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

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
  static dynamic _windowProvider(String name) {
    try {
      if (!js_util.hasProperty(html.window, name)) return null;
      return js_util.getProperty(html.window, name);
    } catch (_) {
      return null;
    }
  }

  static bool _providerFlag(dynamic provider, String name) {
    if (provider == null) return false;
    try {
      return js_util.hasProperty(provider, name) &&
          js_util.getProperty(provider, name) == true;
    } catch (_) {
      return false;
    }
  }

  static dynamic _findInjectedProvider(
    dynamic root,
    List<String> flags,
  ) {
    if (root == null) return null;
    for (final flag in flags) {
      if (_providerFlag(root, flag)) return root;
    }
    try {
      if (!js_util.hasProperty(root, 'providers')) return null;
      final providers = js_util.getProperty(root, 'providers');
      if (providers == null || !js_util.hasProperty(providers, 'length')) {
        return null;
      }
      final lengthRaw = js_util.getProperty(providers, 'length');
      final length = lengthRaw is num ? lengthRaw.toInt() : 0;
      for (var i = 0; i < length; i++) {
        final provider = js_util.getProperty(providers, i);
        for (final flag in flags) {
          if (_providerFlag(provider, flag)) return provider;
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  // Existing deploy/test flows may use any injected EIP-1193 provider.
  static dynamic get _ethereum => _windowProvider('ethereum');

  // Address comparison must identify MetaMask specifically when multiple
  // wallet extensions inject providers into the same browser.
  static dynamic get _metaMaskProvider =>
      _findInjectedProvider(_windowProvider('ethereum'), const ['isMetaMask']);

  static dynamic get _kaiaWallet {
    final direct = _windowProvider('klaytn') ?? _windowProvider('kaia');
    if (direct != null) return direct;
    return _findInjectedProvider(
      _windowProvider('ethereum'),
      const ['isKaikas', 'isKaiaWallet'],
    );
  }

  static bool get isSupported => _ethereum != null;
  static bool get isMetaMaskSupported => _metaMaskProvider != null;
  static bool get isKaiaWalletSupported => _kaiaWallet != null;
  static bool get isSolanaSupported =>
      js_util.hasProperty(html.window, 'orqubeSolanaConnect');

  static Future<dynamic> _requestWith(
    dynamic provider,
    String method, [
    dynamic params,
  ]) async {
    if (provider == null) throw StateError('브라우저 지갑 Provider를 찾지 못했습니다.');
    final request = <String, dynamic>{'method': method};
    if (params != null) request['params'] = params;
    final promise = js_util.callMethod(provider, 'request', [
      js_util.jsify(request),
    ]);
    return js_util.promiseToFuture<dynamic>(promise);
  }

  static Future<dynamic> _requestRaw(String method, [dynamic params]) async =>
      _requestWith(_ethereum, method, params);

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

  static Future<void> _switchEvmNetwork(String chain) async {
    final n = networkInfo(chain);
    try {
      await _requestRaw('wallet_switchEthereumChain', [
        {'chainId': n['chainId']},
      ]);
    } catch (_) {
      await _requestRaw('wallet_addEthereumChain', [
        {
          'chainId': n['chainId'],
          'chainName': n['chainName'],
          'nativeCurrency': {
            'name': n['nativeCurrencyName'],
            'symbol': n['nativeCurrencySymbol'],
            'decimals': 18,
          },
          'rpcUrls': [n['rpcUrl']],
          'blockExplorerUrls': [n['explorerUrl']],
        },
      ]);
    }
  }

  static Future<String> currentEvmChainId() async {
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    final raw = await _requestRaw('eth_chainId');
    return raw.toString().toLowerCase();
  }

  static Future<String> ensureEvmTestnet({required String chain}) async {
    if (chain != 'Kaia' && chain != 'Polygon') {
      throw UnsupportedError('Kaia Kairos / Polygon Amoy 테스트넷만 지원합니다.');
    }
    await _switchEvmNetwork(chain);
    final expected = (networkInfo(chain)['chainId'] ?? '').toLowerCase();
    final actual = await currentEvmChainId();
    if (actual != expected) {
      throw StateError('MetaMask 네트워크 확인에 실패했습니다. 예상 $expected, 현재 $actual');
    }
    return actual;
  }

  static Future<BrowserWalletResult> connectEvm({required String chain}) async {
    if (_ethereum == null) {
      throw StateError(
        'MetaMask를 찾지 못했습니다. 확장 프로그램 또는 MetaMask 인앱 브라우저를 확인해 주세요.',
      );
    }
    final accountsRaw = await _requestRaw('eth_requestAccounts');
    final accounts = js_util.dartify(accountsRaw);
    if (accounts is! List || accounts.isEmpty) {
      throw StateError('MetaMask 계정 승인이 필요합니다.');
    }
    await ensureEvmTestnet(chain: chain);
    return BrowserWalletResult(
      address: accounts.first.toString(),
      chain: chain,
    );
  }

  static Future<BrowserWalletResult> connectAddressOnly({
    required bool useKaiaWallet,
  }) async {
    final provider = useKaiaWallet ? _kaiaWallet : _metaMaskProvider;
    if (provider == null) {
      throw StateError(
        useKaiaWallet
            ? 'Kaia Wallet을 찾지 못했습니다. 현재 ORQUBE를 연 같은 브라우저에 Kaia Wallet 확장이 설치·활성화되어 있는지 확인해 주세요.'
            : 'MetaMask를 찾지 못했습니다. 현재 ORQUBE를 연 같은 브라우저에 MetaMask 확장이 설치·활성화되어 있는지 확인해 주세요.',
      );
    }
    final accountsRaw = await _requestWith(provider, 'eth_requestAccounts');
    final accounts = js_util.dartify(accountsRaw);
    if (accounts is! List || accounts.isEmpty) {
      throw StateError(
        '${useKaiaWallet ? 'Kaia Wallet' : 'MetaMask'} 계정 승인이 필요합니다.',
      );
    }
    return BrowserWalletResult(
      address: accounts.first.toString(),
      chain: 'Kaia',
    );
  }

  static Future<String> sendErc20TransferFromSelectedWallet({
    required bool useKaiaWallet,
    required String contractAddress,
    required String toAddress,
    required BigInt amountUnits,
    required int expectedChainId,
  }) async {
    final provider = useKaiaWallet ? _kaiaWallet : _metaMaskProvider;
    if (provider == null) throw StateError('${useKaiaWallet ? 'Kaia Wallet' : 'MetaMask'}을 찾지 못했습니다.');
    final accountsRaw = await _requestWith(provider, 'eth_requestAccounts');
    final accounts = js_util.dartify(accountsRaw);
    if (accounts is! List || accounts.isEmpty) throw StateError('지갑 계정 승인이 필요합니다.');
    final chainRaw = await _requestWith(provider, 'eth_chainId');
    final actual = int.tryParse(chainRaw.toString().replaceFirst('0x', ''), radix: 16) ?? -1;
    if (actual != expectedChainId) throw StateError('지급 지갑 네트워크가 다릅니다. 예상 Chain ID $expectedChainId, 현재 $actual');
    final from = accounts.first.toString();
    final cleanTo = toAddress.toLowerCase().replaceFirst('0x', '');
    final data = '0xa9059cbb${_pad64(cleanTo)}${_pad64(amountUnits.toRadixString(16))}';
    final raw = await _requestWith(provider, 'eth_sendTransaction', [{'from': from, 'to': contractAddress, 'data': data}]);
    final txHash = raw.toString();
    for (var i = 0; i < 60; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final receiptRaw = await _requestWith(provider, 'eth_getTransactionReceipt', [txHash]);
      final receipt = js_util.dartify(receiptRaw);
      if (receipt is Map && receipt.isNotEmpty) {
        final status = (receipt['status'] ?? '').toString().toLowerCase();
        if (status == '0x0') throw StateError('QR REWARD 전송이 실패했습니다. Tx: $txHash');
        if (status == '0x1') return txHash;
      }
    }
    throw StateError('QR REWARD 전송 확인 시간이 초과되었습니다. Tx: $txHash');
  }

  static Future<BrowserWalletResult> connectSolana() async {
    if (!isSolanaSupported) {
      throw StateError('Solana 호환 지갑을 찾지 못했습니다. Phantom 등 브라우저 지갑을 확인해 주세요.');
    }
    final fn = js_util.getProperty(html.window, 'orqubeSolanaConnect');
    final promise = js_util.callMethod(fn, 'call', [html.window]);
    final raw = await js_util.promiseToFuture<dynamic>(promise);
    final data = js_util.dartify(raw);
    if (data is! Map) throw StateError('Solana 지갑 연결 결과를 확인할 수 없습니다.');
    return BrowserWalletResult(
      address: (data['address'] ?? '').toString(),
      chain: 'Solana',
    );
  }

  static String _pad64(String hex) => hex.padLeft(64, '0');

  static Future<String> evmTransactionFrom({
    required String chain,
    required String txHash,
  }) async {
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    await ensureEvmTestnet(chain: chain);
    final raw = await _requestRaw('eth_getTransactionByHash', [txHash]);
    final tx = js_util.dartify(raw);
    if (tx is! Map || tx.isEmpty) {
      throw StateError('배포 트랜잭션 정보를 찾을 수 없습니다.');
    }
    return (tx['from'] ?? '').toString();
  }

  static Future<BigInt> erc20BalanceOf({
    required String chain,
    required String contractAddress,
    required String walletAddress,
  }) async {
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    await ensureEvmTestnet(chain: chain);
    final cleanAddress = walletAddress.toLowerCase().replaceFirst('0x', '');
    final data = '0x70a08231${_pad64(cleanAddress)}';
    final raw = await _requestRaw('eth_call', [
      {'to': contractAddress, 'data': data},
      'latest',
    ]);
    final hex = raw.toString().replaceFirst('0x', '');
    return hex.isEmpty ? BigInt.zero : BigInt.parse(hex, radix: 16);
  }

  static Future<String> sendErc20Transfer({
    required String chain,
    required String contractAddress,
    required String toAddress,
    required BigInt amountUnits,
  }) async {
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    final wallet = await connectEvm(chain: chain);
    final cleanTo = toAddress.toLowerCase().replaceFirst('0x', '');
    final amountHex = amountUnits.toRadixString(16);
    final data = '0xa9059cbb${_pad64(cleanTo)}${_pad64(amountHex)}';
    final raw = await _requestRaw('eth_sendTransaction', [
      {'from': wallet.address, 'to': contractAddress, 'data': data},
    ]);
    final txHash = raw.toString();
    for (var i = 0; i < 60; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final receiptRaw = await _requestRaw('eth_getTransactionReceipt', [
        txHash,
      ]);
      final receipt = js_util.dartify(receiptRaw);
      if (receipt is Map && receipt.isNotEmpty) {
        final status = (receipt['status'] ?? '').toString().toLowerCase();
        if (status == '0x0')
          throw StateError('DROPS 전송 트랜잭션이 실패했습니다. Tx: $txHash');
        if (status == '0x1') return txHash;
      }
    }
    throw StateError('DROPS 전송은 제출되었지만 확인 시간이 초과되었습니다. Tx: $txHash');
  }

  static String _addressWord(String address) =>
      _pad64(address.toLowerCase().replaceFirst('0x', ''));
  static String _uintWord(BigInt value) => _pad64(value.toRadixString(16));

  static Future<String> _sendAndWait({
    required String from,
    required String to,
    required String data,
    BigInt? value,
    String action = '트랜잭션',
  }) async {
    final tx = <String, dynamic>{'from': from, 'to': to, 'data': data};
    if (value != null && value > BigInt.zero)
      tx['value'] = '0x${value.toRadixString(16)}';
    final raw = await _requestRaw('eth_sendTransaction', [tx]);
    final txHash = raw.toString();
    for (var i = 0; i < 60; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final receiptRaw = await _requestRaw('eth_getTransactionReceipt', [
        txHash,
      ]);
      final receipt = js_util.dartify(receiptRaw);
      if (receipt is Map && receipt.isNotEmpty) {
        final status = (receipt['status'] ?? '').toString().toLowerCase();
        if (status == '0x0')
          throw StateError('$action 트랜잭션이 실패했습니다. Tx: $txHash');
        if (status == '0x1') return txHash;
      }
    }
    throw StateError('$action 트랜잭션은 제출되었지만 확인 시간이 초과되었습니다. Tx: $txHash');
  }

  static Future<BigInt> nativeBalance({
    required String chain,
    required String walletAddress,
  }) async {
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    await ensureEvmTestnet(chain: chain);
    final raw = await _requestRaw('eth_getBalance', [walletAddress, 'latest']);
    final hex = raw.toString().replaceFirst('0x', '');
    return hex.isEmpty ? BigInt.zero : BigInt.parse(hex, radix: 16);
  }

  static Future<bool> hasContractCode({
    required String chain,
    required String address,
  }) async {
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    await ensureEvmTestnet(chain: chain);
    final raw = await _requestRaw('eth_getCode', [address, 'latest']);
    final code = raw.toString().toLowerCase();
    return code != '0x' && code != '0x0' && code.length > 4;
  }

  static Future<BigInt> erc20Allowance({
    required String chain,
    required String contractAddress,
    required String ownerAddress,
    required String spenderAddress,
  }) async {
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    await ensureEvmTestnet(chain: chain);
    final data =
        '0xdd62ed3e${_addressWord(ownerAddress)}${_addressWord(spenderAddress)}';
    final raw = await _requestRaw('eth_call', [
      {'to': contractAddress, 'data': data},
      'latest',
    ]);
    final hex = raw.toString().replaceFirst('0x', '');
    return hex.isEmpty ? BigInt.zero : BigInt.parse(hex, radix: 16);
  }

  static Future<String> approveErc20({
    required String chain,
    required String contractAddress,
    required String spenderAddress,
    required BigInt amountUnits,
  }) async {
    final wallet = await connectEvm(chain: chain);
    final data =
        '0x095ea7b3${_addressWord(spenderAddress)}${_uintWord(amountUnits)}';
    return _sendAndWait(
      from: wallet.address,
      to: contractAddress,
      data: data,
      action: 'ERC-20 승인',
    );
  }

  static Future<String> uniswapV2WrappedNative({
    required String chain,
    required String routerAddress,
  }) async {
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    await ensureEvmTestnet(chain: chain);
    final raw = await _requestRaw('eth_call', [
      {'to': routerAddress, 'data': '0xad5c4648'},
      'latest',
    ]);
    final hex = raw.toString().replaceFirst('0x', '').padLeft(64, '0');
    if (hex.length < 40) throw StateError('Router WETH() 응답이 올바르지 않습니다.');
    final address = '0x${hex.substring(hex.length - 40)}';
    if (address.toLowerCase() == '0x0000000000000000000000000000000000000000') {
      throw StateError('Router WETH()가 zero address를 반환했습니다.');
    }
    return address;
  }

  static Future<BigInt> uniswapV2GetAmountOut({
    required String chain,
    required String routerAddress,
    required BigInt amountInUnits,
    required List<String> path,
  }) async {
    if (path.length != 2) throw ArgumentError('현재 Swap 경로는 2개 자산만 지원합니다.');
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    await ensureEvmTestnet(chain: chain);
    final data =
        '0xd06ca61f'
        '${_uintWord(amountInUnits)}'
        '${_uintWord(BigInt.from(64))}'
        '${_uintWord(BigInt.from(2))}'
        '${_addressWord(path[0])}'
        '${_addressWord(path[1])}';
    final raw = await _requestRaw('eth_call', [
      {'to': routerAddress, 'data': data},
      'latest',
    ]);
    final hex = raw.toString().replaceFirst('0x', '');
    if (hex.length < 256)
      throw StateError('Router에서 Swap 견적을 반환하지 못했습니다. 유동성 풀을 확인해 주세요.');
    final length = BigInt.parse(hex.substring(64, 128), radix: 16).toInt();
    if (length < 2 || hex.length < 128 + length * 64)
      throw StateError('Router Swap 견적 형식이 올바르지 않습니다.');
    return BigInt.parse(hex.substring(128 + 64, 128 + 128), radix: 16);
  }

  static Future<String> addUniswapV2LiquidityNative({
    required String chain,
    required String routerAddress,
    required String tokenAddress,
    required BigInt tokenAmountUnits,
    required BigInt nativeAmountUnits,
    required double slippagePercent,
    required String recipientAddress,
  }) async {
    final wallet = await connectEvm(chain: chain);
    final keepBps = ((100 - slippagePercent) * 100).floor();
    final tokenMin =
        (tokenAmountUnits * BigInt.from(keepBps)) ~/ BigInt.from(10000);
    final nativeMin =
        (nativeAmountUnits * BigInt.from(keepBps)) ~/ BigInt.from(10000);
    final deadline = BigInt.from(
      DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 + 20 * 60,
    );
    final data =
        '0xf305d719'
        '${_addressWord(tokenAddress)}'
        '${_uintWord(tokenAmountUnits)}'
        '${_uintWord(tokenMin)}'
        '${_uintWord(nativeMin)}'
        '${_addressWord(recipientAddress)}'
        '${_uintWord(deadline)}';
    return _sendAndWait(
      from: wallet.address,
      to: routerAddress,
      data: data,
      value: nativeAmountUnits,
      action: 'LIQUIDITY',
    );
  }

  static Future<String> swapUniswapV2NativePair({
    required String chain,
    required String routerAddress,
    required String tokenAddress,
    required String wrappedNativeAddress,
    required BigInt amountInUnits,
    required BigInt minimumOutUnits,
    required String recipientAddress,
    required bool tokenToNative,
  }) async {
    final wallet = await connectEvm(chain: chain);
    final deadline = BigInt.from(
      DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000 + 20 * 60,
    );
    if (tokenToNative) {
      final data =
          '0x18cbafe5'
          '${_uintWord(amountInUnits)}'
          '${_uintWord(minimumOutUnits)}'
          '${_uintWord(BigInt.from(160))}'
          '${_addressWord(recipientAddress)}'
          '${_uintWord(deadline)}'
          '${_uintWord(BigInt.from(2))}'
          '${_addressWord(tokenAddress)}'
          '${_addressWord(wrappedNativeAddress)}';
      return _sendAndWait(
        from: wallet.address,
        to: routerAddress,
        data: data,
        action: 'SWAP TOKEN→NATIVE',
      );
    }
    final data =
        '0x7ff36ab5'
        '${_uintWord(minimumOutUnits)}'
        '${_uintWord(BigInt.from(128))}'
        '${_addressWord(recipientAddress)}'
        '${_uintWord(deadline)}'
        '${_uintWord(BigInt.from(2))}'
        '${_addressWord(wrappedNativeAddress)}'
        '${_addressWord(tokenAddress)}';
    return _sendAndWait(
      from: wallet.address,
      to: routerAddress,
      data: data,
      value: amountInUnits,
      action: 'SWAP NATIVE→TOKEN',
    );
  }

  static dynamic _autoVerifyProvider(bool useKaiaWallet) {
    final provider = useKaiaWallet ? _kaiaWallet : _metaMaskProvider;
    if (provider == null) {
      throw StateError(
        useKaiaWallet
            ? 'Kaia Wallet을 찾지 못했습니다. 현재 ORQUBE를 연 같은 브라우저에 Kaia Wallet 확장이 설치·활성화되어 있는지 확인해 주세요.'
            : 'MetaMask를 찾지 못했습니다. 현재 ORQUBE를 연 같은 브라우저에 MetaMask 확장이 설치·활성화되어 있는지 확인해 주세요.',
      );
    }
    return provider;
  }

  static String _autoVerifyWalletLabel(bool useKaiaWallet) =>
      useKaiaWallet ? 'Kaia Wallet' : 'MetaMask';

  static String _normalizeChainId(dynamic raw) {
    final value = raw.toString().trim().toLowerCase();
    if (value.startsWith('0x')) return value;
    final decimal = int.tryParse(value);
    return decimal == null ? value : '0x${decimal.toRadixString(16)}';
  }

  static Future<String> _providerChainId(dynamic provider) async {
    try {
      final raw = await _requestWith(provider, 'eth_chainId');
      return _normalizeChainId(raw);
    } catch (_) {
      final raw = await _requestWith(provider, 'net_version');
      return _normalizeChainId(raw);
    }
  }

  static Future<void> _ensureKaiaMainnetForProvider({
    required dynamic provider,
    required bool useKaiaWallet,
  }) async {
    const info = {
      'chainId': '0x2019',
      'chainName': 'Kaia Mainnet',
      'rpcUrl': 'https://public-en.node.kaia.io',
      'explorerUrl': 'https://kaiascan.io',
    };

    if (!useKaiaWallet) {
      try {
        await _requestWith(provider, 'wallet_switchEthereumChain', [
          {'chainId': info['chainId']},
        ]);
      } catch (_) {
        await _requestWith(provider, 'wallet_addEthereumChain', [
          {
            'chainId': info['chainId'],
            'chainName': info['chainName'],
            'nativeCurrency': {'name': 'KAIA', 'symbol': 'KAIA', 'decimals': 18},
            'rpcUrls': [info['rpcUrl']],
            'blockExplorerUrls': [info['explorerUrl']],
          },
        ]);
      }
    }

    final actual = await _providerChainId(provider);
    if (actual != '0x2019') {
      final wallet = _autoVerifyWalletLabel(useKaiaWallet);
      throw StateError(
        useKaiaWallet
            ? '$wallet에서 Kaia Mainnet(8217)을 먼저 선택해 주세요. 현재 Chain ID: $actual'
            : '$wallet Kaia Mainnet(8217) 전환에 실패했습니다. 현재 Chain ID: $actual',
      );
    }
  }

  static Future<BrowserWalletResult> connectKaiaMainnet({
    required bool useKaiaWallet,
  }) async {
    final provider = _autoVerifyProvider(useKaiaWallet);
    final accountsRaw = await _requestWith(provider, 'eth_requestAccounts');
    final accounts = js_util.dartify(accountsRaw);
    if (accounts is! List || accounts.isEmpty) {
      throw StateError('${_autoVerifyWalletLabel(useKaiaWallet)} 계정 승인이 필요합니다.');
    }
    await _ensureKaiaMainnetForProvider(
      provider: provider,
      useKaiaWallet: useKaiaWallet,
    );
    return BrowserWalletResult(
      address: accounts.first.toString(),
      chain: 'Kaia',
    );
  }

  static Future<BigInt> kaiaMainnetNativeBalance({
    required String walletAddress,
    required bool useKaiaWallet,
  }) async {
    final provider = _autoVerifyProvider(useKaiaWallet);
    await _ensureKaiaMainnetForProvider(
      provider: provider,
      useKaiaWallet: useKaiaWallet,
    );
    final raw = await _requestWith(provider, 'eth_getBalance', [
      walletAddress,
      'latest',
    ]);
    final hex = raw.toString().replaceFirst('0x', '');
    return hex.isEmpty ? BigInt.zero : BigInt.parse(hex, radix: 16);
  }

  static Future<BigInt> kaiaMainnetErc20Balance({
    required String contractAddress,
    required String walletAddress,
    required bool useKaiaWallet,
  }) async {
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(contractAddress)) {
      throw ArgumentError('ORBS 컨트랙트 주소가 올바르지 않습니다.');
    }
    final provider = _autoVerifyProvider(useKaiaWallet);
    await _ensureKaiaMainnetForProvider(
      provider: provider,
      useKaiaWallet: useKaiaWallet,
    );
    final cleanAddress = walletAddress.toLowerCase().replaceFirst('0x', '');
    final data = '0x70a08231${_pad64(cleanAddress)}';
    final raw = await _requestWith(provider, 'eth_call', [
      {'to': contractAddress, 'data': data},
      'latest',
    ]);
    final hex = raw.toString().replaceFirst('0x', '');
    return hex.isEmpty ? BigInt.zero : BigInt.parse(hex, radix: 16);
  }

  static Future<String> _sendAndWaitWithProvider({
    required dynamic provider,
    required String from,
    required String to,
    required String data,
    BigInt? value,
    String action = '트랜잭션',
  }) async {
    final tx = <String, dynamic>{'from': from, 'to': to, 'data': data};
    if (value != null && value > BigInt.zero) {
      tx['value'] = '0x${value.toRadixString(16)}';
    }
    final raw = await _requestWith(provider, 'eth_sendTransaction', [tx]);
    final txHash = raw.toString();
    for (var i = 0; i < 60; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final receiptRaw = await _requestWith(provider, 'eth_getTransactionReceipt', [
        txHash,
      ]);
      final receipt = js_util.dartify(receiptRaw);
      if (receipt is Map && receipt.isNotEmpty) {
        final status = (receipt['status'] ?? '').toString().toLowerCase();
        if (status == '0x0') {
          throw StateError('$action 트랜잭션이 실패했습니다. Tx: $txHash');
        }
        if (status == '0x1') return txHash;
      }
    }
    throw StateError('$action 트랜잭션은 제출되었지만 확인 시간이 초과되었습니다. Tx: $txHash');
  }

  static Future<String> sendKaiaMainnetNative({
    required String toAddress,
    required double amountKai,
    required bool useKaiaWallet,
    String expectedFrom = '',
  }) async {
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(toAddress)) {
      throw ArgumentError('AUTO VERIFY 운영지갑 주소가 올바르지 않습니다.');
    }
    final provider = _autoVerifyProvider(useKaiaWallet);
    await _ensureKaiaMainnetForProvider(
      provider: provider,
      useKaiaWallet: useKaiaWallet,
    );
    final accountsRaw = await _requestWith(provider, 'eth_requestAccounts');
    final accounts = js_util.dartify(accountsRaw);
    if (accounts is! List || accounts.isEmpty) {
      throw StateError('${_autoVerifyWalletLabel(useKaiaWallet)} 계정 승인이 필요합니다.');
    }
    final from = accounts.first.toString();
    if (expectedFrom.isNotEmpty && from.toLowerCase() != expectedFrom.toLowerCase()) {
      throw StateError('CONNECT WALLET 이후 현재 계정이 변경되었습니다. 결제를 중단했습니다.');
    }
    final wei = BigInt.parse((amountKai * 1e18).round().toString());
    return _sendAndWaitWithProvider(
      provider: provider,
      from: from,
      to: toAddress,
      data: '0x',
      value: wei,
      action: 'AUTO VERIFY KAI 결제',
    );
  }

  static Future<String> sendKaiaMainnetErc20({
    required String contractAddress,
    required String toAddress,
    required BigInt amountUnits,
    required bool useKaiaWallet,
    String expectedFrom = '',
  }) async {
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(contractAddress)) {
      throw ArgumentError('ORBS 컨트랙트 주소가 올바르지 않습니다.');
    }
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(toAddress)) {
      throw ArgumentError('AUTO VERIFY 운영지갑 주소가 올바르지 않습니다.');
    }
    final provider = _autoVerifyProvider(useKaiaWallet);
    await _ensureKaiaMainnetForProvider(
      provider: provider,
      useKaiaWallet: useKaiaWallet,
    );
    final accountsRaw = await _requestWith(provider, 'eth_requestAccounts');
    final accounts = js_util.dartify(accountsRaw);
    if (accounts is! List || accounts.isEmpty) {
      throw StateError('${_autoVerifyWalletLabel(useKaiaWallet)} 계정 승인이 필요합니다.');
    }
    final from = accounts.first.toString();
    if (expectedFrom.isNotEmpty && from.toLowerCase() != expectedFrom.toLowerCase()) {
      throw StateError('CONNECT WALLET 이후 현재 계정이 변경되었습니다. 결제를 중단했습니다.');
    }
    final cleanTo = toAddress.toLowerCase().replaceFirst('0x', '');
    final data = '0xa9059cbb${_pad64(cleanTo)}${_pad64(amountUnits.toRadixString(16))}';
    return _sendAndWaitWithProvider(
      provider: provider,
      from: from,
      to: contractAddress,
      data: data,
      action: 'AUTO VERIFY ORBS 결제',
    );
  }

  static Future<BrowserDeploymentResult> deployEvm({
    required String chain,
    required String bytecode,
  }) async {
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    final wallet = await connectEvm(chain: chain);
    final txHashRaw = await _requestRaw('eth_sendTransaction', [
      {'from': wallet.address, 'data': bytecode},
    ]);
    final txHash = txHashRaw.toString();
    for (var i = 0; i < 60; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));
      final receiptRaw = await _requestRaw('eth_getTransactionReceipt', [
        txHash,
      ]);
      final receipt = js_util.dartify(receiptRaw);
      if (receipt is Map && receipt.isNotEmpty) {
        final status = (receipt['status'] ?? '').toString().toLowerCase();
        if (status == '0x0') throw StateError('온체인 배포 트랜잭션이 실패했습니다.');
        final address = (receipt['contractAddress'] ?? '').toString();
        if (address.isNotEmpty) {
          return BrowserDeploymentResult(
            address: address,
            txHash: txHash,
            chain: chain,
            walletAddress: wallet.address,
          );
        }
      }
    }
    throw StateError('배포 트랜잭션은 전송되었지만 확인 시간이 초과되었습니다. Tx: $txHash');
  }

  static Future<BrowserDeploymentResult> deploySolana({
    required int decimals,
    required int totalSupply,
  }) async {
    if (!js_util.hasProperty(html.window, 'orqubeSolanaDeployMint')) {
      throw StateError('Solana Devnet 배포 브리지를 불러오지 못했습니다.');
    }
    final fn = js_util.getProperty(html.window, 'orqubeSolanaDeployMint');
    final promise = js_util.callMethod(fn, 'call', [
      html.window,
      decimals,
      totalSupply.toString(),
    ]);
    final raw = await js_util.promiseToFuture<dynamic>(promise);
    final data = js_util.dartify(raw);
    if (data is! Map) throw StateError('Solana 배포 결과를 확인할 수 없습니다.');
    return BrowserDeploymentResult(
      address: (data['address'] ?? '').toString(),
      txHash: (data['txHash'] ?? '').toString(),
      chain: 'Solana',
      walletAddress:
          (data['walletAddress'] ?? data['ownerAddress'] ?? '').toString(),
    );
  }
}
