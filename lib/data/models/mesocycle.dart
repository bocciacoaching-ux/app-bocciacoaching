/// Mesociclo — agrupación de microciclos dentro de un período.
/// Generalmente dura entre 3 y 6 semanas.
class Mesocycle {
  final int? mesocycleId;
  final int number;
  final String name;
  final MesocycleType type;
  final DateTime startDate;
  final DateTime endDate;
  final int weeks;
  final String? objective;
  final int? macrocycleId;

  const Mesocycle({
    this.mesocycleId,
    required this.number,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.weeks,
    this.objective,
    this.macrocycleId,
  });

  Mesocycle copyWith({
    int? mesocycleId,
    int? number,
    String? name,
    MesocycleType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? weeks,
    String? objective,
    int? macrocycleId,
  }) {
    return Mesocycle(
      mesocycleId: mesocycleId ?? this.mesocycleId,
      number: number ?? this.number,
      name: name ?? this.name,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weeks: weeks ?? this.weeks,
      objective: objective ?? this.objective,
      macrocycleId: macrocycleId ?? this.macrocycleId,
    );
  }

  Map<String, dynamic> toJson() => {
        'mesocycleId': mesocycleId,
        'number': number,
        'name': name,
        'type': type.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'weeks': weeks,
        'objective': objective,
        'macrocycleId': macrocycleId,
      };

  /// JSON para CreateMesocycleDto (sin mesocycleId, macrocycleId).
  Map<String, dynamic> toCreateJson() => {
        'number': number,
        'name': name,
        'type': type.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'weeks': weeks,
        'objective': objective,
      };

  factory Mesocycle.fromJson(Map<String, dynamic> json) {
    return Mesocycle(
      mesocycleId: json['mesocycleId'] as int?,
      number: json['number'] as int,
      name: json['name'] as String,
      type: MesocycleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MesocycleType.desarrollador,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      weeks: json['weeks'] as int,
      objective: json['objective'] as String?,
      macrocycleId: json['macrocycleId'] as int?,
    );
  }
}

/// Tipos de mesociclo.
enum MesocycleType {
  introductorio('Introductorio'),
  desarrollador('Desarrollador'),
  estabilizador('Estabilizador'),
  competitivo('Competitivo'),
  recuperacion('Recuperación'),
  precompetitivo('Pre-competitivo');

  final String label;
  const MesocycleType(this.label);
}
