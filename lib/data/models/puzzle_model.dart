// lib/data/models/puzzle_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'puzzle_model.freezed.dart';
part 'puzzle_model.g.dart';

@freezed
class PuzzleModel with _$PuzzleModel {
  const factory PuzzleModel({
    required String id,
    required String fen,
    @JsonKey(name: 'solution_san')
    required List<String> solutionSan,
    required String type,
    required int difficulty,
    required String theme,
    @Default(0.6)
    double rating,
    @Default(0)
    int attempts,
    @Default(false)
    bool isSolved,
    String? hint,
  }) = _PuzzleModel;

  factory PuzzleModel.fromJson(Map<String, dynamic> json) =>
      _$PuzzleModelFromJson(json);
}