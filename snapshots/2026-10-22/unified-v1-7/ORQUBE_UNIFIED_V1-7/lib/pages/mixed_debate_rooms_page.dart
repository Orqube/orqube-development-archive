import '../widgets/dark_control_theme.dart';
import 'dart:async';
import '../services/debate_effects.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

import '../services/mixed_debate_service.dart';
import '../services/mixed_debate_voice.dart';
import '../services/debate_recorder.dart';

class MixedDebateRoomsPage extends StatefulWidget {
  final String? initialRoomId, inviteToken;
  const MixedDebateRoomsPage({super.key, this.initialRoomId, this.inviteToken});
  @override
  State<MixedDebateRoomsPage> createState() => _MixedDebateRoomsPageState();
}

class _MixedDebateRoomsPageState extends State<MixedDebateRoomsPage> {
  final _name = TextEditingController(),
      _topic = TextEditingController(),
      _code = TextEditingController(),
      _text = TextEditingController();
  final _voice = MixedDebateVoice(), _recorder = DebateRecorder();
  String _roomId = '', _visibility = 'public';
  int _minutes = 10;
  bool _busy = false,
      _driving = false,
      _subtitles = true,
      _voiceEnabled = true,
      _closing = false;
  double _volume = 1, _previousVolume = 1;
  int? _active;
  Map<String, dynamic>? _room;
  List<Map<String, dynamic>> _messages = [], _rooms = [];
  List<Map<String, dynamic>> _profiles = List.generate(
    4,
    (i) => {
      'name': i == 3 ? '진행자' : '패널 ${i + 1}',
      'type': 'ai',
      'uid': '',
      'gender': 'male',
      'appearance': '',
      'personality': '',
      'speakingStyle': '',
      'ideology': '',
      'imageMode': 'upload',
      'imageBase64': '',
    },
  );
  StreamSubscription? _roomSub, _messageSub, _authSub;
  String _accountUid = '';
  Timer? _clock;
  int _epoch = 0, _seenSequence = 0;
  String _summaryPlayed = '';
  bool _playing = false;
  final List<Map<String, dynamic>> _playQueue = [];
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _host => _room?['ownerUid'] == _uid;
  bool get _live => _room?['status'] == 'live';
  int get _remaining {
    final end = _room?['endAt'] as Timestamp?;
    return end == null
        ? _minutes * 60
        : end
              .toDate()
              .difference(DateTime.now())
              .inSeconds
              .clamp(0, 1800)
              .toInt();
  }

