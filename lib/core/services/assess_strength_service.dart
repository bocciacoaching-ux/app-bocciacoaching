import 'dart:convert';
import '../network/http_logger.dart';
import '../constants/app_config.dart';

class AssessStrengthService {
  final String _base = AppConfig.baseUrl;

  // POST /api/AssessStrength/AddEvaluation
  Future<Map<String, dynamic>?> addEvaluation({
    required String description,
    required String teamId,
    required String coachId,
  }) async {
    try {
      final response = await HttpLogger.post(
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
    required String coachId,
    required String athleteId,
    required String assessStrengthId,
  }) async {
    try {
      final response = await HttpLogger.post(
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
    required String athleteId,
    required String assessStrengthId,
    double? coordinateX,
    double? coordinateY,
    bool isStrength = false,
    bool isCadence = false,
    bool isDirection = false,
    bool isTrajectory = false,
  }) async {
    try {
      final response = await HttpLogger.post(
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
          'coordinateX': coordinateX,
          'coordinateY': coordinateY,
          'isStrength': isStrength,
          'isCadence': isCadence,
          'isDirection': isDirection,
          'isTrajectory': isTrajectory,
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

  // GET /api/AssessStrength/GetActiveEvaluation/{teamId}/{coachId}
  Future<Map<String, dynamic>?> getActiveEvaluation(String teamId, String coachId) async {
    try {
      final response = await HttpLogger.get(
        Uri.parse('$_base/AssessStrength/GetActiveEvaluation/$teamId/$coachId'),
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
    required String id,
    required DateTime evaluationDate,
    String? description,
    required String teamId,
    String? state,
  }) async {
    try {
      final response = await HttpLogger.put(
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

  // POST /api/AssessStrength/Cancel
  Future<Map<String, dynamic>?> cancel({
    required String assessStrengthId,
    required String coachId,
    String? reason,
  }) async {
    try {
      final response = await HttpLogger.post(
        Uri.parse('$_base/AssessStrength/Cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'assessStrengthId': assessStrengthId,
          'coachId': coachId,
          'reason': reason,
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

  // GET /api/AssessStrength/DebugEvaluations/{teamId}
  Future<void> debugEvaluations(String teamId) async {
    try {
      await HttpLogger.get(
        Uri.parse('$_base/AssessStrength/DebugEvaluations/$teamId'),
      );
    } catch (_) {
      // debug endpoint
    }
  }

  // GET /api/AssessStrength/GetTeamEvaluations/{teamId}
  Future<Map<String, dynamic>?> getTeamEvaluations(String teamId) async {
    try {
      final response = await HttpLogger.get(
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
  Future<Map<String, dynamic>?> getEvaluationStatistics(String assessStrengthId) async {
    try {
      final response = await HttpLogger.get(
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
  Future<Map<String, dynamic>?> getEvaluationDetails(String assessStrengthId) async {
    try {
      final response = await HttpLogger.get(
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

  // GET /api/AssessStrength/CoachHasEvaluations/{coachId}
  Future<Map<String, dynamic>?> coachHasEvaluations(String coachId) async {
    try {
      final response = await HttpLogger.get(
        Uri.parse('$_base/AssessStrength/CoachHasEvaluations/$coachId'),
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
