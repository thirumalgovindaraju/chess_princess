// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DrillModelImpl _$$DrillModelImplFromJson(Map<String, dynamic> json) =>
    _$DrillModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      difficulty: json['difficulty'] as String,
      fen: json['fen'] as String,
      solutionMoves: (json['solution_moves'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      hints: (json['hints'] as List<dynamic>).map((e) => e as String).toList(),
      description: json['description'] as String?,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      successes: (json['successes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$DrillModelImplToJson(_$DrillModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'difficulty': instance.difficulty,
      'fen': instance.fen,
      'solution_moves': instance.solutionMoves,
      'hints': instance.hints,
      'description': instance.description,
      'attempts': instance.attempts,
      'successes': instance.successes,
    };
