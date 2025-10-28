import '../extensions/string_extensions.dart';

class ValidationUtils {
  /// Validates lesson title
  static String? validateLessonTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  /// Validates FEN string
  static String? validateFen(String? value) {
    if (value == null || value.isEmpty) {
      return 'FEN is required';
    }
    if (!value.isValidFen()) {
      return 'Invalid FEN format';
    }
    return null;
  }

  /// Validates puzzle difficulty
  static String? validateDifficulty(int? value) {
    if (value == null) {
      return 'Difficulty is required';
    }
    if (value < 1000 || value > 3000) {
      return 'Difficulty must be between 1000 and 3000';
    }
    return null;
  }

  /// Validates duration in seconds
  static String? validateDuration(int? value) {
    if (value == null) {
      return 'Duration is required';
    }
    if (value <= 0) {
      return 'Duration must be positive';
    }
    if (value > 7200) {
      return 'Duration must be less than 2 hours';
    }
    return null;
  }
}