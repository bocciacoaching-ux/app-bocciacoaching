import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Repositorio de atletas — encapsula las llamadas a la API de athletes.
class AthleteRepository {
  final ApiClient _apiClient;

  AthleteRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Obtiene la lista de atletas.
  Future<Map<String, dynamic>> getAthletes() async {
    return await _apiClient.get(ApiEndpoints.athletes);
  }

  /// Obtiene un atleta por ID.
  Future<Map<String, dynamic>> getAthleteById(String athleteId) async {
    return await _apiClient.get('${ApiEndpoints.athletes}/$athleteId');
  }

  /// Crea un nuevo atleta.
  Future<Map<String, dynamic>> createAthlete(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.athletes, body: data);
  }

  /// Actualiza un atleta.
  Future<Map<String, dynamic>> updateAthlete(
      String athleteId, Map<String, dynamic> data) async {
    return await _apiClient
        .put('${ApiEndpoints.athletes}/$athleteId', body: data);
  }
}
