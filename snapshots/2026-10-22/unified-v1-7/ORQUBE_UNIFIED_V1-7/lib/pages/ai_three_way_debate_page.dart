import '../services/admin_access.dart';
import '../widgets/dark_control_theme.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/debate_visual.dart';
import '../widgets/debate_visual_board.dart';
import '../services/debate_recorder.dart';
import 'live_debate_room_page.dart';
import '../widgets/debate_character.dart';
import '../services/email_verification_dialog.dart';
import '../services/debate_api_service.dart';
import 'dart:async';
import '../services/debate_effects.dart';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../services/debate_voice.dart';

class AiThreeWayDebatePage extends StatefulWidget {
  final bool presentation;
  const AiThreeWayDebatePage({super.key, this.presentation = false});

  @override
  State<AiThreeWayDebatePage> createState() => _AiThreeWayDebatePageState();
}

class _AiThreeWayDebatePageState extends State<AiThreeWayDebatePage> {
  late final Future<bool> _adminAccess = AdminAccess.allowed();

  static const _bg = Color(0xFF071322);
  static const _lime = Color(0xFFFFD34F);
  static const _purple = Color(0xFF9B5CFF);
  static const _cyan = Color(0xFF55E6FF);

  final _topicController = TextEditingController();
  final _questionController = TextEditingController();
  final _voice = DebateVoice();
  final _recorder = DebateRecorder();
  bool _recording = false;
  bool _recordBusy = false;
  Timer? _recordMonitor;
  final _scrollController = ScrollController();

  final List<_DebateLine> _lines = [];
  Timer? _timer;
  int _durationMinutes = 3;
  int _remainingSeconds = 180;
  bool _running = false;
  bool _voiceEnabled = true;
  double _volume = 1.0;
  double _previousVolume = 1.0;
  bool _summarySpeaking = false;
  String _summarySessionId = '';
  bool _subtitlesEnabled = true;
  bool _summaryReady = false;
  bool _summaryRequested = false;
  bool _busy = false;
  bool _speaking = false;
  String? _queuedQuestion;
  DateTime? _lastGenerationAt;
  DateTime? _deadline;
  Future<Map<String, dynamic>?>? _nextBatch;
  String _nextQuestion = '';
  Object? _nextError;
  int _retryCount = 0;
  int? _activePanel;
  int _generation = 0;
  String _summary = '';
  List<String> _checks = [];
  final List<_DebateLine> _pending = [];

  List<DebateVisual> _visuals = List.of(DebateVisual.defaults);
  int _visualIndex = 0;
  bool _autoVisual = true;
  bool _visualFocus = false;
  bool _visualLoading = false;
  String _visualStorageKey = '';
  List<DebateVisual> _sessionVisuals = [];

  @override
  void initState() {
    super.initState();
    if (widget.presentation) {
      _topicController.text = 'ORQUBE의 기능과 미래: 안심산행·자동 토큰 생성·QR 보상·실사용 방향';
      _visualStorageKey = 'orqube_visual_debate_v1_${FirebaseAuth.instance.currentUser?.uid ?? "guest"}';
      _visualLoading = true;
      unawaited(_loadVisuals());
    }
  }

