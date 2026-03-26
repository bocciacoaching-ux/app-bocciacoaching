import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import '../../data/models/active_direction_evaluation.dart';
import '../../data/models/direction_evaluation.dart';
import '../../data/models/direction_statistics.dart';

class AssessDirectionService {
  final String _base = AppConfig.baseUrl;

  // POST /api/AssessDirection/AddEvaluation
  Future<Map<String, dynamic>?> addEvaluation({
    required String description,
    required int teamId,
    required int coachId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessDirection/AddEvaluation'),
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

  // POST /api/AssessDirection/AthletesToEvaluated
  Future<Map<String, dynamic>?> addAthleteToEvaluation({
    required int coachId,
    required int athleteId,
    required int assessDirectionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessDirection/AthletesToEvaluated'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'coachId': coachId,
          'athleteId': athleteId,
          'assessDirectionId': assessDirectionId,
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

  // POST /api/AssessDirection/AddDetailsToEvaluation
  Future<bool?> addDetailsToEvaluation({
    required int boxNumber,
    required int throwOrder,
    double? targetDistance,
    double? scoreObtained,
    String? observations,
    required bool status,
    required int athleteId,
    required int assessDirectionId,
    required double coordinateX,
    required double coordinateY,
    required bool deviatedRight,
    required bool deviatedLeft,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessDirection/AddDetailsToEvaluation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'boxNumber': boxNumber,
          'throwOrder': throwOrder,
          'targetDistance': targetDistance,
          'scoreObtained': scoreObtained,
          'observations': observations,
          'status': status,
          'athleteId': athleteId,
          'assessDirectionId': assessDirectionId,
          'coordinateX': coordinateX,
          'coordinateY': coordinateY,
          'deviatedRight': deviatedRight,
          'deviatedLeft': deviatedLeft,
        }),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is bool) return decoded;
        return null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/AssessDirection/GetActiveEvaluation/{teamId}/{coachId}
  Future<ActiveDirectionEvaluation?> getActiveEvaluation(
      int teamId, int coachId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_base/AssessDirection/GetActiveEvaluation/$teamId/$coachId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          return ActiveDirectionEvaluation.fromJson(
              body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/AssessDirection/DebugEvaluations/{teamId}
  Future<void> debugEvaluations(int teamId) async {
    try {
      await http.get(
        Uri.parse('$_base/AssessDirection/DebugEvaluations/$teamId'),
      );
    } catch (_) {
      // debug endpoint
    }
  }

  // PUT /api/AssessDirection/UpdateState
  Future<Map<String, dynamic>?> updateState({
    required int id,
    required DateTime evaluationDate,
    String? description,
    required int teamId,
    String? state,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/AssessDirection/UpdateState'),
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

  // POST /api/AssessDirection/Cancel
  Future<Map<String, dynamic>?> cancel({
    required int assessDirectionId,
    required int coachId,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessDirection/Cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'assessDirectionId': assessDirectionId,
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

  // GET /api/AssessDirection/GetTeamEvaluations/{teamId}
  Future<List<DirectionEvaluationSummaryDto>?> getTeamEvaluations(
      int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/AssessDirection/GetTeamEvaluations/$teamId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => DirectionEvaluationSummaryDto.fromJson(
                  e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/AssessDirection/GetEvaluationStatistics/{assessDirectionId}
  Future<List<DirectionAthleteStatisticsDto>?> getEvaluationStatistics(
      int assessDirectionId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_base/AssessDirection/GetEvaluationStatistics/$assessDirectionId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => DirectionAthleteStatisticsDto.fromJson(
                  e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/AssessDirection/GetEvaluationDetails/{assessDirectionId}
  Future<DirectionEvaluationDetailsDto?> getEvaluationDetails(
      int assessDirectionId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_base/AssessDirection/GetEvaluationDetails/$assessDirectionId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          return DirectionEvaluationDetailsDto.fromJson(
              body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
