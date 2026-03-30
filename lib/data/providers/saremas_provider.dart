import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/athlete.dart';
import '../models/saremas_throw.dart';
import '../models/active_saremas_evaluation.dart';
import '../../core/services/assess_saremas_service.dart';

/// Componente técnico fijo para cada lanzamiento SAREMAS+ (1-28).
/// Los 28 lanzamientos están organizados en 4 bloques de 7:
///   Bloque 1 (1-7):  Diagonal Roja
///   Bloque 2 (8-14): Diagonal Azul
///   Bloque 3 (15-21): Diagonal Roja
///   Bloque 4 (22-28): Diagonal Azul
const Map<int, String> kSaremasComponentPerThrow = {
  // ── Bloque 1 – Diagonal Roja ──────────────────────────────────────
  1: 'Salida',
  2: 'Romper',
  3: 'Arrimar',
  4: 'Empujar A',
  5: 'Sapito Ras',
  6: 'Montar',
  7: 'Penal',
  // ── Bloque 2 – Diagonal Azul ──────────────────────────────────────
  8: 'Romper',
  9: 'Arrimar',
  10: 'Empujar F',
  11: 'Romper AE',
  12: 'Apoyar',
  13: 'Empujar A',
  14: 'Penal',
  // ── Bloque 3 – Diagonal Roja ──────────────────────────────────────
  15: 'Romper',
  16: 'Arrimar',
  17: 'Empujar A',
  18: 'Empujar LA',
  19: 'Sapito AE',
  20: 'Arrimar',
  21: 'Penal',
  // ── Bloque 4 – Diagonal Azul ──────────────────────────────────────
  22: 'Salida',
  23: 'Romper',
  24: 'Arrimar',
  25: 'Empujar A',
  26: 'Arrima R Zona',
  27: 'Libre Entrega',
  28: 'Penal',
};

/// Provider que gestiona todo el estado de una evaluación SAREMAS+.
///
/// Son 28 lanzamientos organizados en 4 bloques de 7.
/// Diagonal alterna cada bloque: Roja → Azul → Roja → Azul.
class SaremasProvider extends ChangeNotifier {
  final AssessSaremasService _service = AssessSaremasService();

  // ── Configuración ─────────────────────────────────────────────────
  static const int totalThrows = 28;
  static const int throwsPerBlock = 7;

  // ── Estado de la evaluación ───────────────────────────────────────
  int? _saremasEvalId;
  int _currentThrowIndex = 0;
  bool _isLoading = false;
  String _evaluationName = '';

  List<Athlete> _selectedAthletes = [];
  List<SaremasThrow> _completedThrows = [];

  SaremasProvider() {
    _restorePersistedId();
  }

  /// Restaura el ID de evaluación guardado en SharedPreferences.
  Future<void> _restorePersistedId() async {
    final prefs = await SharedPreferences.getInstance();
    _saremasEvalId = prefs.getInt('saremasEvalId');
    notifyListeners();
  }

  // ── Estado del lanzamiento actual ─────────────────────────────────
  int? _currentScore;
  String? _selectedComponent;
  final TextEditingController _observationsController = TextEditingController();

  // Failure tags
  bool _tagFuerza = false;
  bool _tagDireccion = false;
  bool _tagCadencia = false;
  bool _tagTrayectoria = false;

  // ── Datos de la cancha (componente "Salida") ──────────────────
  double? _whiteBallX;
  double? _whiteBallY;
  double? _colorBallX;
  double? _colorBallY;
  double? _estimatedDistance;
  double? _launchPointX;
  double? _launchPointY;
  double? _distanceToLaunchPoint;

  // ── Getters ───────────────────────────────────────────────────────
  int? get saremasEvalId => _saremasEvalId;
  int get currentThrowNumber => _currentThrowIndex + 1;
  int get currentThrowIndex => _currentThrowIndex;
  int get totalShotsCount => totalThrows;
  bool get isLoading => _isLoading;
  String get evaluationName => _evaluationName;

  List<Athlete> get selectedAthletes => _selectedAthletes;
  List<SaremasThrow> get completedThrows => _completedThrows;

  int? get currentScore => _currentScore;
  String? get selectedComponent => _selectedComponent;
  TextEditingController get observationsController => _observationsController;

  bool get tagFuerza => _tagFuerza;
  bool get tagDireccion => _tagDireccion;
  bool get tagCadencia => _tagCadencia;
  bool get tagTrayectoria => _tagTrayectoria;

