// lib/core/extensions/list_extensions.dart
extension ListExtension<T> on List<T> {
  /// Safely gets element at index, returns null if out of bounds
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Splits list into chunks of specified size
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size > length) ? length : i + size));
    }
    return chunks;
  }

  /// Returns random element from list
  T? random() {
    if (isEmpty) return null;
    final random = DateTime.now().millisecondsSinceEpoch % length;
    return this[random];
  }

  /// Groups list items by a key function
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keyFunction(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Returns distinct elements
  List<T> distinct() {
    return toSet().toList();
  }

  /// Returns list with elements that satisfy condition
  List<T> whereNotNull() {
    return where((e) => e != null).toList();
  }
}

// lib/core/extensions/int_extensions.dart
extension IntExtension on int {
  /// Formats integer with commas (1000 -> 1,000)
  String formatWithCommas() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
    );
  }

  /// Converts rating to difficulty label
  String toDifficultyLabel() {
    if (this < 1200) return 'Beginner';
    if (this < 1600) return 'Intermediate';
    if (this < 2000) return 'Advanced';
    return 'Expert';
  }

  /// Converts seconds to duration string
  String toDurationString() {
    final hours = this ~/ 3600;
    final minutes = (this % 3600) ~/ 60;
    final seconds = this % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Returns ordinal string (1 -> 1st, 2 -> 2nd)
  String toOrdinal() {
    if (this % 100 >= 11 && this % 100 <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }

  /// Clamps value between min and max
  int clampTo(int min, int max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}