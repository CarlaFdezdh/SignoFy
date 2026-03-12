// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      emoji: '🤟',
      title: 'Bienvenido a SignoFy',
      subtitle:
          'La app gamificada para aprender Lengua de Signos Española, gratis y sin límites.',
    ),
    _OnboardingPage(
      emoji: '🎮',
      title: 'Aprende jugando',
      subtitle:
          'Gana XP, mantén tu racha diaria y desbloquea insignias mientras aprendes LSE de forma natural.',
    ),
    _OnboardingPage(
      emoji: '🎥',
      title: 'Signos en vídeo',
      subtitle:
          'Todos los signos con vídeo real, de la base de datos oficial LSE-Sign del BCBL.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await context.read<AppProvider>().setUserName(name);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Indicadores de página
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: List.generate(
                  _pages.length + 1,
                  (i) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= _currentPage
                            ? AppTheme.primary
                            : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Páginas de introducción
                  ..._pages.map((p) => _PageContent(page: p)),

                  // Página final: nombre de usuario
                  _NamePage(controller: _nameController),
                ],
              ),
            ),

            // Botón de acción
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentPage < _pages.length ? _next : _finish,
                  child: Text(
                    _currentPage < _pages.length ? 'Siguiente' : 'Empezar a aprender',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(page.emoji, style: const TextStyle(fontSize: 96))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 32),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.onSurfaceMuted,
              fontSize: 16,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  const _NamePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👋', style: TextStyle(fontSize: 72))
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          const Text(
            '¿Cómo te llamamos?',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Solo para personalizar tu experiencia',
            style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 14),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: 'Tu nombre...',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