  double? get whiteBallX => _whiteBallX;
  double? get whiteBallY => _whiteBallY;
  double? get colorBallX => _colorBallX;
  double? get colorBallY => _colorBallY;
  double? get estimatedDistance => _estimatedDistance;
  double? get launchPointX => _launchPointX;
  double? get launchPointY => _launchPointY;
  double? get distanceToLaunchPoint => _distanceToLaunchPoint;

  /// Indica si el componente actual es "Salida".
  bool get isSalidaComponent =>
      _selectedComponent?.toLowerCase() == 'salida';

  String get currentAthleteName =>
      _selectedAthletes.isNotEmpty ? _selectedAthletes.first.name : '';

  /// Diagonal del bloque actual basada en el índice del lanzamiento.
  /// Bloque 0 (tiros 1-7): Roja
  /// Bloque 1 (tiros 8-14): Azul
  /// Bloque 2 (tiros 15-21): Roja
  /// Bloque 3 (tiros 22-28): Azul
  String get currentDiagonal {
    final blockIndex = _currentThrowIndex ~/ throwsPerBlock;
    return blockIndex.isEven ? 'Roja' : 'Azul';
  }

  /// Número de bloque actual (1-4).
  int get currentBlock => (_currentThrowIndex ~/ throwsPerBlock) + 1;

  /// Progreso como fracción 0.0 – 1.0.
  double get progress => currentThrowNumber / totalThrows;

