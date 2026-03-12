// lib/services/lse_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sign.dart';

/// Servicio de acceso a la base de datos LSE-Sign (BCBL)
/// http://lse-sign.bcbl.eu/web-busqueda/
///
/// El portal usa WordPress + un plugin personalizado con llamadas AJAX.
/// Las peticiones de búsqueda se hacen via POST a wp-admin/admin-ajax.php
/// con action=buscar_signos y los parámetros de filtro.
class LseApiService {
  static const String _baseUrl = 'http://lse-sign.bcbl.eu/web-busqueda';
  static const String _ajaxUrl = '$_baseUrl/wp-admin/admin-ajax.php';
  static const String _videoBaseUrl = '$_baseUrl/wp-content/uploads/videos';

  // Sesión (requiere login para el portal)
  String? _sessionCookie;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  // ─── Autenticación ────────────────────────────────────────────────────────
  /// Login en el portal LSE-Sign con las credenciales del investigador
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/wp-login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'log': username,
          'pwd': password,
          'wp-submit': 'Acceder',
          'redirect_to': '/web-busqueda/?page_id=55',
          'testcookie': '1',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 302) {
        final cookies = response.headers['set-cookie'];
        if (cookies != null && cookies.contains('wordpress_logged_in')) {
          _sessionCookie = cookies;
          _isLoggedIn = true;
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ─── Búsqueda de signos ───────────────────────────────────────────────────
  /// Busca signos por texto libre
  Future<List<Sign>> searchSigns(String query, {int limit = 20}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest',
      };
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }

      final response = await http.post(
        Uri.parse(_ajaxUrl),
        headers: headers,
        body: {
          'action': 'buscar_signos',
          'busqueda': query,
          'limite': limit.toString(),
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return _parseSignsResponse(response.body);
      }
    } catch (e) {
      // En desarrollo: devolver datos de ejemplo
      return _getMockSigns(query);
    }
    return _getMockSigns(query);
  }

  /// Busca signos por categoría
  Future<List<Sign>> getSignsByCategory(String category, {int limit = 30}) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest',
      };
      if (_sessionCookie != null) headers['Cookie'] = _sessionCookie!;

      final response = await http.post(
        Uri.parse(_ajaxUrl),
        headers: headers,
        body: {
          'action': 'buscar_signos',
          'categoria': category,
          'limite': limit.toString(),
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return _parseSignsResponse(response.body);
      }
    } catch (_) {}
    return _getMockSignsByCategory(category);
  }

  /// Obtiene los signos de una lección concreta (por IDs)
  Future<List<Sign>> getSignsByIds(List<String> ids) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest',
      };
      if (_sessionCookie != null) headers['Cookie'] = _sessionCookie!;

      final response = await http.post(
        Uri.parse(_ajaxUrl),
        headers: headers,
        body: {
          'action': 'buscar_signos',
          'ids': ids.join(','),
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return _parseSignsResponse(response.body);
      }
    } catch (_) {}
    return [];
  }

  // ─── Construcción de URL de vídeo ─────────────────────────────────────────
  /// Construye la URL de vídeo para un signo dado su ID en la BD de BCBL
  String getVideoUrl(String signId) {
    return '$_videoBaseUrl/$signId.mp4';
  }

  // ─── Parsers ─────────────────────────────────────────────────────────────
  List<Sign> _parseSignsResponse(String body) {
    try {
      // El endpoint puede devolver JSON directamente o HTML con datos embedded
      if (body.trim().startsWith('[') || body.trim().startsWith('{')) {
        final dynamic decoded = jsonDecode(body);
        if (decoded is List) {
          return decoded
              .map((e) => Sign.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        if (decoded is Map && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((e) => Sign.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      // Fallback: parsear HTML
      return _parseSignsFromHtml(body);
    } catch (_) {
      return [];
    }
  }

  List<Sign> _parseSignsFromHtml(String html) {
    final signs = <Sign>[];
    // Extraer datos del HTML usando regex para patrones conocidos del portal
    final videoPattern = RegExp(
      r'<video[^>]*src="([^"]+)"[^>]*>',
      caseSensitive: false,
    );
    final wordPattern = RegExp(
      r'class="[^"]*signo[^"]*"[^>]*>([^<]+)<',
      caseSensitive: false,
    );

    final videoMatches = videoPattern.allMatches(html).toList();
    final wordMatches = wordPattern.allMatches(html).toList();

    for (var i = 0; i < videoMatches.length; i++) {
      signs.add(Sign(
        id: 'parsed_$i',
        word: i < wordMatches.length ? wordMatches[i].group(1)!.trim() : 'Signo ${i + 1}',
        videoUrl: videoMatches[i].group(1),
      ));
    }
    return signs;
  }

  // ─── Datos de demostración ────────────────────────────────────────────────
  /// Signos de ejemplo mientras no hay conexión o credenciales
  List<Sign> _getMockSigns(String query) {
    final all = _allMockSigns();
    if (query.isEmpty) return all.take(10).toList();
    final lower = query.toLowerCase();
    return all
        .where((s) => s.word.toLowerCase().contains(lower))
        .toList();
  }

  List<Sign> _getMockSignsByCategory(String category) {
    return _allMockSigns()
        .where((s) => s.category == category)
        .toList();
  }

  List<Sign> _allMockSigns() => [
    Sign(
      id: '1', word: 'Hola',
      videoUrl: '$_videoBaseUrl/1.mp4',
      category: 'Saludos y despedidas',
      difficulty: 'basico',
      definition: 'Saludo informal y cordial',
    ),
    Sign(
      id: '2', word: 'Adiós',
      videoUrl: '$_videoBaseUrl/2.mp4',
      category: 'Saludos y despedidas',
      difficulty: 'basico',
      definition: 'Despedida estándar',
    ),
    Sign(
      id: '3', word: 'Gracias',
      videoUrl: '$_videoBaseUrl/3.mp4',
      category: 'Saludos y despedidas',
      difficulty: 'basico',
      definition: 'Expresión de agradecimiento',
    ),
    Sign(
      id: '4', word: 'Por favor',
      videoUrl: '$_videoBaseUrl/4.mp4',
      category: 'Saludos y despedidas',
      difficulty: 'basico',
    ),
    Sign(
      id: '5', word: 'Sí',
      videoUrl: '$_videoBaseUrl/5.mp4',
      category: 'Saludos y despedidas',
      difficulty: 'basico',
    ),
    Sign(
      id: '6', word: 'No',
      videoUrl: '$_videoBaseUrl/6.mp4',
      category: 'Saludos y despedidas',
      difficulty: 'basico',
    ),
    Sign(
      id: '7', word: 'Te quiero',
      videoUrl: '$_videoBaseUrl/7.mp4',
      category: 'Emociones',
      difficulty: 'basico',
    ),
    Sign(
      id: '8', word: 'Feliz',
      videoUrl: '$_videoBaseUrl/8.mp4',
      category: 'Emociones',
      difficulty: 'basico',
    ),
    Sign(
      id: '9', word: 'Triste',
      videoUrl: '$_videoBaseUrl/9.mp4',
      category: 'Emociones',
      difficulty: 'basico',
    ),
    Sign(
      id: '10', word: 'Ayuda',
      videoUrl: '$_videoBaseUrl/10.mp4',
      category: 'Verbos cotidianos',
      difficulty: 'basico',
    ),
    Sign(
      id: '11', word: 'Madre',
      videoUrl: '$_videoBaseUrl/11.mp4',
      category: 'Familia',
      difficulty: 'basico',
    ),
    Sign(
      id: '12', word: 'Padre',
      videoUrl: '$_videoBaseUrl/12.mp4',
      category: 'Familia',
      difficulty: 'basico',
    ),
    Sign(
      id: '13', word: 'Hermano',
      videoUrl: '$_videoBaseUrl/13.mp4',
      category: 'Familia',
      difficulty: 'basico',
    ),
    Sign(
      id: '14', word: 'Uno',
      videoUrl: '$_videoBaseUrl/14.mp4',
      category: 'Números',
      difficulty: 'basico',
    ),
    Sign(
      id: '15', word: 'Dos',
      videoUrl: '$_videoBaseUrl/15.mp4',
      category: 'Números',
      difficulty: 'basico',
    ),
  ];
}
