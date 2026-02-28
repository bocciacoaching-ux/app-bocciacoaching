import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Repositorio de equipos — encapsula las llamadas a la API de teams.
class TeamRepository {
  final ApiClient _apiClient;

  TeamRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Obtiene la lista de equipos.
  Future<Map<String, dynamic>> getTeams() async {
    return await _apiClient.get(ApiEndpoints.teams);
  }

  /// Obtiene los miembros de un equipo.
  Future<Map<String, dynamic>> getTeamMembers(String teamId) async {
    return await _apiClient.get('${ApiEndpoints.teamMembers}/$teamId');
  }

  /// Crea un nuevo equipo.
  Future<Map<String, dynamic>> createTeam(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.teams, body: data);
  }

  /// Actualiza un equipo existente.
  Future<Map<String, dynamic>> updateTeam(
      String teamId, Map<String, dynamic> data) async {
    return await _apiClient.put('${ApiEndpoints.teams}/$teamId', body: data);
  }

  /// Elimina un equipo.
  Future<Map<String, dynamic>> deleteTeam(String teamId) async {
    return await _apiClient.delete('${ApiEndpoints.teams}/$teamId');
  }
}