  /// Determina si se puede avanzar al siguiente lanzamiento.
  bool get canGoNext {
    if (_currentScore == null) return false;
    // Si el puntaje es 0, 1 o 2 → observación obligatoria
    if (_currentScore! <= 2 && _observationsController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  // ── Manejo de atletas ─────────────────────────────────────────────
  void addAthlete(Athlete athlete) {
    if (!_selectedAthletes.any((a) => a.id == athlete.id)) {
      _selectedAthletes.add(athlete);
      notifyListeners();
    }
  }

  void removeAthlete(int athleteId) {
    _selectedAthletes.removeWhere((a) => a.id == athleteId);
    notifyListeners();
  }

  // ── Iniciar evaluación ────────────────────────────────────────────
  Future<void> startNewEvaluation(
    String name,
    int teamId,
    int coachId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Crear evaluación en la API
      final result = await _service.addEvaluation(
        description: name,
        teamId: teamId,
        coachId: coachId,
      );
      final id = result != null
          ? (result['data']?['saremasEvalId'] as int?)
          : null;

      if (id != null) {
        _saremasEvalId = id;
      } else {
        // Fallback local si la API falla
        _saremasEvalId = DateTime.now().millisecondsSinceEpoch;
      }

      _evaluationName = name;

      // Persistir el ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('saremasEvalId', _saremasEvalId!);

      // Registrar atletas en la API
      for (final athlete in _selectedAthletes) {
        await _service.addAthleteToEvaluation(
          coachId: coachId,
          athleteId: athlete.id,
          saremasEvalId: _saremasEvalId!,
        );
      }

      _currentThrowIndex = 0;
      _completedThrows = [];
      _resetCurrentThrowState();
    } catch (_) {
      // Fallback local
      _saremasEvalId = DateTime.now().millisecondsSinceEpoch;
      _evaluationName = name;
      _currentThrowIndex = 0;
      _completedThrows = [];
      _resetCurrentThrowState();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Consulta la API para verificar si existe una evaluación activa
  /// para el equipo y coach dados.
  Future<ActiveSaremasEvaluation?> checkForActiveEvaluation(
      int teamId, int coachId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final activeEval = await _service.getActiveEvaluation(teamId, coachId);
      if (activeEval != null) {
        _isLoading = false;
        notifyListeners();
        return activeEval;
      }
    } catch (_) {
      // Si falla, continuamos sin evaluación activa
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  /// Reanuda una evaluación activa existente.
  Future<void> resumeEvaluation(ActiveSaremasEvaluation activeEval) async {
    _isLoading = true;
    notifyListeners();

    _saremasEvalId = activeEval.saremasEvalId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('saremasEvalId', _saremasEvalId!);

    // Restaurar atletas
    _selectedAthletes = activeEval.athletes
        .map((a) => Athlete(id: a.athleteId, name: a.name ?? ''))
        .toList();

    // Restaurar lanzamientos completados
    _completedThrows = [];
    for (final athlete in activeEval.athletes) {
      for (final t in athlete.throws_) {
        _completedThrows.add(SaremasThrow(
          throwNumber: t.throwNumber,
          diagonal: t.diagonal ?? '',
          technicalComponent: t.technicalComponent ?? '',
          scoreObtained: t.scoreObtained,
          observations: t.observations ?? '',
          failureTags: t.failureTagsList,
          whiteBallX: t.whiteBallX,
          whiteBallY: t.whiteBallY,
          colorBallX: t.colorBallX,
          colorBallY: t.colorBallY,
          estimatedDistance: t.estimatedDistance,
          launchPointX: t.launchPointX,
          launchPointY: t.launchPointY,
          distanceToLaunchPoint: t.distanceToLaunchPoint,
        ));
      }
    }

    // Posicionar en el siguiente tiro pendiente
    _currentThrowIndex = _completedThrows.length < totalThrows
        ? _completedThrows.length
        : totalThrows - 1;
    _resetCurrentThrowState();
    _loadExistingThrowIfAny();

    _isLoading = false;
    notifyListeners();
  }

  /// Cancela la evaluación activa vía API.
  Future<void> cancelEvaluation(int coachId, {String? reason}) async {
    if (_saremasEvalId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.cancel(
        saremasEvalId: _saremasEvalId!,
        coachId: coachId,
        reason: reason,
      );
    } catch (_) {
      // Continuar con reset local aunque falle la API
    }

    await resetForNewEvaluation();
    _isLoading = false;
    notifyListeners();
  }

  /// Finaliza la evaluación activa cambiando su estado vía API.
  Future<void> finalizeEvaluation(int teamId) async {
    if (_saremasEvalId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateState(
        saremasEvalId: _saremasEvalId!,
        evaluationDate: DateTime.now(),
        description: _evaluationName,
        teamId: teamId,
        state: 'Finalizado',
      );
    } catch (_) {
      // Continuamos aunque falle
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Resetear para nueva evaluación ────────────────────────────────
  Future<void> resetForNewEvaluation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saremasEvalId');
    _saremasEvalId = null;
    _currentThrowIndex = 0;
    _selectedAthletes = [];
    _completedThrows = [];
    _evaluationName = '';
    _resetCurrentThrowState();
    notifyListeners();
  }

  // ── Selección de puntaje ──────────────────────────────────────────
  void setScore(int score) {
    _currentScore = score;
    notifyListeners();
  }

  // ── Selección de componente técnico ───────────────────────────────
  void setComponent(String component) {
    _selectedComponent = component;
    notifyListeners();
  }

  // ── Toggle tags ───────────────────────────────────────────────────
  void toggleTagFuerza() {
    _tagFuerza = !_tagFuerza;
    notifyListeners();
  }

  void toggleTagDireccion() {
    _tagDireccion = !_tagDireccion;
    notifyListeners();
  }

  void toggleTagCadencia() {
    _tagCadencia = !_tagCadencia;
    notifyListeners();
  }

  void toggleTagTrayectoria() {
    _tagTrayectoria = !_tagTrayectoria;
    notifyListeners();
  }

  // ── Datos de la cancha ────────────────────────────────────────────
  void setBallPositions({
    required double whiteBallX,
    required double whiteBallY,
    required double colorBallX,
    required double colorBallY,
    required double estimatedDistance,
    double? launchPointX,
    double? launchPointY,
    double? distanceToLaunchPoint,
  }) {
    _whiteBallX = whiteBallX;
    _whiteBallY = whiteBallY;
    _colorBallX = colorBallX;
    _colorBallY = colorBallY;
    _estimatedDistance = estimatedDistance;
    _launchPointX = launchPointX;
    _launchPointY = launchPointY;
    _distanceToLaunchPoint = distanceToLaunchPoint;
    notifyListeners();
  }

  void clearBallPositions() {
    _whiteBallX = null;
    _whiteBallY = null;
    _colorBallX = null;
    _colorBallY = null;
    _estimatedDistance = null;
    _launchPointX = null;
    _launchPointY = null;
    _distanceToLaunchPoint = null;
    notifyListeners();
  }

  // ── Navegación de tiros ───────────────────────────────────────────
  Future<void> nextShot() async {
    if (!canGoNext) return;

    // Construir tags de fallo
    final tags = <String>[];
    if (_tagFuerza) tags.add('Fuerza');
    if (_tagDireccion) tags.add('Dirección');
    if (_tagCadencia) tags.add('Cadencia');
    if (_tagTrayectoria) tags.add('Trayectoria');

    final throwData = SaremasThrow(
      throwNumber: currentThrowNumber,
      diagonal: currentDiagonal,
      technicalComponent: _selectedComponent!,
      scoreObtained: _currentScore!,
      observations: _observationsController.text.trim(),
      failureTags: tags,
      whiteBallX: _whiteBallX,
      whiteBallY: _whiteBallY,
      colorBallX: _colorBallX,
      colorBallY: _colorBallY,
      estimatedDistance: _estimatedDistance,
      launchPointX: _launchPointX,
      launchPointY: _launchPointY,
      distanceToLaunchPoint: _distanceToLaunchPoint,
    );

    _isLoading = true;
    notifyListeners();

    // Enviar detalle del tiro a la API
    if (_saremasEvalId != null) {
      try {
        await _service.addDetailsToEvaluation(
          throwNumber: throwData.throwNumber,
          diagonal: throwData.diagonal,
          technicalComponent: throwData.technicalComponent,
          scoreObtained: throwData.scoreObtained,
          observations: throwData.observations,
          failureTags: tags.join(','),
          status: 'Activo',
          athleteId:
              _selectedAthletes.isNotEmpty ? _selectedAthletes.first.id : 0,
          saremasEvalId: _saremasEvalId!,
          whiteBallX: throwData.whiteBallX,
          whiteBallY: throwData.whiteBallY,
          colorBallX: throwData.colorBallX,
          colorBallY: throwData.colorBallY,
          estimatedDistance: throwData.estimatedDistance,
          launchPointX: throwData.launchPointX,
          launchPointY: throwData.launchPointY,
          distanceToLaunchPoint: throwData.distanceToLaunchPoint,
        );
      } catch (_) {
        // Continuamos aunque falle la API
      }
    }

    // Si estamos editando un tiro anterior, reemplazamos
    final existingIdx =
        _completedThrows.indexWhere((t) => t.throwNumber == currentThrowNumber);
    if (existingIdx >= 0) {
      _completedThrows[existingIdx] = throwData;
    } else {
      _completedThrows.add(throwData);
    }

    if (_currentThrowIndex < totalThrows - 1) {
      _currentThrowIndex++;
      _resetCurrentThrowState();
      _loadExistingThrowIfAny();
    } else {
      // Evaluación finalizada – limpiar persistencia
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saremasEvalId');
    }

    _isLoading = false;
    notifyListeners();
  }

  void previousShot() {
    if (_currentThrowIndex > 0) {
      _currentThrowIndex--;
      _resetCurrentThrowState();
      _loadExistingThrowIfAny();
      notifyListeners();
    }
  }

  /// Verifica si ya existe un tiro guardado para el índice actual
  /// y carga su data en el formulario.
  void _loadExistingThrowIfAny() {
    final existing = _completedThrows
        .where((t) => t.throwNumber == currentThrowNumber)
        .toList();
    if (existing.isNotEmpty) {
      final t = existing.first;
      _currentScore = t.scoreObtained;
      _selectedComponent = t.technicalComponent;
      _observationsController.text = t.observations;
      _tagFuerza = t.failureTags.contains('Fuerza');
      _tagDireccion = t.failureTags.contains('Dirección');
      _tagCadencia = t.failureTags.contains('Cadencia');
      _tagTrayectoria = t.failureTags.contains('Trayectoria');
      _whiteBallX = t.whiteBallX;
      _whiteBallY = t.whiteBallY;
      _colorBallX = t.colorBallX;
      _colorBallY = t.colorBallY;
      _estimatedDistance = t.estimatedDistance;
      _launchPointX = t.launchPointX;
      _launchPointY = t.launchPointY;
      _distanceToLaunchPoint = t.distanceToLaunchPoint;
    }
  }

  void _resetCurrentThrowState() {
    _currentScore = null;
    // El componente se asigna automáticamente según el número de lanzamiento
    _selectedComponent = kSaremasComponentPerThrow[currentThrowNumber];
    _observationsController.clear();
    _tagFuerza = false;
    _tagDireccion = false;
    _tagCadencia = false;
    _tagTrayectoria = false;
    _whiteBallX = null;
    _whiteBallY = null;
    _colorBallX = null;
    _colorBallY = null;
    _estimatedDistance = null;
    _launchPointX = null;
    _launchPointY = null;
    _distanceToLaunchPoint = null;
  }

  /// Verdadero si se completaron los 28 tiros.
  bool get isEvaluationComplete => _completedThrows.length >= totalThrows;

  /// Resumen estadístico simple.
  Map<String, dynamic> get summaryStats {
    if (_completedThrows.isEmpty) return {};
    final total = _completedThrows.fold<int>(
        0, (sum, t) => sum + t.scoreObtained);
    final avg = total / _completedThrows.length;
    return {
      'totalScore': total,
      'averageScore': avg,
      'throwsCompleted': _completedThrows.length,
      'maxPossible': totalThrows * 5,
    };
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }
}
