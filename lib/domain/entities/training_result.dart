// lib/domain/entities/training_result.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'training_result.freezed.dart';
part 'training_result.g.dart';

@freezed
class TrainingResult with _$TrainingResult {
  const factory TrainingResult({
    required String id,
    required String userId,
    required String itemId,  // Changed from contentId to match provider
    required String type,  // Changed from contentType to match provider
    required DateTime completedAt,
    required int score,  // Changed from double to int to match provider
    required int timeSpentSeconds,  // Changed from duration to match provider
    required bool isSuccess,  // Changed from isPassed to match provider
    Map<String, Object?>? metadata,
  }) = _TrainingResult;

  factory TrainingResult.fromJson(Map<String, dynamic> json) =>
      _$TrainingResultFromJson(json);
}