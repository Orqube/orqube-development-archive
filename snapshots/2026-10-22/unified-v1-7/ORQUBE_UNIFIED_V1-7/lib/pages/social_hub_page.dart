import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/social_service.dart';

class SocialHubPage extends StatelessWidget {
  const SocialHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF050510),
        appBar: AppBar(
          title: const Text('ORQUBE SOCIAL'),
          backgroundColor: const Color(0xFF0B0B18),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'FEED'),
              Tab(text: 'PEOPLE'),
              Tab(text: 'REQUESTS'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ActivityFeed(), _People(), _FriendRequests()],
        ),
      ),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('activities')
              .orderBy('createdAt', descending: true)
              .limit(100)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '활동 피드 오류: ${snapshot.error}',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              '표시할 활동이 없습니다.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children:
              docs.map((doc) {
                final data = doc.data();
                final displayName =
                    (data['displayName'] ?? 'ORQUBE User').toString();
                final title = (data['title'] ?? '').toString();
                final description = (data['description'] ?? '').toString();

                return Card(
                  color: const Color(0xFF111120),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.bolt)),
                    title: Text(
                      displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '$title\n$description',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    isThreeLine: true,
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}

class _People extends StatelessWidget {
  const _People();

  String _initial(dynamic value) {
    final text = (value ?? 'O').toString().trim();
    return text.isEmpty ? 'O' : text.substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('users').limit(100).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '회원 오류: ${snapshot.error}',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs =
            snapshot.data!.docs
                .where((document) => document.id != myUid)
                .toList();

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              '표시할 회원이 없습니다.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children:
              docs.map((doc) {
                final data = doc.data();
                final nickname =
                    (data['nickname'] ?? data['email'] ?? 'ORQUBE User')
                        .toString();
                final rank = (data['rank'] ?? 'MEMBER').toString();

                return Card(
                  color: const Color(0xFF111120),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(_initial(data['nickname'])),
                    ),
                    title: Text(
                      nickname,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      rank,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        try {
                          if (value == 'follow') {
                            await SocialService.instance.follow(doc.id);
                          } else if (value == 'friend') {
                            await SocialService.instance.sendFriendRequest(
                              doc.id,
                            );
                          }

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('요청을 전송했습니다.')),
                          );
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('요청 실패: $error')),
                          );
                        }
                      },
                      itemBuilder:
                          (_) => const [
                            PopupMenuItem<String>(
                              value: 'follow',
                              child: Text('팔로우'),
                            ),
                            PopupMenuItem<String>(
                              value: 'friend',
                              child: Text('친구 요청'),
                            ),
                          ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}

class _FriendRequests extends StatelessWidget {
  const _FriendRequests();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Text('로그인이 필요합니다.', style: TextStyle(color: Colors.white70)),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('friend_requests')
              .where('toUid', isEqualTo: uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              '친구 요청 오류: ${snapshot.error}',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final pending =
            snapshot.data!.docs
                .where((document) => document.data()['status'] == 'pending')
                .toList();

        if (pending.isEmpty) {
          return const Center(
            child: Text(
              '대기 중인 친구 요청이 없습니다.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children:
              pending.map((doc) {
                final data = doc.data();
                final fromUid = (data['fromUid'] ?? '').toString();

                return Card(
                  color: const Color(0xFF111120),
                  child: ListTile(
                    title: const Text(
                      '친구 요청',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '사용자 ID: $fromUid',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Wrap(
                      spacing: 2,
                      children: [
                        IconButton(
                          tooltip: '수락',
                          onPressed: () async {
                            await SocialService.instance.respondFriendRequest(
                              doc.reference,
                              true,
                            );
                          },
                          icon: const Icon(
                            Icons.check,
                            color: Colors.greenAccent,
                          ),
                        ),
                        IconButton(
                          tooltip: '거절',
                          onPressed: () async {
                            await SocialService.instance.respondFriendRequest(
                              doc.reference,
                              false,
                            );
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
