// lib/widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/user_progress.dart';
import '../models/sign.dart';
import '../models/lesson.dart';

// ─── Barra de XP / Nivel ──────────────────────────────────────────────────────
class XpLevelBar extends StatelessWidget {
  final UserProgress progress;
  const XpLevelBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _LevelCircle(level: progress.level),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progress.levelTitle,
                      style: const TextStyle(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${progress.totalXP} XP',
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: progress.levelProgress.clamp(0.0, 1.0),
                  backgroundColor: AppTheme.surfaceElevated,
                  linearGradient: AppTheme.xpGradient,
                  barRadius: const Radius.circular(4),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 4),
                Text(
                  '${progress.xpForNextLevel - progress.totalXP} XP para nivel ${progress.level + 1}',
                  style: const TextStyle(
                    color: AppTheme.onSurfaceMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCircle extends StatelessWidget {
  final int level;
  const _LevelCircle({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$level',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ─── Chip de racha ────────────────────────────────────────────────────────────
class StreakChip extends StatelessWidget {
  final int streak;
  final bool compact;
  const StreakChip({super.key, required this.streak, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: AppTheme.streakGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔥',
            style: TextStyle(fontSize: compact ? 14 : 16),
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 13 : 15,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 2),
            const Text(
              'días',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tarjeta de lección ───────────────────────────────────────────────────────
class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;

  const LessonCard({super.key, required this.lesson, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLocked = lesson.status == LessonStatus.locked;
    final isCompleted = lesson.status == LessonStatus.completed;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCompleted
                  ? AppTheme.success.withOpacity(0.4)
                  : isLocked
                      ? Colors.transparent
                      : AppTheme.primary.withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              _LessonIcon(lesson: lesson, isLocked: isLocked),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        color: isLocked
                            ? AppTheme.onSurfaceMuted
                            : AppTheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.subtitle,
                      style: const TextStyle(
                        color: AppTheme.onSurfaceMuted,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isCompleted && lesson.lastScore != null) ...[
                      const SizedBox(height: 6),
                      _ScoreBar(score: lesson.lastScore!),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _LessonTrailing(
                lesson: lesson,
                isLocked: isLocked,
                isCompleted: isCompleted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonIcon extends StatelessWidget {
  final Lesson lesson;
  final bool isLocked;

  const _LessonIcon({required this.lesson, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: isLocked
            ? null
            : LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.8),
                  AppTheme.primaryLight.withOpacity(0.6),
                ],
              ),
        color: isLocked ? AppTheme.surfaceElevated : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          isLocked ? '🔒' : lesson.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _LessonTrailing extends StatelessWidget {
  final Lesson lesson;
  final bool isLocked;
  final bool isCompleted;

  const _LessonTrailing({
    required this.lesson,
    required this.isLocked,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return const Icon(Icons.lock_outline_rounded,
          color: AppTheme.onSurfaceMuted, size: 20);
    }
    if (isCompleted) {
      return Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppTheme.success, size: 22),
          const SizedBox(height: 4),
          Text(
            '+${lesson.xpReward}',
            style: const TextStyle(
              color: AppTheme.gold,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        const Icon(Icons.arrow_forward_ios_rounded,
            color: AppTheme.primary, size: 16),
        const SizedBox(height: 4),
        Text(
          '+${lesson.xpReward} XP',
          style: const TextStyle(
            color: AppTheme.gold,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final double score;
  const _ScoreBar({required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearPercentIndicator(
            lineHeight: 4,
            percent: score.clamp(0.0, 1.0),
            backgroundColor: AppTheme.surfaceElevated,
            progressColor: score == 1.0 ? AppTheme.gold : AppTheme.accent,
            barRadius: const Radius.circular(2),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(score * 100).round()}%',
          style: TextStyle(
            color: score == 1.0 ? AppTheme.gold : AppTheme.accent,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ─── Tarjeta de signo (diccionario) ──────────────────────────────────────────
class SignCard extends StatelessWidget {
  final Sign sign;
  final VoidCallback? onTap;

  const SignCard({super.key, required this.sign, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.surfaceElevated,
                      AppTheme.primary.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.sign_language_rounded,
                    size: 40,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sign.word,
                    style: const TextStyle(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sign.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sign.category!,
                      style: const TextStyle(
                        color: AppTheme.onSurfaceMuted,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

// ─── Banner de nueva insignia ─────────────────────────────────────────────────
class BadgeBanner extends StatelessWidget {
  final String badgeId;
  final VoidCallback onClose;

  const BadgeBanner({super.key, required this.badgeId, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final badge = BadgeCatalog.all().firstWhere(
      (b) => b.id == badgeId,
      orElse: () => AppBadge(
        id: badgeId,
        name: 'Nueva insignia',
        description: '¡Lo estás haciendo genial!',
        emoji: '🏅',
        type: AppBadgeType.special,
      ),
    );

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D1B69), AppTheme.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎉 ¡Nueva insignia!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  badge.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  badge.description,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
          ),
        ],
      ),
    ).animate().slideY(begin: -1, duration: 400.ms, curve: Curves.easeOutBack);
  }
}
