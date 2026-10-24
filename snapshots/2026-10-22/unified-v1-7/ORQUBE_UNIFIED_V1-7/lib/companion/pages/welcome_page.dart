import 'safe_hiking_page.dart';
import 'orqube_domain_button.dart';
import '../utils/app_language.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'role_entry_page.dart';
import 'connection_invite_page.dart';
import 'public_help_center_page.dart';
import 'companion_theme.dart';
class WelcomeGate extends StatefulWidget {
  final OrqubeMapMode? initialMode;
  WelcomeGate({super.key, this.initialMode});
  @override State<WelcomeGate> createState() => _WelcomeGateState();
}
class _WelcomeGateState extends State<WelcomeGate> with LanguageAware<WelcomeGate> {
  bool? accepted;
  bool checked = false;
  @override void initState() { super.initState(); load(); }
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => accepted = prefs.getBool('hiking_intro_v2') ?? false);
  }
  @override Widget build(BuildContext context) => Theme(data: companionLightTheme(), child: Builder(builder: _buildPage));
  Widget _buildPage(BuildContext context) {
    if (accepted == null) return Scaffold(body: Center(child: CircularProgressIndicator()));
    if (accepted!) return InviteHomeGate(child: RoleEntryPage(initialMode: widget.initialMode));
    return Scaffold(appBar: AppBar(actions: [OrqubeDomainButton(), LanguageButton()], title: AppText('ORQUBE • 안심동행 시작하기')),
      body: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 720),
        child: Material(color: Color(0xFFF3F6F4), child: ListView(padding: EdgeInsets.all(24), children: [
          Icon(Icons.landscape_rounded, size: 80, color: Color(0xFF176B53)),
          AppText('준비하고, 기록하고, 안전하게 돌아오세요.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          AppText('안전산행·안심귀가·가족과 친구 위치 확인을 제공합니다. 승인한 보호자와 이동 중 위치·최근 경로를 공유할 수 있습니다. GPS 경로·출발점·귀환 계획과 저장 지도 기능도 제공합니다. 실제 위치 권한은 내 위치 또는 산행 시작을 누를 때 요청합니다. 권한을 거부해도 설명서를 볼 수 있습니다.', style: TextStyle(height: 1.7)),
          Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Color(0xFFDFE8E2))), child: Padding(padding: EdgeInsets.all(20), child: AppText('개인정보 안내\n이메일은 Firebase 인증에 사용합니다. 보호자 이름·연락처와 위치·시간·산행 상태는 기능 이용 시 Firebase 서버에 저장됩니다. 보호자 연락처 등록만으로 알림이 발송되지 않습니다. 지도 제공자·주소 검색·길찾기 서비스에는 요청한 지역 또는 좌표가 전달될 수 있습니다.\n\n기록은 직접 삭제할 때까지 보관될 수 있습니다. 계정 화면에서 산행 기록 삭제·회원탈퇴를 할 수 있습니다. 외부 메시지로 보낸 위치는 앱에서 회수할 수 없습니다.', style: TextStyle(height: 1.7)))),
          Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Color(0xFFDFE8E2))), child: Padding(padding: EdgeInsets.all(20), child: AppText('지원 범위\nSOS는 서버 기록 및 좌표 안내이며 119 자동 신고가 아닙니다. 저장 지도는 현재 화면 영역의 이미지입니다. 앱 종료·기기 절전·GPS 불량 시 기록이 중단될 수 있습니다. 백신 검사·외부 보안 인증을 받은 앱이라는 표시는 사용하지 않습니다.', style: TextStyle(height: 1.7)))),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PublicHelpCenterPage(language: 'ko'))), child: AppText('상세 사용설명서와 데이터 처리 안내')),
          CheckboxListTile(tileColor: Colors.white, value: checked, onChanged: (v) => setState(() => checked = v ?? false), title: AppText('개인정보·위치 사용 방식과 지원 범위를 확인했습니다.')),
          FilledButton(onPressed: checked ? () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('hiking_intro_v2', true);
            if (mounted) setState(() => accepted = true);
          } : null, child: AppText('안심동행 시작하기')),
        ])))));
  }
}
