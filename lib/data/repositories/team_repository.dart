import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Repositorio de equipos — encapsula las llamadas a la API de teams.
class TeamRepository {
  final ApiClient _apiClient;

  TeamRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Obtiene los equipos de un entrenador.
  Future<Map<String, dynamic>> getTeamsForUser(int coachId) async {
    return await _apiClient.get(ApiEndpoints.getTeamsForUser(coachId));
  }

  /// Obtiene los miembros de un equipo por rol.
  Future<Map<String, dynamic>> getUsersForTeam(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.getUsersForTeam, body: data);
  }

  /// Crea un nuevo equipo.
  Future<Map<String, dynamic>> addNewTeam(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.addNewTeam, body: data);
  }

  /// Añade un miembro a un equipo.
  Future<Map<String, dynamic>> addNewTeamMember(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.addNewTeamMember, body: data);
  }

  /// Actualiza un equipo existente.
  Future<Map<String, dynamic>> updateTeam(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.updateTeam, body: data);
  }

  /// Obtiene estadísticas recientes de un equipo.
  Future<Map<String, dynamic>> getRecentStatistics(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.getRecentStatistics, body: data);
  }
}
