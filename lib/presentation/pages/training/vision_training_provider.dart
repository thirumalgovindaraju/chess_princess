// lib/presentation/pages/training/vision_training_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisionTrainingStats {
  final Map<String, ModeStats> modeStats;
  final int totalXP;
  final int overallLevel;
  final Set<String> unlockedAchievements;

  VisionTrainingStats({
    required this.modeStats,
    this.totalXP = 0,
    this.overallLevel = 1,
    Set<String>? unlockedAchievements,
  }) : unlockedAchievements = unlockedAchievements ?? {};

  VisionTrainingStats copyWith({
    Map<String, ModeStats>? modeStats,
    int? totalXP,
    int? overallLevel,
    Set<String>? unlockedAchievements,
  }) {
    return VisionTrainingStats(
      modeStats: modeStats ?? this.modeStats,
      totalXP: totalXP ?? this.totalXP,
      overallLevel: overallLevel ?? this.overallLevel,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modeStats': modeStats.map((key, value) => MapEntry(key, value.toJson())),
      'totalXP': totalXP,
      'overallLevel': overallLevel,
      'unlockedAchievements': unlockedAchievements.toList(),
    };
  }

  factory VisionTrainingStats.fromJson(Map<String, dynamic> json) {
    return VisionTrainingStats(
      modeStats: (json['modeStats'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, ModeStats.fromJson(value)),
      ),
      totalXP: json['totalXP'] ?? 0,
      overallLevel: json['overallLevel'] ?? 1,
      unlockedAchievements: Set<String>.from(json['unlockedAchievements'] ?? []),
    );
  }
}

class ModeStats {
  final int played;
  final int correct;
  final int bestScore;
  final int bestStreak;
  final DateTime? lastPlayed;

  ModeStats({
    this.played = 0,
    this.correct = 0,
    this.bestScore = 0,
    this.bestStreak = 0,
    this.lastPlayed,
  });

  double get accuracy => played > 0 ? correct / played : 0.0;

  ModeStats copyWith({
    int? played,
    int? correct,
    int? bestScore,
    int? bestStreak,
    DateTime? lastPlayed,
  }) {
    return ModeStats(
      played: played ?? this.played,
      correct: correct ?? this.correct,
      bestScore: bestScore ?? this.bestScore,
      bestStreak: bestStreak ?? this.bestStreak,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'played': played,
      'correct': correct,
      'bestScore': bestScore,
      'bestStreak': bestStreak,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }

  factory ModeStats.fromJson(Map<String, dynamic> json) {
    return ModeStats(
      played: json['played'] ?? 0,
      correct: json['correct'] ?? 0,
      bestScore: json['bestScore'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'])
          : null,
    );
  }
}

class VisionTrainingNotifier extends StateNotifier<VisionTrainingStats> {
  VisionTrainingNotifier() : super(
    VisionTrainingStats(
      modeStats: {
        'positionMemory': ModeStats(),
        'coordinateTraining': ModeStats(),
        'patternRecognition': ModeStats(),
        'moveVisualization': ModeStats(),
        'blindfoldGame': ModeStats(),
        'knightTour': ModeStats(),
        'checkDetection': ModeStats(),
      },
    ),
  ) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('vision_training_stats');
      if (jsonString != null) {
        // Parse and load stats
        // state = VisionTrainingStats.fromJson(json.decode(jsonString));
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('vision_training_stats', json.encode(state.toJson()));
    } catch (e) {
      print('Error saving stats: $e');
    }
  }

  void recordAttempt({
    required String mode,
    required bool isCorrect,
    int score = 0,
    int streak = 0,
  }) {
    final currentStats = state.modeStats[mode] ?? ModeStats();
    final newStats = currentStats.copyWith(
      played: currentStats.played + 1,
      correct: isCorrect ? currentStats.correct + 1 : currentStats.correct,
      bestScore: score > currentStats.bestScore ? score : currentStats.bestScore,
      bestStreak: streak > currentStats.bestStreak ? streak : currentStats.bestStreak,
      lastPlayed: DateTime.now(),
    );

    final newModeStats = Map<String, ModeStats>.from(state.modeStats);
    newModeStats[mode] = newStats;

    final xpGain = isCorrect ? 20 : 5;
    final newXP = state.totalXP + xpGain;
    final newLevel = (newXP / 100).floor() + 1;

    state = state.copyWith(
      modeStats: newModeStats,
      totalXP: newXP,
      overallLevel: newLevel,
    );

    _checkAchievements(mode, newStats, streak);
    _saveStats();
  }

  void _checkAchievements(String mode, ModeStats stats, int currentStreak) {
    final achievements = <String>{};

    // First win
    if (stats.correct == 1) {
      achievements.add('firstWin');
    }

    // Streak achievements
    if (currentStreak >= 5) {
      achievements.add('streak5');
    }
    if (currentStreak >= 10) {
      achievements.add('streak10');
    }

    // Perfect game
    if (stats.played > 0 && stats.accuracy == 1.0 && stats.played >= 5) {
      achievements.add('perfectGame');
    }

    // Marathon
    if (stats.played >= 100) {
      achievements.add('marathon');
    }

    // Level achievements
    if (state.overallLevel >= 10) {
      achievements.add('master');
    }
    if (state.overallLevel >= 25) {
      achievements.add('grandmaster');
    }

    if (achievements.isNotEmpty) {
      final newAchievements = Set<String>.from(state.unlockedAchievements)
        ..addAll(achievements);

      state = state.copyWith(unlockedAchievements: newAchievements);
      _saveStats();
    }
  }

  Map<String, dynamic> getOverallStats() {
    int totalPlayed = 0;
    int totalCorrect = 0;
    int totalBestScore = 0;

    for (var stats in state.modeStats.values) {
      totalPlayed += stats.played;
      totalCorrect += stats.correct;
      totalBestScore += stats.bestScore;
    }

    return {
      'totalPlayed': totalPlayed,
      'totalCorrect': totalCorrect,
      'overallAccuracy': totalPlayed > 0 ? totalCorrect / totalPlayed : 0.0,
      'totalBestScore': totalBestScore,
      'totalXP': state.totalXP,
      'level': state.overallLevel,
    };
  }

  void reset() {
    state = VisionTrainingStats(
      modeStats: {
        'positionMemory': ModeStats(),
        'coordinateTraining': ModeStats(),
        'patternRecognition': ModeStats(),
        'moveVisualization': ModeStats(),
        'blindfoldGame': ModeStats(),
        'knightTour': ModeStats(),
        'checkDetection': ModeStats(),
      },
    );
    _saveStats();
  }
}

final visionTrainingStatsProvider =
StateNotifierProvider<VisionTrainingNotifier, VisionTrainingStats>((ref) {
  return VisionTrainingNotifier();
});
