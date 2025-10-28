import '../models/chess_puzzle.dart';
import '../models/chess_board.dart';
import '../models/position.dart';
import '../database/database_helper.dart';
import 'dart:math';

class EnhancedPuzzleService {
  // ===== CACHING SYSTEM =====
  static Map<String, int>? _categoryStats;
  static Map<int, int>? _difficultyStats;
  static Map<String, List<ChessPuzzle>>? _recentPuzzlesCache;
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiration = Duration(hours: 1);

  // ===== CATEGORIES =====
  static const List<PuzzleCategory> categories = [
    PuzzleCategory(
      id: 'Checkmate',
      name: 'Checkmate Puzzles',
      icon: '♔',
      description: 'Find the fastest checkmate',
      color: 0xFFE53935,
    ),
    PuzzleCategory(
      id: 'Tactics',
      name: 'Tactical Motifs',
      icon: '⚔️',
      description: 'Forks, pins, and skewers',
      color: 0xFFFF6F00,
    ),
    PuzzleCategory(
      id: 'Endgame',
      name: 'Endgame Mastery',
      icon: '👑',
      description: 'Win the endgame',
      color: 0xFF1976D2,
    ),
    PuzzleCategory(
      id: 'Opening',
      name: 'Opening Traps',
      icon: '🎯',
      description: 'Punish opening mistakes',
      color: 0xFF388E3C,
    ),
    PuzzleCategory(
      id: 'Middlegame',
      name: 'Middlegame Tactics',
      icon: '⚡',
      description: 'Win in the middlegame',
      color: 0xFF7B1FA2,
    ),
    PuzzleCategory(
      id: 'Sacrifices',
      name: 'Brilliant Sacrifices',
      icon: '💎',
      description: 'Sacrifice to win',
      color: 0xFFC2185B,
    ),
    PuzzleCategory(
      id: 'Defense',
      name: 'Defensive Tactics',
      icon: '🛡️',
      description: 'Save difficult positions',
      color: 0xFF00838F,
    ),
    PuzzleCategory(
      id: 'Mixed',
      name: 'Mixed Puzzles',
      icon: '🎲',
      description: 'All types of puzzles',
      color: 0xFF455A64,
    ),
  ];

  // ===== CACHE MANAGEMENT =====

