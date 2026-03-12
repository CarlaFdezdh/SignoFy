// lib/models/sign.dart
class Sign {
  final String id;
  final String word;
  final String? videoUrl;
  final String? imageUrl;
  final String? definition;
  final String? category;
  final String? subcategory;
  final String? difficulty; // 'basico', 'intermedio', 'avanzado'
  final List<String>? synonyms;
  final String? grammaticalType; // sustantivo, verbo, adjetivo...
  final bool? isTwoHanded;
  final String? location; // localización corporal del signo
  final String? movement;

  const Sign({
    required this.id,
    required this.word,
    this.videoUrl,
    this.imageUrl,
    this.definition,
    this.category,
    this.subcategory,
    this.difficulty,
    this.synonyms,
    this.grammaticalType,
    this.isTwoHanded,
    this.location,
    this.movement,
  });

  factory Sign.fromJson(Map<String, dynamic> json) {
    return Sign(
      id: json['id']?.toString() ?? '',
      word: json['palabra'] ?? json['word'] ?? json['nombre'] ?? '',
      videoUrl: _buildVideoUrl(json),
      imageUrl: json['imagen'] ?? json['image_url'],
      definition: json['definicion'] ?? json['definition'],
      category: json['categoria'] ?? json['category'],
      subcategory: json['subcategoria'],
      difficulty: json['nivel'] ?? json['difficulty'],
      synonyms: json['sinonimos'] != null
          ? List<String>.from(json['sinonimos'])
          : null,
      grammaticalType: json['tipo_gramatical'],
      isTwoHanded: json['bimanual'] == '1' || json['bimanual'] == true,
      location: json['localizacion'],
      movement: json['movimiento'],
    );
  }

  static String? _buildVideoUrl(Map<String, dynamic> json) {
    // LSE-Sign BCBL usa URLs del tipo:
    // http://lse-sign.bcbl.eu/web-busqueda/wp-content/uploads/videos/{id}.mp4
    final rawUrl = json['video'] ?? json['video_url'] ?? json['videoUrl'];
    if (rawUrl != null) return rawUrl.toString();
    final id = json['id']?.toString();
    if (id != null && id.isNotEmpty) {
      return 'http://lse-sign.bcbl.eu/web-busqueda/wp-content/uploads/videos/$id.mp4';
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word,
    'videoUrl': videoUrl,
    'imageUrl': imageUrl,
    'definition': definition,
    'category': category,
    'difficulty': difficulty,
  };

  Sign copyWith({String? difficulty}) => Sign(
    id: id,
    word: word,
    videoUrl: videoUrl,
    imageUrl: imageUrl,
    definition: definition,
    category: category,
    subcategory: subcategory,
    difficulty: difficulty ?? this.difficulty,
    synonyms: synonyms,
    grammaticalType: grammaticalType,
    isTwoHanded: isTwoHanded,
    location: location,
    movement: movement,
  );
}

// Categorías de signos disponibles en LSE-Sign
class SignCategories {
  static const List<String> all = [
    'Saludos y despedidas',
    'Familia',
    'Números',
    'Colores',
    'Días y meses',
    'Alimentos',
    'Animales',
    'Cuerpo humano',
    'Emociones',
    'Verbos cotidianos',
    'Preguntas',
    'Lugares',
    'Transporte',
    'Ropa',
    'Profesiones',
    'Naturaleza',
    'Tiempo meteorológico',
    'Tecnología',
    'Salud',
    'Educación',
  ];

  static const Map<String, String> icons = {
    'Saludos y despedidas': '👋',
    'Familia': '👨‍👩‍👧‍👦',
    'Números': '🔢',
    'Colores': '🎨',
    'Días y meses': '📅',
    'Alimentos': '🍎',
    'Animales': '🐾',
    'Cuerpo humano': '💪',
    'Emociones': '😊',
    'Verbos cotidianos': '⚡',
    'Preguntas': '❓',
    'Lugares': '📍',
    'Transporte': '🚌',
    'Ropa': '👕',
    'Profesiones': '💼',
    'Naturaleza': '🌿',
    'Tiempo meteorológico': '☀️',
    'Tecnología': '💻',
    'Salud': '❤️‍🩹',
    'Educación': '📚',
  };
}
