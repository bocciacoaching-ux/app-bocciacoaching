import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/http_logger.dart';
import '../constants/app_config.dart';
import '../constants/api_endpoints.dart';
import '../../data/models/daily_wellness.dart';

/// Servicio HTTP para el controlador Wellness del backend.
class WellnessService {
  final String _base = AppConfig.baseUrl;

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // ─── POST /api/Wellness/AddDailyWellness ────────────────────────
  Future<bool> addDailyWellness(DailyWellness wellness) async {
    try {
      final response = await HttpLogger.post(
        Uri.parse('$_base${ApiEndpoints.wellnessAddDailyWellness}'),
        headers: _headers,
        body: jsonEncode(wellness.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[WellnessService] addDailyWellness error: $e');
      return false;
    }
  }

  // ─── PUT /api/Wellness/UpdateDailyWellness ──────────────────────
  Future<bool> updateDailyWellness(DailyWellness wellness) async {
    try {
      final response = await HttpLogger.put(
        Uri.parse('$_base${ApiEndpoints.wellnessUpdateDailyWellness}'),
        headers: _headers,
        body: jsonEncode(wellness.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[WellnessService] updateDailyWellness error: $e');
      return false;
    }
  }

  // ─── GET /api/Wellness/GetTodayWellness/{athleteId} ─────────────
  Future<DailyWellness?> getTodayWellness(String athleteId) async {
    return _getSingle(ApiEndpoints.wellnessGetTodayWellness(athleteId));
  }

  // ─── GET /api/Wellness/GetWellnessByDate/{athleteId}/{date} ─────
  Future<DailyWellness?> getWellnessByDate(
      String athleteId, String date) async {
    return _getSingle(ApiEndpoints.wellnessGetWellnessByDate(athleteId, date));
  }

  // ─── GET /api/Wellness/GetWellnessById/{dailyWellnessId} ────────
  Future<DailyWellness?> getWellnessById(String dailyWellnessId) async {
    return _getSingle(ApiEndpoints.wellnessGetWellnessById(dailyWellnessId));
  }

  // ─── GET /api/Wellness/GetAthleteHistory/{athleteId} ────────────
  Future<List<DailyWellness>?> getAthleteHistory(String athleteId) async {
    return _getList(ApiEndpoints.wellnessGetAthleteHistory(athleteId));
  }

  // ─── GET /api/Wellness/GetTeamWellnessByDate/{teamId}/{date} ────
  Future<List<DailyWellness>?> getTeamWellnessByDate(
      String teamId, String date) async {
    return _getList(ApiEndpoints.wellnessGetTeamWellnessByDate(teamId, date));
  }

  // ─── Helpers ────────────────────────────────────────────────────
  Future<DailyWellness?> _getSingle(String path) async {
    try {
      final response = await HttpLogger.get(
        Uri.parse('$_base$path'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          return DailyWellness.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[WellnessService] GET $path error: $e');
      return null;
    }
  }

  Future<List<DailyWellness>?> _getList(String path) async {
    try {
      final response = await HttpLogger.get(
        Uri.parse('$_base$path'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => DailyWellness.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (e) {
      debugPrint('[WellnessService] GET $path error: $e');
      return null;
    }
  }
}
