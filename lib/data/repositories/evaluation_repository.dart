import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Repositorio de evaluaciones — encapsula las llamadas a la API.
class EvaluationRepository {
  final ApiClient _apiClient;

  EvaluationRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Obtiene la lista de evaluaciones.
  Future<Map<String, dynamic>> getEvaluations() async {
    return await _apiClient.get(ApiEndpoints.evaluations);
  }

  /// Crea una nueva evaluación.
  Future<Map<String, dynamic>> createEvaluation(
      Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.evaluations, body: data);
  }

  /// Obtiene estadísticas.
  Future<Map<String, dynamic>> getStatistics() async {
    return await _apiClient.get(ApiEndpoints.statistics);
  }
}