  Future<void> _loadVisuals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_visualStorageKey);
      if (raw != null) {
        final decoded = (jsonDecode(raw) as List).map((x) =>
          DebateVisual.fromJson(Map<String, dynamic>.from(x as Map))).toList();
        if (decoded.isNotEmpty && decoded.length <= 20 && mounted) setState(() => _visuals = decoded);
      }
    } catch (_) {
      if (mounted) _message('저장된 자료를 읽지 못해 기본 자료를 표시합니다.');
    } finally {
      if (mounted) setState(() => _visualLoading = false);
    }
  }

  Future<void> _editVisual({bool add = false}) async {
    if (_running || _busy || _summarySpeaking || _visualLoading) return;
    if (add && _visuals.length >= 20) { _message('자료는 최대 20개까지 등록할 수 있습니다.'); return; }
    final result = await editDebateVisual(context, add
      ? DebateVisual(id: 'custom_${DateTime.now().microsecondsSinceEpoch}', title: '새 자료')
      : _visuals[_visualIndex]);
    if (result == null || !mounted) return;
    final next = List<DebateVisual>.of(_visuals);
    if (add) { next.add(result); } else { next[_visualIndex] = result; }
    await _saveVisuals(next, add ? next.length - 1 : _visualIndex);
  }

  Future<void> _saveVisuals(List<DebateVisual> next, int index) async {
    setState(() => _visualLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(next.map((x) => x.toJson()).toList());
      if (raw.length > 6 * 1024 * 1024) throw Exception('자료 전체 용량은 6MB 이하로 줄여주세요.');
      if (!await prefs.setString(_visualStorageKey, raw)) throw Exception('저장 실패');
      if (mounted) setState(() { _visuals = next; _visualIndex = index; });
    } catch (e) {
      if (mounted) _message('자료를 저장하지 못했습니다: $e');
    } finally {
      if (mounted) setState(() => _visualLoading = false);
    }
  }

  Future<Map<String, dynamic>> _generate(String topic, String question,
    List<Map<String, dynamic>> history, {bool summarize = false}) =>
    DebateApiService.generate(topic, question, history, summarize: summarize,
      presentation: widget.presentation,
      visuals: widget.presentation ? _sessionVisuals.map((x) => x.toJson(includeImage: false)).toList() : const []);

  void _followVisual(_DebateLine line) {
    if (!widget.presentation || !_autoVisual) return;
    final exact = _visuals.indexWhere((x) => x.id == line.visualId);
    if (exact >= 0) { _visualIndex = exact; return; }
    if (line.visualId == 'none') return;
    final text = line.text.toLowerCase();
    int best = 0;
    for (int i = 0; i < _visuals.length; i++) {
      final score = _visuals[i].keywords.split(',').map((k) => k.trim().toLowerCase())
        .where((k) => k.isNotEmpty && text.contains(k)).length;
      if (score > best) { best = score; _visualIndex = i; }
    }
  }

  Widget _visualStage() {
    const names = ['털보', '따불', '신사', '진행자', '시민패널'];
    final canEdit = !_running && !_busy && !_summarySpeaking && !_visualLoading;
    return Column(children: [
      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
        children: List.generate(4, (i) => Column(mainAxisSize: MainAxisSize.min, children: [
          _radioAvatar(i, _activePanel == i ? _lime : _cyan, size: 64),
          Text('${names[i]}${_activePanel == i ? " · 발언 중" : ""}',
            style: TextStyle(color: _activePanel == i ? _lime : Colors.white70)),
        ]))),
      const SizedBox(height: 12),
      DebateVisualBoard(visual: _visuals[_visualIndex],
        speaker: _activePanel == null ? '발언 대기' : names[_activePanel!],
        subtitle: !_subtitlesEnabled ? '' : _summarySpeaking ? _summary
          : _lines.isEmpty ? '' : _lines.last.text),
      const SizedBox(height: 10),
      if (!_visualFocus) Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
        FilterChip(label: const Text('발언에 맞춰 자동 전환'), selected: _autoVisual,
          onSelected: (v) => setState(() => _autoVisual = v)),
        IconButton(tooltip: '이전 자료', onPressed: () => setState(() {
          _autoVisual = false; _visualIndex = (_visualIndex - 1 + _visuals.length) % _visuals.length;
        }), icon: const Icon(Icons.chevron_left, color: Colors.white)),
        Text('${_visualIndex + 1} / ${_visuals.length}', style: const TextStyle(color: Colors.white)),
        IconButton(tooltip: '다음 자료', onPressed: () => setState(() {
          _autoVisual = false; _visualIndex = (_visualIndex + 1) % _visuals.length;
        }), icon: const Icon(Icons.chevron_right, color: Colors.white)),
        TextButton(onPressed: canEdit ? () => _editVisual() : null, child: const Text('자료 편집')),
        TextButton(onPressed: canEdit ? () => _editVisual(add: true) : null, child: const Text('새 자료')),
        TextButton(onPressed: canEdit && _visuals.length > 1 ? () async {
          final next = List<DebateVisual>.of(_visuals)..removeAt(_visualIndex);
          await _saveVisuals(next, 0);
        } : null, child: const Text('현재 자료 삭제')),
      ]),
      if (!_visualFocus) Wrap(spacing: 6, runSpacing: 4, children: _visuals.asMap().entries.map((e) => ChoiceChip(
        label: Text(e.value.title), selected: _visualIndex == e.key,
        onSelected: (_) => setState(() { _autoVisual = false; _visualIndex = e.key; }),
      )).toList()),
      if (!_visualFocus) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text(
        '자료는 이 기기·브라우저에 저장됩니다. AI는 이미지 자체가 아닌 제목·설명·상태를 참고합니다.\n녹화 시 현재 탭과 탭 오디오를 선택하고 자료 화면이 보이도록 유지해주세요.',
        style: TextStyle(color: Colors.white60, fontSize: 11))),
    ]);
  }

  @override
  void dispose() {
    _generation++;
    _recordMonitor?.cancel();
    if (_recorder.recording) unawaited(_recorder.stop().catchError((_) => ""));
    _timer?.cancel();
    _voice.stop();
    _voice.clearPrepared();
    _topicController.dispose();
    _questionController.dispose();
    _scrollController.dispose();
    DebateEffects.stop();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_recordBusy) return;
    setState(() => _recordBusy = true);
    try {
      if (_recorder.recording) {
        final name = await _recorder.stop();
        if (mounted) _message('영상 다운로드를 요청했습니다: $name');
      } else {
        final notice = await _recorder.start();
        if (mounted) _message(notice);
        _recordMonitor?.cancel();
        _recordMonitor = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          final active = _recorder.recording;
          if (_recording != active) setState(() => _recording = active);
          if (!active) _recordMonitor?.cancel();
        });
      }
    } catch (e) {
      if (mounted) _message('영상 녹화: $e');
    } finally {
      if (mounted)
        setState(() {
          _recordBusy = false;
          _recording = _recorder.recording;
        });
    }
  }

  Future<void> _start() async {
    if (_busy || _running || _speaking || _visualLoading) return;
    final topic = _topicController.text.trim();
    if (widget.presentation) _sessionVisuals = List.of(_visuals);
    if (topic.length < 2) {
      _message('토론 주제를 입력해주세요.');
      return;
    }
    setState(() => _busy = true);
    final effectsPermission = DebateEffects.unlock();
    final permission = _voice.unlock();
    final generation = ++_generation;
    await permission;
    await effectsPermission;
    if (!mounted || generation != _generation) return;
    _voice.stop();
    _voice.clearPrepared();
    _nextBatch = null;
    _nextError = null;
    _retryCount = 0;
    setState(() {
      _busy = true;
      _lines.clear();
      _pending.clear();
      _queuedQuestion = null;
      _summaryReady = false;
      _summaryRequested = false;
      _summary = '';
      _summarySessionId = '';
      _summarySpeaking = false;
    });
    try {
      _lastGenerationAt = DateTime.now();
      final result = await _generate(topic, '', []);
      if (!mounted || generation != _generation) return;
      _readResult(result);
      _message(widget.presentation ? '자료 동반형 토론 · 서버 연결 확인' : DebateEffects.comedy ? '풍자 모드 서버 적용 확인 · 군중 반응 활성화' : '일반 토론 모드');
      setState(() {
        _running = true;
        _remainingSeconds = _durationMinutes * 60;
      });
      _deadline = DateTime.now().add(Duration(minutes: _durationMinutes));
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || !_running) return;
        setState(() => _remainingSeconds = ((_deadline!.difference(DateTime.now()).inMilliseconds / 1000).ceil()).clamp(0, _durationMinutes * 60).toInt());
        if (_remainingSeconds <= 0) _finish(summarize: true);
      });
      setState(() => _busy = false);
      unawaited(_playPending(generation));
    } catch (e) {
      if (mounted) _message('토론 생성 실패: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _readResult(Map<String, dynamic> data) {
    for (final raw in data['lines'] as List) {
      final x = Map<String, dynamic>.from(raw as Map);
      final panel = (x['panel'] as num).toInt();
      if (panel >= 0 && panel <= 4)
        _pending.add(
          _DebateLine(
            panel,
            '${x['stage']}',
            '${x['text']}',
            sessionId: '${data['id'] ?? ''}',
            visualId: widget.presentation && x.containsKey('visualId') && '${x['visualId']}'.isEmpty
              ? 'none' : '${x['visualId'] ?? ''}',
          ),
        );
    }
  }

  // One future at a time. Include queued lines so the next batch answers
  // the end of this batch; it is not presented or summarized until played.
  void _prefetchBatch(int generation) {
    if (_nextBatch != null || !_running || generation != _generation) return;
    final elapsed = _lastGenerationAt == null ? 11000 : DateTime.now().difference(_lastGenerationAt!).inMilliseconds;
    if (elapsed < 11000) return;
    _nextQuestion = _queuedQuestion ?? '';
    _nextError = null;
    _lastGenerationAt = DateTime.now();
    final history = [..._history(), ..._pending.map((x) => <String, dynamic>{
      'panel': ['A', 'B', 'C', '진행자', '시민'][x.panel], 'text': x.text,
    })];
    _nextBatch = _generate(_topicController.text.trim(), _nextQuestion, history)
      .then<Map<String, dynamic>?>((data) => data, onError: (Object error) {
        if (generation == _generation) _nextError = error;
        return null;
      });
  }

  Future<void> _playPending(int generation) async {
    if (_speaking) return;
    _speaking = true;
    try {
      while (mounted && generation == _generation && _running) {
        if (_pending.isEmpty) {
          final elapsed = _lastGenerationAt == null ? 11000 : DateTime.now().difference(_lastGenerationAt!).inMilliseconds;
          if (_nextBatch == null && elapsed < 11000) await Future<void>.delayed(Duration(milliseconds: 11000 - elapsed));
          if (!mounted || generation != _generation || !_running) break;
          setState(() { _busy = true; _activePanel = null; });
          _prefetchBatch(generation);
          final requestedQuestion = _nextQuestion;
          final result = await _nextBatch!;
          if (!mounted || generation != _generation || !_running) break;
          _nextBatch = null;
          setState(() => _busy = false);
          if (result == null) {
            final error = _nextError;
            if (error is DebateRequestException && error.retryable) {
              _retryCount++;
              _message('연결 재시도 $_retryCount · 설정 시간 안에서 토론을 이어갑니다. $error');
              // Keep the question queued; the deadline timer remains active.
              await Future<void>.delayed(Duration(seconds: _retryCount < 3 ? 3 : 10));
              continue;
            }
            _message('토론 서버 확인이 필요합니다: $error');
            _finish(summarize: true);
            break;
          }
          _retryCount = 0;
          _readResult(result);
          if (requestedQuestion.isNotEmpty && _queuedQuestion == requestedQuestion) _queuedQuestion = null;
          if (_pending.isEmpty) {
            _message('빈 응답을 받아 다음 발언을 다시 요청합니다.');
            continue;
          }
        }
        final line = _pending.removeAt(0);
        bool shown = false;
        void showLine() {
          if (shown || !mounted || generation != _generation || !_running) return;
          shown = true;
          setState(() { _lines.add(line); _activePanel = line.panel; _followVisual(line); });
          _scrollToBottom();
          if (_pending.length <= 3) _prefetchBatch(generation);
        }
        if (_voiceEnabled) {
          final supported = await _voice.speak(
            line.text,
            panelIndex: line.panel,
            sessionId: line.sessionId,
            onStarted: () {
              showLine();
              if (_pending.length <= 3) _prefetchBatch(generation);
              if (_pending.isNotEmpty) {
                final next = _pending.first;
                Timer(const Duration(milliseconds: 1300), () {
                  if (mounted && _running && generation == _generation && _voiceEnabled) {
                    _voice.prepare(next.text, panelIndex: next.panel, sessionId: next.sessionId);
                  }
                });
              }
            },
          );
          if (!supported && mounted && generation == _generation) {
            showLine();
            _message(
              '${_voice.lastError} · 자막으로 계속합니다.',
            );
            await Future<void>.delayed(
              Duration(milliseconds: 1500 + line.text.length * 35),
            );
          }
        } else {
          showLine();
          await Future<void>.delayed(
            Duration(milliseconds: 1500 + line.text.length * 35),
          );
        }
        if (!widget.presentation && mounted && generation == _generation && _running) await DebateEffects.play(line.stage);
      }
    } finally {
      _speaking = false;
      if (mounted && generation == _generation) setState(() => _activePanel = null);
    }
  }

  void _finish({bool summarize = false}) {
    DebateEffects.stop();
    if (!_running) return;
    _timer?.cancel();
    _generation++;
    _pending.clear();
    _nextBatch = null;
    _voice.stop();
    _voice.clearPrepared();
    if (!mounted) return;
    final requestSummary = summarize && !_summaryRequested;
    setState(() {
      _running = false;
      _busy = false;
      _activePanel = null;
      _remainingSeconds =
          summarize
              ? 0
              : _remainingSeconds.clamp(0, _durationMinutes * 60).toInt();
      _summaryReady = requestSummary;
      _summary = '';
      _summarySessionId = '';
      _summarySpeaking = false;
      _checks = [];
      if (requestSummary) _summaryRequested = true;
    });
    if (requestSummary) {
      if (_lines.any((line) => line.panel <= 3)) {
        unawaited(_summarizeShown());
      } else {
        setState(() => _summary = '표시된 패널 발언이 없어 요약할 내용이 없습니다.');
      }
    } else {
      _message('토론을 중지했습니다. 최종 요약은 설정 시간이 끝날 때 표시됩니다.');
    }
  }

  Future<void> _summarizeShown() async {
    final generation = _generation;
    try {
      final result = await _generate(
        _topicController.text.trim(),
        '새 발언을 추가하지 말고 history에 표시된 실제 발언만 summary에서 요약해 주세요.',
        _history(),
        summarize: true,
      );
      if (mounted && generation == _generation) {
        setState(() {
          _summarySessionId = '${result["id"] ?? ""}';
          _summary = '${result['summary'] ?? ''}';
          _checks =
              (result['checks'] as List? ?? [])
                  .map((x) => x.toString())
                  .toList();
        });
        _scrollToBottom();
        if (_voiceEnabled) await _readSummary();
      }
    } catch (_) {
      if (mounted && generation == _generation)
        setState(() => _summary = '최종 요약을 불러오지 못했습니다. 표시된 발언을 확인해 주세요.');
    }
  }

  Future<void> _readSummary() async {
    if (_summarySpeaking || _summary.trim().isEmpty || _summarySessionId.isEmpty) return;
    final generation = _generation;
    setState(() { _summarySpeaking = true; _activePanel = 3; });
    final ok = await _voice.speak(_summary, panelIndex: 3, sessionId: _summarySessionId);
    if (!mounted || generation != _generation) return;
    setState(() { _summarySpeaking = false; _activePanel = null; });
    if (!ok) _message('진행자 음성을 재생하지 못했습니다. 요약 읽기를 다시 누르거나 음성 서버 배포 상태를 확인하세요.');
  }

  List<Map<String, dynamic>> _history() =>
      _lines
          .map(
            (x) => {
              'panel': ['A', 'B', 'C', '진행자', '시민'][x.panel],
              'text': x.text,
            },
          )
          .toList();

  Future<void> _submitQuestion() async {
    if (!_running) { _message('토론을 시작한 뒤 설정 시간 안에 질문해 주세요.'); return; }
    final question = _questionController.text.trim();
    if (question.isEmpty) { _message('시민 질문을 입력해주세요.'); return; }
    if (question.length > 800) { _message('시민 질문은 800자 이내로 입력해주세요.'); return; }
    if (_queuedQuestion != null) { _message('앞서 접수한 질문에 답변한 뒤 다음 질문을 보내주세요.'); return; }
    setState(() { _queuedQuestion = question; _questionController.clear(); });
    _message('시민 질문을 접수했습니다. 현재 발언 묶음이 끝나면 음성과 자막으로 질문하고 세 패널이 답변합니다.');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );

  String get _clock =>
      '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _adminAccess,
    builder: (context, snapshot) {
      if (snapshot.data == true) return _buildDebate(context);
      return Scaffold(
        appBar: AppBar(title: const Text('관리자 전용 토론')),
        body: Center(child: Text(snapshot.connectionState == ConnectionState.waiting
            ? '권한 확인 중…' : '관리자만 이용할 수 있습니다.')),
      );
    },
  );

  Widget _buildDebate(BuildContext context) => Theme(
    data: darkControlTheme(),
    child: Builder(builder: _buildContent),
  );

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E1B),
        foregroundColor: Colors.white,
        title: Text(
          widget.presentation ? 'ORQUBE 자료 동반형 토론' : 'ORQUBE AI RADIO DEBATE',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 17),
        ),
        actions: [
          if (widget.presentation) IconButton(
            tooltip: _visualFocus ? '조작 화면으로' : '자료 집중 화면',
            onPressed: () => setState(() => _visualFocus = !_visualFocus),
            icon: Icon(_visualFocus ? Icons.close_fullscreen : Icons.slideshow)),
          if (widget.presentation && _recording) IconButton(
            tooltip: '녹화 종료·저장', onPressed: _recordBusy ? null : _toggleRecording,
            icon: const Icon(Icons.stop_circle, color: Colors.redAccent)),
          IconButton(
            tooltip: '이메일 인증',
            onPressed: () => showEmailVerificationDialog(context),
            icon: const Icon(Icons.mark_email_read_outlined),
          ),
          if (MediaQuery.of(context).size.width >= 600)
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _lime.withOpacity(.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _lime),
              ),
              child: const Text(
                'BETA · DEV ONLY',
                style: TextStyle(
                  color: _lime,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1000 && constraints.maxHeight >= 420;
            final gap = constraints.maxWidth < 600 ? 8.0 : 14.0;
            return Padding(
              padding: EdgeInsets.all(gap),
              child: widget.presentation && _visualFocus
                  ? SingleChildScrollView(child: _visualStage())
                  : widget.presentation
                  ? (wide ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 7, child: SingleChildScrollView(child: Column(children: [
                        _visualStage(), _radioControls(),
                      ]))),
                      SizedBox(width: gap), Expanded(flex: 4, child: _debatePanel()),
                    ]) : ListView(children: [
                      _visualStage(), _radioControls(), SizedBox(height: gap),
                      SizedBox(height: 500, child: _debatePanel()),
                    ]))
                  : wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(
                            child: Column(children: [
                              SizedBox(
                                height: ((constraints.maxHeight - 2 * gap) * .48).clamp(160.0, 410.0).toDouble(),
                                child: Center(child: _radioStage()),
                              ),
                              SizedBox(height: gap),
                              _radioControls(),
                            ]),
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(flex: 4, child: _debatePanel()),
                      ],
                    )
                  : ListView(children: [
                      _radioStage(),
                      SizedBox(height: gap),
                      SizedBox(
                        height: (constraints.maxHeight * .72).clamp(400.0, 720.0).toDouble(),
                        child: _debatePanel(),
                      ),
                      SizedBox(height: gap),
                      _radioControls(),
                    ]),
            );
          },
        ),
      ),
    );
  }

  Widget _radioControls() => _card(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Icon(Icons.description_outlined, color: Colors.white70, size: 22),
          SizedBox(width: 8),
          Text('토론 주제', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _topicController,
          enabled: !_running && !_busy && !_speaking && !_summarySpeaking,
          minLines: 1,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: _input('토론할 주제를 입력하세요'),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.schedule_outlined, color: Colors.white70, size: 22),
              const SizedBox(width: 7),
              const Text('토론 시간', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _durationMinutes,
                dropdownColor: const Color(0xFF13243A),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                items: List.generate(10, (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('${(i + 1).toString().padLeft(2, '0')}:00'),
                )),
                onChanged: _running || _busy || _speaking || _summarySpeaking ? null : (value) {
                  if (value == null) return;
                  setState(() { _durationMinutes = value; _remainingSeconds = value * 60; });
                },
              ),
            ]),
            FilledButton.icon(
              onPressed: _running ? () => _finish() : (_busy || _speaking || _summarySpeaking || _visualLoading ? null : _start),
              style: FilledButton.styleFrom(
                backgroundColor: _running ? Colors.redAccent : _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              icon: Icon(_running ? Icons.stop_rounded : Icons.play_arrow_rounded),
              label: Text(_running ? '토론 종료' : _busy ? 'AI 생성 중…' : '토론 시작'),
            ),
            OutlinedButton.icon(
              onPressed: _recordBusy ? null : _toggleRecording,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
              icon: Icon(_recording ? Icons.stop_circle_outlined : Icons.fiber_manual_record,
                color: Colors.redAccent),
              label: Text(_recording ? '녹화 종료·저장' : '녹화 시작'),
            ),
          ],
        ),
        const SizedBox(height: 8),
