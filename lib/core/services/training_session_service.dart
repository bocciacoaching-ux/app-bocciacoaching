import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import '../../data/models/training_session.dart';

/// Servicio HTTP para el controlador TrainingSession del backend.
///
/// Endpoints alineados al swagger v1 de BocciaCoaching API.
/// Gestiona sesiones de entrenamiento, sus partes y secciones.
class TrainingSessionService {
  final String _base = AppConfig.baseUrl;

  // ─── POST /api/TrainingSession/Create ───────────────────────────
  /// Crea una sesión de entrenamiento completa con partes y secciones.
  /// Retorna TrainingSessionResponseDtoResponseContract.
  Future<TrainingSession?> create({
    required int microcycleId,
    String? dayOfWeek,
    required int duration,
    DateTime? startTime,
    DateTime? endTime,
    required double throwPercentage,
    required int totalThrowsBase,
    List<Map<String, dynamic>>? parts,
  }) async {
    try {
      final body = {
        'microcycleId': microcycleId,
        'dayOfWeek': dayOfWeek,
        'duration': duration,
        if (startTime != null) 'startTime': startTime.toIso8601String(),
        if (endTime != null) 'endTime': endTime.toIso8601String(),
        'throwPercentage': throwPercentage,
        'totalThrowsBase': totalThrowsBase,
        if (parts != null) 'parts': parts,
      };
      debugPrint(
          '[TrainingSessionService] POST Create body: ${jsonEncode(body)}');
      final response = await http.post(
        Uri.parse('$_base/TrainingSession/Create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint(
          '[TrainingSessionService] Create status: ${response.statusCode}');
      debugPrint(
          '[TrainingSessionService] Create response: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          return TrainingSession.fromJson(
              decoded['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TrainingSessionService] Create error: $e');
      return null;
    }
  }

  /// Crea una sesión directamente desde un objeto TrainingSession.
  Future<TrainingSession?> createFromSession(TrainingSession session) async {
    return create(
      microcycleId: session.microcycleId,
      dayOfWeek: session.dayOfWeek,
      duration: session.duration,
      startTime: session.startTime,
      endTime: session.endTime,
      throwPercentage: session.throwPercentage,
      totalThrowsBase: session.totalThrowsBase,
      parts: session.parts.map((p) => p.toCreateJson()).toList(),
    );
  }

  // ─── GET /api/TrainingSession/GetById/{sessionId} ───────────────
  /// Retorna TrainingSessionResponseDtoResponseContract.
  Future<TrainingSession?> getById(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/TrainingSession/GetById/$sessionId'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          return TrainingSession.fromJson(
              decoded['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TrainingSessionService] GetById error: $e');
      return null;
    }
  }

  // ─── GET /api/TrainingSession/GetByMicrocycle/{microcycleId} ────
  /// Retorna TrainingSessionSummaryDtoListResponseContract.
  Future<List<TrainingSessionSummary>?> getByMicrocycle(
      int microcycleId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/TrainingSession/GetByMicrocycle/$microcycleId'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((e) => TrainingSessionSummary.fromJson(
                  e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TrainingSessionService] GetByMicrocycle error: $e');
      return null;
    }
  }

  // ─── PUT /api/TrainingSession/Update ────────────────────────────
  /// Actualiza una sesión existente (UpdateTrainingSessionDto).
  /// Retorna TrainingSessionResponseDtoResponseContract.
  Future<TrainingSession?> update({
    required int trainingSessionId,
    String? status,
    int? duration,
    DateTime? startTime,
    DateTime? endTime,
    double? throwPercentage,
    int? totalThrowsBase,
    String? dayOfWeek,
  }) async {
    try {
      final body = {
        'trainingSessionId': trainingSessionId,
        if (status != null) 'status': status,
        if (duration != null) 'duration': duration,
        if (startTime != null) 'startTime': startTime.toIso8601String(),
        if (endTime != null) 'endTime': endTime.toIso8601String(),
        if (throwPercentage != null) 'throwPercentage': throwPercentage,
        if (totalThrowsBase != null) 'totalThrowsBase': totalThrowsBase,
        if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
      };
      final response = await http.put(
        Uri.parse('$_base/TrainingSession/Update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          return TrainingSession.fromJson(
              decoded['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TrainingSessionService] Update error: $e');
      return null;
    }
  }

  /// Actualiza desde un objeto TrainingSession.
  Future<TrainingSession?> updateFromSession(TrainingSession session) async {
    if (session.trainingSessionId == null) return null;
    return update(
      trainingSessionId: session.trainingSessionId!,
      status: session.status,
      duration: session.duration,
      startTime: session.startTime,
      endTime: session.endTime,
      throwPercentage: session.throwPercentage,
      totalThrowsBase: session.totalThrowsBase,
      dayOfWeek: session.dayOfWeek,
    );
  }

  // ─── DELETE /api/TrainingSession/Delete/{sessionId} ─────────────
  /// Retorna BooleanResponseContract.
  Future<bool> delete(int sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_base/TrainingSession/Delete/$sessionId'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['success'] == true && decoded['data'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('[TrainingSessionService] Delete error: $e');
      return false;
    }
  }

  // ─── POST /api/TrainingSession/AddSection ───────────────────────
  /// Agrega una sección a una parte de sesión (AddSessionSectionDto).
  /// Retorna SessionSectionResponseDtoResponseContract.
  Future<SessionSection?> addSection({
    required int sessionPartId,
    String? name,
    required int numberOfThrows,
    required bool isOwnDiagonal,
    DateTime? startTime,
    DateTime? endTime,
    String? observation,
  }) async {
    try {
      final body = {
        'sessionPartId': sessionPartId,
        'name': name,
        'numberOfThrows': numberOfThrows,
        'isOwnDiagonal': isOwnDiagonal,
        if (startTime != null) 'startTime': startTime.toIso8601String(),
        if (endTime != null) 'endTime': endTime.toIso8601String(),
        'observation': observation,
      };
      final response = await http.post(
        Uri.parse('$_base/TrainingSession/AddSection'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          return SessionSection.fromJson(
              decoded['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TrainingSessionService] AddSection error: $e');
      return null;
    }
  }

  /// Agrega una sección directamente desde un objeto SessionSection.
  Future<SessionSection?> addSectionFromModel(SessionSection section) async {
    return addSection(
      sessionPartId: section.sessionPartId,
      name: section.name,
      numberOfThrows: section.numberOfThrows,
      isOwnDiagonal: section.isOwnDiagonal,
      startTime: section.startTime,
      endTime: section.endTime,
      observation: section.observation,
    );
  }

  // ─── PUT /api/TrainingSession/UpdateSection ─────────────────────
  /// Actualiza una sección existente (UpdateSessionSectionDto).
  /// Retorna SessionSectionResponseDtoResponseContract.
  Future<SessionSection?> updateSection({
    required int sessionSectionId,
    String? name,
    int? numberOfThrows,
    String? status,
    bool? isOwnDiagonal,
    DateTime? startTime,
    DateTime? endTime,
    String? observation,
  }) async {
    try {
      final body = {
        'sessionSectionId': sessionSectionId,
        if (name != null) 'name': name,
        if (numberOfThrows != null) 'numberOfThrows': numberOfThrows,
        if (status != null) 'status': status,
        if (isOwnDiagonal != null) 'isOwnDiagonal': isOwnDiagonal,
        if (startTime != null) 'startTime': startTime.toIso8601String(),
        if (endTime != null) 'endTime': endTime.toIso8601String(),
        'observation': observation,
      };
      final response = await http.put(
        Uri.parse('$_base/TrainingSession/UpdateSection'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          return SessionSection.fromJson(
              decoded['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TrainingSessionService] UpdateSection error: $e');
      return null;
    }
  }

  /// Actualiza una sección desde un objeto SessionSection.
  Future<SessionSection?> updateSectionFromModel(
      SessionSection section) async {
    if (section.sessionSectionId == null) return null;
    return updateSection(
      sessionSectionId: section.sessionSectionId!,
      name: section.name,
      numberOfThrows: section.numberOfThrows,
      status: section.status,
      isOwnDiagonal: section.isOwnDiagonal,
      startTime: section.startTime,
      endTime: section.endTime,
      observation: section.observation,
    );
  }

  // ─── DELETE /api/TrainingSession/DeleteSection/{sectionId} ──────
  /// Retorna BooleanResponseContract.
  Future<bool> deleteSection(int sectionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_base/TrainingSession/DeleteSection/$sectionId'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['success'] == true && decoded['data'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('[TrainingSessionService] DeleteSection error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Endpoints de Atleta — /api/TrainingSession/Athlete/*
  // ═══════════════════════════════════════════════════════════════════

  // ─── POST /api/TrainingSession/Athlete/GetSessionsByDateRange ───
  /// Obtiene las sesiones planificadas para un atleta en un rango de fechas.
  /// Body: GetAthleteSessionsDto { athleteId, startDate, endDate }.
  /// Retorna AthleteSessionSummaryDtoListResponseContract.
  Future<List<AthleteSessionSummary>?> getAthleteSessionsByDateRange({
    required int athleteId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final body = {
        'athleteId': athleteId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
      debugPrint(
          '[TrainingSessionService] POST Athlete/GetSessionsByDateRange body: ${jsonEncode(body)}');
      final response = await http.post(
        Uri.parse('$_base/TrainingSession/Athlete/GetSessionsByDateRange'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint(
          '[TrainingSessionService] GetSessionsByDateRange status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((e) => AthleteSessionSummary.fromJson(
                  e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (e) {
      debugPrint(
          '[TrainingSessionService] GetSessionsByDateRange error: $e');
      return null;
    }
  }

  // ─── GET /api/TrainingSession/Athlete/GetSessionDetail/{sessionId}/{athleteId}
  /// Obtiene el detalle completo de una sesión para un atleta específico.
  /// Retorna TrainingSessionResponseDtoResponseContract.
  Future<TrainingSession?> getAthleteSessionDetail({
    required int sessionId,
    required int athleteId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_base/TrainingSession/Athlete/GetSessionDetail/$sessionId/$athleteId'),
      );
      debugPrint(
          '[TrainingSessionService] GetSessionDetail status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          return TrainingSession.fromJson(
              decoded['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint(
          '[TrainingSessionService] GetSessionDetail error: $e');
      return null;
    }
  }

  // ─── PUT /api/TrainingSession/Athlete/StartSession ──────────────
  /// Un atleta inicia una sesión de entrenamiento.
  /// Body: AthleteUpdateSessionStatusDto { trainingSessionId, athleteId }.
  /// Retorna TrainingSessionResponseDtoResponseContract.
  Future<TrainingSession?> athleteStartSession({
    required int trainingSessionId,
    required int athleteId,
  }) async {
    try {
      final body = {
        'trainingSessionId': trainingSessionId,
        'athleteId': athleteId,
      };
      debugPrint(
          '[TrainingSessionService] PUT Athlete/StartSession body: ${jsonEncode(body)}');
      final response = await http.put(
        Uri.parse('$_base/TrainingSession/Athlete/StartSession'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint(
          '[TrainingSessionService] StartSession status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          return TrainingSession.fromJson(
              decoded['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TrainingSessionService] StartSession error: $e');
      return null;
    }
  }

  // ─── PUT /api/TrainingSession/Athlete/FinishSession ─────────────
  /// Un atleta finaliza una sesión de entrenamiento.
  /// Body: AthleteUpdateSessionStatusDto { trainingSessionId, athleteId }.
  /// Retorna TrainingSessionResponseDtoResponseContract.
  Future<TrainingSession?> athleteFinishSession({
    required int trainingSessionId,
    required int athleteId,
  }) async {
    try {
      final body = {
        'trainingSessionId': trainingSessionId,
        'athleteId': athleteId,
      };
      debugPrint(
          '[TrainingSessionService] PUT Athlete/FinishSession body: ${jsonEncode(body)}');
      final response = await http.put(
        Uri.parse('$_base/TrainingSession/Athlete/FinishSession'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint(
          '[TrainingSessionService] FinishSession status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['success'] == true && decoded['data'] != null) {
          return TrainingSession.fromJson(
              decoded['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('[TrainingSessionService] FinishSession error: $e');
      return null;
    }
  }
}
