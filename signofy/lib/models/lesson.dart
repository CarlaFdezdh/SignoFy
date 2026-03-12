// lib/models/lesson.dart
import 'sign.dart';

enum LessonStatus { locked, available, inProgress, completed }
enum ExerciseType { watchAndChoose, chooseSign, translateSentence, fillBlank }
enum DifficultyLevel { basico, intermedio, avanzado }

class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final DifficultyLevel difficulty;
  final String category;
  final List<Exercise> exercises;
  LessonStatus status;
  int xpReward;
  int completionCount;
  double? lastScore; // 0.0 - 1.0

  Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.difficulty,
    required this.category,
    required this.exercises,
    this.status = LessonStatus.locked,
    this.xpReward = 30,
    this.completionCount = 0,
    this.lastScore,
  });

  int get totalQuestions => exercises.length;
  bool get isCompleted => status == LessonStatus.completed;
  bool get isUnlocked =>
      status == LessonStatus.available || status == LessonStatus.inProgress;

  String get difficultyLabel {
    switch (difficulty) {
      case DifficultyLevel.basico:
        return 'Básico';
      case DifficultyLevel.intermedio:
        return 'Intermedio';
      case DifficultyLevel.avanzado:
        return 'Avanzado';
    }
  }
}

class Exercise {
  final String id;
  final ExerciseType type;
  final Sign sign;
  final List<String> options;    // Opciones de respuesta (palabras)
  final String correctAnswer;
  final String? instruction;
  final String? hint;

  const Exercise({
    required this.id,
    required this.type,
    required this.sign,
    required this.options,
    required this.correctAnswer,
    this.instruction,
    this.hint,
  });

  String get instructionText {
    if (instruction != null) return instruction!;
    switch (type) {
      case ExerciseType.watchAndChoose:
        return '¿Qué signo es este?';
      case ExerciseType.chooseSign:
        return '¿Cuál es el signo para esta palabra?';
      case ExerciseType.translateSentence:
        return 'Traduce esta frase';
      case ExerciseType.fillBlank:
        return 'Completa la frase';
    }
  }
}

class LessonResult {
  final String lessonId;
  final int correctAnswers;
  final int totalQuestions;
  final int xpEarned;
  final int timeSeconds;
  final DateTime completedAt;

  const LessonResult({
    required this.lessonId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.xpEarned,
    required this.timeSeconds,
    required this.completedAt,
  });

  double get score => totalQuestions > 0 ? correctAnswers / totalQuestions : 0;
  bool get isPerfect => score == 1.0;
  String get scoreLabel => '${(score * 100).round()}%';
}

// Generador de lecciones predefinidas por tema
class LessonCatalog {
  static List<Lesson> getBasicLessons() {
    return [
      Lesson(
        id: 'greetings_01',
        title: 'Saludos básicos',
        subtitle: 'Hola, Adiós, Gracias, Por favor',
        emoji: '👋',
        difficulty: DifficultyLevel.basico,
        category: 'Saludos y despedidas',
        exercises: [],
        status: LessonStatus.available,
        xpReward: 20,
      ),
      Lesson(
        id: 'greetings_02',
        title: 'Presentaciones',
        subtitle: 'Me llamo, Soy de, Encantado/a',
        emoji: '🤝',
        difficulty: DifficultyLevel.basico,
        category: 'Saludos y despedidas',
        exercises: [],
        xpReward: 25,
      ),
      Lesson(
        id: 'numbers_01',
        title: 'Números del 1 al 10',
        subtitle: 'Aprende a contar con las manos',
        emoji: '🔢',
        difficulty: DifficultyLevel.basico,
        category: 'Números',
        exercises: [],
        xpReward: 20,
      ),
      Lesson(
        id: 'numbers_02',
        title: 'Números del 10 al 100',
        subtitle: 'Decenas y combinaciones',
        emoji: '💯',
        difficulty: DifficultyLevel.basico,
        category: 'Números',
        exercises: [],
        xpReward: 30,
      ),
      Lesson(
        id: 'colors_01',
        title: 'Los colores',
        subtitle: 'Rojo, azul, verde, amarillo...',
        emoji: '🎨',
        difficulty: DifficultyLevel.basico,
        category: 'Colores',
        exercises: [],
        xpReward: 25,
      ),
      Lesson(
        id: 'family_01',
        title: 'La familia',
        subtitle: 'Madre, padre, hermano/a, abuelos',
        emoji: '👨‍👩‍👧‍👦',
        difficulty: DifficultyLevel.basico,
        category: 'Familia',
        exercises: [],
        xpReward: 25,
      ),
      Lesson(
        id: 'emotions_01',
        title: 'Emociones básicas',
        subtitle: 'Feliz, triste, enfadado, sorprendido',
        emoji: '😊',
        difficulty: DifficultyLevel.basico,
        category: 'Emociones',
        exercises: [],
        xpReward: 30,
      ),
      Lesson(
        id: 'food_01',
        title: 'Alimentos cotidianos',
        subtitle: 'Pan, agua, leche, fruta...',
        emoji: '🍎',
        difficulty: DifficultyLevel.intermedio,
        category: 'Alimentos',
        exercises: [],
        xpReward: 35,
      ),
      Lesson(
        id: 'days_01',
        title: 'Días de la semana',
        subtitle: 'Lunes, martes, miércoles...',
        emoji: '📅',
        difficulty: DifficultyLevel.basico,
        category: 'Días y meses',
        exercises: [],
        xpReward: 25,
      ),
      Lesson(
        id: 'body_01',
        title: 'El cuerpo humano',
        subtitle: 'Cabeza, manos, pies, cara...',
        emoji: '💪',
        difficulty: DifficultyLevel.intermedio,
        category: 'Cuerpo humano',
        exercises: [],
        xpReward: 35,
      ),
    ];
  }
}
