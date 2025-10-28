// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lesson_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LessonModel _$LessonModelFromJson(Map<String, dynamic> json) {
  return _LessonModel.fromJson(json);
}

/// @nodoc
mixin _$LessonModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_seconds')
  int get durationSeconds => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String get thumbnailUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'video_url')
  String get videoUrl => throw _privateConstructorUsedError;
  List<LessonSlideModel> get slides => throw _privateConstructorUsedError;
  List<LessonQuizModel> get quizzes => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonModelCopyWith<LessonModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonModelCopyWith<$Res> {
  factory $LessonModelCopyWith(
          LessonModel value, $Res Function(LessonModel) then) =
      _$LessonModelCopyWithImpl<$Res, LessonModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String level,
      @JsonKey(name: 'duration_seconds') int durationSeconds,
      @JsonKey(name: 'thumbnail_url') String thumbnailUrl,
      @JsonKey(name: 'video_url') String videoUrl,
      List<LessonSlideModel> slides,
      List<LessonQuizModel> quizzes,
      double progress,
      bool isCompleted});
}

/// @nodoc
class _$LessonModelCopyWithImpl<$Res, $Val extends LessonModel>
    implements $LessonModelCopyWith<$Res> {
  _$LessonModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? level = null,
    Object? durationSeconds = null,
    Object? thumbnailUrl = null,
    Object? videoUrl = null,
    Object? slides = null,
    Object? quizzes = null,
    Object? progress = null,
    Object? isCompleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      slides: null == slides
          ? _value.slides
          : slides // ignore: cast_nullable_to_non_nullable
              as List<LessonSlideModel>,
      quizzes: null == quizzes
          ? _value.quizzes
          : quizzes // ignore: cast_nullable_to_non_nullable
              as List<LessonQuizModel>,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonModelImplCopyWith<$Res>
    implements $LessonModelCopyWith<$Res> {
  factory _$$LessonModelImplCopyWith(
          _$LessonModelImpl value, $Res Function(_$LessonModelImpl) then) =
      __$$LessonModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String level,
      @JsonKey(name: 'duration_seconds') int durationSeconds,
      @JsonKey(name: 'thumbnail_url') String thumbnailUrl,
      @JsonKey(name: 'video_url') String videoUrl,
      List<LessonSlideModel> slides,
      List<LessonQuizModel> quizzes,
      double progress,
      bool isCompleted});
}

/// @nodoc
class __$$LessonModelImplCopyWithImpl<$Res>
    extends _$LessonModelCopyWithImpl<$Res, _$LessonModelImpl>
    implements _$$LessonModelImplCopyWith<$Res> {
  __$$LessonModelImplCopyWithImpl(
      _$LessonModelImpl _value, $Res Function(_$LessonModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? level = null,
    Object? durationSeconds = null,
    Object? thumbnailUrl = null,
    Object? videoUrl = null,
    Object? slides = null,
    Object? quizzes = null,
    Object? progress = null,
    Object? isCompleted = null,
  }) {
    return _then(_$LessonModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      slides: null == slides
          ? _value._slides
          : slides // ignore: cast_nullable_to_non_nullable
              as List<LessonSlideModel>,
      quizzes: null == quizzes
          ? _value._quizzes
          : quizzes // ignore: cast_nullable_to_non_nullable
              as List<LessonQuizModel>,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonModelImpl implements _LessonModel {
  const _$LessonModelImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.level,
      @JsonKey(name: 'duration_seconds') required this.durationSeconds,
      @JsonKey(name: 'thumbnail_url') required this.thumbnailUrl,
      @JsonKey(name: 'video_url') required this.videoUrl,
      required final List<LessonSlideModel> slides,
      required final List<LessonQuizModel> quizzes,
      this.progress = 0.0,
      this.isCompleted = false})
      : _slides = slides,
        _quizzes = quizzes;

  factory _$LessonModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String level;
  @override
  @JsonKey(name: 'duration_seconds')
  final int durationSeconds;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String thumbnailUrl;
  @override
  @JsonKey(name: 'video_url')
  final String videoUrl;
  final List<LessonSlideModel> _slides;
  @override
  List<LessonSlideModel> get slides {
    if (_slides is EqualUnmodifiableListView) return _slides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slides);
  }

  final List<LessonQuizModel> _quizzes;
  @override
  List<LessonQuizModel> get quizzes {
    if (_quizzes is EqualUnmodifiableListView) return _quizzes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quizzes);
  }

  @override
  @JsonKey()
  final double progress;
  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'LessonModel(id: $id, title: $title, description: $description, level: $level, durationSeconds: $durationSeconds, thumbnailUrl: $thumbnailUrl, videoUrl: $videoUrl, slides: $slides, quizzes: $quizzes, progress: $progress, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            const DeepCollectionEquality().equals(other._slides, _slides) &&
            const DeepCollectionEquality().equals(other._quizzes, _quizzes) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      level,
      durationSeconds,
      thumbnailUrl,
      videoUrl,
      const DeepCollectionEquality().hash(_slides),
      const DeepCollectionEquality().hash(_quizzes),
      progress,
      isCompleted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonModelImplCopyWith<_$LessonModelImpl> get copyWith =>
      __$$LessonModelImplCopyWithImpl<_$LessonModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonModelImplToJson(
      this,
    );
  }
}

