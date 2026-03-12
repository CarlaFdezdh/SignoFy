# SignoFy ProGuard rules

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mantener modelos de datos (para JSON serialization)
-keep class com.signofy.signofy.** { *; }

# OkHttp / http package
-dontwarn okhttp3.**
-dontwarn okio.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# video_player
-keep class androidx.media.** { *; }

# Shared preferences
-keep class androidx.datastore.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
