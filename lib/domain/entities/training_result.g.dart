// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingResultImpl _$$TrainingResultImplFromJson(Map<String, dynamic> json) =>
    _$TrainingResultImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      itemId: json['itemId'] as String,
      type: json['type'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      score: (json['score'] as num).toInt(),
      timeSpentSeconds: (json['timeSpentSeconds'] as num).toInt(),
      isSuccess: json['isSuccess'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$TrainingResultImplToJson(
        _$TrainingResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'itemId': instance.itemId,
      'type': instance.type,
      'completedAt': instance.completedAt.toIso8601String(),
      'score': instance.score,
      'timeSpentSeconds': instance.timeSpentSeconds,
      'isSuccess': instance.isSuccess,
      'metadata': instance.metadata,
    };
