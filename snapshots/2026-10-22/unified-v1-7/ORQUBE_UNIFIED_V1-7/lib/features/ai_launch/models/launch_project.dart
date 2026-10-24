enum LaunchCategory {
  dailyLife,
  hobby,
  work,
  localBusiness,
  professional,
  creator,
  community,
  event,
  meme,
  publicFigure,

  // 아래 항목은 UI에서 보이지만 self-service 토큰 발행은 막습니다.
  politics,
  financialInvestment,
  gambling,
  prohibitedCommerce,
}

enum AssetMode {
  digitalBadge,
  communityToken,
  publicToken,
}

enum LaunchStatus {
  draft,
  review,
  published,
  deploymentReady,
  deployed,
  externalMarketReady,
  archived,
}
