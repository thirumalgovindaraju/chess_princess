// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_progress_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProgressModel _$UserProgressModelFromJson(Map<String, dynamic> json) {
  return _UserProgressModel.fromJson(json);
}

/// @nodoc
mixin _$UserProgressModel {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_lessons_completed')
  int get totalLessonsCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_puzzles_solved')
  int get totalPuzzesSolved => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_drills_completed')
  int get totalDrillsCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_puzzle_rating')
  double get averagePuzzleRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_activity_at')
  String get lastActivityAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'achievement_badges')
  List<String> get achievementBadges => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProgressModelCopyWith<UserProgressModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressModelCopyWith<$Res> {
  factory $UserProgressModelCopyWith(
          UserProgressModel value, $Res Function(UserProgressModel) then) =
      _$UserProgressModelCopyWithImpl<$Res, UserProgressModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'total_lessons_completed') int totalLessonsCompleted,
      @JsonKey(name: 'total_puzzles_solved') int totalPuzzesSolved,
      @JsonKey(name: 'total_drills_completed') int totalDrillsCompleted,
      @JsonKey(name: 'average_puzzle_rating') double averagePuzzleRating,
      @JsonKey(name: 'last_activity_at') String lastActivityAt,
      @JsonKey(name: 'achievement_badges') List<String> achievementBadges});
}

/// @nodoc
class _$UserProgressModelCopyWithImpl<$Res, $Val extends UserProgressModel>
    implements $UserProgressModelCopyWith<$Res> {
  _$UserProgressModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalLessonsCompleted = null,
    Object? totalPuzzesSolved = null,
    Object? totalDrillsCompleted = null,
    Object? averagePuzzleRating = null,
    Object? lastActivityAt = null,
    Object? achievementBadges = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalLessonsCompleted: null == totalLessonsCompleted
          ? _value.totalLessonsCompleted
          : totalLessonsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      totalPuzzesSolved: null == totalPuzzesSolved
          ? _value.totalPuzzesSolved
          : totalPuzzesSolved // ignore: cast_nullable_to_non_nullable
              as int,
      totalDrillsCompleted: null == totalDrillsCompleted
          ? _value.totalDrillsCompleted
          : totalDrillsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      averagePuzzleRating: null == averagePuzzleRating
          ? _value.averagePuzzleRating
          : averagePuzzleRating // ignore: cast_nullable_to_non_nullable
              as double,
      lastActivityAt: null == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as String,
      achievementBadges: null == achievementBadges
          ? _value.achievementBadges
          : achievementBadges // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProgressModelImplCopyWith<$Res>
    implements $UserProgressModelCopyWith<$Res> {
  factory _$$UserProgressModelImplCopyWith(_$UserProgressModelImpl value,
          $Res Function(_$UserProgressModelImpl) then) =
      __$$UserProgressModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'total_lessons_completed') int totalLessonsCompleted,
      @JsonKey(name: 'total_puzzles_solved') int totalPuzzesSolved,
      @JsonKey(name: 'total_drills_completed') int totalDrillsCompleted,
      @JsonKey(name: 'average_puzzle_rating') double averagePuzzleRating,
      @JsonKey(name: 'last_activity_at') String lastActivityAt,
      @JsonKey(name: 'achievement_badges') List<String> achievementBadges});
}

