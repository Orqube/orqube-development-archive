import 'package:flutter/material.dart';
import 'ai_three_way_debate_page.dart';
import 'mixed_debate_rooms_page.dart';
import 'visual_debate_page.dart';
import '../services/admin_access.dart';

class DebateHubPage extends StatelessWidget {
  final bool adminMode;
  const DebateHubPage({super.key, this.adminMode = false});
  @override
  Widget build(BuildContext context) => adminMode
      ? FutureBuilder<bool>(
          future: AdminAccess.allowed(),
          builder: (context, snapshot) => snapshot.data == true
              ? _content(context, true)
              : Scaffold(appBar: AppBar(title: const Text('관리자 토론')),
                  body: Center(child: Text(snapshot.connectionState == ConnectionState.waiting
                      ? '권한 확인 중…' : '관리자만 이용할 수 있습니다.'))),
        )
      : _content(context, false);

  Widget _content(BuildContext context, bool admin) => Scaffold(
    appBar: AppBar(title: Text(admin ? '관리자 토론 대시보드' : '사람·AI 선택형 토론')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      if (admin) _entry(context, 'AI 3자 토론', '기존 음성 토론 · 풍자 설정',
        Icons.record_voice_over, const AiThreeWayDebatePage()),
      _entry(context, '사람·AI 선택형 토론', '진행자·패널 구성과 공동 토론방',
        Icons.groups, const MixedDebateRoomsPage()),
      if (admin) _entry(context, '자료 동반형 토론', '발언과 도표·표어·이미지 · 녹화',
        Icons.slideshow, const VisualDebatePage()),
    ]),
  );
  Widget _entry(BuildContext context, String title, String subtitle,
    IconData icon, Widget page) => Card(child: ListTile(
      contentPadding: const EdgeInsets.all(16), leading: Icon(icon),
      title: Text(title), subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
    ));
}
