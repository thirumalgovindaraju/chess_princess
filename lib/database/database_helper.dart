import 'package:postgres/postgres.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  PostgreSQLConnection? _connection;

  // Singleton pattern
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  DatabaseHelper._internal();

  // Database configuration
  Future<PostgreSQLConnection> get connection async {
    if (_connection != null && !_connection!.isClosed) {
      return _connection!;
    }

    _connection = PostgreSQLConnection(
      'localhost',  // Replace with your PostgreSQL host
      5432,             // Port
      'chess_puzzles_db',  // Database name
      username: 'postgres',
      password: 'admin123',
      useSSL: false,
    );

    await _connection!.open();
    return _connection!;
  }

  // Close connection
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }

  // ===== PUZZLE RETRIEVAL METHODS =====

  // Get all puzzles with pagination
  Future<List<Map<String, dynamic>>> getAllPuzzles({
    int limit = 100000,
    int offset = 0,
  }) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT * FROM puzzles ORDER BY rating ASC LIMIT @limit OFFSET @offset',
      substitutionValues: {'limit': limit, 'offset': offset},
    );
    return _mapPuzzleResults(results);
  }

  // Get puzzles by category with pagination
  Future<List<Map<String, dynamic>>> getPuzzlesByCategory(
      String category, {
        int limit = 100000,
        int offset = 0,
      }) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT * FROM puzzles WHERE category = @category ORDER BY rating ASC LIMIT @limit OFFSET @offset',
      substitutionValues: {'category': category, 'limit': limit, 'offset': offset},
    );
    return _mapPuzzleResults(results);
  }

  // Get puzzle by ID
  Future<Map<String, dynamic>?> getPuzzleById(String puzzleId) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT * FROM puzzles WHERE "puzzleId" = @puzzleId LIMIT 1',
      substitutionValues: {'puzzleId': puzzleId},
    );

    if (results.isEmpty) return null;
    return _mapPuzzleRow(results.first);
  }


  // Get random puzzle by category
  Future<Map<String, dynamic>?> getRandomPuzzleByCategory(String category) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT * FROM puzzles WHERE category = @category ORDER BY RANDOM() LIMIT 1',
      substitutionValues: {'category': category},
    );

    if (results.isEmpty) return null;
    return _mapPuzzleRow(results.first);
  }

  // Get filtered puzzles (advanced search)
  Future<List<Map<String, dynamic>>> getFilteredPuzzles({
    String? category,
    int? difficultyLevel,
    int? minRating,
    int? maxRating,
    List<String>? themes,
    int limit = 100000,
    int offset = 0,
  }) async {
    final conn = await connection;

    String query = 'SELECT * FROM puzzles WHERE 1=1';
    Map<String, dynamic> params = {};

    if (category != null && category != 'Mixed') {
      query += ' AND category = @category';
      params['category'] = category;
    }

    if (difficultyLevel != null) {
      query += ' AND difficulty_level = @difficultyLevel';
      params['difficultyLevel'] = difficultyLevel;
    }

    if (minRating != null) {
      query += ' AND rating >= @minRating';
      params['minRating'] = minRating;
    }

    if (maxRating != null) {
      query += ' AND rating <= @maxRating';
      params['maxRating'] = maxRating;
    }

    if (themes != null && themes.isNotEmpty) {
      for (int i = 0; i < themes.length; i++) {
        query += ' AND themes ILIKE @theme$i';
        params['theme$i'] = '%${themes[i]}%';
      }
    }

    query += ' ORDER BY rating ASC LIMIT @limit OFFSET @offset';
    params['limit'] = limit;
    params['offset'] = offset;

    final results = await conn.query(query, substitutionValues: params);
    return _mapPuzzleResults(results);
  }

  // ===== STATISTICS METHODS =====

  // Get category statistics
  Future<Map<String, int>> getCategoryStats() async {
    final conn = await connection;
    final results = await conn.query('''
      SELECT category, COUNT(*) as count 
      FROM puzzles 
      WHERE category IS NOT NULL
      GROUP BY category 
      ORDER BY count DESC
    ''');

    Map<String, int> stats = {};
    for (var row in results) {
      final category = row[0] as String;
      final count = row[1] as int;
      stats[category] = count;
    }
    return stats;
  }

  // Get difficulty level statistics
  Future<Map<int, int>> getDifficultyLevelStats() async {
    final conn = await connection;
    final results = await conn.query('''
      SELECT difficulty_level, COUNT(*) as count 
      FROM puzzles 
      WHERE difficulty_level IS NOT NULL
      GROUP BY difficulty_level 
      ORDER BY difficulty_level
    ''');

    Map<int, int> stats = {};
    for (var row in results) {
      final level = row[0] as int;
      final count = row[1] as int;
      stats[level] = count;
    }
    return stats;
  }

  // Get rating distribution
  Future<Map<String, int>> getRatingDistribution() async {
    final conn = await connection;
    final results = await conn.query('''
      SELECT 
        CASE 
          WHEN rating < 1000 THEN '< 1000'
          WHEN rating BETWEEN 1000 AND 1499 THEN '1000-1499'
          WHEN rating BETWEEN 1500 AND 1999 THEN '1500-1999'
          WHEN rating BETWEEN 2000 AND 2499 THEN '2000-2499'
          ELSE '2500+'
        END as rating_range,
        COUNT(*) as count
      FROM puzzles
      GROUP BY rating_range
      ORDER BY MIN(rating)
    ''');

    Map<String, int> distribution = {};
    for (var row in results) {
      distribution[row[0] as String] = row[1] as int;
    }
    return distribution;
  }

  // Get total puzzle count
  Future<int> getTotalPuzzleCount() async {
    final conn = await connection;
    final results = await conn.query('SELECT COUNT(*) FROM puzzles');
    return results.first[0] as int;
  }

  // Get theme statistics
  Future<Map<String, int>> getThemeStats({int limit = 20}) async {
    final conn = await connection;
    final results = await conn.query('''
      SELECT 
        unnest(string_to_array(themes, ' ')) as theme,
        COUNT(*) as count
      FROM puzzles
      WHERE themes IS NOT NULL AND themes != ''
      GROUP BY theme
      HAVING COUNT(*) > 100000
      ORDER BY count DESC
      LIMIT @limit
    ''', substitutionValues: {'limit': limit});

    Map<String, int> stats = {};
    for (var row in results) {
      if (row[0] != null && row[0].toString().isNotEmpty) {
        stats[row[0] as String] = row[1] as int;
      }
    }
    return stats;
  }

  // ===== USER PROGRESS METHODS (Optional) =====

  // Save user progress
  Future<void> saveUserProgress({
    required String userId,
    required String puzzleId,
    required bool solved,
    required int attempts,
    required int timeSpent,
  }) async {
    final conn = await connection;
    await conn.query('''
      INSERT INTO user_progress (user_id, puzzle_id, solved, attempts, time_spent, completed_at)
      VALUES (@userId, @puzzleId, @solved, @attempts, @timeSpent, NOW())
      ON CONFLICT (user_id, puzzle_id) 
      DO UPDATE SET 
        solved = @solved,
        attempts = user_progress.attempts + @attempts,
        time_spent = user_progress.time_spent + @timeSpent,
        completed_at = NOW()
    ''', substitutionValues: {
      'userId': userId,
      'puzzleId': puzzleId,
      'solved': solved,
      'attempts': attempts,
      'timeSpent': timeSpent,
    });
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final conn = await connection;
    final results = await conn.query('''
      SELECT 
        COUNT(*) as total_attempted,
        SUM(CASE WHEN solved THEN 1 ELSE 0 END) as total_solved,
        SUM(attempts) as total_attempts,
        SUM(time_spent) as total_time,
        AVG(CASE WHEN solved THEN attempts ELSE NULL END) as avg_attempts_to_solve
      FROM user_progress
      WHERE user_id = @userId
    ''', substitutionValues: {'userId': userId});

    if (results.isEmpty) return {};

    final row = results.first;
    return {
      'totalAttempted': row[0] ?? 0,
      'totalSolved': row[1] ?? 0,
      'totalAttempts': row[2] ?? 0,
      'totalTime': row[3] ?? 0,
      'avgAttemptsToSolve': row[4]?.toDouble() ?? 0.0,
    };
  }

  // Get user's solved puzzles
  Future<List<String>> getUserSolvedPuzzles(String userId) async {
    final conn = await connection;
    final results = await conn.query('''
      SELECT puzzle_id FROM user_progress 
      WHERE user_id = @userId AND solved = true
      ORDER BY completed_at DESC
    ''', substitutionValues: {'userId': userId});

    return results.map((row) => row[0] as String).toList();
  }

  // ===== HELPER METHODS =====

  List<Map<String, dynamic>> _mapPuzzleResults(PostgreSQLResult results) {
    return results.map((row) => _mapPuzzleRow(row)).toList();
  }

  Map<String, dynamic> _mapPuzzleRow(PostgreSQLResultRow row) {
    return {
      'puzzleId': row[0],
      'fen': row[1],
      'moves': row[2],
      'rating': row[3],
      'ratingDeviation': row[4],
      'popularity': row[5],
      'numPlays': row[6],
      'themes': row[7],
      'gameUrl': row[8],
      'openingTags': row[9],
      'category': row.length > 10 ? row[10] : 'Mixed',
      'subcategory': row.length > 11 ? row[11] : null,
      'difficulty_level': row.length > 12 ? row[12] : null,
    };
  }

  // ===== COMPATIBILITY WRAPPERS for PuzzleService =====