/// @nodoc
class __$$UserProgressModelImplCopyWithImpl<$Res>
    extends _$UserProgressModelCopyWithImpl<$Res, _$UserProgressModelImpl>
    implements _$$UserProgressModelImplCopyWith<$Res> {
  __$$UserProgressModelImplCopyWithImpl(_$UserProgressModelImpl _value,
      $Res Function(_$UserProgressModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? totalLessonsCompleted = null,
    Object? totalPuzzesSolved = null,
    Object? totalDrillsCompleted = null,
    Object? averagePuzzleRating = null,
    Object? lastActivityAt = null,
    Object? achievementBadges = null,
  }) {
    return _then(_$UserProgressModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalLessonsCompleted: null == totalLessonsCompleted
          ? _value.totalLessonsCompleted
          : totalLessonsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      totalPuzzesSolved: null == totalPuzzesSolved
          ? _value.totalPuzzesSolved
          : totalPuzzesSolved // ignore: cast_nullable_to_non_nullable
              as int,
      totalDrillsCompleted: null == totalDrillsCompleted
          ? _value.totalDrillsCompleted
          : totalDrillsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      averagePuzzleRating: null == averagePuzzleRating
          ? _value.averagePuzzleRating
          : averagePuzzleRating // ignore: cast_nullable_to_non_nullable
              as double,
      lastActivityAt: null == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as String,
      achievementBadges: null == achievementBadges
          ? _value._achievementBadges
          : achievementBadges // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressModelImpl implements _UserProgressModel {
  const _$UserProgressModelImpl(
      {@JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'total_lessons_completed')
      required this.totalLessonsCompleted,
      @JsonKey(name: 'total_puzzles_solved') required this.totalPuzzesSolved,
      @JsonKey(name: 'total_drills_completed')
      required this.totalDrillsCompleted,
      @JsonKey(name: 'average_puzzle_rating') required this.averagePuzzleRating,
      @JsonKey(name: 'last_activity_at') required this.lastActivityAt,
      @JsonKey(name: 'achievement_badges')
      required final List<String> achievementBadges})
      : _achievementBadges = achievementBadges;

  factory _$UserProgressModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressModelImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'total_lessons_completed')
  final int totalLessonsCompleted;
  @override
  @JsonKey(name: 'total_puzzles_solved')
  final int totalPuzzesSolved;
  @override
  @JsonKey(name: 'total_drills_completed')
  final int totalDrillsCompleted;
  @override
  @JsonKey(name: 'average_puzzle_rating')
  final double averagePuzzleRating;
  @override
  @JsonKey(name: 'last_activity_at')
  final String lastActivityAt;
  final List<String> _achievementBadges;
  @override
  @JsonKey(name: 'achievement_badges')
  List<String> get achievementBadges {
    if (_achievementBadges is EqualUnmodifiableListView)
      return _achievementBadges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievementBadges);
  }

  @override
  String toString() {
    return 'UserProgressModel(userId: $userId, totalLessonsCompleted: $totalLessonsCompleted, totalPuzzesSolved: $totalPuzzesSolved, totalDrillsCompleted: $totalDrillsCompleted, averagePuzzleRating: $averagePuzzleRating, lastActivityAt: $lastActivityAt, achievementBadges: $achievementBadges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalLessonsCompleted, totalLessonsCompleted) ||
                other.totalLessonsCompleted == totalLessonsCompleted) &&
            (identical(other.totalPuzzesSolved, totalPuzzesSolved) ||
                other.totalPuzzesSolved == totalPuzzesSolved) &&
            (identical(other.totalDrillsCompleted, totalDrillsCompleted) ||
                other.totalDrillsCompleted == totalDrillsCompleted) &&
            (identical(other.averagePuzzleRating, averagePuzzleRating) ||
                other.averagePuzzleRating == averagePuzzleRating) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt) &&
            const DeepCollectionEquality()
                .equals(other._achievementBadges, _achievementBadges));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      totalLessonsCompleted,
      totalPuzzesSolved,
      totalDrillsCompleted,
      averagePuzzleRating,
      lastActivityAt,
      const DeepCollectionEquality().hash(_achievementBadges));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressModelImplCopyWith<_$UserProgressModelImpl> get copyWith =>
      __$$UserProgressModelImplCopyWithImpl<_$UserProgressModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressModelImplToJson(
      this,
    );
  }
}

abstract class _UserProgressModel implements UserProgressModel {
  const factory _UserProgressModel(
      {@JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'total_lessons_completed')
      required final int totalLessonsCompleted,
      @JsonKey(name: 'total_puzzles_solved')
      required final int totalPuzzesSolved,
      @JsonKey(name: 'total_drills_completed')
      required final int totalDrillsCompleted,
      @JsonKey(name: 'average_puzzle_rating')
      required final double averagePuzzleRating,
      @JsonKey(name: 'last_activity_at') required final String lastActivityAt,
      @JsonKey(name: 'achievement_badges')
      required final List<String> achievementBadges}) = _$UserProgressModelImpl;

  factory _UserProgressModel.fromJson(Map<String, dynamic> json) =
      _$UserProgressModelImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'total_lessons_completed')
  int get totalLessonsCompleted;
  @override
  @JsonKey(name: 'total_puzzles_solved')
  int get totalPuzzesSolved;
  @override
  @JsonKey(name: 'total_drills_completed')
  int get totalDrillsCompleted;
  @override
  @JsonKey(name: 'average_puzzle_rating')
  double get averagePuzzleRating;
  @override
  @JsonKey(name: 'last_activity_at')
  String get lastActivityAt;
  @override
  @JsonKey(name: 'achievement_badges')
  List<String> get achievementBadges;
  @override
  @JsonKey(ignore: true)
  _$$UserProgressModelImplCopyWith<_$UserProgressModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
