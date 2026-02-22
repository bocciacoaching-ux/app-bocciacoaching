import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/assess_strength.dart';
import '../models/evaluation_throw.dart';

class AssessStrengthService {
  static const String baseUrl = "https://api.ejemplo.com"; // Replace with real URL

  Future<AssessStrength?> getActiveEvaluation(int teamId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/assess-strength/active/$teamId'));
      if (response.statusCode == 200) {
        return AssessStrength.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int?> createEvaluation(String evaluationName, int teamId, int coachId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/assess-strength/add-evaluation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'evaluationName': evaluationName,
          'teamId': teamId,
          'coachId': coachId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> addAthletesToEvaluation(int coachId, List<int> athleteIds, int assessStrengthId) async {
    try {
      // Assuming the API takes a list or we call it for each
      for (var athleteId in athleteIds) {
        await http.post(
          Uri.parse('$baseUrl/api/assess-strength/add-athletes-to-evaluated'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'coachId': coachId,
            'athleteId': athleteId,
            'assessStrengthId': assessStrengthId,
          }),
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveThrow(EvaluationThrow throwData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/assess-strength/add-details-to-evaluation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(throwData.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
