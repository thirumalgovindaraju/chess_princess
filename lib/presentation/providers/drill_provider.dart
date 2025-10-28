// lib/presentation/providers/drill_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Provider for drill attempts/stats
final drillAttemptProvider = StateNotifierProvider<DrillAttemptNotifier, Map<String, Map<String, int>>>((ref) {
  return DrillAttemptNotifier();
});

class DrillAttemptNotifier extends StateNotifier<Map<String, Map<String, int>>> {
  DrillAttemptNotifier() : super({});

  Future<void> recordAttempt(String drillId, bool isSuccess) async {
    final attempts = Map<String, Map<String, int>>.from(state);

    if (!attempts.containsKey(drillId)) {
      attempts[drillId] = {'total': 0, 'success': 0};
    }

    attempts[drillId]!['total'] = (attempts[drillId]!['total'] ?? 0) + 1;

    if (isSuccess) {
      attempts[drillId]!['success'] = (attempts[drillId]!['success'] ?? 0) + 1;
    }

    state = attempts;

    // TODO: Persist to storage
  }
}