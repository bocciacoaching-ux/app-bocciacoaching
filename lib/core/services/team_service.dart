import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../network/http_logger.dart';
import '../constants/app_config.dart';
import '../constants/api_endpoints.dart';
import '../../data/models/team.dart';
import '../../data/models/team_member.dart';

/// Servicio HTTP para el recurso Teams del backend (API v1).
///
/// Todas las respuestas vienen envueltas en `{ success, message, data }`.
/// Errores: 400 (validación), 404 / 409 (`ProblemDetails`), 500.
class TeamService {
  final String _base = AppConfig.baseUrl;

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$_base$path');
    return (query == null || query.isEmpty)
        ? uri
        : uri.replace(queryParameters: query);
  }

  bool _isOk(http.Response r) => r.statusCode >= 200 && r.statusCode < 300;

  Map<String, dynamic>? _decodeMap(http.Response r) {
    if (r.body.isEmpty) return null;
    final decoded = jsonDecode(r.body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  // ─── POST /api/v1/teams ─────────────────────────────────────────
  /// Crea un equipo. Devuelve el contrato `{ success, message, data: teamId }`.
  Future<Map<String, dynamic>?> addNewTeam({
    String? nameTeam,
    String? description,
    required String coachId,
    String? image,
    bool? bc1,
    bool? bc2,
    bool? bc3,
    bool? bc4,
    bool? pairs,
    bool? teams,
    String? country,
    String? region,
  }) async {
    try {
      final response = await HttpLogger.post(
        _uri(ApiEndpoints.teams),
        headers: _headers,
        body: jsonEncode({
          'nameTeam': nameTeam,
          'description': description,
          'coachId': coachId,
          'image': image,
          'bc1': bc1,
          'bc2': bc2,
          'bc3': bc3,
          'bc4': bc4,
          'pairs': pairs,
          'teams': teams,
          'country': country,
          'region': region,
        }),
      );
      if (_isOk(response)) return _decodeMap(response);
      return null;
    } catch (e) {
      debugPrint('[TeamService] addNewTeam error: $e');
      return null;
    }
  }

  // ─── GET /api/v1/teams/{teamId} ─────────────────────────────────
  Future<Team?> getTeamById(String teamId) async {
    try {
      final response = await HttpLogger.get(
        _uri(ApiEndpoints.teamById(teamId)),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final body = _decodeMap(response);
        if (body?['success'] == true && body?['data'] is Map) {
          return Team.fromJson(body!['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TeamService] getTeamById error: $e');
      return null;
    }
  }

  // ─── POST /api/v1/teams/{teamId}/members ────────────────────────
  /// Agrega un usuario al equipo. 409 si ya es integrante.
  Future<Map<String, dynamic>?> addNewTeamMember({
    required String userId,
    required String teamId,
  }) async {
    try {
      final response = await HttpLogger.post(
        _uri(ApiEndpoints.teamMembers(teamId)),
        headers: _headers,
        body: jsonEncode({'userId': userId}),
      );
      if (_isOk(response)) return _decodeMap(response);
      return null;
    } catch (e) {
      debugPrint('[TeamService] addNewTeamMember error: $e');
      return null;
    }
  }

  // ─── GET /api/v1/users/{userId}/teams ───────────────────────────
  /// Equipos en los que el usuario es entrenador o miembro activo.
  Future<List<Team>?> getTeamsForUser({required String coachId}) async {
    try {
      final response = await HttpLogger.get(
        _uri(ApiEndpoints.userTeams(coachId)),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final body = _decodeMap(response);
        if (body?['success'] == true && body?['data'] is List) {
          return (body!['data'] as List)
              .map((e) => Team.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TeamService] getTeamsForUser error: $e');
      return null;
    }
  }

  // ─── GET /api/v1/teams/{teamId}/members?roleId= ─────────────────
  /// Integrantes del equipo; si se envía [rolId] filtra por rol.
  Future<List<TeamMember>?> getUsersForTeam({
    required String teamId,
    String? rolId,
  }) async {
    try {
      final response = await HttpLogger.get(
        _uri(
          ApiEndpoints.teamMembers(teamId),
          rolId != null && rolId.isNotEmpty ? {'roleId': rolId} : null,
        ),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final body = _decodeMap(response);
        if (body?['success'] == true && body?['data'] is List) {
          return (body!['data'] as List)
              .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TeamService] getUsersForTeam error: $e');
      return null;
    }
  }

  // ─── PUT /api/v1/teams/{teamId} ─────────────────────────────────
  /// Actualiza los datos editables del equipo. Devuelve `true` si se guardó.
  Future<bool?> updateTeam({
    required String teamId,
    String? image,
    bool? bc1,
    bool? bc2,
    bool? bc3,
    bool? bc4,
    String? country,
    String? region,
  }) async {
    try {
      final response = await HttpLogger.put(
        _uri(ApiEndpoints.teamById(teamId)),
        headers: _headers,
        body: jsonEncode({
          'teamId': teamId,
          'image': image,
          'bc1': bc1,
          'bc2': bc2,
          'bc3': bc3,
          'bc4': bc4,
          'country': country,
          'region': region,
        }),
      );
      if (!_isOk(response)) return false;
      if (response.body.isEmpty) return true;
      final decoded = jsonDecode(response.body);
      // v1 responde con el contrato estándar; se tolera el booleano plano
      // histórico por compatibilidad.
      if (decoded is bool) return decoded;
      if (decoded is Map<String, dynamic>) {
        if (decoded['success'] != true) return false;
        final data = decoded['data'];
        return data is bool ? data : true;
      }
      return true;
    } catch (e) {
      debugPrint('[TeamService] updateTeam error: $e');
      return null;
    }
  }

  // ─── GET /api/v1/teams/{teamId}/strength-statistics/recent?coachId= ──
  /// Últimas estadísticas de fuerza del equipo registradas por un entrenador.
  Future<Map<String, dynamic>?> getRecentStatistics({
    required String coachId,
    required String teamId,
  }) async {
    try {
      final response = await HttpLogger.get(
        _uri(ApiEndpoints.teamRecentStrengthStatistics(teamId),
            {'coachId': coachId}),
        headers: _headers,
      );
      if (response.statusCode == 200) return _decodeMap(response);
      return null;
    } catch (e) {
      debugPrint('[TeamService] getRecentStatistics error: $e');
      return null;
    }
  }
}
