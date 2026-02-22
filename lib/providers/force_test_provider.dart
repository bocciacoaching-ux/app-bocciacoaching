import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/athlete.dart';
import '../models/force_test_config.dart';
import '../models/evaluation_throw.dart';
import '../models/assess_strength.dart';
import '../models/statistics.dart';
import '../services/assess_strength_service.dart';

class ForceTestProvider extends ChangeNotifier {
  final AssessStrengthService _service = AssessStrengthService();
  
  int? _assessStrengthId;
  int _currentShotIndex = 0;
  List<Athlete> _selectedAthletes = [];
  List<EvaluationThrow> _completedThrows = [];
  List<ForceTestConfig> _testConfig = [];
  bool _isLoading = false;

  Offset? _currentSelection;
  int? _currentScore;
  final TextEditingController _observationsController = TextEditingController();

  int? get assessStrengthId => _assessStrengthId;
  int get currentShotNumber => _currentShotIndex + 1;
  int get totalShots => _testConfig.length;
  List<Athlete> get selectedAthletes => _selectedAthletes;
  List<EvaluationThrow> get completedThrows => _completedThrows;
  bool get isLoading => _isLoading;
  
  Offset? get currentSelection => _currentSelection;
  int? get currentScore => _currentScore;
  TextEditingController get observationsController => _observationsController;
  
  ForceTestConfig? get currentShotConfig => 
      _testConfig.isNotEmpty && _currentShotIndex < _testConfig.length 
          ? _testConfig[_currentShotIndex] 
          : null;

  bool get canGoNext {
    if (_currentScore == null) return false;
    if (_currentScore! <= 2 && _observationsController.text.trim().isEmpty) return false;
    return true;
  }

  ForceTestProvider() {
    _loadConfig();
    _checkActiveEvaluation();
  }

  Future<void> _loadConfig() async {
    final String response = await rootBundle.loadString('assets/data/test.force.json');
    final data = await json.decode(response) as List;
    _testConfig = data.map((e) => ForceTestConfig.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> _checkActiveEvaluation() async {
    final prefs = await SharedPreferences.getInstance();
    _assessStrengthId = prefs.getInt('assessStrengthId');
    notifyListeners();
  }

  void setSelection(double x, double y, int score) {
    _currentSelection = Offset(x, y);
    _currentScore = score;
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

  Future<void> startNewEvaluation(String name, int teamId, int coachId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _service.createEvaluation(name, teamId, coachId);
      if (id != null) {
        _assessStrengthId = id;
      } else {
        // Fallback for demo purposes if API fails
        _assessStrengthId = DateTime.now().millisecondsSinceEpoch;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('assessStrengthId', _assessStrengthId!);
      
      // Attempt to add athletes but don't block if it fails in demo
      await _service.addAthletesToEvaluation(coachId, _selectedAthletes.map((a) => a.id).toList(), _assessStrengthId!);
      
      _currentShotIndex = 0;
      _completedThrows = [];
      _resetCurrentShotState();
    } catch (e) {
      // Final fallback to ensure we always advance
      _assessStrengthId = DateTime.now().millisecondsSinceEpoch;
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> nextShot() async {
    if (!canGoNext || currentShotConfig == null || _assessStrengthId == null) return;

    final evaluationThrow = EvaluationThrow(
      boxNumber: currentShotConfig!.boxNumber,
      throwOrder: currentShotConfig!.shotNumber,
      targetDistance: currentShotConfig!.targetDistance,
      scoreObtained: _currentScore!,
      observations: _observationsController.text,
      status: true,
      athleteId: _selectedAthletes.isNotEmpty ? _selectedAthletes.first.id : 0,
      assessStrengthId: _assessStrengthId!,
      coordinateX: _currentSelection!.dx,
      coordinateY: _currentSelection!.dy,
    );

    _isLoading = true;
    notifyListeners();

    // En modo demo permitimos avanzar aunque falle el guardado en servidor
    await _service.saveThrow(evaluationThrow);

    _completedThrows.add(evaluationThrow);
    if (_currentShotIndex < _testConfig.length - 1) {
      _currentShotIndex++;
      _resetCurrentShotState();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('assessStrengthId');
      _assessStrengthId = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void previousShot() {
    if (_currentShotIndex > 0) {
      _currentShotIndex--;
      // Load previous data if exists
      if (_completedThrows.length > _currentShotIndex) {
        final prevThrow = _completedThrows[_currentShotIndex];
        _currentSelection = Offset(prevThrow.coordinateX, prevThrow.coordinateY);
        _currentScore = prevThrow.scoreObtained;
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
    _observationsController.clear();
    notifyListeners();
  }

  Statistics get stats {
    int totalPoints = 0;
    int effectiveThrows = 0;
    int failedThrows = 0;
    
    DistanceStats short = DistanceStats(label: "Corta", hits: 0, total: 0, totalPoints: 0);
    DistanceStats medium = DistanceStats(label: "Media", hits: 0, total: 0, totalPoints: 0);
    DistanceStats long = DistanceStats(label: "Larga", hits: 0, total: 0, totalPoints: 0);
    
    List<int> distribution = List.filled(6, 0);
    List<double> blocks = List.filled(6, 0);
    List<int> blockCounts = List.filled(6, 0);

    for (var t in _completedThrows) {
      totalPoints += t.scoreObtained;
      if (t.scoreObtained >= 0 && t.scoreObtained <= 5) {
        distribution[t.scoreObtained]++;
      }
      
      bool isHit = t.scoreObtained >= 3;
      if (isHit) effectiveThrows++; else failedThrows++;

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

    double genEff = _completedThrows.isEmpty ? 0 : (totalPoints / (_completedThrows.length * 5)) * 100;
    double precision = _completedThrows.isEmpty ? 0 : (effectiveThrows / _completedThrows.length) * 100;

    return Statistics(
      generalEffectiveness: genEff,
      precision: precision,
      effectiveThrows: effectiveThrows,
      failedThrows: failedThrows,
      shortStats: short,
      mediumStats: medium,
      longStats: long,
      scoreByBlock: List.generate(6, (i) => blockCounts[i] == 0 ? 0 : blocks[i] / blockCounts[i]),
      scoreDistribution: distribution,
      coordinates: _completedThrows.map((e) => {'x': e.coordinateX, 'y': e.coordinateY}).toList(),
    );
  }

  DistanceStats _updateDistanceStats(DistanceStats current, int score) {
    return DistanceStats(
      label: current.label,
      hits: current.hits + (score >= 3 ? 1 : 0),
      total: current.total + 1,
      totalPoints: current.totalPoints + score,
    );
  }
}
