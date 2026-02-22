import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AthleteService {
  final String _base = AppConfig.baseUrl;

  // POST /api/User/SearchAthletesForNameAndTeams
  Future<Map<String, dynamic>?> searchAthletes({
    String? firstName,
    required int teamId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/User/SearchAthletesForNameAndTeams'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'firstName': firstName, 'teamId': teamId}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/User/AddAthlete
  Future<Map<String, dynamic>?> addAthlete({
    String? dni,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? address,
    DateTime? seniority,
    required bool status,
    required int coachId,
    int? teamId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/User/AddAthlete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dni': dni,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'address': address,
          'seniority': seniority?.toIso8601String(),
          'status': status,
          'coachId': coachId,
          'teamId': teamId,
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
}
