import 'package:flutter/material.dart';
import '../models/athlete.dart';
import '../models/saremas_throw.dart';

/// Componentes técnicos disponibles para la evaluación SAREMAS+.
const List<String> kSaremasComponents = [
  'Salida',
  'Aproximación',
  'Arrimate',
  'Contención',
  'Impacto',
  'Despeje',
  'Presión',
];

/// Provider que gestiona todo el estado de una evaluación SAREMAS+.
///
/// Son 28 lanzamientos organizados en 4 bloques de 7.
/// Diagonal alterna cada bloque: Roja → Azul → Roja → Azul.
class SaremasProvider extends ChangeNotifier {
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

  // ── Estado del lanzamiento actual ─────────────────────────────────
  int? _currentScore;
  String? _selectedComponent;
  final TextEditingController _observationsController = TextEditingController();

  // Failure tags
  bool _tagFuerza = false;
  bool _tagDireccion = false;
  bool _tagCadencia = false;
  bool _tagTrayectoria = false;

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
    if (_selectedComponent == null) return false;
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
      // Para uso local generamos un ID temporal
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

  // ── Resetear para nueva evaluación ────────────────────────────────
  Future<void> resetForNewEvaluation() async {
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

  // ── Navegación de tiros ───────────────────────────────────────────
  void nextShot() {
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
    );

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
      // Evaluación finalizada
      notifyListeners();
    }
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
    }
  }

  void _resetCurrentThrowState() {
    _currentScore = null;
    _selectedComponent = null;
    _observationsController.clear();
    _tagFuerza = false;
    _tagDireccion = false;
    _tagCadencia = false;
    _tagTrayectoria = false;
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