abstract class _LessonModel implements LessonModel {
  const factory _LessonModel(
      {required final String id,
      required final String title,
      required final String description,
      required final String level,
      @JsonKey(name: 'duration_seconds') required final int durationSeconds,
      @JsonKey(name: 'thumbnail_url') required final String thumbnailUrl,
      @JsonKey(name: 'video_url') required final String videoUrl,
      required final List<LessonSlideModel> slides,
      required final List<LessonQuizModel> quizzes,
      final double progress,
      final bool isCompleted}) = _$LessonModelImpl;

  factory _LessonModel.fromJson(Map<String, dynamic> json) =
      _$LessonModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get level;
  @override
  @JsonKey(name: 'duration_seconds')
  int get durationSeconds;
  @override
  @JsonKey(name: 'thumbnail_url')
  String get thumbnailUrl;
  @override
  @JsonKey(name: 'video_url')
  String get videoUrl;
  @override
  List<LessonSlideModel> get slides;
  @override
  List<LessonQuizModel> get quizzes;
  @override
  double get progress;
  @override
  bool get isCompleted;
  @override
  @JsonKey(ignore: true)
  _$$LessonModelImplCopyWith<_$LessonModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonSlideModel _$LessonSlideModelFromJson(Map<String, dynamic> json) {
  return _LessonSlideModel.fromJson(json);
}

/// @nodoc
mixin _$LessonSlideModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonSlideModelCopyWith<LessonSlideModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonSlideModelCopyWith<$Res> {
  factory $LessonSlideModelCopyWith(
          LessonSlideModel value, $Res Function(LessonSlideModel) then) =
      _$LessonSlideModelCopyWithImpl<$Res, LessonSlideModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'image_url') String imageUrl,
      String text,
      String? caption});
}

/// @nodoc
class _$LessonSlideModelCopyWithImpl<$Res, $Val extends LessonSlideModel>
    implements $LessonSlideModelCopyWith<$Res> {
  _$LessonSlideModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? text = null,
    Object? caption = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonSlideModelImplCopyWith<$Res>
    implements $LessonSlideModelCopyWith<$Res> {
  factory _$$LessonSlideModelImplCopyWith(_$LessonSlideModelImpl value,
          $Res Function(_$LessonSlideModelImpl) then) =
      __$$LessonSlideModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'image_url') String imageUrl,
      String text,
      String? caption});
}

