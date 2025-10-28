// lib/services/chess_coach.dart

import 'dart:math';
import '../models/coach_suggestion.dart';
import '../models/chess_board.dart';
import '../models/position.dart';
import 'chess_ai.dart';

class ChessCoach {
  final ChessAI _ai = ChessAI();

  static const Map<String, int> PIECE_VALUES = {
    'p': 100,
    'n': 320,
    'b': 330,
    'r': 500,
    'q': 900,
    'k': 20000,
  };

  // Main analysis method
  Future<CoachAnalysis> analyzePosition(
      ChessBoard board,
      List<String> moveHistory,
      ) async {
    final suggestions = <CoachSuggestion>[];

    // Perform various analyses
    final evaluation = _ai.evaluatePositionDetailed(board);
    final gamePhase = _determineGamePhase(board);
    final statistics = _calculateStatistics(board);
    final bestMoves = suggestBestMoves(board, count: 5);

    // Check for tactical opportunities
    suggestions.addAll(_findTacticalOpportunities(board));

    // Check for positional issues
    suggestions.addAll(_findPositionalIssues(board));

    // Check for strategic recommendations
    suggestions.addAll(_findStrategicRecommendations(board, gamePhase));

    // Check move history for patterns
    if (moveHistory.length >= 4) {
      suggestions.addAll(_analyzeRecentMoves(board, moveHistory));
    }

    // Sort by priority
    suggestions.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    return CoachAnalysis(
      suggestions: suggestions,
      positionEvaluation: evaluation['totalScore'],
      gamePhase: gamePhase,
      statistics: statistics,
      bestMoves: bestMoves,
    );
  }

  // Analyze move quality after it's made
  CoachSuggestion? analyzeMoveQuality(
      ChessBoard previousBoard,
      ChessBoard currentBoard,
      String move,
      ) {
    final prevEval = _ai.evaluatePositionDetailed(previousBoard);
    final currEval = _ai.evaluatePositionDetailed(currentBoard);

    final evalChange = currEval['totalScore'] - prevEval['totalScore'];

    // Check if move was a blunder
    if (evalChange.abs() > 300) {
      return CoachSuggestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: SuggestionType.mistake,
        priority: SuggestionPriority.critical,
        title: 'Blunder Alert!',
        message: 'That move significantly weakened your position. The evaluation changed by ${evalChange.toStringAsFixed(0)} points.',
        explanation: 'Consider reviewing the position before this move.',
      );
    }

