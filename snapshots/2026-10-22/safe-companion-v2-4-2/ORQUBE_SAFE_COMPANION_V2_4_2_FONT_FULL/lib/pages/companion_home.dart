import '../services/trip_tracking.dart';
import '../services/guardian_share.dart';
import 'location_share_page.dart';
import 'orqube_domain_button.dart';
import '../utils/app_language.dart';
import 'package:flutter/material.dart';
import 'companion_theme.dart';
import 'safe_hiking_page.dart';
import 'hiking_account_page.dart';
import 'guardian_page.dart';
import 'public_help_center_page.dart';
class CompanionHome extends StatelessWidget {
  CompanionHome({super.key});
  @override Widget build(BuildContext context) => Theme(data: companionLightTheme(), child: Builder(builder: _buildPage));
  Widget _buildPage(BuildContext context) {
    void open(Widget page) {
      final tracking=TripTracking.instance;
      if(tracking.active && (page is SafeHikingPage || page is LocationSharePage)) {
        page=tracking.mode=='location'?const LocationSharePage():SafeHikingPage(initialMode:tracking.mode=='safe_home'?OrqubeMapMode.safeHome:OrqubeMapMode.safeHiking);
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
    return Scaffold(appBar: AppBar(title: AppText('ORQUBE 안심동행'), actions: [OrqubeDomainButton(), LanguageButton(),IconButton(onPressed: () => open(HikingAccountPage()), icon: Icon(Icons.account_circle_outlined))]),
      body: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 720), child: ListView(padding: EdgeInsets.all(24), children: [
        Container(padding: EdgeInsets.all(28), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(colors: [Color(0xFF165442), Color(0xFF15354F)])), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.health_and_safety, size: 48, color: Colors.white), SizedBox(height: 16), AppText('떠나는 순간부터\n안전하게 돌아올 때까지', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)), SizedBox(height: 12), AppText('나의 동의로 시작하는 위치 공유\n안전산행 · 안심귀가 · 보호자 연결', style: TextStyle(color: Color(0xFFD9EBE3), height: 1.6))])),
        SizedBox(height: 24),
        ListenableBuilder(listenable:TripTracking.instance,builder:(context,_) {
          final t=TripTracking.instance;
          if(!t.active)return const SizedBox.shrink();
          return Card(child:ListTile(leading:const Icon(Icons.my_location),
            title:AppText('이동 기록 진행 중 · 화면을 나가도 계속됩니다'),
            subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(t.mode=='location'?'30 min':t.mode=='safe_home'?AppLanguage.t('안심귀가'):AppLanguage.t('안전산행')),
              if(t.position!=null)Text('${AppLanguage.t('마지막 GPS 수신')}: ${t.position!.timestamp.toLocal()}'),
              ValueListenableBuilder<ShareDelivery>(valueListenable: GuardianShare.delivery,
                builder: (context, delivery, _) => AppText(!t.sharing ? '위치 공유 상태: 공유 안 함' : delivery.failed ? '위치 전송 실패 · 인터넷과 위치 권한을 확인하세요.' : delivery.confirmedAt == null ? '위치 공유 상태: 서버 전송 확인 중' : '위치 공유 중 · 마지막 서버 저장: ${delivery.confirmedAt!.toLocal()}')),
              if(t.error!=null)AppText('위치 또는 전송 오류 · 마지막 수신 시각을 확인하세요.'),
            ]),
            trailing:const Icon(Icons.chevron_right),onTap:()=>open(t.mode=='location'?const LocationSharePage():SafeHikingPage())));
        }),
        _tile(Icons.landscape, '안전산행', '산행 경로와 귀환 계획', () => open(SafeHikingPage(initialMode: OrqubeMapMode.safeHiking))),
        _tile(Icons.nightlight_round, '안심귀가', '목적지와 귀가 경로 기록', () => open(SafeHikingPage(initialMode: OrqubeMapMode.safeHome))),
        _tile(Icons.share_location, '위치 공유', '가족·친구와 30분 위치 공유', () => open(LocationSharePage())),
        _tile(Icons.people_alt, '내 사람·모임', '가족·친구 연결 · 변경 · 공유 중지 · 해제', () => open(GuardianPage())),
        _tile(Icons.login, '로그인 · 내 계정', '오르큐브 계정으로 이용', () => open(HikingAccountPage())),
        _tile(Icons.menu_book_outlined, '통합 사용설명서', '산행 · 귀가 · 가족과 친구 위치 공유 안내', () => open(PublicHelpCenterPage(language: 'ko'))),
        SizedBox(height: 16), AppText('통합 V2.4 · 위치 공유는 이동 화면의 공유 버튼으로 시작합니다. 보호자도 로그인해야 합니다. 문자로 보낸 지도 좌표는 실시간 링크가 아닙니다. 앱 내부 화면 이동은 기록을 종료하지 않습니다. 강제 종료·기기 절전·통신 단절 시 갱신이 중단될 수 있습니다.', style: TextStyle(color: Color(0xFF526B60), height: 1.6)),
      ]))));
  }
  Widget _tile(IconData icon, String title, String subtitle, VoidCallback tap) => Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Color(0xFFDFE8E2))), margin: EdgeInsets.only(bottom: 12), child: ListTile(contentPadding: EdgeInsets.all(18), leading: Icon(icon, size: 32, color: Color(0xFF176B53)), title: AppText(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)), subtitle: AppText(subtitle), trailing: Icon(Icons.chevron_right), onTap: tap));
}
