/// Shared presentation formatters for durations and counts.
class AppFormatters {
  AppFormatters._();

  /// Formats [seconds] as `m:ss` (e.g., `3:05`, or `0:00` for non-positive).
  static String durationSeconds(int seconds) {
    if (seconds <= 0) return '0:00';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  /// Formats [duration] as `m:ss`.
  static String duration(Duration duration) {
    final totalSecs = duration.inSeconds;
    if (totalSecs <= 0) return '0:00';
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
