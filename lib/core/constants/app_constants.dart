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

  // ── Roles (uuid) ─────────────────────────────────────────────────
  // NOTA: El backend usa GUIDs para los roles. Sustituye estos valores por
  // los identificadores reales devueltos por `/api/Rol/GetAll`.
  static const String roleCoachId = '00000000-0000-0000-0000-000000000002';
  static const String roleAthleteId = '00000000-0000-0000-0000-000000000003';
}
