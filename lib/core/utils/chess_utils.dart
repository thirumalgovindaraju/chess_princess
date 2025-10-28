// lib/core/utils/chess_utils.dart
class ChessUtils {
  /// Gets square color (true = light, false = dark)
  static bool isLightSquare(String square) {
    if (square.length != 2) return true;
    final file = square[0].codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = square[1].codeUnitAt(0) - '1'.codeUnitAt(0);
    return (file + rank) % 2 == 0;
  }

  /// Validates if move is in algebraic notation
  static bool isValidMoveNotation(String move) {
    // Simplified validation
    final regex = RegExp(
        r'^[NBRQK]?[a-h]?[1-8]?x?[a-h][1-8](?:=[NBRQ])?[+#]?$');
    return regex.hasMatch(move);
  }

  /// Converts file letter to index (a=0, h=7)
  static int fileToIndex(String file) {
    return file.codeUnitAt(0) - 'a'.codeUnitAt(0);
  }

  /// Converts rank number to index (1=0, 8=7)
  static int rankToIndex(String rank) {
    return rank.codeUnitAt(0) - '1'.codeUnitAt(0);
  }

  /// Gets opposite color
  static String oppositeColor(String color) {
    return color == 'white' ? 'black' : 'white';
  }
}