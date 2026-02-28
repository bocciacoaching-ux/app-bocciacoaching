/// Constantes globales de la aplicación.
abstract final class AppConstants {
  // ── API ──────────────────────────────────────────────────────────
  static const String baseUrl = 'https://bocciacoachingapi.onrender.com/api';

  // ── Almacenamiento ───────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // ── Timeouts ─────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── App Info ─────────────────────────────────────────────────────
  static const String appName = 'Boccia Coaching App';
  static const String appVersion = '1.0.0';
}
