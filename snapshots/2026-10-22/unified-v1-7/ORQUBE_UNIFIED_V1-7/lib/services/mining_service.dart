import 'dart:async';

class MiningTick {
  final int seconds;
  final double sessionOrbs;
  final double totalOrbs;
  final int points;
  final bool isMining;
  final double boostRate;

  const MiningTick({
    required this.seconds,
    required this.sessionOrbs,
    required this.totalOrbs,
    required this.points,
    required this.isMining,
    required this.boostRate,
  });

  String get timeText {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }
}

class MiningService {
  MiningService({
    this.baseOrbsPerSecond = 0.000137,
    this.boostRate = 1.0,
    double initialOrbs = 0.0,
    int initialPoints = 1260,
  }) : _totalOrbs = initialOrbs,
       _points = initialPoints;

  final double baseOrbsPerSecond;
  double boostRate;

  Timer? _timer;

  int _seconds = 0;
  double _sessionOrbs = 0.0;
  double _totalOrbs = 0.0;
  int _points = 0;
  bool _isMining = false;

  final StreamController<MiningTick> _controller =
      StreamController<MiningTick>.broadcast();

  Stream<MiningTick> get stream => _controller.stream;

  MiningTick get current => MiningTick(
    seconds: _seconds,
    sessionOrbs: _sessionOrbs,
    totalOrbs: _totalOrbs,
    points: _points,
    isMining: _isMining,
    boostRate: boostRate,
  );

  void start() {
    if (_isMining) return;

    _isMining = true;
    _emit();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds += 1;

      final mined = baseOrbsPerSecond * boostRate;
      _sessionOrbs += mined;
      _totalOrbs += mined;

      if (_seconds % 5 == 0) {
        _points += 1;
      }

      _emit();
    });
  }

  void pause() {
    _isMining = false;
    _timer?.cancel();
    _emit();
  }

  void toggle() {
    if (_isMining) {
      pause();
    } else {
      start();
    }
  }

  void resetSession() {
    _seconds = 0;
    _sessionOrbs = 0.0;
    _emit();
  }

  void claimDailyReward({int points = 10, double orbs = 0.010000}) {
    _points += points;
    _totalOrbs += orbs;
    _emit();
  }

  void claimAdReward({int points = 10, double orbs = 0.005000}) {
    _points += points;
    _totalOrbs += orbs;
    _emit();
  }

  void setBoost(double value) {
    boostRate = value;
    _emit();
  }

  void setInitialData({required int points, required double orbs}) {
    _points = points;
    _totalOrbs = orbs;
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(current);
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
