// lib/data/models/user_progress_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress_model.freezed.dart';
part 'user_progress_model.g.dart';

@freezed
class UserProgressModel with _$UserProgressModel {
  const factory UserProgressModel({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'total_lessons_completed') required int totalLessonsCompleted,
    @JsonKey(name: 'total_puzzles_solved') required int totalPuzzesSolved,
    @JsonKey(name: 'total_drills_completed') required int totalDrillsCompleted,
    @JsonKey(name: 'average_puzzle_rating') required double averagePuzzleRating,
    @JsonKey(name: 'last_activity_at') required String lastActivityAt,
    @JsonKey(name: 'achievement_badges') required List<String> achievementBadges,
  }) = _UserProgressModel;

  factory UserProgressModel.fromJson(Map<String, dynamic> json) =>
      _$UserProgressModelFromJson(json);
}