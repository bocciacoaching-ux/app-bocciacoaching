/// Distribución porcentual de entrenamiento para un microciclo.
class TrainingDistribution {
  final double fisicaGeneral;
  final double fisicaEspecial;
  final double tecnica;
  final double tactica;
  final double teorica;
  final double psicologica;

  const TrainingDistribution({
    this.fisicaGeneral = 0.0,
    this.fisicaEspecial = 0.0,
    this.tecnica = 0.0,
    this.tactica = 0.0,
    this.teorica = 0.0,
    this.psicologica = 0.0,
  });

  /// Total debe sumar 1.0 (100%).
  double get total =>
      fisicaGeneral + fisicaEspecial + tecnica + tactica + teorica + psicologica;

  TrainingDistribution copyWith({
    double? fisicaGeneral,
    double? fisicaEspecial,
    double? tecnica,
    double? tactica,
    double? teorica,
    double? psicologica,
  }) {
    return TrainingDistribution(
      fisicaGeneral: fisicaGeneral ?? this.fisicaGeneral,
      fisicaEspecial: fisicaEspecial ?? this.fisicaEspecial,
      tecnica: tecnica ?? this.tecnica,
      tactica: tactica ?? this.tactica,
      teorica: teorica ?? this.teorica,
      psicologica: psicologica ?? this.psicologica,
    );
  }

  Map<String, double> toMap() => {
        'FISICA GENERAL': fisicaGeneral,
        'FISICA ESPECIAL': fisicaEspecial,
        'TÉCNICA': tecnica,
        'TÁTICA': tactica,
        'TEÓRICA': teorica,
        'PSICOLÓGICA': psicologica,
      };

  Map<String, dynamic> toJson() => {
        'fisicaGeneral': fisicaGeneral,
        'fisicaEspecial': fisicaEspecial,
        'tecnica': tecnica,
        'tactica': tactica,
        'teorica': teorica,
        'psicologica': psicologica,
      };

  factory TrainingDistribution.fromJson(Map<String, dynamic> json) {
    return TrainingDistribution(
      fisicaGeneral: (json['fisicaGeneral'] as num?)?.toDouble() ?? 0.0,
      fisicaEspecial: (json['fisicaEspecial'] as num?)?.toDouble() ?? 0.0,
      tecnica: (json['tecnica'] as num?)?.toDouble() ?? 0.0,
      tactica: (json['tactica'] as num?)?.toDouble() ?? 0.0,
      teorica: (json['teorica'] as num?)?.toDouble() ?? 0.0,
      psicologica: (json['psicologica'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Distribuciones por tipo de microciclo, basadas en el formato Macro 2026.
  /// Los porcentajes provienen del Excel de referencia.
  static TrainingDistribution forMicrocycleType(MicrocycleType type) {
    switch (type) {
      case MicrocycleType.ordinario: // μ2 – Ordinario
        return const TrainingDistribution(
          fisicaGeneral: 0.15,
          fisicaEspecial: 0.15,
          tecnica: 0.20,
          tactica: 0.20,
          teorica: 0.20,
          psicologica: 0.10,
        );
      case MicrocycleType.choque: // μ4 – Choque (Volumen)
        return const TrainingDistribution(
          fisicaGeneral: 0.25,
          fisicaEspecial: 0.20,
          tecnica: 0.25,
          tactica: 0.10,
          teorica: 0.10,
          psicologica: 0.10,
        );
      case MicrocycleType.recuperacion: // μ7 – Recuperación
        return const TrainingDistribution(
          fisicaGeneral: 0.05,
          fisicaEspecial: 0.05,
          tecnica: 0.10,
          tactica: 0.15,
          teorica: 0.60,
          psicologica: 0.05,
        );
      case MicrocycleType.activacion: // μ3 – Estabilizador
        return const TrainingDistribution(
          fisicaGeneral: 0.10,
          fisicaEspecial: 0.10,
          tecnica: 0.15,
          tactica: 0.25,
          teorica: 0.25,
          psicologica: 0.15,
        );
      case MicrocycleType.competitivo: // μ5/μ6 – Choque Intensidad/Competencia
        return const TrainingDistribution(
          fisicaGeneral: 0.05,
          fisicaEspecial: 0.05,
          tecnica: 0.10,
          tactica: 0.30,
          teorica: 0.25,
          psicologica: 0.25,
        );
      case MicrocycleType.transitorio: // Transición / TO
        return const TrainingDistribution(
          fisicaGeneral: 0.25,
          fisicaEspecial: 0.15,
          tecnica: 0.30,
          tactica: 0.15,
          teorica: 0.10,
          psicologica: 0.05,
        );
    }
  }
}

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
  final TrainingDistribution trainingDistribution;

  const Microcycle({
    required this.number,
    required this.startDate,
    required this.endDate,
    required this.weekNumber,
    required this.type,
    this.mesocycleName,
    this.periodName,
    this.notes,
    this.trainingDistribution = const TrainingDistribution(),
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
    TrainingDistribution? trainingDistribution,
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
      trainingDistribution: trainingDistribution ?? this.trainingDistribution,
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
        'trainingDistribution': trainingDistribution.toJson(),
      };

  factory Microcycle.fromJson(Map<String, dynamic> json) {
    final type = MicrocycleType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MicrocycleType.ordinario,
    );
    return Microcycle(
      number: json['number'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      weekNumber: json['weekNumber'] as int,
      type: type,
      mesocycleName: json['mesocycleName'] as String?,
      periodName: json['periodName'] as String?,
      notes: json['notes'] as String?,
      trainingDistribution: json['trainingDistribution'] != null
          ? TrainingDistribution.fromJson(
              json['trainingDistribution'] as Map<String, dynamic>)
          : TrainingDistribution.forMicrocycleType(type),
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
