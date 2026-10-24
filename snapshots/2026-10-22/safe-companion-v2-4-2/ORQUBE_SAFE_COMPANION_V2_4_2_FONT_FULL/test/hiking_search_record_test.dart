import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orqube_safe_hiking/services/hiking_search_record.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(HikingSearchRecord.cancelRetriesForTest);
  test('GPS journal survives a preferences read and preserves observation time', () async {
    SharedPreferences.setMockInitialValues({});
    final time = DateTime.utc(2026,10,15,3);
    await HikingSearchRecord.start('test-user', startedAt: time, plannedReturnAt: time.add(const Duration(hours: 4)), guardianName: 'Guardian');
    final p = Position(latitude: 37, longitude: 127, timestamp: time, accuracy: 5,
      altitude: 100, altitudeAccuracy: 10, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
    await HikingSearchRecord.append('test-user', p);
    await HikingSearchRecord.append('test-user', p);
    final record = (await HikingSearchRecord.read('test-user'))!;
    expect((record['points'] as List).length, 1);
    expect((record['points'] as List).first['time'], time.toIso8601String());
    expect(record['consent'], false);
    await HikingSearchRecord.stop('test-user', finish: true);
    final ended = (await HikingSearchRecord.read('test-user'))!;
    expect(ended['recording'], false);
    expect(ended['consent'], false);
    expect(ended['pending'], true); // Offline deletion must remain durable.
  });
  test('Account journals remain separate', () async {
    SharedPreferences.setMockInitialValues({});
    await HikingSearchRecord.start('other-user', startedAt: DateTime.utc(2026), guardianName: '');
    expect(await HikingSearchRecord.read('unknown-user'), isNull);
    expect((await HikingSearchRecord.read('other-user'))!['ownerUid'], 'other-user');
  });
  test('Bounded server sampling preserves both endpoints', () {
    final route = List<Map>.generate(10000, (i) => {'lat': i / 1000, 'lng': 127});
    final sampled = sampleSearchPoints(route, 4000);
    expect(sampled.length, 4000);
    expect(sampled.first, route.first);
    expect(sampled.last, route.last);
  });
  test('GeoJSON uses longitude then latitude and includes observation time', () {
    final result = searchGeoJson({'points': [{'lat': 37, 'lng': 127, 'time': '2026-10-15T03:00:00Z'}]});
    final feature = (result['features'] as List).single as Map;
    expect(feature['geometry']['coordinates'], [127,37]);
    expect(feature['properties']['observedAt'], '2026-10-15T03:00:00Z');
  });
}
