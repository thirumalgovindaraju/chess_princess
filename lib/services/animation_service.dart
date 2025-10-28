import 'package:flutter/material.dart';

enum AnimationSpeed { slow, normal, fast, instant }

class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  AnimationSpeed _speed = AnimationSpeed.normal;
  bool _animationsEnabled = true;

  AnimationSpeed get speed => _speed;
  bool get enabled => _animationsEnabled;

  void setSpeed(AnimationSpeed speed) {
    _speed = speed;
  }

  void setEnabled(bool enabled) {
    _animationsEnabled = enabled;
  }

  Duration get moveDuration {
    if (!_animationsEnabled) return Duration.zero;
    switch (_speed) {
      case AnimationSpeed.slow:
        return const Duration(milliseconds: 500);
      case AnimationSpeed.normal:
        return const Duration(milliseconds: 300);
      case AnimationSpeed.fast:
        return const Duration(milliseconds: 150);
      case AnimationSpeed.instant:
        return Duration.zero;
    }
  }

  Duration get captureDuration {
    if (!_animationsEnabled) return Duration.zero;
    switch (_speed) {
      case AnimationSpeed.slow:
        return const Duration(milliseconds: 400);
      case AnimationSpeed.normal:
        return const Duration(milliseconds: 250);
      case AnimationSpeed.fast:
        return const Duration(milliseconds: 120);
      case AnimationSpeed.instant:
        return Duration.zero;
    }
  }

  Duration get highlightDuration {
    if (!_animationsEnabled) return Duration.zero;
    return const Duration(milliseconds: 200);
  }
}