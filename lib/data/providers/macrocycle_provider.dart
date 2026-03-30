import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/macrocycle.dart';
import '../models/macrocycle_event.dart';
import '../models/macrocycle_summary.dart';
import '../models/mesocycle.dart';
import '../models/microcycle.dart';
import '../../core/services/macrocycle_service.dart';

/// Provider que gestiona el estado de los macrociclos.
///
/// Maneja la persistencia local, cálculo de períodos, mesociclos
/// y microciclos, así como la lista completa de macrociclos.
class MacrocycleProvider extends ChangeNotifier {
  static const _kStorageKey = 'macrocycles_data';

  final MacrocycleService _service = MacrocycleService();

  List<Macrocycle> _macrocycles = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────

  List<Macrocycle> get macrocycles => List.unmodifiable(_macrocycles);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMacrocycles => _macrocycles.isNotEmpty;

  /// Retorna macrociclos filtrados por atleta.
  List<Macrocycle> macrocyclesForAthlete(int athleteId) =>
      _macrocycles.where((m) => m.athleteId == athleteId).toList();

  // ── Persistencia ───────────────────────────────────────────────────

  /// Carga los macrociclos desde la API (por equipo) con fallback a local.
  Future<void> loadMacrocycles({int? teamId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Intentar cargar desde la API si se tiene teamId
      if (teamId != null) {
        final List<MacrocycleSummaryDto>? summaries = await _service.getByTeam(teamId);
        if (summaries != null && summaries.isNotEmpty) {
          // Obtener cada macrociclo completo por su ID
          final fullMacrocycles = <Macrocycle>[];
          for (final summary in summaries) {
            if (summary.macrocycleId != null) {
              final full = await _service.getById(summary.macrocycleId!);
              if (full != null) {
                fullMacrocycles.add(full);
              }
            }
          }
          if (fullMacrocycles.isNotEmpty) {
            _macrocycles = fullMacrocycles;
            // Sincronizar a local
            await _save();
            _isLoading = false;
            notifyListeners();
            return;
          }
        }
      }

      // Fallback: cargar desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _macrocycles = list
            .map((e) => Macrocycle.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Si la API falla, intentar cargar localmente
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_kStorageKey);
        if (raw != null) {
          final list = jsonDecode(raw) as List<dynamic>;
          _macrocycles = list
              .map((e) => Macrocycle.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (localError) {
        _errorMessage = 'Error al cargar macrociclos: $localError';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Guarda los macrociclos en SharedPreferences.
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _macrocycles.map((m) => m.toJson()).toList();
    await prefs.setString(_kStorageKey, jsonEncode(data));
  }

  // ── CRUD ───────────────────────────────────────────────────────────

  /// Agrega un macrociclo nuevo: envía a la API y persiste localmente.
  Future<void> addMacrocycle(Macrocycle macrocycle) async {
    // Intentar crear en la API
    try {
      final result = await _service.create(
        name: macrocycle.name,
        athleteId: macrocycle.athleteId,
        athleteName: macrocycle.athleteName,
        coachId: macrocycle.coachId ?? 0,
        teamId: macrocycle.teamId ?? 0,
        startDate: macrocycle.startDate,
        endDate: macrocycle.endDate,
        notes: macrocycle.notes,
        events: macrocycle.events
            .map((e) => e.toJson())
            .toList(),
        mesocycles: macrocycle.mesocycles
            .map((m) => m.toJson())
            .toList(),
        microcycles: macrocycle.microcycles
            .map((m) => m.toJson())
            .toList(),
      );
      if (result != null && result['data'] != null) {
        final apiId = result['data']['macrocycleId']?.toString();
        if (apiId != null) {
          // Actualizar el macrociclo con el ID de la API
          final updated = macrocycle.copyWith(macrocycleId: apiId);
          _macrocycles.add(updated);
          await _save();
          notifyListeners();
          return;
        }
      }
    } catch (_) {
      // Fallback: guardar solo localmente
    }

    _macrocycles.add(macrocycle);
    await _save();
    notifyListeners();
  }

  /// Actualiza un macrociclo existente: envía a la API y persiste localmente.
  Future<void> updateMacrocycle(Macrocycle macrocycle) async {
    final index = _macrocycles.indexWhere((m) => m.id == macrocycle.id);
    if (index >= 0) {
      // Intentar actualizar en la API si tiene macrocycleId
      if (macrocycle.macrocycleId != null) {
        try {
          await _service.update(
            macrocycleId: macrocycle.macrocycleId!,
            name: macrocycle.name,
            athleteId: macrocycle.athleteId,
            athleteName: macrocycle.athleteName,
            coachId: macrocycle.coachId ?? 0,
            teamId: macrocycle.teamId ?? 0,
            startDate: macrocycle.startDate,
            endDate: macrocycle.endDate,
            notes: macrocycle.notes,
            events: macrocycle.events
                .map((e) => e.toJson())
                .toList(),
          );
        } catch (_) {
          // Continuamos con persistencia local
        }
      }

      _macrocycles[index] = macrocycle;
      await _save();
      notifyListeners();
    }
  }

  /// Elimina un macrociclo por ID: llama a la API y lo remueve localmente.
  Future<void> deleteMacrocycle(String id) async {
    final target = _macrocycles.firstWhere(
      (m) => m.id == id,
      orElse: () => _macrocycles.first,
    );

    // Si tiene macrocycleId de la API, eliminarlo allí también
    if (target.macrocycleId != null) {
      try {
        await _service.delete(target.macrocycleId!);
      } catch (_) {
        // Continuamos con eliminación local
      }
    }

    _macrocycles.removeWhere((m) => m.id == id);
    await _save();
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════
  // LÓGICA DE CÁLCULO DEL MACROCICLO
  // ══════════════════════════════════════════════════════════════════

  /// Construye un macrociclo completo a partir de los datos base.
  ///
  /// Calcula automáticamente:
  /// 1. Los microciclos (semanas) entre startDate y endDate.
  /// 2. Los períodos (etapas) basados en los eventos.
  /// 3. Los mesociclos agrupando microciclos en bloques de 4 semanas.
  static Macrocycle buildMacrocycle({
    required String id,
    required int athleteId,
    required String athleteName,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required List<MacrocycleEvent> events,
    String? notes,
  }) {
    // Normalizar fechas al inicio de semana (lunes)
    final normalizedStart = _startOfWeek(startDate);
    final normalizedEnd = endDate;

    // 1. Calcular microciclos (semanas)
    final microcycles =
        _calculateMicrocycles(normalizedStart, normalizedEnd, events);

    // 2. Calcular períodos (etapas)
    final periods =
        _calculatePeriods(normalizedStart, normalizedEnd, events);

    // 3. Calcular mesociclos
    final mesocycles = _calculateMesocycles(microcycles, periods);

    // Asignar período y mesociclo a cada microciclo
    final enrichedMicrocycles = _enrichMicrocycles(
      microcycles,
      periods,
      mesocycles,
    );

    return Macrocycle(
      id: id,
      athleteId: athleteId,
      athleteName: athleteName,
      name: name,
      startDate: normalizedStart,
      endDate: normalizedEnd,
      events: events,
      periods: periods,
      mesocycles: mesocycles,
      microcycles: enrichedMicrocycles,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  /// Lunes más reciente (o el mismo día si ya es lunes).
  static DateTime _startOfWeek(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }

  /// Calcula los microciclos (uno por semana) entre dos fechas.
  static List<Microcycle> _calculateMicrocycles(
    DateTime start,
    DateTime end,
    List<MacrocycleEvent> events,
  ) {
    final microcycles = <Microcycle>[];
    var current = start;
    int number = 1;
    int weekNum = _weekOfYear(start);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final weekEnd = current.add(const Duration(days: 6));
      final actualEnd = weekEnd.isAfter(end) ? end : weekEnd;

      // Determinar tipo según eventos de la semana
      final type = _microcycleTypeForWeek(current, actualEnd, events);

      microcycles.add(Microcycle(
        number: number,
        startDate: current,
        endDate: actualEnd,
        weekNumber: weekNum,
        type: type,
      ));

      current = current.add(const Duration(days: 7));
      number++;
      weekNum++;
    }

    return microcycles;
  }

  /// Determina el tipo de microciclo según los eventos que caen en esa semana.
  static MicrocycleType _microcycleTypeForWeek(
    DateTime weekStart,
    DateTime weekEnd,
    List<MacrocycleEvent> events,
  ) {
    for (final event in events) {
      // Si el evento se solapa con la semana
      if (event.startDate.isBefore(weekEnd.add(const Duration(days: 1))) &&
          event.endDate
              .isAfter(weekStart.subtract(const Duration(days: 1)))) {
        switch (event.type) {
          case EventType.competencia:
            return MicrocycleType.competitivo;
          case EventType.descanso:
            return MicrocycleType.recuperacion;
          case EventType.evaluacion:
            return MicrocycleType.activacion;
          default:
            break;
        }
      }
    }
    return MicrocycleType.ordinario;
  }

  /// Calcula las etapas / períodos del macrociclo.
  ///
  /// Distribución basada en los eventos:
  /// - Desde el inicio hasta 2 semanas antes de la primera competencia → Preparatorio General
  /// - 2 semanas antes de cada competencia → Preparatorio Especial
  /// - Semanas de competencia → Competitivo
  /// - Después de la última competencia → Transición
  static List<MacrocyclePeriod> _calculatePeriods(
    DateTime start,
    DateTime end,
    List<MacrocycleEvent> events,
  ) {
    final competitions = events
        .where((e) => e.type == EventType.competencia)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final periods = <MacrocyclePeriod>[];
    final totalWeeks =
        (end.difference(start).inDays / 7).ceil().clamp(1, 999);

    if (competitions.isEmpty) {
      // Sin competencias: todo es preparatorio general
      periods.add(MacrocyclePeriod(
        name: PeriodType.preparatorioGeneral.label,
        type: PeriodType.preparatorioGeneral,
        startDate: start,
        endDate: end,
        weeks: totalWeeks,
      ));
      return periods;
    }

    var currentDate = start;

    for (int i = 0; i < competitions.length; i++) {
      final comp = competitions[i];
      final preCompStart =
          comp.startDate.subtract(const Duration(days: 14));

      // Preparatorio General/Especial antes de la competencia
      if (currentDate.isBefore(preCompStart)) {
        // Preparatorio General
        final prepGenEnd =
            preCompStart.subtract(const Duration(days: 1));
        if (currentDate.isBefore(prepGenEnd) ||
            currentDate.isAtSameMomentAs(prepGenEnd)) {
          final weeks =
              (prepGenEnd.difference(currentDate).inDays / 7).ceil();
          if (weeks > 0) {
            periods.add(MacrocyclePeriod(
              name: i == 0
                  ? PeriodType.preparatorioGeneral.label
                  : PeriodType.preparatorioEspecial.label,
              type: i == 0
                  ? PeriodType.preparatorioGeneral
                  : PeriodType.preparatorioEspecial,
              startDate: currentDate,
              endDate: prepGenEnd,
              weeks: weeks,
            ));
            currentDate =
                prepGenEnd.add(const Duration(days: 1));
          }
        }

        // Preparatorio Especial (2 semanas antes)
        final prepEspEnd =
            comp.startDate.subtract(const Duration(days: 1));
        final prepEspWeeks =
            (prepEspEnd.difference(currentDate).inDays / 7).ceil();
        if (prepEspWeeks > 0) {
          periods.add(MacrocyclePeriod(
            name: PeriodType.preparatorioEspecial.label,
            type: PeriodType.preparatorioEspecial,
            startDate: currentDate,
            endDate: prepEspEnd,
            weeks: prepEspWeeks,
          ));
          currentDate = prepEspEnd.add(const Duration(days: 1));
        }
      }

      // Período Competitivo
      final compWeeks =
          (comp.endDate.difference(comp.startDate).inDays / 7).ceil().clamp(1, 999);
      periods.add(MacrocyclePeriod(
        name: PeriodType.competitivo.label,
        type: PeriodType.competitivo,
        startDate: comp.startDate,
        endDate: comp.endDate,
        weeks: compWeeks,
      ));
      currentDate = comp.endDate.add(const Duration(days: 1));
    }

    // Transición: después de la última competencia hasta el final
    if (currentDate.isBefore(end) ||
        currentDate.isAtSameMomentAs(end)) {
      final transWeeks =
          (end.difference(currentDate).inDays / 7).ceil().clamp(1, 999);
      periods.add(MacrocyclePeriod(
        name: PeriodType.transicion.label,
        type: PeriodType.transicion,
        startDate: currentDate,
        endDate: end,
        weeks: transWeeks,
      ));
    }

    return periods;
  }

  /// Calcula mesociclos agrupando microciclos en bloques de 4 semanas
  /// alineados a los períodos.
  static List<Mesocycle> _calculateMesocycles(
    List<Microcycle> microcycles,
    List<MacrocyclePeriod> periods,
  ) {
    if (microcycles.isEmpty) return [];

    final mesocycles = <Mesocycle>[];
    int mesoNumber = 1;
    int microIndex = 0;
    const weeksPerMeso = 4;

    for (final period in periods) {
      // Microciclos que caen en este período
      final periodMicros = <Microcycle>[];
      while (microIndex < microcycles.length) {
        final micro = microcycles[microIndex];
        if (micro.startDate.isBefore(
                period.endDate.add(const Duration(days: 1))) &&
            micro.endDate.isAfter(
                period.startDate.subtract(const Duration(days: 1)))) {
          periodMicros.add(micro);
          microIndex++;
        } else {
          break;
        }
      }

      // Agrupar en mesociclos de ~4 semanas
      for (int i = 0; i < periodMicros.length; i += weeksPerMeso) {
        final end = (i + weeksPerMeso <= periodMicros.length)
            ? i + weeksPerMeso
            : periodMicros.length;
        final chunk = periodMicros.sublist(i, end);

        if (chunk.isEmpty) continue;

        final mesoType = _mesoTypeFromPeriod(period.type);

        mesocycles.add(Mesocycle(
          number: mesoNumber,
          name: 'Meso $mesoNumber – ${mesoType.label}',
          type: mesoType,
          startDate: chunk.first.startDate,
          endDate: chunk.last.endDate,
          weeks: chunk.length,
          objective: _defaultObjective(mesoType),
        ));

        mesoNumber++;
      }
    }

    return mesocycles;
  }

  /// Tipo de mesociclo según el período al que pertenece.
  static MesocycleType _mesoTypeFromPeriod(PeriodType periodType) {
    switch (periodType) {
      case PeriodType.preparatorioGeneral:
        return MesocycleType.desarrollador;
      case PeriodType.preparatorioEspecial:
        return MesocycleType.precompetitivo;
      case PeriodType.competitivo:
        return MesocycleType.competitivo;
      case PeriodType.transicion:
        return MesocycleType.recuperacion;
    }
  }

  /// Objetivo por defecto según el tipo de mesociclo.
  static String _defaultObjective(MesocycleType type) {
    switch (type) {
      case MesocycleType.introductorio:
        return 'Adaptación y evaluación inicial';
      case MesocycleType.desarrollador:
        return 'Desarrollo de capacidades físicas y técnicas';
      case MesocycleType.estabilizador:
        return 'Consolidación de las cargas de trabajo';
      case MesocycleType.competitivo:
        return 'Máximo rendimiento competitivo';
      case MesocycleType.recuperacion:
        return 'Regeneración y descanso activo';
      case MesocycleType.precompetitivo:
        return 'Preparación específica para la competencia';
    }
  }

  /// Enriquece microciclos con el nombre de su período y mesociclo,
  /// y asigna la distribución de entrenamiento según el tipo de microciclo.
  static List<Microcycle> _enrichMicrocycles(
    List<Microcycle> microcycles,
    List<MacrocyclePeriod> periods,
    List<Mesocycle> mesocycles,
  ) {
    return microcycles.map((micro) {
      String? periodName;
      String? mesoName;

      for (final period in periods) {
        if (!micro.startDate.isAfter(period.endDate) &&
            !micro.endDate.isBefore(period.startDate)) {
          periodName = period.name;
          break;
        }
      }

      for (final meso in mesocycles) {
        if (!micro.startDate.isAfter(meso.endDate) &&
            !micro.endDate.isBefore(meso.startDate)) {
          mesoName = meso.name;
          break;
        }
      }

      // Asignar distribución de entrenamiento según tipo de microciclo
      final distribution =
          TrainingDistribution.forMicrocycleType(micro.type);

      return micro.copyWith(
        periodName: periodName,
        mesocycleName: mesoName,
        trainingDistribution: distribution,
      );
    }).toList();
  }

  /// Número de la semana del año.
  static int _weekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    return (daysDiff / 7).ceil() + 1;
  }
}
