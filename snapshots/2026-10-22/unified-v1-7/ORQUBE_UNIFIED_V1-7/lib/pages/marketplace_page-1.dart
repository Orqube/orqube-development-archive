import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});
  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  static const bg = Color(0xFF03040B),
      panel = Color(0xFF0B0D1B),
      lime = Color(0xFFD7FF35),
      muted = Color(0xFFAAB0C5);
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _contact = TextEditingController();
  final _description = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _contact.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      msg('로그인이 필요합니다.');
      return;
    }
    if (busy) return;
    setState(() => busy = true);
    try {
      await FirebaseFirestore.instance.collection('airsoft_market_posts').add({
        'ownerUid': u.uid,
        'ownerEmail': u.email ?? '',
        'title': _title.text.trim(),
        'price': _price.text.trim(),
        'contact': _contact.text.trim(),
        'description': _description.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      msg('등록이 완료되었습니다.');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      msg('등록 실패: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void msg(String s) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }

  Widget field(TextEditingController c, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      maxLines: label.contains('소개') || label.contains('설명') ? 4 : 1,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: muted),
        filled: true,
        fillColor: panel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white12),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bg,
    appBar: AppBar(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      title: const Text(
        '마켓 판매글 등록',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('필수 정보를 입력한 뒤 등록하세요.', style: TextStyle(color: muted)),
        const SizedBox(height: 16),
        field(_title, '상품명'),
        field(_price, '가격'),
        field(_contact, '연락처'),
        field(_description, '상품 설명'),
        const SizedBox(height: 6),
        FilledButton.icon(
          onPressed: busy ? null : save,
          style: FilledButton.styleFrom(
            backgroundColor: lime,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(16),
          ),
          icon: const Icon(Icons.save_rounded),
          label: Text(
            busy ? '저장 중...' : '등록하기',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}
