import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_session.dart';
import 'team_provider.dart';
import 'statistics_provider.dart';

/// Representa un paso del onboarding mostrado en el dashboard.
class OnboardingStep {
  final String id;
  final String title;
  final String subtitle;
  final bool completed;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.completed,
  });
}

/// Estado de onboarding del usuario actual.
///
/// Persiste banderas básicas (intro vista, "recordar más tarde") y deriva
/// el estado de los pasos a partir de los providers existentes
/// ([TeamProvider], [StatisticsProvider]) sin duplicar fuentes de verdad.
class OnboardingProvider extends ChangeNotifier {
  static const _kIntroSeenPrefix = 'onboarding.introSeen.';
  static const _kRemindLaterPrefix = 'onboarding.remindLater.';

  bool _introSeen = false;
  bool _remindLater = false;
  int? _userId;

  bool get introSeen => _introSeen;
  bool get remindLater => _remindLater;
  int? get userId => _userId;

  /// Carga las banderas para el usuario indicado.
  Future<void> loadFor(int userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    _introSeen = prefs.getBool('$_kIntroSeenPrefix$userId') ?? false;
    _remindLater = prefs.getBool('$_kRemindLaterPrefix$userId') ?? false;
    notifyListeners();
  }

  /// Marca la introducción (carrusel de bienvenida) como vista.
  Future<void> markIntroSeen() async {
    _introSeen = true;
    final id = _userId;
    if (id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_kIntroSeenPrefix$id', true);
    }
    notifyListeners();
  }

  /// Marca la opción «Recordar más tarde» (oculta la intro temporalmente).
  Future<void> setRemindLater(bool value) async {
    _remindLater = value;
    final id = _userId;
    if (id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_kRemindLaterPrefix$id', value);
    }
    notifyListeners();
  }

  /// Limpia el estado al cerrar sesión.
  void clear() {
    _userId = null;
    _introSeen = false;
    _remindLater = false;
    notifyListeners();
  }

  // ── Derivación de pasos ──────────────────────────────────────────────

  /// Devuelve los pasos del onboarding según el rol del [session].
  List<OnboardingStep> stepsFor({
    required UserSession session,
    required TeamProvider teamProvider,
    required StatisticsProvider statsProvider,
  }) {
    if (session.isAthlete) {
      return _athleteSteps(session, teamProvider, statsProvider);
    }
    return _coachSteps(session, teamProvider, statsProvider);
  }

  List<OnboardingStep> _coachSteps(
    UserSession session,
    TeamProvider tp,
    StatisticsProvider sp,
  ) {
    final hasTeam = tp.teams.isNotEmpty;
    final hasAthletes = tp.members.isNotEmpty ||
        tp.teams.any((t) => t.memberCount > 0);
    final totalEvals =
        (sp.dashboardIndicators?['totalEvaluations'] as num?)?.toInt() ?? 0;
    final hasEvaluation = totalEvals > 0;

    return [
      OnboardingStep(
        id: 'account',
        title: 'Crear tu cuenta',
        subtitle: 'Ya tienes tu perfil de coach activo',
        completed: true,
      ),
      OnboardingStep(
        id: 'team',
        title: 'Configurar tu equipo',
        subtitle: hasTeam
            ? 'Tu equipo ya está creado'
            : 'Personaliza los datos del equipo',
        completed: hasTeam,
      ),
      OnboardingStep(
        id: 'athletes',
        title: 'Agregar atletas',
        subtitle: hasAthletes
            ? 'Ya tienes atletas registrados'
            : 'Registra a tus atletas para evaluar',
        completed: hasAthletes,
      ),
      OnboardingStep(
        id: 'evaluation',
        title: 'Realizar tu primera evaluación',
        subtitle: hasEvaluation
            ? 'Ya registraste tu primera evaluación'
            : 'Mide el rendimiento de tus atletas',
        completed: hasEvaluation,
      ),
    ];
  }

  List<OnboardingStep> _athleteSteps(
    UserSession session,
    TeamProvider tp,
    StatisticsProvider sp,
  ) {
    final hasTeam = tp.teams.isNotEmpty;
    final profileReady =
        (session.image != null && session.image!.isNotEmpty) ||
            (session.country != null && session.country!.isNotEmpty);
    final totalEvals =
        (sp.athleteDashboard?['totalEvaluations'] as num?)?.toInt() ?? 0;
    final hasEvaluation = totalEvals > 0;

    return [
      OnboardingStep(
        id: 'account',
        title: 'Crear tu cuenta',
        subtitle: 'Tu perfil de deportista está activo',
        completed: true,
      ),
      OnboardingStep(
        id: 'team',
        title: 'Únete a tu primer equipo',
        subtitle: hasTeam
            ? 'Ya formas parte de un equipo'
            : 'Acepta la invitación de tu entrenador',
        completed: hasTeam,
      ),
      OnboardingStep(
        id: 'profile',
        title: 'Completa tu perfil',
        subtitle: profileReady
            ? 'Tu información personal está lista'
            : 'Añade tu foto y datos personales',
        completed: profileReady,
      ),
      OnboardingStep(
        id: 'evaluation',
        title: 'Realiza tu primera evaluación',
        subtitle: hasEvaluation
            ? 'Ya completaste tu primera evaluación'
            : 'Responde la auto-evaluación SAREMAS',
        completed: hasEvaluation,
      ),
    ];
  }

  /// Cantidad de pasos completados.
  int completedCount(List<OnboardingStep> steps) =>
      steps.where((s) => s.completed).length;

  /// Progreso 0..1
  double progress(List<OnboardingStep> steps) {
    if (steps.isEmpty) return 0;
    return completedCount(steps) / steps.length;
  }

  /// `true` cuando todos los pasos están completados.
  bool isComplete(List<OnboardingStep> steps) =>
      steps.isNotEmpty && completedCount(steps) == steps.length;
}