// Fix naming mismatch
  Future<int> getTotalPuzzlesCount() async {
    return await getTotalPuzzleCount(); // already defined
  }

// Get puzzles by rating range
  Future<List<Map<String, dynamic>>> getPuzzlesByRating(
      int minRating,
      int maxRating, {
        int limit = 100000,
      }) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT * FROM puzzles WHERE rating BETWEEN @min AND @max ORDER BY rating ASC LIMIT @limit',
      substitutionValues: {'min': minRating, 'max': maxRating, 'limit': limit},
    );
    return _mapPuzzleResults(results);
  }

// Get puzzles by theme
  Future<List<Map<String, dynamic>>> getPuzzlesByTheme(
      String theme, {
        int limit = 100000,
      }) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT * FROM puzzles WHERE themes ILIKE @theme ORDER BY rating ASC LIMIT @limit',
      substitutionValues: {'theme': '%$theme%', 'limit': limit},
    );
    return _mapPuzzleResults(results);
  }

// Get unsolved puzzles (if you track user progress)
  Future<List<Map<String, dynamic>>> getUnsolvedPuzzles({int limit = 100000}) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT * FROM puzzles ORDER BY RANDOM() LIMIT @limit',
      substitutionValues: {'limit': limit},
    );
    return _mapPuzzleResults(results);
  }

