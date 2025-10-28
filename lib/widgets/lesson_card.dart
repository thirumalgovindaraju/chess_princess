// domain/entities/lesson.dart

enum LessonLevel {
  beginner,
  intermediate,
  advanced,
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final LessonLevel level;
  final int durationSeconds;
  final List<Quiz> quizzes;
  final bool isCompleted;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.level,
    required this.durationSeconds,
    required this.quizzes,
    this.isCompleted = false,
  });

  // Factory constructor for creating from JSON (common in API calls)
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      level: LessonLevel.values[json['level'] as int? ?? 0],
      durationSeconds: json['durationSeconds'] as int,
      quizzes: (json['quizzes'] as List<dynamic>? ?? [])
          .map((q) => Quiz.fromJson(q as Map<String, dynamic>))
          .toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'level': level.index,
      'durationSeconds': durationSeconds,
      'quizzes': quizzes.map((q) => q.toJson()).toList(),
      'isCompleted': isCompleted,
    };
  }

  // CopyWith method for creating modified copies
  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    LessonLevel? level,
    int? durationSeconds,
    List<Quiz>? quizzes,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      level: level ?? this.level,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      quizzes: quizzes ?? this.quizzes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Lesson &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              description == other.description &&
              thumbnailUrl == other.thumbnailUrl &&
              level == other.level &&
              durationSeconds == other.durationSeconds &&
              isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      thumbnailUrl.hashCode ^
      level.hashCode ^
      durationSeconds.hashCode ^
      isCompleted.hashCode;

  @override
  String toString() =>
      'Lesson(id: $id, title: $title, level: $level, isCompleted: $isCompleted)';
}

class Quiz {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  const Quiz({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}