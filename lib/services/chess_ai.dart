// lib/services/chess_ai.dart
import 'dart:math';
import '../models/chess_board.dart';
import '../models/position.dart';

enum AIDifficulty { easy, medium, hard }

class ChessAI {
  final Random _random = Random();
  int _nodesEvaluated = 0;

  static const Map<String, int> pieceValues = {
    'p': 100,
    'n': 320,
    'b': 330,
    'r': 500,
    'q': 900,
    'k': 20000,
  };

  // Piece-Square Tables for positional evaluation
  static const List<List<int>> pawnTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5, 5, 10, 25, 25, 10, 5, 5],
    [0, 0, 0, 20, 20, 0, 0, 0],
    [5, -5, -10, 0, 0, -10, -5, 5],
    [5, 10, 10, -20, -20, 10, 10, 5],
    [0, 0, 0, 0, 0, 0, 0, 0]
  ];

  static const List<List<int>> knightTable = [
    [-50, -40, -30, -30, -30, -30, -40, -50],
    [-40, -20, 0, 0, 0, 0, -20, -40],
    [-30, 0, 10, 15, 15, 10, 0, -30],
    [-30, 5, 15, 20, 20, 15, 5, -30],
    [-30, 0, 15, 20, 20, 15, 0, -30],
    [-30, 5, 10, 15, 15, 10, 5, -30],
    [-40, -20, 0, 5, 5, 0, -20, -40],
    [-50, -40, -30, -30, -30, -30, -40, -50]
  ];

  static const List<List<int>> bishopTable = [
    [-20, -10, -10, -10, -10, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 10, 10, 5, 0, -10],
    [-10, 5, 5, 10, 10, 5, 5, -10],
    [-10, 0, 10, 10, 10, 10, 0, -10],
    [-10, 10, 10, 10, 10, 10, 10, -10],
    [-10, 5, 0, 0, 0, 0, 5, -10],
    [-20, -10, -10, -10, -10, -10, -10, -20]
  ];

  static const List<List<int>> rookTable = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [5, 10, 10, 10, 10, 10, 10, 5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [0, 0, 0, 5, 5, 0, 0, 0]
  ];

  static const List<List<int>> kingMiddleGameTable = [
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-20, -30, -30, -40, -40, -30, -30, -20],
    [-10, -20, -20, -20, -20, -20, -20, -10],
    [20, 20, 0, 0, 0, 0, 20, 20],
    [20, 30, 10, 0, 0, 10, 30, 20]
  ];

  /// Main entry point - gets best move based on difficulty
  Map<String, dynamic>? getBestMove(ChessBoard board, AIDifficulty difficulty) {
    _nodesEvaluated = 0;
    final allMoves = getAllLegalMoves(board, false);

    if (allMoves.isEmpty) return null;

    Map<String, dynamic>? bestMove;

    switch (difficulty) {
      case AIDifficulty.easy:
        bestMove = _getEasyMove(board, allMoves);
        break;
      case AIDifficulty.medium:
        bestMove = _getMediumMove(board, allMoves);
        break;
      case AIDifficulty.hard:
        bestMove = _getHardMove(board, allMoves);
        break;
    }

    print('AI evaluated $_nodesEvaluated positions');
    return bestMove;
  }

  /// EASY MODE: Random moves with slight preference for captures
  Map<String, dynamic> _getEasyMove(ChessBoard board, List<Map<String, dynamic>> allMoves) {
    // 40% completely random
    if (_random.nextDouble() < 0.4) {
      return allMoves[_random.nextInt(allMoves.length)];
    }

    // 60% prefer captures but still somewhat random
    final captures = allMoves.where((move) {
      final to = move['to'] as Position;
      return board.squares[to.row][to.col] != null;
    }).toList();

    if (captures.isNotEmpty && _random.nextDouble() < 0.7) {
      return captures[_random.nextInt(captures.length)];
    }

    return allMoves[_random.nextInt(allMoves.length)];
  }

  /// MEDIUM MODE: Minimax with depth 2-3
  Map<String, dynamic> _getMediumMove(ChessBoard board, List<Map<String, dynamic>> allMoves) {
    Map<String, dynamic>? bestMove;
    double bestScore = double.negativeInfinity;

    _orderMoves(allMoves, board);

    for (final move in allMoves) {
      final testBoard = board.copy();
      testBoard.movePiece(move['from'] as Position, move['to'] as Position);

      final score = _minimax(testBoard, 2, false, double.negativeInfinity, double.infinity);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? allMoves[_random.nextInt(allMoves.length)];
  }

  /// HARD MODE: Minimax with depth 4
  Map<String, dynamic> _getHardMove(ChessBoard board, List<Map<String, dynamic>> allMoves) {
    Map<String, dynamic>? bestMove;
    double bestScore = double.negativeInfinity;

    _orderMoves(allMoves, board);

    for (final move in allMoves) {
      final testBoard = board.copy();
      testBoard.movePiece(move['from'] as Position, move['to'] as Position);

      final score = _minimax(testBoard, 4, false, double.negativeInfinity, double.infinity);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? allMoves[_random.nextInt(allMoves.length)];
  }

  /// Minimax algorithm with alpha-beta pruning
  double _minimax(ChessBoard board, int depth, bool isMaximizing, double alpha, double beta) {
    _nodesEvaluated++;

    if (depth == 0) {
      return _evaluateBoard(board);
    }

    final moves = getAllLegalMoves(board, !isMaximizing);

    // Game over detection
    if (moves.isEmpty) {
      if (isInCheck(board, !isMaximizing)) {
        return isMaximizing ? -100000.0 + depth : 100000.0 - depth;
      }
      return 0.0; // Stalemate
    }

    if (isMaximizing) {
      double maxEval = double.negativeInfinity;
      for (final move in moves) {
        final testBoard = board.copy();
        testBoard.movePiece(move['from'] as Position, move['to'] as Position);

        final eval = _minimax(testBoard, depth - 1, false, alpha, beta);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);

        if (beta <= alpha) break; // Beta cutoff
      }
      return maxEval;
    } else {
      double minEval = double.infinity;
      for (final move in moves) {
        final testBoard = board.copy();
        testBoard.movePiece(move['from'] as Position, move['to'] as Position);

        final eval = _minimax(testBoard, depth - 1, true, alpha, beta);
        minEval = min(minEval, eval);
        beta = min(beta, eval);

        if (beta <= alpha) break; // Alpha cutoff
      }
      return minEval;
    }
  }

  /// Order moves for better alpha-beta pruning
  void _orderMoves(List<Map<String, dynamic>> moves, ChessBoard board) {
    moves.sort((a, b) {
      final aTo = a['to'] as Position;
      final bTo = b['to'] as Position;

      final aPiece = board.squares[aTo.row][aTo.col];
      final bPiece = board.squares[bTo.row][bTo.col];

      if (aPiece != null && bPiece == null) return -1;
      if (aPiece == null && bPiece != null) return 1;

      if (aPiece != null && bPiece != null) {
        final aValue = pieceValues[aPiece.typeString] ?? 0;
        final bValue = pieceValues[bPiece.typeString] ?? 0;
        return bValue.compareTo(aValue);
      }

      return 0;
    });
  }

  /// Comprehensive board evaluation
  double _evaluateBoard(ChessBoard board) {
    double score = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.squares[row][col];
        if (piece == null) continue;

        final pieceValue = pieceValues[piece.typeString] ?? 0;
        final positionValue = _getPositionValue(piece.typeString, row, col, piece.isWhite);

        final totalValue = pieceValue + positionValue;
        score += piece.isWhite ? -totalValue : totalValue;
      }
    }

    // Mobility bonus
    final whiteMoves = getAllLegalMoves(board, true).length;
    final blackMoves = getAllLegalMoves(board, false).length;
    score += (blackMoves - whiteMoves) * 10;

    // King safety
    score += _evaluateKingSafety(board);

    return score;
  }

  /// Get positional value from piece-square tables
  double _getPositionValue(String pieceType, int row, int col, bool isWhite) {
    final adjustedRow = isWhite ? 7 - row : row;

    switch (pieceType) {
      case 'p':
        return pawnTable[adjustedRow][col].toDouble();
      case 'n':
        return knightTable[adjustedRow][col].toDouble();
      case 'b':
        return bishopTable[adjustedRow][col].toDouble();
      case 'r':
        return rookTable[adjustedRow][col].toDouble();
      case 'k':
        return kingMiddleGameTable[adjustedRow][col].toDouble();
      default:
        return 0;
    }
  }

  /// Evaluate king safety
  double _evaluateKingSafety(ChessBoard board) {
    double score = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.squares[row][col];
        if (piece != null && piece.typeString == 'k') {
          final safety = _getKingSafety(board, Position(row:row, col:col), piece.isWhite);
          score += piece.isWhite ? -safety : safety;
        }
      }
    }

    return score;
  }

  double _getKingSafety(ChessBoard board, Position kingPos, bool isWhite) {
    double safety = 0;

    final pawnRow = isWhite ? kingPos.row - 1 : kingPos.row + 1;
    if (pawnRow >= 0 && pawnRow < 8) {
      for (int colOffset = -1; colOffset <= 1; colOffset++) {
        final col = kingPos.col + colOffset;
        if (col >= 0 && col < 8) {
          final piece = board.squares[pawnRow][col];
          if (piece != null && piece.typeString == 'p' && piece.isWhite == isWhite) {
            safety += 15;
          }
        }
      }
    }

    return safety;
  }

  /// CRITICAL: Check if king is in check using pseudo-legal moves
  bool isInCheck(ChessBoard board, bool isWhite) {
    Position? kingPos;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.squares[row][col];
        if (piece != null && piece.typeString == 'k' && piece.isWhite == isWhite) {
          kingPos = Position(row:row, col:col);
          break;
        }
      }
      if (kingPos != null) break;
    }

    if (kingPos == null) return false;

    // Check if any opponent piece can attack the king
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.squares[row][col];
        if (piece != null && piece.isWhite != isWhite) {
          final moves = _getPseudoLegalMovesForPiece(board, Position(row:row, col:col));
          if (moves.any((pos) => pos.row == kingPos!.row && pos.col == kingPos.col)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Get all legal moves for a color (filters out moves that leave king in check)
  List<Map<String, dynamic>> getAllLegalMoves(ChessBoard board, bool isWhite) {
    final moves = <Map<String, dynamic>>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.squares[row][col];
        if (piece != null && piece.isWhite == isWhite) {
          final from = Position(row:row, col:col);
          final pieceMoves = getLegalMovesForPiece(board, from);

          for (final to in pieceMoves) {
            moves.add({
              'from': from,
              'to': to,
              'piece': piece,
              'notation': '${_squareToNotation(from)}${_squareToNotation(to)}',
            });
          }
        }
      }
    }

    return moves;
  }

  /// Get legal moves for a specific piece (validates moves don't leave king in check)
  List<Position> getLegalMovesForPiece(ChessBoard board, Position from) {
    final pseudoLegalMoves = _getPseudoLegalMovesForPiece(board, from);
    final legalMoves = <Position>[];

    final piece = board.squares[from.row][from.col];
    if (piece == null) return [];

    // Test each move to ensure it doesn't leave king in check
    for (final to in pseudoLegalMoves) {
      final testBoard = board.copy();
      testBoard.movePiece(from, to);

      if (!isInCheck(testBoard, piece.isWhite)) {
        legalMoves.add(to);
      }
    }

    return legalMoves;
  }

  /// Get pseudo-legal moves (without check validation)
  List<Position> _getPseudoLegalMovesForPiece(ChessBoard board, Position from) {
    final piece = board.squares[from.row][from.col];
    if (piece == null) return [];

    switch (piece.typeString) {
      case 'p':
        return _getPawnMoves(board, from, piece.isWhite);
      case 'n':
        return _getKnightMoves(board, from, piece.isWhite);
      case 'b':
        return _getBishopMoves(board, from, piece.isWhite);
      case 'r':
        return _getRookMoves(board, from, piece.isWhite);
      case 'q':
        return _getQueenMoves(board, from, piece.isWhite);
      case 'k':
        return _getKingMoves(board, from, piece.isWhite);
      default:
        return [];
    }
  }

  /// Pawn moves - White moves UP (negative direction)
  /*
  List<Position> _getPawnMoves(ChessBoard board, Position from, bool isWhite) {
    final moves = <Position>[];
    final direction = isWhite ? -1 : 1;
    final startRank = isWhite ? 6 : 1;

    // Forward move
    final oneStep = Position(row: from.row + direction, col: from.col);
    if (_isValidPosition(oneStep) && board.squares[oneStep.row][oneStep.col] == null) {
      moves.add(oneStep);

      // Two-step from starting position
      if (from.row == startRank) {
        final twoStep = Position(from.row + (direction * 2), from.col);
        if (board.squares[twoStep.row][twoStep.col] == null) {
          moves.add(twoStep);
        }
      }
    }

    // Diagonal captures
    for (final colOffset in [-1, 1]) {
      final capturePos = Position(row: from.row + direction, col: from.col + colOffset);
      if (_isValidPosition(capturePos)) {
        final target = board.squares[capturePos.row][capturePos.col];
        if (target != null && target.isWhite != isWhite) {
          moves.add(capturePos);
        }
      }
    }

    return moves;
  }
  */
  List<Position> _getPawnMoves(ChessBoard board, Position from, bool isWhite) {
    final moves = <Position>[];
    final direction = isWhite ? -1 : 1;
    final startRank = isWhite ? 6 : 1;

    // Forward move
    final oneStep = Position(row: from.row + direction, col: from.col);
    if (_isValidPosition(oneStep) && board.squares[oneStep.row][oneStep.col] == null) {
      moves.add(oneStep);

      // Two-step from starting position
      if (from.row == startRank) {
        final twoStep = Position(row: from.row + (direction * 2), col: from.col);
        if (board.squares[twoStep.row][twoStep.col] == null) {
          moves.add(twoStep);
        }
      }
    }

    // Diagonal captures
    for (final colOffset in [-1, 1]) {
      final capturePos = Position(row: from.row + direction, col: from.col + colOffset);
      if (_isValidPosition(capturePos)) {
        final target = board.squares[capturePos.row][capturePos.col];
        if (target != null && target.isWhite != isWhite) {
          moves.add(capturePos);
        }
      }
    }

    return moves;
  }

  List<Position> _getKnightMoves(ChessBoard board, Position from, bool isWhite) {
    final moves = <Position>[];
    final offsets = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1],
    ];

    for (final offset in offsets) {
      final to = Position(row: from.row + offset[0], col: from.col + offset[1]);
      if (_isValidPosition(to)) {
        final target = board.squares[to.row][to.col];
        if (target == null || target.isWhite != isWhite) {
          moves.add(to);
        }
      }
    }

    return moves;
  }

  List<Position> _getBishopMoves(ChessBoard board, Position from, bool isWhite) {
    return _getSlidingMoves(board, from, isWhite, [
      [-1, -1], [-1, 1], [1, -1], [1, 1],
    ]);
  }

  List<Position> _getRookMoves(ChessBoard board, Position from, bool isWhite) {
    return _getSlidingMoves(board, from, isWhite, [
      [-1, 0], [1, 0], [0, -1], [0, 1],
    ]);
  }

  List<Position> _getQueenMoves(ChessBoard board, Position from, bool isWhite) {
    return _getSlidingMoves(board, from, isWhite, [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1],
    ]);
  }

  List<Position> _getKingMoves(ChessBoard board, Position from, bool isWhite) {
    final moves = <Position>[];
    final offsets = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1],
    ];

    for (final offset in offsets) {
      final to = Position(row: from.row + offset[0], col: from.col + offset[1]);
      if (_isValidPosition(to)) {
        final target = board.squares[to.row][to.col];
        if (target == null || target.isWhite != isWhite) {
          moves.add(to);
        }
      }
    }

    return moves;
  }

  /*
  List<Position> _getSlidingMoves(ChessBoard board, Position from, bool isWhite, List<List<int>> directions) {
    final moves = <Position>[];

    for (final direction in directions) {
      int row = from.row + direction[0];
      int col = from.col + direction[1];

      while (_isValidPosition(Position(row:row, col:col))) {
        final target = board.squares[row][col];

        if (target == null) {
          moves.add(Position(row:row, col:col));
        } else {
          if (target.isWhite != isWhite) {
            moves.add(Position(row:row, col:col));
          }
          break;
        }

        row += direction[0];
        col += direction[1];
      }
    }

    return moves;
  }
*/
  List<Position> _getSlidingMoves(
      ChessBoard board, Position from, bool isWhite, List<List<int>> directions) {
    final moves = <Position>[];

    for (final direction in directions) {
      int row = from.row + direction[0];
      int col = from.col + direction[1];

      while (_isValidPosition(Position(row: row, col: col))) {
        final target = board.squares[row][col];

        if (target == null) {
          moves.add(Position(row: row, col: col));
        } else {
          if (target.isWhite != isWhite) {
            moves.add(Position(row: row, col: col));
          }
          break;
        }

        row += direction[0];
        col += direction[1];
      }
    }

    return moves;
  }


  bool _isValidPosition(Position pos) {
    return pos.row >= 0 && pos.row < 8 && pos.col >= 0 && pos.col < 8;
  }

  String _squareToNotation(Position pos) {
    const files = 'abcdefgh';
    return '${files[pos.col]}${8 - pos.row}';
  }

  /// Detailed position evaluation for debugging
  Map<String, dynamic> evaluatePositionDetailed(ChessBoard board) {
    double materialScore = 0;
    double positionalScore = 0;

    Map<String, int> whitePieces = {};
    Map<String, int> blackPieces = {};

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.squares[row][col];
        if (piece == null) continue;

        final pieceType = piece.typeString;
        final value = pieceValues[pieceType] ?? 0;
        final posValue = _getPositionValue(pieceType, row, col, piece.isWhite);

        if (piece.isWhite) {
          whitePieces[pieceType] = (whitePieces[pieceType] ?? 0) + 1;
          materialScore += value;
          positionalScore += posValue;
        } else {
          blackPieces[pieceType] = (blackPieces[pieceType] ?? 0) + 1;
          materialScore -= value;
          positionalScore -= posValue;
        }
      }
    }

    final mobilityScore = (getAllLegalMoves(board, true).length - getAllLegalMoves(board, false).length) * 10.0;

    return {
      'totalScore': materialScore + positionalScore + mobilityScore,
      'material': materialScore,
      'positional': positionalScore,
      'mobility': mobilityScore,
      'whitePieces': whitePieces,
      'blackPieces': blackPieces,
    };
  }

  /// NEW METHOD: Get best move WITH evaluation data for display
  /*Map<String, dynamic>? getBestMoveWithEvaluation(ChessBoard board, AIDifficulty difficulty) {
    _nodesEvaluated = 0;
    final allMoves = getAllLegalMoves(board, false);

    if (allMoves.isEmpty) return null;

    Map<String, dynamic>? bestMove;
    double bestScore = double.negativeInfinity;
    List<Map<String, dynamic>> topMoves = [];

    switch (difficulty) {
      case AIDifficulty.easy:
        bestMove = _getEasyMove(board, allMoves);
        break;

      case AIDifficulty.medium:
      case AIDifficulty.hard:
        final depth = difficulty == AIDifficulty.medium ? 2 : 4;
        _orderMoves(allMoves, board);

        // Evaluate all moves and track top 5
        for (final move in allMoves) {
          final testBoard = board.copy();
          testBoard.movePiece(move['from'] as Position, move['to'] as Position);

          final score = _minimax(testBoard, depth, false, double.negativeInfinity, double.infinity);

          topMoves.add({
            'move': move,
            'score': score,
            'notation': move['notation'],
          });

          if (score > bestScore) {
            bestScore = score;
            bestMove = move;
          }
        }

        // Sort and keep top 5 moves
        topMoves.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
        topMoves = topMoves.take(5).toList();
        break;
    }

    print('AI evaluated $_nodesEvaluated positions');

    if (bestMove == null) return null;

    // Return move with evaluation data
    return {
      'from': bestMove['from'],
      'to': bestMove['to'],
      'notation': bestMove['notation'],
      'evaluation': {
        'score': bestScore,
        'nodes': _nodesEvaluated,
        'depth': difficulty == AIDifficulty.easy ? 0 : (difficulty == AIDifficulty.medium ? 2 : 4),
        'boardEval': evaluatePositionDetailed(board),
      },
      'topMoves': topMoves,
    };
  }
  */
  Map<String, dynamic>? getBestMoveWithEvaluation(ChessBoard board, AIDifficulty difficulty) {
    _nodesEvaluated = 0;
    final allMoves = getAllLegalMoves(board, false);

    if (allMoves.isEmpty) return null;

    Map<String, dynamic>? bestMove;
    double bestScore = double.negativeInfinity;
    List<Map<String, dynamic>> topMoves = [];

    switch (difficulty) {
      case AIDifficulty.easy:
        bestMove = _getEasyMove(board, allMoves);
        break;

      case AIDifficulty.medium:
      case AIDifficulty.hard:
        final depth = difficulty == AIDifficulty.medium ? 2 : 4;
        _orderMoves(allMoves, board);

        for (final move in allMoves) {
          final testBoard = board.copy();
          testBoard.movePiece(move['from'] as Position, move['to'] as Position);

          final score = _minimax(testBoard, depth, false, double.negativeInfinity, double.infinity);

          topMoves.add({
            'move': move,
            'score': score,
            'notation': move['notation'],
          });

          if (score > bestScore) {
            bestScore = score;
            bestMove = move;
          }
        }

        topMoves.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
        topMoves = topMoves.take(5).toList();
        break;
    }

    print('AI evaluated $_nodesEvaluated positions');

    if (bestMove == null) return null;

    return {
      'from': bestMove['from'],
      'to': bestMove['to'],
      'notation': bestMove['notation'],
      'evaluation': {
        'score': bestScore,
        'nodes': _nodesEvaluated,
        'depth': difficulty == AIDifficulty.easy ? 0 : (difficulty == AIDifficulty.medium ? 2 : 4),
        'boardEval': evaluatePositionDetailed(board),
      },
      'topMoves': topMoves,
    };
  }

  evaluatePosition(ChessBoard chessBoard) {}
}