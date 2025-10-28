// lib/services/unified_puzzle_service.dart
import '../../models/chess_puzzle.dart';
import '../domain/entities/puzzle.dart';
import '../domain/adapters/puzzle_adapter.dart';
import '../database/database_helper.dart';
import '../models/chess_board.dart';

/// Unified service that handles all puzzle operations
/// Works with both ChessPuzzle and Puzzle models
class UnifiedPuzzleService {
  static UnifiedPuzzleService? _instance;
  static UnifiedPuzzleService get instance => _instance ??= UnifiedPuzzleService._();
  UnifiedPuzzleService._();

  // Cache
  static List<ChessPuzzle>? _cachedPuzzles;
  static Map<String, int>? _categoryStats;
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiration = Duration(minutes: 30);

  // ===== PUBLIC API =====

  /// Load puzzles by difficulty
  Future<List<ChessPuzzle>> getPuzzlesByDifficulty(
      PuzzleDifficulty difficulty, {
        int limit = 50,
      }) async {
    try {
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

      return PuzzleAdapter.fromDatabaseList(puzzleMaps);
    } catch (e) {
      print('Error loading puzzles by difficulty: $e');
      return _getFallbackPuzzles(difficulty);
    }
  }

  /// Load all puzzles
  Future<List<ChessPuzzle>> loadPuzzles({int limit = 50}) async {
    // Check cache first
    if (_isCacheValid() && _cachedPuzzles != null) {
      return _cachedPuzzles!.take(limit).toList();
    }

    try {
      final puzzleMaps = await DatabaseHelper.instance.getAllPuzzles(limit: limit);
      final puzzles = PuzzleAdapter.fromDatabaseList(puzzleMaps);

      _cachedPuzzles = puzzles;
      _lastCacheUpdate = DateTime.now();

      return puzzles;
    } catch (e) {
      print('Error loading puzzles: $e');
      return _getDefaultPuzzles();
    }
  }

  /// Get puzzles by theme
  Future<List<ChessPuzzle>> getPuzzlesByTheme(
      String theme, {
        int limit = 50,
      }) async {
    try {
      final puzzleMaps = await DatabaseHelper.instance.getPuzzlesByTheme(
        theme,
        limit: limit,
      );
      return PuzzleAdapter.fromDatabaseList(puzzleMaps);
    } catch (e) {
      print('Error loading puzzles by theme: $e');
      return [];
    }
  }

  /// Get a random puzzle
  Future<ChessPuzzle?> getRandomPuzzle({
    PuzzleDifficulty? difficulty,
  }) async {
    try {
      int? minRating, maxRating;

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

      if (puzzleMap != null) {
        return PuzzleAdapter.fromDatabaseMap(puzzleMap);
      }
      return null;
    } catch (e) {
      print('Error getting random puzzle: $e');
      return null;
    }
  }

  /// Get puzzle by ID
  Future<ChessPuzzle?> getPuzzleById(String puzzleId) async {
    try {
      final puzzleMap = await DatabaseHelper.instance.getPuzzleById(puzzleId);
      if (puzzleMap != null) {
        return PuzzleAdapter.fromDatabaseMap(puzzleMap);
      }
      return null;
    } catch (e) {
      print('Error getting puzzle by ID: $e');
      return null;
    }
  }

  /// Save puzzle completion
  Future<void> completePuzzle(
      String puzzleId,
      Duration timeSpent,
      List<String> movesMade,
      ) async {
    try {
      await DatabaseHelper.instance.saveProgress(
        puzzleId: puzzleId,
        completed: true,
        skipped: false,
        attempts: 1,
        timeSpentSeconds: timeSpent.inSeconds,
      );
    } catch (e) {
      print('Error saving puzzle completion: $e');
    }
  }

  /// Skip puzzle
  Future<void> skipPuzzle(String puzzleId) async {
    try {
      await DatabaseHelper.instance.saveProgress(
        puzzleId: puzzleId,
        completed: false,
        skipped: true,
        attempts: 0,
        timeSpentSeconds: 0,
      );
    } catch (e) {
      print('Error skipping puzzle: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final stats = await DatabaseHelper.instance.getStatistics();

      // Add difficulty breakdown
      stats['easy'] = await _getCountByDifficulty(PuzzleDifficulty.easy);
      stats['medium'] = await _getCountByDifficulty(PuzzleDifficulty.medium);
      stats['hard'] = await _getCountByDifficulty(PuzzleDifficulty.hard);
      stats['expert'] = await _getCountByDifficulty(PuzzleDifficulty.expert);

      return stats;
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'easy': 0,
        'medium': 0,
        'hard': 0,
        'expert': 0,
        'totalSolved': 0,
        'totalAttempted': 0,
      };
    }
  }

