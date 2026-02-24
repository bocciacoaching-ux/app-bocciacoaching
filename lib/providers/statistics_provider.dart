import 'package:flutter/foundation.dart';
import '../services/assess_strength_service.dart';

enum StatsLoadingStatus { idle, loading, success, error }

class StatisticsProvider extends ChangeNotifier {
  final AssessStrengthService _service = AssessStrengthService();

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
  StatsLoadingStatus _statsStatus = StatsLoadingStatus.idle;
  String? _statsError;

  Map<String, dynamic>? get evaluationStats => _evaluationStats;
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
          _evaluations =
              data.map((e) => e as Map<String, dynamic>).toList();
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
    notifyListeners();

    try {
      final result =
          await _service.getEvaluationStatistics(assessStrengthId);

      if (result != null) {
        _evaluationStats = result['data'] is Map<String, dynamic>
            ? result['data'] as Map<String, dynamic>
            : result;
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
      final result =
          await _service.getEvaluationDetails(assessStrengthId);

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

  /// Limpia el estado (útil al cerrar sesión o cambiar de equipo).
  void clear() {
    _evaluations = [];
    _evaluationsStatus = StatsLoadingStatus.idle;
    _evaluationsError = null;
    _evaluationStats = null;
    _statsStatus = StatsLoadingStatus.idle;
    _statsError = null;
    _evaluationDetails = null;
    _detailsStatus = StatsLoadingStatus.idle;
    _detailsError = null;
    _selectedEvaluationId = null;
    notifyListeners();
  }
}
