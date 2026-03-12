// lib/screens/sign_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/sign.dart';
import '../theme/app_theme.dart';

class SignDetailScreen extends StatelessWidget {
  final Sign sign;
  const SignDetailScreen({super.key, required this.sign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(sign.word),
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video / imagen del signo
            _VideoSection(sign: sign),
            const SizedBox(height: 24),

            // Nombre y categoría
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sign.word,
                        style: const TextStyle(
                          color: AppTheme.onSurface,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (sign.category != null)
                        Text(
                          sign.category!,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (sign.difficulty != null)
                  _DifficultyBadge(difficulty: sign.difficulty!),
              ],
            ).animate().fadeIn(duration: 300.ms),

            if (sign.definition != null) ...[
              const SizedBox(height: 20),
              _InfoCard(
                icon: '📖',
                title: 'Definición',
                content: sign.definition!,
              ),
            ],

            const SizedBox(height: 16),
            _SignProperties(sign: sign),

            if (sign.synonyms != null && sign.synonyms!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SynonymsCard(synonyms: sign.synonyms!),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _VideoSection extends StatelessWidget {
  final Sign sign;
  const _VideoSection({required this.sign});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceElevated,
            AppTheme.primary.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          // Contenido (placeholder o vídeo real)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sign_language_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                if (sign.videoUrl != null)
                  ElevatedButton.icon(
                    onPressed: () {/* TODO: VideoPlayerScreen */},
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Ver el signo en vídeo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  )
                else
                  const Text(
                    'Vídeo próximamente',
                    style: TextStyle(
                      color: AppTheme.onSurfaceMuted,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          // Chip BCBL attribution
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'LSE-Sign · BCBL',
                style: TextStyle(
                  color: AppTheme.onSurfaceMuted,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.95, 0.95),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  const _DifficultyBadge({required this.difficulty});

  Color get _color {
    switch (difficulty.toLowerCase()) {
      case 'basico':
        return AppTheme.success;
      case 'intermedio':
        return AppTheme.warning;
      case 'avanzado':
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        difficulty[0].toUpperCase() + difficulty.substring(1),
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.onSurfaceMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }
}

class _SignProperties extends StatelessWidget {
  final Sign sign;
  const _SignProperties({required this.sign});

  @override
  Widget build(BuildContext context) {
    final props = <Map<String, String>>[];

    if (sign.grammaticalType != null) {
      props.add({'label': 'Tipo gramatical', 'value': sign.grammaticalType!});
    }
    if (sign.location != null) {
      props.add({'label': 'Localización', 'value': sign.location!});
    }
    if (sign.movement != null) {
      props.add({'label': 'Movimiento', 'value': sign.movement!});
    }
    if (sign.isTwoHanded != null) {
      props.add({
        'label': 'Bimanual',
        'value': sign.isTwoHanded! ? 'Sí' : 'No',
      });
    }

    if (props.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Características del signo',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: props
              .map((p) => _PropChip(label: p['label']!, value: p['value']!))
              .toList(),
        ),
      ],
    );
  }
}

class _PropChip extends StatelessWidget {
  final String label;
  final String value;

  const _PropChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SynonymsCard extends StatelessWidget {
  final List<String> synonyms;
  const _SynonymsCard({required this.synonyms});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'También se conoce como',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: synonyms
              .map(
                (s) => Chip(
                  label: Text(s),
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                  labelStyle: const TextStyle(
                    color: AppTheme.primaryLight,
                    fontSize: 13,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
