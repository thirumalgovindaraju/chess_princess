import '../models/chess_puzzle.dart';
import '../models/chess_board.dart';
import '../models/position.dart';
import '../database/database_helper.dart';
import '../database/progress_helper.dart';

class PuzzleService {
  // Cache for frequently accessed data
  static List<String>? _cachedThemes;
  static int? _cachedTotalCount;

  /// Load puzzles with pagination
  static Future<List<ChessPuzzle>> loadPuzzles({
    int limit = 100000,
    int offset = 0,
  }) async {
    try {
      final puzzleMaps = await DatabaseHelper.instance.getAllPuzzles(
        limit: limit,
        offset: offset,
      );
      print('PuzzleService: Loaded ${puzzleMaps.length} puzzle maps');

      if (puzzleMaps.isEmpty) {
        print('WARNING: No puzzles in database!');
      }

      return puzzleMaps.map((map) => _puzzleFromMap(map)).toList();
    } catch (e) {
      print('ERROR in loadPuzzles: $e');
      return [];
    }
  }

  /// Get total number of puzzles in database
  static Future<int> getTotalPuzzlesCount() async {
    if (_cachedTotalCount != null) {
      return _cachedTotalCount!;
    }

    try {
      _cachedTotalCount = await DatabaseHelper.instance.getTotalPuzzlesCount();
      return _cachedTotalCount!;
    } catch (e) {
      print('ERROR getting total count: $e');
      return 0;
    }
  }

  /// Get puzzle by ID
  static Future<ChessPuzzle?> getPuzzleById(String puzzleId) async {
    try {
      final puzzleMap = await DatabaseHelper.instance.getPuzzleById(puzzleId);
      if (puzzleMap == null) return null;
      return _puzzleFromMap(puzzleMap);
    } catch (e) {
      print('ERROR getting puzzle by ID: $e');
      return null;
    }
  }

  /// Get puzzles by difficulty (based on rating ranges)
  static Future<List<ChessPuzzle>> getPuzzlesByDifficulty(
      PuzzleDifficulty difficulty, {
        int limit = 100000,
      }) async {
    try {
      // Map difficulty to rating ranges
      int minRating, maxRating;
      switch (difficulty) {
        case PuzzleDifficulty.easy:
          minRating = 0;
          maxRating = 1500;
          break;
        case PuzzleDifficulty.medium:
          minRating = 1500;
          maxRating = 2000;
          break;
        case PuzzleDifficulty.hard:
          minRating = 2000;
          maxRating = 2500;
          break;
        case PuzzleDifficulty.expert:
          minRating = 2500;
          maxRating = 9999;
          break;
      }

      final puzzleMaps = await DatabaseHelper.instance.getPuzzlesByRating(
        minRating,
        maxRating,
        limit: limit,
      );

      print('Found ${puzzleMaps.length} puzzles for difficulty: ${difficulty.name}');
      return puzzleMaps.map((map) => _puzzleFromMap(map)).toList();
    } catch (e) {
      print('Error getting puzzles by difficulty: $e');
      return [];
    }
  }

  /// Get puzzles by rating range
  static Future<List<ChessPuzzle>> getPuzzlesByRating({
    required int minRating,
    required int maxRating,
    int limit = 100000,
  }) async {
    try {
      final puzzleMaps = await DatabaseHelper.instance.getPuzzlesByRating(
        minRating,
        maxRating,
        limit: limit,
      );
      return puzzleMaps.map((map) => _puzzleFromMap(map)).toList();
    } catch (e) {
      print('Error getting puzzles by rating: $e');
      return [];
    }
  }

  /// Get puzzles by theme
  static Future<List<ChessPuzzle>> getPuzzlesByTheme({
    required String theme,
    int limit = 100000,
  }) async {
    try {
      final puzzleMaps = await DatabaseHelper.instance.getPuzzlesByTheme(
        theme,
        limit: limit,
      );
      return puzzleMaps.map((map) => _puzzleFromMap(map)).toList();
    } catch (e) {
      print('Error getting puzzles by theme: $e');
      return [];
    }
  }

  /// Get a random puzzle with optional rating filter
  static Future<ChessPuzzle?> getRandomPuzzle({
    int? minRating,
    int? maxRating,
    PuzzleDifficulty? difficulty,
  }) async {
    try {
      // If difficulty is provided, use its rating range
      if (difficulty != null) {
        switch (difficulty) {
          case PuzzleDifficulty.easy:
            minRating = 0;
            maxRating = 1500;
            break;
          case PuzzleDifficulty.medium:
            minRating = 1500;
            maxRating = 2000;
            break;
          case PuzzleDifficulty.hard:
            minRating = 2000;
            maxRating = 2500;
            break;
          case PuzzleDifficulty.expert:
            minRating = 2500;
            maxRating = 9999;
            break;
        }
      }

      final puzzleMap = await DatabaseHelper.instance.getRandomPuzzle(
        minRating: minRating,
        maxRating: maxRating,
      );
      if (puzzleMap == null) return null;
      return _puzzleFromMap(puzzleMap);
    } catch (e) {
      print('Error getting random puzzle: $e');
      return null;
    }
  }

