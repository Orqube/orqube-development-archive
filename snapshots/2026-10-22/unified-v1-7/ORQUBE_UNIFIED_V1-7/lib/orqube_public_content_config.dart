/// Public, non-secret ORQUBE homepage configuration.
///
/// Keep API keys and secrets out of this file. Values here are intended to be
/// visible to every visitor and can be replaced later by Firestore-backed data.
class OrqubePublicContentConfig {
  static const String youtubeChannelUrl = 'https://www.youtube.com/@orqube';

  /// Representative ORQUBE homepage video.
  /// Change only this value when the featured video changes.
  static const String youtubeFeaturedVideoUrl =
      'https://youtu.be/R-BR28kb76Y?si=nOpXxVFlc9GO_GIR';
  static const String youtubeFeaturedVideoId = 'R-BR28kb76Y';
  static const String youtubeFeaturedThumbnailUrl =
      'https://img.youtube.com/vi/R-BR28kb76Y/hqdefault.jpg';

  /// 토론 영상 업로드 후 YouTube 공유 링크를 입력하세요.
  static const String debateVideoUrl = '';

  static const String xProfileUrl = 'https://x.com/orqubic';

  /// Official ORQUBE community NAVER Cafe.
  static const String naverCafeUrl =
      'https://m.cafe.naver.com/koreaspecialforces.cafe';

  static const String tokenName = 'ORBS';
  static const String maximumSupply = '310,000,000 ORBS';

  /// Update these two values after the final Kaia token deployment.
  static const String network = 'Kaia';
  static const String tokenContractAddress = '';
  static const String blockExplorerBaseUrl = 'https://kaiascan.io';

  /// Firestore public data locations used by the homepage.
  /// home_media/{doc}: enabled, type(image|video), title, description,
  /// thumbnailUrl, mediaUrl, sortOrder
  static const String mediaCollection = 'home_media';

  /// Realtime homepage mirror of NAVER Cafe posts.
  /// Fields: enabled, title, summary, url, publishedAt, sortOrder
  static const String cafePostsCollection = 'home_cafe_posts';

  /// public_config/blockchain can override holderCount, transferCount,
  /// network, contractAddress and explorerUrl without a code deployment.
  static const String publicConfigCollection = 'public_config';
  static const String blockchainDocument = 'blockchain';
}
