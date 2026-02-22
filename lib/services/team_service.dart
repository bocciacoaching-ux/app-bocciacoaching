import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class TeamService {
  final String _base = AppConfig.baseUrl;

  // POST /api/Team/AddNewTeam
  Future<Map<String, dynamic>?> addNewTeam({
    String? nameTeam,
    String? description,
    required int coachId,
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
      final response = await http.post(
        Uri.parse('$_base/Team/AddNewTeam'),
        headers: {'Content-Type': 'application/json'},
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
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Team/AddNewTeamMember
  Future<Map<String, dynamic>?> addNewTeamMember({
    required int userId,
    required int teamId,
    required DateTime dateCreation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Team/AddNewTeamMember'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'teamId': teamId,
          'dateCreation': dateCreation.toIso8601String(),
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Team/GetTeamsForUser
  Future<List<dynamic>?> getTeamsForUser({
    String? nameTeam,
    String? description,
    required int coachId,
    String? image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Team/GetTeamsForUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nameTeam': nameTeam,
          'description': description,
          'coachId': coachId,
          'image': image,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Team/GetUsersForTeam
  Future<Map<String, dynamic>?> getUsersForTeam({
    required int teamId,
    required int rolId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Team/GetUsersForTeam'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'teamId': teamId, 'rolId': rolId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Team/UpdateTeam
  Future<bool?> updateTeam({
    required int teamId,
    String? image,
    bool? bc1,
    bool? bc2,
    bool? bc3,
    bool? bc4,
    String? country,
    String? region,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Team/UpdateTeam'),
        headers: {'Content-Type': 'application/json'},
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
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as bool;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Team/GetRecentStatistics
  Future<Map<String, dynamic>?> getRecentStatistics({
    required int coachId,
    required int teamId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Team/GetRecentStatistics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'coachId': coachId, 'teamId': teamId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
