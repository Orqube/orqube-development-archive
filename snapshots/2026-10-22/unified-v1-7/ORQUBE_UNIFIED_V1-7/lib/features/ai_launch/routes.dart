import 'package:flutter/material.dart';
import 'screens/ai_launch_home_page.dart';
import 'screens/launch_project_page.dart';

class AiLaunchRoutes {
  static const home = '/ai-launch';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == home) {
      final ownerUid = settings.arguments as String? ?? '';
      return MaterialPageRoute(
        builder: (_) => AiLaunchHomePage(ownerUid: ownerUid),
      );
    }

    if (settings.name != null &&
        settings.name!.startsWith('/ai-launch/project/')) {
      final id = settings.name!.split('/').last;
      return MaterialPageRoute(
        builder: (_) => LaunchProjectPage(projectId: id),
      );
    }

    return null;
  }
}
