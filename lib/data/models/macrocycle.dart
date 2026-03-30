import 'macrocycle_event.dart';
import 'mesocycle.dart';
import 'microcycle.dart';

/// Modelo principal del macrociclo de entrenamiento.
///
/// Un macrociclo está asociado a un atleta y define un período de
/// planificación deportiva con fecha de inicio y fin, eventos,
/// etapas (períodos), mesociclos y microciclos calculados.
///
/// Ajustado al swagger: macrocycleId es String.
class Macrocycle {
  final String id;
  final String? macrocycleId;
  final int athleteId;
  final String athleteName;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int? coachId;
  final int? teamId;
  final List<MacrocycleEvent> events;
  final List<MacrocyclePeriod> periods;
  final List<Mesocycle> mesocycles;
  final List<Microcycle> microcycles;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Macrocycle({
    required this.id,
    this.macrocycleId,
    required this.athleteId,
    required this.athleteName,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.coachId,
    this.teamId,
    this.events = const [],
    this.periods = const [],
    this.mesocycles = const [],
    this.microcycles = const [],
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Número total de semanas del macrociclo.
  int get totalWeeks =>
      endDate.difference(startDate).inDays ~/ 7 +
      (endDate.difference(startDate).inDays % 7 > 0 ? 1 : 0);

  /// Duración total en días.
  int get totalDays => endDate.difference(startDate).inDays + 1;

  Macrocycle copyWith({
    String? id,
    String? macrocycleId,
    int? athleteId,
    String? athleteName,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    int? coachId,
    int? teamId,
    List<MacrocycleEvent>? events,
    List<MacrocyclePeriod>? periods,
    List<Mesocycle>? mesocycles,
    List<Microcycle>? microcycles,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Macrocycle(
      id: id ?? this.id,
      macrocycleId: macrocycleId ?? this.macrocycleId,
      athleteId: athleteId ?? this.athleteId,
      athleteName: athleteName ?? this.athleteName,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      coachId: coachId ?? this.coachId,
      teamId: teamId ?? this.teamId,
      events: events ?? this.events,
      periods: periods ?? this.periods,
      mesocycles: mesocycles ?? this.mesocycles,
      microcycles: microcycles ?? this.microcycles,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'macrocycleId': macrocycleId,
        'athleteId': athleteId,
        'athleteName': athleteName,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'coachId': coachId,
        'teamId': teamId,
        'events': events.map((e) => e.toJson()).toList(),
        'periods': periods.map((p) => p.toJson()).toList(),
        'mesocycles': mesocycles.map((m) => m.toJson()).toList(),
        'microcycles': microcycles.map((m) => m.toJson()).toList(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Macrocycle.fromJson(Map<String, dynamic> json) {
    return Macrocycle(
      id: (json['macrocycleId'] ?? json['id'] ?? '').toString(),
      macrocycleId: json['macrocycleId']?.toString(),
      athleteId: json['athleteId'] as int,
      athleteName: json['athleteName'] as String? ?? '',
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      coachId: json['coachId'] as int?,
      teamId: json['teamId'] as int?,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) =>
                  MacrocycleEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      periods: (json['periods'] as List<dynamic>?)
              ?.map((p) =>
                  MacrocyclePeriod.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      mesocycles: (json['mesocycles'] as List<dynamic>?)
              ?.map(
                  (m) => Mesocycle.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      microcycles: (json['microcycles'] as List<dynamic>?)
              ?.map(
                  (m) => Microcycle.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// Período / etapa del macrociclo (Preparatorio General, Preparatorio
/// Especial, Competitivo, Transición).
class MacrocyclePeriod {
  final int? macrocyclePeriodId;
  final String name;
  final PeriodType type;
  final DateTime startDate;
  final DateTime endDate;
  final int weeks;
  final int? macrocycleId;

  const MacrocyclePeriod({
    this.macrocyclePeriodId,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.weeks,
    this.macrocycleId,
  });

  MacrocyclePeriod copyWith({
    int? macrocyclePeriodId,
    String? name,
    PeriodType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? weeks,
    int? macrocycleId,
  }) {
    return MacrocyclePeriod(
      macrocyclePeriodId: macrocyclePeriodId ?? this.macrocyclePeriodId,
      name: name ?? this.name,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weeks: weeks ?? this.weeks,
      macrocycleId: macrocycleId ?? this.macrocycleId,
    );
  }

  Map<String, dynamic> toJson() => {
        'macrocyclePeriodId': macrocyclePeriodId,
        'name': name,
        'type': type.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'weeks': weeks,
        'macrocycleId': macrocycleId,
      };

  factory MacrocyclePeriod.fromJson(Map<String, dynamic> json) {
    return MacrocyclePeriod(
      macrocyclePeriodId: json['macrocyclePeriodId'] as int?,
      name: json['name'] as String,
      type: PeriodType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PeriodType.preparatorioGeneral,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      weeks: json['weeks'] as int,
      macrocycleId: json['macrocycleId'] as int?,
    );
  }
}

/// Tipos de períodos del macrociclo.
enum PeriodType {
  preparatorioGeneral('Preparatorio General'),
  preparatorioEspecial('Preparatorio Especial'),
  competitivo('Competitivo'),
  transicion('Transición');

  final String label;
  const PeriodType(this.label);
}
