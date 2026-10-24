import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../web_link.dart';

/// 공개 게시판. 로그인 없이 열람하며 동영상은 YouTube에서 재생합니다.
class PublicVideoBoard extends StatelessWidget {
  const PublicVideoBoard({super.key, required this.language});
  final String language;

  static String? videoId(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'https') return null;
    final host = uri.host.toLowerCase();
    String? id;
    if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      id = uri.pathSegments.first;
    } else if (host == 'youtube.com' || host == 'www.youtube.com' ||
        host == 'm.youtube.com') {
      if (uri.path == '/watch') id = uri.queryParameters['v'];
      if (uri.pathSegments.length == 2 &&
          ['shorts', 'embed', 'live'].contains(uri.pathSegments.first)) {
        id = uri.pathSegments.last;
      }
    }
    return id != null && RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id)
        ? id : null;
  }

  @override
  Widget build(BuildContext context) {
    final ko = language == 'ko';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xF00C1020),
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ko ? '영상 게시판' : 'Video Board',
                style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(ko ? '게시물을 누르면 YouTube에서 영상을 볼 수 있습니다.'
                  : 'Select a post to watch on YouTube.',
                style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('video_posts')
                    .where('published', isEqualTo: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(ko ? '영상 게시판을 불러오지 못했습니다.' : 'Unable to load videos.',
                    style: const TextStyle(color: Colors.white70));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs.toList()..sort((a, b) {
                    final x = a.data()['createdAt']; final y = b.data()['createdAt'];
                    return (y is Timestamp ? y.millisecondsSinceEpoch : 0)
                        .compareTo(x is Timestamp ? x.millisecondsSinceEpoch : 0);
                  });
                  if (docs.isEmpty) return Text(ko ? '등록된 공개 영상이 없습니다.' : 'No public videos yet.',
                    style: const TextStyle(color: Colors.white70));
                  return Column(children: [for (final doc in docs) _post(context, {
                    'title': doc.data()['title'] as String? ?? '',
                    'description': doc.data()['description'] as String? ?? '',
                    'url': doc.data()['url'] as String? ?? '',
                  }, ko)]);
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _post(BuildContext context, Map<String, String> post, bool ko) {
    final id = videoId(post['url']!);
    final ready = id != null;
    final compact = MediaQuery.sizeOf(context).width < 420;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFF161C30),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: ready ? () => openExternalUrl('https://www.youtube.com/watch?v=$id') : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              SizedBox(
                width: compact ? 80 : 140,
                height: compact ? 52 : 80,
                child: ready ? Image.network('https://img.youtube.com/vi/$id/hqdefault.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.play_circle_fill, color: Colors.white, size: 38))
                  : const Icon(Icons.video_library_outlined, color: Colors.white54, size: 38),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(post['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(post['description']!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Text(ready ? (ko ? '▶ YouTube에서 보기' : '▶ Watch on YouTube')
                    : (ko ? '업로드 준비 중' : 'Upload pending'),
                  style: TextStyle(color: ready ? Colors.lightBlueAccent : Colors.white54, fontSize: 12)),
              ])),
            ]),
          ),
        ),
      ),
    );
  }
}
