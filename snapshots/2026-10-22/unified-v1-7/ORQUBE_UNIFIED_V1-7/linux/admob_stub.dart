import 'package:flutter/material.dart';

class AdMobHelper {
  static Future<void> initialize() async {}

  static Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    required VoidCallback onUnavailable,
  }) async {
    // Chrome/Web에서는 Google AdMob SDK가 직접 동작하지 않습니다.
    // 웹 테스트 중에는 보상 로직만 확인할 수 있도록 보상을 지급합니다.
    onRewarded();
  }
}

class AdMobBannerBox extends StatelessWidget {
  const AdMobBannerBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: const Text(
        'AdMob Banner Area — Android app에서 실제 광고가 표시됩니다.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }
}
