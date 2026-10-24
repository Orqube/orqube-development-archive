import '../admin/auto_marketing_page.dart';
import '../services/admin_access.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/fusion_marketing_approval_page.dart';
import '../features/ai_launch/screens/ai_marketing_approval_page.dart';
import '../services/fusion_marketing_service.dart';

class AiMarketingCenterPage extends StatefulWidget {
  const AiMarketingCenterPage({super.key});
  @override
  State<AiMarketingCenterPage> createState() => _AiMarketingCenterPageState();
}

class _AiMarketingCenterPageState extends State<AiMarketingCenterPage> {
  static const bg = Color(0xFF03040B), panel = Color(0xFF0B0D1B), lime = Color(0xFFD7FF35), purple = Color(0xFF8B2CF6), muted = Color(0xFFAAB0C5);
  final keyForm = GlobalKey<FormState>();
  final name = TextEditingController(), objective = TextEditingController(), message = TextEditingController(), audience = TextEditingController(), cta = TextEditingController();
  bool official = true, admin = false, generating = false;
  bool checkingAdmin = true;
  String country = '대한민국', language = '한국어', projectId = '';
  Map<String, dynamic>? result;
  String resultId = '';
  final channels = <String>{'ORQUBE 홈', 'Facebook', 'X'};
  static const allChannels = ['ORQUBE 홈', 'Facebook', 'X', 'YouTube', '네이버 카페', 'Telegram', 'Discord', 'QR/오프라인'];

  @override
  void initState() { super.initState(); _loadAdmin(); }
  Future<void> _loadAdmin() async {
    bool permitted = false;
    try { permitted = await AdminAccess.allowed(); } catch (_) {}
    if (mounted) setState(() { admin = permitted; checkingAdmin = false; });
  }

  @override
  void dispose() { for (final c in [name, objective, message, audience, cta]) { c.dispose(); } super.dispose(); }

  void _mode(bool value) {
    if (value && !admin) { _toast('ORQUBE 공식 홍보는 관리자 계정 전용입니다.'); return; }
    setState(() { official = value; result = null; if (value) { name.text = 'ORQUBE 공식 캠페인'; projectId = ''; } });
  }

