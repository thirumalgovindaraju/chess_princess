// lib/database/progress_helper.dart
// Local progress tracking using Hive (no PostgreSQL required)
import 'package:hive_flutter/hive_flutter.dart';

class ProgressHelper {
  static const String _progressBox = 'user_progress';
  static const String _statsBox = 'user_stats';

  // Initialize Hive boxes
  static Future<void> init() async {
    await Hive.openBox<Map>(_progressBox);
    await Hive.openBox<Map>(_statsBox);
    print('Progress tracking initialized');
  }

  // Save progress for a puzzle
  static Future<void> saveProgress({
    required String puzzleId,
    required bool completed,
    required bool skipped,
    required int attempts,
    required int timeSpentSeconds,
  }) async {
    final box = Hive.box<Map>(_progressBox);

    final existing = box.get(puzzleId);
    final previousAttempts = existing != null ? (existing['attempts'] as int? ?? 0) : 0;
    final previousTime = existing != null ? (existing['timeSpent'] as int? ?? 0) : 0;

    await box.put(puzzleId, {
      'completed': completed,
      'skipped': skipped,
      'attempts': previousAttempts + attempts,
      'timeSpent': previousTime + timeSpentSeconds,
      'lastAttempt': DateTime.now().toIso8601String(),
      'firstAttempt': existing?['firstAttempt'] ?? DateTime.now().toIso8601String(),
    });

    // Update global stats
    await _updateGlobalStats(completed, skipped, attempts, timeSpentSeconds);

    print('Progress saved for puzzle $puzzleId: completed=$completed, skipped=$skipped');
  }

  // Update global statistics
  static Future<void> _updateGlobalStats(
      bool completed,
      bool skipped,
      int attempts,
      int timeSpent,
      ) async {
    final box = Hive.box<Map>(_statsBox);
    final stats = box.get('global', defaultValue: {
      'totalAttempted': 0,
      'totalSolved': 0,
      'totalSkipped': 0,
      'totalAttempts': 0,
      'totalTime': 0,
    }) as Map;

    stats['totalAttempted'] = (stats['totalAttempted'] as int? ?? 0) + 1;
    if (completed) {
      stats['totalSolved'] = (stats['totalSolved'] as int? ?? 0) + 1;
    }
    if (skipped) {
      stats['totalSkipped'] = (stats['totalSkipped'] as int? ?? 0) + 1;
    }
    stats['totalAttempts'] = (stats['totalAttempts'] as int? ?? 0) + attempts;
    stats['totalTime'] = (stats['totalTime'] as int? ?? 0) + timeSpent;

    await box.put('global', stats);
  }

