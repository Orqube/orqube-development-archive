class TripMetrics {
  static String elapsed(DateTime startedAt, DateTime now) {
    final elapsed = now.difference(startedAt);
    final seconds = elapsed.isNegative ? 0 : elapsed.inSeconds;
    return '${(seconds ~/ 3600).toString().padLeft(2,'0')}:${((seconds ~/ 60) % 60).toString().padLeft(2,'0')}:${(seconds % 60).toString().padLeft(2,'0')}';
  }
  /// A repeated callback carrying an old fix must not look like fresh GPS.
  static bool stale(DateTime observedAt, DateTime now) =>
    now.difference(observedAt) > const Duration(seconds:20) ||
    observedAt.difference(now) > const Duration(minutes:5);
}