// Get popular puzzles (by popularity or numPlays)
  Future<List<Map<String, dynamic>>> getPopularPuzzles({int limit = 100000}) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT * FROM puzzles ORDER BY numPlays DESC NULLS LAST LIMIT @limit',
      substitutionValues: {'limit': limit},
    );
    return _mapPuzzleResults(results);
  }

// Advanced search
  Future<List<Map<String, dynamic>>> searchPuzzles({
    int? minRating,
    int? maxRating,
    String? theme,
    int limit = 100000,
    int offset = 0,
  }) async {
    final conn = await connection;
    String query = 'SELECT * FROM puzzles WHERE 1=1';
    Map<String, dynamic> params = {'limit': limit, 'offset': offset};

    if (minRating != null) {
      query += ' AND rating >= @minRating';
      params['minRating'] = minRating;
    }
    if (maxRating != null) {
      query += ' AND rating <= @maxRating';
      params['maxRating'] = maxRating;
    }
    if (theme != null && theme.isNotEmpty) {
      query += ' AND themes ILIKE @theme';
      params['theme'] = '%$theme%';
    }

    query += ' ORDER BY rating ASC LIMIT @limit OFFSET @offset';
    final results = await conn.query(query, substitutionValues: params);
    return _mapPuzzleResults(results);
  }

// Get available themes
  Future<List<String>> getAvailableThemes() async {
    final conn = await connection;
    final results = await conn.query('''
    SELECT DISTINCT unnest(string_to_array(themes, ' ')) AS theme
    FROM puzzles WHERE themes IS NOT NULL AND themes != ''
  ''');
    return results.map((row) => row[0] as String).toList();
  }

// Save puzzle progress
  Future<void> saveProgress({
    required String puzzleId,
    required bool completed,
    required bool skipped,
    required int attempts,
    required int timeSpentSeconds,
  }) async {
    await saveUserProgress(
      userId: 'default_user', // replace with actual user logic later
      puzzleId: puzzleId,
      solved: completed,
      attempts: attempts,
      timeSpent: timeSpentSeconds,
    );
  }

// Get count of completed puzzles
  Future<int> getCompletedCount() async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT COUNT(*) FROM user_progress WHERE solved = true',
    );
    return results.first[0] as int;
  }

// General user statistics wrapper
  Future<Map<String, dynamic>> getStatistics() async {
    return await getUserStats('default_user'); // fallback user
  }

// Overload getRandomPuzzle with optional rating range
  Future<Map<String, dynamic>?> getRandomPuzzle({
    int? minRating,
    int? maxRating,
  }) async {
    final conn = await connection;
    String query = 'SELECT * FROM puzzles';
    Map<String, dynamic> params = {};

    if (minRating != null) {
      query += ' WHERE rating >= @min';
      params['min'] = minRating;
    }
    if (maxRating != null) {
      query += minRating != null
          ? ' AND rating <= @max'
          : ' WHERE rating <= @max';
      params['max'] = maxRating;
    }

    query += ' ORDER BY RANDOM() LIMIT 1';
    final results = await conn.query(query, substitutionValues: params);
    return results.isNotEmpty ? _mapPuzzleRow(results.first) : null;
  }


  // Refresh materialized views (if you create them for performance)
  Future<void> refreshMaterializedViews() async {
    final conn = await connection;
    try {
      await conn.query('REFRESH MATERIALIZED VIEW CONCURRENTLY puzzle_stats');
    } catch (e) {
      print('No materialized views to refresh: $e');
    }
  }

  // Vacuum analyze for performance
  Future<void> optimizeDatabase() async {
    final conn = await connection;
    await conn.query('VACUUM ANALYZE puzzles');
  }
}