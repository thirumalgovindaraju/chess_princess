// lib/data/datasources/local_data_source.dart
import 'package:hive/hive.dart';
import 'dart:convert';

class LocalDataSource {
  final Box<String> lessonsBox;
  final Box<String> drillsBox;
  final Box<String> puzzlesBox;
  final Box<String> resultsBox;

  LocalDataSource({
    required this.lessonsBox,
    required this.drillsBox,
    required this.puzzlesBox,
    required this.resultsBox,
  });

  // Lesson progress methods
  Future<Map<String, double>> getLessonProgress() async {
    try {
      final data = lessonsBox.get('progress');
      if (data == null) return {};

      final decoded = jsonDecode(data) as Map<String, dynamic>;
      return Map<String, double>.from(
          decoded.map((key, value) => MapEntry(key, (value as num).toDouble()))
      );
    } catch (e) {
      return {};
    }
  }

  Future<void> saveLessonProgress(String lessonId, double progress) async {
    final current = await getLessonProgress();
    current[lessonId] = progress;
    await lessonsBox.put('progress', jsonEncode(current));
  }

  Future<void> cacheLessonProgress(Map<String, double> progress) async {
    await lessonsBox.put('progress', jsonEncode(progress));
  }

  // Drill progress methods
  Future<Map<String, double>> getDrillProgress() async {
    try {
      final data = drillsBox.get('progress');
      if (data == null) return {};

      final decoded = jsonDecode(data) as Map<String, dynamic>;
      return Map<String, double>.from(
          decoded.map((key, value) => MapEntry(key, (value as num).toDouble()))
      );
    } catch (e) {
      return {};
    }
  }

  Future<void> saveDrillProgress(String drillId, double progress) async {
    final current = await getDrillProgress();
    current[drillId] = progress;
    await drillsBox.put('progress', jsonEncode(current));
  }

  Future<void> cacheDrillProgress(Map<String, double> progress) async {
    await drillsBox.put('progress', jsonEncode(progress));
  }

  // Puzzle progress methods
  Future<Map<String, double>> getPuzzleProgress() async {
    try {
      final data = puzzlesBox.get('progress');
      if (data == null) return {};

      final decoded = jsonDecode(data) as Map<String, dynamic>;
      return Map<String, double>.from(
          decoded.map((key, value) => MapEntry(key, (value as num).toDouble()))
      );
    } catch (e) {
      return {};
    }
  }

  Future<void> savePuzzleProgress(String puzzleId, double progress) async {
    final current = await getPuzzleProgress();
    current[puzzleId] = progress;
    await puzzlesBox.put('progress', jsonEncode(current));
  }

  Future<void> cachePuzzleProgress(Map<String, double> progress) async {
    await puzzlesBox.put('progress', jsonEncode(progress));
  }

  // Training results methods
  Future<Map<String, dynamic>> getTrainingResults() async {
    try {
      final data = resultsBox.get('results');
      if (data == null) return {};

      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Future<void> saveTrainingResult(Map<String, dynamic> result) async {
    final current = await getTrainingResults();
    final timestamp = DateTime.now().toIso8601String();
    current[timestamp] = result;
    await resultsBox.put('results', jsonEncode(current));
  }

  Future<void> cacheTrainingResults(Map<String, dynamic> results) async {
    await resultsBox.put('results', jsonEncode(results));
  }

  // Utility methods
  Future<void> clearAll() async {
    await Future.wait([
      lessonsBox.clear(),
      drillsBox.clear(),
      puzzlesBox.clear(),
      resultsBox.clear(),
    ]);
  }
}