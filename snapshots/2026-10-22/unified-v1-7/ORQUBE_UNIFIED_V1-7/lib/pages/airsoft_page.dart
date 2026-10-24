import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/social_service.dart';
import 'team_create_page.dart';

class AirsoftPage extends StatelessWidget {
  const AirsoftPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF050510),
        appBar: AppBar(
          title: const Text('AIRSOFT'),
          backgroundColor: const Color(0xFF0B0B18),
          actions: [
            IconButton(
              tooltip: '팀 등록',
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const TeamCreatePage()),
                );
                if (created == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('새 팀이 팀 목록에 등록되었습니다.')),
                  );
                }
              },
              icon: const Icon(Icons.group_add_outlined),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'TEAM'), Tab(text: 'MATCH'), Tab(text: 'GUIDE')],
          ),
        ),
        body: const TabBarView(children: [_TeamList(), _MatchList(), _Guide()]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _registerMember(context),
          icon: const Icon(Icons.how_to_reg),
          label: const Text('일반회원 등록'),
        ),
      ),
    );
  }

  Future<void> _registerMember(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('airsoft_participants')
        .doc(user.uid)
        .set({
          'uid': user.uid,
          'email': user.email,
          'joinedAt': FieldValue.serverTimestamp(),
          'role': 'member',
        }, SetOptions(merge: true));

    await SocialService.instance.writeActivity(
      type: 'airsoft_member',
      title: 'Airsoft 일반 회원 참여 등록',
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('일반 회원 참여 등록이 완료되었습니다.')));
  }
}

class _TeamList extends StatelessWidget {
  const _TeamList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('airsoft_teams')
              .orderBy('createdAt', descending: true)
              .limit(50)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('팀 데이터 오류: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.groups_outlined, size: 58, color: Colors.white30),
                  const SizedBox(height: 14),
                  const Text('등록된 팀이 없습니다.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TeamCreatePage()),
                    ),
                    icon: const Icon(Icons.group_add_outlined),
                    label: const Text('첫 팀 등록하기'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children:
              snapshot.data!.docs.map((doc) {
                final data = doc.data();
                final name = (data['name'] ?? 'Airsoft Team').toString();
                final region =
                    (data['region'] ?? data['location'] ?? '').toString();
                final description = (data['description'] ?? '').toString();
                final ownerUid = (data['ownerUid'] ?? '').toString();

                return Card(
                  color: const Color(0xFF111120),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.groups_rounded),
                    ),
                    title: Text(name),
                    subtitle: Text(
                      '$region\n$description',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: FilledButton(
                      onPressed: () async {
                        await SocialService.instance.applyToTeam(
                          doc.id,
                          name,
                          ownerUid,
                        );

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('팀 참가 신청을 보냈습니다.')),
                        );
                      },
                      child: const Text('신청'),
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('airsoft_matches')
              .orderBy('startAt')
              .limit(50)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('경기 데이터 오류: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              '등록된 경기가 없습니다.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children:
              snapshot.data!.docs.map((doc) {
                final data = doc.data();
                final timestamp = data['startAt'];
                final date = timestamp is Timestamp ? timestamp.toDate() : null;
                final title = (data['title'] ?? 'Airsoft Match').toString();
                final location = (data['location'] ?? '').toString();

                final scheduleText =
                    date == null
                        ? '일정 미정'
                        : '${date.year}.${date.month}.${date.day} '
                            '${date.hour.toString().padLeft(2, '0')}:'
                            '${date.minute.toString().padLeft(2, '0')}';

                return Card(
                  color: const Color(0xFF111120),
                  child: ListTile(
                    leading: const Icon(Icons.event, color: Color(0xFFD7FF35)),
                    title: Text(title),
                    subtitle: Text('$scheduleText\n$location'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}

class _Guide extends StatelessWidget {
  const _Guide();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _GuideCard('안전장비', '보안경과 안면 보호구를 항상 착용하고 현장 규칙을 준수하세요.'),
        _GuideCard('총기 운반', '전용 가방에 넣고 탄창을 분리하여 공개 장소에서 노출하지 마세요.'),
        _GuideCard('경기 예절', '심판 판정과 히트 콜을 존중하고 근거리 사격 제한을 확인하세요.'),
        _GuideCard('법규 확인', '지역별 모의총포 관련 법규와 경기장 운영 규정을 사전에 확인하세요.'),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String title;
  final String body;

  const _GuideCard(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111120),
      child: ListTile(
        leading: const Icon(
          Icons.verified_user_outlined,
          color: Color(0xFFD7FF35),
        ),
        title: Text(title),
        subtitle: Text(body),
      ),
    );
  }
}
