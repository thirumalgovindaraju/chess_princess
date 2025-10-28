
import '../extensions/int_extensions.dart';

class FormatUtils {
  /// Formats chess move in standard notation
  static String formatMove(String move) {
    // Remove any non-alphanumeric characters
    final cleaned = move.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return cleaned;
  }

  /// Formats puzzle rating
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  /// Formats time duration
  static String formatDuration(int seconds) {
    return seconds.toDurationString();
  }

  /// Formats large numbers (1500 -> 1.5K)
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Formats score with percentage
  static String formatScore(int score, int total) {
    if (total == 0) return '0%';
    final percentage = (score / total * 100).toStringAsFixed(0);
    return '$score/$total ($percentage%)';
  }
}