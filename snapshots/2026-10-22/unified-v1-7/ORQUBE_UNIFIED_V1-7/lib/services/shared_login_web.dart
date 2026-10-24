import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

const _hub = 'https://ullim.orqubic.com/api/sso';
bool _busy = false;
bool _started = false;

Future<Map<String, dynamic>> _request(String path,
    {String method = 'GET', Map<String, dynamic>? body}) async {
  final request = await html.HttpRequest.request('$_hub/$path',
    method: method, withCredentials: true,
    requestHeaders: body == null ? null : {'Content-Type': 'application/json'},
    sendData: body == null ? null : jsonEncode(body)).timeout(const Duration(seconds: 30));
  return Map<String, dynamic>.from(jsonDecode(request.responseText ?? '{}') as Map);
}

Future<void> _publish(User user) async {
  final idToken = await user.getIdToken();
  final refresh = user.refreshToken;
  if (idToken == null || refresh == null) return;
  await _request('session', method: 'POST', body: {
    'idToken': idToken, 'refreshToken': refresh,
  });
}

Future<void> _sync() async {
  if (_busy) return;
  _busy = true;
  try {
    final session = await _request('session');
    final user = FirebaseAuth.instance.currentUser;
    final remote = session['user'] as Map?;
    if (remote != null && remote['id'] != user?.uid) {
      final result = await _request('firebase', method: 'POST', body: {});
      final token = result['customToken'];
      if (token is String) await FirebaseAuth.instance.signInWithCustomToken(token);
    } else if (remote == null && session['signedOut'] == true && user != null) {
      await FirebaseAuth.instance.signOut();
    } else if (remote == null && user != null) {
      await _publish(user);
    }
  } catch (error) {
    // Network failures never erase local Firebase authentication.
    debugPrint('Shared sign-in temporarily unavailable: $error');
  } finally {
    _busy = false;
  }
}

Future<void> startSharedLogin() async {
  if (_started) return;
  _started = true;
  await _sync();
  var first = true;
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (first) { first = false; return; }
    if (_busy) return;
    _busy = true;
    try {
      if (user == null) {
        await _request('session', method: 'DELETE');
      } else {
        await _publish(user);
      }
    } catch (error) {
      debugPrint('Shared sign-in sync failed: $error');
    } finally { _busy = false; }
  });
  html.document.onVisibilityChange.listen((_) {
    if (html.document.visibilityState == 'visible') unawaited(_sync());
  });
  html.window.onFocus.listen((_) => unawaited(_sync()));
  Timer.periodic(const Duration(minutes: 15), (_) {
    if (html.document.visibilityState == 'visible') unawaited(_sync());
  });
}

Future<void> sharedSignOut() async {
  await _request('session', method: 'DELETE');
  await FirebaseAuth.instance.signOut();
}
