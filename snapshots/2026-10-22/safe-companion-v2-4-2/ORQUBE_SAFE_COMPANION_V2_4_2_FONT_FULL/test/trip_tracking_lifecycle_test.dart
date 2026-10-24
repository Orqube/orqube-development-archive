import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orqube_safe_hiking/services/trip_tracking.dart';

Position fix(double lat, DateTime time) => Position(latitude:lat,longitude:127,
  timestamp:time,accuracy:5,altitude:0,altitudeAccuracy:0,heading:0,
  headingAccuracy:0,speed:1,speedAccuracy:0);

void main() {
  test('detaching a screen listener keeps GPS alive; reopening sees the same route', () async {
    final input=StreamController<Position>();
    final t=TripTracking.forTest(currentUid:()=> 'owner',positions:(_)=>input.stream);
    var draws=0; void listener(){draws++;}
    t.addListener(listener);
    final now=DateTime.now();
    await t.start(owner:'owner',tripMode:'safe_home',sessionCollection:'',startTime:now,
      initialRoute:[],initialDistance:0,metadata:{});
    input.add(fix(37,now)); await Future<void>.delayed(Duration.zero);
    t.removeListener(listener); final previousDraws=draws;
    input.add(fix(37.001,now.add(const Duration(seconds:2))));
    await Future<void>.delayed(Duration.zero);
    expect(draws,previousDraws); expect(t.active,isTrue);
    expect(t.route.length,2); expect(t.distanceKm,greaterThan(0));
    t.addListener(listener);
    input.add(fix(37.002,now.add(const Duration(seconds:4))));
    await Future<void>.delayed(Duration.zero);
    expect(draws,greaterThan(previousDraws)); expect(t.route.length,3);
    await t.stop(); expect(t.active,isFalse); expect(input.hasListener,isFalse);
    t.removeListener(listener); t.dispose(); await input.close();
  });
  test('one session only; account mismatch prevents new coordinates', () async {
    var owner='owner'; final input=StreamController<Position>();
    final t=TripTracking.forTest(currentUid:()=>owner,positions:(_)=>input.stream);
    final now=DateTime.now();
    await t.start(owner:'owner',tripMode:'safe_home',sessionCollection:'',startTime:now,
      initialRoute:[],initialDistance:0,metadata:{});
    await expectLater(t.start(owner:'owner',tripMode:'location',sessionCollection:'',startTime:now,
      initialRoute:[],initialDistance:0,metadata:{}),throwsStateError);
    owner='another'; input.add(fix(37,now)); await Future<void>.delayed(Duration.zero);
    expect(t.position,isNull); expect(t.route,isEmpty);
    await t.stop();t.dispose();await input.close();
  });
  test('30 minute share expiry ends its GPS session, not just the banner', () async {
    final input=StreamController<Position>();
    final t=TripTracking.forTest(currentUid:()=> 'owner',positions:(_)=>input.stream);
    await t.start(owner:'owner',tripMode:'location',sessionCollection:'',startTime:DateTime.now(),
      initialRoute:[],initialDistance:0,metadata:{});
    t.setSharing(true,until:DateTime.now().subtract(const Duration(seconds:1)));
    await Future<void>.delayed(const Duration(milliseconds:20));
    expect(t.active,isFalse);expect(t.sharing,isFalse);expect(input.hasListener,isFalse);
    t.dispose();await input.close();
  });
}
