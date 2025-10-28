import 'package:hive_flutter/hive_flutter.dart';

class PuzzleDatabase {
  static const String _boxName = 'puzzles';
  static const String _progressBoxName = 'progress';
  static const String _themeBoxName = 'themes';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_boxName);
    await Hive.openBox<Map>(_progressBoxName);
    await Hive.openBox<List>(_themeBoxName);

    final box = Hive.box<Map>(_boxName);
    if (box.isEmpty) {
      await _insertInitialPuzzles();
    }
    print('Hive database initialized with ${box.length} puzzles');
  }

  static Future<void> _insertInitialPuzzles() async {
    final box = Hive.box<Map>(_boxName);
    print('Inserting themed puzzles into Hive...');

    final puzzles = [
      // CHECKMATE PATTERNS
      {'id': 'cm1', 'name': 'Back Rank Mate', 'description': 'Classic back rank checkmate', 'fenPosition': '6k1/5ppp/8/8/8/8/8/R6K w - - 0 1', 'solution': 'Ra8#', 'difficulty': 'easy', 'theme': 'Back Rank Mate', 'category': 'Checkmate Patterns', 'movesToMate': 1, 'playerColor': 'white', 'hints': 'The king has no escape|Move rook to back rank', 'tier': 1},
      {'id': 'cm2', 'name': 'Smothered Mate', 'description': 'Knight delivers checkmate', 'fenPosition': '6rk/6pp/7N/8/8/8/8/7K w - - 0 1', 'solution': 'Nf7#', 'difficulty': 'easy', 'theme': 'Smothered Mate', 'category': 'Checkmate Patterns', 'movesToMate': 1, 'playerColor': 'white', 'hints': 'King trapped by own pieces|Knight jumps in', 'tier': 1},
      {'id': 'cm3', 'name': 'Arabian Mate', 'description': 'Rook and knight checkmate', 'fenPosition': '7k/7N/6R1/8/8/8/8/6K1 w - - 0 1', 'solution': 'Rh6#', 'difficulty': 'easy', 'theme': 'Arabian Mate', 'category': 'Checkmate Patterns', 'movesToMate': 1, 'playerColor': 'white', 'hints': 'Knight controls f7|Rook to h6', 'tier': 1},

      // TACTICAL MOTIFS
      {'id': 'tm1', 'name': 'Knight Fork', 'description': 'Fork king and rook', 'fenPosition': 'r4rk1/5ppp/8/4N3/8/8/5PPP/5RK1 w - - 0 1', 'solution': 'Nd7', 'difficulty': 'medium', 'theme': 'Fork', 'category': 'Tactical Motifs', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Attack two pieces at once|Check the king', 'tier': 3},
      {'id': 'tm2', 'name': 'Pin Tactic', 'description': 'Pin knight to king', 'fenPosition': 'r3k2r/8/4n3/8/8/8/5B2/4K2R w - - 0 1', 'solution': 'Bd4', 'difficulty': 'medium', 'theme': 'Pin', 'category': 'Tactical Motifs', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Align bishop with king|Knight cannot move', 'tier': 3},
      {'id': 'tm3', 'name': 'Skewer Attack', 'description': 'Attack king then rook', 'fenPosition': 'r3k3/8/8/8/8/8/4B3/R3K2R w - - 0 1', 'solution': 'Bb5+', 'difficulty': 'medium', 'theme': 'Skewer', 'category': 'Tactical Motifs', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Check the king|Win the rook', 'tier': 3},
      {'id': 'tm4', 'name': 'Discovered Attack', 'description': 'Uncover attacking piece', 'fenPosition': 'r4rk1/5ppp/4B3/4N3/8/8/5PPP/5RK1 w - - 0 1', 'solution': 'Nd7', 'difficulty': 'medium', 'theme': 'Discovered Attack', 'category': 'Tactical Motifs', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Move knight with threat|Bishop attacks rook', 'tier': 3},
      {'id': 'tm5', 'name': 'Double Check', 'description': 'Two pieces give check', 'fenPosition': '6k1/5ppp/8/8/8/8/5PPP/R3R1K1 w - - 0 1', 'solution': 'Re8+', 'difficulty': 'medium', 'theme': 'Double Check', 'category': 'Tactical Motifs', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Move rook with check|Both rooks attack', 'tier': 2},

      // DEFENSIVE PUZZLES
      {'id': 'dp1', 'name': 'Perpetual Check', 'description': 'Force a draw', 'fenPosition': '6k1/5ppp/8/8/8/8/5Q2/6K1 w - - 0 1', 'solution': 'Qf8+,Kh7,Qf7+', 'difficulty': 'medium', 'theme': 'Perpetual Check', 'category': 'Defensive Puzzles', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Repeat checks|Force a draw', 'tier': 4},
      {'id': 'dp2', 'name': 'Counterattack', 'description': 'Turn defense into offense', 'fenPosition': 'r4rk1/5ppp/8/8/8/8/5Q2/R6K w - - 0 1', 'solution': 'Qf8+', 'difficulty': 'medium', 'theme': 'Counterattack', 'category': 'Defensive Puzzles', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Attack instead of defend|Check the king', 'tier': 4},

      // ENDGAME TACTICS
      {'id': 'et1', 'name': 'Pawn Promotion', 'description': 'Promote with check', 'fenPosition': '6k1/5PPp/6p1/8/8/8/8/6K1 w - - 0 1', 'solution': 'f8=Q+', 'difficulty': 'easy', 'theme': 'Promotion', 'category': 'Endgame Tactics', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Promote with check|New queen', 'tier': 2},
      {'id': 'et2', 'name': 'King and Pawn', 'description': 'Precise king movement', 'fenPosition': '6k1/5p1p/6p1/8/8/8/5PKP/8 w - - 0 1', 'solution': 'Kf3', 'difficulty': 'medium', 'theme': 'King and Pawn', 'category': 'Endgame Tactics', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Advance the king|Control key squares', 'tier': 4},

      // ADVANCED THEMES
      {'id': 'at1', 'name': 'Zugzwang', 'description': 'Any move loses', 'fenPosition': '7k/6Pp/6K1/8/8/8/8/7R w - - 0 1', 'solution': 'Rh2', 'difficulty': 'hard', 'theme': 'Zugzwang', 'category': 'Advanced Themes', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Put opponent in zugzwang|Any king move loses', 'tier': 4},
      {'id': 'at2', 'name': 'Zwischenzug', 'description': 'In-between move', 'fenPosition': 'r1bq1rk1/5ppp/8/4N3/8/8/5PPP/R1BQ1RK1 w - - 0 1', 'solution': 'Nf7', 'difficulty': 'hard', 'theme': 'Zwischenzug', 'category': 'Advanced Themes', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Insert a threat first|Don\'t recapture immediately', 'tier': 4},
      {'id': 'at3', 'name': 'Queen Sacrifice', 'description': 'Sacrifice for mate', 'fenPosition': 'r4rk1/5Qpp/8/8/8/8/5PPP/R5K1 w - - 0 1', 'solution': 'Qxf7+,Rxf7,Ra8#', 'difficulty': 'hard', 'theme': 'Queen Sacrifice', 'category': 'Advanced Themes', 'movesToMate': 0, 'playerColor': 'white', 'hints': 'Give up the queen|Rook delivers mate', 'tier': 5},
    ];

    for (var puzzle in puzzles) {
      await box.put(puzzle['id'], puzzle);
    }

    // Store available themes
    final themeBox = Hive.box<List>(_themeBoxName);
    await themeBox.put('categories', [
      'Checkmate Patterns',
      'Tactical Motifs',
      'Defensive Puzzles',
      'Endgame Tactics',
      'Advanced Themes',
    ]);

    print('Inserted ${puzzles.length} themed puzzles into Hive');
  }

  static List<Map<String, dynamic>> getAllPuzzles() {
    final box = Hive.box<Map>(_boxName);
    return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static List<Map<String, dynamic>> getPuzzlesByDifficulty(String difficulty) {
    final box = Hive.box<Map>(_boxName);
    return box.values
        .where((e) => e['difficulty'] == difficulty)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static List<Map<String, dynamic>> getPuzzlesByCategory(String category) {
    final box = Hive.box<Map>(_boxName);
    return box.values
        .where((e) => e['category'] == category)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static List<Map<String, dynamic>> getPuzzlesByTheme(String theme) {
    final box = Hive.box<Map>(_boxName);
    return box.values
        .where((e) => e['theme'] == theme)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static List<String> getAllCategories() {
    final themeBox = Hive.box<List>(_themeBoxName);
    final categories = themeBox.get('categories');
    return categories?.cast<String>() ?? [];
  }

  static List<Map<String, dynamic>> getPuzzlesByTier(int tier) {
    final box = Hive.box<Map>(_boxName);
    return box.values
        .where((e) => e['tier'] == tier)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<void> saveProgress(String puzzleId, bool completed, bool skipped, int attempts, int timeSpent) async {
    final box = Hive.box<Map>(_progressBoxName);
    await box.put(puzzleId, {
      'completed': completed,
      'skipped': skipped,
      'attempts': attempts,
      'timeSpent': timeSpent,
      'lastAttempt': DateTime.now().toIso8601String(),
    });
  }

  static int getCompletedCount() {
    final box = Hive.box<Map>(_progressBoxName);
    return box.values.where((e) => e['completed'] == true).length;
  }
}