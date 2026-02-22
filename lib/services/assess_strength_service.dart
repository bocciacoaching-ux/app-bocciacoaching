import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AssessStrengthService {
  final String _base = AppConfig.baseUrl;

  // POST /api/AssessStrength/AddEvaluation
  Future<Map<String, dynamic>?> addEvaluation({
    required String description,
    required int teamId,
    required int coachId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessStrength/AddEvaluation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'description': description,
          'teamId': teamId,
          'coachId': coachId,
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

  // POST /api/AssessStrength/AthletesToEvaluated
  Future<List<dynamic>?> addAthleteToEvaluation({
    required int coachId,
    required int athleteId,
    required int assessStrengthId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessStrength/AthletesToEvaluated'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'coachId': coachId,
          'athleteId': athleteId,
          'assessStrengthId': assessStrengthId,
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

  // POST /api/AssessStrength/AddDeatilsToEvaluation
  Future<List<dynamic>?> addDetailsToEvaluation({
    required int boxNumber,
    required int throwOrder,
    double? targetDistance,
    double? scoreObtained,
    String? observations,
    required bool status,
    required int athleteId,
    required int assessStrengthId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessStrength/AddDeatilsToEvaluation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'boxNumber': boxNumber,
          'throwOrder': throwOrder,
          'targetDistance': targetDistance,
          'scoreObtained': scoreObtained,
          'observations': observations,
          'status': status,
          'athleteId': athleteId,
          'assessStrengthId': assessStrengthId,
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

  // GET /api/AssessStrength/GetActiveEvaluation/{teamId}
  Future<Map<String, dynamic>?> getActiveEvaluation(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/AssessStrength/GetActiveEvaluation/$teamId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // PUT /api/AssessStrength/UpdateState
  Future<Map<String, dynamic>?> updateState({
    required int id,
    required DateTime evaluationDate,
    String? description,
    required int teamId,
    String? state,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/AssessStrength/UpdateState'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'evaluationDate': evaluationDate.toIso8601String(),
          'description': description,
          'teamId': teamId,
          'state': state,
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

  // GET /api/AssessStrength/GetTeamEvaluations/{teamId}
  Future<Map<String, dynamic>?> getTeamEvaluations(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/AssessStrength/GetTeamEvaluations/$teamId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/AssessStrength/GetEvaluationStatistics/{assessStrengthId}
  Future<Map<String, dynamic>?> getEvaluationStatistics(int assessStrengthId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/AssessStrength/GetEvaluationStatistics/$assessStrengthId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/AssessStrength/GetEvaluationDetails/{assessStrengthId}
  Future<Map<String, dynamic>?> getEvaluationDetails(int assessStrengthId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/AssessStrength/GetEvaluationDetails/$assessStrengthId'),
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
