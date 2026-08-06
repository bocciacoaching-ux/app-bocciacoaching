import 'dart:convert';
import '../network/http_logger.dart';
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
    required String teamId,
    required String coachId,
  }) async {
    try {
      final response = await HttpLogger.post(
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
    required String coachId,
    required String athleteId,
    required String saremasEvalId,
  }) async {
    try {
      final response = await HttpLogger.post(
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
    required String athleteId,
    required String saremasEvalId,
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
      final response = await HttpLogger.post(
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
      String teamId, String coachId) async {
    try {
      final response = await HttpLogger.get(
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
    required String saremasEvalId,
    required DateTime evaluationDate,
    String? description,
    required String teamId,
    String? state,
  }) async {
    try {
      final response = await HttpLogger.put(
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
    required String saremasEvalId,
    required String coachId,
    String? reason,
  }) async {
    try {
      final response = await HttpLogger.post(
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
      String teamId) async {
    try {
      final response = await HttpLogger.get(
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
      String saremasEvalId) async {
    try {
      final response = await HttpLogger.get(
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
      String saremasEvalId) async {
    try {
      final response = await HttpLogger.get(
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
  Future<SaremasAthleteHistoryDto?> getAthleteHistory(String athleteId) async {
    try {
      final response = await HttpLogger.get(
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

  // GET /api/AssessSaremas/CoachHasEvaluations/{coachId}
  Future<Map<String, dynamic>?> coachHasEvaluations(String coachId) async {
    try {
      final response = await HttpLogger.get(
        Uri.parse('$_base/AssessSaremas/CoachHasEvaluations/$coachId'),
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
