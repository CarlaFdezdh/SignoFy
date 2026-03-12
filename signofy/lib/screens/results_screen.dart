// lib/screens/results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/lesson.dart';
import '../theme/app_theme.dart';

class ResultsScreen extends StatefulWidget {
  final LessonResult result;
  const ResultsScreen({super.key, required this.result});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.result.isPerfect) {
      _confetti.play();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [AppTheme.primary, AppTheme.gold, AppTheme.accent],
              numberOfParticles: 30,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),

                  // Emoji resultado
                  Text(
                    r.isPerfect ? '🏆' : r.score >= 0.7 ? '😊' : '💪',
                    style: const TextStyle(fontSize: 72),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 16),

                  Text(
                    r.isPerfect
                        ? '¡Perfecto!'
                        : r.score >= 0.7
                            ? '¡Muy bien!'
                            : '¡Buen intento!',
                    style: const TextStyle(
                      color: AppTheme.onSurface,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 8),

                  Text(
                    '${r.correctAnswers} de ${r.totalQuestions} respuestas correctas',
                    style: const TextStyle(
                      color: AppTheme.onSurfaceMuted,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 32),

                  // Círculo de porcentaje
                  CircularPercentIndicator(
                    radius: 80,
                    lineWidth: 10,
                    percent: r.score.clamp(0.0, 1.0),
                    center: Text(
                      r.scoreLabel,
                      style: const TextStyle(
                        color: AppTheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    backgroundColor: AppTheme.surfaceElevated,
                    linearGradient: r.isPerfect
                        ? AppTheme.xpGradient
                        : const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.accent],
                          ),
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 1000,
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                  const SizedBox(height: 32),

                  // Stats row
                  Row(
                    children: [
                      _ResultStat(
                        icon: '⚡',
                        value: '+${r.xpEarned} XP',
                        label: 'Ganados',
                        color: AppTheme.gold,
                      ),
                      _ResultStat(
                        icon: '⏱️',
                        value: _formatTime(r.timeSeconds),
                        label: 'Tiempo',
                        color: AppTheme.accent,
                      ),
                      _ResultStat(
                        icon: r.isPerfect ? '🎯' : '✅',
                        value: '${r.correctAnswers}/${r.totalQuestions}',
                        label: 'Correctas',
                        color: AppTheme.success,
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const Spacer(),

                  // Botones
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.popUntil(context, (r) => r.isFirst),
                          child: const Text('Continuar'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Repasar lección'),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }
}

class _ResultStat extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _ResultStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.onSurfaceMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