  @override
  void initState() {
    super.initState();
    _accountUid = _uid;
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user?.uid == _accountUid) return;
      _accountUid = user?.uid ?? '';
      if (_recorder.recording) {
        try {
          await _recorder.stop();
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _room = null;
          _rooms.clear();
        });
        await _leave();
        if (mounted) setState(() {});
      }
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
        unawaited(_drive());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialRoomId != null && _uid.isNotEmpty) {
        unawaited(_join(widget.initialRoomId!, widget.inviteToken));
      } else {
        unawaited(_refresh());
      }
    });
  }

  @override
  void dispose() {
    _epoch++;
    _clock?.cancel();
    _authSub?.cancel();
    _roomSub?.cancel();
    _messageSub?.cancel();
    _voice.stop();
    if (_recorder.recording) unawaited(_recorder.stop().catchError((_) => ''));
    for (final c in [_name, _topic, _code, _text]) {
      c.dispose();
    }
    DebateEffects.stop();
    super.dispose();
  }

  void _notice(Object e) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
  }

  Future<Map<String, dynamic>> _call(
    String action,
    Map<String, dynamic> data, {
    String function = 'manageMixedDebateRoom',
  }) => MixedDebateService.call(action, {
    'roomId': _roomId,
    ...data,
  }, function: function);
  Future<void> _refresh() async {
    if (_uid.isEmpty) return;
    try {
      final r = await _call('list', {});
      if (mounted)
        setState(
          () => _rooms = (r['rooms'] as List)
              .map((x) => Map<String, dynamic>.from(x as Map))
              .toList(),
        );
    } catch (e) {
      _notice(e);
    }
  }

  Future<void> _guard(Future<void> Function() fn) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await fn();
    } catch (e) {
      _notice(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() async {
    await _guard(() async {
      final r = await _call('create', {
        'name': _name.text,
        'topic': _topic.text,
        'minutes': _minutes,
        'visibility': _visibility,
        'profiles': _profiles,
      });
      await _enter('${r['roomId']}');
    });
  }

  Future<void> _join(String code, [String? token]) async {
    await _guard(() async {
      String roomId = code.trim();
      String? invite = token;
      final uri = Uri.tryParse(roomId);
      if (uri != null && uri.queryParameters.containsKey('debateRoom')) {
        roomId = uri.queryParameters['debateRoom']!;
        invite = uri.queryParameters['invite'];
      }
      await _call('join', {'roomId': roomId, 'inviteToken': invite ?? ''});
      await _enter(roomId);
    });
  }

  Future<void> _enter(String id) async {
    _epoch++;
    _voice.stop();
    _playQueue.clear();
    _playing = false;
    await _roomSub?.cancel();
    await _messageSub?.cancel();
    if (!mounted) return;
    setState(() {
      _roomId = id;
      _room = null;
      _messages = [];
      _seenSequence = 0;
      _summaryPlayed = '';
      _closing = false;
    });
    final ref = FirebaseFirestore.instance
        .collection('mixed_debate_rooms')
        .doc(id);
    final epoch = _epoch;
    _roomSub = ref.snapshots().listen((doc) {
      if (!mounted || epoch != _epoch) return;
      final r = doc.data();
      if (r == null) return;
      setState(() {
        _room = r;
        _profiles = (r['profiles'] as List)
            .map((x) => Map<String, dynamic>.from(x as Map))
            .toList();
      });
      if (r['status'] == 'ended' &&
          '${r['summary'] ?? ''}'.isNotEmpty &&
          _summaryPlayed != r['summarySessionId']) {
        _summaryPlayed = '${r['summarySessionId']}';
        _voice.stop();
        _playQueue.clear();
        _playQueue.add({
          'panel': 3,
          'text': r['summary'],
          'sessionId': r['summarySessionId'],
        });
        unawaited(_play(epoch));
      }
    }, onError: (Object e) => _notice('방 조회 실패: $e'));
    bool initial = true;
    _messageSub = ref
        .collection('messages')
        .orderBy('sequence', descending: true)
        .limit(200)
        .snapshots()
        .listen((snap) {
          if (!mounted || epoch != _epoch) return;
          final list = snap.docs.reversed.map((d) => d.data()).toList();
          setState(() => _messages = list);
          for (final m in list) {
            final seq = (m['sequence'] as num).toInt();
            if (seq > _seenSequence) {
              _seenSequence = seq;
              if (!initial) _playQueue.add(m);
            }
          }
          initial = false;
          unawaited(_play(epoch));
        }, onError: (Object e) => _notice('발언 조회 실패: $e'));
  }

  Future<void> _play(int epoch) async {
    if (_playing) return;
    _playing = true;
    try {
      while (mounted && epoch == _epoch && _playQueue.isNotEmpty) {
        final m = _playQueue.removeAt(0);
        final panel = (m['panel'] as num).toInt();
        setState(() => _active = panel);
        if (_voiceEnabled) {
          final ok = await _voice.speak(
            '${m['text']}',
            panelIndex: panel,
            sessionId: '${m['sessionId']}',
          );
          if (!ok) _notice('음성 재생: ${_voice.lastError}');
        } else {
          await Future<void>.delayed(
            Duration(milliseconds: 1000 + '${m['text']}'.length * 30),
          );
        }
        if (mounted && epoch == _epoch) await DebateEffects.play('${m['stage']}');
      }
    } finally {
      if (epoch == _epoch) {
        _playing = false;
        if (mounted) setState(() => _active = null);
      }
    }
  }

  DateTime? _nextGeneration;
  Future<void> _drive() async {
    if (!_host || _closing) return;
    if (_room?['status'] == 'closing') {
      if ((_room?['generatingUntil'] as Timestamp?)?.toDate().isAfter(
            DateTime.now(),
          ) !=
          true)
        await _finish();
      return;
    }
    if (!_live) return;
    if (_remaining == 0) {
      await _finish();
      return;
    }
    if (_driving || _busy) return;
    if (_playing || _playQueue.isNotEmpty) return;
    _driving = true;
    final epoch = _epoch;
    try {
      final pending = _room?['pending'] as List? ?? [];
      if (pending.isNotEmpty) {
        await _call('publish', {'sequence': _room!['sequence']});
      } else if (_profiles.any((p) => p['type'] == 'ai') &&
          (_nextGeneration == null ||
              DateTime.now().isAfter(_nextGeneration!))) {
        _nextGeneration = DateTime.now().add(const Duration(seconds: 12));
        await _call('generate', {}, function: 'generateMixedDebate');
      }
    } catch (e) {
      if (epoch == _epoch) {
        _nextGeneration = DateTime.now().add(const Duration(seconds: 15));
        _notice(e);
      }
    } finally {
      _driving = false;
    }
  }

  Future<void> _finish() async {
    if (_closing || !_host) return;
    setState(() => _closing = true);
    try {
      await _call('summary', {
        'summarize': true,
      }, function: 'generateMixedDebate');
    } catch (e) {
      _notice('최종 요약 실패: $e · 종료·요약 버튼으로 재시도하세요.');
    } finally {
      if (mounted) setState(() => _closing = false);
    }
  }

  Future<void> _send(bool question) async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    await Future.wait([DebateEffects.unlock(), _voice.unlock()]);
    await _guard(() async {
      await _call(question ? 'question' : 'send', {
        'text': text,
        'requestId': '${_uid}_${DateTime.now().microsecondsSinceEpoch}',
      });
      _text.clear();
    });
  }

  Future<void> _record() async {
    await _guard(() async {
      if (_recorder.recording) {
        final file = await _recorder.stop();
        _notice('녹화 파일 다운로드: $file');
        if (_host) await _call('recording', {'filename': file});
      } else {
        _notice(await _recorder.start());
      }
    });
  }

  String _compress(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('JPG·PNG·WEBP 사진을 선택하세요.');
    final resized = img.copyResize(decoded, width: 384);
    for (final quality in [80, 65, 45, 25]) {
      final jpeg = img.encodeJpg(resized, quality: quality);
      if (jpeg.length <= 150000) return base64Encode(jpeg);
    }
    throw Exception('사진 용량을 줄여 다시 선택하세요.');
  }

  Future<void> _edit(int index) async {
    if (!_host || _room?['status'] != 'waiting') return;
    final draft = Map<String, dynamic>.from(_profiles[index]);
    bool processing = false;
    String? error;
    final controllers = {
      for (final key in [
        'name',
        'appearance',
        'personality',
        'speakingStyle',
        'ideology',
      ])
        key: TextEditingController(text: '${draft[key] ?? ''}'),
    };
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, change) {
          Widget field(
            String key,
            String label, {
            int lines = 1,
            int max = 600,
          }) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: controllers[key],
              maxLines: lines,
              maxLength: max,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          );
          Future<void> photo(bool generate) async {
            if (processing) return;
            change(() => processing = true);
            try {
              Uint8List? bytes;
              if (generate) {
                final r = await _call('portrait', {
                  'panel': index,
                  'appearance': controllers['appearance']!.text,
                }, function: 'generateMixedDebatePortrait');
                bytes = base64Decode('${r['imageBase64']}');
              } else {
                final r = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  withData: true,
                );
                if (r == null) return;
                bytes = r.files.single.bytes;
                if (bytes == null) throw Exception('사진을 읽지 못했습니다.');
                if (bytes.length > 10000000)
                  throw Exception('10MB 이하 사진을 선택하세요.');
              }
              draft['imageBase64'] = _compress(bytes);
              change(() => error = null);
            } catch (e) {
              change(() => error = '$e');
            } finally {
              change(() => processing = false);
            }
          }

          final members = Map<String, dynamic>.from(
            _room?['members'] as Map? ?? {},
          );
          return AlertDialog(
            title: Text(index == 3 ? '진행자 설정' : '패널 ${index + 1} 설정'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    field('name', '화면에 표시할 별칭', max: 40),
                    DropdownButtonFormField<String>(
                      value: draft['type'] as String,
                      decoration: const InputDecoration(labelText: '사람 / AI'),
                      items: const [
                        DropdownMenuItem(
                          value: 'ai',
                          child: Text('AI · 자동 발언'),
                        ),
                        DropdownMenuItem(
                          value: 'human',
                          child: Text('사람 · 직접 글 입력'),
                        ),
                      ],
                      onChanged: processing
                          ? null
                          : (v) => change(() => draft['type'] = v),
                    ),
                    if (draft['type'] == 'human')
                      DropdownButtonFormField<String>(
                        value: members.containsKey(draft['uid'])
                            ? draft['uid'] as String
                            : '',
                        decoration: const InputDecoration(
                          labelText: '입장한 참가자 지정',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('참가자 선택'),
                          ),
                          ...members.entries.map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text('${(e.value as Map)['name']}'),
                            ),
                          ),
                        ],
                        onChanged: processing
                            ? null
                            : (v) => change(() => draft['uid'] = v),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: draft['gender'] as String,
                      decoration: const InputDecoration(labelText: '합성 음성'),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('남성')),
                        DropdownMenuItem(value: 'female', child: Text('여성')),
                      ],
                      onChanged: processing
                          ? null
                          : (v) => change(() => draft['gender'] = v),
                    ),
                    const SizedBox(height: 12),
                    field(
                      'appearance',
                      '인물 묘사 · 나이대, 외모, 머리·수염, 옷차림, 표정',
                      lines: 3,
                      max: 1000,
                    ),
                    DropdownButtonFormField<String>(
                      value: draft['imageMode'] as String,
                      decoration: const InputDecoration(
                        labelText: '프로필 이미지 방식',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'upload',
                          child: Text('직접 사진 올리기'),
                        ),
                        DropdownMenuItem(
                          value: 'generate',
                          child: Text('묘사로 AI 이미지 생성'),
                        ),
                      ],
                      onChanged: processing
                          ? null
                          : (v) => change(() => draft['imageMode'] = v),
                    ),
                    const SizedBox(height: 8),
                    if ('${draft['imageBase64']}'.isNotEmpty)
                      Image.memory(
                        base64Decode('${draft['imageBase64']}'),
                        height: 150,
                      ),
                    TextButton.icon(
                      onPressed: processing
                          ? null
                          : () => photo(draft['imageMode'] == 'generate'),
                      icon: const Icon(Icons.portrait),
                      label: Text(
                        draft['imageMode'] == 'generate'
                            ? 'AI 이미지 생성 (API 요금 발생)'
                            : '사진 선택',
                      ),
                    ),
                    if (processing) const LinearProgressIndicator(),
                    if (error != null)
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    field('personality', '성격 · 차분함, 직설적, 유머 등', lines: 2),
                    field('speakingStyle', '언변 · 짧은 반문, 논리적 설명 등', lines: 2),
                    field('ideology', '관점·이념 성향 (AI 발언에 적용)', lines: 2),
                    const Text(
                      '외모는 이미지에만 적용합니다. 사람의 발언은 AI가 대신 만들지 않습니다. 사람의 글도 선택한 합성 음성으로 읽습니다. 실제 마이크 통화는 포함되지 않습니다.',
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: processing
                    ? null
                    : () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: processing
                    ? null
                    : () => Navigator.pop(context, true),
                child: const Text('저장'),
              ),
            ],
          );
        },
      ),
    );
    if (saved == true && mounted) {
      for (final entry in controllers.entries) {
        draft[entry.key] = entry.value.text;
      }
      final ps = _profiles.map((p) => Map<String, dynamic>.from(p)).toList();
      ps[index] = draft;
      await _guard(() async {
        await _call('configure', {'profiles': ps});
      });
    }
    for (final c in controllers.values) {
      c.dispose();
    }
  }

  Future<void> _leave() async {
    if (_recorder.recording) {
      _notice('녹화를 종료·저장한 뒤 이동하세요.');
      return;
    }
    _epoch++;
    _voice.stop();
    _playQueue.clear();
    await _roomSub?.cancel();
    await _messageSub?.cancel();
    if (mounted)
      setState(() {
        _roomId = '';
        _room = null;
        _nextGeneration = null;
      });
    await _refresh();
  }

  String _label(int panel) =>
      panel == 4 ? '시민패널' : '${_profiles[panel]['name']}';
  Widget _photo(int panel, {double height = 160}) {
    final b64 = '${_profiles[panel]['imageBase64'] ?? ''}';
    return b64.isEmpty
        ? SizedBox(
            height: height,
            child: Center(
              child: Icon(
                panel == 3 ? Icons.record_voice_over : Icons.person,
                size: height * .55,
                color: Colors.white38,
              ),
            ),
          )
        : Image.memory(
            base64Decode(b64),
            height: height,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          );
  }

  Widget _input(TextEditingController c, String label, {int lines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          maxLines: lines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            border: const OutlineInputBorder(),
          ),
        ),
      );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_recorder.recording,
    child: Theme(
      data: darkControlTheme(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1727),
        appBar: AppBar(
          title: Text(_room?['name'] ?? '사람 + AI 토론방 BETA'),
          actions: [
            if (_roomId.isNotEmpty)
              TextButton(onPressed: _leave, child: const Text('방 목록')),
          ],
        ),
        body: _uid.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('ORQUBE 계정으로 로그인한 뒤 입장하세요.'),
                    TextButton(
                      onPressed: () => Navigator.maybePop(context),
                      child: const Text('홈으로 돌아가기'),
                    ),
                  ],
                ),
              )
            : _roomId.isEmpty
            ? _lobby()
            : _room == null
            ? const Center(child: CircularProgressIndicator())
            : _dashboard(),
      ),
    ),
  );
  Widget _lobby() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        '기존 3자 토론과 별도로 방을 만듭니다. 진행자 1명·패널 3명을 사람 또는 AI로 선택하세요.',
        style: TextStyle(fontSize: 18),
      ),
      const SizedBox(height: 18),
      _input(_name, '방 이름'),
      _input(_topic, '토론 주제', lines: 2),
      DropdownButtonFormField<int>(
        value: _minutes,
        decoration: const InputDecoration(labelText: '전체 시간'),
        items: [
          1,
          3,
          5,
          10,
          20,
          30,
        ].map((i) => DropdownMenuItem(value: i, child: Text('$i분'))).toList(),
        onChanged: (v) => setState(() => _minutes = v ?? 10),
      ),
      DropdownButtonFormField<String>(
        value: _visibility,
        decoration: const InputDecoration(labelText: '공개 범위'),
        items: const [
          DropdownMenuItem(value: 'public', child: Text('공개방 · 로그인 회원 누구나 입장')),
          DropdownMenuItem(value: 'private', child: Text('비공개방 · 초대 링크로만 입장')),
        ],
        onChanged: (v) => setState(() => _visibility = v ?? 'public'),
      ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _busy ? null : _create,
        child: const Text('방 만들기 · 프로필 설정'),
      ),
      const SizedBox(height: 24),
      _input(_code, '방 코드 또는 초대 링크'),
      FilledButton(
        onPressed: _busy ? null : () => _join(_code.text),
        child: const Text('입장'),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          const Expanded(
            child: Text('내 토론방 · 공개 토론방', style: TextStyle(fontSize: 18)),
          ),
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      ..._rooms.map(
        (r) => Card(
          child: ListTile(
            title: Text('${r['name']}'),
            subtitle: Text(
              '${r['topic']}\n${r['visibility'] == 'private' ? '비공개' : '공개'} · ${r['minutes']}분 · ${r['status']}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _join('${r['id']}'),
          ),
        ),
      ),
      if (_busy) const LinearProgressIndicator(),
    ],
  );
  Widget _dashboard() {
    final r = _room!;
    final people = Map<String, dynamic>.from(r['members'] as Map? ?? {});
    final mySeat = _profiles.indexWhere(
      (p) => p['type'] == 'human' && p['uid'] == _uid,
    );
    final stage = LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth < 600
            ? (c.maxWidth - 12) / 2
            : (c.maxWidth - 36) / 4;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [0, 1, 3, 2]
              .map(
                (i) => SizedBox(
                  width: width,
                  child: Card(
                    color: _active == i
                        ? const Color(0xFF365366)
                        : const Color(0xFF142B40),
                    child: Column(
                      children: [
                        _photo(i, height: c.maxWidth < 600 ? 135 : 200),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '${_label(i)} · ${_profiles[i]['type'] == 'ai' ? 'AI' : '사람'}${_active == i ? ' · 발언 중' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_host && r['status'] == 'waiting')
                          TextButton(
                            onPressed: _busy ? null : () => _edit(i),
                            child: const Text('프로필 설정'),
                          ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${r['topic']}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${r['visibility'] == 'private' ? '비공개방' : '공개방'} · ${r['minutes']}분 · 남은 시간 ${_remaining ~/ 60}:${(_remaining % 60).toString().padLeft(2, '0')} · ${r['status']}',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TextButton.icon(
              onPressed: () async {
                final link = Uri.base
                    .replace(
                      path: '/',
                      fragment: '',
                      queryParameters: {
                        'debateRoom': _roomId,
                        if (r['visibility'] == 'private')
                          'invite': '${r['inviteToken']}',
                      },
                    )
                    .toString();
                await Clipboard.setData(ClipboardData(text: link));
                _notice('초대 링크 복사 완료');
              },
              icon: const Icon(Icons.link),
              label: const Text('초대 링크 복사'),
            ),
            if (_host && r['status'] == 'waiting')
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => _guard(() async {
                        await Future.wait([DebateEffects.unlock(), _voice.unlock()]);
                        await _call('start', {});
                      }),
                child: const Text('토론 시작'),
              ),
            if (_host && (r['status'] == 'live' || r['status'] == 'closing'))
              FilledButton(
                onPressed: _closing ? null : _finish,
                child: Text(_closing ? '최종 요약 중…' : '종료·최종 음성 요약'),
              ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _record,
              icon: Icon(
                _recorder.recording
                    ? Icons.stop_circle
                    : Icons.fiber_manual_record,
                color: Colors.redAccent,
              ),
              label: Text(_recorder.recording ? '녹화 종료·저장' : '녹화 시작'),
            ),
            TextButton(
              onPressed: () async {
                await Future.wait([DebateEffects.unlock(), _voice.unlock()]);
                _notice('음성 재생을 활성화했습니다.');
              },
              child: const Text('음성 활성화'),
            ),
          ],
        ),
Wrap(spacing: 8, children: [
          FilterChip(label: const Text('풍자·개그 v2'), selected: DebateEffects.comedy,
            onSelected: (v) => setState(() { DebateEffects.comedy = v; if (!v) DebateEffects.stop(); })),
          FilterChip(label: const Text('군중 웃음·효과음'), selected: DebateEffects.enabled,
            onSelected: (v) => setState(() { DebateEffects.enabled = v; if (!v) DebateEffects.stop(); })),
          TextButton(onPressed: () => DebateEffects.preview('웃음'), child: const Text('웃음 미리듣기')),
          TextButton(onPressed: () => DebateEffects.preview('박수'), child: const Text('박수 미리듣기')),
        ]),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (_volume > 0) {
                    _previousVolume = _volume;
                    _volume = 0;
                  } else {
                    _volume = _previousVolume;
                  }
                });
                _voice.setVolume(_volume); DebateEffects.setVolume(_volume);
              },
              icon: Icon(_volume == 0 ? Icons.volume_off : Icons.volume_up),
            ),
            Text('음량 ${(_volume * 100).round()}%'),
            Expanded(
              child: Slider(
                value: _volume,
                onChanged: (v) {
                  setState(() => _volume = v);
                  _voice.setVolume(v); DebateEffects.setVolume(v);
                },
              ),
            ),
          ],
        ),
        Wrap(
          children: [
            FilterChip(
              label: const Text('자막'),
              selected: _subtitles,
              onSelected: (v) => setState(() => _subtitles = v),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('음성'),
              selected: _voiceEnabled,
              onSelected: (v) {
                setState(() => _voiceEnabled = v);
                if (!v) _voice.stop();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '방장 ${people[r['ownerUid']]?['name'] ?? ''} · 참가자 ${people.length}명 · 내 역할 ${_host
              ? '방장'
              : mySeat == 3
              ? '진행자'
              : mySeat >= 0
              ? '패널'
              : '관람자'}',
        ),
        if (_host && r['status'] == 'live')
          const Text(
            '방장 화면을 열어 두면 AI 토론이 이어집니다. 관람 화면도 음성 활성화를 눌러주세요.',
            style: TextStyle(color: Colors.white60),
          ),
        ExpansionTile(
          title: const Text('참가자 · 권한'),
          children: people.entries
              .map(
                (e) => ListTile(
                  title: Text('${(e.value as Map)['name']}'),
                  subtitle: Text(
                    e.key == r['ownerUid']
                        ? '방장 · 설정/시작/종료'
                        : _profiles.any(
                            (p) => p['type'] == 'human' && p['uid'] == e.key,
                          )
                        ? '사람 좌석 · 발언/시민 질문'
                        : '관람자 · 시민 질문',
                  ),
                ),
              )
              .toList(),
        ),
        if (_busy || _driving || _closing) const LinearProgressIndicator(),
      ],
    );
    final chat = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '대화 기록 · 자막',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 420,
          child: ListView(
            reverse: true,
            children: _messages.reversed
                .map(
                  (m) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_label((m['panel'] as num).toInt())} · ${m['stage']}',
                            style: const TextStyle(color: Colors.amberAccent),
                          ),
                          if (_subtitles) SelectableText('${m['text']}'),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if ('${r['summary'] ?? ''}'.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '최종 요약',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText('${r['summary']}'),
                  TextButton(
                    onPressed: () async {
                      await Future.wait([DebateEffects.unlock(), _voice.unlock()]);
                      _playQueue.add({
                        'panel': 3,
                        'text': r['summary'],
                        'sessionId': r['summarySessionId'],
                      });
                      await _play(_epoch);
                    },
                    child: const Text('최종 요약 다시 읽기'),
                  ),
                ],
              ),
            ),
          ),
        _input(_text, mySeat >= 0 ? '내 발언 또는 시민 질문' : '시민 질문', lines: 2),
        Wrap(
          spacing: 8,
          children: [
            if (mySeat >= 0)
              FilledButton(
                onPressed: _live && _remaining > 0 && !_busy
                    ? () => _send(false)
                    : null,
                child: const Text('내 발언 등록'),
              ),
            OutlinedButton(
              onPressed: _live && _remaining > 0 && !_busy
                  ? () => _send(true)
                  : null,
              child: const Text('시민 질문 등록'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ExpansionTile(
          title: const Text('방별 녹화 파일 기록'),
          children: [
            const Text('영상은 녹화한 기기에 다운로드됩니다. 여기에는 파일명과 저장 시간을 기록합니다.'),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('mixed_debate_rooms')
                  .doc(_roomId)
                  .collection('recordings')
                  .snapshots(),
              builder: (c, s) => s.hasError
                  ? Text('녹화 기록 조회 실패: ${s.error}')
                  : Column(
                      children: (s.data?.docs ?? [])
                          .map(
                            (d) => ListTile(
                              title: Text('${d.data()['filename']}'),
                              subtitle: Text(
                                '${(d.data()['createdAt'] as Timestamp?)?.toDate().toLocal() ?? ''}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 1000
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [stage, const SizedBox(height: 16), controls],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [chat],
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                stage,
                const SizedBox(height: 12),
                controls,
                const SizedBox(height: 16),
                chat,
              ],
            ),
    );
  }
}
