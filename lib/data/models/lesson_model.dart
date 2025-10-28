// lib/data/models/lesson_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_model.freezed.dart';
part 'lesson_model.g.dart';

@freezed
class LessonModel with _$LessonModel {
  const factory LessonModel({
    required String id,
    required String title,
    required String description,
    required String level,
    @JsonKey(name: 'duration_seconds') required int durationSeconds,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    @JsonKey(name: 'video_url') required String videoUrl,
    required List<LessonSlideModel> slides,
    required List<LessonQuizModel> quizzes,
    @Default(0.0) double progress,
    @Default(false) bool isCompleted,
  }) = _LessonModel;

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      _$LessonModelFromJson(json);
}

@freezed
class LessonSlideModel with _$LessonSlideModel {
  const factory LessonSlideModel({
    required String id,
    @JsonKey(name: 'image_url') required String imageUrl,
    required String text,
    String? caption,
  }) = _LessonSlideModel;

  factory LessonSlideModel.fromJson(Map<String, dynamic> json) =>
      _$LessonSlideModelFromJson(json);
}

@freezed
class LessonQuizModel with _$LessonQuizModel {
  const factory LessonQuizModel({
    required String id,
    required String type,
    required String question,
    List<String>? options,
    @JsonKey(name: 'answer_index') int? answerIndex,
    String? fen,
    @JsonKey(name: 'solution_san') List<String>? solutionSan,
    @Default(false) bool isAnswered,
    @Default(false) bool isCorrect,
  }) = _LessonQuizModel;

  factory LessonQuizModel.fromJson(Map<String, dynamic> json) =>
      _$LessonQuizModelFromJson(json);
}