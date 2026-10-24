class DebateVoice {
  String lastError = '현재 앱에서는 웹 음성만 지원합니다. Chrome에서 실행해 주세요.';
  Future<bool> unlock() async => false;
  Future<bool> speak(String text, {required int panelIndex, required String sessionId, void Function()? onStarted}) async => false;
  void prepare(String text, {required int panelIndex, required String sessionId}) {}
  void clearPrepared() {}
  void setVolume(double value) {}
  void stop() {}
}
