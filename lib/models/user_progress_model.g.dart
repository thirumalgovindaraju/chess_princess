// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProgressModelImpl _$$UserProgressModelImplFromJson(
        Map<String, dynamic> json) =>
    _$UserProgressModelImpl(
      userId: json['user_id'] as String,
      totalLessonsCompleted: (json['total_lessons_completed'] as num).toInt(),
      totalPuzzesSolved: (json['total_puzzles_solved'] as num).toInt(),
      totalDrillsCompleted: (json['total_drills_completed'] as num).toInt(),
      averagePuzzleRating: (json['average_puzzle_rating'] as num).toDouble(),
      lastActivityAt: json['last_activity_at'] as String,
      achievementBadges: (json['achievement_badges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$UserProgressModelImplToJson(
        _$UserProgressModelImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'total_lessons_completed': instance.totalLessonsCompleted,
      'total_puzzles_solved': instance.totalPuzzesSolved,
      'total_drills_completed': instance.totalDrillsCompleted,
      'average_puzzle_rating': instance.averagePuzzleRating,
      'last_activity_at': instance.lastActivityAt,
      'achievement_badges': instance.achievementBadges,
    };
