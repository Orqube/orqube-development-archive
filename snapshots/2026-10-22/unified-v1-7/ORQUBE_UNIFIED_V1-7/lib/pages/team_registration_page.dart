import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/orqube_i18n.dart';

class TeamRegistrationPage extends StatefulWidget {
  const TeamRegistrationPage({super.key});

  @override
  State<TeamRegistrationPage> createState() => _TeamRegistrationPageState();
}

class _TeamRegistrationPageState extends State<TeamRegistrationPage> {
  static const bg = Color(0xFF03040B),
      panel = Color(0xFF0B0D1B),
      lime = Color(0xFFD7FF35),
      muted = Color(0xFFAAB0C5);

  String _t(String ko, String en) => OrqubeI18n.currentPair(ko, en);

  final _name = TextEditingController();
  final _region = TextEditingController();
  final _contact = TextEditingController();
  final _description = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    _name.dispose();
    _region.dispose();
    _contact.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      msg(_t('로그인이 필요합니다.', 'Sign in required.'));
      return;
    }
    if (busy) return;
    setState(() => busy = true);
    try {
      await FirebaseFirestore.instance.collection('airsoft_teams').add({
        'ownerUid': u.uid,
        'ownerEmail': u.email ?? '',
        'name': _name.text.trim(),
        'region': _region.text.trim(),
        'contact': _contact.text.trim(),
        'description': _description.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      msg(_t('등록이 완료되었습니다.', 'Registration completed.'));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      msg('${_t('등록 실패:', 'Registration failed:')} $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void msg(String s) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
    }
  }

  Widget field(
    TextEditingController c,
    String label, {
    int maxLines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      maxLines: maxLines,
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
      title: Text(
        _t('팀 등록', 'Team Registration'),
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _t('필수 정보를 입력한 뒤 등록하세요.', 'Enter the required information, then register.'),
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 16),
        field(_name, _t('팀 이름', 'Team name'), maxLines: 1),
        field(_region, _t('활동 지역', 'Region'), maxLines: 1),
        field(_contact, _t('연락처', 'Contact'), maxLines: 1),
        field(_description, _t('팀 소개', 'Team description'), maxLines: 4),
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
            busy
                ? _t('저장 중...', 'Saving...')
                : _t('등록하기', 'Register'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}
