// lib/providers/app_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../models/lesson.dart';
import '../models/sign.dart';
import '../services/progress_service.dart';
import '../services/lse_api_service.dart';

class AppProvider extends ChangeNotifier {
  final ProgressService _progressService = ProgressService();
  final LseApiService _apiService = LseApiService();

  UserProgress _progress = UserProgress();
  List<Lesson> _lessons = [];
  String _userName = 'Aprendiz';
  bool _isLoading = true;
  String? _newBadgeId; // Para mostrar animación de nueva insignia

  UserProgress get progress => _progress;
  List<Lesson> get lessons => _lessons;
  String get userName => _userName;
  bool get isLoading => _isLoading;
  String? get newBadgeId => _newBadgeId;
  LseApiService get apiService => _apiService;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _progress = await _progressService.loadProgress();
    _userName = await _progressService.getUserName();
    _lessons = _progressService.getUpdatedLessons(
      LessonCatalog.getBasicLessons(),
      _progress,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _progressService.setUserName(name);
    notifyListeners();
  }

  Future<LessonResult> submitLessonResult(
    Lesson lesson,
    int correctAnswers,
    int totalQuestions,
    int timeSeconds,
  ) async {
    final previousBadges = List<String>.from(_progress.unlockedBadgeIds);

    final result = await _progressService.completeLesson(
      _progress,
      lesson,
      correctAnswers,
      totalQuestions,
      timeSeconds,
    );

    // Detectar nueva insignia
    final newBadges = _progress.unlockedBadgeIds
        .where((id) => !previousBadges.contains(id))
        .toList();
    if (newBadges.isNotEmpty) {
      _newBadgeId = newBadges.first;
    }

    _lessons = _progressService.getUpdatedLessons(_lessons, _progress);
    notifyListeners();
    return result;
  }

  void clearNewBadge() {
    _newBadgeId = null;
  }

  // ─── Búsqueda de signos ───────────────────────────────────────────────────
  Future<List<Sign>> searchSigns(String query) =>
      _apiService.searchSigns(query);

  Future<List<Sign>> getSignsByCategory(String category) =>
      _apiService.getSignsByCategory(category);

  // ─── Login API ────────────────────────────────────────────────────────────
  Future<bool> loginToApi(String user, String pass) =>
      _apiService.login(user, pass);
}
