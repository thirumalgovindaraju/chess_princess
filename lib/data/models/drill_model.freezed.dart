// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drill_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DrillModel _$DrillModelFromJson(Map<String, dynamic> json) {
  return _DrillModel.fromJson(json);
}

/// @nodoc
mixin _$DrillModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  String get fen => throw _privateConstructorUsedError;
  @JsonKey(name: 'solution_moves')
  List<String> get solutionMoves => throw _privateConstructorUsedError;
  List<String> get hints => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get attempts => throw _privateConstructorUsedError;
  int get successes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DrillModelCopyWith<DrillModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DrillModelCopyWith<$Res> {
  factory $DrillModelCopyWith(
          DrillModel value, $Res Function(DrillModel) then) =
      _$DrillModelCopyWithImpl<$Res, DrillModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      String difficulty,
      String fen,
      @JsonKey(name: 'solution_moves') List<String> solutionMoves,
      List<String> hints,
      String? description,
      int attempts,
      int successes});
}

/// @nodoc
class _$DrillModelCopyWithImpl<$Res, $Val extends DrillModel>
    implements $DrillModelCopyWith<$Res> {
  _$DrillModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? difficulty = null,
    Object? fen = null,
    Object? solutionMoves = null,
    Object? hints = null,
    Object? description = freezed,
    Object? attempts = null,
    Object? successes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      fen: null == fen
          ? _value.fen
          : fen // ignore: cast_nullable_to_non_nullable
              as String,
      solutionMoves: null == solutionMoves
          ? _value.solutionMoves
          : solutionMoves // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hints: null == hints
          ? _value.hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      attempts: null == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int,
      successes: null == successes
          ? _value.successes
          : successes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DrillModelImplCopyWith<$Res>
    implements $DrillModelCopyWith<$Res> {
  factory _$$DrillModelImplCopyWith(
          _$DrillModelImpl value, $Res Function(_$DrillModelImpl) then) =
      __$$DrillModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      String difficulty,
      String fen,
      @JsonKey(name: 'solution_moves') List<String> solutionMoves,
      List<String> hints,
      String? description,
      int attempts,
      int successes});
}

/// @nodoc
class __$$DrillModelImplCopyWithImpl<$Res>
    extends _$DrillModelCopyWithImpl<$Res, _$DrillModelImpl>
    implements _$$DrillModelImplCopyWith<$Res> {
  __$$DrillModelImplCopyWithImpl(
      _$DrillModelImpl _value, $Res Function(_$DrillModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? difficulty = null,
    Object? fen = null,
    Object? solutionMoves = null,
    Object? hints = null,
    Object? description = freezed,
    Object? attempts = null,
    Object? successes = null,
  }) {
    return _then(_$DrillModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      fen: null == fen
          ? _value.fen
          : fen // ignore: cast_nullable_to_non_nullable
              as String,
      solutionMoves: null == solutionMoves
          ? _value._solutionMoves
          : solutionMoves // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hints: null == hints
          ? _value._hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<String>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      attempts: null == attempts
          ? _value.attempts
          : attempts // ignore: cast_nullable_to_non_nullable
              as int,
      successes: null == successes
          ? _value.successes
          : successes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DrillModelImpl implements _DrillModel {
  const _$DrillModelImpl(
      {required this.id,
      required this.name,
      required this.type,
      required this.difficulty,
      required this.fen,
      @JsonKey(name: 'solution_moves')
      required final List<String> solutionMoves,
      required final List<String> hints,
      this.description,
      this.attempts = 0,
      this.successes = 0})
      : _solutionMoves = solutionMoves,
        _hints = hints;

  factory _$DrillModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DrillModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  @override
  final String difficulty;
  @override
  final String fen;
  final List<String> _solutionMoves;
  @override
  @JsonKey(name: 'solution_moves')
  List<String> get solutionMoves {
    if (_solutionMoves is EqualUnmodifiableListView) return _solutionMoves;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_solutionMoves);
  }

  final List<String> _hints;
  @override
  List<String> get hints {
    if (_hints is EqualUnmodifiableListView) return _hints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hints);
  }

  @override
  final String? description;
  @override
  @JsonKey()
  final int attempts;
  @override
  @JsonKey()
  final int successes;

  @override
  String toString() {
    return 'DrillModel(id: $id, name: $name, type: $type, difficulty: $difficulty, fen: $fen, solutionMoves: $solutionMoves, hints: $hints, description: $description, attempts: $attempts, successes: $successes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DrillModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.fen, fen) || other.fen == fen) &&
            const DeepCollectionEquality()
                .equals(other._solutionMoves, _solutionMoves) &&
            const DeepCollectionEquality().equals(other._hints, _hints) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.attempts, attempts) ||
                other.attempts == attempts) &&
            (identical(other.successes, successes) ||
                other.successes == successes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      type,
      difficulty,
      fen,
      const DeepCollectionEquality().hash(_solutionMoves),
      const DeepCollectionEquality().hash(_hints),
      description,
      attempts,
      successes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DrillModelImplCopyWith<_$DrillModelImpl> get copyWith =>
      __$$DrillModelImplCopyWithImpl<_$DrillModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DrillModelImplToJson(
      this,
    );
  }
}

abstract class _DrillModel implements DrillModel {
  const factory _DrillModel(
      {required final String id,
      required final String name,
      required final String type,
      required final String difficulty,
      required final String fen,
      @JsonKey(name: 'solution_moves')
      required final List<String> solutionMoves,
      required final List<String> hints,
      final String? description,
      final int attempts,
      final int successes}) = _$DrillModelImpl;

  factory _DrillModel.fromJson(Map<String, dynamic> json) =
      _$DrillModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  String get difficulty;
  @override
  String get fen;
  @override
  @JsonKey(name: 'solution_moves')
  List<String> get solutionMoves;
  @override
  List<String> get hints;
  @override
  String? get description;
  @override
  int get attempts;
  @override
  int get successes;
  @override
  @JsonKey(ignore: true)
  _$$DrillModelImplCopyWith<_$DrillModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
