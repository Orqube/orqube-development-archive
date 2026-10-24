import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobHelper {
  // 반드시 본인 AdMob 광고 단위 ID로 교체하세요.
  static const String androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  static RewardedAd? _rewardedAd;
  static bool _loadingRewarded = false;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await loadRewardedAd();
  }

  static Future<void> loadRewardedAd() async {
    if (_loadingRewarded) return;
    _loadingRewarded = true;

    await RewardedAd.load(
      adUnitId: androidRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _loadingRewarded = false;
        },
      ),
    );
  }

  static Future<void> showRewardedAd({required VoidCallback onRewarded}) async {
    final ad = _rewardedAd;
    if (ad == null) {
      await loadRewardedAd();
      // 광고가 실제로 로드되지 않았다면 보상을 지급하지 않습니다.
      return;
    }

    _rewardedAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadRewardedAd();
      },
    );

    await ad.show(onUserEarnedReward: (ad, reward) {
      onRewarded();
    });
  }
}

class AdMobBannerBox extends StatefulWidget {
  const AdMobBannerBox({super.key});

  @override
  State<AdMobBannerBox> createState() => _AdMobBannerBoxState();
}

class _AdMobBannerBoxState extends State<AdMobBannerBox> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdMobHelper.androidBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _loaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() => _loaded = false);
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
    if (!_loaded || _bannerAd == null) {
      return Container(
        height: 72,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: const Text('AdMob Banner Loading...', style: TextStyle(color: Colors.white70)),
      );
    }

    return SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
