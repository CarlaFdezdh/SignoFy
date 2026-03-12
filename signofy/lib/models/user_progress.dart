// lib/models/user_progress.dart

class AppBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final AppBadgeType type;
  bool isUnlocked;
  DateTime? unlockedAt;

  AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

enum AppBadgeType { streak, xp, lessons, perfect, category, special }

class UserProgress {
  int totalXP;
  int currentStreak;
  int longestStreak;
  int lessonsCompleted;
  int perfectLessons;
  DateTime? lastStudyDate;
  Map<String, bool> completedLessons;
  Map<String, double> lessonScores;
  List<String> unlockedBadgeIds;
  String? currentLeague;
  int weeklyXP;
  DateTime weekStart;

  UserProgress({
    this.totalXP = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lessonsCompleted = 0,
    this.perfectLessons = 0,
    this.lastStudyDate,
    Map<String, bool>? completedLessons,
    Map<String, double>? lessonScores,
    List<String>? unlockedBadgeIds,
    this.currentLeague = 'bronce',
    this.weeklyXP = 0,
    DateTime? weekStart,
  })  : completedLessons = completedLessons ?? {},
        lessonScores = lessonScores ?? {},
        unlockedBadgeIds = unlockedBadgeIds ?? [],
        weekStart = weekStart ?? DateTime.now();

  int get level {
    if (totalXP < 100) return 1;
    if (totalXP < 300) return 2;
    if (totalXP < 600) return 3;
    if (totalXP < 1000) return 4;
    if (totalXP < 1500) return 5;
    if (totalXP < 2200) return 6;
    if (totalXP < 3000) return 7;
    if (totalXP < 4000) return 8;
    if (totalXP < 5500) return 9;
    return 10 + ((totalXP - 5500) ~/ 2000);
  }

  int get xpForCurrentLevel {
    const thresholds = [0, 100, 300, 600, 1000, 1500, 2200, 3000, 4000, 5500];
    final lv = level.clamp(1, 10);
    return lv <= 9 ? thresholds[lv - 1] : thresholds.last + (lv - 10) * 2000;
  }

  int get xpForNextLevel {
    const thresholds = [100, 300, 600, 1000, 1500, 2200, 3000, 4000, 5500, 7500];
    final lv = level.clamp(1, 10);
    return lv <= 9 ? thresholds[lv - 1] : xpForCurrentLevel + 2000;
  }

  double get levelProgress {
    final current = xpForCurrentLevel;
    final next = xpForNextLevel;
    return (totalXP - current) / (next - current);
  }

  String get levelTitle {
    if (level < 3) return 'Aprendiz';
    if (level < 5) return 'Estudiante';
    if (level < 7) return 'Comunicador';
    if (level < 9) return 'Intérprete';
    return 'Maestro LSE';
  }

  String get leagueEmoji {
    switch (currentLeague) {
      case 'bronce': return '🥉';
      case 'plata':  return '🥈';
      case 'oro':    return '🥇';
      case 'diamante': return '💎';
      default: return '🥉';
    }
  }

  bool get studiedToday {
    if (lastStudyDate == null) return false;
    final now = DateTime.now();
    final last = lastStudyDate!;
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }

  void addXP(int amount) {
    totalXP += amount;
    weeklyXP += amount;
    _updateLeague();
  }

  void markStudiedToday() {
    final now = DateTime.now();
    if (!studiedToday) {
      final yesterday = now.subtract(const Duration(days: 1));
      final wasYesterday = lastStudyDate != null &&
          lastStudyDate!.year == yesterday.year &&
          lastStudyDate!.month == yesterday.month &&
          lastStudyDate!.day == yesterday.day;
      currentStreak = wasYesterday ? currentStreak + 1 : 1;
      if (currentStreak > longestStreak) longestStreak = currentStreak;
    }
    lastStudyDate = now;
  }

