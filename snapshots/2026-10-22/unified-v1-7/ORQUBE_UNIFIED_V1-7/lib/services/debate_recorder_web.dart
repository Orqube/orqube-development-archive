import 'dart:js_interop';
@JS('orqubeRecorder.recording')
external bool get _recording;
@JS('orqubeRecorder.start')
external JSPromise<JSString> _startRecording();
@JS('orqubeRecorder.stop')
external JSPromise<JSString> _stopRecording();
class DebateRecorder {
  bool get recording { try { return _recording; } catch (_) { return false; } }
  Future<String> start() async => (await _startRecording().toDart).toDart;
  Future<String> stop() async => (await _stopRecording().toDart).toDart;
}
