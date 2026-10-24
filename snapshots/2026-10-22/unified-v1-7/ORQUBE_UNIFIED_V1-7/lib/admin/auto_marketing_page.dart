import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/auto_marketing_service.dart';

class AutoMarketingPage extends StatefulWidget {
  const AutoMarketingPage({super.key});
  @override
  State<AutoMarketingPage> createState() => _AutoMarketingPageState();
}

class _AutoMarketingPageState extends State<AutoMarketingPage> {
  final service = AutoMarketingService();
  final brief = TextEditingController();
  final facts = TextEditingController();
  final landing = TextEditingController();
  Map<String, dynamic>? data;
  Map<String, dynamic> settings = {};
  bool busy = false;
  bool dirty = false;
  String message = '';
  String filter = 'all';
  static const fieldNames = {
    'AIRSOFT': '에어소프트',
    'SAFE_COMPANION': '안심동행',
    'MEME_CREATOR': '밈코인 제작',
    'TOKEN_CREATOR': '토큰 자동생성',
    'PI_COMPANION': 'Pi 연동',
  };
  static const marketNames = {
    'KR': '한국 · 한국어',
    'JP': '일본 · 일본어',
    'TW': '대만 · 번체중국어',
    'PH': '필리핀 · 영어',
    'VN': '베트남 · 베트남어',
    'ID': '인도네시아 · 인도네시아어',
    'TH': '태국 · 태국어',
    'GLOBAL': '글로벌 · 영어',
    'FR': '프랑스 · 프랑스어',
    'BR': '브라질 · 포르투갈어',
  };
  static const statusNames = {
    'pending': '검토 대기',
    'accepted': '채택',
    'held': '보류',
    'rejected': '제외',
    'draft': '초안',
    'approved': '사용 승인',
    'generating': '생성 중',
    'failed': '실패',
    'completed': '완료',
    'running': '실행 중',
    'allowed': '허용 확인',
    'conditional': '조건부',
    'prohibited': '금지',
    'unknown': '미확인',
  };
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    brief.dispose();
    facts.dispose();
    landing.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> rows(String key) => (data?[key] as List? ?? [])
      .map((x) => Map<String, dynamic>.from(x as Map))
      .toList();
  String label(dynamic value) => statusNames[value] ?? '$value';
  String date(dynamic value) => value is num && value > 0
      ? DateTime.fromMillisecondsSinceEpoch(value.toInt())
            .toLocal()
            .toString()
            .split('.')
            .first
      : '없음';
  Future<void> _load() async {
    setState(() {
      busy = true;
      message = '';
    });
    try {
      final result = await service.call('STATE');
      if (!mounted) return;
      data = result;
      settings = Map<String, dynamic>.from(result['settings'] as Map);
      brief.text = '${settings['brief'] ?? ''}';
      facts.text = '${settings['verifiedFacts'] ?? ''}';
      landing.text = '${settings['landingUrl'] ?? ''}';
      dirty = false;
    } catch (e) {
      message = '$e';
    }
    if (mounted)
      setState(() {
        busy = false;
      });
  }

  Future<void> _act(
    String action, [
    Map<String, dynamic> payload = const {},
  ]) async {
    setState(() {
      busy = true;
      message = '';
    });
    try {
      final result = await service.call(action, payload);
      if (!mounted) return;
      final skipped = result['skipped'];
      await _load();
      if (!mounted) return;
      setState(() {
        message = skipped == null
            ? '처리되었습니다. 게시 상태는 아직 미게시입니다.'
            : {
                    'PAUSED': '자동 발굴이 꺼져 있습니다.',
                    'RUNNING': '다른 검색이 진행 중입니다. 잠시 후 새로고침하세요.',
                    'DAILY_LIMIT': '오늘 실행 한도에 도달했습니다. 한국시간 자정 후 다시 실행할 수 있습니다.',
                    'NOT_DUE': '다음 실행 시각을 기다리는 중입니다.',
                  }[skipped] ??
                  '$skipped';
      });
    } catch (e) {
      if (mounted)
        setState(() {
          busy = false;
          message = '$e';
        });
    }
  }

  Future<void> _save() async {
    await _act('SAVE', {
      'settings': {
        ...settings,
        'brief': brief.text,
        'verifiedFacts': facts.text,
        'landingUrl': landing.text,
      },
    });
  }

