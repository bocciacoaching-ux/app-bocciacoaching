import 'package:flutter/foundation.dart';
import '../../core/services/assess_strength_service.dart';
import '../../core/services/statistics_service.dart';

enum StatsLoadingStatus { idle, loading, success, error }

class StatisticsProvider extends ChangeNotifier {
  final AssessStrengthService _service = AssessStrengthService();
  final StatisticsService _statisticsService = StatisticsService();

  // ── Estado de evaluaciones del equipo ──────────────────────────────
  List<Map<String, dynamic>> _evaluations = [];
  StatsLoadingStatus _evaluationsStatus = StatsLoadingStatus.idle;
  String? _evaluationsError;

  List<Map<String, dynamic>> get evaluations => List.unmodifiable(_evaluations);
  StatsLoadingStatus get evaluationsStatus => _evaluationsStatus;
  String? get evaluationsError => _evaluationsError;
  bool get isLoadingEvaluations =>
      _evaluationsStatus == StatsLoadingStatus.loading;

  // ── Estado de estadísticas de una evaluación ──────────────────────
  Map<String, dynamic>? _evaluationStats;
  List<Map<String, dynamic>> _evaluationStatsList = [];
  StatsLoadingStatus _statsStatus = StatsLoadingStatus.idle;
  String? _statsError;

  Map<String, dynamic>? get evaluationStats => _evaluationStats;
  List<Map<String, dynamic>> get evaluationStatsList =>
      List.unmodifiable(_evaluationStatsList);
  StatsLoadingStatus get statsStatus => _statsStatus;
  String? get statsError => _statsError;
  bool get isLoadingStats => _statsStatus == StatsLoadingStatus.loading;

  // ── Estado de detalles de una evaluación ───────────────────────────
  Map<String, dynamic>? _evaluationDetails;
  StatsLoadingStatus _detailsStatus = StatsLoadingStatus.idle;
  String? _detailsError;

  Map<String, dynamic>? get evaluationDetails => _evaluationDetails;
  StatsLoadingStatus get detailsStatus => _detailsStatus;
  String? get detailsError => _detailsError;
  bool get isLoadingDetails => _detailsStatus == StatsLoadingStatus.loading;

  // ── Evaluación seleccionada ────────────────────────────────────────
  int? _selectedEvaluationId;
  int? get selectedEvaluationId => _selectedEvaluationId;

