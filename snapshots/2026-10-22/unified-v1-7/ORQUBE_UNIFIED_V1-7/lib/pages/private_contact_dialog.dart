import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../web_link.dart';
import 'login_page.dart';

Future<void> showPrivateContact(BuildContext context) => showDialog<void>(
  context: context, barrierDismissible: false,
  builder: (_) => const _ContactDialog());

class _ContactDialog extends StatefulWidget {
  const _ContactDialog();
  @override State<_ContactDialog> createState() => _ContactDialogState();
}
class _ContactDialogState extends State<_ContactDialog> {
  final subject = TextEditingController();
  final message = TextEditingController();
  bool busy = false, consent = false;
  String feedback = '';
  @override void dispose() { subject.dispose(); message.dispose(); super.dispose(); }
  Future<void> send() async {
    final user = FirebaseAuth.instance.currentUser;
    if (busy || user == null || !user.emailVerified || !consent) return;
    if (subject.text.trim().isEmpty || message.text.trim().isEmpty) {
      setState(() => feedback = '제목과 문의 내용을 입력해 주세요.'); return;
    }
    setState(() { busy = true; feedback = ''; });
    try {
      await FirebaseFirestore.instance.collection('private_inquiries').add({
        'uid': user.uid, 'email': user.email ?? '',
        'subject': subject.text.trim(), 'message': message.text.trim(),
        'status': 'received', 'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 15));
      if (mounted) setState(() { subject.clear(); message.clear(); consent = false; feedback = '문의가 비공개로 접수되었습니다. 답변은 가입 이메일로 안내할 수 있습니다.'; });
    } catch (_) {
      if (mounted) setState(() => feedback = '접수를 확인하지 못했습니다. 내 문의 내역을 확인한 뒤 다시 시도하거나 이메일로 문의해 주세요.');
    } finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> inbox() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final token = await user.getIdTokenResult();
      if (!mounted) return;
      final admin = token.claims?['admin'] == true && user.emailVerified;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => _InquiryInbox(admin: admin, uid: user.uid)));
    } catch (_) { if (mounted) setState(() => feedback = '문의 내역을 열지 못했습니다. 로그인 상태를 확인해 주세요.'); }
  }
  @override Widget build(BuildContext context) => AlertDialog(
    title: const Text('CONTACT · 비공개 문의'),
    content: SizedBox(width: 580, child: SingleChildScrollView(child: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = FirebaseAuth.instance.currentUser;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          const Text('여러분의 의견에 귀 기울이겠습니다. 서비스 이용 중 불편이나 제휴 제안을 남겨 주세요. 확인 후 필요한 안내를 드리겠습니다.', style: TextStyle(height: 1.6)),
          TextButton(onPressed: () => openExternalUrl('mailto:koreapadosori@gmail.com'), child: const Text('koreapadosori@gmail.com')),
          TextButton(onPressed: () => openExternalUrl('tel:0322331222'), child: const Text('Tel:032-233-1222')),
          const ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('투자 · 기술 · 사업 협업 안내'),
            children: [Padding(padding: EdgeInsets.only(bottom: 16), child: Text(
              'ORQUBE는 AI 토큰 생성, 안전산행·안심귀가, AIRSOFT 커뮤니티와 글로벌 보상 생태계를 함께 발전시킬 투자자와 파트너를 찾습니다. 제휴 검토는 사업 목적, 법규 준수, 사용자 안전, 기술 기여와 장기 협업 가능성을 기준으로 진행합니다. 아래 문의 양식으로 제안해 주세요.',
              style: TextStyle(height: 1.6))),],
          ),
          const Text('문의는 공개 게시판에 표시되지 않으며 작성자와 관리자만 확인할 수 있습니다. 비밀번호·지갑 개인키·복구문구는 요청하지 않습니다.', style: TextStyle(height: 1.6)),
          const SizedBox(height: 12),
          if (user == null) FilledButton(onPressed: busy ? null : () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(onLoginSuccess: () async { Navigator.of(context).pop(); })));
            if (mounted) setState(() {});
          }, child: const Text('로그인 후 비공개 문의 작성')),
          if (user != null && !user.emailVerified) const Text('이메일 인증 완료 후 문의를 접수할 수 있습니다. 계정 화면에서 인증 상태를 확인해 주세요.'),
          if (user != null && user.emailVerified) ...[
            Text('회신 이메일: ${user.email ?? ''}'),
            const SizedBox(height: 12),
            TextField(controller: subject, enabled: !busy, maxLength: 120, decoration: const InputDecoration(labelText: '문의 제목', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: message, enabled: !busy, minLines: 5, maxLines: 10, maxLength: 5000, decoration: const InputDecoration(labelText: '문의 내용 (비공개)', border: OutlineInputBorder())),
            CheckboxListTile(contentPadding: EdgeInsets.zero, value: consent, onChanged: busy ? null : (v) => setState(() => consent = v ?? false), title: const Text('문의 처리·회신을 위해 계정 ID, 이메일, 제목, 내용, 접수 시각을 저장하는 데 동의합니다. 내 문의 내역에서 삭제할 수 있습니다.')),
            FilledButton(onPressed: busy || !consent ? null : send, child: Text(busy ? '접수 중…' : '비공개 문의 접수')),
            TextButton(onPressed: busy ? null : inbox, child: const Text('내 문의 내역 / 관리자 문의함')),
          ],
          if (feedback.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(feedback)),
        ]);
      },
    ))),
    actions: [TextButton(onPressed: busy ? null : () => Navigator.pop(context), child: const Text('닫기'))],
  );
}
class _InquiryInbox extends StatelessWidget {
  final bool admin;
  final String uid;
  const _InquiryInbox({required this.admin, required this.uid});
  @override Widget build(BuildContext context) {
    final Query<Map<String,dynamic>> query = admin
      ? FirebaseFirestore.instance.collection('private_inquiries').orderBy('createdAt', descending: true).limit(100)
      : FirebaseFirestore.instance.collection('private_inquiries').where('uid', isEqualTo: uid);
    return Scaffold(appBar: AppBar(title: Text(admin ? '관리자 · 비공개 문의함 (최근 100건)' : '내 비공개 문의')),
      body: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream: query.snapshots(), builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('문의를 읽지 못했습니다. 로그인·권한·인터넷 연결을 확인하세요.'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final rows = snapshot.data!.docs.toList()..sort((a,b) => ((b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0).compareTo((a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0));
        if (rows.isEmpty) return const Center(child: Text('접수된 문의가 없습니다.'));
        return ListView(padding: const EdgeInsets.all(16), children: [for (final row in rows) Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${row.data()['subject']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SelectableText('${row.data()['email']}'),
          Text((row.data()['createdAt'] as Timestamp?)?.toDate().toLocal().toString() ?? '저장 확인 중'),
          const SizedBox(height: 12), SelectableText('${row.data()['message']}'),
          TextButton(onPressed: () async {
            final yes = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('문의 삭제'), content: const Text('문의 내용을 삭제하시겠습니까?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('취소')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('삭제'))]));
            if (yes != true) return;
            try { await row.reference.delete(); } catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제하지 못했습니다. 다시 시도해 주세요.'))); }
          }, child: const Text('문의 삭제')),
        ]))) ]);
      }));
  }
}
