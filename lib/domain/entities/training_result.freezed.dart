// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrainingResult _$TrainingResultFromJson(Map<String, dynamic> json) {
  return _TrainingResult.fromJson(json);
}

/// @nodoc
mixin _$TrainingResult {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get itemId =>
      throw _privateConstructorUsedError; // Changed from contentId to match provider
  String get type =>
      throw _privateConstructorUsedError; // Changed from contentType to match provider
  DateTime get completedAt => throw _privateConstructorUsedError;
  int get score =>
      throw _privateConstructorUsedError; // Changed from double to int to match provider
  int get timeSpentSeconds =>
      throw _privateConstructorUsedError; // Changed from duration to match provider
  bool get isSuccess =>
      throw _privateConstructorUsedError; // Changed from isPassed to match provider
  Map<String, Object?>? get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainingResultCopyWith<TrainingResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingResultCopyWith<$Res> {
  factory $TrainingResultCopyWith(
          TrainingResult value, $Res Function(TrainingResult) then) =
      _$TrainingResultCopyWithImpl<$Res, TrainingResult>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String itemId,
      String type,
      DateTime completedAt,
      int score,
      int timeSpentSeconds,
      bool isSuccess,
      Map<String, Object?>? metadata});
}

/// @nodoc
class _$TrainingResultCopyWithImpl<$Res, $Val extends TrainingResult>
    implements $TrainingResultCopyWith<$Res> {
  _$TrainingResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? itemId = null,
    Object? type = null,
    Object? completedAt = null,
    Object? score = null,
    Object? timeSpentSeconds = null,
    Object? isSuccess = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      timeSpentSeconds: null == timeSpentSeconds
          ? _value.timeSpentSeconds
          : timeSpentSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, Object?>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainingResultImplCopyWith<$Res>
    implements $TrainingResultCopyWith<$Res> {
  factory _$$TrainingResultImplCopyWith(_$TrainingResultImpl value,
          $Res Function(_$TrainingResultImpl) then) =
      __$$TrainingResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String itemId,
      String type,
      DateTime completedAt,
      int score,
      int timeSpentSeconds,
      bool isSuccess,
      Map<String, Object?>? metadata});
}

/// @nodoc
class __$$TrainingResultImplCopyWithImpl<$Res>
    extends _$TrainingResultCopyWithImpl<$Res, _$TrainingResultImpl>
    implements _$$TrainingResultImplCopyWith<$Res> {
  __$$TrainingResultImplCopyWithImpl(
      _$TrainingResultImpl _value, $Res Function(_$TrainingResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? itemId = null,
    Object? type = null,
    Object? completedAt = null,
    Object? score = null,
    Object? timeSpentSeconds = null,
    Object? isSuccess = null,
    Object? metadata = freezed,
  }) {
    return _then(_$TrainingResultImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      timeSpentSeconds: null == timeSpentSeconds
          ? _value.timeSpentSeconds
          : timeSpentSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, Object?>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingResultImpl implements _TrainingResult {
  const _$TrainingResultImpl(
      {required this.id,
      required this.userId,
      required this.itemId,
      required this.type,
      required this.completedAt,
      required this.score,
      required this.timeSpentSeconds,
      required this.isSuccess,
      final Map<String, Object?>? metadata})
      : _metadata = metadata;

  factory _$TrainingResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingResultImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String itemId;
// Changed from contentId to match provider
  @override
  final String type;
// Changed from contentType to match provider
  @override
  final DateTime completedAt;
  @override
  final int score;
// Changed from double to int to match provider
  @override
  final int timeSpentSeconds;
// Changed from duration to match provider
  @override
  final bool isSuccess;
// Changed from isPassed to match provider
  final Map<String, Object?>? _metadata;
// Changed from isPassed to match provider
  @override
  Map<String, Object?>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'TrainingResult(id: $id, userId: $userId, itemId: $itemId, type: $type, completedAt: $completedAt, score: $score, timeSpentSeconds: $timeSpentSeconds, isSuccess: $isSuccess, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.timeSpentSeconds, timeSpentSeconds) ||
                other.timeSpentSeconds == timeSpentSeconds) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      itemId,
      type,
      completedAt,
      score,
      timeSpentSeconds,
      isSuccess,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingResultImplCopyWith<_$TrainingResultImpl> get copyWith =>
      __$$TrainingResultImplCopyWithImpl<_$TrainingResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingResultImplToJson(
      this,
    );
  }
}

abstract class _TrainingResult implements TrainingResult {
  const factory _TrainingResult(
      {required final String id,
      required final String userId,
      required final String itemId,
      required final String type,
      required final DateTime completedAt,
      required final int score,
      required final int timeSpentSeconds,
      required final bool isSuccess,
      final Map<String, Object?>? metadata}) = _$TrainingResultImpl;

  factory _TrainingResult.fromJson(Map<String, dynamic> json) =
      _$TrainingResultImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get itemId;
  @override // Changed from contentId to match provider
  String get type;
  @override // Changed from contentType to match provider
  DateTime get completedAt;
  @override
  int get score;
  @override // Changed from double to int to match provider
  int get timeSpentSeconds;
  @override // Changed from duration to match provider
  bool get isSuccess;
  @override // Changed from isPassed to match provider
  Map<String, Object?>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$TrainingResultImplCopyWith<_$TrainingResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
