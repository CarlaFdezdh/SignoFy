// lib/screens/dictionary_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/app_provider.dart';
import '../models/sign.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'sign_detail_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  List<Sign> _signs = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadSigns('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadSigns(value);
    });
  }

  Future<void> _loadSigns(String query) async {
    setState(() => _isLoading = true);
    final provider = context.read<AppProvider>();
    List<Sign> results;

    if (_selectedCategory != 'Todos') {
      results = await provider.getSignsByCategory(_selectedCategory);
      if (query.isNotEmpty) {
        results = results
            .where((s) => s.word.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    } else {
      results = await provider.searchSigns(query);
    }

    if (mounted) {
      setState(() {
        _signs = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            _SearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
            _CategoryFilter(
              selected: _selectedCategory,
              onChanged: (cat) {
                setState(() => _selectedCategory = cat);
                _loadSigns(_searchController.text);
              },
            ),
            Expanded(
              child: _isLoading
                  ? _ShimmerGrid()
                  : _signs.isEmpty
                      ? _EmptySearch(query: _searchController.text)
                      : _SignsGrid(signs: _signs),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diccionario LSE',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Base de datos BCBL · ${SignCategories.all.length} categorías',
            style: const TextStyle(
              color: AppTheme.onSurfaceMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppTheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Buscar un signo...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.onSurfaceMuted),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppTheme.onSurfaceMuted),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategoryFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final categories = ['Todos', ...SignCategories.all];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          final emoji = cat == 'Todos'
              ? '🔍'
              : SignCategories.icons[cat] ?? '📖';

          return GestureDetector(
            onTap: () => onChanged(cat),
            child: AnimatedContainer(
              duration: 200.ms,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.onSurfaceMuted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SignsGrid extends StatelessWidget {
  final List<Sign> signs;
  const _SignsGrid({required this.signs});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: signs.length,
      itemBuilder: (context, i) => SignCard(
        sign: signs[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SignDetailScreen(sign: signs[i]),
          ),
        ),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppTheme.surfaceCard,
        highlightColor: AppTheme.surfaceElevated,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            query.isEmpty
                ? 'Escribe para buscar un signo'
                : 'No se encontraron resultados\npara "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
