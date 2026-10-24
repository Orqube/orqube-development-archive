/// An invitation identifies an account; it is never a location-access credential.
class ConnectionInvite {
  final String uid;
  const ConnectionInvite(this.uid);
  static bool validUid(String uid) => RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(uid);
  static ConnectionInvite? parse(String input, {bool allowId = false}) {
    final text = input.trim();
    if (allowId && validUid(text)) return ConnectionInvite(text);
    var uri = Uri.tryParse(text);
    if (uri == null || uri.userInfo.isNotEmpty) return null;
    final web = uri.scheme == 'https' && ['safe.orqubic.com', 'www.orqubic.com', 'orqubic.com', 'orqube-576e7.web.app', 'orqube-576e7.firebaseapp.com'].contains(uri.host) && !uri.hasPort && uri.path == '/';
    final app = uri.scheme == 'orqubesafe' && uri.host == 'invite' && uri.path.isEmpty && !uri.hasPort;
    if (!web && !app) return null;
    if (web && uri.query.isEmpty && uri.fragment.startsWith('/?')) {
      final fragment = Uri.tryParse(uri.fragment);
      if (fragment == null || fragment.path != '/') return null;
      uri = uri.replace(query: fragment.query, fragment: '');
    }
    if (uri.queryParametersAll['orqube_invite']?.length != 1) return null;
    final uid = uri.queryParameters['orqube_invite'] ?? '';
    return validUid(uid) ? ConnectionInvite(uid) : null;
  }
  String link(String language) => Uri.https('www.orqubic.com', '/', {'orqube_invite': uid, 'lang': language}).toString();
  String get appLink => Uri(scheme: 'orqubesafe', host: 'invite', queryParameters: {'orqube_invite': uid}).toString();
}
