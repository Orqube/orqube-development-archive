import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Keeps one harmless Firestore listener alive for the lifetime of a web app.
///
/// Firebase Web SDK has had intermittent b815/ca9 target bookkeeping failures
/// when a cold WebChannel rapidly opens/closes transient listen targets. ORQUBE
/// touches Firestore from several nested Token Launch routes, so we establish a
/// public, read-only target once at startup and deliberately keep it alive.
///
/// The listener reads no private data and does not block app startup if the
/// network is temporarily unavailable.
class FirestoreWebGuard {
  FirestoreWebGuard._();

  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _bootstrapSubscription;
  static bool _started = false;

  static Future<void> start() async {
    if (!kIsWeb || _started) return;
    _started = true;

    final firstEvent = Completer<void>();

    try {
      _bootstrapSubscription = FirebaseFirestore.instance
          .collection('public_config')
          .doc('firestore_bootstrap')
          .snapshots(includeMetadataChanges: true)
          .listen(
        (_) {
          if (!firstEvent.isCompleted) firstEvent.complete();
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('FirestoreWebGuard listener warning: $error');
          if (!firstEvent.isCompleted) firstEvent.complete();
        },
        cancelOnError: false,
      );

      // Give the initial listen target a chance to finish its handshake, but
      // never make a temporary Firestore outage prevent ORQUBE from opening.
      await firstEvent.future.timeout(
        const Duration(seconds: 4),
        onTimeout: () {},
      );
    } catch (e) {
      debugPrint('FirestoreWebGuard startup warning: $e');
    }
  }

  /// Intentionally unused during normal app life. Keeping the target open is
  /// the guard. This exists only for tests/future controlled shutdown.
  static Future<void> stop() async {
    await _bootstrapSubscription?.cancel();
    _bootstrapSubscription = null;
    _started = false;
  }
}
