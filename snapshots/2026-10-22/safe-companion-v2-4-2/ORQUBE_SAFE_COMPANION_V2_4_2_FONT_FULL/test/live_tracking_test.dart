import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:orqube_safe_hiking/utils/live_tracking.dart';
void main() {
  final now = DateTime.utc(2026, 10, 15, 3);
  TrackingFreshness check({bool active=true, bool cached=false, int age=0, int ttl=120}) => trackingFreshness(
    active: active, cached: cached, now: now,
    updatedAt: now.subtract(Duration(seconds: age)), expiresAt: now.add(Duration(seconds: ttl)));
  test('Live updates distinguish delayed, cached, expired and stopped states', () {
    expect(check(age: 5), TrackingFreshness.fresh);
    expect(check(age: 21), TrackingFreshness.delayed);
    expect(check(cached: true), TrackingFreshness.cached);
    expect(check(ttl: 0), TrackingFreshness.expired);
    expect(check(active: false), TrackingFreshness.stopped);
    expect(check(active: false, cached: true), TrackingFreshness.stopped);
  });
  test('Animation clamps to the latest received fix without extrapolation', () {
    const from = LatLng(37, 127), to = LatLng(38, 128);
    expect(interpolateFix(from, to, 0.5).latitude, closeTo(37.5, 0.00001));
    expect(interpolateFix(from, to, 2).latitude, to.latitude);
    expect(interpolateFix(from, to, -1).latitude, from.latitude);
  });
  test('Crossing the date line takes the short route', () {
    final middle = interpolateFix(const LatLng(0,179), const LatLng(0,-179), 0.5);
    expect(middle.longitude.abs(), closeTo(180, 0.00001));
  });
}