  // Get progress for a specific puzzle
  static Map<String, dynamic>? getProgress(String puzzleId) {
    final box = Hive.box<Map>(_progressBox);
    final data = box.get(puzzleId);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // Get count of completed puzzles
  static int getCompletedCount() {
    final box = Hive.box<Map>(_progressBox);
    return box.values.where((e) => e['completed'] == true).length;
  }

  // Get count of skipped puzzles
  static int getSkippedCount() {
    final box = Hive.box<Map>(_progressBox);
    return box.values.where((e) => e['skipped'] == true).length;
  }

  // Get total attempted puzzles
  static int getAttemptedCount() {
    final box = Hive.box<Map>(_progressBox);
    return box.length;
  }

  // Get global statistics
  static Map<String, dynamic> getGlobalStats() {
    final box = Hive.box<Map>(_statsBox);
    final stats = box.get('global', defaultValue: {
      'totalAttempted': 0,
      'totalSolved': 0,
      'totalSkipped': 0,
      'totalAttempts': 0,
      'totalTime': 0,
    }) as Map;

    return Map<String, dynamic>.from(stats);
  }

  // Get list of solved puzzle IDs
  static List<String> getSolvedPuzzleIds() {
    final box = Hive.box<Map>(_progressBox);
    return box.keys
        .where((key) {
      final data = box.get(key);
      return data != null && data['completed'] == true;
    })
        .map((key) => key.toString())
        .toList();
  }

  // Check if puzzle is completed
  static bool isPuzzleCompleted(String puzzleId) {
    final progress = getProgress(puzzleId);
    return progress?['completed'] == true;
  }

  // Check if puzzle is skipped
  static bool isPuzzleSkipped(String puzzleId) {
    final progress = getProgress(puzzleId);
    return progress?['skipped'] == true;
  }

  // Get attempts for puzzle
  static int getPuzzleAttempts(String puzzleId) {
    final progress = getProgress(puzzleId);
    return progress?['attempts'] ?? 0;
  }

  // Get time spent on puzzle (in seconds)
  static int getPuzzleTimeSpent(String puzzleId) {
    final progress = getProgress(puzzleId);
    return progress?['timeSpent'] ?? 0;
  }

  // Reset progress for a puzzle
  static Future<void> resetPuzzleProgress(String puzzleId) async {
    final box = Hive.box<Map>(_progressBox);
    await box.delete(puzzleId);
    print('Progress reset for puzzle $puzzleId');
  }

  // Reset all progress
  static Future<void> resetAllProgress() async {
    final progressBox = Hive.box<Map>(_progressBox);
    final statsBox = Hive.box<Map>(_statsBox);

    await progressBox.clear();
    await statsBox.clear();

    print('All progress reset');
  }

  // Get recent puzzles (last 10)
  static List<Map<String, dynamic>> getRecentPuzzles({int limit = 10}) {
    final box = Hive.box<Map>(_progressBox);

    final allProgress = box.keys.map((key) {
      final data = box.get(key);
      if (data == null) return null;

      return {
        'puzzleId': key.toString(),
        ...Map<String, dynamic>.from(data),
      };
    }).whereType<Map<String, dynamic>>().toList();

    // Sort by last attempt (most recent first)
    allProgress.sort((a, b) {
      final aTime = DateTime.parse(a['lastAttempt'] as String? ?? '2000-01-01');
      final bTime = DateTime.parse(b['lastAttempt'] as String? ?? '2000-01-01');
      return bTime.compareTo(aTime);
    });

    return allProgress.take(limit).toList();
  }

  // Get success rate
  static double getSuccessRate() {
    final attempted = getAttemptedCount();
    if (attempted == 0) return 0.0;

    final completed = getCompletedCount();
    return (completed / attempted) * 100;
  }

  // Get average time per puzzle (in seconds)
  static double getAverageTimePerPuzzle() {
    final stats = getGlobalStats();
    final totalTime = stats['totalTime'] as int? ?? 0;
    final totalSolved = stats['totalSolved'] as int? ?? 0;

    if (totalSolved == 0) return 0.0;
    return totalTime / totalSolved;
  }

  // Get average attempts per puzzle
  static double getAverageAttemptsPerPuzzle() {
    final stats = getGlobalStats();
    final totalAttempts = stats['totalAttempts'] as int? ?? 0;
    final totalSolved = stats['totalSolved'] as int? ?? 0;

    if (totalSolved == 0) return 0.0;
    return totalAttempts / totalSolved;
  }

  // Export progress to JSON (for backup)
  static Map<String, dynamic> exportProgress() {
    final progressBox = Hive.box<Map>(_progressBox);
    final statsBox = Hive.box<Map>(_statsBox);

    return {
      'progress': progressBox.toMap(),
      'stats': statsBox.toMap(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  // Import progress from JSON (for restore)
  static Future<void> importProgress(Map<String, dynamic> data) async {
    final progressBox = Hive.box<Map>(_progressBox);
    final statsBox = Hive.box<Map>(_statsBox);

    await progressBox.clear();
    await statsBox.clear();

    if (data['progress'] != null) {
      final progressData = data['progress'] as Map;
      for (var entry in progressData.entries) {
        await progressBox.put(entry.key, entry.value);
      }
    }

    if (data['stats'] != null) {
      final statsData = data['stats'] as Map;
      for (var entry in statsData.entries) {
        await statsBox.put(entry.key, entry.value);
      }
    }

    print('Progress imported successfully');
  }
}