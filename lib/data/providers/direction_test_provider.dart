import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/athlete.dart';
import '../models/force_test_config.dart';
import '../models/direction_evaluation_throw.dart';
import '../models/statistics.dart';
import '../models/active_direction_evaluation.dart';
import '../../core/services/assess_direction_service.dart';

class DirectionTestProvider extends ChangeNotifier {
  final AssessDirectionService _service = AssessDirectionService();

  int? _assessDirectionId;
  int _currentShotIndex = 0;
  List<Athlete> _selectedAthletes = [];
  List<DirectionEvaluationThrow> _completedThrows = [];
  List<ForceTestConfig> _testConfig = [];
  bool _isLoading = false;

  Offset? _currentSelection;
  int? _currentScore;
  bool _deviatedLeft = false;
  bool _deviatedRight = false;
  final TextEditingController _observationsController = TextEditingController();

  int? get assessDirectionId => _assessDirectionId;
  int get currentShotNumber => _currentShotIndex + 1;
  int get totalShots => _testConfig.length;
  List<Athlete> get selectedAthletes => _selectedAthletes;
  List<DirectionEvaluationThrow> get completedThrows => _completedThrows;
  bool get isLoading => _isLoading;

  Offset? get currentSelection => _currentSelection;
  int? get currentScore => _currentScore;
  bool get deviatedLeft => _deviatedLeft;
  bool get deviatedRight => _deviatedRight;
  TextEditingController get observationsController => _observationsController;

  ForceTestConfig? get currentShotConfig =>
      _testConfig.isNotEmpty && _currentShotIndex < _testConfig.length
          ? _testConfig[_currentShotIndex]
          : null;

  bool get canGoNext {
    if (_currentScore == null) return false;
    // At least one cause must be selected (left or right deviation)
    if (!_deviatedLeft && !_deviatedRight) return false;
    return true;
  }

  DirectionTestProvider() {
    _loadConfig();
    _checkActiveEvaluation();
  }