  /// Limpia la evaluación seleccionada para volver a la lista.
  void clearSelectedEvaluation() {
    _selectedEvaluationId = null;
    _evaluationStats = null;
    _evaluationStatsList = [];
    _evaluationDetails = null;
    _statsStatus = StatsLoadingStatus.idle;
    _detailsStatus = StatsLoadingStatus.idle;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════
  // MÉTODOS
  // ══════════════════════════════════════════════════════════════════

  /// Obtiene las evaluaciones de un equipo.
  Future<void> fetchTeamEvaluations(int teamId) async {
    if (_evaluationsStatus == StatsLoadingStatus.loading) return;

    _evaluationsStatus = StatsLoadingStatus.loading;
    _evaluationsError = null;
    notifyListeners();

    try {
      final result = await _service.getTeamEvaluations(teamId);

      if (result != null) {
        // La API puede devolver una lista en "data" o directamente
        final data = result['data'];
        if (data is List) {
          _evaluations = data.map((e) => e as Map<String, dynamic>).toList();
        } else {
          _evaluations = [];
        }
        _evaluationsStatus = StatsLoadingStatus.success;
      } else {
        _evaluationsError = 'No se pudieron cargar las evaluaciones.';
        _evaluationsStatus = StatsLoadingStatus.error;
      }
    } catch (e) {
      _evaluationsError = 'Error al cargar las evaluaciones: $e';
      _evaluationsStatus = StatsLoadingStatus.error;
    }

    notifyListeners();
  }

  /// Obtiene las estadísticas de una evaluación específica.
  Future<void> fetchEvaluationStatistics(int assessStrengthId) async {
    _selectedEvaluationId = assessStrengthId;
    _statsStatus = StatsLoadingStatus.loading;
    _statsError = null;
    _evaluationStatsList = [];
    notifyListeners();

    try {
      final result = await _service.getEvaluationStatistics(assessStrengthId);

      if (result != null) {
        final data = result['data'];
        if (data is List) {
          _evaluationStatsList =
              data.map((e) => e as Map<String, dynamic>).toList();
          // Keep first item as the general stats map for backward compat
          if (_evaluationStatsList.isNotEmpty) {
            _evaluationStats = _evaluationStatsList.first;
          }
        } else if (data is Map<String, dynamic>) {
          _evaluationStats = data;
          _evaluationStatsList = [data];
        } else {
          _evaluationStats = result;
          _evaluationStatsList = [result];
        }
        _statsStatus = StatsLoadingStatus.success;
      } else {
        _statsError = 'No se pudieron cargar las estadísticas.';
        _statsStatus = StatsLoadingStatus.error;
      }
    } catch (e) {
      _statsError = 'Error al cargar las estadísticas: $e';
      _statsStatus = StatsLoadingStatus.error;
    }

    notifyListeners();
  }

  /// Obtiene los detalles de una evaluación específica.
  Future<void> fetchEvaluationDetails(int assessStrengthId) async {
    _detailsStatus = StatsLoadingStatus.loading;
    _detailsError = null;
    notifyListeners();

    try {
      final result = await _service.getEvaluationDetails(assessStrengthId);

      if (result != null) {
        _evaluationDetails = result['data'] is Map<String, dynamic>
            ? result['data'] as Map<String, dynamic>
            : result;
        _detailsStatus = StatsLoadingStatus.success;
      } else {
        _detailsError = 'No se pudieron cargar los detalles.';
        _detailsStatus = StatsLoadingStatus.error;
      }
    } catch (e) {
      _detailsError = 'Error al cargar los detalles: $e';
      _detailsStatus = StatsLoadingStatus.error;
    }

    notifyListeners();
  }

  /// Carga estadísticas y detalles de una evaluación a la vez.
  Future<void> fetchFullEvaluationData(int assessStrengthId) async {
    await Future.wait([
      fetchEvaluationStatistics(assessStrengthId),
      fetchEvaluationDetails(assessStrengthId),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════
  // DASHBOARD DATA (powered by StatisticsService)
  // ══════════════════════════════════════════════════════════════════

  // ── Indicadores del dashboard ─────────────────────────────────────
  Map<String, dynamic>? _dashboardIndicators;
  StatsLoadingStatus _dashboardIndicatorsStatus = StatsLoadingStatus.idle;

  Map<String, dynamic>? get dashboardIndicators => _dashboardIndicators;
  StatsLoadingStatus get dashboardIndicatorsStatus =>
      _dashboardIndicatorsStatus;
  bool get isLoadingDashboardIndicators =>
      _dashboardIndicatorsStatus == StatsLoadingStatus.loading;

  // ── Dashboard completo ────────────────────────────────────────────
  Map<String, dynamic>? _dashboardComplete;
  StatsLoadingStatus _dashboardCompleteStatus = StatsLoadingStatus.idle;

  Map<String, dynamic>? get dashboardComplete => _dashboardComplete;
  StatsLoadingStatus get dashboardCompleteStatus => _dashboardCompleteStatus;

  // ── Top atletas ───────────────────────────────────────────────────
  List<Map<String, dynamic>> _topAthletes = [];
  StatsLoadingStatus _topAthletesStatus = StatsLoadingStatus.idle;

  List<Map<String, dynamic>> get topAthletes =>
      List.unmodifiable(_topAthletes);
  StatsLoadingStatus get topAthletesStatus => _topAthletesStatus;

  // ── Tests recientes ───────────────────────────────────────────────
  List<Map<String, dynamic>> _recentTests = [];
  StatsLoadingStatus _recentTestsStatus = StatsLoadingStatus.idle;

  List<Map<String, dynamic>> get recentTests =>
      List.unmodifiable(_recentTests);
  StatsLoadingStatus get recentTestsStatus => _recentTestsStatus;

  // ── Evolución mensual ─────────────────────────────────────────────
  Map<String, dynamic>? _monthlyEvolution;
  StatsLoadingStatus _monthlyEvolutionStatus = StatsLoadingStatus.idle;

  Map<String, dynamic>? get monthlyEvolution => _monthlyEvolution;
  StatsLoadingStatus get monthlyEvolutionStatus => _monthlyEvolutionStatus;

  // ── Dashboard del atleta ──────────────────────────────────────────
  Map<String, dynamic>? _athleteDashboard;
  StatsLoadingStatus _athleteDashboardStatus = StatsLoadingStatus.idle;

  Map<String, dynamic>? get athleteDashboard => _athleteDashboard;
  StatsLoadingStatus get athleteDashboardStatus => _athleteDashboardStatus;
  bool get isLoadingAthleteDashboard =>
      _athleteDashboardStatus == StatsLoadingStatus.loading;

  /// Obtiene los indicadores del dashboard del coach.
  Future<void> fetchDashboardIndicators({int? coachId, int? teamId}) async {
    _dashboardIndicatorsStatus = StatsLoadingStatus.loading;
    notifyListeners();

    try {
      final result = await _statisticsService.getDashboardIndicators(
        coachId: coachId,
        teamId: teamId,
      );
      if (result != null && result['success'] == true) {
        _dashboardIndicators = result['data'] as Map<String, dynamic>?;
        _dashboardIndicatorsStatus = StatsLoadingStatus.success;
      } else {
        _dashboardIndicatorsStatus = StatsLoadingStatus.error;
      }
    } catch (_) {
      _dashboardIndicatorsStatus = StatsLoadingStatus.error;
    }

    notifyListeners();
  }

  /// Obtiene el dashboard completo del coach.
  Future<void> fetchDashboardComplete({int? coachId}) async {
    _dashboardCompleteStatus = StatsLoadingStatus.loading;
    notifyListeners();

    try {
      final result = await _statisticsService.getDashboardComplete(
        coachId: coachId,
      );
      if (result != null && result['success'] == true) {
        _dashboardComplete = result['data'] as Map<String, dynamic>?;
        _dashboardCompleteStatus = StatsLoadingStatus.success;
      } else {
        _dashboardCompleteStatus = StatsLoadingStatus.error;
      }
    } catch (_) {
      _dashboardCompleteStatus = StatsLoadingStatus.error;
    }

    notifyListeners();
  }

  /// Obtiene los atletas con mejor rendimiento.
  Future<void> fetchTopPerformanceAthletes({
    int? coachId,
    int? teamId,
    int limit = 5,
  }) async {
    _topAthletesStatus = StatsLoadingStatus.loading;
    notifyListeners();

    try {
      final result = await _statisticsService.getTopPerformanceAthletes(
        coachId: coachId,
        teamId: teamId,
        limit: limit,
      );
      if (result != null && result['success'] == true) {
        final data = result['data'];
        if (data is List) {
          _topAthletes =
              data.map((e) => e as Map<String, dynamic>).toList();
        }
        _topAthletesStatus = StatsLoadingStatus.success;
      } else {
        _topAthletesStatus = StatsLoadingStatus.error;
      }
    } catch (_) {
      _topAthletesStatus = StatsLoadingStatus.error;
    }

    notifyListeners();
  }

  /// Obtiene los tests más recientes.
  Future<void> fetchRecentTests({
    int? coachId,
    int? teamId,
    int limit = 10,
  }) async {
    _recentTestsStatus = StatsLoadingStatus.loading;
    notifyListeners();

    try {
      final result = await _statisticsService.getRecentTests(
        coachId: coachId,
        teamId: teamId,
        limit: limit,
      );
      if (result != null && result['success'] == true) {
        final data = result['data'];
        if (data is List) {
          _recentTests =
              data.map((e) => e as Map<String, dynamic>).toList();
        }
        _recentTestsStatus = StatsLoadingStatus.success;
      } else {
        _recentTestsStatus = StatsLoadingStatus.error;
      }
    } catch (_) {
      _recentTestsStatus = StatsLoadingStatus.error;
    }

    notifyListeners();
  }

  /// Obtiene la evolución mensual.
  Future<void> fetchMonthlyEvolution({
    int? coachId,
    int? teamId,
    int months = 12,
  }) async {
    _monthlyEvolutionStatus = StatsLoadingStatus.loading;
    notifyListeners();

    try {
      final result = await _statisticsService.getMonthlyEvolution(
        coachId: coachId,
        teamId: teamId,
        months: months,
      );
      if (result != null && result['success'] == true) {
        _monthlyEvolution = result['data'] as Map<String, dynamic>?;
        _monthlyEvolutionStatus = StatsLoadingStatus.success;
      } else {
        _monthlyEvolutionStatus = StatsLoadingStatus.error;
      }
    } catch (_) {
      _monthlyEvolutionStatus = StatsLoadingStatus.error;
    }

    notifyListeners();
  }

  /// Obtiene el dashboard completo de un atleta individual.
  Future<void> fetchAthleteFullDashboard(int athleteId) async {
    _athleteDashboardStatus = StatsLoadingStatus.loading;
    notifyListeners();

    try {
      final result =
          await _statisticsService.getAthleteFullDashboard(athleteId);
      if (result != null && result['success'] == true) {
        _athleteDashboard = result['data'] as Map<String, dynamic>?;
        _athleteDashboardStatus = StatsLoadingStatus.success;
      } else {
        _athleteDashboardStatus = StatsLoadingStatus.error;
      }
    } catch (_) {
      _athleteDashboardStatus = StatsLoadingStatus.error;
    }

    notifyListeners();
  }

  /// Carga todos los datos del dashboard del coach de una vez.
  Future<void> fetchAllDashboardData({int? coachId, int? teamId}) async {
    await Future.wait([
      fetchDashboardIndicators(coachId: coachId, teamId: teamId),
      fetchTopPerformanceAthletes(coachId: coachId, teamId: teamId),
      fetchRecentTests(coachId: coachId, teamId: teamId),
      fetchMonthlyEvolution(coachId: coachId, teamId: teamId),
    ]);
  }

  /// Limpia el estado (útil al cerrar sesión o cambiar de equipo).
  void clear() {
    _evaluations = [];
    _evaluationsStatus = StatsLoadingStatus.idle;
    _evaluationsError = null;
    _evaluationStats = null;
    _evaluationStatsList = [];
    _statsStatus = StatsLoadingStatus.idle;
    _statsError = null;
    _evaluationDetails = null;
    _detailsStatus = StatsLoadingStatus.idle;
    _detailsError = null;
    _selectedEvaluationId = null;
    // Dashboard
    _dashboardIndicators = null;
    _dashboardIndicatorsStatus = StatsLoadingStatus.idle;
    _dashboardComplete = null;
    _dashboardCompleteStatus = StatsLoadingStatus.idle;
    _topAthletes = [];
    _topAthletesStatus = StatsLoadingStatus.idle;
    _recentTests = [];
    _recentTestsStatus = StatsLoadingStatus.idle;
    _monthlyEvolution = null;
    _monthlyEvolutionStatus = StatsLoadingStatus.idle;
    _athleteDashboard = null;
    _athleteDashboardStatus = StatsLoadingStatus.idle;
    notifyListeners();
  }
}
