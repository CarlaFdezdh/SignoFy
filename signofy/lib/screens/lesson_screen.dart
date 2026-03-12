// lib/screens/lesson_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/lesson.dart';
import '../models/sign.dart';
import '../providers/app_provider.dart';
import '../services/lse_api_service.dart';
import '../theme/app_theme.dart';
import 'results_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final AnimationController _progressController;

  List<_QuizItem> _quizItems = [];
  int _currentIndex = 0;
  int _correctAnswers = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _isLoading = true;
  final DateTime _startTime = DateTime.now();

  // Barra de progreso de la lección
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _progressController = AnimationController(vsync: this, duration: 300.ms);
    _progressAnim = Tween<double>(begin: 0, end: 0)
        .animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
    _loadQuizData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadQuizData() async {
    final api = context.read<AppProvider>().apiService;

    // Cargar signos de la categoría de la lección
    final signs = await api.getSignsByCategory(widget.lesson.category);

    // Construir items de quiz: 4-8 preguntas
    final items = <_QuizItem>[];
    final available = signs.isNotEmpty ? signs : _fallbackSigns();

    for (var i = 0; i < available.length.clamp(0, 8); i++) {
      final sign = available[i];
      final wrongOptions = available
          .where((s) => s.id != sign.id)
          .take(3)
          .map((s) => s.word)
          .toList();

      final options = [sign.word, ...wrongOptions]..shuffle();
      items.add(_QuizItem(sign: sign, options: options));
    }

    if (items.isEmpty) {
      // Crear quiz mínimo con signos de ejemplo
      items.addAll(_buildFallbackQuiz());
    }

    setState(() {
      _quizItems = items;
      _isLoading = false;
    });
    _updateProgress();
  }

  void _updateProgress() {
    final target = _quizItems.isEmpty
        ? 0.0
        : (_currentIndex / _quizItems.length);
    _progressAnim = Tween<double>(
      begin: _progressAnim.value,
      end: target,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
    _progressController.forward(from: 0);
  }

  void _onAnswerSelected(String answer) {
    if (_answered) return;
    final isCorrect = answer == _quizItems[_currentIndex].sign.word;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (isCorrect) _correctAnswers++;
    });

    if (isCorrect) {
      _confettiController.play();
    }

    // Avanzar automáticamente tras 1.5 segundos
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentIndex < _quizItems.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
        _updateProgress();
      } else {
        _finishLesson();
      }
    });
  }

  void _finishLesson() async {
    final seconds = DateTime.now().difference(_startTime).inSeconds;
    final provider = context.read<AppProvider>();
    final result = await provider.submitLessonResult(
      widget.lesson,
      _correctAnswers,
      _quizItems.length,
      seconds,
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                AppTheme.primary,
                AppTheme.accent,
                AppTheme.gold,
                Colors.white,
              ],
              numberOfParticles: 20,
              gravity: 0.3,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _LessonTopBar(
                  lesson: widget.lesson,
                  progressAnim: _progressAnim,
                  onClose: () => Navigator.pop(context),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                      : _quizItems.isEmpty
                          ? _EmptyState(onBack: () => Navigator.pop(context))
                          : _QuizContent(
                              item: _quizItems[_currentIndex],
                              selectedAnswer: _selectedAnswer,
                              answered: _answered,
                              onAnswerSelected: _onAnswerSelected,
                              currentIndex: _currentIndex,
                              total: _quizItems.length,
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Sign> _fallbackSigns() => [
    const Sign(id: 'f1', word: 'Hola', category: 'Saludos'),
    const Sign(id: 'f2', word: 'Gracias', category: 'Saludos'),
    const Sign(id: 'f3', word: 'Adiós', category: 'Saludos'),
    const Sign(id: 'f4', word: 'Por favor', category: 'Saludos'),
  ];

  List<_QuizItem> _buildFallbackQuiz() {
    final signs = _fallbackSigns();
    return signs.map((sign) {
      final opts = [sign.word, ...signs.where((s) => s.id != sign.id).map((s) => s.word)]
          .take(4)
          .toList()
        ..shuffle();
      return _QuizItem(sign: sign, options: opts);
    }).toList();
  }
}

// ─── Barra superior de lección ────────────────────────────────────────────────
class _LessonTopBar extends StatelessWidget {
  final Lesson lesson;
  final Animation<double> progressAnim;
  final VoidCallback onClose;

  const _LessonTopBar({
    required this.lesson,
    required this.progressAnim,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: AppTheme.onSurfaceMuted),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: progressAnim,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressAnim.value,
                  backgroundColor: AppTheme.surfaceElevated,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                  minHeight: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.bolt_rounded, color: AppTheme.gold, size: 20),
        ],
      ),
    );
  }
}

