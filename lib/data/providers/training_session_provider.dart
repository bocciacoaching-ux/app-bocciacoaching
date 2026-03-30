import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/training_session.dart';
import '../../core/services/training_session_service.dart';

/// Provider que gestiona el estado de las sesiones de entrenamiento.
///
/// Maneja la comunicación con la API y persistencia local como fallback.
/// Las sesiones están vinculadas a microciclos y contienen partes y secciones.
class TrainingSessionProvider extends ChangeNotifier {
  static const _kStorageKey = 'training_sessions_data';

  final TrainingSessionService _service = TrainingSessionService();

  /// Sesiones cargadas para el microciclo actual.
  List<TrainingSessionSummary> _sessionSummaries = [];

  /// Sesión completa actualmente seleccionada/editándose.
  TrainingSession? _currentSession;

  /// Microciclo actualmente seleccionado.
  int? _currentMicrocycleId;

  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────

  List<TrainingSessionSummary> get sessionSummaries =>
      List.unmodifiable(_sessionSummaries);
  TrainingSession? get currentSession => _currentSession;
  int? get currentMicrocycleId => _currentMicrocycleId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSessions => _sessionSummaries.isNotEmpty;

  /// Resúmenes filtrados por día de la semana.
  List<TrainingSessionSummary> sessionsForDay(String dayOfWeek) =>
      _sessionSummaries
          .where((s) => s.dayOfWeek == dayOfWeek)
          .toList();

  /// Días de la semana que ya tienen sesión programada.
  Set<String> get scheduledDays =>
      _sessionSummaries
          .where((s) => s.dayOfWeek != null)
          .map((s) => s.dayOfWeek!)
          .toSet();

  // ── Cargar sesiones de un microciclo ───────────────────────────────