    // Check if move was questionable
    if (evalChange.abs() > 150) {
      return CoachSuggestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: SuggestionType.warning,
        priority: SuggestionPriority.high,
        title: 'Questionable Move',
        message: 'This move weakened your position. Look for better alternatives.',
        explanation: 'The evaluation changed by ${evalChange.toStringAsFixed(0)} points.',
      );
    }

    // Check if move was excellent
    if (evalChange > 100) {
      return CoachSuggestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: SuggestionType.praise,
        priority: SuggestionPriority.low,
        title: 'Excellent Move!',
        message: 'That was a strong move that improved your position.',
        explanation: 'The evaluation improved by ${evalChange.toStringAsFixed(0)} points.',
      );
    }

    return null;
  }

  // Find tactical opportunities
  List<CoachSuggestion> _findTacticalOpportunities(ChessBoard board) {
    final suggestions = <CoachSuggestion>[];

    // Check for undefended pieces
    final undefendedPieces = _findUndefendedPieces(board);
    if (undefendedPieces.isNotEmpty) {
      suggestions.add(CoachSuggestion(
        id: 'tactical_undefended_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.tactical,
        priority: SuggestionPriority.high,
        title: 'Undefended Pieces',
        message: 'There are ${undefendedPieces.length} undefended pieces on the board. Consider attacking them!',
        explanation: 'Pieces at: ${undefendedPieces.map((p) => _positionToNotation(p)).join(", ")}',
      ));
    }

    // Check for pieces that can be captured
    final hangingPieces = _findHangingPieces(board);
    if (hangingPieces.isNotEmpty) {
      suggestions.add(CoachSuggestion(
        id: 'tactical_hanging_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.tactical,
        priority: SuggestionPriority.critical,
        title: 'Hanging Piece!',
        message: 'You have pieces that can be captured! Protect them immediately.',
        explanation: 'Vulnerable pieces at: ${hangingPieces.map((p) => _positionToNotation(p)).join(", ")}',
      ));
    }

    // Check for fork opportunities
    final forkMoves = _findForkOpportunities(board);
    if (forkMoves.isNotEmpty) {
      suggestions.add(CoachSuggestion(
        id: 'tactical_fork_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.tactical,
        priority: SuggestionPriority.high,
        title: 'Fork Opportunity!',
        message: 'You can attack multiple pieces at once with a fork!',
        move: forkMoves.first,
        explanation: 'Look for moves that attack two or more valuable pieces simultaneously.',
      ));
    }

    // Check for pin opportunities
    final pinMoves = _findPinOpportunities(board);
    if (pinMoves.isNotEmpty) {
      suggestions.add(CoachSuggestion(
        id: 'tactical_pin_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.tactical,
        priority: SuggestionPriority.medium,
        title: 'Pin Available',
        message: 'You can pin an opponent\'s piece, restricting its movement.',
        move: pinMoves.first,
        explanation: 'A pin immobilizes a piece by threatening a more valuable piece behind it.',
      ));
    }

    return suggestions;
  }

  // Find positional issues
  List<CoachSuggestion> _findPositionalIssues(ChessBoard board) {
    final suggestions = <CoachSuggestion>[];

    // Check king safety
    final kingSafety = _evaluateKingSafety(board);
    if (kingSafety < -50) {
      suggestions.add(CoachSuggestion(
        id: 'positional_king_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.positional,
        priority: SuggestionPriority.high,
        title: 'King Safety Concern',
        message: 'Your king is not well protected. Consider castling or adding defensive pieces.',
        explanation: 'A safe king is crucial for the middlegame and endgame.',
      ));
    }

    // Check piece development
    final developmentScore = _evaluateDevelopment(board);
    if (developmentScore < -2) {
      suggestions.add(CoachSuggestion(
        id: 'positional_development_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.positional,
        priority: SuggestionPriority.medium,
        title: 'Underdeveloped Pieces',
        message: 'Focus on developing your pieces before launching attacks.',
        explanation: 'Knights and bishops should be developed early in the game.',
      ));
    }

    // Check pawn structure
    final pawnIssues = _analyzePawnStructure(board);
    if (pawnIssues.isNotEmpty) {
      suggestions.add(CoachSuggestion(
        id: 'positional_pawns_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.positional,
        priority: SuggestionPriority.low,
        title: 'Pawn Structure',
        message: 'You have ${pawnIssues.length} weak pawns. Try to avoid creating more weaknesses.',
        explanation: 'Weak pawns include isolated, doubled, and backward pawns.',
      ));
    }

    // Check piece coordination
    final coordination = _evaluatePieceCoordination(board);
    if (coordination < 0) {
      suggestions.add(CoachSuggestion(
        id: 'positional_coordination_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.positional,
        priority: SuggestionPriority.medium,
        title: 'Piece Coordination',
        message: 'Your pieces are not working together effectively. Coordinate your pieces to support each other.',
        explanation: 'Good piece coordination creates stronger attacks and better defense.',
      ));
    }

    return suggestions;
  }

  // Find strategic recommendations
  List<CoachSuggestion> _findStrategicRecommendations(
      ChessBoard board,
      String gamePhase,
      ) {
    final suggestions = <CoachSuggestion>[];

    if (gamePhase == 'opening') {
      suggestions.add(CoachSuggestion(
        id: 'strategic_opening_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.opening,
        priority: SuggestionPriority.low,
        title: 'Opening Principles',
        message: 'Control the center, develop pieces, and castle early.',
        explanation: 'These fundamental principles help establish a strong position.',
      ));
    } else if (gamePhase == 'endgame') {
      suggestions.add(CoachSuggestion(
        id: 'strategic_endgame_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.endgame,
        priority: SuggestionPriority.medium,
        title: 'Endgame Strategy',
        message: 'Activate your king and push passed pawns.',
        explanation: 'In the endgame, the king becomes a powerful attacking piece.',
      ));
    }

    // Check material balance
    final materialBalance = _calculateMaterialBalance(board);
    if (materialBalance > 300) {
      suggestions.add(CoachSuggestion(
        id: 'strategic_material_up_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.strategic,
        priority: SuggestionPriority.medium,
        title: 'Material Advantage',
        message: 'You\'re ahead in material. Consider simplifying by trading pieces.',
        explanation: 'When ahead, trading pieces makes your advantage more decisive.',
      ));
    } else if (materialBalance < -300) {
      suggestions.add(CoachSuggestion(
        id: 'strategic_material_down_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.strategic,
        priority: SuggestionPriority.high,
        title: 'Material Disadvantage',
        message: 'You\'re behind in material. Avoid trades and create complications.',
        explanation: 'Complex positions offer more chances when behind in material.',
      ));
    }

    return suggestions;
  }

  // Analyze recent moves
  List<CoachSuggestion> _analyzeRecentMoves(
      ChessBoard board,
      List<String> moveHistory,
      ) {
    final suggestions = <CoachSuggestion>[];

    // Check for repetition
    if (_checkForRepetition(moveHistory)) {
      suggestions.add(CoachSuggestion(
        id: 'pattern_repetition_${DateTime.now().millisecondsSinceEpoch}',
        type: SuggestionType.warning,
        priority: SuggestionPriority.medium,
        title: 'Move Repetition',
        message: 'You\'re repeating moves. Consider finding a new plan.',
        explanation: 'Repetition can lead to a draw or wasted time.',
      ));
    }

    return suggestions;
  }

  // Suggest best moves
  List<String> suggestBestMoves(ChessBoard board, {int count = 3}) {
    final moves = _ai.getAllLegalMoves(board, board.isWhiteTurn);

    // Evaluate each move
    final evaluatedMoves = moves.map((moveData) {
      final testBoard = board.copy();
      final from = moveData['from'] as Position;
      final to = moveData['to'] as Position;

      // Make the move on test board
      testBoard.movePiece(from, to);

      final evaluation = _ai.evaluatePositionDetailed(testBoard);

      return {
        'move': moveData['notation'],
        'score': evaluation['totalScore'],
      };
    }).toList();

    // Sort by score
    evaluatedMoves.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return evaluatedMoves
        .take(count)
        .map((m) => m['move'] as String)
        .toList();
  }

  // Helper methods
  String _determineGamePhase(ChessBoard board) {
    int pieceCount = 0;
    bool queensOnBoard = false;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.squares[row][col];
        if (piece != null) {
          pieceCount++;
          //if (piece.type.toLowerCase() == 'q') {
          if (piece.typeString == 'q') {
            queensOnBoard = true;
          }
        }
      }
    }

    if (pieceCount <= 10 || !queensOnBoard) {
      return 'endgame';
    } else if (pieceCount >= 28) {
      return 'opening';
    } else {
      return 'middlegame';
    }
  }

  Map<String, dynamic> _calculateStatistics(ChessBoard board) {
    int whiteMaterial = 0;
    int blackMaterial = 0;
    int whitePieces = 0;
    int blackPieces = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.squares[row][col];
        if (piece != null) {
          //final value = PIECE_VALUES[piece.type.toLowerCase()] ?? 0;
          final value = PIECE_VALUES[piece.typeString] ?? 0;
          if (piece.isWhite) {
            whiteMaterial += value;
            whitePieces++;
          } else {
            blackMaterial += value;
            blackPieces++;
          }
        }
      }
    }

    return {
      'whiteMaterial': whiteMaterial,
      'blackMaterial': blackMaterial,
      'materialAdvantage': whiteMaterial - blackMaterial,
      'whitePieces': whitePieces,
      'blackPieces': blackPieces,
    };
  }

  List<Position> _findUndefendedPieces(ChessBoard board) {
    final undefended = <Position>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.squares[row][col];
        if (piece != null && !piece.isWhite) {
          final pos = Position(row:row, col:col);
          if (!_isPieceDefended(board, pos)) {
            undefended.add(pos);
          }
        }
      }
    }

    return undefended;
  }

  List<Position> _findHangingPieces(ChessBoard board) {
    // Similar to undefended but checks if piece can be captured
    return _findUndefendedPieces(board);
  }

  List<String> _findForkOpportunities(ChessBoard board) {
    // Simplified fork detection
    return [];
  }

  List<String> _findPinOpportunities(ChessBoard board) {
    // Simplified pin detection
    return [];
  }

  double _evaluateKingSafety(ChessBoard board) {
    // Simplified king safety evaluation
    return 0.0;
  }

  double _evaluateDevelopment(ChessBoard board) {
    // Count developed pieces
    int developed = 0;
    final backRank = board.isWhiteTurn ? 0 : 7;

    for (int col = 0; col < 8; col++) {
      final piece = board.squares[backRank][col];
      if (piece != null) {
        //final type = piece.type.toLowerCase();
        final type = piece.typeString;
        if (type == 'n' || type == 'b') {
          developed--;
        }
      }
    }

    return developed.toDouble();
  }

  List<Position> _analyzePawnStructure(ChessBoard board) {
    // Find weak pawns
    return [];
  }

  double _evaluatePieceCoordination(ChessBoard board) {
    // Simplified coordination evaluation
    return 0.0;
  }

  int _calculateMaterialBalance(ChessBoard board) {
    final stats = _calculateStatistics(board);
    return stats['materialAdvantage'];
  }

  bool _checkForRepetition(List<String> moveHistory) {
    if (moveHistory.length < 8) return false;

    final recent = moveHistory.sublist(moveHistory.length - 4);
    final previous = moveHistory.sublist(moveHistory.length - 8, moveHistory.length - 4);

    return recent[0] == previous[0] &&
        recent[1] == previous[1] &&
        recent[2] == previous[2] &&
        recent[3] == previous[3];
  }

  bool _isPieceDefended(ChessBoard board, Position pos) {
    // Simplified defense check
    return false;
  }

  String _positionToNotation(Position pos) {
    const files = 'abcdefgh';
    return '${files[pos.col]}${8 - pos.row}';
  }
}