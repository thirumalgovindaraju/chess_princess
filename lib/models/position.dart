// lib/models/position.dart

class Position {
  final int row;
  final int col;

  const Position({required this.row, required this.col});

  /// Create a Position from algebraic notation (e.g., 'e4', 'a1')
  factory Position.fromAlgebraic(String notation) {
    if (notation.length != 2) {
      throw ArgumentError('Invalid algebraic notation: $notation');
    }
    final col = notation.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final row = 8 - int.parse(notation[1]);
    return Position(row: row, col: col);
  }

  /// Convert Position to algebraic notation (e.g., 'e4', 'a1')
  String toAlgebraic() {
    final colChar = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rowNum = 8 - row;
    return '$colChar$rowNum';
  }

  /// Check if position is within the chess board bounds
  bool isValid() {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  /// Get the distance between two positions
  int distanceTo(Position other) {
    return (row - other.row).abs() + (col - other.col).abs();
  }

  /// Get the straight-line distance (for diagonal/straight moves)
  int chebyshevDistance(Position other) {
    return ((row - other.row).abs() > (col - other.col).abs())
        ? (row - other.row).abs()
        : (col - other.col).abs();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Position &&
              runtimeType == other.runtimeType &&
              row == other.row &&
              col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position(row: $row, col: $col, algebraic: ${toAlgebraic()})';
}