  static bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheExpiration;
  }

  static void clearCache() {
    _categoryStats = null;
    _difficultyStats = null;
    _recentPuzzlesCache = null;
    _lastCacheUpdate = null;
  }

  static void _updateCacheTimestamp() {
    _lastCacheUpdate = DateTime.now();
  }

  // ===== STATISTICS METHODS =====

  static Future<Map<String, int>> getCategoryStats() async {
    if (_categoryStats != null && _isCacheValid()) {
      return _categoryStats!;
    }

    try {
      _categoryStats = await DatabaseHelper.instance.getCategoryStats();
      _updateCacheTimestamp();
      return _categoryStats!;
    } catch (e) {
      print('Error getting category stats: $e');
      return _categoryStats ?? {};
    }
  }

  static Future<Map<int, int>> getDifficultyLevelStats() async {
    if (_difficultyStats != null && _isCacheValid()) {
      return _difficultyStats!;
    }

    try {
      _difficultyStats = await DatabaseHelper.instance.getDifficultyLevelStats();
      _updateCacheTimestamp();
      return _difficultyStats!;
    } catch (e) {
      print('Error getting difficulty stats: $e');
      return _difficultyStats ?? {};
    }
  }

  // ===== PUZZLE RETRIEVAL =====

  static Future<List<ChessPuzzle>> getPuzzlesByCategory(
      String category, {
        int page = 1,
        int pageSize = 100,
      }) async {
    try {
      final offset = (page - 1) * pageSize;
      final puzzleMaps = await DatabaseHelper.instance.getPuzzlesByCategory(
        category,
        limit: pageSize,
        offset: offset,
      );

      return puzzleMaps.map((map) => _puzzleFromMap(map)).toList();
    } catch (e) {
      print('Error getting puzzles by category: $e');
      return [];
    }
  }

  static Future<List<ChessPuzzle>> getFilteredPuzzles({
    String? category,
    int? difficultyLevel,
    int? minRating,
    int? maxRating,
    List<String>? themes,
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final puzzleMaps = await DatabaseHelper.instance.getFilteredPuzzles(
        category: category,
        difficultyLevel: difficultyLevel,
        minRating: minRating,
        maxRating: maxRating,
        themes: themes,
        limit: pageSize,
        offset: offset,
      );

      return puzzleMaps.map((map) => _puzzleFromMap(map)).toList();
    } catch (e) {
      print('Error getting filtered puzzles: $e');
      return [];
    }
  }

  static Future<ChessPuzzle?> getRandomPuzzleByCategory(String category) async {
    try {
      final puzzleMap = await DatabaseHelper.instance.getRandomPuzzleByCategory(category);
      if (puzzleMap == null) return null;
      return _puzzleFromMap(puzzleMap);
    } catch (e) {
      print('Error getting random puzzle: $e');
      return null;
    }
  }

  // ===== DAILY PUZZLE =====

  static Future<ChessPuzzle?> getDailyPuzzle() async {
    try {
      final today = DateTime.now();
      final daysSinceEpoch = today.difference(DateTime(2025, 1, 1)).inDays;

      // Generate consistent puzzle ID for the day
      final puzzleId = (daysSinceEpoch % 100000).toString().padLeft(5, '0');

      final puzzleMap = await DatabaseHelper.instance.getPuzzleById(puzzleId);
      if (puzzleMap != null) {
        return _puzzleFromMap(puzzleMap);
      }

      // Fallback to random medium-difficulty puzzle
      final fallbackPuzzles = await getFilteredPuzzles(
        difficultyLevel: 3,
        pageSize: 1,
      );

      return fallbackPuzzles.isNotEmpty ? fallbackPuzzles.first : null;
    } catch (e) {
      print('Error getting daily puzzle: $e');
      return null;
    }
  }

  // ===== RECOMMENDATION ENGINE =====

  // Get recommended puzzles based on user skill level
  static Future<List<ChessPuzzle>> getRecommendedPuzzles({
    required int userRating,
    int count = 10,
    List<String>? preferredThemes,
  }) async {
    try {
      // Calculate rating range (±100 points)
      final minRating = (userRating - 100).clamp(500, 3000);
      final maxRating = (userRating + 100).clamp(500, 3000);

      final puzzles = await getFilteredPuzzles(
        minRating: minRating,
        maxRating: maxRating,
        themes: preferredThemes,
        pageSize: count * 2, // Get extra for variety
      );

      // Shuffle and return requested count
      puzzles.shuffle();
      return puzzles.take(count).toList();
    } catch (e) {
      print('Error getting recommended puzzles: $e');
      return [];
    }
  }

  // Get progressive training puzzles (gradually increasing difficulty)
  static Future<List<ChessPuzzle>> getProgressiveTrainingSet({
    required int startDifficulty,
    int count = 20,
  }) async {
    try {
      final puzzles = <ChessPuzzle>[];
      final puzzlesPerLevel = (count / 6).ceil();

      // Get puzzles from each difficulty level
      for (int level = startDifficulty; level <= 6 && puzzles.length < count; level++) {
        final levelPuzzles = await getFilteredPuzzles(
          difficultyLevel: level,
          pageSize: puzzlesPerLevel,
        );
        puzzles.addAll(levelPuzzles);
      }

      return puzzles.take(count).toList();
    } catch (e) {
      print('Error getting progressive training set: $e');
      return [];
    }
  }

  // Get themed puzzle set
  static Future<List<ChessPuzzle>> getThemedPuzzleSet({
    required String theme,
    int count = 15,
    int? minRating,
    int? maxRating,
  }) async {
    try {
      return await getFilteredPuzzles(
        themes: [theme],
        minRating: minRating,
        maxRating: maxRating,
        pageSize: count,
      );
    } catch (e) {
      print('Error getting themed puzzle set: $e');
      return [];
    }
  }

  // Get "Puzzle Rush" set (quick tactical puzzles)
  static Future<List<ChessPuzzle>> getPuzzleRushSet({
    int count = 50,
    int? difficultyLevel,
  }) async {
    try {
      // Focus on quick tactical themes
      const rushThemes = ['fork', 'pin', 'skewer', 'hangingPiece'];

      final puzzles = await getFilteredPuzzles(
        difficultyLevel: difficultyLevel,
        themes: rushThemes,
        pageSize: count,
      );

      puzzles.shuffle();
      return puzzles;
    } catch (e) {
      print('Error getting puzzle rush set: $e');
      return [];
    }
  }

  // ===== HELPER METHODS =====

  static ChessPuzzle _puzzleFromMap(Map<String, dynamic> map) {
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
      id: map['puzzleId'] ?? '',
      name: 'Puzzle ${map['puzzleId']}',
      description: 'Rating: $rating | ${map['category'] ?? "Mixed"}',
      fenPosition: fen,
      solution: moves,
      difficulty: difficulty,
      theme: primaryTheme,
      movesToMate: _calculateMovesToMate(themes),
      playerColor: playerColor,
      hints: _generateHints(themes, moves),
    );
  }

  static PuzzleDifficulty _ratingToDifficulty(int rating) {
    if (rating < 1200) return PuzzleDifficulty.easy;
    if (rating < 1800) return PuzzleDifficulty.medium;
    if (rating < 2400) return PuzzleDifficulty.hard;
    return PuzzleDifficulty.expert;
  }

  static PieceColor _getPlayerColorFromFEN(String fen) {
    final parts = fen.split(' ');
    if (parts.length > 1) {
      return parts[1] == 'w' ? PieceColor.white : PieceColor.black;
    }
    return PieceColor.white;
  }

  static int _calculateMovesToMate(List<String> themes) {
    for (var theme in themes) {
      if (theme.contains('mateIn')) {
        final match = RegExp(r'mateIn(\d+)').firstMatch(theme);
        if (match != null) {
          return int.tryParse(match.group(1) ?? '0') ?? 0;
        }
      }
    }
    return 0;
  }

  static List<String> _generateHints(List<String> themes, List<String> moves) {
    final hints = <String>[];

    // Theme-based hints
    if (themes.contains('fork')) hints.add('Look for a double attack!');
    if (themes.contains('pin')) hints.add('Pin the opponent\'s piece');
    if (themes.contains('skewer')) hints.add('Force the opponent to move');
    if (themes.contains('mate')) hints.add('Checkmate is near!');
    if (themes.contains('sacrifice')) hints.add('A sacrifice may be needed');
    if (themes.contains('discoveredAttack')) hints.add('Move to reveal an attack');
    if (themes.contains('deflection')) hints.add('Deflect the defender');
    if (themes.contains('attraction')) hints.add('Lure a piece to a bad square');
    if (themes.contains('hangingPiece')) hints.add('Look for undefended pieces');
    if (themes.contains('backRankMate')) hints.add('The back rank is weak');

    // Piece-based hints from first move
    if (moves.isNotEmpty) {
      final firstMove = moves.first;
      if (firstMove.contains('Q')) hints.add('The queen is powerful here');
      if (firstMove.contains('R')) hints.add('A rook move might be key');
      if (firstMove.contains('N')) hints.add('Knights can jump to victory');
      if (firstMove.contains('B')) hints.add('The bishop controls diagonals');
    }

    return hints.isNotEmpty ? hints : ['Think carefully about the position'];
  }

  // ===== UTILITY METHODS =====

  static PuzzleCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<PuzzleCategory> getCategoriesByDifficulty(PuzzleDifficulty difficulty) {
    // Return all categories (they all support all difficulties)
    return categories;
  }
}

// ===== CATEGORY MODEL =====

class PuzzleCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int color;

  const PuzzleCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PuzzleCategory &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}