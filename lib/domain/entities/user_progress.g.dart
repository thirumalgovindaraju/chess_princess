// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProgressImpl _$$UserProgressImplFromJson(Map<String, dynamic> json) =>
    _$UserProgressImpl(
      userId: json['userId'] as String,
      lessonProgress: (json['lessonProgress'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      drillProgress: (json['drillProgress'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      puzzleProgress: (json['puzzleProgress'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      overallProgress: (json['overallProgress'] as num?)?.toDouble() ?? 0.0,
      totalCompletions: (json['totalCompletions'] as num?)?.toInt() ?? 0,
      averageAccuracy: (json['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$UserProgressImplToJson(_$UserProgressImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'lessonProgress': instance.lessonProgress,
      'drillProgress': instance.drillProgress,
      'puzzleProgress': instance.puzzleProgress,
      'overallProgress': instance.overallProgress,
      'totalCompletions': instance.totalCompletions,
      'averageAccuracy': instance.averageAccuracy,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
