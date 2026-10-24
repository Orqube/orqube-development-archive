import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/moderation_service.dart';

class ChatPage extends StatefulWidget {
  final String roomId;
  final String title;
  final bool englishOnly;
  const ChatPage({super.key, required this.roomId, required this.title, this.englishOnly = false});
  @override State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  Set<String> _blocked = <String>{};

  @override void initState() { super.initState(); _loadBlocked(); }
  Future<void> _loadBlocked() async { final ids = await ModerationService.instance.blockedUserIds(); if (mounted) setState(() => _blocked = ids); }

  Future<void> _send() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _sending) return;
    final result = ModerationService.instance.inspect(_controller.text);
    if (!result.allowed) { _notice(result.reason!); return; }
    if (result.sanitized.isEmpty) return;
    if (widget.englishOnly && RegExp(r'[가-힣]').hasMatch(result.sanitized)) { _notice('Global Chat에서는 영어 메시지를 사용해 주세요.'); return; }
    setState(() => _sending = true);
    try {
      final profile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = profile.data() ?? <String, dynamic>{};
      await FirebaseFirestore.instance.collection('chat_rooms').doc(widget.roomId).collection('messages').add({
        'uid': user.uid,
        'displayName': data['nickname'] ?? user.displayName ?? 'ORQUBE User',
        'text': result.sanitized,
        'language': widget.englishOnly ? 'en' : 'ko',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    } finally { if (mounted) setState(() => _sending = false); }
  }

  void _notice(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _actions(String messageId, String uid) async {
    await showModalBottomSheet(context: context, backgroundColor: const Color(0xFF121222), builder: (ctx) => SafeArea(child: Wrap(children: [
      ListTile(leading: const Icon(Icons.flag_outlined, color: Colors.orangeAccent), title: const Text('신고'), onTap: () async { Navigator.pop(ctx); await ModerationService.instance.report(targetType: 'chat', targetId: messageId, targetUid: uid, reason: '사용자 신고'); _notice('신고가 접수되었습니다.'); }),
      if (uid != FirebaseAuth.instance.currentUser?.uid) ListTile(leading: const Icon(Icons.block, color: Colors.redAccent), title: const Text('사용자 차단'), onTap: () async { Navigator.pop(ctx); await ModerationService.instance.blockUser(uid); await _loadBlocked(); _notice('사용자를 차단했습니다.'); }),
    ])));
  }

  @override Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection('chat_rooms').doc(widget.roomId).collection('messages').orderBy('createdAt', descending: true).limit(100);
    return Scaffold(backgroundColor: const Color(0xFF050510), appBar: AppBar(title: Text(widget.title), backgroundColor: const Color(0xFF0B0B18)), body: SafeArea(child: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(10), color: const Color(0xFF17142A), child: Text(widget.englishOnly ? 'English only · Community safety filter enabled' : '국내 채팅 · 커뮤니티 안전 필터 적용', style: const TextStyle(color: Colors.white70, fontSize: 12))),
      Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: query.snapshots(), builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('채팅을 불러오지 못했습니다.\n${snap.error}', textAlign: TextAlign.center));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs.where((d) => !_blocked.contains(d.data()['uid'])).toList();
        if (docs.isEmpty) return const Center(child: Text('첫 메시지를 남겨보세요.', style: TextStyle(color: Colors.white54)));
        return ListView.builder(reverse: true, controller: _scrollController, padding: const EdgeInsets.all(12), itemCount: docs.length, itemBuilder: (context, i) {
          final doc=docs[i]; final d=doc.data(); final mine=d['uid']==FirebaseAuth.instance.currentUser?.uid;
          return Align(alignment: mine?Alignment.centerRight:Alignment.centerLeft, child: GestureDetector(onLongPress: () => _actions(doc.id, d['uid'] ?? ''), child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(11), constraints: const BoxConstraints(maxWidth: 310), decoration: BoxDecoration(color: mine?const Color(0xFF6D28D9):const Color(0xFF17172A), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d['displayName'] ?? 'User', style: const TextStyle(color: Color(0xFFD7FF35), fontSize: 11, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(d['text'] ?? '', style: const TextStyle(color: Colors.white))]))));
        });
      })),
      Padding(padding: const EdgeInsets.all(10), child: Row(children: [Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 4, decoration: InputDecoration(hintText: widget.englishOnly?'Write a message in English':'메시지 입력', filled: true, fillColor: const Color(0xFF111120), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)))), const SizedBox(width: 8), IconButton.filled(onPressed: _sending?null:_send, icon: _sending?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.send_rounded))]))
    ])));
  }
}