  Future<void> _open(dynamic value) async {
    final uri = Uri.tryParse('$value');
    if (uri == null || uri.scheme != 'https') return;
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          mounted)
        setState(() {
          message = '링크를 열지 못했습니다.';
        });
    } catch (e) {
      if (mounted)
        setState(() {
          message = '링크 열기 실패: $e';
        });
    }
  }

  Widget _link(String text, dynamic url) => TextButton(
    onPressed: '$url'.startsWith('https://') ? () => _open(url) : null,
    child: Text(text),
  );
  Widget _card(List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
  Widget _title(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      text,
      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
    ),
  );
  void _toggle(String key, String value, bool selected) {
    final values = List<String>.from(settings[key] as List? ?? []);
    if (selected) {
      if (!values.contains(value)) values.add(value);
    } else {
      values.remove(value);
    }
    setState(() {
      settings[key] = values;
      dirty = true;
    });
  }

  Widget _config() => _card([
    _title('지속 발굴 설정'),
    SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('주기적 자동 발굴'),
      subtitle: const Text('서버에서 실행하므로 화면을 닫아도 작동합니다. 저장 후 적용됩니다.'),
      value: settings['enabled'] == true,
      onChanged: busy
          ? null
          : (v) => setState(() {
              settings['enabled'] = v;
              dirty = true;
            }),
    ),
    const Text('대상 분야'),
    Wrap(
      spacing: 8,
      children: fieldNames.entries
          .map(
            (e) => FilterChip(
              label: Text(e.value),
              selected: (settings['fields'] as List? ?? []).contains(e.key),
              onSelected: busy ? null : (v) => _toggle('fields', e.key, v),
            ),
          )
          .toList(),
    ),
    const SizedBox(height: 14),
    const Text('국가와 콘텐츠 언어'),
    Wrap(
      spacing: 8,
      children: marketNames.entries
          .map(
            (e) => FilterChip(
              label: Text(e.value),
              selected: (settings['markets'] as List? ?? []).contains(e.key),
              onSelected: busy ? null : (v) => _toggle('markets', e.key, v),
            ),
          )
          .toList(),
    ),
    const SizedBox(height: 14),
    DropdownButtonFormField<int>(
      value: settings['intervalHours'] as int? ?? 6,
      decoration: const InputDecoration(labelText: '실행 간격'),
      items: List.generate(
        24,
        (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}시간마다')),
      ),
      onChanged: busy
          ? null
          : (v) => setState(() {
              settings['intervalHours'] = v;
              dirty = true;
            }),
    ),
    DropdownButtonFormField<int>(
      value: settings['dailyLimit'] as int? ?? 4,
      decoration: const InputDecoration(labelText: '하루 검색 실행 한도 · 한국시간 기준'),
      items: List.generate(
        12,
        (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}회')),
      ),
      onChanged: busy
          ? null
          : (v) => setState(() {
              settings['dailyLimit'] = v;
              dirty = true;
            }),
    ),
    const SizedBox(height: 12),
    TextField(
      controller: brief,
      enabled: !busy,
      maxLength: 2000,
      maxLines: 3,
      decoration: const InputDecoration(labelText: '캠페인 목표'),
      onChanged: (_) => setState(() {
        dirty = true;
      }),
    ),
    TextField(
      controller: facts,
      enabled: !busy,
      maxLength: 3000,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: '직접 확인한 기능과 사실',
        hintText: '검증한 기능만 입력하세요. 비어 있으면 시제품 의견 모집으로 작성합니다.',
      ),
      onChanged: (_) => setState(() {
        dirty = true;
      }),
    ),
    TextField(
      controller: landing,
      enabled: !busy,
      decoration: const InputDecoration(labelText: '소개 페이지 HTTPS 주소'),
      onChanged: (_) => setState(() {
        dirty = true;
      }),
    ),
    const SizedBox(height: 12),
    const Text('홍보 초안을 만들 채널'),
    Wrap(
      spacing: 8,
      children:
          ['X', 'Instagram', 'Facebook', 'YouTube', '네이버 카페', 'ORQUBE 사이트']
              .map(
                (channel) => FilterChip(
                  label: Text(channel),
                  selected: (settings['channels'] as List? ?? []).contains(
                    channel,
                  ),
                  onSelected: busy
                      ? null
                      : (v) => _toggle('channels', channel, v),
                ),
              )
              .toList(),
    ),
    SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('검색 후 융합 캠페인 초안 생성'),
      subtitle: const Text('회당 적합 후보 최대 1곳 · 관련 서비스 최대 2개를 연결합니다.'),
      value: settings['autoDraft'] == true,
      onChanged: busy
          ? null
          : (v) => setState(() {
              settings['autoDraft'] = v;
              dirty = true;
            }),
    ),
    const Text(
      '한 번에 분야·국가 조합 하나를 검색하고 최대 5개 후보를 저장합니다. 다음 실행에서 다음 조합으로 이동합니다. 웹 검색·AI API 사용료가 발생하며 횟수 제한은 금액 한도가 아닙니다.',
    ),
    const SizedBox(height: 12),
    Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        FilledButton(
          onPressed: busy ? null : _save,
          child: Text(dirty ? '변경 설정 저장' : '설정 저장'),
        ),
        OutlinedButton(
          onPressed: busy || dirty ? null : () => _act('RUN'),
          child: const Text('지금 1회 발굴'),
        ),
      ],
    ),
    if (dirty) const Text('변경 내용을 저장해야 수동 검색을 실행할 수 있습니다.'),
  ]);
  Future<void> _review(Map<String, dynamic> c) async {
    String status = '${c['reviewStatus'] ?? 'pending'}';
    if (!['accepted', 'held', 'rejected'].contains(status)) status = 'held';
    String policy = '${c['policyStatus'] ?? 'unknown'}';
    final note = TextEditingController(text: '${c['reviewNote'] ?? ''}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: Text('${c['name']} 검토'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: status,
                    items: ['accepted', 'held', 'rejected']
                        .map(
                          (v) =>
                              DropdownMenuItem(value: v, child: Text(label(v))),
                        )
                        .toList(),
                    onChanged: (v) => update(() {
                      status = v!;
                    }),
                  ),
                  DropdownButtonFormField<String>(
                    value: policy,
                    items: ['unknown', 'allowed', 'conditional', 'prohibited']
                        .map(
                          (v) =>
                              DropdownMenuItem(value: v, child: Text(label(v))),
                        )
                        .toList(),
                    onChanged: (v) => update(() {
                      policy = v!;
                    }),
                  ),
                  TextField(
                    controller: note,
                    maxLength: 1000,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '규칙을 읽고 확인한 조건과 메모',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
    final text = note.text;
    note.dispose();
    if (ok == true && mounted)
      await _act('REVIEW', {
        'id': c['id'],
        'status': status,
        'policyStatus': policy,
        'note': text,
      });
  }

  Widget _candidate(Map<String, dynamic> c) => _card([
    Text(
      '${c['name']}',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    Text(
      '${marketNames[c['market']] ?? c['market']} · ${fieldNames[c['field']] ?? c['field']} · AI 적합도 ${c['fitScore']}',
    ),
    Text('검토 ${label(c['reviewStatus'])} / 규칙 ${label(c['policyStatus'])}'),
    Text('${c['fitReason']}'),
    const SizedBox(height: 8),
    Text(
      '최근 활동일: ${c['lastActivityDate'] == '' ? '미확인' : c['lastActivityDate']} · AI 조사 결과',
    ),
    Text('${c['activityEvidence']}'),
    Text('AI 규칙 판단: ${label(c['suggestedPolicy'])}'),
    Text('${c['ruleEvidence']}'),
    if ('${c['reviewNote'] ?? ''}'.isNotEmpty)
      Text('검토 메모: ${c['reviewNote']}'),
    Text('확인 시각: ${date(c['checkedAt'])}'),
    Wrap(
      spacing: 8,
      children: [
        _link('커뮤니티 원문', c['url']),
        _link('활동 근거', c['evidenceUrl']),
        _link('규칙 근거', c['rulesUrl']),
        OutlinedButton(
          onPressed: busy ? null : () => _review(c),
          child: const Text('채택·규칙 검토'),
        ),
      ],
    ),
  ]);
  String _draftText(Map<String, dynamic> d) =>
      '${d['title']}\n\n${d['nucleus']}\n\n${d['communityPost']}\n\n${(d['channelAssets'] as List? ?? []).map((a) => '${a['channel']}\n${a['copy']}').join('\n\n')}\n\n출처: ${d['candidateUrl']}';
  Future<void> _record(Map<String, dynamic> d) async {
    final url = TextEditingController(text: '${d['publishedUrl'] ?? ''}');
    final note = TextEditingController(text: '${d['resultNote'] ?? ''}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('직접 게시한 결과 기록'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: url,
                decoration: const InputDecoration(labelText: '게시물 HTTPS 주소'),
              ),
              TextField(
                controller: note,
                maxLines: 3,
                maxLength: 1500,
                decoration: const InputDecoration(
                  labelText: '관측 기간과 반응·가입 등 확인한 결과',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('기록'),
          ),
        ],
      ),
    );
    final payload = {
      'id': d['id'],
      'publishedUrl': url.text,
      'note': note.text,
    };
    url.dispose();
    note.dispose();
    if (ok == true && mounted) await _act('RESULT', payload);
  }

  Widget _draft(Map<String, dynamic> d) => _card([
    Text(
      '${d['title'] ?? '생성 중인 캠페인'}',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    Text('${d['language']} · ${label(d['status'])} · 외부 자동 게시 OFF'),
    if (d['approvalExpired'] == true)
      const Text('후보 규칙이 바뀌거나 검토가 만료되어 다시 확인해야 합니다.'),
    SelectableText('${d['nucleus'] ?? ''}'),
    Text('서비스 연결 이유: ${d['fusionReason'] ?? ''}'),
    ExpansionTile(
      title: const Text('커뮤니티와 채널별 초안 보기'),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SelectableText(_draftText(d)),
        ),
      ],
    ),
    Text('다음 행동: ${(d['nextSteps'] as List? ?? []).join(' / ')}'),
    if ('${d['publishedUrl'] ?? ''}'.isNotEmpty) ...[
      _link('직접 게시한 글', d['publishedUrl']),
      Text('${d['resultNote'] ?? ''}'),
    ],
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: _draftText(d)));
            if (mounted)
              setState(() {
                message = '초안을 복사했습니다. 게시 전 최신 규칙과 사실을 확인하세요.';
              });
          },
          child: const Text('전체 초안 복사'),
        ),
        FilledButton(
          onPressed: busy
              ? null
              : () =>
                    _act('REVIEW_DRAFT', {'id': d['id'], 'status': 'approved'}),
          child: const Text('사용 승인'),
        ),
        OutlinedButton(
          onPressed: busy
              ? null
              : () => _act('REVIEW_DRAFT', {'id': d['id'], 'status': 'held'}),
          child: const Text('보류'),
        ),
        TextButton(
          onPressed: busy ? null : () => _record(d),
          child: const Text('게시·반응 기록'),
        ),
      ],
    ),
    const Text('승인은 자동 게시를 실행하지 않습니다. 후보 채택과 최근 규칙 확인이 선행되어야 합니다.'),
  ]);
  Widget _run(Map<String, dynamic> r) => _card([
    Text('${date(r['startedAt'])} · ${label(r['status'])}'),
    Text(
      '검색 ${r['pair']?['field'] ?? ''} / ${r['pair']?['market'] ?? ''} · 후보 ${r['candidateCount'] ?? 0}개',
    ),
    if (r['error'] != null) Text('오류: ${r['error']}'),
    if ('${r['draftError'] ?? ''}'.isNotEmpty)
      Text('초안 오류: ${r['draftError']}'),
    ExpansionTile(
      title: const Text('검색 기록과 출처'),
      children: [
        SelectableText('${r['researchNote'] ?? ''}'),
        ...(r['sources'] as List? ?? []).map(
          (s) => _link('${s['title']}', s['url']),
        ),
      ],
    ),
  ]);
  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData.light(useMaterial3: true)
        .copyWith(scaffoldBackgroundColor: const Color(0xFFF3F5F9)),
    child: Scaffold(
      appBar: AppBar(
        title: const Text('지속 발굴 · 핵융합 마케팅'),
        actions: [
          IconButton(
            onPressed: busy ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '분야·국가 순환 검색 → 출처 확인 → 관련 서비스 캠페인 초안 → 관리자 검토',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '공개 웹 조사만 수행합니다. AI의 활동일·규칙 판단은 원문 검토가 필요합니다. 계정 로그인·DM·외부 자동 게시 기능은 연결되어 있지 않습니다.',
                ),
                if (busy) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                  const Text(
                    '처리 중입니다. 검색은 수 분 걸릴 수 있습니다. 요청이 끊겨도 서버가 실행 중일 수 있으니 새로고침으로 기록을 확인하세요.',
                  ),
                ],
                if (message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      message,
                      style: const TextStyle(color: Color(0xFF8A3000)),
                    ),
                  ),
                if (data != null) ...[
                  _card([
                    Text(
                      '자동 발굴: ${settings['enabled'] == true ? '켜짐' : '꺼짐'} / 오늘 실행 ${data!['runtime']['count'] ?? 0}회 (기준일 ${data!['runtime']['day'] ?? '없음'})',
                    ),
                    Text('다음 실행 예정: ${date(data!['runtime']['nextRunAt'])}'),
                    const Text(
                      '서버는 매시간 설정을 확인합니다. 목록은 최근 후보 40개·초안 30개·실행 15개까지 표시합니다.',
                    ),
                  ]),
                  _config(),
                  _title('발굴 후보'),
                  Wrap(
                    spacing: 8,
                    children: {'all': '전체', ...fieldNames}.entries
                        .map(
                          (e) => ChoiceChip(
                            label: Text(e.value),
                            selected: filter == e.key,
                            onSelected: (_) => setState(() {
                              filter = e.key;
                            }),
                          ),
                        )
                        .toList(),
                  ),
                  if (rows('candidates').isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('아직 후보가 없습니다. 설정을 저장하고 지금 1회 발굴을 실행하세요.'),
                    ),
                  ...rows('candidates')
                      .where(
                        (c) =>
                            filter == 'all' ||
                            (c['fields'] as List? ?? [c['field']]).contains(
                              filter,
                            ),
                      )
                      .map(_candidate),
                  _title('융합 캠페인 초안'),
                  ...rows('drafts').map(_draft),
                  _title('실행 기록'),
                  ...rows('runs').map(_run),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