  /// Get unsolved puzzles
  static Future<List<ChessPuzzle>> getUnsolvedPuzzles({
    int limit = 100000,
  }) async {
    try {
      final puzzleMaps = await DatabaseHelper.instance.getUnsolvedPuzzles(
        limit: limit,
      );
      return puzzleMaps.map((map) => _puzzleFromMap(map)).toList();
    } catch (e) {
      print('Error getting unsolved puzzles: $e');
      return [];
    }
  }

  /// Get popular puzzles (most played)
  static Future<List<ChessPuzzle>> getPopularPuzzles({
    int limit = 100000,
  }) async {
    try {
      final puzzleMaps = await DatabaseHelper.instance.getPopularPuzzles(
        limit: limit,
      );
      return puzzleMaps.map((map) => _puzzleFromMap(map)).toList();
    } catch (e) {
      print('Error getting popular puzzles: $e');
      return [];
    }
  }

  /// Advanced search with multiple filters
  static Future<List<ChessPuzzle>> searchPuzzles({
    int? minRating,
    int? maxRating,
    String? theme,
    PuzzleDifficulty? difficulty,
    int limit = 100000,
    int offset = 0,
  }) async {
    try {
      // Override rating if difficulty is provided
      if (difficulty != null) {
        switch (difficulty) {
          case PuzzleDifficulty.easy:
            minRating = 0;
            maxRating = 1500;
            break;
          case PuzzleDifficulty.medium:
            minRating = 1500;
            maxRating = 2000;
            break;
          case PuzzleDifficulty.hard:
            minRating = 2000;
            maxRating = 2500;
            break;
          case PuzzleDifficulty.expert:
            minRating = 2500;
            maxRating = 9999;
            break;
        }
      }

      final puzzleMaps = await DatabaseHelper.instance.searchPuzzles(
        minRating: minRating,
        maxRating: maxRating,
        theme: theme,
        limit: limit,
        offset: offset,
      );
      return puzzleMaps.map((map) => _puzzleFromMap(map)).toList();
    } catch (e) {
      print('Error searching puzzles: $e');
      return [];
    }
  }

  /// Get all available themes from database
  static Future<List<String>> getAvailableThemes() async {
    // Return cached themes if available
    if (_cachedThemes != null) {
      return _cachedThemes!;
    }

    try {
      _cachedThemes = await DatabaseHelper.instance.getAvailableThemes();
      return _cachedThemes!;
    } catch (e) {
      print('Error getting themes: $e');
      return [];
    }
  }

  /// Get puzzles from a set (legacy support)
  static Future<List<ChessPuzzle>> getPuzzlesFromSet(String setName) async {
    // Map set names to themes or use default
    return await loadPuzzles(limit: 100000);
  }

  /// Get puzzles by tier (maps to rating ranges)
  static Future<List<ChessPuzzle>> getPuzzlesByTier(int tier) async {
    // Map tier to rating ranges
    final ratingRanges = {
      1: [0, 1200],
      2: [1200, 1500],
      3: [1500, 1800],
      4: [1800, 2100],
      5: [2100, 2400],
    };

    final range = ratingRanges[tier] ?? [0, 9999];
    return getPuzzlesByRating(
      minRating: range[0],
      maxRating: range[1],
      limit: 100000,
    );
  }

  /// Convert database map to ChessPuzzle object
  static ChessPuzzle _puzzleFromMap(Map<String, dynamic> map) {
    // Extract themes from the Themes field (space-separated)
    final themesString = map['themes'] as String? ?? '';
    final themes = themesString.split(' ').where((t) => t.isNotEmpty).toList();
    final primaryTheme = themes.isNotEmpty ? themes.first : 'Tactics';

    // Parse rating to determine difficulty
    final rating = map['rating'] as int? ?? 1500;
    final difficulty = _ratingToDifficulty(rating);

    // Parse moves (space-separated in Lichess format)
    final movesString = map['moves'] as String? ?? '';
    final moves = movesString.split(' ').where((m) => m.isNotEmpty).toList();

    // Determine player color from FEN position
    final fen = map['fen'] as String? ?? '';
    final playerColor = _getPlayerColorFromFEN(fen);

    return ChessPuzzle(
      id: map['puzzleId'] ?? '',
      name: 'Puzzle ${map['puzzleId']}',
      description: 'Rating: $rating | Themes: ${themes.take(3).join(", ")}',
      fenPosition: fen,
      solution: moves,
      difficulty: difficulty,
      theme: primaryTheme,
      movesToMate: _calculateMovesToMate(themes),
      playerColor: playerColor,
      hints: _generateHints(themes, moves),
    );
  }

  /// Map rating to difficulty level
  static PuzzleDifficulty _ratingToDifficulty(int rating) {
    if (rating < 1500) return PuzzleDifficulty.easy;
    if (rating < 2000) return PuzzleDifficulty.medium;
    if (rating < 2500) return PuzzleDifficulty.hard;
    return PuzzleDifficulty.expert;
  }

