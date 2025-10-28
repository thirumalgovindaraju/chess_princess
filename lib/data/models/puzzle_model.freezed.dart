// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'puzzle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PuzzleModel _$PuzzleModelFromJson(Map<String, dynamic> json) {
  return _PuzzleModel.fromJson(json);
}

/// @nodoc
mixin _$PuzzleModel {
  String get id => throw _privateConstructorUsedError;
  String get fen => throw _privateConstructorUsedError;
  @JsonKey(name: 'solution_san')
  List<String> get solutionSan => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get difficulty => throw _privateConstructorUsedError;
  String get theme => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  bool get isSolved => throw _privateConstructorUsedError;
  String? get hint => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PuzzleModelCopyWith<PuzzleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PuzzleModelCopyWith<$Res> {
  factory $PuzzleModelCopyWith(
          PuzzleModel value, $Res Function(PuzzleModel) then) =
      _$PuzzleModelCopyWithImpl<$Res, PuzzleModel>;
  @useResult
  $Res call(
      {String id,
      String fen,
      @JsonKey(name: 'solution_san') List<String> solutionSan,
      String type,
      int difficulty,
      String theme,
      double rating,
      int attempts,
      bool isSolved,
      String? hint});
}

/// @nodoc
class _$PuzzleModelCopyWithImpl<$Res, $Val extends PuzzleModel>
    implements $PuzzleModelCopyWith<$Res> {
  _$PuzzleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fen = null,
    Object? solutionSan = null,
    Object? type = null,
    Object? difficulty = null,
    Object? theme = null,
    Object? rating = null,
    Object? attempts = null,
    Object? isSolved = null,
    Object? hint = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fen: null == fen
          ? _value.fen
          : fen // ignore: cast_nullable_to_non_nullable
              as String,
      solutionSan: null == solutionSan
          ? _value.solutionSan
          : solutionSan // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as int,
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      attempts: null == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int,
      isSolved: null == isSolved
          ? _value.isSolved
          : isSolved // ignore: cast_nullable_to_non_nullable
              as bool,
      hint: freezed == hint
          ? _value.hint
          : hint // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PuzzleModelImplCopyWith<$Res>
    implements $PuzzleModelCopyWith<$Res> {
  factory _$$PuzzleModelImplCopyWith(
          _$PuzzleModelImpl value, $Res Function(_$PuzzleModelImpl) then) =
      __$$PuzzleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fen,
      @JsonKey(name: 'solution_san') List<String> solutionSan,
      String type,
      int difficulty,
      String theme,
      double rating,
      int attempts,
      bool isSolved,
      String? hint});
}

/// @nodoc
class __$$PuzzleModelImplCopyWithImpl<$Res>
    extends _$PuzzleModelCopyWithImpl<$Res, _$PuzzleModelImpl>
    implements _$$PuzzleModelImplCopyWith<$Res> {
  __$$PuzzleModelImplCopyWithImpl(
      _$PuzzleModelImpl _value, $Res Function(_$PuzzleModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fen = null,
    Object? solutionSan = null,
    Object? type = null,
    Object? difficulty = null,
    Object? theme = null,
    Object? rating = null,
    Object? attempts = null,
    Object? isSolved = null,
    Object? hint = freezed,
  }) {
    return _then(_$PuzzleModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fen: null == fen
          ? _value.fen
          : fen // ignore: cast_nullable_to_non_nullable
              as String,
      solutionSan: null == solutionSan
          ? _value._solutionSan
          : solutionSan // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as int,
      theme: null == theme
          ? _value.theme
          : theme // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      attempts: null == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int,
      isSolved: null == isSolved
          ? _value.isSolved
          : isSolved // ignore: cast_nullable_to_non_nullable
              as bool,
      hint: freezed == hint
          ? _value.hint
          : hint // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PuzzleModelImpl implements _PuzzleModel {
  const _$PuzzleModelImpl(
      {required this.id,
      required this.fen,
      @JsonKey(name: 'solution_san') required final List<String> solutionSan,
      required this.type,
      required this.difficulty,
      required this.theme,
      this.rating = 0.6,
      this.attempts = 0,
      this.isSolved = false,
      this.hint})
      : _solutionSan = solutionSan;

  factory _$PuzzleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PuzzleModelImplFromJson(json);

  @override
  final String id;
  @override
  final String fen;
  final List<String> _solutionSan;
  @override
  @JsonKey(name: 'solution_san')
  List<String> get solutionSan {
    if (_solutionSan is EqualUnmodifiableListView) return _solutionSan;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_solutionSan);
  }

  @override
  final String type;
  @override
  final int difficulty;
  @override
  final String theme;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int attempts;
  @override
  @JsonKey()
  final bool isSolved;
  @override
  final String? hint;

  @override
  String toString() {
    return 'PuzzleModel(id: $id, fen: $fen, solutionSan: $solutionSan, type: $type, difficulty: $difficulty, theme: $theme, rating: $rating, attempts: $attempts, isSolved: $isSolved, hint: $hint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PuzzleModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fen, fen) || other.fen == fen) &&
            const DeepCollectionEquality()
                .equals(other._solutionSan, _solutionSan) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.theme, theme) || other.theme == theme) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.isSolved, isSolved) ||
                other.isSolved == isSolved) &&
            (identical(other.hint, hint) || other.hint == hint));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fen,
      const DeepCollectionEquality().hash(_solutionSan),
      type,
      difficulty,
      theme,
      rating,
      attempts,
      isSolved,
      hint);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PuzzleModelImplCopyWith<_$PuzzleModelImpl> get copyWith =>
      __$$PuzzleModelImplCopyWithImpl<_$PuzzleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PuzzleModelImplToJson(
      this,
    );
  }
}

abstract class _PuzzleModel implements PuzzleModel {
  const factory _PuzzleModel(
      {required final String id,
      required final String fen,
      @JsonKey(name: 'solution_san') required final List<String> solutionSan,
      required final String type,
      required final int difficulty,
      required final String theme,
      final double rating,
      final int attempts,
      final bool isSolved,
      final String? hint}) = _$PuzzleModelImpl;

  factory _PuzzleModel.fromJson(Map<String, dynamic> json) =
      _$PuzzleModelImpl.fromJson;

  @override
  String get id;
  @override
  String get fen;
  @override
  @JsonKey(name: 'solution_san')
  List<String> get solutionSan;
  @override
  String get type;
  @override
  int get difficulty;
  @override
  String get theme;
  @override
  double get rating;
  @override
  int get attempts;
  @override
  bool get isSolved;
  @override
  String? get hint;
  @override
  @JsonKey(ignore: true)
  _$$PuzzleModelImplCopyWith<_$PuzzleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
