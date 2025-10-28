// lib/models/chess_board.dart

import 'package:flutter/material.dart';
import 'position.dart';

// Enums for piece types and colors
enum PieceType { king, queen, rook, bishop, knight, pawn }
enum PieceColor { white, black }

// Chess piece class with full features
class ChessPiece {
  final PieceType type;
  final PieceColor color;
  Position position;
  bool hasMoved;

  ChessPiece(
      this.type,
      this.color, {
        required this.position,
        this.hasMoved = false,
      });

  // Compatibility properties for existing code
  String get typeString {
    switch (type) {
      case PieceType.king:
        return 'k';
      case PieceType.queen:
        return 'q';
      case PieceType.rook:
        return 'r';
      case PieceType.bishop:
        return 'b';
      case PieceType.knight:
        return 'n';
      case PieceType.pawn:
        return 'p';
    }
  }

  bool get isWhite => color == PieceColor.white;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChessPiece && other.type == type && other.color == color;
  }

  @override
  int get hashCode => type.hashCode ^ color.hashCode;

  @override
  String toString() => '${color.name} ${type.name}';

  int get value {
    switch (type) {
      case PieceType.pawn:
        return 100;
      case PieceType.knight:
        return 320;
      case PieceType.bishop:
        return 330;
      case PieceType.rook:
        return 500;
      case PieceType.queen:
        return 900;
      case PieceType.king:
        return 20000;
    }
  }

  String get symbol {
    switch (type) {
      case PieceType.king:
        return color == PieceColor.white ? '♔' : '♚';
      case PieceType.queen:
        return color == PieceColor.white ? '♕' : '♛';
      case PieceType.rook:
        return color == PieceColor.white ? '♖' : '♜';
      case PieceType.bishop:
        return color == PieceColor.white ? '♗' : '♝';
      case PieceType.knight:
        return color == PieceColor.white ? '♘' : '♞';
      case PieceType.pawn:
        return color == PieceColor.white ? '♙' : '♟';
    }
  }

  String get name {
    switch (type) {
      case PieceType.king:
        return 'King';
      case PieceType.queen:
        return 'Queen';
      case PieceType.rook:
        return 'Rook';
      case PieceType.bishop:
        return 'Bishop';
      case PieceType.knight:
        return 'Knight';
      case PieceType.pawn:
        return 'Pawn';
    }
  }

  String get algebraicSymbol {
    switch (type) {
      case PieceType.king:
        return 'K';
      case PieceType.queen:
        return 'Q';
      case PieceType.rook:
        return 'R';
      case PieceType.bishop:
        return 'B';
      case PieceType.knight:
        return 'N';
      case PieceType.pawn:
        return '';
    }
  }

  ChessPiece copy() {
    return ChessPiece(
      type,
      color,
      position: position,
      hasMoved: hasMoved,
    );
  }

  factory ChessPiece.fromFen(String fen, Position position) {
    PieceColor color =
    fen.toUpperCase() == fen ? PieceColor.white : PieceColor.black;

    switch (fen.toLowerCase()) {
      case 'k':
        return ChessPiece(PieceType.king, color, position: Position(row: position.row, col: position.col));
      case 'q':
        return ChessPiece(PieceType.queen, color, position: Position(row: position.row, col: position.col));
      case 'r':
        return ChessPiece(PieceType.rook, color, position: Position(row: position.row, col: position.col));
      case 'b':
        return ChessPiece(PieceType.bishop, color, position: Position(row: position.row, col: position.col));
      case 'n':
        return ChessPiece(PieceType.knight, color, position: Position(row: position.row, col: position.col));
      case 'p':
        return ChessPiece(PieceType.pawn, color, position: Position(row: position.row, col: position.col));
      default:
        throw ArgumentError('Invalid FEN piece notation: $fen');
    }
  }

  String toFen() {
    String symbol = algebraicSymbol.toLowerCase();
    if (type == PieceType.pawn) {
      symbol = 'p';
    }
    return color == PieceColor.white ? symbol.toUpperCase() : symbol;
  }

  factory ChessPiece.fromString(String typeStr, bool isWhite, Position position) {
    final color = isWhite ? PieceColor.white : PieceColor.black;
    switch (typeStr.toLowerCase()) {
      case 'k':
        return ChessPiece(PieceType.king, color, position: Position(row: position.row, col: position.col));
      case 'q':
        return ChessPiece(PieceType.queen, color, position: Position(row: position.row, col: position.col));
      case 'r':
        return ChessPiece(PieceType.rook, color, position: Position(row: position.row, col: position.col));
      case 'b':
        return ChessPiece(PieceType.bishop, color, position: Position(row: position.row, col: position.col));
      case 'n':
        return ChessPiece(PieceType.knight, color, position: Position(row: position.row, col: position.col));
      case 'p':
        return ChessPiece(PieceType.pawn, color, position: Position(row: position.row, col: position.col));
      default:
        throw ArgumentError('Invalid piece type: $typeStr');
    }
  }
}

