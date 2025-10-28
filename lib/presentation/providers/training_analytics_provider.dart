// lib/presentation/providers/training_analytics_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_princess/domain/entities/training_result.dart';

// Training analytics provider
final trainingAnalyticsProvider = StateNotifierProvider<TrainingAnalyticsNotifier, TrainingAnalyticsState>((ref) {
  return TrainingAnalyticsNotifier();
});

class TrainingAnalyticsState {
  final List<TrainingResult> results;
  final Map<String, int> itemAttempts;
  final Map<String, int> itemSuccesses;
  final int totalTime;
  final int totalScore;

  TrainingAnalyticsState({
    this.results = const [],
    this.itemAttempts = const {},
    this.itemSuccesses = const {},
    this.totalTime = 0,
    this.totalScore = 0,
  });

  TrainingAnalyticsState copyWith({
    List<TrainingResult>? results,
    Map<String, int>? itemAttempts,
    Map<String, int>? itemSuccesses,
    int? totalTime,
    int? totalScore,
  }) {
    return TrainingAnalyticsState(
      results: results ?? this.results,
      itemAttempts: itemAttempts ?? this.itemAttempts,
      itemSuccesses: itemSuccesses ?? this.itemSuccesses,
      totalTime: totalTime ?? this.totalTime,
      totalScore: totalScore ?? this.totalScore,
    );
  }

  // Calculate success rate
  double getSuccessRate() {
    final totalAttempts = itemAttempts.values.fold(0, (sum, val) => sum + val);
    final totalSuccesses = itemSuccesses.values.fold(0, (sum, val) => sum + val);
    return totalAttempts > 0 ? (totalSuccesses / totalAttempts) * 100 : 0;
  }

  // Get average time per result
  double getAverageTime() {
    return results.isNotEmpty ? totalTime / results.length : 0;
  }

  // Get average score
  double getAverageScore() {
    return results.isNotEmpty ? totalScore / results.length : 0;
  }

  // Get results by type
  List<TrainingResult> getResultsByType(String type) {
    return results.where((r) => r.type == type).toList();
  }

  // Get recent results
  List<TrainingResult> getRecentResults(int limit) {
    final sorted = List<TrainingResult>.from(results)
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sorted.take(limit).toList();
  }

  // Get stats for specific item
  Map<String, dynamic> getItemStats(String itemId) {
    return {
      'attempts': itemAttempts[itemId] ?? 0,
      'successes': itemSuccesses[itemId] ?? 0,
      'successRate': (itemAttempts[itemId] ?? 0) > 0
          ? ((itemSuccesses[itemId] ?? 0) / itemAttempts[itemId]!) * 100
          : 0,
    };
  }
}

class TrainingAnalyticsNotifier extends StateNotifier<TrainingAnalyticsState> {
  TrainingAnalyticsNotifier() : super(TrainingAnalyticsState());

  Future<void> recordResult(TrainingResult result) async {
    final newResults = [...state.results, result];
    final newAttempts = Map<String, int>.from(state.itemAttempts);
    final newSuccesses = Map<String, int>.from(state.itemSuccesses);

    // Update attempts
    newAttempts[result.itemId] = (newAttempts[result.itemId] ?? 0) + 1;

    // Update successes if successful
    if (result.isSuccess) {
      newSuccesses[result.itemId] = (newSuccesses[result.itemId] ?? 0) + 1;
    }

    state = state.copyWith(
      results: newResults,
      itemAttempts: newAttempts,
      itemSuccesses: newSuccesses,
      totalTime: state.totalTime + result.timeSpentSeconds,
      totalScore: state.totalScore + result.score,
    );

    // TODO: Persist to database or storage
    await _persistData();
  }

  Future<void> clearResults() async {
    state = TrainingAnalyticsState();
    await _persistData();
  }

  Future<void> deleteResult(String resultId) async {
    final result = state.results.firstWhere((r) => r.id == resultId);
    final newResults = state.results.where((r) => r.id != resultId).toList();

    // Recalculate stats
    final newAttempts = Map<String, int>.from(state.itemAttempts);
    final newSuccesses = Map<String, int>.from(state.itemSuccesses);

    newAttempts[result.itemId] = (newAttempts[result.itemId] ?? 1) - 1;
    if (result.isSuccess) {
      newSuccesses[result.itemId] = (newSuccesses[result.itemId] ?? 1) - 1;
    }

    state = state.copyWith(
      results: newResults,
      itemAttempts: newAttempts,
      itemSuccesses: newSuccesses,
      totalTime: state.totalTime - result.timeSpentSeconds,
      totalScore: state.totalScore - result.score,
    );

    await _persistData();
  }

  Future<void> loadResults() async {
    // TODO: Load from database or storage
    // For now, just keeping in-memory state
  }

  Future<void> _persistData() async {
    // TODO: Save to SharedPreferences, SQLite, or other storage
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('training_results', jsonEncode(state.results));
  }

  // Get performance trend (last N results)
  List<double> getPerformanceTrend(int limit) {
    final recent = state.getRecentResults(limit);
    return recent.map((r) => r.score.toDouble()).toList().reversed.toList();
  }

  // Get time spent by type
  Map<String, int> getTimeByType() {
    final timeByType = <String, int>{};
    for (final result in state.results) {
      timeByType[result.type] = (timeByType[result.type] ?? 0) + result.timeSpentSeconds;
    }
    return timeByType;
  }

  // Get success rate by type
  Map<String, double> getSuccessRateByType() {
    final rateByType = <String, double>{};
    final typeGroups = <String, List<TrainingResult>>{};

    for (final result in state.results) {
      typeGroups[result.type] = [...(typeGroups[result.type] ?? []), result];
    }

    for (final entry in typeGroups.entries) {
      final successCount = entry.value.where((r) => r.isSuccess).length;
      rateByType[entry.key] = (successCount / entry.value.length) * 100;
    }

    return rateByType;
  }
}