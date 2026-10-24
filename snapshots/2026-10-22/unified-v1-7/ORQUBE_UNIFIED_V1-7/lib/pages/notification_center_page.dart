import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        title: const Text('NOTIFICATION CENTER'),
        backgroundColor: const Color(0xFF0B0B18),
        actions: [
          if (uid != null)
            TextButton(
              onPressed: () async {
                final snap = await FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications').where('read', isEqualTo: false).get();
                final batch = FirebaseFirestore.instance.batch();
                for (final doc in snap.docs) { batch.update(doc.reference, {'read': true}); }
                await batch.commit();
              },
              child: const Text('모두 읽음'),
            ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications').orderBy('createdAt', descending: true).limit(100).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('알림 오류: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('새 알림이 없습니다.', style: TextStyle(color: Colors.white54)));
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index]; final d = doc.data(); final read = d['read'] == true;
                    return Card(
                      color: read ? const Color(0xFF10101D) : const Color(0xFF191532),
                      child: ListTile(
                        leading: Icon(_icon((d['type'] ?? '').toString()), color: read ? Colors.white54 : const Color(0xFFD7FF35)),
                        title: Text((d['title'] ?? '알림').toString(), style: TextStyle(fontWeight: read ? FontWeight.w500 : FontWeight.w800)),
                        subtitle: Text((d['body'] ?? '').toString()),
                        trailing: read ? null : const CircleAvatar(radius: 4, backgroundColor: Color(0xFFD7FF35)),
                        onTap: () => doc.reference.update({'read': true}),
                        onLongPress: () => doc.reference.delete(),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'follow': return Icons.person_add_alt_1;
      case 'friend_request': return Icons.group_add;
      case 'team_application': return Icons.sports_mma;
      case 'comment': return Icons.chat_bubble_outline;
      case 'badge': return Icons.military_tech;
      default: return Icons.notifications_active_outlined;
    }
  }
}