// Chess board class
class ChessBoard {
  List<List<ChessPiece?>> squares;
  bool isWhiteTurn;
  List<String> moveHistory;
  List<ChessPiece> capturedPieces;
  bool isGameOver;
  PieceColor? winner;
  List<Function(ChessPiece)> _captureListeners = [];

  ChessBoard({
    required this.squares,
    this.isWhiteTurn = true,
    List<String>? moveHistory,
    List<ChessPiece>? capturedPieces,
    this.isGameOver = false,
    this.winner,
  })  : moveHistory = moveHistory ?? [],
        capturedPieces = capturedPieces ?? [];

  // Compatibility getters
  PieceColor get currentPlayer =>
      isWhiteTurn ? PieceColor.white : PieceColor.black;

  factory ChessBoard.initial() {
    final squares = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));

    // Black pieces (row 0 and 1)
    squares[0][0] = ChessPiece(PieceType.rook, PieceColor.black, position: Position(row: 0, col: 0));
    squares[0][1] = ChessPiece(PieceType.knight, PieceColor.black, position: Position(row: 0, col: 1));
    squares[0][2] = ChessPiece(PieceType.bishop, PieceColor.black, position: Position(row: 0, col: 2));
    squares[0][3] = ChessPiece(PieceType.queen, PieceColor.black, position: Position(row: 0, col: 3));
    squares[0][4] = ChessPiece(PieceType.king, PieceColor.black, position: Position(row: 0, col: 4));
    squares[0][5] = ChessPiece(PieceType.bishop, PieceColor.black, position: Position(row: 0, col: 5));
    squares[0][6] = ChessPiece(PieceType.knight, PieceColor.black, position: Position(row: 0, col: 6));
    squares[0][7] = ChessPiece(PieceType.rook, PieceColor.black, position: Position(row: 0, col: 7));
    for (int col = 0; col < 8; col++) {
      squares[1][col] = ChessPiece(PieceType.pawn, PieceColor.black, position: Position(row: 1, col: col));
    }

    // White pieces (row 6 and 7)
    for (int col = 0; col < 8; col++) {
      squares[6][col] = ChessPiece(PieceType.pawn, PieceColor.white, position: Position(row: 6, col: col));
    }
    squares[7][0] = ChessPiece(PieceType.rook, PieceColor.white, position: Position(row: 7, col: 0));
    squares[7][1] = ChessPiece(PieceType.knight, PieceColor.white, position: Position(row: 7, col: 1));
    squares[7][2] = ChessPiece(PieceType.bishop, PieceColor.white, position: Position(row: 7, col: 2));
    squares[7][3] = ChessPiece(PieceType.queen, PieceColor.white, position: Position(row: 7, col: 3));
    squares[7][4] = ChessPiece(PieceType.king, PieceColor.white, position: Position(row: 7, col: 4));
    squares[7][5] = ChessPiece(PieceType.bishop, PieceColor.white, position: Position(row: 7, col: 5));
    squares[7][6] = ChessPiece(PieceType.knight, PieceColor.white, position: Position(row: 7, col: 6));
    squares[7][7] = ChessPiece(PieceType.rook, PieceColor.white, position: Position(row: 7, col: 7));

    return ChessBoard(squares: squares, isWhiteTurn: true);
  }

  ChessBoard copy() {
    final newSquares = List.generate(8, (row) {
      return List.generate(8, (col) {
        final piece = squares[row][col];
        return piece?.copy();
      });
    });

    return ChessBoard(
      squares: newSquares,
      isWhiteTurn: isWhiteTurn,
      moveHistory: List.from(moveHistory),
      capturedPieces: capturedPieces.map((p) => p.copy()).toList(),
      isGameOver: isGameOver,
      winner: winner,
    );
  }

  bool makeMove(Position from, Position to, {PieceType? promotionPiece}) {
    final piece = getPieceAt(from);
    if (piece == null || piece.isWhite != isWhiteTurn) {
      return false;
    }

    // Check if move is legal
    if (!isMoveLegal(from, to)) {
      return false;
    }

    final capturedPiece = getPieceAt(to);
    if (capturedPiece != null) {
      capturedPieces.add(capturedPiece);
      _notifyCapture(capturedPiece);
    }

    // Handle pawn promotion
    if (piece.type == PieceType.pawn && promotionPiece != null) {
      if ((piece.color == PieceColor.white && to.row == 0) ||
          (piece.color == PieceColor.black && to.row == 7)) {
        final promotedPiece = ChessPiece(
          promotionPiece,
          piece.color,
          position: to,
          hasMoved: true,
        );
        squares[to.row][to.col] = promotedPiece;
        squares[from.row][from.col] = null;
      } else {
        piece.position = to;
        squares[to.row][to.col] = piece;
        squares[from.row][from.col] = null;
        piece.hasMoved = true;
      }
    } else {
      piece.position = to;
      squares[to.row][to.col] = piece;
      squares[from.row][from.col] = null;
      piece.hasMoved = true;
    }

    final moveNotation = _positionToNotation(from) + _positionToNotation(to);
    moveHistory.add(moveNotation);

    isWhiteTurn = !isWhiteTurn;
    return true;
  }

  factory ChessBoard.fromFen(String fen) {
    final parts = fen.split(' ');
    final position = parts[0];
    final turn = parts.length > 1 ? parts[1] : 'w';

    final squares = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));

    final rows = position.split('/');
    for (int row = 0; row < 8 && row < rows.length; row++) {
      int col = 0;
      for (int i = 0; i < rows[row].length; i++) {
        final char = rows[row][i];
        if (char.contains(RegExp(r'[1-8]'))) {
          col += int.parse(char);
        } else {
          squares[row][col] = ChessPiece.fromFen(char, Position(row: row, col: col));
          col++;
        }
      }
    }

    return ChessBoard(
      squares: squares,
      isWhiteTurn: turn == 'w',
    );
  }

  String toFEN() {
    String fenPosition = '';

    for (int row = 0; row < 8; row++) {
      int emptyCount = 0;

      for (int col = 0; col < 8; col++) {
        final piece = squares[row][col];

        if (piece == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            fenPosition += emptyCount.toString();
            emptyCount = 0;
          }
          fenPosition += piece.toFen();
        }
      }

      if (emptyCount > 0) {
        fenPosition += emptyCount.toString();
      }

      if (row < 7) {
        fenPosition += '/';
      }
    }

    String turn = isWhiteTurn ? 'w' : 'b';
    return '$fenPosition $turn - - 0 1';
  }

  // Get all pieces on the board
  List<ChessPiece> getAllPieces() {
    List<ChessPiece> pieces = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = squares[row][col];
        if (piece != null) {
          pieces.add(piece);
        }
      }
    }
    return pieces;
  }

  void movePiece(Position from, Position to) {
    final piece = squares[from.row][from.col];
    if (piece == null) return;

    final capturedPiece = squares[to.row][to.col];
    if (capturedPiece != null) {
      capturedPieces.add(capturedPiece);
      _notifyCapture(capturedPiece);
    }

    piece.position = to;
    squares[to.row][to.col] = piece;
    squares[from.row][from.col] = null;
    piece.hasMoved = true;
    isWhiteTurn = !isWhiteTurn;
  }

  ChessPiece? getPieceAt(Position pos) {
    if (pos.row < 0 || pos.row >= 8 || pos.col < 0 || pos.col >= 8) {
      return null;
    }
    return squares[pos.row][pos.col];
  }

  void setPieceAt(Position pos, ChessPiece? piece) {
    if (pos.row < 0 || pos.row >= 8 || pos.col < 0 || pos.col >= 8) {
      return;
    }
    if (piece != null) {
      piece.position = pos;
    }
    squares[pos.row][pos.col] = piece;
  }

  bool isValidPosition(Position pos) {
    return pos.row >= 0 && pos.row < 8 && pos.col >= 0 && pos.col < 8;
  }

  void addCaptureListener(Function(ChessPiece) listener) {
    _captureListeners.add(listener);
  }

  void _notifyCapture(ChessPiece piece) {
    for (var listener in _captureListeners) {
      listener(piece);
    }
  }

  bool undoLastMove() {
    if (moveHistory.isEmpty) return false;
    moveHistory.removeLast();
    isWhiteTurn = !isWhiteTurn;
    if (capturedPieces.isNotEmpty) {
      capturedPieces.removeLast();
    }
    return true;
  }

  void reset() {
    final initial = ChessBoard.initial();
    squares = initial.squares;
    isWhiteTurn = true;
    moveHistory.clear();
    capturedPieces.clear();
    isGameOver = false;
    winner = null;
    _captureListeners.clear();
  }

  // Check if a position is under attack by the specified color
  bool isPositionUnderAttack(Position position, PieceColor defenderColor) {
    PieceColor attackerColor =
    defenderColor == PieceColor.white ? PieceColor.black : PieceColor.white;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = getPieceAt(Position(row: row, col: col));
        if (piece != null && piece.color == attackerColor) {
          if (_canPieceAttackPosition(piece, Position(row: row, col: col), position)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _canPieceAttackPosition(ChessPiece piece, Position from, Position to) {
    int rowDiff = (to.row - from.row).abs();
    int colDiff = (to.col - from.col).abs();

    switch (piece.type) {
      case PieceType.pawn:
        int direction = piece.color == PieceColor.white ? -1 : 1;
        return (to.row - from.row == direction) && colDiff == 1;

      case PieceType.knight:
        return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);

      case PieceType.bishop:
        if (rowDiff != colDiff) return false;
        return _isPathClear(from, to);

      case PieceType.rook:
        if (from.row != to.row && from.col != to.col) return false;
        return _isPathClear(from, to);

      case PieceType.queen:
        if (from.row != to.row && from.col != to.col && rowDiff != colDiff) {
          return false;
        }
        return _isPathClear(from, to);

      case PieceType.king:
        return rowDiff <= 1 && colDiff <= 1;
    }
  }

  bool _isPathClear(Position from, Position to) {
    int rowStep = (to.row - from.row).sign;
    int colStep = (to.col - from.col).sign;

    int currentRow = from.row + rowStep;
    int currentCol = from.col + colStep;

    while (currentRow != to.row || currentCol != to.col) {
      if (getPieceAt(Position(row: currentRow, col: currentCol)) != null) {
        return false;
      }
      currentRow += rowStep;
      currentCol += colStep;
    }

    return true;
  }

  // Check if king is in check
  bool isKingInCheck(PieceColor kingColor) {
    Position? kingPos = _findKingPosition(kingColor);
    if (kingPos == null) return false;
    return isPositionUnderAttack(kingPos, kingColor);
  }

  Position? _findKingPosition(PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = getPieceAt(Position(row: row, col: col));
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == color) {
          return Position(row: row, col: col);
        }
      }
    }
    return null;
  }

  // Check if move would leave king in check
  bool wouldLeaveKingInCheck(Position from, Position to) {
    final piece = getPieceAt(from);
    if (piece == null) return true;

    final capturedPiece = getPieceAt(to);

    // Simulate the move
    squares[from.row][from.col] = null;
    squares[to.row][to.col] = piece;

    bool inCheck = isKingInCheck(piece.color);

    // Undo the move
    squares[from.row][from.col] = piece;
    squares[to.row][to.col] = capturedPiece;

    return inCheck;
  }

  // Check if a move is legal
  bool isMoveLegal(Position from, Position to) {
    final piece = getPieceAt(from);
    if (piece == null) return false;

    // Check if it's the correct player's turn
    if (piece.color != currentPlayer) return false;

    // Check if destination has own piece
    final destPiece = getPieceAt(to);
    if (destPiece != null && destPiece.color == piece.color) return false;

    // Check piece-specific movement rules
    if (!_isValidPieceMove(piece, from, to)) return false;

    // Check if move would leave king in check
    if (wouldLeaveKingInCheck(from, to)) return false;

    return true;
  }

  bool _isValidPieceMove(ChessPiece piece, Position from, Position to) {
    int rowDiff = to.row - from.row;
    int colDiff = to.col - from.col;
    int absRowDiff = rowDiff.abs();
    int absColDiff = colDiff.abs();

    switch (piece.type) {
      case PieceType.pawn:
        return _isValidPawnMove(piece, from, to, rowDiff, absRowDiff, absColDiff);

      case PieceType.knight:
        return (absRowDiff == 2 && absColDiff == 1) ||
            (absRowDiff == 1 && absColDiff == 2);

      case PieceType.bishop:
        return absRowDiff == absColDiff && _isPathClear(from, to);

      case PieceType.rook:
        return (rowDiff == 0 || colDiff == 0) && _isPathClear(from, to);

      case PieceType.queen:
        return (rowDiff == 0 || colDiff == 0 || absRowDiff == absColDiff) &&
            _isPathClear(from, to);

      case PieceType.king:
        return absRowDiff <= 1 && absColDiff <= 1;
    }
  }

  bool _isValidPawnMove(ChessPiece piece, Position from, Position to,
      int rowDiff, int absRowDiff, int absColDiff) {
    int direction = piece.color == PieceColor.white ? -1 : 1;
    int colDiff = to.col - from.col;
    final destPiece = getPieceAt(to);

    // Forward move
    if (colDiff == 0 && destPiece == null) {
      if (rowDiff == direction) return true;
      if (!piece.hasMoved && rowDiff == direction * 2) {
        Position intermediatePos = Position(row: from.row + direction, col: from.col);
        return getPieceAt(intermediatePos) == null;
      }
    }

    // Capture move
    if (absColDiff == 1 && rowDiff == direction && destPiece != null) {
      return true;
    }

    return false;
  }

  // Check for stalemate
  bool isStalemate() {
    if (isKingInCheck(currentPlayer)) {
      return false;
    }

    return !_hasLegalMoves(currentPlayer);
  }

  // Check for checkmate
  bool isCheckmate() {
    if (!isKingInCheck(currentPlayer)) {
      return false;
    }

    return !_hasLegalMoves(currentPlayer);
  }

  bool _hasLegalMoves(PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = getPieceAt(Position(row: row, col: col));
        if (piece != null && piece.color == color) {
          for (int destRow = 0; destRow < 8; destRow++) {
            for (int destCol = 0; destCol < 8; destCol++) {
              Position dest = Position(row: destRow, col: destCol);
              if (isMoveLegal(Position(row: row, col: col), dest)) {
                return true;
              }
            }
          }
        }
      }
    }
    return false;
  }

  String _positionToNotation(Position pos) {
    const files = 'abcdefgh';
    return '${files[pos.col]}${8 - pos.row}';
  }

  @override
  String toString() {
    String result = '';
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = squares[row][col];
        result += piece != null ? piece.symbol : '.';
        result += ' ';
      }
      result += '\n';
    }
    return result;
  }
}

