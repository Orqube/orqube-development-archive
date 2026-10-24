import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/people_service.dart';
import '../services/invite_inbox.dart';
import '../utils/connection_invite.dart';
import '../utils/app_language.dart';
import 'hiking_account_page.dart';
import 'invite_scanner_page.dart';
import 'companion_theme.dart';

class ConnectionInvitePage extends StatefulWidget {
  final ConnectionInvite? initial;
  const ConnectionInvitePage({super.key, this.initial});
  @override State<ConnectionInvitePage> createState() => _ConnectionInvitePageState();
}
class _ConnectionInvitePageState extends State<ConnectionInvitePage> with LanguageAware<ConnectionInvitePage> {
  final input = TextEditingController();
  final name = TextEditingController();
  String relation = 'family', message = '';
  ConnectionInvite? target;
  bool busy = false;
  @override void initState() { super.initState(); target = widget.initial; }
  @override void dispose() { input.dispose(); name.dispose(); super.dispose(); }
  Future<void> act(Future<void> Function() action) async {
    if (busy) return;
    setState(() { busy = true; message = ''; });
    try { await action(); } catch (_) { if (mounted) setState(() => message = '처리하지 못했습니다. 로그인·이메일 인증·인터넷 연결을 확인한 뒤 다시 시도하세요.'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  Future<void> connect() async {
    final peer = target;
    final user = FirebaseAuth.instance.currentUser;
    if (peer == null || user == null || !user.emailVerified) return;
    if (peer.uid == user.uid) { setState(() => message = '내 초대 링크입니다. 상대방에게 보내주세요.'); return; }
    final label = name.text.trim();
    if (label.isEmpty) { setState(() => message = '상대방을 알아볼 표시 이름을 입력하세요.'); return; }
    await act(() async {
      await user.reload();
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (FirebaseAuth.instance.currentUser?.uid != user.uid) throw StateError('Account changed');
      final rows = await PeopleService.load();
      final matches = rows.where((p) => p.uid == peer.uid).toList();
      if (matches.isNotEmpty && matches.first.status == 'accepted') {
        await PeopleService.saveMetadata(peer.uid, matches.first.connectionId, label, relation);
        if (mounted) setState(() => message = '이미 연결된 사람입니다. 이름과 관계를 저장했습니다.');
      } else if (matches.isNotEmpty && matches.first.incoming) {
        await PeopleService.accept(matches.first, label, relation);
        if (mounted) setState(() => message = '연결되었습니다. 이동을 시작할 때 공유할 사람으로 선택하세요.');
      } else {
        await PeopleService.invite(peer.uid, label, relation);
        if (mounted) setState(() => message = '연결 요청을 보냈습니다. 상대방의 받은 초대에서 승인하면 연결됩니다.');
      }
      if (InviteInbox.pending.value?.uid == peer.uid) await InviteInbox.clear();
      if (mounted) setState(() => target = null);
    });
  }
  Future<void> login() async {
    await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => HikingAccountPage()));
    if (mounted) setState(() {});
  }
  @override Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final invite = user == null ? null : ConnectionInvite(user.uid);
    final link = invite?.link(AppLanguage.changed.value);
    return Theme(data: companionLightTheme(), child: Scaffold(
      appBar: AppBar(title: AppText('가족·친구 초대'), actions: [LanguageButton()]),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: ListView(padding: const EdgeInsets.all(24), children: [
        AppText('링크나 QR로 쉽게 연결하세요.', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        AppText('휴대폰 공유창에서 WhatsApp·LINE·문자·이메일 등 설치된 앱을 선택할 수 있습니다. 연결 후에도 위치 공유는 직접 시작해야 합니다.', style: const TextStyle(fontSize: 17, height: 1.7)),
        if (user == null || !user.emailVerified) ...[
          const SizedBox(height: 16), AppText('연결하려면 로그인과 이메일 인증이 필요합니다. 받은 초대는 로그인 후에도 유지됩니다.'),
          FilledButton(onPressed: busy ? null : login, child: AppText('로그인·인증 확인')),
        ],
        if (invite != null) Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          AppText('내 초대 QR', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          AppText('상대방이 스캔한 뒤 연결 요청을 보내면 내가 승인합니다. QR에는 내 연결 ID가 포함됩니다.'),
          const SizedBox(height: 16),
          Semantics(label: AppLanguage.t('내 초대 QR'), child: Container(color: Colors.white, padding: const EdgeInsets.all(12), child: QrImageView(data: link!, size: 220, backgroundColor: Colors.white))),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: busy ? null : () => act(() async {
            final box = context.findRenderObject() as RenderBox?;
            await Share.share('${AppLanguage.t('오르큐브 안심동행에서 연결해요. 링크를 열고 로그인한 뒤 연결 요청을 보내주세요. 위치는 자동 공유되지 않습니다.')}\n$link',
              sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size);
          }), icon: const Icon(Icons.ios_share), label: AppText('초대 링크 보내기')),
          OutlinedButton.icon(onPressed: busy ? null : () => act(() async { await Clipboard.setData(ClipboardData(text: link!)); if (mounted) setState(() => message = '초대 링크를 복사했습니다.'); }), icon: const Icon(Icons.copy), label: AppText('초대 링크 복사')),
        ]))),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: busy ? null : () async {
          final scanned = await Navigator.push<ConnectionInvite>(context, MaterialPageRoute(builder: (_) => const InviteScannerPage()));
          if (scanned != null && mounted) setState(() { target = scanned; message = ''; });
        }, icon: const Icon(Icons.qr_code_scanner), label: AppText('상대방 QR 스캔')),
        TextField(controller: input, maxLength: 600, decoration: InputDecoration(labelText: AppLanguage.t('받은 초대 링크 또는 연결 ID'))),
        TextButton(onPressed: busy ? null : () { final parsed = ConnectionInvite.parse(input.text, allowId: true); setState(() { target = parsed; message = parsed == null ? '올바른 오르큐브 초대 링크 또는 연결 ID를 입력하세요.' : ''; }); }, child: AppText('받은 초대 확인')),
        if (target != null) Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppText('연결할 사람 확인', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          AppText('링크만으로 상대방 신원을 보증하지 않습니다. 알고 있는 사람에게 받은 초대인지 확인하세요.'),
          SelectableText(target!.uid),
          TextField(controller: name, maxLength: 80, decoration: InputDecoration(labelText: AppLanguage.t('표시 이름'))),
          DropdownButtonFormField<String>(value: relation, items: PeopleService.relations.entries.map((e) => DropdownMenuItem(value: e.key, child: AppText(e.value))).toList(), onChanged: busy ? null : (v) => setState(() => relation = v ?? 'family')),
          FilledButton(onPressed: busy || user == null || !user.emailVerified ? null : connect, child: AppText('연결 요청·수락')),
          if (kIsWeb) TextButton(onPressed: busy ? null : () => act(() async { if (!await launchUrl(Uri.parse(target!.appLink), mode: LaunchMode.externalApplication)) { if (mounted) setState(() => message = '설치된 앱을 열지 못했습니다. 이 화면에서 계속하거나 앱에서 링크를 붙여넣으세요.'); } }), child: AppText('설치된 앱에서 열기')),
          TextButton(onPressed: busy ? null : () async { if (InviteInbox.pending.value?.uid == target!.uid) await InviteInbox.clear(); if (mounted) setState(() => target = null); }, child: AppText('초대 닫기')),
        ]))),
        if (busy) const LinearProgressIndicator(),
        if (message.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: AppText(message, style: const TextStyle(fontSize: 17, height: 1.7))),
      ]))),
    ));
  }
}

/// Shown only at the home screen: receiving a link never interrupts a trip.
class InviteHomeGate extends StatefulWidget {
  final Widget child;
  const InviteHomeGate({super.key, required this.child});
  @override State<InviteHomeGate> createState() => _InviteHomeGateState();
}
class _InviteHomeGateState extends State<InviteHomeGate> {
  @override Widget build(BuildContext context) => ValueListenableBuilder<ConnectionInvite?>(
    valueListenable: InviteInbox.pending, builder: (context, invite, _) => invite == null ? widget.child :
      ConnectionInvitePage(key: ValueKey(invite.uid), initial: invite),
  );
}
