// lib/data/repositories/progress_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/repositories/progress_repository.dart';
import '../../data/datasources/local_datasource.dart';
import '../../core/logger/app_logger.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final Dio dio;
  final LocalDataSource localDataSource;
  final Connectivity connectivity;
  final AppLogger logger;

  ProgressRepositoryImpl({
    required this.dio,
    required this.localDataSource,
    required this.connectivity,
    required this.logger,
  });

  @override
  Future<Map<String, double>> fetchLessonProgress() async {
    try {
      final connected = await _checkConnectivity();

      if (connected) {
        final response = await dio.get('/progress/lessons');
        final data = response.data as Map<String, dynamic>;
        final progress = Map<String, double>.from(
            data.map((key, value) => MapEntry(key, (value as num).toDouble()))
        );

        // Cache locally
        await localDataSource.cacheLessonProgress(progress);
        return progress;
      } else {
        // Return cached data if offline
        return await localDataSource.getLessonProgress();
      }
    } catch (e) {
      logger.error('Error fetching lesson progress: $e');
      // Fallback to local cache
      return await localDataSource.getLessonProgress();
    }
  }

  @override
  Future<Map<String, double>> fetchDrillProgress() async {
    try {
      final connected = await _checkConnectivity();

      if (connected) {
        final response = await dio.get('/progress/drills');
        final data = response.data as Map<String, dynamic>;
        final progress = Map<String, double>.from(
            data.map((key, value) => MapEntry(key, (value as num).toDouble()))
        );

        await localDataSource.cacheDrillProgress(progress);
        return progress;
      } else {
        return await localDataSource.getDrillProgress();
      }
    } catch (e) {
      logger.error('Error fetching drill progress: $e');
      return await localDataSource.getDrillProgress();
    }
  }

  @override
  Future<Map<String, double>> fetchPuzzleProgress() async {
    try {
      final connected = await _checkConnectivity();

      if (connected) {
        final response = await dio.get('/progress/puzzles');
        final data = response.data as Map<String, dynamic>;
        final progress = Map<String, double>.from(
            data.map((key, value) => MapEntry(key, (value as num).toDouble()))
        );

        await localDataSource.cachePuzzleProgress(progress);
        return progress;
      } else {
        return await localDataSource.getPuzzleProgress();
      }
    } catch (e) {
      logger.error('Error fetching puzzle progress: $e');
      return await localDataSource.getPuzzleProgress();
    }
  }

  @override
  Future<void> saveLessonProgress(String lessonId, double progress) async {
    try {
      // Save locally first
      await localDataSource.saveLessonProgress(lessonId, progress);

      // Sync with remote if connected
      final connected = await _checkConnectivity();
      if (connected) {
        await dio.post(
          '/progress/lessons/$lessonId',
          data: {'progress': progress},
        );
      }
    } catch (e) {
      logger.error('Error saving lesson progress: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveDrillProgress(String drillId, double progress) async {
    try {
      await localDataSource.saveDrillProgress(drillId, progress);

      final connected = await _checkConnectivity();
      if (connected) {
        await dio.post(
          '/progress/drills/$drillId',
          data: {'progress': progress},
        );
      }
    } catch (e) {
      logger.error('Error saving drill progress: $e');
      rethrow;
    }
  }

  @override
  Future<void> savePuzzleProgress(String puzzleId, double progress) async {
    try {
      await localDataSource.savePuzzleProgress(puzzleId, progress);

      final connected = await _checkConnectivity();
      if (connected) {
        await dio.post(
          '/progress/puzzles/$puzzleId',
          data: {'progress': progress},
        );
      }
    } catch (e) {
      logger.error('Error saving puzzle progress: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getTrainingResults() async {
    try {
      final connected = await _checkConnectivity();

      if (connected) {
        final response = await dio.get('/training/results');
        final data = response.data as Map<String, dynamic>;

        await localDataSource.cacheTrainingResults(data);
        return data;
      } else {
        return await localDataSource.getTrainingResults();
      }
    } catch (e) {
      logger.error('Error fetching training results: $e');
      return await localDataSource.getTrainingResults();
    }
  }

  @override
  Future<void> saveTrainingResult(Map<String, dynamic> result) async {
    try {
      await localDataSource.saveTrainingResult(result);

      final connected = await _checkConnectivity();
      if (connected) {
        await dio.post('/training/results', data: result);
      }
    } catch (e) {
      logger.error('Error saving training result: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isConnected() async {
    return await _checkConnectivity();
  }

  // Private helper method to avoid variable naming conflicts
  Future<bool> _checkConnectivity() async {
    try {
      final result = await connectivity.checkConnectivity();
      // Check if connected via mobile or wifi
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;
    } catch (e) {
      logger.error('Error checking connectivity: $e');
      return false;
    }
  }
}