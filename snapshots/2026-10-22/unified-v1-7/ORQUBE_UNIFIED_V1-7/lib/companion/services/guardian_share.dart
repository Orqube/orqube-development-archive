import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
class ShareDelivery {
  final DateTime? confirmedAt;
  final bool failed;
  const ShareDelivery({this.confirmedAt,this.failed=false});
}
class GuardianShare {
  static final delivery = ValueNotifier<ShareDelivery>(const ShareDelivery());
  static int _epoch = 0;
  static void beginSession() { _epoch++; _last = null; _lastPoint = null; delivery.value = const ShareDelivery(); }
  static DateTime? _last;
  static LatLng? _lastPoint;
  static String? _lastUid;
  static final db = FirebaseFirestore.instance;
  static Future<void> publish(double lat, double lng, List<LatLng> route, String mode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !user.emailVerified) return;
    if (_lastUid != user.uid) { _epoch++; _last = null; _lastPoint = null; _lastUid = user.uid; delivery.value = const ShareDelivery(); }
    final epoch = _epoch;
    final point = LatLng(lat, lng);
    final moved = _lastPoint == null || const Distance().as(LengthUnit.Meter, _lastPoint!, point) >= 2;
    final interval = Duration(seconds: moved ? 5 : 15);
    if (_last != null && DateTime.now().difference(_last!) < interval) return;
    _lastPoint = point;
    _last = DateTime.now();
    try {
      await db.collection('safety_shares').doc(user.uid).set({
        'ownerUid': user.uid, 'active': true, 'mode': mode,
        'latitude': lat, 'longitude': lng,
        'route': route.skip(route.length > 500 ? route.length - 500 : 0).map((p) => GeoPoint(p.latitude, p.longitude)).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 2))),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 4));
      if (_epoch == epoch && FirebaseAuth.instance.currentUser?.uid == user.uid) delivery.value = ShareDelivery(confirmedAt:DateTime.now());
    } catch (_) { if (_epoch == epoch && FirebaseAuth.instance.currentUser?.uid == user.uid) { _last = null; delivery.value = ShareDelivery(confirmedAt:delivery.value.confirmedAt,failed:true); } }
  }
  static Future<void> stop() async {
    _epoch++; delivery.value = const ShareDelivery();
    _last = null; _lastPoint = null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await db.collection('safety_shares').doc(uid).set({'ownerUid': uid, 'active': false, 'route': [], 'viewerUids': [], 'searchViewerUids': [], 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true)).timeout(const Duration(seconds: 4));
  }
}
