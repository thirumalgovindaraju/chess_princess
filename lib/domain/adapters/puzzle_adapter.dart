// lib/domain/adapters/puzzle_adapter.dart
import '../entities/puzzle.dart';
import '../../models/chess_puzzle.dart';
import '../../models/chess_board.dart';

/// Adapter to convert between different puzzle representations
class PuzzleAdapter {
  /// Convert domain Puzzle entity to ChessPuzzle model
  static ChessPuzzle toChessPuzzle(Puzzle puzzle) {
    return ChessPuzzle(
      id: puzzle.id,
      name: 'Puzzle ${puzzle.id}',
      description: 'Difficulty: ${puzzle.difficulty} | Theme: ${puzzle.theme}',
      difficulty: _difficultyFromRating(puzzle.difficulty),
      theme: puzzle.theme,
      fenPosition: puzzle.fen,
      solution: puzzle.solutionSan,
      movesToMate: _calculateMovesToMate(puzzle.theme),
      playerColor: _getPlayerColorFromFEN(puzzle.fen),
      hints: puzzle.hint != null ? [puzzle.hint!] : [],
    );
  }

  /// Convert ChessPuzzle model to domain Puzzle entity
  static Puzzle fromChessPuzzle(ChessPuzzle chessPuzzle) {
    return Puzzle(
      id: chessPuzzle.id,
      fen: chessPuzzle.fenPosition,
      difficulty: _ratingFromDifficulty(chessPuzzle.difficulty),
      theme: chessPuzzle.theme,
      hint: chessPuzzle.hints.isNotEmpty ? chessPuzzle.hints.first : null,
      rating: _ratingFromDifficulty(chessPuzzle.difficulty).toDouble(),
      solutionSan: chessPuzzle.solution,
    );
  }

  /// Convert database map to ChessPuzzle
  static ChessPuzzle fromDatabaseMap(Map<String, dynamic> map) {
    final themesString = map['themes'] as String? ?? '';
    final themes = themesString.split(' ').where((t) => t.isNotEmpty).toList();
    final primaryTheme = themes.isNotEmpty ? themes.first : 'Tactics';

    final rating = map['rating'] as int? ?? 1500;
    final difficulty = _ratingToDifficulty(rating);

    final movesString = map['moves'] as String? ?? '';
    final moves = movesString.split(' ').where((m) => m.isNotEmpty).toList();

    final fen = map['fen'] as String? ?? '';
    final playerColor = _getPlayerColorFromFEN(fen);

    return ChessPuzzle(
      id: map['puzzleId'] ?? map['id'] ?? '',
      name: 'Puzzle ${map['puzzleId'] ?? map['id'] ?? ''}',
      description: 'Rating: $rating | Themes: ${themes.take(3).join(", ")}',
      fenPosition: fen,
      solution: moves,
      difficulty: difficulty,
      theme: primaryTheme,
      movesToMate: _calculateMovesToMate(themes.join(' ')),
      playerColor: playerColor,
      hints: _generateHints(themes, moves),
    );
  }

  /// Convert ChessPuzzle to database map
  static Map<String, dynamic> toDatabase(ChessPuzzle puzzle) {
    return {
      'puzzleId': puzzle.id,
      'fen': puzzle.fenPosition,
      'moves': puzzle.solution.join(' '),
      'rating': _ratingFromDifficulty(puzzle.difficulty),
      'themes': puzzle.theme,
      'category': _getCategoryFromTheme(puzzle.theme),
      'difficulty_level': _difficultyLevelFromEnum(puzzle.difficulty),
    };
  }

  // ===== PRIVATE HELPER METHODS =====

  static PuzzleDifficulty _ratingToDifficulty(int rating) {
    if (rating < 1500) return PuzzleDifficulty.easy;
    if (rating < 2000) return PuzzleDifficulty.medium;
    if (rating < 2500) return PuzzleDifficulty.hard;
    return PuzzleDifficulty.expert;
  }

  static PuzzleDifficulty _difficultyFromRating(int rating) {
    if (rating < 1400) return PuzzleDifficulty.easy;
    if (rating < 1800) return PuzzleDifficulty.medium;
    if (rating < 2200) return PuzzleDifficulty.hard;
    return PuzzleDifficulty.expert;
  }