// ─── Contenido del quiz ───────────────────────────────────────────────────────
class _QuizContent extends StatelessWidget {
  final _QuizItem item;
  final String? selectedAnswer;
  final bool answered;
  final ValueChanged<String> onAnswerSelected;
  final int currentIndex;
  final int total;

  const _QuizContent({
    required this.item,
    required this.selectedAnswer,
    required this.answered,
    required this.onAnswerSelected,
    required this.currentIndex,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${currentIndex + 1} / $total',
            style: const TextStyle(
              color: AppTheme.onSurfaceMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '¿Qué signo es este?',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),

          // Video / imagen del signo
          _SignVideoCard(sign: item.sign),

          const SizedBox(height: 32),

          // Opciones de respuesta
          ...item.options.asMap().entries.map((entry) {
            final option = entry.value;
            final isSelected = selectedAnswer == option;
            final isCorrect = option == item.sign.word;

            Color borderColor = AppTheme.primary.withOpacity(0.3);
            Color bgColor = AppTheme.surfaceCard;
            Color textColor = AppTheme.onSurface;
            Widget? trailing;

            if (answered) {
              if (isCorrect) {
                borderColor = AppTheme.success;
                bgColor = AppTheme.success.withOpacity(0.12);
                textColor = AppTheme.success;
                trailing = const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 22);
              } else if (isSelected) {
                borderColor = AppTheme.error;
                bgColor = AppTheme.error.withOpacity(0.12);
                textColor = AppTheme.error;
                trailing = const Icon(Icons.cancel_rounded,
                    color: AppTheme.error, size: 22);
              }
            } else if (isSelected) {
              borderColor = AppTheme.primary;
              bgColor = AppTheme.primary.withOpacity(0.15);
            }

            return GestureDetector(
              onTap: answered ? null : () => onAnswerSelected(option),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing,
                  ],
                ),
              )
                  .animate(delay: (entry.key * 80).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.05),
            );
          }),

          if (answered) ...[
            const SizedBox(height: 8),
            _AnswerFeedback(
              isCorrect: selectedAnswer == item.sign.word,
              word: item.sign.word,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Card de vídeo del signo ──────────────────────────────────────────────────
class _SignVideoCard extends StatelessWidget {
  final Sign sign;
  const _SignVideoCard({required this.sign});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceElevated,
            AppTheme.primary.withOpacity(0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          // Fondo decorativo
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.08),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono de signo (placeholder hasta tener vídeos)
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sign_language_rounded,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Si hay URL de vídeo, mostrar botón de play
                if (sign.videoUrl != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill_rounded,
                            color: AppTheme.primary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Ver el signo',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(
          begin: const Offset(0.9, 0.9),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}

// ─── Feedback de respuesta ────────────────────────────────────────────────────
class _AnswerFeedback extends StatelessWidget {
  final bool isCorrect;
  final String word;

  const _AnswerFeedback({required this.isCorrect, required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isCorrect ? AppTheme.success : AppTheme.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isCorrect ? AppTheme.success : AppTheme.error).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Text(
            isCorrect ? '🎉' : '😅',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? '¡Correcto!' : '¡Casi!',
                  style: TextStyle(
                    color: isCorrect ? AppTheme.success : AppTheme.error,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                if (!isCorrect)
                  Text(
                    'Era: $word',
                    style: TextStyle(
                      color: isCorrect
                          ? AppTheme.success
                          : AppTheme.error.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBack;
  const _EmptyState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'No se encontraron signos\npara esta lección',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onBack, child: const Text('Volver')),
        ],
      ),
    );
  }
}

// ─── Modelo interno de pregunta ───────────────────────────────────────────────
class _QuizItem {
  final Sign sign;
  final List<String> options;
  const _QuizItem({required this.sign, required this.options});
}
