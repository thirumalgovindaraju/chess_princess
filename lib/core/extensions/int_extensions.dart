// lib/core/extensions/int_extensions.dart
extension DurationFormatting on int {
  String toDurationString() {
    final duration = Duration(seconds: this);
    final minutes = duration.inMinutes;
    final remainingSeconds = this % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}