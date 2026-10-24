enum LaunchChain { kaia, polygon, solana }

extension LaunchChainInfo on LaunchChain {
  String get key => switch (this) {
    LaunchChain.kaia => 'Kaia',
    LaunchChain.polygon => 'Polygon',
    LaunchChain.solana => 'Solana',
  };

  String get label => switch (this) {
    LaunchChain.kaia => 'KAIA',
    LaunchChain.polygon => 'POLYGON',
    LaunchChain.solana => 'SOLANA',
  };

  String get testnetLabel => switch (this) {
    LaunchChain.kaia => 'Kairos Testnet',
    LaunchChain.polygon => 'Amoy Testnet',
    LaunchChain.solana => 'Devnet',
  };

  bool get isEvm => this != LaunchChain.solana;

  static LaunchChain fromStored(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'polygon': return LaunchChain.polygon;
      case 'solana': return LaunchChain.solana;
      default: return LaunchChain.kaia;
    }
  }
}
