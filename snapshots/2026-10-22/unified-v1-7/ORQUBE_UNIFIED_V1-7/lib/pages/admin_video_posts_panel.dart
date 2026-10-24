import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/public_video_board.dart';

/// Embedded in the role-checked administrator dashboard; rules enforce writes.
class AdminVideoPostsPanel extends StatefulWidget {
  const AdminVideoPostsPanel({super.key});
  @override
  State<AdminVideoPostsPanel> createState() => _AdminVideoPostsPanelState();
}

class _AdminVideoPostsPanelState extends State<AdminVideoPostsPanel> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _url = TextEditingController();
  final _description = TextEditingController();
  final _posts = FirebaseFirestore.instance.collection('video_posts');
  String? _editingId;
  bool _published = false;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose(); _url.dispose(); _description.dispose();
    super.dispose();
  }

  void _message(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _reset() {
    _title.clear(); _url.clear(); _description.clear();
    setState(() { _editingId = null; _published = false; });
    _form.currentState?.reset();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final id = PublicVideoBoard.videoId(_url.text)!;
      final data = <String, dynamic>{
        'title': _title.text.trim(), 'description': _description.text.trim(),
        'url': 'https://www.youtube.com/watch?v=$id',
        'published': _published, 'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser!.uid,
      };
      if (_editingId == null) {
        await _posts.add({...data, 'createdAt': FieldValue.serverTimestamp()});
      } else {
        await _posts.doc(_editingId).update(data);
      }
      if (!mounted) return;
      _reset(); _message('영상 게시물이 저장되었습니다.');
    } catch (e) { _message('저장 실패: $e'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _delete(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('영상 게시물 삭제'),
      content: Text('「${doc.data()['title']}」 게시물을 삭제할까요? YouTube 원본 영상은 유지됩니다.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제'))],
    ));
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await doc.reference.delete();
      if (!mounted) return;
      if (_editingId == doc.id) _reset();
      _message('삭제되었습니다.');
    } catch (e) { _message('삭제 실패: $e'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('영상 게시 관리', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('먼저 YouTube에 영상을 업로드한 뒤 링크를 등록하세요. 공개 설정한 게시물만 홈페이지에 표시됩니다.'),
    const SizedBox(height: 16),
    Form(key: _form, child: Column(children: [
      TextFormField(controller: _title, enabled: !_busy, maxLength: 160,
        decoration: const InputDecoration(labelText: '제목'),
        validator: (v) => (v ?? '').trim().isEmpty ? '제목을 입력하세요.' : null),
      TextFormField(controller: _url, enabled: !_busy, maxLength: 2048,
        decoration: const InputDecoration(labelText: 'YouTube 링크 (https://...)'),
        validator: (v) => PublicVideoBoard.videoId(v ?? '') == null ? '올바른 YouTube 영상 링크를 입력하세요.' : null),
      TextFormField(controller: _description, enabled: !_busy, maxLength: 3000, minLines: 2, maxLines: 5,
        decoration: const InputDecoration(labelText: '설명')),
      SwitchListTile(title: const Text('공개'), subtitle: const Text('끄면 관리자만 볼 수 있습니다.'),
        value: _published, onChanged: _busy ? null : (v) => setState(() => _published = v)),
      Wrap(spacing: 12, children: [
        FilledButton.icon(onPressed: _busy ? null : _save, icon: const Icon(Icons.save),
          label: Text(_busy ? '처리 중…' : _editingId == null ? 'YouTube 링크 등록' : '수정 저장')),
        TextButton(onPressed: _busy ? null : _reset, child: const Text('새 게시물 / 수정 취소')),
      ]),
    ])),
    const Divider(height: 32),
    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _posts.snapshots(), builder: (context, snapshot) {
      if (snapshot.hasError) return const Text('게시물을 불러오지 못했습니다. 관리자 권한과 Firestore 규칙 배포를 확인하세요.');
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snapshot.data!.docs.toList()..sort((a, b) {
        final x = a.data()['createdAt']; final y = b.data()['createdAt'];
        return (y is Timestamp ? y.millisecondsSinceEpoch : 0).compareTo(x is Timestamp ? x.millisecondsSinceEpoch : 0);
      });
      if (docs.isEmpty) return const Text('등록된 영상이 없습니다.');
      return Column(children: [for (final doc in docs) Card(child: Padding(
        padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(doc.data()['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(doc.data()['published'] == true ? '공개' : '비공개'),
          Text(doc.data()['url'] as String? ?? ''),
          Wrap(spacing: 8, children: [
            TextButton.icon(onPressed: _busy ? null : () {
              final data = doc.data();
              setState(() {
                _editingId = doc.id; _title.text = data['title'] as String? ?? '';
                _url.text = data['url'] as String? ?? ''; _description.text = data['description'] as String? ?? '';
                _published = data['published'] == true;
              });
            }, icon: const Icon(Icons.edit), label: const Text('수정')),
            TextButton.icon(onPressed: _busy ? null : () => _delete(doc),
              icon: const Icon(Icons.delete_outline), label: const Text('삭제')),
          ]),
        ]),
      ))]);
    }),
  ]);
}
