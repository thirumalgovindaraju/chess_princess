// lib/domain/repositories/lesson_repository.dart

import '../entities/lesson.dart'; // ✅ add this import
//import '../entities/lesson_level.dart'; // ✅ if LessonLevel is in another file

abstract class LessonRepository {
  Future<List<Lesson>> getLessons({LessonLevel? level});
  Future<Lesson> getLessonById(String id);
  Future<void> saveLessonProgress(String lessonId, double progress);
  Future<void> markLessonComplete(String lessonId);
  Future<void> saveLessonLocally(Lesson lesson);
  Future<List<Lesson>> getCachedLessons();
}
