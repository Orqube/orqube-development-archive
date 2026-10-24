import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

// One retained trip per account on this device. Never resume GPS/sharing implicitly.
class HikingSearchRecord {
  static final status = ValueNotifier<String>('');
  static Map<String, dynamic>? _record;
  static String? _uid;
  static Future<void> _queue = Future<void>.value();
  static bool _busy = false;
  static DateTime? _lastAttempt;
  @visibleForTesting
  static void cancelRetriesForTest() { _retry?.cancel(); _retry = null; }
  static Timer? _retry;
  static String key(String uid) => 'hiking_search_v1_$uid';
  static Future<Map<String,dynamic>?> read(String uid) async {
    await _queue;
    final text = (await SharedPreferences.getInstance()).getString(key(uid));
    if (text == null) return null;
    try { return Map<String,dynamic>.from(jsonDecode(text) as Map); }
    catch (_) { status.value = '기기 기록을 읽지 못했습니다.'; return null; }
  }
  static Future<void> _edit(String uid, void Function() change) {
    final next = _queue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (_uid != uid) {
        _uid = uid; _record = null;
        final raw = prefs.getString(key(uid));
        if (raw != null) _record = Map<String,dynamic>.from(jsonDecode(raw) as Map);
      }
      change();
      if (_record != null && !await prefs.setString(key(uid), jsonEncode(_record))) {
        throw StateError('Device storage failed');
      }
    });
    _queue = next.catchError((Object _) { status.value = '기기 저장 실패 · 저장 공간을 확인하세요.'; });
    return next;
  }
  static Future<void> start(String uid, {required DateTime startedAt, DateTime? plannedReturnAt, required String guardianName}) async {
    await _edit(uid, () { _record = {
      'ownerUid': uid, 'tripId': '${uid}_${startedAt.millisecondsSinceEpoch}',
      'startedAt': startedAt.toUtc().toIso8601String(),
      'plannedReturnAt': plannedReturnAt?.toUtc().toIso8601String(),
      'guardianName': guardianName, 'recording': true, 'consent': false,
      'pending': true, 'revision': 0, 'points': <dynamic>[], 'droppedPoints': 0,
    }; });
  }
  static Future<void> append(String uid, Position p) async {
    if (!p.latitude.isFinite || !p.longitude.isFinite || p.latitude.abs()>90 || p.longitude.abs()>180) return;
    await _edit(uid, () {
      final r = _record; if (r == null || r['recording'] != true) return;
      final points = r['points'] as List;
      // Polling an old fix must not make that fix appear newly observed.
      final observed = p.timestamp.toUtc().toIso8601String();
      if (points.isNotEmpty && (points.last as Map)['time'] == observed) return;
      if (points.isNotEmpty) {
        final prev = points.last as Map;
        final age = p.timestamp.difference(DateTime.parse(prev['time'] as String));
        if (age.isNegative) return;
        final distance = Geolocator.distanceBetween((prev['lat'] as num).toDouble(), (prev['lng'] as num).toDouble(), p.latitude, p.longitude);
        if (distance < 5 && age < const Duration(seconds: 15)) return;
      }
      points.add({'lat': p.latitude, 'lng': p.longitude, 'time': observed,
        'accuracy': p.accuracy.isFinite ? p.accuracy : null, 'altitude': p.altitude.isFinite ? p.altitude : null});
      if (points.length > 10000) { points.removeAt(0); r['droppedPoints'] = (r['droppedPoints'] as int) + 1; }
      r['revision'] = (r['revision'] as int) + 1; if (r['consent'] == true) r['pending'] = true;
    });
    unawaited(sync());
  }
  static Future<void> plan(String uid, DateTime planned) async {
    await _edit(uid, () {
      if (_record == null || _record!['recording'] != true) return;
      _record!['plannedReturnAt'] = planned.toUtc().toIso8601String();
      _record!['revision'] = (_record!['revision'] as int) + 1;
      if (_record!['consent'] == true) _record!['pending'] = true;
    });
    unawaited(sync());
  }
  static Future<void> consent(String uid) async {
    await _edit(uid, () {
      if (_record == null) throw StateError('Start hike first');
      _record!['consent'] = true; _record!['pending'] = true;
      _record!['revision'] = (_record!['revision'] as int) + 1;
    });
    _retry?.cancel();
    _retry = Timer.periodic(const Duration(seconds: 20), (_) => unawaited(sync()));
    unawaited(sync());
  }
  static Future<void> stop(String uid, {bool finish = false}) async {
    await _edit(uid, () {
      if (_record == null) return;
      _record!['consent'] = false; _record!['pending'] = true;
      _record!['revision'] = (_record!['revision'] as int) + 1;
      if (finish) { _record!['recording'] = false; _record!['endedAt'] = DateTime.now().toUtc().toIso8601String(); }
    });
    // Keep a durable stop marker and retry while the process is alive.
    _retry ??= Timer.periodic(const Duration(seconds: 20), (_) => unawaited(sync()));
    unawaited(sync());
  }
  static Future<void> resume(String uid) async {
    _retry?.cancel();
    _retry = Timer.periodic(const Duration(seconds: 20), (_) => unawaited(sync()));
    await _edit(uid, () { if (_record != null) { _record!['recording'] = true; _record!['consent'] = false; _record!['pending'] = true; _record!['revision'] = (_record!['revision'] as int) + 1; } });
    unawaited(sync());
    // A new explicit share/retention consent is required after reopening.
  }
  static Future<void> sync() async {
    User? user;
    try { user = FirebaseAuth.instance.currentUser; } catch (_) { return; }
    if (_busy || user == null || !user.emailVerified || user.uid != _uid) return;
    await _queue;
    if (_busy || user.uid != _uid || _record == null || _record!['pending'] != true) return;
    if (_record!['consent'] == true && _lastAttempt != null && DateTime.now().difference(_lastAttempt!) < const Duration(seconds: 20)) return;
    _lastAttempt = DateTime.now();
    _busy = true;
    try {
      final ref = FirebaseFirestore.instance.collection('hiking_search_records').doc(user.uid);
      await ref.get(const GetOptions(source: Source.server)).timeout(const Duration(seconds: 5));
      await _queue;
      if (FirebaseAuth.instance.currentUser?.uid != user.uid || _uid != user.uid) return;
      final snapshot = jsonDecode(jsonEncode(_record)) as Map<String,dynamic>;
      final rev = snapshot['revision'];
      if (snapshot['consent'] != true) {
        await ref.delete().timeout(const Duration(seconds: 5));
      } else {
        final points = (snapshot['points'] as List).cast<Map>();
        if (points.isEmpty) return;
        final latest = points.last;
        final sampled = sampleSearchPoints(points, 4000);
        await ref.set({
          'ownerUid': user.uid, 'tripId': snapshot['tripId'], 'active': true,
          'startedAt': Timestamp.fromDate(DateTime.parse(snapshot['startedAt'] as String)),
          'plannedReturnAt': snapshot['plannedReturnAt'] == null ? null : Timestamp.fromDate(DateTime.parse(snapshot['plannedReturnAt'] as String)),
          'latitude': latest['lat'], 'longitude': latest['lng'],
          'observedAt': Timestamp.fromDate(DateTime.parse(latest['time'] as String)),
          'route': sampled.map((p) => {'latitude': p['lat'], 'longitude': p['lng'], 'observedAt': Timestamp.fromDate(DateTime.parse(p['time'] as String))}).toList(),
          'pointCount': points.length, 'droppedPoints': snapshot['droppedPoints'],
          'updatedAt': FieldValue.serverTimestamp(),
          'retainUntil': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
        }).timeout(const Duration(seconds: 8));
      }
      if (FirebaseAuth.instance.currentUser?.uid != user.uid || _uid != user.uid) return;
      await _edit(user.uid, () { if (_record?['revision'] == rev || (snapshot['consent'] != true && _record?['consent'] != true)) _record!['pending'] = false; });
      status.value = '서버 반영 완료';
      if (_record?['consent'] != true && _record?['pending'] != true) { _retry?.cancel(); _retry = null; }
    } catch (_) { status.value = '서버 전송 대기 · 연결 복구 후 재시도'; }
    finally { _busy = false; }
  }
  static Future<void> retryFor(String uid) async {
    await _edit(uid, () {});
    if (_record?['pending'] == true) {
      _retry?.cancel();
      _retry = Timer.periodic(const Duration(seconds: 20), (_) => unawaited(sync()));
    }
    await sync();
  }
  static Future<void> eraseLocal(String uid) async {
    await stop(uid, finish: true);
    // Explicit deletion also covers reinstall/device records that no longer exist locally.
    final ref = FirebaseFirestore.instance.collection('hiking_search_records').doc(uid);
    await ref.get(const GetOptions(source: Source.server)).timeout(const Duration(seconds: 5));
    await ref.delete().timeout(const Duration(seconds: 8));
    await _queue;
    if (FirebaseAuth.instance.currentUser?.uid != uid) throw StateError('Account changed');
    await _edit(uid, () { if (_record != null) _record!['pending'] = false; });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key(uid));
    if (_uid == uid) { _record = null; _retry?.cancel(); _retry = null; }
  }
}
List<Map> sampleSearchPoints(List<Map> points, int limit) {
  if (points.length <= limit) return List<Map>.from(points);
  return List.generate(limit, (i) => points[(i * (points.length - 1) / (limit - 1)).round()]);
}
Map<String,dynamic> searchGeoJson(Map<String,dynamic> record) {
  final points = (record['points'] as List? ?? []).cast<Map>();
  return {'type': 'FeatureCollection', 'features': [
    if (points.length >= 2) {'type': 'Feature', 'properties': {'kind': 'recorded_route'},
      'geometry': {'type': 'LineString', 'coordinates': points.map((p) => [p['lng'], p['lat']]).toList()}},
    for (final p in points) {'type': 'Feature', 'properties': {'observedAt': p['time'], 'accuracyMeters': p['accuracy']},
      'geometry': {'type': 'Point', 'coordinates': [p['lng'],p['lat']]}},
  ], 'trip': {'startedAt': record['startedAt'], 'plannedReturnAt': record['plannedReturnAt'], 'endedAt': record['endedAt'],
    'droppedPoints': record['droppedPoints'], 'notice': 'Recorded observations only. Not a live position or a rescue dispatch.'}};
}
