import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'wallet_setup_page.dart';

class LoginPage extends StatefulWidget {
  final String language;
  const LoginPage({super.key, required this.language});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final auth = AuthService();
  bool loading = false;

  void msg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  Future<void> run(Future Function() job) async { try { setState(()=>loading=true); await job(); } catch(e){ msg('오류: $e'); } finally { if(mounted) setState(()=>loading=false); } }
  void goNext() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WalletSetupPage(language: widget.language)));

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bgLight,
    appBar: AppBar(title: const Text('ORQUBE Login')),
    body: Center(child: Container(width: 460, padding: const EdgeInsets.all(26), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.security, color: AppColors.purple, size: 70),
      const SizedBox(height: 12),
      const Text('ORQUBE 회원가입 / 로그인', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
      const SizedBox(height: 20),
      TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      if(loading) const CircularProgressIndicator() else Row(children: [
        Expanded(child: ElevatedButton(onPressed: ()=>run(() async { await auth.emailSignUp(email.text, password.text); goNext(); }), child: const Text('이메일 가입'))),
        const SizedBox(width: 8),
        Expanded(child: ElevatedButton(onPressed: ()=>run(() async { await auth.emailLogin(email.text, password.text); goNext(); }), child: const Text('이메일 로그인'))),
      ]),
      const SizedBox(height: 12),
      ElevatedButton.icon(onPressed: ()=>run(() async { final p = await auth.googleLogin(); if(p != null) goNext(); }), icon: const Icon(Icons.g_mobiledata), label: const Text('구글 계정으로 계속하기')),
      const SizedBox(height: 8),
      OutlinedButton(onPressed: goNext, child: const Text('테스트용 바로 입장')),
    ])),
  );
}
