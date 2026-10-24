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
  const BrowserDeploymentResult({required this.address, required this.txHash, required this.chain});
  final String address;
  final String txHash;
  final String chain;
}

class BrowserWalletBridge {
  static dynamic get _ethereum => js_util.getProperty(html.window, 'ethereum');
  static bool get isSupported => _ethereum != null;
  static bool get isSolanaSupported =>
      js_util.hasProperty(html.window, 'orqubeSolanaConnect');

  static Future<dynamic> _requestRaw(String method, [dynamic params]) async {
    final request = <String, dynamic>{'method': method};
    if (params != null) request['params'] = params;
    final promise = js_util.callMethod(_ethereum, 'request', [js_util.jsify(request)]);
    return js_util.promiseToFuture<dynamic>(promise);
  }

  static Map<String, String> _network(String chain) {
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
    final n = _network(chain);
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

  static Future<BrowserWalletResult> connectEvm({required String chain}) async {
    if (_ethereum == null) {
      throw StateError('MetaMask를 찾지 못했습니다. 확장 프로그램 또는 MetaMask 인앱 브라우저를 확인해 주세요.');
    }
    final accountsRaw = await _requestRaw('eth_requestAccounts');
    final accounts = js_util.dartify(accountsRaw);
    if (accounts is! List || accounts.isEmpty) {
      throw StateError('MetaMask 계정 승인이 필요합니다.');
    }
    await _switchEvmNetwork(chain);
    return BrowserWalletResult(address: accounts.first.toString(), chain: chain);
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

  static Future<BigInt> erc20BalanceOf({
    required String chain,
    required String contractAddress,
    required String walletAddress,
  }) async {
    if (_ethereum == null) throw StateError('MetaMask를 찾지 못했습니다.');
    await _switchEvmNetwork(chain);
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
      final receiptRaw = await _requestRaw('eth_getTransactionReceipt', [txHash]);
      final receipt = js_util.dartify(receiptRaw);
      if (receipt is Map && receipt.isNotEmpty) {
        final status = (receipt['status'] ?? '').toString().toLowerCase();
        if (status == '0x0') throw StateError('DROPS 전송 트랜잭션이 실패했습니다. Tx: $txHash');
        if (status == '0x1') return txHash;
      }
    }
    throw StateError('DROPS 전송은 제출되었지만 확인 시간이 초과되었습니다. Tx: $txHash');
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
      final receiptRaw = await _requestRaw('eth_getTransactionReceipt', [txHash]);
      final receipt = js_util.dartify(receiptRaw);
      if (receipt is Map && receipt.isNotEmpty) {
        final status = (receipt['status'] ?? '').toString().toLowerCase();
        if (status == '0x0') throw StateError('온체인 배포 트랜잭션이 실패했습니다.');
        final address = (receipt['contractAddress'] ?? '').toString();
        if (address.isNotEmpty) {
          return BrowserDeploymentResult(address: address, txHash: txHash, chain: chain);
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
    final promise = js_util.callMethod(fn, 'call', [html.window, decimals, totalSupply.toString()]);
    final raw = await js_util.promiseToFuture<dynamic>(promise);
    final data = js_util.dartify(raw);
    if (data is! Map) throw StateError('Solana 배포 결과를 확인할 수 없습니다.');
    return BrowserDeploymentResult(
      address: (data['address'] ?? '').toString(),
      txHash: (data['txHash'] ?? '').toString(),
      chain: 'Solana',
    );
  }
}