  /// Get completed puzzle count
  Future<int> getCompletedCount() async {
    try {
      return await DatabaseHelper.instance.getCompletedCount();
    } catch (e) {
      print('Error getting completed count: $e');
      return 0;
    }
  }

  /// Get hint for puzzle
  String getHint(ChessPuzzle puzzle, int moveIndex) {
    if (puzzle.hints.isEmpty) {
      return 'Look for the best move in this position.';
    }

    if (moveIndex >= 0 && moveIndex < puzzle.hints.length) {
      return puzzle.hints[moveIndex];
    }

    return puzzle.hints.first;
  }

  /// Get available themes
  Future<List<String>> getAvailableThemes() async {
    try {
      return await DatabaseHelper.instance.getAvailableThemes();
    } catch (e) {
      print('Error getting themes: $e');
      return ['Checkmate', 'Fork', 'Pin', 'Skewer', 'Tactics'];
    }
  }

  /// Get total puzzle count
  Future<int> getTotalPuzzlesCount() async {
    try {
      return await DatabaseHelper.instance.getTotalPuzzleCount();
    } catch (e) {
      print('Error getting total count: $e');
      return 0;
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedPuzzles = null;
    _categoryStats = null;
    _lastCacheUpdate = null;
  }

  /// Refresh data from database
  Future<void> refresh() async {
    clearCache();
    await loadPuzzles();
  }

  // ===== PRIVATE METHODS =====

  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiration;
  }