  /// Extract player color from FEN string
  static PieceColor _getPlayerColorFromFEN(String fen) {
    // FEN format: position w/b - - 0 1
    // Second field indicates whose turn it is
    final parts = fen.split(' ');
    if (parts.length > 1) {
      return parts[1] == 'w' ? PieceColor.white : PieceColor.black;
    }
    return PieceColor.white;
  }

  /// Calculate moves to mate from themes
  static int _calculateMovesToMate(List<String> themes) {
    // Extract mate information from themes
    for (var theme in themes) {
      if (theme.contains('mateIn')) {
        final match = RegExp(r'mateIn(\d+)').firstMatch(theme);
        if (match != null) {
          return int.tryParse(match.group(1) ?? '0') ?? 0;
        }
      }
    }
    return 0; // Not a mate puzzle
  }

  /// Generate contextual hints based on themes
  static List<String> _generateHints(List<String> themes, List<String> moves) {
    final hints = <String>[];

    // Generate hints based on themes
    if (themes.contains('fork')) {
      hints.add('Look for a move that attacks multiple pieces');
    }
    if (themes.contains('pin')) {
      hints.add('Find a way to immobilize an opponent\'s piece');
    }
    if (themes.contains('skewer')) {
      hints.add('Attack a valuable piece with a less valuable one behind it');
    }
    if (themes.contains('discoveredAttack')) {
      hints.add('Move a piece to reveal an attack from another piece');
    }
    if (themes.contains('mate') || themes.contains('mateIn1') || themes.contains('mateIn2')) {
      hints.add('Look for checkmate!');
    }
    if (themes.contains('sacrifice')) {
      hints.add('Consider sacrificing material for a tactical advantage');
    }
    if (themes.contains('endgame')) {
      hints.add('Focus on king activity and pawn promotion');
    }
    if (themes.contains('middlegame')) {
      hints.add('Look for tactical opportunities in the center');
    }
    if (themes.contains('opening')) {
      hints.add('Develop your pieces and control the center');
    }
    if (themes.contains('crushing')) {
      hints.add('There\'s a decisive move that wins material or the game');
    }
    if (themes.contains('hangingPiece')) {
      hints.add('One of your opponent\'s pieces is undefended');
    }
    if (themes.contains('backRankMate')) {
      hints.add('The opponent\'s king is trapped on the back rank');
    }

    // Add a generic hint about the first move
    if (moves.isNotEmpty && hints.isEmpty) {
      hints.add('Find the best move for this position');
    }

    return hints.isNotEmpty ? hints : ['Think carefully about the position'];
  }

  /// Parse difficulty from string (legacy support)
  static PuzzleDifficulty _parseDifficulty(String diff) {
    switch (diff.toLowerCase()) {
      case 'easy':
        return PuzzleDifficulty.easy;
      case 'medium':
        return PuzzleDifficulty.medium;
      case 'hard':
        return PuzzleDifficulty.hard;
      case 'expert':
        return PuzzleDifficulty.expert;
      default:
        return PuzzleDifficulty.easy;
    }
  }

  /// Save completed puzzle progress
  // When completing a puzzle:
  static Future<void> completePuzzle(
      String puzzleId,
      Duration timeSpent,
      List<String> movesMade,
      ) async {
    await ProgressHelper.saveProgress(
      puzzleId: puzzleId,
      completed: true,
      skipped: false,
      attempts: 1,
      timeSpentSeconds: timeSpent.inSeconds,
    );
  }


  // When skipping a puzzle:
  static Future<void> skipPuzzle(String puzzleId) async {
    await ProgressHelper.saveProgress(
      puzzleId: puzzleId,
      completed: false,
      skipped: true,
      attempts: 0,
      timeSpentSeconds: 0,
    );
  }

  /// Get count of completed puzzles
  static Future<int> getCompletedCount() async {
    return await DatabaseHelper.instance.getCompletedCount();
  }

  /// Get user statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    return await DatabaseHelper.instance.getStatistics();
  }

  /// Get hint for current move
  static String getHint(ChessPuzzle puzzle, int moveIndex) {
    if (moveIndex >= 0 && moveIndex < puzzle.hints.length) {
      return puzzle.hints[moveIndex];
    }
    return puzzle.hints.isNotEmpty ? puzzle.hints[0] : 'Find the best move.';
  }

  /// Clear cached data
  static void clearCache() {
    _cachedThemes = null;
    _cachedTotalCount = null;
  }

  /// Get difficulty statistics
  static Future<Map<PuzzleDifficulty, int>> getDifficultyStats() async {
    try {
      final stats = <PuzzleDifficulty, int>{};

      for (var difficulty in PuzzleDifficulty.values) {
        final puzzles = await getPuzzlesByDifficulty(difficulty, limit: 1);
        // This is approximate - you might want to add a count query
        stats[difficulty] = puzzles.isNotEmpty ? 1000 : 0; // Placeholder
      }

      return stats;
    } catch (e) {
      print('Error getting difficulty stats: $e');
      return {};
    }
  }
}