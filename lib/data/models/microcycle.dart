/// Microciclo — unidad mínima de planificación, generalmente 1 semana.
class Microcycle {
  final int number;
  final DateTime startDate;
  final DateTime endDate;
  final int weekNumber;
  final MicrocycleType type;
  final String? mesocycleName;
  final String? periodName;
  final String? notes;

  const Microcycle({
    required this.number,
    required this.startDate,
    required this.endDate,
    required this.weekNumber,
    required this.type,
    this.mesocycleName,
    this.periodName,
    this.notes,
  });

  /// Nombre descriptivo del microciclo.
  String get label => 'Micro $number (Sem $weekNumber)';

  Microcycle copyWith({
    int? number,
    DateTime? startDate,
    DateTime? endDate,
    int? weekNumber,
    MicrocycleType? type,
    String? mesocycleName,
    String? periodName,
    String? notes,
  }) {
    return Microcycle(
      number: number ?? this.number,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weekNumber: weekNumber ?? this.weekNumber,
      type: type ?? this.type,
      mesocycleName: mesocycleName ?? this.mesocycleName,
      periodName: periodName ?? this.periodName,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'weekNumber': weekNumber,
        'type': type.name,
        'mesocycleName': mesocycleName,
        'periodName': periodName,
        'notes': notes,
      };

  factory Microcycle.fromJson(Map<String, dynamic> json) {
    return Microcycle(
      number: json['number'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      weekNumber: json['weekNumber'] as int,
      type: MicrocycleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MicrocycleType.ordinario,
      ),
      mesocycleName: json['mesocycleName'] as String?,
      periodName: json['periodName'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// Tipos de microciclo según su carga / enfoque.
enum MicrocycleType {
  ordinario('Ordinario'),
  choque('Choque'),
  recuperacion('Recuperación'),
  activacion('Activación'),
  competitivo('Competitivo'),
  transitorio('Transitorio');

  final String label;
  const MicrocycleType(this.label);
}
