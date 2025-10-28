import 'package:freezed_annotation/freezed_annotation.dart';

part 'drill_model.freezed.dart';
part 'drill_model.g.dart';

@freezed
class DrillModel with _$DrillModel {
  const factory DrillModel({
    required String id,
    required String name,
    required String type,
    required String difficulty,
    required String fen,
    @JsonKey(name: 'solution_moves') required List<String> solutionMoves,
    required List<String> hints,
    String? description,
    @Default(0) int attempts,
    @Default(0) int successes,
  }) = _DrillModel;

  factory DrillModel.fromJson(Map<String, dynamic> json) =>
      _$DrillModelFromJson(json);
}