  static int _ratingFromDifficulty(PuzzleDifficulty difficulty) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return 1200;
      case PuzzleDifficulty.medium:
        return 1700;
      case PuzzleDifficulty.hard:
        return 2100;
      case PuzzleDifficulty.expert:
        return 2600;
    }
  }

  static int _difficultyLevelFromEnum(PuzzleDifficulty difficulty) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return 2;
      case PuzzleDifficulty.medium:
        return 3;
      case PuzzleDifficulty.hard:
        return 4;
      case PuzzleDifficulty.expert:
        return 5;
    }
  }

  static PieceColor _getPlayerColorFromFEN(String fen) {
    final parts = fen.split(' ');
    if (parts.length > 1) {
      return parts[1] == 'w' ? PieceColor.white : PieceColor.black;
    }
    return PieceColor.white;
  }

  static int _calculateMovesToMate(String themeString) {
    final match = RegExp(r'mateIn(\d+)').firstMatch(themeString);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  static List<String> _generateHints(List<String> themes, List<String> moves) {
    final hints = <String>[];

    for (var theme in themes) {
      switch (theme.toLowerCase()) {
        case 'fork':
          hints.add('Look for a move that attacks multiple pieces');
          break;
        case 'pin':
          hints.add('Find a way to immobilize an opponent\'s piece');
          break;
        case 'skewer':
          hints.add('Attack a valuable piece with a less valuable one behind it');
          break;
        case 'discoveredattack':
          hints.add('Move a piece to reveal an attack from another piece');
          break;
        case 'mate':
        case 'matein1':
        case 'matein2':
        case 'matein3':
          hints.add('Look for checkmate!');
          break;
        case 'sacrifice':
          hints.add('Consider sacrificing material for a tactical advantage');
          break;
        case 'endgame':
          hints.add('Focus on king activity and pawn promotion');
          break;
        case 'middlegame':
          hints.add('Look for tactical opportunities in the center');
          break;
        case 'opening':
          hints.add('Develop your pieces and control the center');
          break;
        case 'crushing':
          hints.add('There\'s a decisive move that wins material or the game');
          break;
        case 'hangingpiece':
          hints.add('One of your opponent\'s pieces is undefended');
          break;
        case 'backrankmate':
          hints.add('The opponent\'s king is trapped on the back rank');
          break;
      }
    }

    if (hints.isEmpty && moves.isNotEmpty) {
      hints.add('Find the best move for this position');
    }

    return hints.isNotEmpty ? hints.take(3).toList() : ['Think carefully about the position'];
  }

  static String _getCategoryFromTheme(String theme) {
    final themeLower = theme.toLowerCase();

    if (themeLower.contains('mate') || themeLower.contains('checkmate')) {
      return 'Checkmate';
    }
    if (themeLower.contains('fork') || themeLower.contains('pin') ||
        themeLower.contains('skewer') || themeLower.contains('discovered')) {
      return 'Tactics';
    }
    if (themeLower.contains('endgame')) {
      return 'Endgame';
    }
    if (themeLower.contains('opening')) {
      return 'Opening';
    }
    if (themeLower.contains('sacrifice')) {
      return 'Sacrifices';
    }
    if (themeLower.contains('defense') || themeLower.contains('defensive')) {
      return 'Defense';
    }

    return 'Mixed';
  }

  /// Batch convert list of database maps to ChessPuzzles
  static List<ChessPuzzle> fromDatabaseList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => fromDatabaseMap(map)).toList();
  }

  /// Batch convert list of Puzzle entities to ChessPuzzles
  static List<ChessPuzzle> fromPuzzleList(List<Puzzle> puzzles) {
    return puzzles.map((puzzle) => toChessPuzzle(puzzle)).toList();
  }

  /// Validate FEN string
  static bool isValidFEN(String fen) {
    final parts = fen.split(' ');
    if (parts.length != 6) return false;

    final position = parts[0];
    final ranks = position.split('/');
    if (ranks.length != 8) return false;

    // Check each rank
    for (var rank in ranks) {
      int fileCount = 0;
      for (var char in rank.split('')) {
        if ('12345678'.contains(char)) {
          fileCount += int.parse(char);
        } else if ('rnbqkpRNBQKP'.contains(char)) {
          fileCount++;
        } else {
          return false;
        }
      }
      if (fileCount != 8) return false;
    }

    return true;
  }
}