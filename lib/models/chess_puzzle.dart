// lib/domain/models/chess_puzzle.dart

import 'chess_board.dart';
import 'position.dart';

/// Difficulty levels for chess puzzles
enum PuzzleDifficulty {
  easy,
  medium,
  hard,
  expert,
}

/// Core puzzle model used across the app
class ChessPuzzle {
  final String id;
  final String name;
  final String? description;
  final PuzzleDifficulty difficulty;
  final String theme;
  final String fenPosition;
  final List<String> solution;
  final int movesToMate;
  final PieceColor playerColor;
  final List<String> hints;

  ChessPuzzle({
    required this.id,
    required this.name,
    this.description,
    required this.difficulty,
    required this.theme,
    required this.fenPosition,
    required this.solution,
    required this.movesToMate,
    required this.playerColor,
    this.hints = const [],
  });

  /// Get human-readable difficulty name
  String get difficultyName {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return 'Easy';
      case PuzzleDifficulty.medium:
        return 'Medium';
      case PuzzleDifficulty.hard:
        return 'Hard';
      case PuzzleDifficulty.expert:
        return 'Expert';
    }
  }

  /// Create a ChessBoard from this puzzle's FEN position
  ChessBoard createBoard() {
    try {
      print('Creating board from FEN: $fenPosition');

      // Use the ChessBoard.fromFen() factory constructor
      final board = ChessBoard.fromFen(fenPosition);

      print('Board created successfully from FEN');
      return board;
    } catch (e, stackTrace) {
      print('❌ Error creating board from FEN: $e');
      print('Stack trace: $stackTrace');
      print('Falling back to initial board');
      return ChessBoard.initial();
    }
  }

  factory ChessPuzzle.fromJson(Map<String, dynamic> json) {
    return ChessPuzzle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      difficulty: PuzzleDifficulty.values.firstWhere(
            (e) => e.name == (json['difficulty'] ?? 'medium'),
        orElse: () => PuzzleDifficulty.medium,
      ),
      theme: json['theme'] ?? 'Tactics',
      fenPosition: json['fenPosition'] ?? '',
      solution: List<String>.from(json['solution'] ?? []),
      movesToMate: json['movesToMate'] ?? 0,
      playerColor: json['playerColor'] == 'black'
          ? PieceColor.black
          : PieceColor.white,
      hints: List<String>.from(json['hints'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty.name,
      'theme': theme,
      'fenPosition': fenPosition,
      'solution': solution,
      'movesToMate': movesToMate,
      'playerColor': playerColor.name,
      'hints': hints,
    };
  }

  @override
  String toString() =>
      'ChessPuzzle(id: $id, theme: $theme, difficulty: ${difficulty.name})';
}