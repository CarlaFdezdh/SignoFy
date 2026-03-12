// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/lesson.dart';
import 'lesson_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.surface,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, provider),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge nueva insignia
                    if (provider.newBadgeId != null)
                      BadgeBanner(
                        badgeId: provider.newBadgeId!,
                        onClose: provider.clearNewBadge,
                      ),

                    _DailyGreeting(provider: provider),
                    const SizedBox(height: 16),
                    _StatsRow(provider: provider),
                    const SizedBox(height: 24),
                    _XpSection(provider: provider),
                    const SizedBox(height: 28),
                    _LessonOfDayBanner(provider: provider),
                    const SizedBox(height: 28),
                    _LessonsSection(provider: provider),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AppProvider provider) {
    return SliverAppBar(
      backgroundColor: AppTheme.surface,
      floating: true,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 8),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: const Text(
                  'Signo',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const Text(
                'Fy',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(' 🤟', style: TextStyle(fontSize: 22)),
              const Spacer(),
              StreakChip(streak: provider.progress.currentStreak),
            ],
          ),
        ),
      ),
      expandedHeight: 72,
    );
  }
}

// ─── Saludo diario ────────────────────────────────────────────────────────────
class _DailyGreeting extends StatelessWidget {
  final AppProvider provider;
  const _DailyGreeting({required this.provider});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_greeting()}, ${provider.userName} 👋',
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.05, duration: 400.ms),
          const SizedBox(height: 4),
          Text(
            provider.progress.studiedToday
                ? '¡Ya practicaste hoy! Sigue así 🔥'
                : '¡Hora de aprender algo nuevo!',
            style: const TextStyle(
              color: AppTheme.onSurfaceMuted,
              fontSize: 14,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ─── Fila de estadísticas ─────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final AppProvider provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final p = provider.progress;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatCard(
            label: 'Lecciones',
            value: '${p.lessonsCompleted}',
            icon: '📚',
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Perfectas',
            value: '${p.perfectLessons}',
            icon: '🎯',
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Liga',
            value: p.currentLeague!,
            icon: p.leagueEmoji,
            capitalize: true,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final bool capitalize;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.capitalize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              capitalize
                  ? '${value[0].toUpperCase()}${value.substring(1)}'
                  : value,
              style: const TextStyle(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 16,
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
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

// ─── Sección de XP ────────────────────────────────────────────────────────────
class _XpSection extends StatelessWidget {
  final AppProvider provider;
  const _XpSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: XpLevelBar(progress: provider.progress),
    );
  }
}

// ─── Banner "Lección del día" ─────────────────────────────────────────────────
class _LessonOfDayBanner extends StatelessWidget {
  final AppProvider provider;
  const _LessonOfDayBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    final nextLesson = provider.lessons.firstWhere(
      (l) => l.status == LessonStatus.available,
      orElse: () => provider.lessons.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _openLesson(context, nextLesson),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lección del día',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextLesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextLesson.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StartButton(lesson: nextLesson, onTap: () => _openLesson(context, nextLesson)),
                ],
              ),
              const Spacer(),
              Text(
                nextLesson.emoji,
                style: const TextStyle(fontSize: 56),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.05, duration: 500.ms);
  }

  void _openLesson(BuildContext context, Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson)),
    );
  }
}

class _StartButton extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const _StartButton({required this.lesson, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            lesson.status == LessonStatus.completed
                ? 'Repasar'
                : 'Empezar',
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppTheme.primaryDark,
            size: 16,
          ),
        ],
      ),
    );
  }
}

// ─── Lista de lecciones ───────────────────────────────────────────────────────
class _LessonsSection extends StatelessWidget {
  final AppProvider provider;
  const _LessonsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Todas las lecciones',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...provider.lessons.asMap().entries.map(
          (entry) => LessonCard(
            lesson: entry.value,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LessonScreen(lesson: entry.value),
              ),
            ),
          )
              .animate(delay: (entry.key * 60).ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.05),
        ),
      ],
    );
  }
}
