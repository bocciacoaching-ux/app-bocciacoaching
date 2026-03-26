import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Repositorio de atletas — encapsula las llamadas a la API de athletes.
class AthleteRepository {
  final ApiClient _apiClient;

  AthleteRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Obtiene la lista de todos los usuarios.
  Future<Map<String, dynamic>> getInfoUser() async {
    return await _apiClient.get(ApiEndpoints.getInfoUser);
  }

  /// Busca atletas por nombre y equipo.
  Future<Map<String, dynamic>> searchAthletes(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.searchAthletes, body: data);
  }

  /// Crea un nuevo atleta.
  Future<Map<String, dynamic>> addAthlete(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.addAthlete, body: data);
  }

  /// Actualiza la información de un usuario.
  Future<Map<String, dynamic>> updateUserInfo(Map<String, dynamic> data) async {
    return await _apiClient.put(ApiEndpoints.updateUserInfo, body: data);
  }
}
