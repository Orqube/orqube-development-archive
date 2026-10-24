import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/connection_invite.dart';

class InviteInbox {
  static final pending = ValueNotifier<ConnectionInvite?>(null);
  static const _key = 'pending_connection_invite_v1';
  static StreamSubscription<Uri>? _subscription;
  static final _links = AppLinks();
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) pending.value = ConnectionInvite.parse(saved);
    if (kIsWeb) {
      await receive(Uri.base);
    } else {
      _subscription ??= _links.uriLinkStream.listen((uri) { unawaited(receive(uri)); }, onError: (Object _) {});
      try { final uri = await _links.getInitialLink(); if (uri != null) await receive(uri); } catch (_) { /* Manual paste remains available. */ }
    }
  }
  static Future<void> receive(Uri uri) async {
    final invite = ConnectionInvite.parse(uri.toString());
    if (invite == null) return;
    await (await SharedPreferences.getInstance()).setString(_key, invite.link('en'));
    pending.value = invite;
  }
  static Future<void> clear() async {
    await (await SharedPreferences.getInstance()).remove(_key);
    pending.value = null;
  }
}
