extension DoubleExtension on double {
  /// Formats to percentage string
  String toPercentage({int decimals = 0}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  /// Rounds to specified decimal places
  double roundTo(int places) {
    final mod = 10.0 * places;
    return (this * mod).round() / mod;
  }

  /// Formats rating with one decimal
  String toRatingString() {
    return toStringAsFixed(1);
  }

  /// Converts to progress value (0.0 to 1.0)
  double toProgress() {
    if (this < 0) return 0.0;
    if (this > 1) return 1.0;
    return this;
  }
}
