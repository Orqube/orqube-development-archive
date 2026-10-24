import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/orqube_i18n.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  static const _bg = Color(0xFF03040B);
  static const _panel = Color(0xFF0A0B18);
  static const _violet = Color(0xFFB85CFF);
  static const _lime = Color(0xFFD7FF35);

  List<Map<String, String>> get _fallback => [
    {
      'category': OrqubeI18n.currentPair('공지', 'NOTICE'),
      'title': OrqubeI18n.currentPair(
        'ORQUBE V14 PART4 개발 안내',
        'ORQUBE V14 PART4 Development',
      ),
      'content': OrqubeI18n.currentPair(
        '프로필, 출석, 커뮤니티와 뉴스 기능을 단계적으로 확장하고 있습니다.',
        'Profile, attendance, community and news features are being expanded step by step.',
      ),
    },
    {
      'category': OrqubeI18n.currentPair('이벤트', 'EVENT'),
      'title': OrqubeI18n.currentPair('출석 보상 이벤트', 'Attendance Reward Event'),
      'content': OrqubeI18n.currentPair(
        '매일 출석하고 POINT와 ORBS 보상을 확인하세요.',
        'Check in every day and claim POINT and ORBS rewards.',
      ),
    },
    {
      'category': 'AIRSOFT',
      'title': 'ORQUBE Airsoft Community',
      'content': OrqubeI18n.currentPair(
        '팀 모집, 장비 정보, 게임 후기 게시판이 준비 중입니다.',
        'Team recruitment, gear information and game review boards are coming soon.',
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('orqube_news')
        .where('isActive', isEqualTo: true)
        .limit(50);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text(
          'ORQUBE NEWS',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _fallbackList(context);
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator(color: _lime));
          final docs =
              snapshot.data?.docs.toList() ??
              <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          docs.sort((a, b) {
            final at = a.data()['publishedAt'];
            final bt = b.data()['publishedAt'];
            final ad =
                at is Timestamp
                    ? at.toDate()
                    : DateTime.fromMillisecondsSinceEpoch(0);
            final bd =
                bt is Timestamp
                    ? bt.toDate()
                    : DateTime.fromMillisecondsSinceEpoch(0);
            return bd.compareTo(ad);
          });
          if (docs.isEmpty) return _fallbackList(context);
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              return _tile(context, data);
            },
          );
        },
      ),
    );
  }

  Widget _fallbackList(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: _fallback.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, i) => _tile(context, _fallback[i]),
  );

  Widget _tile(BuildContext context, Map<String, dynamic> data) {
    final category = (data['category'] ?? 'NEWS').toString();
    final title =
        (data['title'] ?? OrqubeI18n.currentPair('제목 없음', 'Untitled'))
            .toString();
    final content = (data['content'] ?? data['body'] ?? '').toString();
    final timestamp = data['publishedAt'];
    String date = '';
    if (timestamp is Timestamp) {
      final d = timestamp.toDate().toLocal();
      date =
          '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
    }
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => NewsDetailPage(
                    category: category,
                    title: title,
                    content: content,
                    date: date,
                  ),
            ),
          ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: _violet.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _violet),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: _violet,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({
    super.key,
    required this.category,
    required this.title,
    required this.content,
    required this.date,
  });
  final String category;
  final String title;
  final String content;
  final String date;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: NewsPage._bg,
    appBar: AppBar(
      backgroundColor: NewsPage._bg,
      foregroundColor: Colors.white,
      title: Text(OrqubeI18n.currentPair('뉴스 상세', 'NEWS DETAIL')),
    ),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          category,
          style: const TextStyle(
            color: NewsPage._violet,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        if (date.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(date, style: const TextStyle(color: Colors.white38)),
        ],
        const SizedBox(height: 18),
        const Divider(color: Colors.white12),
        const SizedBox(height: 18),
        Text(
          content.isEmpty
              ? OrqubeI18n.currentPair(
                '상세 내용이 등록되지 않았습니다.',
                'No details have been posted.',
              )
              : content,
          style: const TextStyle(
            color: Colors.white70,
            height: 1.7,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}