  /// Carga las sesiones de un microciclo desde la API.
  Future<void> loadSessionsForMicrocycle(int microcycleId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentMicrocycleId = microcycleId;
    notifyListeners();

    try {
      final summaries = await _service.getByMicrocycle(microcycleId);
      if (summaries != null) {
        _sessionSummaries = summaries;
        await _saveLocally(microcycleId);
      } else {
        // Fallback a local
        await _loadLocally(microcycleId);
      }
    } catch (e) {
      debugPrint('[TrainingSessionProvider] loadSessions error: $e');
      await _loadLocally(microcycleId);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Obtener sesión completa ────────────────────────────────────────

  /// Carga una sesión completa por su ID (con partes y secciones).
  Future<TrainingSession?> loadFullSession(int sessionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _service.getById(sessionId);
      if (session != null) {
        _currentSession = session;
      }
    } catch (e) {
      debugPrint('[TrainingSessionProvider] loadFullSession error: $e');
      _errorMessage = 'Error al cargar la sesión: $e';
    }

    _isLoading = false;
    notifyListeners();
    return _currentSession;
  }

  // ── Crear sesión ───────────────────────────────────────────────────

  /// Crea una nueva sesión de entrenamiento.
  ///
  /// Retorna `null` en éxito, o un mensaje de error.
  Future<String?> createSession(TrainingSession session) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _service.createFromSession(session);
      if (created != null) {
        _currentSession = created;
        // Refrescar lista de resúmenes
        if (_currentMicrocycleId != null) {
          await loadSessionsForMicrocycle(_currentMicrocycleId!);
        }
        _isLoading = false;
        notifyListeners();
        return null; // éxito
      }
      _isLoading = false;
      _errorMessage = 'No se pudo crear la sesión';
      notifyListeners();
      return _errorMessage;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al crear la sesión: $e';
      notifyListeners();
      return _errorMessage;
    }
  }

  /// Crea una sesión con las 4 partes predeterminadas (vacías).
  Future<String?> createSessionWithDefaultParts({
    required int microcycleId,
    required String dayOfWeek,
    required int duration,
    required double throwPercentage,
    required int totalThrowsBase,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final defaultParts = [
      SessionPart(name: SessionPartType.propulsion.label, order: 1),
      SessionPart(name: SessionPartType.saremas.label, order: 2),
      SessionPart(name: SessionPartType.dosContraUno.label, order: 3),
      SessionPart(name: SessionPartType.escenariosDeJuego.label, order: 4),
    ];

    final session = TrainingSession(
      microcycleId: microcycleId,
      dayOfWeek: dayOfWeek,
      duration: duration,
      throwPercentage: throwPercentage,
      totalThrowsBase: totalThrowsBase,
      startTime: startTime,
      endTime: endTime,
      parts: defaultParts,
    );

    return createSession(session);
  }

  // ── Actualizar sesión ──────────────────────────────────────────────

  /// Actualiza una sesión de entrenamiento existente.
  Future<String?> updateSession(TrainingSession session) async {
    if (session.trainingSessionId == null) {
      return 'La sesión no tiene ID';
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _service.updateFromSession(session);
      if (updated != null) {
        _currentSession = updated;
        // Refrescar lista
        if (_currentMicrocycleId != null) {
          await loadSessionsForMicrocycle(_currentMicrocycleId!);
        }
        _isLoading = false;
        notifyListeners();
        return null;
      }
      _isLoading = false;
      _errorMessage = 'No se pudo actualizar la sesión';
      notifyListeners();
      return _errorMessage;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar: $e';
      notifyListeners();
      return _errorMessage;
    }
  }

  /// Actualiza el estado de una sesión.
  Future<String?> updateSessionStatus(
      int sessionId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _service.update(
        trainingSessionId: sessionId,
        status: newStatus,
      );
      if (updated != null) {
        _currentSession = updated;
        if (_currentMicrocycleId != null) {
          await loadSessionsForMicrocycle(_currentMicrocycleId!);
        }
        _isLoading = false;
        notifyListeners();
        return null;
      }
      _isLoading = false;
      notifyListeners();
      return 'No se pudo actualizar el estado';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Error: $e';
    }
  }

  // ── Eliminar sesión ────────────────────────────────────────────────

  /// Elimina una sesión de entrenamiento.
  Future<bool> deleteSession(int sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _service.delete(sessionId);
      if (success) {
        _sessionSummaries.removeWhere(
            (s) => s.trainingSessionId == sessionId);
        if (_currentSession?.trainingSessionId == sessionId) {
          _currentSession = null;
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('[TrainingSessionProvider] deleteSession error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Gestión de secciones ───────────────────────────────────────────

  /// Agrega una sección a una parte de la sesión actual.
  Future<SessionSection?> addSection({
    required int sessionPartId,
    required String name,
    required int numberOfThrows,
    required bool isOwnDiagonal,
    DateTime? startTime,
    DateTime? endTime,
    String? observation,
  }) async {
    try {
      final section = await _service.addSection(
        sessionPartId: sessionPartId,
        name: name,
        numberOfThrows: numberOfThrows,
        isOwnDiagonal: isOwnDiagonal,
        startTime: startTime,
        endTime: endTime,
        observation: observation,
      );
      if (section != null && _currentSession != null) {
        // Recargar la sesión completa para reflejar el cambio
        await loadFullSession(_currentSession!.trainingSessionId!);
      }
      return section;
    } catch (e) {
      debugPrint('[TrainingSessionProvider] addSection error: $e');
      return null;
    }
  }

  /// Actualiza una sección existente.
  Future<SessionSection?> updateSection(SessionSection section) async {
    if (section.sessionSectionId == null) return null;

    try {
      final updated = await _service.updateSectionFromModel(section);
      if (updated != null && _currentSession != null) {
        await loadFullSession(_currentSession!.trainingSessionId!);
      }
      return updated;
    } catch (e) {
      debugPrint('[TrainingSessionProvider] updateSection error: $e');
      return null;
    }
  }

  /// Elimina una sección.
  Future<bool> deleteSection(int sectionId) async {
    try {
      final success = await _service.deleteSection(sectionId);
      if (success && _currentSession != null) {
        await loadFullSession(_currentSession!.trainingSessionId!);
      }
      return success;
    } catch (e) {
      debugPrint('[TrainingSessionProvider] deleteSection error: $e');
      return false;
    }
  }

  // ── Utilidades ─────────────────────────────────────────────────────

  /// Limpia la sesión actual seleccionada.
  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }

  /// Limpia todo el estado.
  void clear() {
    _sessionSummaries = [];
    _currentSession = null;
    _currentMicrocycleId = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Persistencia local (fallback) ─────────────────────────────────

  Future<void> _saveLocally(int microcycleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _sessionSummaries.map((s) => s.toJson()).toList();
      await prefs.setString(
          '${_kStorageKey}_$microcycleId', jsonEncode(data));
    } catch (_) {}
  }

  Future<void> _loadLocally(int microcycleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('${_kStorageKey}_$microcycleId');
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _sessionSummaries = list
            .map((e) => TrainingSessionSummary.fromJson(
                e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }
}