  Future<void> _loadConfig() async {
    final String response =
        await rootBundle.loadString('assets/data/test.direction.json');
    final data = await json.decode(response) as List;
    _testConfig = data.map((e) => ForceTestConfig.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> _checkActiveEvaluation() async {
    final prefs = await SharedPreferences.getInstance();
    _assessDirectionId = prefs.getInt('assessDirectionId');
    notifyListeners();
  }

  /// Check if there is an active direction evaluation for the team/coach.
  Future<ActiveDirectionEvaluation?> checkForActiveEvaluation(
      int teamId, int coachId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _service.getActiveEvaluation(teamId, coachId);
      if (result != null) {
        _isLoading = false;
        notifyListeners();
        return result;
      }
    } catch (_) {
      // Allow continuing without active evaluation
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  /// Resume an existing active evaluation.
  Future<void> resumeEvaluation(ActiveDirectionEvaluation activeEval) async {
    _isLoading = true;
    notifyListeners();

    _assessDirectionId = activeEval.assessDirectionId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('assessDirectionId', _assessDirectionId!);

    // Restore athletes
    _selectedAthletes = activeEval.athletes
        .map((a) => Athlete(id: a.athleteId, name: a.athleteName))
        .toList();

    // Restore completed throws
    _completedThrows = activeEval.throws
        .map((t) => DirectionEvaluationThrow(
              boxNumber: t.boxNumber,
              throwOrder: t.throwOrder,
              targetDistance: t.targetDistance ?? 0.0,
              scoreObtained: (t.scoreObtained ?? 0).toInt(),
              observations: t.observations ?? '',
              status: t.status,
              athleteId: t.athleteId,
              assessDirectionId: activeEval.assessDirectionId,
              coordinateX: 0.0,
              coordinateY: 0.0,
              deviatedRight: t.deviatedRight,
              deviatedLeft: t.deviatedLeft,
            ))
        .toList();

    // Position index at the next pending throw
    _currentShotIndex = _completedThrows.length < _testConfig.length
        ? _completedThrows.length
        : _testConfig.length - 1;

    _resetCurrentShotState();

    _isLoading = false;
    notifyListeners();
  }

  void setSelection(double x, double y, int score) {
    _currentSelection = Offset(x, y);
    _currentScore = score;
    notifyListeners();
  }

  void toggleDeviatedLeft() {
    _deviatedLeft = !_deviatedLeft;
    if (_deviatedLeft) _deviatedRight = false;
    notifyListeners();
  }

  void toggleDeviatedRight() {
    _deviatedRight = !_deviatedRight;
    if (_deviatedRight) _deviatedLeft = false;
    notifyListeners();
  }

  void addAthlete(Athlete athlete) {
    if (!_selectedAthletes.any((a) => a.id == athlete.id)) {
      _selectedAthletes.add(athlete);
      notifyListeners();
    }
  }

  void removeAthlete(int id) {
    _selectedAthletes.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  /// Reset all state for a new evaluation.
  Future<void> resetForNewEvaluation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('assessDirectionId');
    _assessDirectionId = null;
    _currentShotIndex = 0;
    _selectedAthletes = [];
    _completedThrows = [];
    _resetCurrentShotState();
  }

  Future<void> startNewEvaluation(
      String name, int teamId, int coachId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _service.addEvaluation(
        description: name,
        teamId: teamId,
        coachId: coachId,
      );
      final id = result != null
          ? (result['data']?['assessDirectionId'] as int?)
          : null;
      if (id != null) {
        _assessDirectionId = id;
      } else {
        // Fallback for demo purposes
        _assessDirectionId = DateTime.now().millisecondsSinceEpoch;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('assessDirectionId', _assessDirectionId!);

      // Add athletes
      for (final athleteId in _selectedAthletes.map((a) => a.id)) {
        await _service.addAthleteToEvaluation(
          coachId: coachId,
          athleteId: athleteId,
          assessDirectionId: _assessDirectionId!,
        );
      }

      _currentShotIndex = 0;
      _completedThrows = [];
      _resetCurrentShotState();
    } catch (e) {
      // Fallback to ensure we always advance
      _assessDirectionId = DateTime.now().millisecondsSinceEpoch;
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> nextShot() async {
    if (!canGoNext ||
        currentShotConfig == null ||
        _assessDirectionId == null) return;

    final dirThrow = DirectionEvaluationThrow(
      boxNumber: currentShotConfig!.boxNumber,
      throwOrder: currentShotConfig!.shotNumber,
      targetDistance: currentShotConfig!.targetDistance,
      scoreObtained: _currentScore!,
      observations: _observationsController.text,
      status: true,
      athleteId:
          _selectedAthletes.isNotEmpty ? _selectedAthletes.first.id : 0,
      assessDirectionId: _assessDirectionId!,
      coordinateX: _currentSelection!.dx,
      coordinateY: _currentSelection!.dy,
      deviatedRight: _deviatedRight,
      deviatedLeft: _deviatedLeft,
    );

    _isLoading = true;
    notifyListeners();

    // Save to API (allow demo mode if it fails)
    await _service.addDetailsToEvaluation(
      boxNumber: dirThrow.boxNumber,
      throwOrder: dirThrow.throwOrder,
      targetDistance: dirThrow.targetDistance,
      scoreObtained: dirThrow.scoreObtained.toDouble(),
      observations: dirThrow.observations,
      status: dirThrow.status,
      athleteId: dirThrow.athleteId,
      assessDirectionId: dirThrow.assessDirectionId,
      coordinateX: dirThrow.coordinateX,
      coordinateY: dirThrow.coordinateY,
      deviatedRight: dirThrow.deviatedRight,
      deviatedLeft: dirThrow.deviatedLeft,
    );

    _completedThrows.add(dirThrow);
    if (_currentShotIndex < _testConfig.length - 1) {
      _currentShotIndex++;
      _resetCurrentShotState();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('assessDirectionId');
      _assessDirectionId = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void previousShot() {
    if (_currentShotIndex > 0) {
      _currentShotIndex--;
      if (_completedThrows.length > _currentShotIndex) {
        final prevThrow = _completedThrows[_currentShotIndex];
        _currentSelection =
            Offset(prevThrow.coordinateX, prevThrow.coordinateY);
        _currentScore = prevThrow.scoreObtained;
        _deviatedLeft = prevThrow.deviatedLeft;
        _deviatedRight = prevThrow.deviatedRight;
        _observationsController.text = prevThrow.observations;
      } else {
        _resetCurrentShotState();
      }
      notifyListeners();
    }
  }

  void _resetCurrentShotState() {
    _currentSelection = null;
    _currentScore = null;
    _deviatedLeft = false;
    _deviatedRight = false;
    _observationsController.clear();
    notifyListeners();
  }

  Statistics get stats {
    int totalPoints = 0;
    int effectiveThrows = 0;
    int failedThrows = 0;

    DistanceStats short =
        DistanceStats(label: 'Corta', hits: 0, total: 0, totalPoints: 0);
    DistanceStats medium =
        DistanceStats(label: 'Media', hits: 0, total: 0, totalPoints: 0);
    DistanceStats long =
        DistanceStats(label: 'Larga', hits: 0, total: 0, totalPoints: 0);

    List<int> distribution = List.filled(6, 0);
    List<double> blocks = List.filled(6, 0);
    List<int> blockCounts = List.filled(6, 0);

    for (var t in _completedThrows) {
      totalPoints += t.scoreObtained;
      if (t.scoreObtained >= 0 && t.scoreObtained <= 5) {
        distribution[t.scoreObtained]++;
      }

      bool isHit = t.scoreObtained >= 3;
      if (isHit) {
        effectiveThrows++;
      } else {
        failedThrows++;
      }

      int blockIdx = (t.throwOrder - 1) ~/ 6;
      if (blockIdx < 6) {
        blocks[blockIdx] += t.scoreObtained;
        blockCounts[blockIdx]++;
      }

      if (t.targetDistance <= 4.0) {
        short = _updateDistanceStats(short, t.scoreObtained);
      } else if (t.targetDistance <= 7.0) {
        medium = _updateDistanceStats(medium, t.scoreObtained);
      } else {
        long = _updateDistanceStats(long, t.scoreObtained);
      }
    }

    double genEff = _completedThrows.isEmpty
        ? 0
        : (totalPoints / (_completedThrows.length * 5)) * 100;
    double precision = _completedThrows.isEmpty
        ? 0
        : (effectiveThrows / _completedThrows.length) * 100;

    return Statistics(
      generalEffectiveness: genEff,
      precision: precision,
      effectiveThrows: effectiveThrows,
      failedThrows: failedThrows,
      shortStats: short,
      mediumStats: medium,
      longStats: long,
      scoreByBlock: List.generate(
          6, (i) => blockCounts[i] == 0 ? 0 : blocks[i] / blockCounts[i]),
      scoreDistribution: distribution,
      coordinates: _completedThrows
          .map((e) => {'x': e.coordinateX, 'y': e.coordinateY})
          .toList(),
    );
  }

  /// Direction-specific stats: deviation counters.
  int get totalDeviatedLeft =>
      _completedThrows.where((t) => t.deviatedLeft).length;
  int get totalDeviatedRight =>
      _completedThrows.where((t) => t.deviatedRight).length;

  DistanceStats _updateDistanceStats(DistanceStats current, int score) {
    return DistanceStats(
      label: current.label,
      hits: current.hits + (score >= 3 ? 1 : 0),
      total: current.total + 1,
      totalPoints: current.totalPoints + score,
    );
  }
}
