import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Repositorio de evaluaciones — encapsula las llamadas a la API.
class EvaluationRepository {
  final ApiClient _apiClient;

  EvaluationRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  // ── Strength ─────────────────────────────────────────────────────

  /// Crea una nueva evaluación de fuerza.
  Future<Map<String, dynamic>> addStrengthEvaluation(
      Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.strengthAddEvaluation, body: data);
  }

  /// Obtiene evaluaciones de fuerza de un equipo.
  Future<Map<String, dynamic>> getStrengthTeamEvaluations(int teamId) async {
    return await _apiClient
        .get(ApiEndpoints.strengthGetTeamEvaluations(teamId));
  }

  /// Obtiene detalles de una evaluación de fuerza.
  Future<Map<String, dynamic>> getStrengthEvaluationDetails(
      int assessStrengthId) async {
    return await _apiClient
        .get(ApiEndpoints.strengthGetEvaluationDetails(assessStrengthId));
  }

  /// Obtiene estadísticas de una evaluación de fuerza.
  Future<Map<String, dynamic>> getStrengthEvaluationStatistics(
      int assessStrengthId) async {
    return await _apiClient
        .get(ApiEndpoints.strengthGetEvaluationStatistics(assessStrengthId));
  }

  // ── Direction ────────────────────────────────────────────────────

  /// Crea una nueva evaluación de dirección.
  Future<Map<String, dynamic>> addDirectionEvaluation(
      Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.directionAddEvaluation, body: data);
  }

  /// Obtiene evaluaciones de dirección de un equipo.
  Future<Map<String, dynamic>> getDirectionTeamEvaluations(int teamId) async {
    return await _apiClient
        .get(ApiEndpoints.directionGetTeamEvaluations(teamId));
  }

  /// Obtiene detalles de una evaluación de dirección.
  Future<Map<String, dynamic>> getDirectionEvaluationDetails(
      int assessDirectionId) async {
    return await _apiClient
        .get(ApiEndpoints.directionGetEvaluationDetails(assessDirectionId));
  }

  /// Obtiene estadísticas de una evaluación de dirección.
  Future<Map<String, dynamic>> getDirectionEvaluationStatistics(
      int assessDirectionId) async {
    return await _apiClient
        .get(ApiEndpoints.directionGetEvaluationStatistics(assessDirectionId));
  }

  // ── Statistics ───────────────────────────────────────────────────

  /// Obtiene indicadores del dashboard.
  Future<Map<String, dynamic>> getDashboardIndicators({
    Map<String, String>? queryParams,
  }) async {
    return await _apiClient.get(ApiEndpoints.dashboardIndicators,
        queryParams: queryParams);
  }

  /// Obtiene el dashboard completo.
  Future<Map<String, dynamic>> getDashboardComplete({
    Map<String, String>? queryParams,
  }) async {
    return await _apiClient.get(ApiEndpoints.dashboardComplete,
        queryParams: queryParams);
  }
}
