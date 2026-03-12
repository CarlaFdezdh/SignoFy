// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../providers/app_provider.dart';
import '../models/user_progress.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final p = provider.progress;
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: CustomScrollView(
            slivers: [
              _ProfileAppBar(
                  userName: provider.userName, progress: p, provider: provider),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: XpLevelBar(progress: p),
                    ),
                    const SizedBox(height: 20),
                    _StatsGrid(progress: p),
                    const SizedBox(height: 24),
                    _BadgesSection(progress: p),
                    const SizedBox(height: 24),
                    _SettingsSection(provider: provider),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── AppBar de perfil ─────────────────────────────────────────────────────────
class _ProfileAppBar extends StatelessWidget {
  final String userName;
  final UserProgress progress;
  final AppProvider provider;

  const _ProfileAppBar({
    required this.userName,
    required this.progress,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.surface,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryDark, AppTheme.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty
                          ? userName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    color: AppTheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${progress.leagueEmoji} Liga ${progress.currentLeague!}',
                      style: const TextStyle(
                        color: AppTheme.onSurfaceMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    StreakChip(streak: progress.currentStreak, compact: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Grid de estadísticas ─────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final UserProgress progress;
  const _StatsGrid({required this.progress});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _Stat('📚', 'Lecciones', '${progress.lessonsCompleted}'),
      _Stat('🎯', 'Perfectas', '${progress.perfectLessons}'),
      _Stat('🔥', 'Mayor racha', '${progress.longestStreak} días'),
      _Stat('⚡', 'XP semana', '${progress.weeklyXP}'),
      _Stat('🏅', 'Nivel', '${progress.level} · ${progress.levelTitle}'),
      _Stat('💎', 'Total XP', '${progress.totalXP}'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemCount: stats.length,
        itemBuilder: (context, i) => _StatBox(stat: stats[i], index: i),
      ),
    );
  }
}

class _Stat {
  final String icon;
  final String label;
  final String value;
  const _Stat(this.icon, this.label, this.value);
}

class _StatBox extends StatelessWidget {
  final _Stat stat;
  final int index;

  const _StatBox({required this.stat, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(stat.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: const TextStyle(
              color: AppTheme.onSurfaceMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.85, 0.85));
  }
}

// ─── Insignias ────────────────────────────────────────────────────────────────
class _BadgesSection extends StatelessWidget {
  final UserProgress progress;
  const _BadgesSection({required this.progress});

  @override
  Widget build(BuildContext context) {
    final badges = BadgeCatalog.all();
    final unlocked = progress.unlockedBadgeIds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Insignias',
                style: TextStyle(
                  color: AppTheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${unlocked.length}/${badges.length}',
                style: const TextStyle(
                  color: AppTheme.onSurfaceMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final badge = badges[i];
              final isUnlocked = unlocked.contains(badge.id);
              return _BadgeItem(badge: badge, isUnlocked: isUnlocked);
            },
          ),
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final AppBadge badge;
  final bool isUnlocked;

  const _BadgeItem({required this.badge, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: badge.description,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppTheme.primary.withOpacity(0.15)
                  : AppTheme.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(
                color: isUnlocked
                    ? AppTheme.primary.withOpacity(0.5)
                    : AppTheme.onSurfaceMuted.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                badge.emoji,
                style: TextStyle(
                  fontSize: 26,
                  color: isUnlocked ? null : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(
              badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isUnlocked
                    ? AppTheme.onSurface
                    : AppTheme.onSurfaceMuted,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ajustes ──────────────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final AppProvider provider;
  const _SettingsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajustes',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Cambiar nombre',
            onTap: () => _showEditName(context, provider),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Credenciales LSE-Sign (BCBL)',
            subtitle: provider.apiService.isLoggedIn
                ? 'Conectado ✓'
                : 'No conectado',
            onTap: () => _showApiLogin(context, provider),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Acerca de SignoFy',
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }

  void _showEditName(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Tu nombre', style: TextStyle(color: AppTheme.onSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.onSurface),
          decoration: const InputDecoration(hintText: 'Escribe tu nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setUserName(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showApiLogin(BuildContext context, AppProvider provider) {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('LSE-Sign BCBL',
            style: TextStyle(color: AppTheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Conecta con tu cuenta de investigador de lse-sign.bcbl.eu para acceder a todos los vídeos y signos.',
              style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(hintText: 'Usuario'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok =
                  await provider.loginToApi(userCtrl.text, passCtrl.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? '✅ Conectado correctamente' : '❌ Error al conectar'),
                  backgroundColor: ok ? AppTheme.success : AppTheme.error,
                ));
              }
            },
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SignoFy',
      applicationVersion: '0.1.0 beta',
      applicationLegalese:
          'Datos LSE-Sign: © BCBL (Basque Center on Cognition, Brain and Language)\n\nApp creada con Flutter · Proyecto en desarrollo',
      children: [
        const SizedBox(height: 12),
        const Text(
          'SignoFy es una app gratuita y gamificada para aprender Lengua de Signos Española (LSE).',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(
                  color: AppTheme.onSurfaceMuted, fontSize: 12))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppTheme.onSurfaceMuted),
      onTap: onTap,
    );
  }
}
