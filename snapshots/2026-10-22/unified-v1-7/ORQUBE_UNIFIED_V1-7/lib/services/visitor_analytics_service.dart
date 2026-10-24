import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ORQUBE lightweight visitor analytics.
///
/// - No visitor counts are shown on user-facing screens.
/// - A random installation/browser id is stored locally.
/// - One device/browser counts once in cumulative unique visitors.
/// - One device/browser counts once per KST day in daily visitors.
/// - `lastSeen` is refreshed periodically so admins can estimate active users.
/// - This is operational analytics, not a replacement for Firebase/GA analytics.
class VisitorAnalyticsService {
  VisitorAnalyticsService._();

  static final VisitorAnalyticsService instance = VisitorAnalyticsService._();

  static const _prefsKey = 'orqube_visitor_installation_id';
  static const _heartbeatInterval = Duration(minutes: 2);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _heartbeat;
  StreamSubscription<User?>? _authSubscription;
  String? _installationId;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      var id = prefs.getString(_prefsKey);
      if (id == null || id.isEmpty) {
        id = _newId();
        await prefs.setString(_prefsKey, id);
      }
      _installationId = id;

      await _recordPresence();

      _heartbeat = Timer.periodic(
        _heartbeatInterval,
        (_) => unawaited(_recordPresence()),
      );

      _authSubscription = _auth.authStateChanges().listen(
        (_) => unawaited(_recordPresence()),
      );
    } catch (e) {
      // Analytics must never prevent ORQUBE from starting.
      debugPrint('VisitorAnalyticsService start skipped: $e');
    }
  }

  Future<void> stop() async {
    _heartbeat?.cancel();
    _heartbeat = null;
    await _authSubscription?.cancel();
    _authSubscription = null;
    _started = false;
  }

  Future<void> _recordPresence() async {
    final id = _installationId;
    if (id == null || id.isEmpty) return;

    try {
      final now = DateTime.now();
      final dayKey = _kstDayKey(now);
      final user = _auth.currentUser;
      final isGuest = user == null;
      final platform = _platformLabel();

      final deviceRef = _db.collection('visitor_devices').doc(id);
      final dailyRef = _db
          .collection('visitor_daily')
          .doc(dayKey)
          .collection('visitors')
          .doc(id);

      final batch = _db.batch();

      batch.set(
        deviceRef,
        {
          'visitorId': id,
          'firstSeen': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
          'isGuest': isGuest,
          'platform': platform,
        },
        SetOptions(merge: true),
      );

      batch.set(
        dailyRef,
        {
          'visitorId': id,
          'dayKey': dayKey,
          'firstSeen': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
          'isGuest': isGuest,
          'platform': platform,
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      debugPrint('Visitor analytics write skipped: $e');
    }
  }

  static String _kstDayKey(DateTime value) {
    final kst = value.toUtc().add(const Duration(hours: 9));
    String two(int n) => n.toString().padLeft(2, '0');
    return '${kst.year}-${two(kst.month)}-${two(kst.day)}';
  }

  static String _platformLabel() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  static String _newId() {
    final random = Random.secure();
    final now = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final tail = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '$now-$tail';
  }
}