// ============================================================================
// CHESS BOARD STYLES
// ============================================================================

class ChessBoardStyles {
  static const Color lightSquare = Color(0xFFE8D7B8);
  static const Color darkSquare = Color(0xFFAA7B4D);
  static const Color boardBorder = Color(0xFF654321);
  static const Color boardBackground = Color(0xFF3D2817);

  static const Color whitePieceMain = Color(0xFFFFFAF0);
  static const Color blackPieceMain = Color(0xFF2C2C2C);

  static const Color selectedSquare = Color(0xFFFFEB3B);
  static const Color validMoveSquare = Color(0xFF81C784);

  static BoxDecoration getBoardDecoration() {
    return BoxDecoration(
      color: boardBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: boardBorder,
        width: 8,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 24,
          offset: Offset(0, 12),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Color(0x20000000),
          blurRadius: 48,
          offset: Offset(0, 24),
          spreadRadius: -8,
        ),
      ],
    );
  }

  static BoxDecoration getSquareDecoration(bool isLight,
      {bool isSelected = false, bool isValidMove = false}) {
    Color baseColor;
    List<Color> gradientColors;

    if (isSelected) {
      baseColor = selectedSquare;
      gradientColors = [
        selectedSquare.withValues(alpha: 0.7),
        selectedSquare,
        selectedSquare.withValues(alpha: 0.8),
      ];
    } else if (isValidMove) {
      baseColor = validMoveSquare;
      gradientColors = [
        validMoveSquare.withValues(alpha: 0.5),
        validMoveSquare.withValues(alpha: 0.6),
        validMoveSquare.withValues(alpha: 0.5),
      ];
    } else if (isLight) {
      baseColor = lightSquare;
      gradientColors = const [
        Color(0xFFF0E0C8),
        Color(0xFFE8D7B8),
        Color(0xFFE0CFA8),
      ];
    } else {
      baseColor = darkSquare;
      gradientColors = const [
        Color(0xFFB88B5E),
        Color(0xFFAA7B4D),
        Color(0xFF9C6B3D),
      ];
    }

    return BoxDecoration(
      color: baseColor,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  static TextStyle getPieceStyle(bool isWhite, double size) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: isWhite ? whitePieceMain : blackPieceMain,
      height: 1.0,
      shadows: [
        Shadow(
          color: isWhite ? const Color(0x60000000) : const Color(0x80000000),
          offset: const Offset(2, 3),
          blurRadius: 4,
        ),
        if (isWhite) ...[
          const Shadow(
            color: Color(0x40FFFFFF),
            offset: Offset(-1, -1),
            blurRadius: 2,
          ),
          const Shadow(
            color: Color(0x20FFFFFF),
            offset: Offset(-2, -2),
            blurRadius: 4,
          ),
        ],
        Shadow(
          color: Colors.black.withValues(alpha: 0.2),
          offset: const Offset(1, 2),
          blurRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration? getPieceContainerDecoration(bool isWhite) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          isWhite ? const Color(0x10FFFFFF) : const Color(0x10000000),
          Colors.transparent,
        ],
      ),
    );
  }

  static TextStyle getCoordinateStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF654321),
      height: 1.0,
    );
  }

  static Widget getMoveIndicatorDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x88555555),
        border: Border.all(
          color: const Color(0xFFDDDDDD),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }

  static Widget getCaptureIndicatorRing(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xCCFF5252),
          width: 4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40FF0000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}