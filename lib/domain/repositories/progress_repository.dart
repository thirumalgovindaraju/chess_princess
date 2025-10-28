// lib/domain/repositories/progress_repository.dart

abstract class ProgressRepository {
  /// Fetch lesson progress from remote or local source
  Future<Map<String, double>> fetchLessonProgress();

  /// Fetch drill progress from remote or local source
  Future<Map<String, double>> fetchDrillProgress();

  /// Fetch puzzle progress from remote or local source
  Future<Map<String, double>> fetchPuzzleProgress();

  /// Save lesson progress locally and sync with remote
  Future<void> saveLessonProgress(String lessonId, double progress);

  /// Save drill progress locally and sync with remote
  Future<void> saveDrillProgress(String drillId, double progress);

  /// Save puzzle progress locally and sync with remote
  Future<void> savePuzzleProgress(String puzzleId, double progress);

  /// Get training results/statistics
  Future<Map<String, dynamic>> getTrainingResults();

  /// Save training result
  Future<void> saveTrainingResult(Map<String, dynamic> result);

  /// Check if device is online
  Future<bool> isConnected();
}