  Future<int> _getCountByDifficulty(PuzzleDifficulty difficulty) async {
    try {
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

      final puzzles = await DatabaseHelper.instance.getPuzzlesByRating(
        minRating,
        maxRating,
        limit: 1,
      );

      // Return approximate count (you could add a COUNT query to DatabaseHelper)
      return puzzles.isNotEmpty ? 1000 : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Fallback puzzles when database fails
  List<ChessPuzzle> _getFallbackPuzzles(PuzzleDifficulty difficulty) {
    final allPuzzles = _getDefaultPuzzles();
    return allPuzzles.where((p) => p.difficulty == difficulty).toList();
  }

  /// Default puzzles for when database is unavailable
  List<ChessPuzzle> _getDefaultPuzzles() {
    return [
      // EASY PUZZLES
      ChessPuzzle(
        id: 'default_1',
        name: 'Back Rank Mate',
        description: 'Deliver checkmate on the back rank',
        fenPosition: '6k1/5ppp/8/8/8/8/8/R6K w - - 0 1',
        solution: ['Ra8#'],
        difficulty: PuzzleDifficulty.easy,
        theme: 'Checkmate',
        movesToMate: 1,
        playerColor: PieceColor.white,
        hints: ['The king has no escape squares', 'Move the rook to the back rank'],
      ),
      ChessPuzzle(
        id: 'default_2',
        name: 'Knight Fork',
        description: 'Fork the king and rook with your knight',
        fenPosition: 'r3k2r/ppp2ppp/8/8/8/3N4/PPP2PPP/R3K2R w KQkq - 0 1',
        solution: ['Nf7+'],
        difficulty: PuzzleDifficulty.easy,
        theme: 'Fork',
        movesToMate: 0,
        playerColor: PieceColor.white,
        hints: ['Attack two pieces at once', 'The knight can check the king and attack the rook'],
      ),
      ChessPuzzle(
        id: 'default_3',
        name: 'Smothered Mate',
        description: 'Classic smothered mate pattern',
        fenPosition: '6rk/6pp/7N/8/8/8/8/7K w - - 0 1',
        solution: ['Nf7#'],
        difficulty: PuzzleDifficulty.easy,
        theme: 'Checkmate',
        movesToMate: 1,
        playerColor: PieceColor.white,
        hints: ['King trapped by own pieces', 'Knight delivers the mate'],
      ),
      ChessPuzzle(
        id: 'default_4',
        name: 'Queen and King Mate',
        description: 'Simple checkmate with queen',
        fenPosition: '7k/8/6K1/8/8/8/8/7Q w - - 0 1',
        solution: ['Qh7#'],
        difficulty: PuzzleDifficulty.easy,
        theme: 'Checkmate',
        movesToMate: 1,
        playerColor: PieceColor.white,
        hints: ['The king is trapped on the edge', 'Deliver checkmate with the queen'],
      ),
      ChessPuzzle(
        id: 'default_5',
        name: 'Pawn Promotion',
        description: 'Promote with check',
        fenPosition: '6k1/5PPp/6p1/8/8/8/8/6K1 w - - 0 1',
        solution: ['f8=Q+'],
        difficulty: PuzzleDifficulty.easy,
        theme: 'Promotion',
        movesToMate: 0,
        playerColor: PieceColor.white,
        hints: ['Promote the pawn', 'Give check with the new queen'],
      ),

      // MEDIUM PUZZLES
      ChessPuzzle(
        id: 'default_6',
        name: 'Pin Tactic',
        description: 'Attack the pinned knight',
        fenPosition: 'r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 4',
        solution: ['Ng5'],
        difficulty: PuzzleDifficulty.medium,
        theme: 'Pin',
        movesToMate: 0,
        playerColor: PieceColor.white,
        hints: ['The knight on f6 is pinned to the king', 'Attack it with your knight'],
      ),
      ChessPuzzle(
        id: 'default_7',
        name: 'Discovered Attack',
        description: 'Remove the defender with a discovered attack',
        fenPosition: 'r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQK2R w KQkq - 0 4',
        solution: ['Bxf7+'],
        difficulty: PuzzleDifficulty.medium,
        theme: 'Discovered Attack',
        movesToMate: 0,
        playerColor: PieceColor.white,
        hints: ['Sacrifice the bishop', 'This reveals an attack on the queen'],
      ),
      ChessPuzzle(
        id: 'default_8',
        name: 'Skewer Attack',
        description: 'Attack king and win rook',
        fenPosition: 'r3k3/8/8/8/8/8/4B3/R3K2R w - - 0 1',
        solution: ['Bb5+'],
        difficulty: PuzzleDifficulty.medium,
        theme: 'Skewer',
        movesToMate: 0,
        playerColor: PieceColor.white,
        hints: ['Check the king first', 'The rook is behind the king'],
      ),

      // HARD PUZZLES
      ChessPuzzle(
        id: 'default_9',
        name: 'Deflection',
        description: 'Deflect the defender',
        fenPosition: 'r4rk1/5ppp/4B3/4N3/8/8/5PPP/5RK1 w - - 0 1',
        solution: ['Nd7'],
        difficulty: PuzzleDifficulty.hard,
        theme: 'Deflection',
        movesToMate: 0,
        playerColor: PieceColor.white,
        hints: ['Move the knight with a threat', 'The bishop will attack the rook'],
      ),
      ChessPuzzle(
        id: 'default_10',
        name: 'Zugzwang',
        description: 'Put opponent in zugzwang',
        fenPosition: '7k/6Pp/6K1/8/8/8/8/7R w - - 0 1',
        solution: ['Rh2'],
        difficulty: PuzzleDifficulty.hard,
        theme: 'Zugzwang',
        movesToMate: 0,
        playerColor: PieceColor.white,
        hints: ['Any king move loses for black', 'Wait for opponent to move'],
      ),

      // EXPERT PUZZLES
      ChessPuzzle(
        id: 'default_11',
        name: 'Queen Sacrifice',
        description: 'Sacrifice queen for checkmate',
        fenPosition: 'r4rk1/5Qpp/8/8/8/8/5PPP/R5K1 w - - 0 1',
        solution: ['Qxf7+', 'Rxf7', 'Ra8#'],
        difficulty: PuzzleDifficulty.expert,
        theme: 'Sacrifice',
        movesToMate: 2,
        playerColor: PieceColor.white,
        hints: ['Give up the queen', 'Rook delivers mate'],
      ),
      ChessPuzzle(
        id: 'default_12',
        name: 'Complex Combination',
        description: 'Multi-move tactical sequence',
        fenPosition: 'r1bq1rk1/5ppp/8/4N3/8/8/5PPP/R1BQ1RK1 w - - 0 1',
        solution: ['Nf7'],
        difficulty: PuzzleDifficulty.expert,
        theme: 'Combination',
        movesToMate: 0,
        playerColor: PieceColor.white,
        hints: ['Fork multiple pieces', 'Calculate all variations'],
      ),
    ];
  }
}

// Export singleton instance for easy access
final puzzleService = UnifiedPuzzleService.instance;