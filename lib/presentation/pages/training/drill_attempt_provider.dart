// lib/presentation/pages/training/drill_attempt_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrillAttempt {
  final String drillId;
  final DateTime timestamp;
  final bool isSuccess;
  final int timeSeconds;

  DrillAttempt({
    required this.drillId,
    required this.timestamp,
    required this.isSuccess,
    required this.timeSeconds,
  });
}

class DrillAttemptState {
  final Map<String, List<DrillAttempt>> attemptsByDrill;

  DrillAttemptState({
    this.attemptsByDrill = const {},
  });

  DrillAttemptState copyWith({
    Map<String, List<DrillAttempt>>? attemptsByDrill,
  }) {
    return DrillAttemptState(
      attemptsByDrill: attemptsByDrill ?? this.attemptsByDrill,
    );
  }

  Map<String, dynamic> getStats(String drillId) {
    final attempts = attemptsByDrill[drillId] ?? [];
    final successes = attempts.where((a) => a.isSuccess).length;

    return {
      'attempts': attempts.length,
      'successes': successes,
      'failures': attempts.length - successes,
    };
  }
}

class DrillAttemptNotifier extends StateNotifier<DrillAttemptState> {
  DrillAttemptNotifier() : super(DrillAttemptState());

  void recordAttempt({
    required String drillId,
    required bool isSuccess,
    required int timeSeconds,
  }) {
    final attempt = DrillAttempt(
      drillId: drillId,
      timestamp: DateTime.now(),
      isSuccess: isSuccess,
      timeSeconds: timeSeconds,
    );

    final currentAttempts = state.attemptsByDrill[drillId] ?? [];
    final updatedAttempts = [...currentAttempts, attempt];

    final newMap = Map<String, List<DrillAttempt>>.from(state.attemptsByDrill);
    newMap[drillId] = updatedAttempts;

    state = state.copyWith(attemptsByDrill: newMap);
  }

  double getSuccessRate(String drillId) {
    final attempts = state.attemptsByDrill[drillId] ?? [];
    if (attempts.isEmpty) return 0.0;

    final successes = attempts.where((a) => a.isSuccess).length;
    return successes / attempts.length;
  }

  Map<String, dynamic> getStats(String drillId) {
    return state.getStats(drillId);
  }

  void clearAttempts(String drillId) {
    final newMap = Map<String, List<DrillAttempt>>.from(state.attemptsByDrill);
    newMap.remove(drillId);
    state = state.copyWith(attemptsByDrill: newMap);
  }

  void clearAllAttempts() {
    state = DrillAttemptState();
  }
}

final drillAttemptProvider = StateNotifierProvider<DrillAttemptNotifier, DrillAttemptState>((ref) {
  return DrillAttemptNotifier();
});
