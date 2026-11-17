import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../network/http_logger.dart';
import '../constants/app_config.dart';
import '../constants/api_endpoints.dart';
import '../../data/models/daily_wellness.dart';

/// Resultado de una escritura de wellness (crear / actualizar).
class WellnessResult {
  final bool success;
  final DailyWellness? data;
  final int? statusCode;
  final String? message;

  const WellnessResult({
    required this.success,
    this.data,
    this.statusCode,
    this.message,
  });

  /// 409: el atleta ya registró su test de ese día.
  bool get isConflict => statusCode == 409;
}

/// Servicio HTTP para el recurso Wellness del backend (API v1).
///
/// Respuestas envueltas en `{ success, message, data }`.
/// Errores: 400 (validación), 404 / 409 (`ProblemDetails`), 500.
class WellnessService {
  final String _base = AppConfig.baseUrl;

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$_base$path');
    return (query == null || query.isEmpty)
        ? uri
        : uri.replace(queryParameters: query);
  }

  /// Formato `yyyy-MM-dd` que espera el backend para fechas en ruta/query.
  static String formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  // ─── POST /api/v1/wellness ──────────────────────────────────────
  /// Registra el test diario. 201 → creado; 409 → ya existe el de ese día.
  Future<WellnessResult> addDailyWellness(DailyWellness wellness) async {
    try {
      final response = await HttpLogger.post(
        _uri(ApiEndpoints.wellness),
        headers: _headers,
        body: jsonEncode(wellness.toCreateJson()),
      );
      return _toResult(response);
    } catch (e) {
      debugPrint('[WellnessService] addDailyWellness error: $e');
      return WellnessResult(success: false, message: e.toString());
    }
  }

  // ─── PUT /api/v1/wellness/{dailyWellnessId} ─────────────────────
  Future<WellnessResult> updateDailyWellness(DailyWellness wellness) async {
    final id = wellness.dailyWellnessId;
    if (id == null || id.isEmpty) {
      return const WellnessResult(
          success: false, message: 'dailyWellnessId es requerido');
    }
    try {
      final response = await HttpLogger.put(
        _uri(ApiEndpoints.wellnessById(id)),
        headers: _headers,
        body: jsonEncode(wellness.toUpdateJson()),
      );
      return _toResult(response);
    } catch (e) {
      debugPrint('[WellnessService] updateDailyWellness error: $e');
      return WellnessResult(success: false, message: e.toString());
    }
  }

  // ─── GET /api/v1/athletes/{athleteId}/wellness/today ────────────
  /// `null` si el atleta aún no registra el test de hoy (404).
  Future<DailyWellness?> getTodayWellness(String athleteId) {
    return _getSingle(ApiEndpoints.athleteWellnessToday(athleteId));
  }

  // ─── GET /api/v1/athletes/{athleteId}/wellness/{date} ───────────
  Future<DailyWellness?> getWellnessByDate(String athleteId, DateTime date) {
    return _getSingle(
        ApiEndpoints.athleteWellnessByDate(athleteId, formatDate(date)));
  }

  // ─── GET /api/v1/wellness/{dailyWellnessId} ─────────────────────
  Future<DailyWellness?> getWellnessById(String dailyWellnessId) {
    return _getSingle(ApiEndpoints.wellnessById(dailyWellnessId));
  }

  // ─── GET /api/v1/athletes/{athleteId}/wellness ──────────────────
  Future<WellnessAthleteHistory?> getAthleteHistory(String athleteId) async {
    final path = ApiEndpoints.athleteWellness(athleteId);
    try {
      final response = await HttpLogger.get(_uri(path), headers: _headers);
      if (response.statusCode == 200) {
        final body = _decodeMap(response);
        final data = body?['data'];
        if (body?['success'] == true && data is Map<String, dynamic>) {
          return WellnessAthleteHistory.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[WellnessService] GET $path error: $e');
      return null;
    }
  }

  // ─── GET /api/v1/teams/{teamId}/wellness?date= ──────────────────
  /// Tests del equipo para [date] (por defecto, hoy).
  Future<List<DailyWellness>?> getTeamWellnessByDate(String teamId,
      [DateTime? date]) async {
    final path = ApiEndpoints.teamWellness(teamId);
    try {
      final response = await HttpLogger.get(
        _uri(path, date != null ? {'date': formatDate(date)} : null),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final body = _decodeMap(response);
        if (body?['success'] == true && body?['data'] is List) {
          return (body!['data'] as List)
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

  // ─── Helpers ────────────────────────────────────────────────────
  Map<String, dynamic>? _decodeMap(http.Response r) {
    if (r.body.isEmpty) return null;
    final decoded = jsonDecode(r.body);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  WellnessResult _toResult(http.Response response) {
    Map<String, dynamic>? body;
    try {
      body = _decodeMap(response);
    } catch (_) {}
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    final data = body?['data'];
    // `message` en el contrato estándar; `detail`/`title` en ProblemDetails.
    final message = (body?['message'] ?? body?['detail'] ?? body?['title'])
        ?.toString();
    return WellnessResult(
      success: ok && body?['success'] != false,
      data: data is Map<String, dynamic> ? DailyWellness.fromJson(data) : null,
      statusCode: response.statusCode,
      message: message,
    );
  }

  Future<DailyWellness?> _getSingle(String path) async {
    try {
      final response = await HttpLogger.get(_uri(path), headers: _headers);
      if (response.statusCode == 200) {
        final body = _decodeMap(response);
        final data = body?['data'];
        if (body?['success'] == true && data is Map<String, dynamic>) {
          return DailyWellness.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[WellnessService] GET $path error: $e');
      return null;
    }
  }
}
