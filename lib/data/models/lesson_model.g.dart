// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonModelImpl _$$LessonModelImplFromJson(Map<String, dynamic> json) =>
    _$LessonModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      thumbnailUrl: json['thumbnail_url'] as String,
      videoUrl: json['video_url'] as String,
      slides: (json['slides'] as List<dynamic>)
          .map((e) => LessonSlideModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      quizzes: (json['quizzes'] as List<dynamic>)
          .map((e) => LessonQuizModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$LessonModelImplToJson(_$LessonModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'level': instance.level,
      'duration_seconds': instance.durationSeconds,
      'thumbnail_url': instance.thumbnailUrl,
      'video_url': instance.videoUrl,
      'slides': instance.slides,
      'quizzes': instance.quizzes,
      'progress': instance.progress,
      'isCompleted': instance.isCompleted,
    };

_$LessonSlideModelImpl _$$LessonSlideModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LessonSlideModelImpl(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      text: json['text'] as String,
      caption: json['caption'] as String?,
    );

Map<String, dynamic> _$$LessonSlideModelImplToJson(
        _$LessonSlideModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image_url': instance.imageUrl,
      'text': instance.text,
      'caption': instance.caption,
    };

_$LessonQuizModelImpl _$$LessonQuizModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LessonQuizModelImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      answerIndex: (json['answer_index'] as num?)?.toInt(),
      fen: json['fen'] as String?,
      solutionSan: (json['solution_san'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isAnswered: json['isAnswered'] as bool? ?? false,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );

Map<String, dynamic> _$$LessonQuizModelImplToJson(
        _$LessonQuizModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'question': instance.question,
      'options': instance.options,
      'answer_index': instance.answerIndex,
      'fen': instance.fen,
      'solution_san': instance.solutionSan,
      'isAnswered': instance.isAnswered,
      'isCorrect': instance.isCorrect,
    };
