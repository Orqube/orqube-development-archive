/// TOKEN USE CENTER progression model.
///
/// The four core utility stages are cumulative. A project that reaches
/// Campaign, for example, keeps Reward and Membership active. `utilityMode`
/// remains supported as a backward-compatible alias for the highest stage.
enum TokenUseStage {
  reward('reward', 'REWARD', '활동·기여 보상', '커뮤니티 참여, 미션, 이벤트, 기여에 대한 토큰 보상'),
  membership('membership', 'MEMBERSHIP', '보유자 혜택·참여권', '보유량 또는 보유 여부에 따라 콘텐츠, 혜택, 참여권을 제공'),
  campaign('campaign', 'CAMPAIGN', '쿠폰·이벤트·프로모션', '브랜드·크리에이터·지역 프로젝트의 캠페인 참여 수단'),

  // Keep legacy id `liquidity` for existing projects. The later real market
  // LIQUIDITY stage uses a separate market-stage namespace/index.
  liquidityReady('liquidity', 'LIQUIDITY READY', '공급·배분·LP 공개 후 거래 준비', '공급, 배분, 락업, 초기 유동성, 위험고지를 공개하고 거래 연결을 준비');

  const TokenUseStage(this.id, this.label, this.shortDescription, this.description);

  final String id;
  final String label;
  final String shortDescription;
  final String description;
}

class TokenUseProgress {
  const TokenUseProgress({required this.highestIndex});

  final int highestIndex;

  static TokenUseProgress fromData(Map<String, dynamic> data) {
    final explicit = data['utilityStageIndex'];
    if (explicit is num) {
      return TokenUseProgress(
        highestIndex: explicit
            .toInt()
            .clamp(0, TokenUseStage.values.length - 1)
            .toInt(),
      );
    }

    final legacy = (data['utilityMode'] ?? 'reward').toString();
    final legacyIndex = TokenUseStage.values.indexWhere((stage) => stage.id == legacy);
    return TokenUseProgress(highestIndex: legacyIndex < 0 ? 0 : legacyIndex);
  }

  TokenUseStage get current => TokenUseStage.values[highestIndex];
  bool get isComplete => highestIndex >= TokenUseStage.values.length - 1;
  TokenUseStage? get next => isComplete ? null : TokenUseStage.values[highestIndex + 1];

  bool isActive(TokenUseStage stage) => TokenUseStage.values.indexOf(stage) <= highestIndex;
  bool isNext(TokenUseStage stage) => next == stage;
}

/// Market expansion starts only after all four core utility stages are active.
/// It intentionally has its own namespace so legacy `utilityMode=liquidity`
/// (LIQUIDITY READY) never collides with the real LIQUIDITY market stage.
enum TokenMarketStage {
  drops('drops', 'DROPS', '대상·수량·조건을 정해 토큰 배포/에어드롭을 준비'),
  liquidity('market_liquidity', 'LIQUIDITY', '초기 유동성·가격·LP 조건 공개 후 풀 연결'),
  swap('swap', 'SWAP', '유동성·고지·운영 조건 충족 후 교환 기능 연결');

  const TokenMarketStage(this.id, this.label, this.description);
  final String id;
  final String label;
  final String description;
}

class TokenMarketProgress {
  const TokenMarketProgress({required this.highestIndex});
  final int highestIndex;

  static TokenMarketProgress fromData(Map<String, dynamic> data) {
    final explicit = data['marketStageIndex'];
    if (explicit is num) {
      return TokenMarketProgress(
        highestIndex: explicit.toInt().clamp(-1, TokenMarketStage.values.length - 1).toInt(),
      );
    }

    // Compatibility with the boolean placeholder written by the previous patch.
    final raw = data['marketExpansion'];
    if (raw is Map) {
      if (raw['swap'] == true) return const TokenMarketProgress(highestIndex: 2);
      if (raw['liquidity'] == true) return const TokenMarketProgress(highestIndex: 1);
      if (raw['drops'] == true) return const TokenMarketProgress(highestIndex: 0);
    }
    return const TokenMarketProgress(highestIndex: -1);
  }

  bool get hasStarted => highestIndex >= 0;
  bool get isComplete => highestIndex >= TokenMarketStage.values.length - 1;
  TokenMarketStage? get current => hasStarted ? TokenMarketStage.values[highestIndex] : null;
  TokenMarketStage? get next =>
      isComplete ? null : TokenMarketStage.values[highestIndex + 1];
  bool isActive(TokenMarketStage stage) =>
      highestIndex >= TokenMarketStage.values.indexOf(stage);
  bool isNext(TokenMarketStage stage) => next == stage;
}

const tokenUseFuturePipeline = <({String id, String label, String description})>[
  (id: 'drops', label: 'DROPS', description: '대상·수량·조건을 정해 토큰 배포/에어드롭을 연결'),
  (id: 'market_liquidity', label: 'LIQUIDITY', description: '초기 유동성·가격·LP 조건 공개 후 풀 연결'),
  (id: 'swap', label: 'SWAP', description: '유동성·고지·운영 조건 충족 후 교환 기능 연결'),
];
