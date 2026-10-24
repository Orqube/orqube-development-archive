import '../services/hiking_search_record.dart';
import 'orqube_domain_button.dart';
import '../utils/app_language.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class HikingAccountPage extends StatefulWidget {
  final Future<void> Function()? onClearLocal;
  HikingAccountPage({super.key, this.onClearLocal});
  @override State<HikingAccountPage> createState() => _HikingAccountPageState();
}
class _HikingAccountPageState extends State<HikingAccountPage> with LanguageAware<HikingAccountPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  bool consent = false;
  bool hidePassword = true;
  bool creating = false;
  final formKey = GlobalKey<FormState>();
  String message = '';
  Future<void> act(Future<String> Function() action) async {
    setState(() { busy = true; message = ''; });
    try { final result = await action(); if (mounted) setState(() => message = result); }
    on FirebaseAuthException catch (e) {
      if (mounted) setState(() => message = switch(e.code) {
        'invalid-email' => '이메일 형식을 확인하세요.',
        'weak-password' => '더 강한 비밀번호를 사용하세요.',
        'email-already-in-use' => '이미 가입된 이메일입니다. 로그인 또는 비밀번호 재설정을 이용하세요.',
        'too-many-requests' => '시도가 너무 많습니다. 잠시 후 다시 시도하세요.',
        'network-request-failed' => '인터넷 연결을 확인하세요.',
        _ => AppLanguage.f('처리하지 못했습니다. 이메일·비밀번호와 인증 상태를 확인하세요. ({code})', {'code': e.code}),
      });
    } catch (_) { if (mounted) setState(() => message = '처리하지 못했습니다. 인터넷 연결과 서버 접근 권한을 확인하세요. 삭제 실패 시 계정은 유지됩니다.'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<bool> confirm(String title, String body) async => await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: AppText(title), content: AppText(body), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: AppText('취소')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: AppText('확인'))])) ?? false;
  Future<void> erase(User user) async {
    await HikingSearchRecord.eraseLocal(user.uid);
    final db = FirebaseFirestore.instance;
    final requests = await db.collection('safety_requests').doc(user.uid).collection('viewers').get(GetOptions(source: Source.server));
    for (final request in requests.docs) { await request.reference.delete(); }
    // 서버 읽기로 연결을 확인한 뒤 삭제합니다. 실패하면 탈퇴로 진행하지 않습니다.
    for (final collection in ['hiking_sessions', 'safe_home_sessions', 'airsoft_live_locations', 'safety_shares']) {
      await db.collection(collection).doc(user.uid).get(GetOptions(source: Source.server));
      await db.collection(collection).doc(user.uid).delete();
    }
    while (true) {
      final rows = await db.collection('airsoft_sos').where('uid', isEqualTo: user.uid).limit(200).get(GetOptions(source: Source.server));
      if (rows.docs.isEmpty) break;
      final batch = db.batch();
      for (final row in rows.docs) { batch.delete(row.reference); }
      await batch.commit();
    }
    await db.collection('users').doc(user.uid).update({'safeHikingGuardian': FieldValue.delete()}).catchError((Object e) {
      if (e is FirebaseException && e.code == 'not-found') return;
      throw e;
    });
    await widget.onClearLocal?.call();
  }
  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  static const forest = Color(0xFF165442);
  static const ink = Color(0xFF172D27);
  static const muted = Color(0xFF61736B);

  Future<String> syncMember() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return '로그인이 필요합니다.';
    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final doc = await tx.get(ref);
        if (!doc.exists) {
          tx.set(ref, {'uid': user.uid, 'displayName': user.displayName ?? '오르큐브 회원',
            'createdAt': FieldValue.serverTimestamp(), 'signupSource': 'safe_companion',
            'companionLastSeenAt': FieldValue.serverTimestamp()});
        } else {
          tx.update(ref, {'companionLastSeenAt': FieldValue.serverTimestamp()});
        }
      }).timeout(Duration(seconds: 8));
      return '';
    } catch (_) {
      return '';
    }
  }
  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;
    if (creating && !consent) {
      setState(() => message = '회원가입 전에 개인정보 처리 안내 확인에 동의해주세요.');
      return;
    }
    await act(() async {
      if (creating) {
        final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(), password: password.text);
        password.clear();
        await syncMember();
        try { await result.user!.sendEmailVerification(); } catch (_) { return '계정은 생성되었습니다. 인증 메일 다시 보내기를 눌러주세요.'; }
        return '가입했습니다. 이메일의 인증 링크를 누른 뒤 인증 상태를 새로고침해주세요.';
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(), password: password.text);
      password.clear();
      await syncMember();
      return '로그인되었습니다.';
    });
  }

  @override
  Widget build(BuildContext context) => Theme(
    // Complete light theme: the parent hiking map's dark theme must not control this form.
    data: ThemeData(fontFamily: 'OrqubeHangul', 
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Color(0xFFF2F6F3),
      colorScheme: ColorScheme.fromSeed(seedColor: forest, brightness: Brightness.light),
      appBarTheme: AppBarTheme(backgroundColor: Color(0xFFF2F6F3), foregroundColor: ink, surfaceTintColor: Colors.transparent, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Color(0xFFF7F9F7),
        labelStyle: TextStyle(color: muted), hintStyle: TextStyle(color: muted),
        prefixIconColor: forest, suffixIconColor: muted,
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Color(0xFFDDE6E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: forest, width: 2)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: forest, foregroundColor: Colors.white,
        disabledBackgroundColor: Color(0xFFDCE5DF), disabledForegroundColor: Color(0xFF52665B),
        minimumSize: Size(double.infinity, 56),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        foregroundColor: forest, minimumSize: Size(double.infinity, 52),
        side: BorderSide(color: Color(0xFFCAD9CF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: forest)),
    ),
    child: Builder(builder: (localContext) => Scaffold(
      appBar: AppBar(actions: [OrqubeDomainButton(), LanguageButton()], title: AppText('안심동행 · 로그인 / 계정', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
      body: StreamBuilder<User?>(stream: FirebaseAuth.instance.userChanges(), builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        return LayoutBuilder(builder: (context, bounds) {
          final wide = bounds.maxWidth >= 900;
          final compact = bounds.maxWidth < 420;
          final card = Container(
            padding: EdgeInsets.all(compact ? 20 : 32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Color(0xFFE2EAE4)),
              boxShadow: [BoxShadow(color: Color(0x0B16382A), blurRadius: 28, offset: Offset(0, 10))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (user == null) ...loginForm(context) else ...accountPanel(context, user),
              if (busy) Padding(padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator()),
              if (message.isNotEmpty) Container(
                margin: EdgeInsets.only(top: 16), padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Color(0xFFEDF4EF), borderRadius: BorderRadius.circular(12)),
                child: Semantics(liveRegion: true, child: AppText(message, style: TextStyle(color: ink, height: 1.6)))),
            ]),
          );
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 28, vertical: wide ? 48 : 20),
            child: Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 1100),
              child: Column(children: [
                if (wide) Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 5, child: hero(user, large: true)), SizedBox(width: 28), Expanded(flex: 6, child: card),
                ]) else ...[hero(user, large: false), SizedBox(height: 20), card],
                SizedBox(height: 24),
                AppText('ORQUBE SAFE COMPANION · V2.1', style: TextStyle(color: muted, fontSize: 11, letterSpacing: 1)),
                SizedBox(height: 12),
              ]))),
          );
        });
      }),
    )),
  );

  Widget hero(User? user, {required bool large}) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF163F32), Color(0xFF092A25)])),
    child: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _MountainPainter())),
      Padding(padding: EdgeInsets.all(large ? 32 : 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.landscape_rounded, color: Color(0xFFC0E2CC), size: 28), SizedBox(width: 10),
          Flexible(child: AppText('ORQUBE / SAFE COMPANION', style: TextStyle(color: Color(0xFFDBECE0), fontSize: 12, letterSpacing: 1.6, fontWeight: FontWeight.w600)))]),
        SizedBox(height: large ? 52 : 24),
        AppText(user == null ? '산에서도, 귀갓길에서도\n마음 편히 함께하세요.' : '오늘도 안전하게,\n소중한 사람과 함께.',
          style: TextStyle(color: Colors.white, fontSize: large ? 35 : 28, height: 1.35, fontWeight: FontWeight.w800, letterSpacing: -.8)),
        SizedBox(height: 16),
        AppText('한 걸음의 설렘부터\n집으로 돌아오는 순간까지.', style: TextStyle(color: Color(0xFFD2E5D9), fontSize: 15, height: 1.7)),
        SizedBox(height: large ? 100 : 48),
        Wrap(spacing: 8, runSpacing: 8, children: [heroTag(Icons.landscape_outlined, '안전산행'), heroTag(Icons.nightlight_round, '안심귀가'), heroTag(Icons.location_on_outlined, '위치 공유'), heroTag(Icons.health_and_safety_outlined, 'SOS')]),
      ])),
    ]),
  );

  Widget heroTag(IconData icon, String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(color: Color(0xE6224D3C), borderRadius: BorderRadius.circular(10), border: Border.all(color: Color(0xFF5C8069))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: Color(0xFFDDEBE1)), SizedBox(width: 6), AppText(label, style: TextStyle(color: Colors.white, fontSize: 12))]),
  );

  List<Widget> loginForm(BuildContext context) => [
    AppText('나의 안심동행 계정', style: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w600)),
    SizedBox(height: 8),
    AppText(creating ? '회원가입' : '다시 만나 반갑습니다', style: TextStyle(color: ink, fontSize: 26, fontWeight: FontWeight.w800)),
    SizedBox(height: 10),
    AppText(creating ? '오르큐브와 함께 사용할 계정을 만드세요.' : '기존 오르큐브 이메일 계정으로 로그인하세요.', style: TextStyle(color: muted, fontSize: 14, height: 1.6)),
    SizedBox(height: 24),
    Container(padding: EdgeInsets.all(4), decoration: BoxDecoration(color: Color(0xFFF0F4F1), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [modeButton(false, '로그인'), SizedBox(width: 4), modeButton(true, '회원가입')])),
    SizedBox(height: 24),
    Form(key: formKey, child: AutofillGroup(child: Column(children: [
      TextFormField(controller: email, enabled: !busy, style: TextStyle(color: ink, fontSize: 16),
        keyboardType: TextInputType.emailAddress, autofillHints: [AutofillHints.email],
        decoration: InputDecoration(labelText: AppLanguage.t('이메일'), hintText: AppLanguage.t('name@example.com'), prefixIcon: Icon(Icons.mail_outline)),
        validator: (v) => v == null || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim()) ? AppLanguage.t('이메일 주소를 확인해주세요.') : null),
      SizedBox(height: 18),
      TextFormField(controller: password, enabled: !busy, style: TextStyle(color: ink, fontSize: 16), obscureText: hidePassword,
        autofillHints: [creating ? AutofillHints.newPassword : AutofillHints.password], autocorrect: false, enableSuggestions: false,
        textInputAction: TextInputAction.done, onFieldSubmitted: (_) { if (!busy) signIn(); },
        decoration: InputDecoration(labelText: AppLanguage.t('비밀번호'), hintText: AppLanguage.t(creating ? '8자 이상 입력해주세요.' : '비밀번호를 입력해주세요.'), prefixIcon: Icon(Icons.lock_outline),
          suffixIcon: IconButton(tooltip: AppLanguage.t(hidePassword ? '비밀번호 보기' : '비밀번호 숨기기'), onPressed: busy ? null : () => setState(() => hidePassword = !hidePassword), icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
        validator: (v) => v == null || v.isEmpty ? AppLanguage.t('비밀번호를 입력해주세요.') : creating && v.length < 8 ? AppLanguage.t('8자 이상 입력해주세요.') : null),
    ]))),
    if (creating) Padding(padding: EdgeInsets.only(top: 14), child: CheckboxListTile(
      tileColor: Colors.white,
      contentPadding: EdgeInsets.zero, controlAffinity: ListTileControlAffinity.leading, activeColor: forest,
      value: consent, onChanged: busy ? null : (v) => setState(() => consent = v ?? false),
      title: AppText('개인정보 처리 안내를 확인했습니다.', style: TextStyle(color: ink, fontSize: 14)),
      subtitle: AppText('첫 실행 안내의 처리 내용을 확인하고 회원가입에 동의합니다.', style: TextStyle(color: muted, fontSize: 12, height: 1.5)))),
    SizedBox(height: 24),
    FilledButton.icon(onPressed: busy ? null : signIn,
      icon: Icon(creating ? Icons.person_add_alt_1 : Icons.arrow_forward_rounded, color: Colors.white, size: 20),
      label: AppText(busy ? '처리 중…' : creating ? '회원가입 · 인증 메일 받기' : '로그인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
    if (!creating) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: busy ? null : () => act(() async {
      if (email.text.trim().isEmpty) return '재설정 안내를 받을 이메일을 입력해주세요.';
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      return '가입된 이메일이면 비밀번호 재설정 메일을 확인해주세요.';
    }), child: AppText('비밀번호를 잊으셨나요?'))),
    SizedBox(height: 14),
    Divider(color: Color(0xFFE5ECE7)),
    SizedBox(height: 14),
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.lock_outline, color: muted, size: 18), SizedBox(width: 8),
      Expanded(child: AppText('로그인 상태는 이 기기에 유지됩니다.\n공용 기기에서는 이용 후 로그아웃해주세요.', style: TextStyle(color: muted, fontSize: 12, height: 1.6)))]),
  ];

  Widget modeButton(bool signup, String label) => Expanded(child: Material(
    color: creating == signup ? Colors.white : Colors.transparent,
    borderRadius: BorderRadius.circular(9),
    child: InkWell(borderRadius: BorderRadius.circular(9), onTap: busy ? null : () => setState(() { creating = signup; message = ''; formKey.currentState?.reset(); }),
      child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: AppText(label, textAlign: TextAlign.center,
        style: TextStyle(color: creating == signup ? forest : muted, fontSize: 14, fontWeight: FontWeight.w700))))));

  List<Widget> accountPanel(BuildContext context, User user) => [
    AppText('내 계정', style: TextStyle(color: ink, fontSize: 28, fontWeight: FontWeight.w800)),
    SizedBox(height: 10), AppText('계정과 개인정보를 한곳에서 관리하세요.', style: TextStyle(color: muted, height: 1.6)),
    SizedBox(height: 24),
    Container(padding: EdgeInsets.all(20), decoration: BoxDecoration(color: Color(0xFFF3F7F4), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppText('로그인한 이메일', style: TextStyle(color: muted, fontSize: 12)), SizedBox(height: 8),
        AppText(user.email ?? '', style: TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w600)), SizedBox(height: 14),
        Row(children: [Icon(user.emailVerified ? Icons.verified_outlined : Icons.info_outline, color: user.emailVerified ? forest : Color(0xFF8B5D17), size: 20), SizedBox(width: 8),
          Expanded(child: AppText(user.emailVerified ? '이메일 인증 완료' : '이메일 인증이 필요합니다.', style: TextStyle(color: user.emailVerified ? forest : Color(0xFF8B5D17), fontWeight: FontWeight.w600)))]),
      ])),
    SizedBox(height: 20),
    FilledButton.icon(onPressed: busy ? null : () => Navigator.pop(context), icon: Icon(Icons.hiking), label: AppText('이전 화면으로 돌아가기')),
    if (!user.emailVerified) TextButton(onPressed: busy ? null : () => act(() async { await user.sendEmailVerification(); return '인증 메일을 보냈습니다.'; }), child: AppText('인증 이메일 다시 보내기')),
    TextButton(onPressed: busy ? null : () => act(() async { await user.reload(); await FirebaseAuth.instance.currentUser?.getIdToken(true); return FirebaseAuth.instance.currentUser?.emailVerified == true ? '이메일 인증 완료. 이동 화면에서 위치 공유를 시작할 수 있습니다.' : '아직 미인증 상태입니다. 받은 메일의 인증 링크를 먼저 눌러주세요.'; }), child: AppText('인증 상태 새로고침')),
    SizedBox(height: 10),
    OutlinedButton(onPressed: busy ? null : () => act(() async { await widget.onClearLocal?.call(); await FirebaseAuth.instance.signOut(); return '로그아웃되었습니다. 이 기기의 저장 지도와 화면 기록을 지웠습니다.'; }), child: AppText('로그아웃')),
    SizedBox(height: 20),
    AppText('위치 공유는 이동 화면에서 시작·중지할 수 있습니다. 계정 관리 후 이동 상태와 공유 상태를 확인하세요.', style: TextStyle(color: muted, fontSize: 12, height: 1.6)),
    SizedBox(height: 16), Divider(color: Color(0xFFE5ECE7)),
    ExpansionTile(tilePadding: EdgeInsets.zero, title: AppText('기록 삭제 · 회원탈퇴', style: TextStyle(color: ink, fontSize: 14)),
      subtitle: AppText('확인 후 진행하는 계정 관리 항목', style: TextStyle(color: muted, fontSize: 12)), children: [
        OutlinedButton(onPressed: busy ? null : () => act(() async {
          if (!await confirm('산행 기록 삭제', '본인의 산행·공유 위치·SOS 기록과 보호자 설정, 기기 저장 지도를 삭제합니다. 복구할 수 없습니다. 다른 ORQUBE 서비스 기록은 삭제하지 않습니다.')) return '취소했습니다.';
          await erase(user); return '산행 기록을 삭제했습니다.';
        }), child: AppText('산행 기록 삭제')),
        SizedBox(height: 16),
        TextField(controller: password, style: TextStyle(color: ink), obscureText: true, autocorrect: false, enableSuggestions: false,
          decoration: InputDecoration(labelText: AppLanguage.t('탈퇴 확인용 현재 비밀번호'), prefixIcon: Icon(Icons.lock_outline))),
        SizedBox(height: 16),
        OutlinedButton(onPressed: busy ? null : () => act(() async {
          if (!await confirm('ORQUBE 회원탈퇴', '이 Firebase 프로젝트의 ORQUBE 공통 로그인 계정이 삭제됩니다. 산행 기록은 먼저 삭제하지만 다른 앱의 별도 데이터는 남을 수 있습니다. 계속하시겠습니까?')) return '취소했습니다.';
          await user.reauthenticateWithCredential(EmailAuthProvider.credential(email: user.email!, password: password.text));
          await erase(user); await user.delete(); password.clear(); return '회원탈퇴가 완료되었습니다.';
        }), child: AppText('회원탈퇴', style: TextStyle(color: Color(0xFF9B3E3E)))),
        SizedBox(height: 12),
      ]),
  ];
}

class _MountainPainter extends CustomPainter {
  _MountainPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final back = Path()..moveTo(0, size.height * .75)..lineTo(size.width * .25, size.height * .48)
      ..lineTo(size.width * .45, size.height * .68)..lineTo(size.width * .74, size.height * .40)
      ..lineTo(size.width, size.height * .70)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(back, Paint()..color = Color(0xFF214D3B));
    final front = Path()..moveTo(0, size.height * .91)..lineTo(size.width * .38, size.height * .65)
      ..lineTo(size.width * .70, size.height * .91)..lineTo(size.width, size.height * .72)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(front, Paint()..color = Color(0xFF315D45));
    canvas.drawCircle(Offset(size.width * .84, size.height * .15), 20, Paint()..color = Color(0xFF53735C));
  }
  @override bool shouldRepaint(covariant _MountainPainter oldDelegate) => false;
}
