// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PuzzleModelImpl _$$PuzzleModelImplFromJson(Map<String, dynamic> json) =>
    _$PuzzleModelImpl(
      id: json['id'] as String,
      fen: json['fen'] as String,
      solutionSan: (json['solution_san'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      type: json['type'] as String,
      difficulty: (json['difficulty'] as num).toInt(),
      theme: json['theme'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.6,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      isSolved: json['isSolved'] as bool? ?? false,
      hint: json['hint'] as String?,
    );

Map<String, dynamic> _$$PuzzleModelImplToJson(_$PuzzleModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fen': instance.fen,
      'solution_san': instance.solutionSan,
      'type': instance.type,
      'difficulty': instance.difficulty,
      'theme': instance.theme,
      'rating': instance.rating,
      'attempts': instance.attempts,
      'isSolved': instance.isSolved,
      'hint': instance.hint,
    };
