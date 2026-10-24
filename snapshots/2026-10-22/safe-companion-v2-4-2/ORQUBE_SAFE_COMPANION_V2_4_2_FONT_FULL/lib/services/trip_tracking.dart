import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'guardian_share.dart';
import 'hiking_search_record.dart';

/// Process-owned session. Routes only attach/detach listeners; they never own GPS.
/// Force-stop/reboot ends this process. No automatic restart or implicit consent.
class TripTracking extends ChangeNotifier {
  TripTracking._() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (active && user?.uid != uid) unawaited(stop());
    });
  }
  @visibleForTesting
  TripTracking.forTest({required String? Function() currentUid,
    required Stream<Position> Function(LocationSettings) positions}) {
    _testUid = currentUid; _testPositions = positions; _testing = true;
  }
  String? Function()? _testUid;
  Stream<Position> Function(LocationSettings)? _testPositions;
  bool _testing = false;
  String? get _currentUid => _testUid != null ? _testUid!() : FirebaseAuth.instance.currentUser?.uid;
  static final instance = TripTracking._();
  String? uid;
  String mode = '';
  String collection = '';
  bool active = false;
  bool sharing = false;
  DateTime? startedAt, sharingUntil;
  Position? position;
  final route = <LatLng>[];
  double distanceKm = 0;
  Map<String, dynamic> details = {};
  String? error;
  StreamSubscription<Position>? _gps;
  Timer? _poll, _expiry;
  int _epoch = 0;
  bool _polling = false;
  bool _stopping = false;
  Future<void>? _inflight;
  DateTime? _snapshotAt;

  static LocationSettings settings() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 0,
        intervalDuration: const Duration(seconds: 2),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'ORQUBE Safe Companion',
          notificationText: 'Location tracking active. Open the app to view or stop.',
          enableWakeLock: true, setOngoing: true,
        ),
      );
    }
    return const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 0);
  }

  Future<void> start({required String owner, required String tripMode,
    required String sessionCollection, required DateTime startTime,
    required List<LatLng> initialRoute, required double initialDistance,
    required Map<String,dynamic> metadata, Position? initialPosition}) async {
    if (active || _stopping) throw StateError('Finish the active trip first');
    uid = owner; mode = tripMode; collection = sessionCollection;
    startedAt = startTime; details = Map.of(metadata);
    route..clear()..addAll(initialRoute); distanceKm = initialDistance;
    position = null; sharing = false; sharingUntil = null; error = null;
    _snapshotAt = null; active = true;
    final token = ++_epoch;
    try {
    _gps = (_testPositions?.call(settings()) ?? Geolocator.getPositionStream(locationSettings: settings())).listen(
      (p) => _enqueue(p, token),
      onError: (Object e) { if (active && token == _epoch) { error = 'GPS'; notifyListeners(); } },
      cancelOnError: false,
    );
    // Web fallback only. Android uses its uninterrupted foreground GPS stream.
    if (kIsWeb) {
      _poll = Timer.periodic(const Duration(seconds: 3), (_) async {
        if (_polling || !active || token != _epoch) return;
        _polling = true;
        try {
          final p = await Geolocator.getCurrentPosition(locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.bestForNavigation, timeLimit: Duration(seconds:10)));
          _enqueue(p, token);
        } catch (_) {} finally { _polling = false; }
      });
    }
    if (initialPosition != null) _enqueue(initialPosition, token);
    notifyListeners();
    } catch (_) {
      active=false;sharing=false;++_epoch;_poll?.cancel();_expiry?.cancel();
      await _gps?.cancel();_gps=null;notifyListeners();rethrow;
    }
  }

  void updateDetails(Map<String,dynamic> value) {
    if (active) details = Map.of(value);
  }

  void setSharing(bool enabled, {DateTime? until}) {
    if (!active) return;
    sharing = enabled; sharingUntil = until; _expiry?.cancel();
    if (enabled && until != null) {
      final delay = until.difference(DateTime.now());
      _expiry = Timer(delay.isNegative ? Duration.zero : delay, () => unawaited(mode == 'location' ? stop() : stopSharing()));
    }
    notifyListeners();
    final p = position;
    if (!_testing && enabled && p != null) unawaited(GuardianShare.publish(p.latitude,p.longitude,route,mode));
  }

  Future<void> stopSharing() async {
    if (!active || !sharing) return;
    final owner = uid;
    sharing = false; sharingUntil = null; _expiry?.cancel();
    notifyListeners();
    if (owner == null || _currentUid != owner) return;
    try { await GuardianShare.stop(); } catch (_) {}
    if (mode == 'safe_hiking') { try { await HikingSearchRecord.stop(owner); } catch (_) {} }
    try {
      await FirebaseFirestore.instance.collection('airsoft_live_locations').doc(owner).delete().timeout(const Duration(seconds:4));
    } catch (_) {}
  }

  void _enqueue(Position p, int token) {
    // Bound work: slow/offline writes must not accumulate an unbounded GPS queue.
    if (_inflight != null || !active || token != _epoch) return;
    final work = _accept(p,token);
    _inflight = work;
    unawaited(work.catchError((Object _) {
      if(active && token==_epoch) {error='tracking';notifyListeners();}
    }).whenComplete(() { if(identical(_inflight,work)) _inflight=null; }));
  }

  Future<void> _accept(Position p, int token) async {
    bool valid() => active && token == _epoch && _currentUid == uid;
    if (!valid() || !p.latitude.isFinite || !p.longitude.isFinite) return;
    if (position != null && !p.timestamp.isAfter(position!.timestamp)) return;
    position = p; error = null;
    final point = LatLng(p.latitude,p.longitude);
    final meters = route.isEmpty ? 0.0 : const Distance().as(LengthUnit.Meter,route.last,point);
    if (route.isEmpty || meters >= (mode == 'safe_hiking' ? 5 : 1)) {
      route.add(point); distanceKm += meters / 1000;
      if (route.length > 4000) route.removeAt(0);
    }
    notifyListeners();
    final owner = uid!;
    if (mode == 'safe_hiking') {
      try { await HikingSearchRecord.append(owner,p); } catch (_) { error = 'storage'; }
    }
    if (!valid()) return;
    if (sharing) unawaited(GuardianShare.publish(p.latitude,p.longitude,List.of(route),mode));
    if (collection.isNotEmpty) {
      final payload = <String,dynamic>{
        'uid':owner,'latitude':p.latitude,'longitude':p.longitude,'accuracy':p.accuracy,
        'speed':p.speed,'heading':p.heading,'active':true,
        'observedAt':Timestamp.fromDate(p.timestamp),'updatedAt':FieldValue.serverTimestamp(),
      };
      if (mode == 'safe_hiking' && (_snapshotAt == null || DateTime.now().difference(_snapshotAt!) >= const Duration(minutes:5))) {
        _snapshotAt = DateTime.now();
        payload.addAll({'routeSnapshotEncoded':route.map((p)=>'${p.latitude.toStringAsFixed(5)},${p.longitude.toStringAsFixed(5)}').join(';'),
          'routeDistanceKm':distanceKm,'clientRouteSavedAt':Timestamp.fromDate(DateTime.now())});
      }
      try { await FirebaseFirestore.instance.collection(collection).doc(owner).set(payload,SetOptions(merge:true)).timeout(const Duration(seconds:4)); }
      catch (_) { if (valid()) error = 'network'; }
    }
    if (!valid() || !sharing) return;
    try {
      await FirebaseFirestore.instance.collection('airsoft_live_locations').doc(owner).set({
        'uid':owner,'latitude':p.latitude,'longitude':p.longitude,'accuracy':p.accuracy,
        'updatedAt':FieldValue.serverTimestamp(),
        'expiresAt':Timestamp.fromDate(sharingUntil ?? DateTime.now().add(const Duration(hours:24))),
      },SetOptions(merge:true)).timeout(const Duration(seconds:4));
    } catch (_) { if (valid()) error = 'network'; }
  }

  Future<void> stop() async {
    if (!active) return;
    _stopping = true;
    final owner = uid, oldMode = mode, oldCollection = collection;
    // Invalidate callbacks before any asynchronous cleanup.
    active = false; sharing = false; sharingUntil = null; ++_epoch;
    _poll?.cancel(); _expiry?.cancel(); final gps = _gps; _gps = null;
    notifyListeners();
    await gps?.cancel();
    try { await _inflight; } catch (_) {}
    _inflight = null;
    if (_testing || owner == null || _currentUid != owner) { _stopping=false; return; }
    try { await GuardianShare.stop(); } catch (_) {}
    if (oldMode == 'safe_hiking') { try { await HikingSearchRecord.stop(owner,finish:true); } catch (_) {} }
    try { await FirebaseFirestore.instance.collection('airsoft_live_locations').doc(owner).delete().timeout(const Duration(seconds:4)); } catch (_) {}
    if (oldCollection.isNotEmpty) {
      try { await FirebaseFirestore.instance.collection(oldCollection).doc(owner).set({
        'uid':owner,'active':false,'sharingActive':false,'endedAt':FieldValue.serverTimestamp(),
        'updatedAt':FieldValue.serverTimestamp(),
      },SetOptions(merge:true)).timeout(const Duration(seconds:4)); } catch (_) {}
    }
    _stopping = false;
  }
}
