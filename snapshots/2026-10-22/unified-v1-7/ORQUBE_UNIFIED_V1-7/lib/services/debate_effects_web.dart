import 'dart:js_interop';
@JS('orqubeEffects.unlock')
external JSPromise<JSAny?> _unlock();
@JS('orqubeEffects.play')
external JSPromise<JSAny?> _play(JSString stage);
@JS('orqubeEffects.stop')
external void _stop();
@JS('orqubeEffects.setVolume')
external void _volume(JSNumber value);
class DebateEffects {
  static Future<void> unlock() async {
    try { await _unlock().toDart; } catch (_) {}
  }
  static bool comedy = true;
  static bool enabled = true;
  static void setVolume(double v) => _volume(v.toJS);
  static void stop() => _stop();
  static Future<void> preview(String stage) async {
    await unlock();
    try { await _play(stage.toJS).toDart; } catch (_) {}
  }
  static Future<void> play(String stage) async {
    if (!comedy || !enabled) return;
    try { await _play(stage.toJS).toDart; } catch (_) {}
  }
}
