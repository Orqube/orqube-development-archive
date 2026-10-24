import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> showEmailVerificationDialog(BuildContext context) async {
  await showDialog<void>(context: context, builder: (_) => const _VerificationDialog());
}
class _VerificationDialog extends StatefulWidget {
  const _VerificationDialog();
  @override State<_VerificationDialog> createState() => _VerificationDialogState();
}
class _VerificationDialogState extends State<_VerificationDialog> {
  bool busy = false;
  String message = '메일함에서 인증 링크를 누른 뒤 인증 확인을 선택하세요.';
  Future<void> run(bool send) async {
    setState(() => busy = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) throw Exception('이메일 계정으로 로그인해 주세요.');
      if (send) {
        await user.sendEmailVerification();
        if (mounted) setState(() => message = '인증 메일을 보냈습니다. 스팸함도 확인해 주세요.');
      } else {
        await user.reload();
        final current = FirebaseAuth.instance.currentUser;
        if (current != null && current.uid == user.uid && current.emailVerified) {
          await current.getIdToken(true);
          if (mounted) Navigator.pop(context);
        } else if (mounted) { setState(() => message = '아직 이메일 인증이 확인되지 않았습니다.'); }
      }
    } catch (e) { if (mounted) setState(() => message = '$e'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override Widget build(BuildContext context) => AlertDialog(
    title: const Text('이메일 인증'),
    content: Text('${FirebaseAuth.instance.currentUser?.email ?? ''}\n$message'),
    actions: [
      TextButton(onPressed: busy ? null : () => Navigator.pop(context), child: const Text('나중에')),
      TextButton(onPressed: busy ? null : () => run(true), child: const Text('인증 메일 보내기')),
      FilledButton(onPressed: busy ? null : () => run(false), child: Text(busy ? '확인 중…' : '인증 확인')),
    ]);
}
