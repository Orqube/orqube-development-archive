import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobIds {
  // 테스트 광고 ID입니다. 실제 출시 전에는 AdMob 콘솔에서 만든 본인 광고 ID로 교체하세요.
  static const rewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const banner = 'ca-app-pub-3940256099942544/6300978111';
}

class AdMobHelper {
  static RewardedAd? _rewardedAd;
  static bool _isLoadingRewarded = false;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await loadRewardedAd();
  }

  static Future<void> loadRewardedAd() async {
    if (_isLoadingRewarded) return;
    _isLoadingRewarded = true;

    await RewardedAd.load(
      adUnitId: AdMobIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoadingRewarded = false;
        },
      ),
    );
  }

  static Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onUnavailable,
  }) async {
    final ad = _rewardedAd;

    if (ad == null) {
      onUnavailable();
      await loadRewardedAd();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onUnavailable();
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
      },
    );
  }
}

class AdMobBannerBox extends StatefulWidget {
  const AdMobBannerBox({super.key});

  @override
  State<AdMobBannerBox> createState() => _AdMobBannerBoxState();
}

class _AdMobBannerBoxState extends State<AdMobBannerBox> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: AdMobIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _isLoaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: const Text(
          'AdMob Banner Loading...',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      );
    }

    return Container(
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
