class LaunchDeepLink {
  const LaunchDeepLink._();

  static String inviteUrl(String projectId) {
    final id = Uri.encodeQueryComponent(projectId.trim());
    return 'https://www.orqubic.com/?launch=$id';
  }

  static String? projectIdFromUri(Uri uri) {
    final raw = uri.queryParameters['launch']?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  static String? get currentProjectId => projectIdFromUri(Uri.base);
}
