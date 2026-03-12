// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_provider.dart';
import 'screens/main_scaffold.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

class SignofyApp extends StatelessWidget {
  const SignofyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(),
      child: MaterialApp(
        title: 'SignoFy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _AppEntry(),
        routes: {
          '/home': (_) => const MainScaffold(),
          '/onboarding': (_) => const OnboardingScreen(),
        },
      ),
    );
  }
}

/// Decide si mostrar onboarding o la app principal
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool? _hasOnboarded;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    setState(() => _hasOnboarded = name != null && name.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasOnboarded == null) {
      return const Scaffold(
        backgroundColor: AppTheme.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🤟', style: TextStyle(fontSize: 64)),
              SizedBox(height: 16),
              CircularProgressIndicator(color: AppTheme.primary),
            ],
          ),
        ),
      );
    }
    return _hasOnboarded! ? const MainScaffold() : const OnboardingScreen();
  }
}
