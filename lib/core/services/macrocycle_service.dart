import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import '../../data/models/macrocycle.dart';
import '../../data/models/macrocycle_summary.dart';

/// Servicio HTTP para el controlador Macrocycle del backend.
///
/// Endpoints alineados al swagger v1 de BocciaCoaching API.
/// Todos los macrocycleId son **String** en la API.
class MacrocycleService {
  final String _base = AppConfig.baseUrl;

  // ─── POST /api/Macrocycle/Create ────────────────────────────────
  /// Crea un macrociclo completo (con events, mesocycles, microcycles).
  /// Retorna MacrocycleResponseDtoResponseContract.
  Future<Map<String, dynamic>?> create({
    required int athleteId,
    String? athleteName,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
    required int coachId,
    required int teamId,
    List<Map<String, dynamic>>? events,
    List<Map<String, dynamic>>? mesocycles,
    List<Map<String, dynamic>>? microcycles,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Macrocycle/Create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'athleteId': athleteId,
          'athleteName': athleteName,
          'name': name,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'notes': notes,
          'coachId': coachId,
          'teamId': teamId,
          if (events != null) 'events': events,
          if (mesocycles != null) 'mesocycles': mesocycles,
          if (microcycles != null) 'microcycles': microcycles,
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

  // ─── GET /api/Macrocycle/GetByAthlete/{athleteId} ───────────────
  /// Retorna MacrocycleSummaryDtoListResponseContract.
  Future<List<MacrocycleSummaryDto>?> getByAthlete(int athleteId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Macrocycle/GetByAthlete/$athleteId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) =>
                  MacrocycleSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── GET /api/Macrocycle/GetByTeam/{teamId} ─────────────────────
  /// Retorna MacrocycleSummaryDtoListResponseContract.
  Future<List<MacrocycleSummaryDto>?> getByTeam(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Macrocycle/GetByTeam/$teamId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) =>
                  MacrocycleSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── GET /api/Macrocycle/GetById/{macrocycleId} ─────────────────
  /// macrocycleId es String. Retorna MacrocycleResponseDtoResponseContract.
  Future<Macrocycle?> getById(String macrocycleId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Macrocycle/GetById/$macrocycleId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          return Macrocycle.fromJson(body['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── PUT /api/Macrocycle/Update ─────────────────────────────────
  /// Actualiza un macrociclo (UpdateMacrocycleDto).
  /// macrocycleId es String. Puede incluir events.
  Future<Map<String, dynamic>?> update({
    required String macrocycleId,
    required int athleteId,
    String? athleteName,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
    required int coachId,
    required int teamId,
    List<Map<String, dynamic>>? events,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/Macrocycle/Update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'macrocycleId': macrocycleId,
          'athleteId': athleteId,
          'athleteName': athleteName,
          'name': name,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'notes': notes,
          'coachId': coachId,
          'teamId': teamId,
          if (events != null) 'events': events,
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

  // ─── DELETE /api/Macrocycle/Delete/{macrocycleId} ────────────────
  /// macrocycleId es String. Retorna BooleanResponseContract.
  Future<Map<String, dynamic>?> delete(String macrocycleId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_base/Macrocycle/Delete/$macrocycleId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── POST /api/Macrocycle/AddEvent ──────────────────────────────
  /// AddMacrocycleEventDto — macrocycleId es String.
  /// Retorna MacrocycleResponseDtoResponseContract.
  Future<Map<String, dynamic>?> addEvent({
    required String macrocycleId,
    required String name,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? location,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Macrocycle/AddEvent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'macrocycleId': macrocycleId,
          'name': name,
          'type': type,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'location': location,
          'notes': notes,
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

  // ─── PUT /api/Macrocycle/UpdateEvent ────────────────────────────
  /// UpdateMacrocycleEventDto — macrocycleEventId y macrocycleId son String.
  /// Retorna MacrocycleResponseDtoResponseContract.
  Future<Map<String, dynamic>?> updateEvent({
    required String macrocycleEventId,
    required String macrocycleId,
    required String name,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? location,
    String? notes,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/Macrocycle/UpdateEvent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'macrocycleEventId': macrocycleEventId,
          'macrocycleId': macrocycleId,
          'name': name,
          'type': type,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'location': location,
          'notes': notes,
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

  // ─── DELETE /api/Macrocycle/DeleteEvent/{eventId} ────────────────
  /// eventId es String. Retorna MacrocycleResponseDtoResponseContract.
  Future<Map<String, dynamic>?> deleteEvent(String eventId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_base/Macrocycle/DeleteEvent/$eventId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── PUT /api/Macrocycle/UpdateMicrocycle ────────────────────────
  /// UpdateMicrocycleDto — macrocycleId es String.
  /// Campos: microcycleId (int), macrocycleId (String), type, hasPeakPerformance,
  /// trainingDistribution.
  /// Retorna BooleanResponseContract.
  Future<Map<String, dynamic>?> updateMicrocycle({
    required int microcycleId,
    required String macrocycleId,
    String? type,
    bool? hasPeakPerformance,
    Map<String, dynamic>? trainingDistribution,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/Macrocycle/UpdateMicrocycle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'microcycleId': microcycleId,
          'macrocycleId': macrocycleId,
          if (type != null) 'type': type,
          if (hasPeakPerformance != null)
            'hasPeakPerformance': hasPeakPerformance,
          if (trainingDistribution != null)
            'trainingDistribution': trainingDistribution,
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

  // ─── GET /api/Macrocycle/GetCoachMacrocycles/{coachId} ──────────
  /// Retorna MacrocycleSummaryDtoListResponseContract.
  Future<List<MacrocycleSummaryDto>?> getCoachMacrocycles(int coachId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Macrocycle/GetCoachMacrocycles/$coachId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((e) =>
                  MacrocycleSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── POST /api/Macrocycle/Duplicate/{macrocycleId} ──────────────
  /// macrocycleId es String.
  /// Body: DuplicateMacrocycleDto con newAthleteId, newAthleteName, newStartDate.
  /// Retorna MacrocycleResponseDtoResponseContract.
  Future<Map<String, dynamic>?> duplicate(
    String macrocycleId, {
    required int newAthleteId,
    String? newAthleteName,
    DateTime? newStartDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Macrocycle/Duplicate/$macrocycleId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'newAthleteId': newAthleteId,
          'newAthleteName': newAthleteName,
          if (newStartDate != null)
            'newStartDate': newStartDate.toIso8601String(),
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
