import 'package:flutter/foundation.dart';
import '../models/training_session.dart';
import '../../core/services/training_session_service.dart';

/// Provider que gestiona las sesiones planificadas para un atleta.
///
/// Utiliza el endpoint `POST /api/TrainingSession/Athlete/GetSessionsByDateRange`
/// para obtener las sesiones en un solo request, en lugar de iterar
/// macrociclos → microciclos → sesiones (N+1).
class AthleteSessionProvider extends ChangeNotifier {
  final TrainingSessionService _sessionService = TrainingSessionService();

  List<AthleteSessionSummary> _sessions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────

  List<AthleteSessionSummary> get sessions =>
      List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSessions => _sessions.isNotEmpty;

  /// Sesiones futuras ordenadas por fecha (la más próxima primero).
  List<AthleteSessionSummary> get upcomingSessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _sessions
        .where((s) {
          final d = scheduledDateOf(s);
          return !d.isBefore(today) && s.isPending;
        })
        .toList()
      ..sort((a, b) =>
          scheduledDateOf(a).compareTo(scheduledDateOf(b)));
  }

  /// Sesiones para un día específico.
  List<AthleteSessionSummary> sessionsForDay(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _sessions.where((s) {
      final d = scheduledDateOf(s);
      return d.year == day.year &&
          d.month == day.month &&
          d.day == day.day;
    }).toList();
  }

  /// Días que tienen sesiones programadas (para marcar en el calendario).
  Set<DateTime> get daysWithSessions {
    return _sessions
        .map((s) {
          final d = scheduledDateOf(s);
          return DateTime(d.year, d.month, d.day);
        })
        .toSet();
  }

  // ── Cargar sesiones del atleta ─────────────────────────────────────

  /// Carga las sesiones planificadas para un atleta en un rango de
  /// fechas amplio (por defecto, ±6 meses desde hoy).
  Future<void> loadAthletesSessions(int athleteId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final start = startDate ?? DateTime(now.year - 1, now.month, now.day);
      final end = endDate ?? DateTime(now.year + 1, now.month, now.day);

      final result = await _sessionService.getAthleteSessionsByDateRange(
        athleteId: athleteId,
        startDate: start,
        endDate: end,
      );

      if (result != null) {
        _sessions = result;
        // Ordenar por fecha calculada
        _sessions.sort((a, b) =>
            scheduledDateOf(a).compareTo(scheduledDateOf(b)));
      } else {
        _sessions = [];
      }
    } catch (e) {
      debugPrint('[AthleteSessionProvider] loadAthletesSessions error: $e');
      _errorMessage = 'Error al cargar las sesiones: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Iniciar / Finalizar sesión ─────────────────────────────────────

  /// Un atleta inicia una sesión de entrenamiento.
  Future<bool> startSession({
    required int trainingSessionId,
    required int athleteId,
  }) async {
    try {
      final result = await _sessionService.athleteStartSession(
        trainingSessionId: trainingSessionId,
        athleteId: athleteId,
      );
      if (result != null) {
        // Recargar para actualizar el estado
        await loadAthletesSessions(athleteId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[AthleteSessionProvider] startSession error: $e');
      return false;
    }
  }

  /// Un atleta finaliza una sesión de entrenamiento.
  Future<bool> finishSession({
    required int trainingSessionId,
    required int athleteId,
  }) async {
    try {
      final result = await _sessionService.athleteFinishSession(
        trainingSessionId: trainingSessionId,
        athleteId: athleteId,
      );
      if (result != null) {
        // Recargar para actualizar el estado
        await loadAthletesSessions(athleteId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[AthleteSessionProvider] finishSession error: $e');
      return false;
    }
  }

  // ── Helpers de cálculo de fecha ────────────────────────────────────

  /// Calcula la fecha programada de una sesión a partir del inicio
  /// del microciclo y el día de la semana indicado.
  static DateTime scheduledDateOf(AthleteSessionSummary session) {
    final microStart = session.microcycleStartDate;
    if (microStart == null) {
      return session.createdAt ?? DateTime.now();
    }
    final offset = _dayOfWeekOffset(session.dayOfWeek);
    return microStart.add(Duration(days: offset));
  }

  /// Offset en días desde lunes (0) hasta domingo (6).
  static int _dayOfWeekOffset(String? day) {
    if (day == null) return 0;
    switch (day.toLowerCase()) {
      case 'lunes':
        return 0;
      case 'martes':
        return 1;
      case 'miercoles':
      case 'miércoles':
        return 2;
      case 'jueves':
        return 3;
      case 'viernes':
        return 4;
      case 'sabado':
      case 'sábado':
        return 5;
      case 'domingo':
        return 6;
      default:
        return 0;
    }
  }

  /// Limpia todo el estado.
  void clear() {
    _sessions = [];
    _errorMessage = null;
    notifyListeners();
  }
}
