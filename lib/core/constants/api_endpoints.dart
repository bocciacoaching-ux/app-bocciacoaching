/// Endpoints de la API centralizados.
abstract final class ApiEndpoints {
  // ── Auth ─────────────────────────────────────────────────────────
  static const String login = '/User/login';
  static const String register = '/User/register';
  static const String logout = '/User/logout';

  // ── User ─────────────────────────────────────────────────────────
  static const String userProfile = '/User/profile';
  static const String changePassword = '/User/change-password';

  // ── Teams ────────────────────────────────────────────────────────
  static const String teams = '/Team';
  static const String teamMembers = '/Team/members';

  // ── Athletes ─────────────────────────────────────────────────────
  static const String athletes = '/Athlete';

  // ── Evaluations ──────────────────────────────────────────────────
  static const String evaluations = '/Evaluation';
  static const String forceTest = '/Evaluation/force-test';

  // ── Statistics ───────────────────────────────────────────────────
  static const String statistics = '/Statistics';

  // ── Notifications ────────────────────────────────────────────────
  static const String notifications = '/Notification';
}
