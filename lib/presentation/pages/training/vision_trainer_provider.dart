// lib/presentation/pages/training/vision_trainer_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Vision Trainer State
class VisionTrainerState {
  final int score;
  final int totalAttempts;
  final int correctAnswers;
  final int currentDifficulty;
  final List<bool> attemptHistory;

  VisionTrainerState({
    this.score = 0,
    this.totalAttempts = 0,
    this.correctAnswers = 0,
    this.currentDifficulty = 1,
    this.attemptHistory = const [],
  });

  VisionTrainerState copyWith({
    int? score,
    int? totalAttempts,
    int? correctAnswers,
    int? currentDifficulty,
    List<bool>? attemptHistory,
  }) {
    return VisionTrainerState(
      score: score ?? this.score,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentDifficulty: currentDifficulty ?? this.currentDifficulty,
      attemptHistory: attemptHistory ?? this.attemptHistory,
    );
  }

  double getAccuracy() {
    if (totalAttempts == 0) return 0.0;
    return correctAnswers / totalAttempts;
  }

  // Get recent performance (last 5 attempts)
  double getRecentAccuracy() {
    if (attemptHistory.isEmpty) return 0.0;
    final recent = attemptHistory.length > 5
        ? attemptHistory.sublist(attemptHistory.length - 5)
        : attemptHistory;
    final correct = recent.where((r) => r).length;
    return correct / recent.length;
  }
}

// Vision Trainer Notifier
class VisionTrainerNotifier extends StateNotifier<VisionTrainerState> {
  VisionTrainerNotifier() : super(VisionTrainerState());

  void recordAttempt({required bool isCorrect}) {
    final newHistory = [...state.attemptHistory, isCorrect];

    state = state.copyWith(
      totalAttempts: state.totalAttempts + 1,
      correctAnswers: isCorrect ? state.correctAnswers + 1 : state.correctAnswers,
      attemptHistory: newHistory,
    );
  }

  void updateScore(int points) {
    state = state.copyWith(
      score: state.score + points,
    );
  }

  void increaseDifficulty() {
    if (state.currentDifficulty < 5) {
      state = state.copyWith(
        currentDifficulty: state.currentDifficulty + 1,
      );
    }
  }

  void decreaseDifficulty() {
    if (state.currentDifficulty > 1) {
      state = state.copyWith(
        currentDifficulty: state.currentDifficulty - 1,
      );
    }
  }

  void setDifficulty(int level) {
    if (level >= 1 && level <= 5) {
      state = state.copyWith(
        currentDifficulty: level,
      );
    }
  }

  void reset() {
    state = VisionTrainerState();
  }

  double getAccuracy() {
    return state.getAccuracy();
  }

  double getRecentAccuracy() {
    return state.getRecentAccuracy();
  }

  // Get performance stats
  Map<String, dynamic> getStats() {
    return {
      'score': state.score,
      'totalAttempts': state.totalAttempts,
      'correctAnswers': state.correctAnswers,
      'accuracy': getAccuracy(),
      'recentAccuracy': getRecentAccuracy(),
      'difficulty': state.currentDifficulty,
    };
  }
}

// Provider
final visionTrainerProvider = StateNotifierProvider<VisionTrainerNotifier, VisionTrainerState>((ref) {
  return VisionTrainerNotifier();
});// TODO Implement this library.