// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) {
  return _UserProgress.fromJson(json);
}

/// @nodoc
mixin _$UserProgress {
  String get userId => throw _privateConstructorUsedError;
  Map<String, double> get lessonProgress => throw _privateConstructorUsedError;
  Map<String, double> get drillProgress => throw _privateConstructorUsedError;
  Map<String, double> get puzzleProgress => throw _privateConstructorUsedError;
  double get overallProgress => throw _privateConstructorUsedError;
  int get totalCompletions => throw _privateConstructorUsedError;
  double get averageAccuracy => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProgressCopyWith<UserProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressCopyWith<$Res> {
  factory $UserProgressCopyWith(
          UserProgress value, $Res Function(UserProgress) then) =
      _$UserProgressCopyWithImpl<$Res, UserProgress>;
  @useResult
  $Res call(
      {String userId,
      Map<String, double> lessonProgress,
      Map<String, double> drillProgress,
      Map<String, double> puzzleProgress,
      double overallProgress,
      int totalCompletions,
      double averageAccuracy,
      DateTime? lastUpdated});
}

/// @nodoc
class _$UserProgressCopyWithImpl<$Res, $Val extends UserProgress>
    implements $UserProgressCopyWith<$Res> {
  _$UserProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? lessonProgress = null,
    Object? drillProgress = null,
    Object? puzzleProgress = null,
    Object? overallProgress = null,
    Object? totalCompletions = null,
    Object? averageAccuracy = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      lessonProgress: null == lessonProgress
          ? _value.lessonProgress
          : lessonProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      drillProgress: null == drillProgress
          ? _value.drillProgress
          : drillProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      puzzleProgress: null == puzzleProgress
          ? _value.puzzleProgress
          : puzzleProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      overallProgress: null == overallProgress
          ? _value.overallProgress
          : overallProgress // ignore: cast_nullable_to_non_nullable
              as double,
      totalCompletions: null == totalCompletions
          ? _value.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProgressImplCopyWith<$Res>
    implements $UserProgressCopyWith<$Res> {
  factory _$$UserProgressImplCopyWith(
          _$UserProgressImpl value, $Res Function(_$UserProgressImpl) then) =
      __$$UserProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      Map<String, double> lessonProgress,
      Map<String, double> drillProgress,
      Map<String, double> puzzleProgress,
      double overallProgress,
      int totalCompletions,
      double averageAccuracy,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$UserProgressImplCopyWithImpl<$Res>
    extends _$UserProgressCopyWithImpl<$Res, _$UserProgressImpl>
    implements _$$UserProgressImplCopyWith<$Res> {
  __$$UserProgressImplCopyWithImpl(
      _$UserProgressImpl _value, $Res Function(_$UserProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? lessonProgress = null,
    Object? drillProgress = null,
    Object? puzzleProgress = null,
    Object? overallProgress = null,
    Object? totalCompletions = null,
    Object? averageAccuracy = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$UserProgressImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      lessonProgress: null == lessonProgress
          ? _value._lessonProgress
          : lessonProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      drillProgress: null == drillProgress
          ? _value._drillProgress
          : drillProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      puzzleProgress: null == puzzleProgress
          ? _value._puzzleProgress
          : puzzleProgress // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      overallProgress: null == overallProgress
          ? _value.overallProgress
          : overallProgress // ignore: cast_nullable_to_non_nullable
              as double,
      totalCompletions: null == totalCompletions
          ? _value.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressImpl implements _UserProgress {
  const _$UserProgressImpl(
      {required this.userId,
      final Map<String, double> lessonProgress = const {},
      final Map<String, double> drillProgress = const {},
      final Map<String, double> puzzleProgress = const {},
      this.overallProgress = 0.0,
      this.totalCompletions = 0,
      this.averageAccuracy = 0.0,
      this.lastUpdated})
      : _lessonProgress = lessonProgress,
        _drillProgress = drillProgress,
        _puzzleProgress = puzzleProgress;

  factory _$UserProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressImplFromJson(json);

  @override
  final String userId;
  final Map<String, double> _lessonProgress;
  @override
  @JsonKey()
  Map<String, double> get lessonProgress {
    if (_lessonProgress is EqualUnmodifiableMapView) return _lessonProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_lessonProgress);
  }

  final Map<String, double> _drillProgress;
  @override
  @JsonKey()
  Map<String, double> get drillProgress {
    if (_drillProgress is EqualUnmodifiableMapView) return _drillProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_drillProgress);
  }

  final Map<String, double> _puzzleProgress;
  @override
  @JsonKey()
  Map<String, double> get puzzleProgress {
    if (_puzzleProgress is EqualUnmodifiableMapView) return _puzzleProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_puzzleProgress);
  }

  @override
  @JsonKey()
  final double overallProgress;
  @override
  @JsonKey()
  final int totalCompletions;
  @override
  @JsonKey()
  final double averageAccuracy;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'UserProgress(userId: $userId, lessonProgress: $lessonProgress, drillProgress: $drillProgress, puzzleProgress: $puzzleProgress, overallProgress: $overallProgress, totalCompletions: $totalCompletions, averageAccuracy: $averageAccuracy, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._lessonProgress, _lessonProgress) &&
            const DeepCollectionEquality()
                .equals(other._drillProgress, _drillProgress) &&
            const DeepCollectionEquality()
                .equals(other._puzzleProgress, _puzzleProgress) &&
            (identical(other.overallProgress, overallProgress) ||
                other.overallProgress == overallProgress) &&
            (identical(other.totalCompletions, totalCompletions) ||
                other.totalCompletions == totalCompletions) &&
            (identical(other.averageAccuracy, averageAccuracy) ||
                other.averageAccuracy == averageAccuracy) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      const DeepCollectionEquality().hash(_lessonProgress),
      const DeepCollectionEquality().hash(_drillProgress),
      const DeepCollectionEquality().hash(_puzzleProgress),
      overallProgress,
      totalCompletions,
      averageAccuracy,
      lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      __$$UserProgressImplCopyWithImpl<_$UserProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressImplToJson(
      this,
    );
  }
}

abstract class _UserProgress implements UserProgress {
  const factory _UserProgress(
      {required final String userId,
      final Map<String, double> lessonProgress,
      final Map<String, double> drillProgress,
      final Map<String, double> puzzleProgress,
      final double overallProgress,
      final int totalCompletions,
      final double averageAccuracy,
      final DateTime? lastUpdated}) = _$UserProgressImpl;

  factory _UserProgress.fromJson(Map<String, dynamic> json) =
      _$UserProgressImpl.fromJson;

  @override
  String get userId;
  @override
  Map<String, double> get lessonProgress;
  @override
  Map<String, double> get drillProgress;
  @override
  Map<String, double> get puzzleProgress;
  @override
  double get overallProgress;
  @override
  int get totalCompletions;
  @override
  double get averageAccuracy;
  @override
  DateTime? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
