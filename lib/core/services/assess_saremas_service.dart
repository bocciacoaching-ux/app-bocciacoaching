import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import '../../data/models/active_saremas_evaluation.dart';
import '../../data/models/saremas_evaluation_summary.dart';
import '../../data/models/saremas_evaluation_details.dart';
import '../../data/models/saremas_statistics.dart';
import '../../data/models/saremas_athlete_history.dart';

class AssessSaremasService {
  final String _base = AppConfig.baseUrl;

  // POST /api/AssessSaremas/AddEvaluation
  Future<Map<String, dynamic>?> addEvaluation({
    required String description,
    required int teamId,
    required int coachId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessSaremas/AddEvaluation'),
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

  // POST /api/AssessSaremas/AthletesToEvaluated
  Future<Map<String, dynamic>?> addAthleteToEvaluation({
    required int coachId,
    required int athleteId,
    required int saremasEvalId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessSaremas/AthletesToEvaluated'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'coachId': coachId,
          'athleteId': athleteId,
          'saremasEvalId': saremasEvalId,
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

  // POST /api/AssessSaremas/AddDetailsToEvaluation
  Future<Map<String, dynamic>?> addDetailsToEvaluation({
    required int throwNumber,
    String? diagonal,
    String? technicalComponent,
    required int scoreObtained,
    String? observations,
    String? failureTags,
    String? status,
    required int athleteId,
    required int saremasEvalId,
    double? whiteBallX,
    double? whiteBallY,
    double? colorBallX,
    double? colorBallY,
    double? estimatedDistance,
    double? launchPointX,
    double? launchPointY,
    double? distanceToLaunchPoint,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessSaremas/AddDetailsToEvaluation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'throwNumber': throwNumber,
          'diagonal': diagonal,
          'technicalComponent': technicalComponent,
          'scoreObtained': scoreObtained,
          'observations': observations,
          'failureTags': failureTags,
          'status': status,
          'athleteId': athleteId,
          'saremasEvalId': saremasEvalId,
          'whiteBallX': whiteBallX,
          'whiteBallY': whiteBallY,
          'colorBallX': colorBallX,
          'colorBallY': colorBallY,
          'estimatedDistance': estimatedDistance,
          'launchPointX': launchPointX,
          'launchPointY': launchPointY,
          'distanceToLaunchPoint': distanceToLaunchPoint,
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

  // GET /api/AssessSaremas/GetActiveEvaluation/{teamId}/{coachId}
  Future<ActiveSaremasEvaluation?> getActiveEvaluation(
      int teamId, int coachId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_base/AssessSaremas/GetActiveEvaluation/$teamId/$coachId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          return ActiveSaremasEvaluation.fromJson(
              body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // PUT /api/AssessSaremas/UpdateState
  Future<Map<String, dynamic>?> updateState({
    required int saremasEvalId,
    required DateTime evaluationDate,
    String? description,
    required int teamId,
    String? state,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/AssessSaremas/UpdateState'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'saremasEvalId': saremasEvalId,
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

  // POST /api/AssessSaremas/Cancel
  Future<Map<String, dynamic>?> cancel({
    required int saremasEvalId,
    required int coachId,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/AssessSaremas/Cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'saremasEvalId': saremasEvalId,
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

  // GET /api/AssessSaremas/GetTeamEvaluations/{teamId}
  Future<List<SaremasEvaluationSummaryDto>?> getTeamEvaluations(
      int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/AssessSaremas/GetTeamEvaluations/$teamId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => SaremasEvaluationSummaryDto.fromJson(
                  e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/AssessSaremas/GetEvaluationDetails/{saremasEvalId}
  Future<SaremasEvaluationDetailsDto?> getEvaluationDetails(
      int saremasEvalId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_base/AssessSaremas/GetEvaluationDetails/$saremasEvalId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          return SaremasEvaluationDetailsDto.fromJson(
              body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/AssessSaremas/GetEvaluationStatistics/{saremasEvalId}
  Future<List<SaremasStatisticsDto>?> getEvaluationStatistics(
      int saremasEvalId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_base/AssessSaremas/GetEvaluationStatistics/$saremasEvalId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => SaremasStatisticsDto.fromJson(
                  e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/AssessSaremas/GetAthleteHistory/{athleteId}
  Future<SaremasAthleteHistoryDto?> getAthleteHistory(int athleteId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/AssessSaremas/GetAthleteHistory/$athleteId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          return SaremasAthleteHistoryDto.fromJson(
              body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
