import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

@JS('Audio')
@staticInterop
class _Audio {
  external factory _Audio(String source);
}

extension on _Audio {
  external JSPromise<JSAny?> play();
  external void pause();
  external set src(String value);
  external set volume(num value);
  external set onended(JSFunction value);
  external set onerror(JSFunction value);
}

class MixedDebateVoice {
  _Audio? _audio;
  String lastError = '';
  Future<bool> unlock() async {
    if (_active != null) return true;
    try {
      final audio = _audio ??= _Audio('');
      audio.src = 'data:audio/wav;base64,UklGRmQGAABXQVZFZm10IBAAAAABAAEAQB8AAIA+AAACABAAZGF0YUAGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      audio.volume = _volume;
      await audio.play().toDart;
      return true;
    } catch (e) {
      lastError = '브라우저 재생 권한: $e';
      return false;
    }
  }

  Completer<bool>? _active;
  Timer? _timeout;
  http.Client? _client;
  int _generation = 0;
  double _volume = 1.0;
  final Map<String, Future<http.Response?>> _prepared = {};
  String _key(String text, int panel, String session) =>
      '$session|$panel|$text';
  Future<http.Response?> _fetch(String text, int panel, String session) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final token = await user.getIdToken();
      const override = String.fromEnvironment('DEBATE_SPEECH_API_URL');
      final project = Firebase.app().options.projectId;
      final url = override.isNotEmpty
          ? override
          : 'https://asia-northeast3-$project.cloudfunctions.net/generateDebateSpeech';
      for (var attempt = 0; attempt < 2; attempt++) {
        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'text': text,
                'panelIndex': panel,
                'sessionId': session,
              }),
            )
            .timeout(const Duration(seconds: 70));
        if (attempt == 0 && [429, 502, 504].contains(response.statusCode)) {
          await Future<void>.delayed(const Duration(milliseconds: 1500));
          continue;
        }
        return response;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void prepare(
    String text, {
    required int panelIndex,
    required String sessionId,
  }) {
    if (_prepared.length >= 2) return;
    _prepared.putIfAbsent(
      _key(text, panelIndex, sessionId),
      () => _fetch(text, panelIndex, sessionId),
    );
  }

  void clearPrepared() => _prepared.clear();
  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0).toDouble();
    _audio?.volume = _volume;
  }

  Future<bool> speak(
    String text, {
    required int panelIndex,
    required String sessionId,
    void Function()? onStarted,
  }) async {
    stop();
    lastError = '';
    final generation = _generation;
    final done = Completer<bool>();
    _active = done;
    final client = http.Client();
    _client = client;
    void complete(bool value) {
      if (!done.isCompleted) done.complete(value);
      if (identical(_active, done)) {
        _timeout?.cancel();
        _active = null;
      }
    }

    try {
      final response =
          await (_prepared.remove(_key(text, panelIndex, sessionId)) ??
              _fetch(text, panelIndex, sessionId));
      if (response == null) {
        lastError = '음성 서버 연결 또는 로그인 확인이 필요합니다.';
        return false;
      }
      if (generation != _generation) return true;
      if (response.statusCode != 200 ||
          !(response.headers['content-type'] ?? '').startsWith('audio/')) {
        String reason = '';
        try {
          reason =
              (jsonDecode(response.body) as Map)['error']?.toString() ?? '';
        } catch (_) {}
        lastError = '음성 서버 HTTP ${response.statusCode} $reason';
        return false;
      }
      if (response.headers['x-debate-speech-version'] != 'dev33-fast-male-v1') {
        lastError = '이전 음성 서버입니다. generateDebateSpeech 함수를 먼저 재배포하세요.';
        return false;
      }
      final audio = _audio ??= _Audio('');
      audio.src = 'data:audio/mpeg;base64,${base64Encode(response.bodyBytes)}';
      _audio = audio;
      audio.volume = _volume;
      audio.onended = ((JSAny? _) {
        complete(true);
      }).toJS;
      audio.onerror = ((JSAny? _) {
        lastError = '오디오 데이터를 재생하지 못했습니다.';
        complete(false);
      }).toJS;
      _timeout = Timer(Duration(seconds: 20 + text.length ~/ 3), () {
        lastError = '음성 재생 시간이 초과되었습니다.';
        audio.pause();
        complete(false);
      });
      await audio.play().toDart;
      if (generation == _generation) onStarted?.call();
      return await done.future;
    } catch (e) {
      lastError = '음성 요청 또는 재생 실패: $e';
      return generation != _generation;
    } finally {
      client.close();
      if (identical(_client, client)) _client = null;
      if (generation == _generation) {
        _timeout?.cancel();
        _audio?.pause();
        _audio?.src = '';

        complete(false);
      }
    }
  }

  void stop() {
    _generation++;
    _timeout?.cancel();
    _client?.close();
    _client = null;
    _audio?.pause();
    _audio?.src = '';

    final active = _active;
    _active = null;
    if (active != null && !active.isCompleted) active.complete(true);
  }
}