  void _updateLeague() {
    if (totalXP >= 5000) {
      currentLeague = 'diamante';
    } else if (totalXP >= 2000) {
      currentLeague = 'oro';
    } else if (totalXP >= 500) {
      currentLeague = 'plata';
    } else {
      currentLeague = 'bronce';
    }
  }

  Map<String, dynamic> toJson() => {
    'totalXP': totalXP,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lessonsCompleted': lessonsCompleted,
    'perfectLessons': perfectLessons,
    'lastStudyDate': lastStudyDate?.toIso8601String(),
    'completedLessons': completedLessons,
    'lessonScores': lessonScores,
    'unlockedBadgeIds': unlockedBadgeIds,
    'currentLeague': currentLeague,
    'weeklyXP': weeklyXP,
    'weekStart': weekStart.toIso8601String(),
  };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    totalXP: json['totalXP'] ?? 0,
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    lessonsCompleted: json['lessonsCompleted'] ?? 0,
    perfectLessons: json['perfectLessons'] ?? 0,
    lastStudyDate: json['lastStudyDate'] != null
        ? DateTime.parse(json['lastStudyDate'])
        : null,
    completedLessons: Map<String, bool>.from(json['completedLessons'] ?? {}),
    lessonScores: Map<String, double>.from(json['lessonScores'] ?? {}),
    unlockedBadgeIds: List<String>.from(json['unlockedBadgeIds'] ?? []),
    currentLeague: json['currentLeague'] ?? 'bronce',
    weeklyXP: json['weeklyXP'] ?? 0,
    weekStart: json['weekStart'] != null
        ? DateTime.parse(json['weekStart'])
        : DateTime.now(),
  );
}

class BadgeCatalog {
  static List<AppBadge> all() => [
    AppBadge(id: 'first_lesson',     name: 'Primera lección',       description: 'Completaste tu primera lección',              emoji: '🌟', type: AppBadgeType.lessons),
    AppBadge(id: 'streak_3',         name: 'Calentando motores',     description: '3 días de racha seguidos',                    emoji: '🔥', type: AppBadgeType.streak),
    AppBadge(id: 'streak_7',         name: 'Una semana sin parar',   description: '7 días de racha',                             emoji: '⚡', type: AppBadgeType.streak),
    AppBadge(id: 'streak_30',        name: 'Mes de dedicación',      description: '30 días de racha',                            emoji: '🏅', type: AppBadgeType.streak),
    AppBadge(id: 'xp_100',           name: 'Primeros pasos',         description: 'Alcanzaste 100 XP',                           emoji: '💫', type: AppBadgeType.xp),
    AppBadge(id: 'xp_500',           name: 'En el camino',           description: 'Alcanzaste 500 XP',                           emoji: '🚀', type: AppBadgeType.xp),
    AppBadge(id: 'xp_1000',          name: 'Mil puntos',             description: 'Alcanzaste 1000 XP',                          emoji: '💎', type: AppBadgeType.xp),
    AppBadge(id: 'perfect_5',        name: 'Perfeccionista',         description: '5 lecciones con puntuación perfecta',         emoji: '🎯', type: AppBadgeType.perfect),
    AppBadge(id: 'lessons_10',       name: 'Aprendiz dedicado',      description: 'Completaste 10 lecciones',                    emoji: '📚', type: AppBadgeType.lessons),
    AppBadge(id: 'lessons_25',       name: 'Comunicador LSE',        description: 'Completaste 25 lecciones',                    emoji: '🤟', type: AppBadgeType.lessons),
    AppBadge(id: 'greetings_master', name: 'Maestro de saludos',     description: 'Completaste todas las lecciones de saludos',  emoji: '👋', type: AppBadgeType.category),
    AppBadge(id: 'numbers_master',   name: 'Maestro de números',     description: 'Completaste todas las lecciones de números',  emoji: '🔢', type: AppBadgeType.category),
  ];
}