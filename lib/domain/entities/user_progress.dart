// lib/domain/entities/user_progress.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';
part 'user_progress.g.dart';

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required String userId,
    @Default({})
    Map<String, double> lessonProgress,
    @Default({})
    Map<String, double> drillProgress,
    @Default({})
    Map<String, double> puzzleProgress,
    @Default(0.0)
    double overallProgress,
    @Default(0)
    int totalCompletions,
    @Default(0.0)
    double averageAccuracy,
    DateTime? lastUpdated,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);
}