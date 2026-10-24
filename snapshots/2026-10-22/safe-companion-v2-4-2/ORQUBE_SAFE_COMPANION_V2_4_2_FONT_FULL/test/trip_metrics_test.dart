import 'package:flutter_test/flutter_test.dart';
import 'package:orqube_safe_hiking/utils/trip_metrics.dart';
void main() {
  test('future start cannot display negative duration; long hikes retain hours', () {
    final now=DateTime.utc(2026,10,15,12);
    expect(TripMetrics.elapsed(now.add(const Duration(minutes:1)),now),'00:00:00');
    expect(TripMetrics.elapsed(now.subtract(const Duration(hours:27,minutes:2,seconds:3)),now),'27:02:03');
  });
  test('stale status follows the fix timestamp rather than callback receipt', () {
    final now=DateTime.utc(2026,10,15,12);
    expect(TripMetrics.stale(now.subtract(const Duration(seconds:20)),now),isFalse);
    expect(TripMetrics.stale(now.subtract(const Duration(seconds:21)),now),isTrue);
    expect(TripMetrics.stale(now.add(const Duration(minutes:6)),now),isTrue);
    expect(TripMetrics.stale(now,now),isFalse);
  });
}
