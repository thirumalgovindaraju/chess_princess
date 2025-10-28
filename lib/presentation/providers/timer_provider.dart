// lib/presentation/providers/timer_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Timer state provider
final timerProvider = StateNotifierProvider<TimerNotifier, int>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<int> {
  TimerNotifier() : super(0);

  Timer? _timer;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state++;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  void resumeTimer() {
    if (_isRunning) return;
    startTimer();
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    state = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}