if (!widget.presentation) Wrap(spacing: 8, children: [
          FilterChip(label: const Text('풍자·개그 v2'), selected: DebateEffects.comedy,
            onSelected: (v) => setState(() { DebateEffects.comedy = v; if (!v) DebateEffects.stop(); })),
          FilterChip(label: const Text('군중 웃음·효과음'), selected: DebateEffects.enabled,
            onSelected: (v) => setState(() { DebateEffects.enabled = v; if (!v) DebateEffects.stop(); })),
          TextButton(onPressed: () => DebateEffects.preview('웃음'), child: const Text('웃음 미리듣기')),
          TextButton(onPressed: () => DebateEffects.preview('박수'), child: const Text('박수 미리듣기')),
        ]),
        Row(children: [
          IconButton(
            tooltip: _volume == 0 ? '음소거 해제' : '음소거',
            icon: Icon(_volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white70),
            onPressed: () {
              setState(() {
                if (_volume > 0) { _previousVolume = _volume; _volume = 0; }
                else { _volume = _previousVolume; }
              });
              _voice.setVolume(_volume); DebateEffects.setVolume(_volume);
            },
          ),
          Text('음량 ${(_volume * 100).round()}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Expanded(child: Slider(
            value: _volume,
            min: 0, max: 1, divisions: 100,
            activeColor: _purple,
            label: '${(_volume * 100).round()}%',
            onChanged: (value) { _voice.setVolume(value); DebateEffects.setVolume(value); setState(() => _volume = value); },
          )),
        ]),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            iconColor: Colors.white70,
            collapsedIconColor: Colors.white70,
            leading: const Icon(Icons.settings_outlined, color: Colors.white70),
            title: const Text('음성 재시도 · 자막 설정', style: TextStyle(color: Colors.white70, fontSize: 14)),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('AI 음성', style: TextStyle(color: Colors.white70)),
                value: _voiceEnabled,
                onChanged: (value) { if (!value) _voice.stop(); setState(() => _voiceEnabled = value); },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('자막', style: TextStyle(color: Colors.white70)),
                value: _subtitlesEnabled,
                onChanged: (value) => setState(() => _subtitlesEnabled = value),
              ),
              const Text('털보·따불·신사·진행자는 독자적인 AI 가상 인물이며 사진은 정지 화면입니다. 로그인 후 토론을 이용하세요. 최종 요약은 설정 시간이 끝나면 진행자가 읽어줍니다.',
                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
              const SizedBox(height: 8),
              const Text('PC Chrome/Edge에서 현재 토론 탭과 탭 오디오 공유를 선택해 녹화하세요. 앱 음량 0%는 녹화에서도 무음이 될 수 있습니다.',
                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
              const SizedBox(height: 8),
              _panelLegend(0, '털보', _purple, '빠르고 힘 있는 허스키 중저음'),
              _panelLegend(1, '따불', Colors.orangeAccent, '밝고 경쾌한 중음'),
              _panelLegend(2, '신사', _cyan, '차분하고 또렷한 중저음'),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LiveDebateRoomPage())),
                icon: const Icon(Icons.groups_outlined),
                label: const Text('별도 공동 문자 토론방 열기'),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _debatePanel() => _card(
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              _running ? Icons.graphic_eq_rounded : Icons.forum_rounded,
              color: _running ? _lime : Colors.white54,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                '발언 · 자막',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              _clock,
              style: TextStyle(
                color: _remainingSeconds < 30 ? Colors.redAccent : _lime,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white12, height: 24),
        Expanded(
          child:
              _lines.isEmpty && !_summaryReady
                  ? const Center(
                    child: Text(
                      '주제와 시간을 정하고 토론을 시작하세요.',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                  : ListView.builder(
                    controller: _scrollController,
                    itemCount: _lines.length + (_summaryReady ? 1 : 0),
                    itemBuilder:
                        (context, index) =>
                            index == _lines.length
                                ? _summaryCard()
                                : _lineCard(_lines[index]),
                  ),
        ),

        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _cyan.withOpacity(.08), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cyan.withOpacity(.4))),
          child: Row(children: [
            const Icon(Icons.groups_outlined, color: _cyan, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(
              !_running ? '토론을 시작하면 시민 질문을 보낼 수 있습니다.'
                : _queuedQuestion != null ? '시민 질문을 접수했습니다.'
                : _busy ? '다음 발언을 준비하고 있습니다.' : '시민 질문을 기다리고 있습니다.',
              style: const TextStyle(color: _cyan, fontSize: 12),
            )),
          ]),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _questionController,
                style: const TextStyle(color: Colors.white),
                decoration: _input(_queuedQuestion == null ? '시민 질문을 보내면 세 패널이 답변합니다' : '접수한 시민 질문 답변 대기 중'),
                onSubmitted: (_) => _submitQuestion(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: '시민 질문 접수',
              onPressed:
                  !_running || _queuedQuestion != null ? null : _submitQuestion,
              style: IconButton.styleFrom(
                backgroundColor: _cyan,
                foregroundColor: _bg,
              ),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _radioStage() => LayoutBuilder(builder: (context, constraints) {
    const labels = ['털보', '따불', '진행자', '신사'];
    const panels = [0, 1, 3, 2];
    final compact = constraints.maxWidth < 500;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: LayoutBuilder(builder: (context, box) => Stack(fit: StackFit.expand, children: [
          Image.asset('assets/images/debate/radio_studio.png', fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF16263A),
              child: Row(children: panels.map((panel) => Expanded(
                child: Center(child: DebateCharacter(panel: panel, color: _lime,
                  size: compact ? 54 : 110, active: _activePanel == panel)),
              )).toList())),
          ),
          const Positioned(top: 10, left: 12, child: Text('AI 가상 인물·합성 음성 · 정지 화면',
            style: TextStyle(color: Colors.white70, fontSize: 10, shadows: [Shadow(color: Colors.black, blurRadius: 4)]))),
          Positioned(
            left: box.maxWidth * .025,
            right: box.maxWidth * .025,
            bottom: box.maxHeight * .235,
            child: Row(children: List.generate(4, (index) {
              final active = _activePanel == panels[index];
              return Expanded(child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(vertical: compact ? 5 : 9, horizontal: 3),
                  decoration: BoxDecoration(
                    color: active ? _lime : const Color(0xEC09131F),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: active ? _lime : const Color(0xFFB89A4F), width: active ? 2 : 1),
                    boxShadow: active ? [BoxShadow(color: _lime.withOpacity(.5), blurRadius: 15)] : [],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    FittedBox(fit: BoxFit.scaleDown, child: Text(labels[index],
                      style: TextStyle(color: active ? _bg : _lime, fontWeight: FontWeight.w900, fontSize: compact ? 12 : 18))),
                    if (active && !compact) const Text('발언 중', style: TextStyle(color: _bg, fontSize: 10)),
                  ]),
                ),
              ));
            })),
          ),
          if (_activePanel == 4) Positioned(left: 12, right: 12, bottom: 8,
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xED09131F), borderRadius: BorderRadius.circular(8)),
              child: const Text('시민패널 발언 중', textAlign: TextAlign.center,
                style: TextStyle(color: _cyan, fontWeight: FontWeight.w700)))),
        ])),
      ),
    );
  });

  Widget _radioAvatar(int panel, Color color, {double size = 40}) {
    const positions = [-.8, -.25, .86, .32];
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
      child: ClipOval(child: OverflowBox(
        alignment: Alignment(positions[panel.clamp(0, 3).toInt()], -.45),
        minWidth: size * 8, maxWidth: size * 8,
        minHeight: size * 4.5, maxHeight: size * 4.5,
        child: Image.asset('assets/images/debate/radio_studio.png', fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(child: DebateCharacter(panel: panel, color: color, size: size))),
      )),
    );
  }

  Widget _lineCard(_DebateLine line) {
    final colors = [_purple, Colors.orangeAccent, _cyan, _lime, Colors.white70];
    final labels = ['털보', '따불', '신사', '진행자', '시민패널'];
    final color = colors[line.panel];
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: identical(line, _lines.last) && _activePanel == line.panel ? _lime : color.withOpacity(.38),
          width: identical(line, _lines.last) && _activePanel == line.panel ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              line.panel == 4
                  ? CircleAvatar(
                    radius: 18,
                    backgroundColor: color,
                    child: const Icon(Icons.person_outline, color: _bg),
                  )
                  : _radioAvatar(line.panel, color, size: 40),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  labels[line.panel],
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
              ),
              Flexible(
                child: Text(
                  line.stage,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ],
          ),
          if (_subtitlesEnabled) ...[
            const SizedBox(height: 9),
            Text(
              line.text,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
            ),
          ],
          if (line.stage.contains('근거')) ...[
            const SizedBox(height: 9),
            const Wrap(
              spacing: 6,
              children: [
                Icon(Icons.fact_check_outlined, color: Colors.amber, size: 16),
                Text(
                  '검증 상태: AI 생성 · 외부 사실 검증 필요',
                  style: TextStyle(color: Colors.amber, fontSize: 11.5),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 6),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _cyan.withOpacity(.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _cyan.withOpacity(.5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '진행자 · 최종 요약',
          style: TextStyle(color: _cyan, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 7),
        Text(
          _summary.isEmpty ? '최종 요약 생성 중…' : _summary,
          style: const TextStyle(color: Colors.white, height: 1.45),
        ),
        TextButton.icon(
          onPressed: _summarySessionId.isEmpty ? null : () {
            if (_summarySpeaking) { _voice.stop(); }
            else { unawaited(_readSummary()); }
          },
          icon: Icon(_summarySpeaking ? Icons.stop : Icons.volume_up),
          label: Text(_summarySpeaking ? '요약 음성 중지' : '진행자 요약 다시 읽기'),
        ),
        ..._checks.map(
          (x) => Text(
            '확인 필요: $x',
            style: const TextStyle(color: Colors.amber, fontSize: 11),
          ),
        ),
        SizedBox(height: 6),
        Text(
          '※ 중립 요약은 결정을 대신하지 않으며, BETA에서는 법률·정책 사실 검증 결과로 사용할 수 없습니다.',
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _panelLegend(int key, String title, Color color, String voice) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          children: [
            DebateCharacter(
              panel: key,
              color: color,
              size: 54,
              active: _activePanel == key,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    voice,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xE60D1020),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white12),
      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 24)],
    ),
    child: child,
  );

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: Colors.white.withOpacity(.045),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Colors.white12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _cyan),
    ),
  );
}

class _DebateLine {
  const _DebateLine(this.panel, this.stage, this.text, {this.sessionId = '', this.visualId = ''});
  final String sessionId;
  final String visualId;
  final int panel;
  final String stage;
  final String text;
}
