import 'package:flutter/material.dart';

import 'mobile_dashboard_page.dart';
import 'premium_splash_page.dart';

/// main_mobile.dart 또는 main.dart에서 DashboardPage 대신 이 위젯을 열면
/// Premium Splash → MobileDashboardPage 순서로 자동 실행됩니다.
class OrqubeV14Entry extends StatelessWidget {
  const OrqubeV14Entry({super.key});

  @override
  Widget build(BuildContext context) {
    return const PremiumSplashPage(nextPage: MobileDashboardPage());
  }
}
