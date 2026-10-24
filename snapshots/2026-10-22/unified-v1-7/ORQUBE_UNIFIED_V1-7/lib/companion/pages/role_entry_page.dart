import 'package:flutter/material.dart';
import '../utils/app_language.dart';
import 'companion_theme.dart';
import 'safe_hiking_page.dart';
import 'companion_home.dart';
import 'guardian_page.dart';
import 'public_help_center_page.dart';
class RoleEntryPage extends StatelessWidget {
  final OrqubeMapMode? initialMode;
  const RoleEntryPage({super.key, this.initialMode});
  @override Widget build(BuildContext context) => Theme(data: companionLightTheme(), child: Scaffold(
    appBar: AppBar(title: AppText('안심동행 · 역할 선택'), actions: const [LanguageButton()]),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: ListView(padding: const EdgeInsets.all(24), children: [
      AppText('이용객 / 보호자', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      FilledButton.icon(icon: const Icon(Icons.hiking), label: AppText('이용객 · 산행·귀가 시작'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => initialMode == null ? CompanionHome() : SafeHikingPage(initialMode: initialMode!)))),
      AppText('이용객: 시작 준비 → 보호자 선택 → 산행·공유 시작'),
      const SizedBox(height: 20),
      FilledButton.icon(icon: const Icon(Icons.people), label: AppText('보호자 · 상대 위치 보기'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardianPage()))),
      AppText('보호자: 로그인 → 사람 연결·수락 → 상대 위치 보기'),
      const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: AppText('웹에서는 이 화면을 켜 두고 위치 권한과 인터넷 연결을 유지하세요. 화면 잠금·다른 탭·절전 시 위치 전송이 중단될 수 있습니다. 앱도 종료·절전 시 연속 전송을 보장하지 않습니다. 보호자는 마지막 수신 시간을 확인하세요.', style: const TextStyle(height: 1.7)))),
      AppText('웹·앱 모두 같은 오르큐브 계정 체계와 사람 초대 QR을 사용합니다. 토큰·추천인 QR은 사람 연결용이 아닙니다. 연결 수락만으로 위치가 공개되지 않습니다.'),
      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicHelpCenterPage(language: AppLanguage.changed.value))), child: AppText('통합 사용설명서')),
    ]))),
  ));
}
