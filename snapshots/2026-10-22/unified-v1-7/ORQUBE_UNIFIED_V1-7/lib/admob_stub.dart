import 'package:flutter/material.dart';

class AdMobHelper {
  static Future<void> initialize() async {}

  static Future<void> showRewardedAd({required VoidCallback onRewarded}) async {
    // Chrome/Web test mode: give reward without loading a real mobile ad.
    onRewarded();
  }
}

class AdMobBannerBox extends StatelessWidget {
  const AdMobBannerBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: const Text(
        'Google AdMob Banner Area\nWeb preview mode',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}