  Future<void> _generate() async {
    if (!await AdminAccess.allowed()) { _toast('관리자 전용 기능입니다.'); return; }
    if (!keyForm.currentState!.validate() || generating) return;
    if (!official && projectId.isEmpty) { _toast('홍보할 내 토큰을 선택해 주세요.'); return; }
    if (channels.isEmpty) { _toast('홍보 채널을 한 개 이상 선택해 주세요.'); return; }
    setState(() => generating = true);
    try {
      final r = await FusionMarketingService().generate(
        campaignType: official ? 'ORQUBE_OFFICIAL' : 'TOKEN_PROMOTION', campaignName: name.text.trim(),
        objective: objective.text.trim(), coreMessage: message.text.trim(), audience: audience.text.trim(),
        country: country, language: language, channels: channels.toList(), projectId: projectId, callToAction: cta.text.trim(),
      );
      if (mounted) { setState(() { result = r.data; resultId = r.id; }); _toast('핵융합식 캠페인 초안이 생성되었습니다.'); }
    } on FusionMarketingException catch (e) { if (mounted) _toast(e.message); }
    finally { if (mounted) setState(() => generating = false); }
  }
  void _toast(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (checkingAdmin || !admin) return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('관리자 AI 마케팅')),
      body: Center(child: checkingAdmin ? const CircularProgressIndicator() : const Text('이메일 인증을 완료한 관리자만 이용할 수 있습니다.', style: TextStyle(color: Colors.white))),
    );
    return Scaffold(backgroundColor: bg, appBar: AppBar(backgroundColor: bg, foregroundColor: Colors.white, title: const Text('ORQUBE AI MARKETING', style: TextStyle(fontWeight: FontWeight.w900))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(18), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1050), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('핵융합식 캠페인 생성', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8), const Text('하나의 핵심 메시지에서 채널별 홍보 콘텐츠와 7일 확산 순서를 함께 생성합니다.', style: TextStyle(color: muted, height: 1.5)),
        if (admin) ...[const SizedBox(height: 16), FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AutoMarketingPage())), icon: const Icon(Icons.travel_explore), label: const Text('외부 커뮤니티 자동 발굴 · 지속 마케팅'))],
        const SizedBox(height: 16), _flow(), const SizedBox(height: 16), if (user == null) _notice('로그인 후 캠페인을 생성할 수 있습니다.'), _modes(),
        if (user != null) ...[const SizedBox(height: 16), _form(user.uid)],
        if (result != null) ...[const SizedBox(height: 20), _result(result!)],
        if (user != null) ...[const SizedBox(height: 22), _history(user.uid)],
      ])))));
  }

  Widget _flow() => Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: box(purple.withOpacity(.12), purple.withOpacity(.5)), child: Wrap(spacing: 8, runSpacing: 8, children: const [
    _Step('1 · 목표'), _Step('2 · 메시지 핵'), _Step('3 · 채널 증식'), _Step('4 · 사람 승인'), _Step('5 · 성과 재활용'),
  ]));

  Widget _modes() => LayoutBuilder(builder: (_, c) { final w = c.maxWidth < 700 ? c.maxWidth : (c.maxWidth - 12) / 2; return Wrap(spacing: 12, runSpacing: 12, children: [
    SizedBox(width: w, child: _modeCard(official, admin, Icons.verified_rounded, '관리자 · ORQUBE 공식 홍보', '플랫폼, 안전산행, 에어소프트, 채굴·보상과 공식 소식을 홍보합니다.', 'ADMIN ONLY', () => _mode(true))),
    SizedBox(width: w, child: _modeCard(!official, true, Icons.token_rounded, '토큰 개발자 · 내 토큰 홍보', '내 토큰을 선택해 실사용, 커뮤니티와 멤버십 중심으로 홍보합니다.', 'TOKEN OWNER', () => _mode(false))),
  ]); });
  Widget _modeCard(bool selected, bool enabled, IconData icon, String title, String sub, String badge, VoidCallback tap) => InkWell(onTap: tap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(18), decoration: box(selected ? purple.withOpacity(.2) : panel, selected ? lime : Colors.white12, selected ? 2 : 1), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Icon(icon, color: enabled ? lime : Colors.white38), const Spacer(), _badge(badge)]), const SizedBox(height: 12),
    Text(title, style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(sub, style: TextStyle(color: enabled ? muted : Colors.white30, height: 1.4)),
  ])));

  Widget _form(String uid) => Container(padding: const EdgeInsets.all(20), decoration: box(panel, Colors.white12), child: Form(key: keyForm, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(official ? 'ORQUBE 공식 캠페인 설계' : '내 토큰 캠페인 설계', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
    const SizedBox(height: 5), Text(official ? 'ORQUBE 공식 브랜드의 목소리로 생성됩니다.' : 'ORQUBE 공식 홍보와 분리되며 토큰 개발자가 발신자로 표시됩니다.', style: const TextStyle(color: lime)), const SizedBox(height: 16),
    if (!official) ...[_projects(uid), const SizedBox(height: 12)],
    _field('캠페인 이름', name, true), const SizedBox(height: 12), _field('이번 캠페인의 목표', objective, true, 2, '예: QR 보상 사용법 알리기'), const SizedBox(height: 12),
    _field('핵심 메시지 · 캠페인의 핵', message, true, 4, '모든 채널에서 변하지 않을 한 가지 약속과 사실'), const SizedBox(height: 12),
    _field('핵심 대상', audience, true, 2, '예: 한국·일본의 에어소프트 사용자'), const SizedBox(height: 12), _field('행동 유도 문구', cta, false, 1, '예: ORQUBE에서 무료로 체험해 보세요'), const SizedBox(height: 12),
    LayoutBuilder(builder: (_, c) { final w = c.maxWidth < 620 ? c.maxWidth : (c.maxWidth - 12) / 2; return Wrap(spacing: 12, runSpacing: 12, children: [
      SizedBox(width: w, child: _drop('대상 지역', country, const ['대한민국','일본','대만','동남아시아','글로벌'], (v) => setState(() => country = v!))),
      SizedBox(width: w, child: _drop('생성 언어', language, const ['한국어','영어','일본어','중국어','프랑스어','포르투갈어'], (v) => setState(() => language = v!))),
    ]); }), const SizedBox(height: 16), const Text('증식할 홍보 채널', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const SizedBox(height: 8),
    Wrap(spacing: 8, runSpacing: 8, children: allChannels.map((x) => FilterChip(label: Text(x), selected: channels.contains(x), selectedColor: purple.withOpacity(.5), checkmarkColor: lime, onSelected: (v) => setState(() => v ? channels.add(x) : channels.remove(x)))).toList()),
    const SizedBox(height: 18), Row(children: [const Expanded(child: Text('자동 게시하지 않고 검토용 초안으로 저장합니다.', style: TextStyle(color: muted))), FilledButton.icon(onPressed: generating ? null : _generate, style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)), icon: generating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome), label: Text(generating ? '생성 중...' : '핵융합 캠페인 생성'))]),
  ])));

  Widget _projects(String uid) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('launch_projects').where('ownerUid', isEqualTo: uid).limit(50).snapshots(), builder: (_, s) {
    final docs = s.data?.docs ?? []; if (docs.isEmpty) return _notice('TOKEN CREATE에서 내 토큰 초안을 먼저 만들어 주세요.');
    return DropdownButtonFormField<String>(value: docs.any((d) => d.id == projectId) ? projectId : null, dropdownColor: panel, decoration: input('홍보할 내 토큰 선택'), items: docs.map((d) { final x = d.data(); return DropdownMenuItem(value: d.id, child: Text('${x['name'] ?? '이름 없는 토큰'} (${x['symbol'] ?? '-'})')); }).toList(), onChanged: (v) => setState(() => projectId = v ?? ''));
  });

  Widget _result(Map<String, dynamic> d) { final assets = (d['channelAssets'] as List?)?.whereType<Map>().toList() ?? []; final seq = d['sevenDaySequence'] as List? ?? []; return Container(padding: const EdgeInsets.all(20), decoration: box(const Color(0xFF101426), lime.withOpacity(.6)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Icon(Icons.hub, color: lime), const SizedBox(width: 9), Expanded(child: Text('${d['campaignTitle'] ?? '캠페인'}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))), _badge('DRAFT')]),
    const SizedBox(height: 8), Text('${d['slogan'] ?? ''}', style: const TextStyle(color: lime, fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 14), _block('캠페인 핵', '${d['nucleus'] ?? ''}'), _block('대상 인사이트', '${d['audienceInsight'] ?? ''}'),
    const Text('채널별 파생 콘텐츠', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 8),
    ...assets.map((raw) { final a = Map<String,dynamic>.from(raw); return Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14), decoration: box(Colors.white.withOpacity(.04), Colors.white10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${a['channel'] ?? ''}', style: const TextStyle(color: lime, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text('${a['headline'] ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const SizedBox(height: 5), SelectableText('${a['body'] ?? ''}', style: const TextStyle(color: Colors.white70, height: 1.45))])); }),
    if (seq.isNotEmpty) _block('7일 확산 순서', seq.asMap().entries.map((e) => '${e.key + 1}일차 · ${e.value}').join('\n')),
    const Text('사람이 검토·수정하고 승인한 뒤 게시합니다.', style: TextStyle(color: lime, fontWeight: FontWeight.w800)), const SizedBox(height: 12),
    if (resultId.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: [
      if (['draft', 'held', 'rejected'].contains('${d['status'] ?? 'draft'}')) FilledButton.icon(onPressed: () => _workflow('SUBMIT'), icon: const Icon(Icons.fact_check), label: const Text('승인 요청')),
      if (admin && '${d['status']}' == 'pending') FilledButton.icon(onPressed: () => _workflow('APPROVE'), icon: const Icon(Icons.verified), label: const Text('승인')),
      if ('${d['status']}' == 'approved') FilledButton.icon(onPressed: _recordPublish, icon: const Icon(Icons.add_link), label: const Text('배포 기록')),
      if ('${d['status']}' == 'approved') OutlinedButton(onPressed: _showDistributionLogs, child: const Text('배포 이력')),
    ]),
  ])); }

  Widget _history(String uid) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Expanded(child: Text('내 캠페인 초안', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900))), if (admin) OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FusionMarketingApprovalPage())), child: const Text('핵융합 승인')), const SizedBox(width: 8), OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiMarketingApprovalPage())), child: const Text('토큰 승인'))]), const SizedBox(height: 9),
    StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream: FirebaseFirestore.instance.collection('marketing_campaigns').where('ownerUid', isEqualTo: uid).limit(20).snapshots(), builder: (_, s) { if (s.hasError) return _notice('캠페인 목록 조회 실패: ${s.error}'); final docs = s.data?.docs ?? []; if (docs.isEmpty) return _notice('아직 생성된 캠페인이 없습니다.'); return Column(children: docs.map((doc) { final x = doc.data(); return ListTile(tileColor: panel, leading: Icon(x['campaignType'] == 'ORQUBE_OFFICIAL' ? Icons.verified : Icons.token, color: lime), title: Text('${x['campaignTitle'] ?? x['campaignName'] ?? x['title'] ?? '캠페인'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), subtitle: Text(x['campaignType'] == 'ORQUBE_OFFICIAL' ? 'ORQUBE 공식 홍보' : '내 토큰 홍보 · ${x['tokenSymbol'] ?? ''}', style: const TextStyle(color: muted)), trailing: _badge('${x['status'] ?? 'pending'}'.toUpperCase()), onTap: x['campaignEngine'] == 'FUSION_V1' ? () => setState(() { result = x; resultId = doc.id; }) : null); }).toList()); }),
  ]);

  Future<void> _workflow(String action) async { try { final x = await FusionMarketingService().workflow(campaignId: resultId, action: action); if (mounted) setState(() => result = {...?result, ...x}); _toast('처리되었습니다.'); } on FusionMarketingException catch (e) { _toast(e.message); } }
  Future<void> _recordPublish() async { final channel = TextEditingController(), url = TextEditingController(), note = TextEditingController(); final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('배포 기록'), content: SizedBox(width: 430, child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: channel, decoration: const InputDecoration(labelText: '채널')), TextField(controller: url, decoration: const InputDecoration(labelText: '게시물 URL')), TextField(controller: note, decoration: const InputDecoration(labelText: '메모'))])), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('기록'))])); if (ok == true) { try { await FusionMarketingService().workflow(campaignId: resultId, action: 'RECORD_PUBLISH', channel: channel.text, publishedUrl: url.text, note: note.text); _toast('배포 기록을 저장했습니다.'); } on FusionMarketingException catch (e) { _toast(e.message); } } channel.dispose(); url.dispose(); note.dispose(); }
  void _showDistributionLogs() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('marketing_campaigns')
              .doc(resultId)
              .collection('distribution_logs')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (_, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    '배포 이력',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (docs.isEmpty) const Text('기록이 없습니다.'),
                  ...docs.map(
                    (doc) {
                      final data = doc.data();
                      return ListTile(
                        leading: const Icon(Icons.public),
                        title: Text('${data['channel'] ?? ''}'),
                        subtitle: Text(
                          '${data['publishedUrl'] ?? ''}\n${data['note'] ?? ''}',
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _field(String label, TextEditingController c, bool required, [int lines = 1, String? hint]) => TextFormField(controller: c, minLines: lines, maxLines: lines, style: const TextStyle(color: Colors.white), decoration: input(label).copyWith(hintText: hint, hintStyle: const TextStyle(color: Colors.white30)), validator: (v) => required && (v == null || v.trim().length < 2) ? '$label을 입력해 주세요.' : null);
  Widget _drop(String label, String value, List<String> items, ValueChanged<String?> change) => DropdownButtonFormField<String>(value: value, dropdownColor: panel, style: const TextStyle(color: Colors.white), decoration: input(label), items: items.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: change);
  InputDecoration input(String label) => InputDecoration(labelText: label, labelStyle: const TextStyle(color: muted), filled: true, fillColor: Colors.white.withOpacity(.035), border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Colors.white12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: lime)));
  BoxDecoration box(Color color, Color border, [double width = 1]) => BoxDecoration(color: color, borderRadius: BorderRadius.circular(18), border: Border.all(color: border, width: width));
  Widget _notice(String text) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: box(purple.withOpacity(.12), purple.withOpacity(.4)), child: Text(text, style: const TextStyle(color: Colors.white70)));
  Widget _block(String title, String body) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: muted, fontWeight: FontWeight.w800)), const SizedBox(height: 4), SelectableText(body, style: const TextStyle(color: Colors.white, height: 1.45))]));
  Widget _badge(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: purple.withOpacity(.25), borderRadius: BorderRadius.circular(20)), child: Text(text, style: const TextStyle(color: lime, fontSize: 11, fontWeight: FontWeight.w900)));
}

class _Step extends StatelessWidget { const _Step(this.text); final String text; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), decoration: BoxDecoration(color: Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(20)), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))); }
