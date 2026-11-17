import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Repositorio de equipos — encapsula las llamadas a la API de Teams (v1).
class TeamRepository {
  final ApiClient _apiClient;

  TeamRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Equipos en los que el usuario es entrenador o miembro activo.
  Future<Map<String, dynamic>> getTeamsForUser(String userId) async {
    return await _apiClient.get(ApiEndpoints.userTeams(userId));
  }

  /// Obtiene un equipo por su identificador.
  Future<Map<String, dynamic>> getTeamById(String teamId) async {
    return await _apiClient.get(ApiEndpoints.teamById(teamId));
  }

  /// Obtiene los miembros de un equipo; filtra por rol si se envía [roleId].
  Future<Map<String, dynamic>> getUsersForTeam(String teamId,
      {String? roleId}) async {
    return await _apiClient.get(
      ApiEndpoints.teamMembers(teamId),
      queryParams: roleId != null ? {'roleId': roleId} : null,
    );
  }

  /// Crea un nuevo equipo. `data` sigue el esquema RequestTeamDto.
  Future<Map<String, dynamic>> addNewTeam(Map<String, dynamic> data) async {
    return await _apiClient.post(ApiEndpoints.teams, body: data);
  }

  /// Añade un usuario a un equipo.
  Future<Map<String, dynamic>> addNewTeamMember(
      String teamId, String userId) async {
    return await _apiClient.post(ApiEndpoints.teamMembers(teamId),
        body: {'userId': userId});
  }

  /// Actualiza un equipo existente. `data` sigue el esquema RequestUpdateTeamDto.
  Future<Map<String, dynamic>> updateTeam(
      String teamId, Map<String, dynamic> data) async {
    return await _apiClient.put(ApiEndpoints.teamById(teamId),
        body: {...data, 'teamId': teamId});
  }

  /// Últimas estadísticas de fuerza del equipo registradas por un entrenador.
  Future<Map<String, dynamic>> getRecentStatistics(
      String teamId, String coachId) async {
    return await _apiClient.get(
      ApiEndpoints.teamRecentStrengthStatistics(teamId),
      queryParams: {'coachId': coachId},
    );
  }
}
