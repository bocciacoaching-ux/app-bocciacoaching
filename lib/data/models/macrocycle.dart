import 'macrocycle_event.dart';
import 'mesocycle.dart';
import 'microcycle.dart';

/// Modelo principal del macrociclo de entrenamiento.
///
/// Un macrociclo está asociado a un atleta y define un período de
/// planificación deportiva con fecha de inicio y fin, eventos,
/// etapas (períodos), mesociclos y microciclos calculados.
class Macrocycle {
  final String id;
  final int athleteId;
  final String athleteName;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<MacrocycleEvent> events;
  final List<MacrocyclePeriod> periods;
  final List<Mesocycle> mesocycles;
  final List<Microcycle> microcycles;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Macrocycle({
    required this.id,
    required this.athleteId,
    required this.athleteName,
    required this.name,
    required this.startDate,
    required this.endDate,
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
    int? athleteId,
    String? athleteName,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
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
      athleteId: athleteId ?? this.athleteId,
      athleteName: athleteName ?? this.athleteName,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
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
        'athleteId': athleteId,
        'athleteName': athleteName,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
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
      id: json['id'] as String,
      athleteId: json['athleteId'] as int,
      athleteName: json['athleteName'] as String? ?? '',
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
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
  final String name;
  final PeriodType type;
  final DateTime startDate;
  final DateTime endDate;
  final int weeks;

  const MacrocyclePeriod({
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.weeks,
  });

  MacrocyclePeriod copyWith({
    String? name,
    PeriodType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? weeks,
  }) {
    return MacrocyclePeriod(
      name: name ?? this.name,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weeks: weeks ?? this.weeks,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'weeks': weeks,
      };

  factory MacrocyclePeriod.fromJson(Map<String, dynamic> json) {
    return MacrocyclePeriod(
      name: json['name'] as String,
      type: PeriodType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PeriodType.preparatorioGeneral,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      weeks: json['weeks'] as int,
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
