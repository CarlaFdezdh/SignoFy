// lib/services/progress_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';
import '../models/lesson.dart';

class ProgressService {
  static const String _progressKey = 'user_progress';
  static const String _nameKey = 'user_name';

  // ─── Cargar / Guardar ─────────────────────────────────────────────────────
  Future<UserProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_progressKey);
    if (json == null) return UserProgress();
    try {
      return UserProgress.fromJson(jsonDecode(json));
    } catch (_) {
      return UserProgress();
    }
  }

  Future<void> saveProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'Aprendiz';
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  // ─── Lógica de lecciones ──────────────────────────────────────────────────
  Future<LessonResult> completeLesson(
    UserProgress progress,
    Lesson lesson,
    int correctAnswers,
    int totalQuestions,
    int timeSeconds,
  ) async {
    final score = totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
    final baseXP = lesson.xpReward;
    final bonusXP = score == 1.0 ? (baseXP * 0.5).round() : 0;
    final streakBonus = progress.currentStreak >= 7 ? 5 : 0;
    final xpEarned = baseXP + bonusXP + streakBonus;

    // Actualizar progreso
    progress.addXP(xpEarned);
    progress.markStudiedToday();
    progress.completedLessons[lesson.id] = true;
    progress.lessonScores[lesson.id] = score;
    progress.lessonsCompleted++;
    if (score == 1.0) progress.perfectLessons++;

    // Comprobar insignias nuevas
    _checkBadges(progress);

    // Guardar
    await saveProgress(progress);

    return LessonResult(
      lessonId: lesson.id,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      xpEarned: xpEarned,
      timeSeconds: timeSeconds,
      completedAt: DateTime.now(),
    );
  }

  void _checkBadges(UserProgress progress) {
    final ids = progress.unlockedBadgeIds;
    void unlock(String id) {
      if (!ids.contains(id)) ids.add(id);
    }

    if (progress.lessonsCompleted >= 1) unlock('first_lesson');
    if (progress.lessonsCompleted >= 10) unlock('lessons_10');
    if (progress.lessonsCompleted >= 25) unlock('lessons_25');
    if (progress.currentStreak >= 3) unlock('streak_3');
    if (progress.currentStreak >= 7) unlock('streak_7');
    if (progress.currentStreak >= 30) unlock('streak_30');
    if (progress.totalXP >= 100) unlock('xp_100');
    if (progress.totalXP >= 500) unlock('xp_500');
    if (progress.totalXP >= 1000) unlock('xp_1000');
    if (progress.perfectLessons >= 5) unlock('perfect_5');
  }

  // ─── Desbloqueo de lecciones ──────────────────────────────────────────────
  List<Lesson> getUpdatedLessons(
    List<Lesson> catalog,
    UserProgress progress,
  ) {
    for (var i = 0; i < catalog.length; i++) {
      final lesson = catalog[i];
      if (progress.completedLessons[lesson.id] == true) {
        lesson.status = LessonStatus.completed;
        lesson.lastScore = progress.lessonScores[lesson.id];
      } else if (i == 0 || progress.completedLessons[catalog[i - 1].id] == true) {
        lesson.status = LessonStatus.available;
      }
      // Las demás permanecen bloqueadas
    }
    return catalog;
  }
}
