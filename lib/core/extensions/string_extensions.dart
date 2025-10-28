extension StringExtension on String {
  /// Capitalizes the first letter of the string
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalizes first letter of each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.capitalize())
        .join(' ');
  }

  /// Validates if string is a valid email
  bool isValidEmail() {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(this);
  }

// lib/core/extensions/string_extensions.dart


  bool isValidFen() {
    // Basic validation for Forsyth–Edwards Notation (FEN)
    final parts = split(' ');

    // FEN should have 6 parts (piece placement, active color, castling, en passant, halfmove, fullmove)
    if (parts.length != 6) return false;

    final board = parts[0];
    final boardRows = board.split('/');

    // Must have 8 rows
    if (boardRows.length != 8) return false;

    // Each row must sum to 8 columns (letters count as 1, digits as their value)
    for (final row in boardRows) {
      int count = 0;
      for (final char in row.split('')) {
        if (RegExp(r'[1-8]').hasMatch(char)) {
          count += int.parse(char);
        } else if (RegExp(r'[prnbqkPRNBQK]').hasMatch(char)) {
          count += 1;
        } else {
          return false; // Invalid character
        }
      }
      if (count != 8) return false;
    }

    // Passed all checks
    return true;
  }


  /// Converts string to chess square notation (e.g., "e4")
  bool isValidChessSquare() {
    if (length != 2) return false;
    final file = this[0];
    final rank = this[1];
    return file.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
        file.codeUnitAt(0) <= 'h'.codeUnitAt(0) &&
        rank.codeUnitAt(0) >= '1'.codeUnitAt(0) &&
        rank.codeUnitAt(0) <= '8'.codeUnitAt(0);
  }

  /// Truncates string to specified length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Removes all whitespace from string
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Checks if string contains only digits
  bool isNumeric() {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// Converts snake_case to camelCase
  String toCamelCase() {
    final parts = split('_');
    if (parts.isEmpty) return this;
    return parts.first + parts.skip(1).map((e) => e.capitalize()).join();
  }

  /// Converts camelCase to snake_case
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }
}