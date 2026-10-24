import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BusinessRegistrationPage extends StatefulWidget {
  const BusinessRegistrationPage({super.key});
  @override
  State<BusinessRegistrationPage> createState() =>
      _BusinessRegistrationPageState();
}

class _BusinessRegistrationPageState extends State<BusinessRegistrationPage> {
  static const bg = Color(0xFF03040B),
      panel = Color(0xFF0B0D1B),
      lime = Color(0xFFD7FF35),
      muted = Color(0xFFAAB0C5);
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _contact = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _contact.dispose();
    _address.dispose();
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
      await FirebaseFirestore.instance.collection('airsoft_businesses').add({
        'ownerUid': u.uid,
        'ownerEmail': u.email ?? '',
        'name': _name.text.trim(),
        'category': _category.text.trim(),
        'contact': _contact.text.trim(),
        'address': _address.text.trim(),
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
        '업체 입점 등록',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('필수 정보를 입력한 뒤 등록하세요.', style: TextStyle(color: muted)),
        const SizedBox(height: 16),
        field(_name, '업체명'),
        field(_category, '업종'),
        field(_contact, '연락처'),
        field(_address, '주소'),
        field(_description, '업체 소개'),
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
