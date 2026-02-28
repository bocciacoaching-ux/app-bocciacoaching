## Flutter / R8 rules ──────────────────────────────────────────────
# Mantener clases de Flutter que se llaman por reflexión.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# local_auth
-keep class androidx.biometric.** { *; }

# Suprimir advertencias comunes
-dontwarn io.flutter.embedding.**
-dontwarn android.security.**
