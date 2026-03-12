# SignoFy 🤟

**App gamificada para aprender Lengua de Signos Española (LSE), gratis.**

> Proyecto en desarrollo activo · Flutter + Dart

---

## 🏗️ Arquitectura del proyecto

```
lib/
├── main.dart                    # Entrada de la app
├── app.dart                     # MaterialApp + router + Provider
├── theme/
│   └── app_theme.dart           # Paleta, tipografía, ThemeData
├── models/
│   ├── sign.dart                # Modelo de signo LSE
│   ├── lesson.dart              # Lecciones, ejercicios, resultados
│   └── user_progress.dart       # XP, rachas, insignias, nivel
├── services/
│   ├── lse_api_service.dart     # Integración con LSE-Sign (BCBL)
│   └── progress_service.dart   # Persistencia local (SharedPreferences)
├── providers/
│   └── app_provider.dart        # Estado global (ChangeNotifier)
├── screens/
│   ├── main_scaffold.dart       # Nav inferior + IndexedStack
│   ├── home_screen.dart         # Dashboard, lección del día
│   ├── lesson_screen.dart       # Quiz de signos con vídeo
│   ├── results_screen.dart      # Pantalla de resultados + XP
│   ├── dictionary_screen.dart   # Diccionario visual con búsqueda
│   ├── sign_detail_screen.dart  # Detalle de un signo
│   ├── profile_screen.dart      # Perfil, insignias, estadísticas
│   └── onboarding_screen.dart   # Flujo de bienvenida
└── widgets/
    └── common_widgets.dart      # XpLevelBar, StreakChip, LessonCard...
```

---

## ⚙️ Instalación y primeros pasos

### Requisitos
- Flutter SDK ≥ 3.0
- Dart ≥ 3.0
- Android Studio / VS Code con plugin Flutter

### 1. Clonar y dependencias

```bash
cd signofy
flutter pub get
```

### 2. Ejecutar

```bash
flutter run
```

### 3. Compilar para producción

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 🔗 Integración con LSE-Sign BCBL

La base de datos de signos proviene del portal oficial:
**http://lse-sign.bcbl.eu/web-busqueda/**

### Autenticación
El portal requiere credenciales de investigador. Desde la app:
1. Ve a **Perfil → Credenciales LSE-Sign (BCBL)**
2. Introduce tu usuario y contraseña del portal
3. La sesión se reutiliza en todas las búsquedas y vídeos

### Datos disponibles por signo
- `word` — Palabra en español
- `videoUrl` — URL del vídeo del signo
- `category` — Categoría temática
- `difficulty` — Nivel (básico / intermedio / avanzado)
- `definition` — Definición
- `grammaticalType` — Tipo gramatical (sustantivo, verbo...)
- `location` — Localización corporal
- `movement` — Descripción del movimiento
- `isTwoHanded` — Si es bimanual
- `synonyms` — Sinónimos / variantes

### Sin credenciales
La app funciona con datos de demostración (15 signos de ejemplo) para permitir desarrollo y pruebas sin necesidad de acceso al portal.

---

## 🎮 Sistema de gamificación

### XP y Niveles
| Nivel | XP requerido | Título |
|-------|-------------|--------|
| 1     | 0           | Aprendiz |
| 2     | 100         | Aprendiz |
| 3     | 300         | Estudiante |
| 5     | 1.000       | Comunicador |
| 7     | 2.200       | Intérprete |
| 10+   | 5.500+      | Maestro LSE |

### Ligas
- 🥉 **Bronce** — 0–499 XP
- 🥈 **Plata** — 500–1.999 XP
- 🥇 **Oro** — 2.000–4.999 XP
- 💎 **Diamante** — 5.000+ XP

### Insignias (12 desbloqueables)
- Rachas: 3, 7 y 30 días
- XP: 100, 500, 1.000
- Lecciones: 1, 10, 25
- Perfectas: 5 lecciones sin errores
- Categorías: Maestro de saludos, Maestro de números

---

## 📋 Roadmap de desarrollo

### v0.1 (actual)
- [x] Arquitectura base
- [x] Sistema de XP, niveles, rachas
- [x] 12 insignias
- [x] 10 lecciones precargadas
- [x] Diccionario con búsqueda y filtro por categoría
- [x] Integración API LSE-Sign BCBL
- [x] Onboarding
- [x] Persistencia local

### v0.2 (próximo)
- [ ] Reproductor de vídeo integrado (chewie + video_player)
- [ ] Modo sin conexión (descarga de lecciones)
- [ ] Más tipos de ejercicio: completar frase, ordenar signos
- [ ] Recordatorios diarios (local notifications)
- [ ] Compartir progreso

### v0.3
- [ ] Liga semanal con ranking
- [ ] Retos semanales
- [ ] Modo repaso (spaced repetition)

### v1.0
- [ ] Reconocimiento de signos con IA (cámara)
- [ ] Modo comunidad

---

## 🤝 Créditos

- **Datos LSE**: LSE-Sign · BCBL (Basque Center on Cognition, Brain and Language) + Fundación CNSE
- **App**: Proyecto SignoFy · Carla Fernández
- **Framework**: Flutter / Dart

---

*Hecho con mucha ilusión 🤟*