/// @nodoc
class __$$LessonSlideModelImplCopyWithImpl<$Res>
    extends _$LessonSlideModelCopyWithImpl<$Res, _$LessonSlideModelImpl>
    implements _$$LessonSlideModelImplCopyWith<$Res> {
  __$$LessonSlideModelImplCopyWithImpl(_$LessonSlideModelImpl _value,
      $Res Function(_$LessonSlideModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? text = null,
    Object? caption = freezed,
  }) {
    return _then(_$LessonSlideModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonSlideModelImpl implements _LessonSlideModel {
  const _$LessonSlideModelImpl(
      {required this.id,
      @JsonKey(name: 'image_url') required this.imageUrl,
      required this.text,
      this.caption});

  factory _$LessonSlideModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonSlideModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  final String text;
  @override
  final String? caption;

  @override
  String toString() {
    return 'LessonSlideModel(id: $id, imageUrl: $imageUrl, text: $text, caption: $caption)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonSlideModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.caption, caption) || other.caption == caption));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, imageUrl, text, caption);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonSlideModelImplCopyWith<_$LessonSlideModelImpl> get copyWith =>
      __$$LessonSlideModelImplCopyWithImpl<_$LessonSlideModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonSlideModelImplToJson(
      this,
    );
  }
}

abstract class _LessonSlideModel implements LessonSlideModel {
  const factory _LessonSlideModel(
      {required final String id,
      @JsonKey(name: 'image_url') required final String imageUrl,
      required final String text,
      final String? caption}) = _$LessonSlideModelImpl;

  factory _LessonSlideModel.fromJson(Map<String, dynamic> json) =
      _$LessonSlideModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  String get text;
  @override
  String? get caption;
  @override
  @JsonKey(ignore: true)
  _$$LessonSlideModelImplCopyWith<_$LessonSlideModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LessonQuizModel _$LessonQuizModelFromJson(Map<String, dynamic> json) {
  return _LessonQuizModel.fromJson(json);
}

/// @nodoc
mixin _$LessonQuizModel {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  List<String>? get options => throw _privateConstructorUsedError;
  @JsonKey(name: 'answer_index')
  int? get answerIndex => throw _privateConstructorUsedError;
  String? get fen => throw _privateConstructorUsedError;
  @JsonKey(name: 'solution_san')
  List<String>? get solutionSan => throw _privateConstructorUsedError;
  bool get isAnswered => throw _privateConstructorUsedError;
  bool get isCorrect => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonQuizModelCopyWith<LessonQuizModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonQuizModelCopyWith<$Res> {
  factory $LessonQuizModelCopyWith(
          LessonQuizModel value, $Res Function(LessonQuizModel) then) =
      _$LessonQuizModelCopyWithImpl<$Res, LessonQuizModel>;
  @useResult
  $Res call(
      {String id,
      String type,
      String question,
      List<String>? options,
      @JsonKey(name: 'answer_index') int? answerIndex,
      String? fen,
      @JsonKey(name: 'solution_san') List<String>? solutionSan,
      bool isAnswered,
      bool isCorrect});
}

/// @nodoc
class _$LessonQuizModelCopyWithImpl<$Res, $Val extends LessonQuizModel>
    implements $LessonQuizModelCopyWith<$Res> {
  _$LessonQuizModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? question = null,
    Object? options = freezed,
    Object? answerIndex = freezed,
    Object? fen = freezed,
    Object? solutionSan = freezed,
    Object? isAnswered = null,
    Object? isCorrect = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: freezed == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      answerIndex: freezed == answerIndex
          ? _value.answerIndex
          : answerIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      fen: freezed == fen
          ? _value.fen
          : fen // ignore: cast_nullable_to_non_nullable
              as String?,
      solutionSan: freezed == solutionSan
          ? _value.solutionSan
          : solutionSan // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isAnswered: null == isAnswered
          ? _value.isAnswered
          : isAnswered // ignore: cast_nullable_to_non_nullable
              as bool,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonQuizModelImplCopyWith<$Res>
    implements $LessonQuizModelCopyWith<$Res> {
  factory _$$LessonQuizModelImplCopyWith(_$LessonQuizModelImpl value,
          $Res Function(_$LessonQuizModelImpl) then) =
      __$$LessonQuizModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String question,
      List<String>? options,
      @JsonKey(name: 'answer_index') int? answerIndex,
      String? fen,
      @JsonKey(name: 'solution_san') List<String>? solutionSan,
      bool isAnswered,
      bool isCorrect});
}

/// @nodoc
class __$$LessonQuizModelImplCopyWithImpl<$Res>
    extends _$LessonQuizModelCopyWithImpl<$Res, _$LessonQuizModelImpl>
    implements _$$LessonQuizModelImplCopyWith<$Res> {
  __$$LessonQuizModelImplCopyWithImpl(
      _$LessonQuizModelImpl _value, $Res Function(_$LessonQuizModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? question = null,
    Object? options = freezed,
    Object? answerIndex = freezed,
    Object? fen = freezed,
    Object? solutionSan = freezed,
    Object? isAnswered = null,
    Object? isCorrect = null,
  }) {
    return _then(_$LessonQuizModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: freezed == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      answerIndex: freezed == answerIndex
          ? _value.answerIndex
          : answerIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      fen: freezed == fen
          ? _value.fen
          : fen // ignore: cast_nullable_to_non_nullable
              as String?,
      solutionSan: freezed == solutionSan
          ? _value._solutionSan
          : solutionSan // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isAnswered: null == isAnswered
          ? _value.isAnswered
          : isAnswered // ignore: cast_nullable_to_non_nullable
              as bool,
      isCorrect: null == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonQuizModelImpl implements _LessonQuizModel {
  const _$LessonQuizModelImpl(
      {required this.id,
      required this.type,
      required this.question,
      final List<String>? options,
      @JsonKey(name: 'answer_index') this.answerIndex,
      this.fen,
      @JsonKey(name: 'solution_san') final List<String>? solutionSan,
      this.isAnswered = false,
      this.isCorrect = false})
      : _options = options,
        _solutionSan = solutionSan;

  factory _$LessonQuizModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonQuizModelImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String question;
  final List<String>? _options;
  @override
  List<String>? get options {
    final value = _options;
    if (value == null) return null;
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'answer_index')
  final int? answerIndex;
  @override
  final String? fen;
  final List<String>? _solutionSan;
  @override
  @JsonKey(name: 'solution_san')
  List<String>? get solutionSan {
    final value = _solutionSan;
    if (value == null) return null;
    if (_solutionSan is EqualUnmodifiableListView) return _solutionSan;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool isAnswered;
  @override
  @JsonKey()
  final bool isCorrect;

  @override
  String toString() {
    return 'LessonQuizModel(id: $id, type: $type, question: $question, options: $options, answerIndex: $answerIndex, fen: $fen, solutionSan: $solutionSan, isAnswered: $isAnswered, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonQuizModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.answerIndex, answerIndex) ||
                other.answerIndex == answerIndex) &&
            (identical(other.fen, fen) || other.fen == fen) &&
            const DeepCollectionEquality()
                .equals(other._solutionSan, _solutionSan) &&
            (identical(other.isAnswered, isAnswered) ||
                other.isAnswered == isAnswered) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      question,
      const DeepCollectionEquality().hash(_options),
      answerIndex,
      fen,
      const DeepCollectionEquality().hash(_solutionSan),
      isAnswered,
      isCorrect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonQuizModelImplCopyWith<_$LessonQuizModelImpl> get copyWith =>
      __$$LessonQuizModelImplCopyWithImpl<_$LessonQuizModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonQuizModelImplToJson(
      this,
    );
  }
}

abstract class _LessonQuizModel implements LessonQuizModel {
  const factory _LessonQuizModel(
      {required final String id,
      required final String type,
      required final String question,
      final List<String>? options,
      @JsonKey(name: 'answer_index') final int? answerIndex,
      final String? fen,
      @JsonKey(name: 'solution_san') final List<String>? solutionSan,
      final bool isAnswered,
      final bool isCorrect}) = _$LessonQuizModelImpl;

  factory _LessonQuizModel.fromJson(Map<String, dynamic> json) =
      _$LessonQuizModelImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get question;
  @override
  List<String>? get options;
  @override
  @JsonKey(name: 'answer_index')
  int? get answerIndex;
  @override
  String? get fen;
  @override
  @JsonKey(name: 'solution_san')
  List<String>? get solutionSan;
  @override
  bool get isAnswered;
  @override
  bool get isCorrect;
  @override
  @JsonKey(ignore: true)
  _$$LessonQuizModelImplCopyWith<_$LessonQuizModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
