/// Porcentaje de lanzamientos para un día de la semana dentro de un tipo de microciclo.
class MicrocycleDayDto {
  final String dayOfWeek;
  final int throwPercentage;
  final bool isCustom;

  const MicrocycleDayDto({
    required this.dayOfWeek,
    required this.throwPercentage,
    this.isCustom = false,
  });

  MicrocycleDayDto copyWith({
    String? dayOfWeek,
    int? throwPercentage,
    bool? isCustom,
  }) {
    return MicrocycleDayDto(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      throwPercentage: throwPercentage ?? this.throwPercentage,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'throwPercentage': throwPercentage,
        'isCustom': isCustom,
      };

  factory MicrocycleDayDto.fromJson(Map<String, dynamic> json) {
    return MicrocycleDayDto(
      dayOfWeek: json['dayOfWeek'] as String,
      throwPercentage: (json['throwPercentage'] as num).toInt(),
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}

/// Tipo de microciclo definido en el backend.
///
/// Obtenido desde GET /api/MicrocycleType/GetAll.
class MicrocycleTypeDto {
  final String microcycleTypeId;
  final String name;
  final String? description;
  final bool status;
  final List<MicrocycleDayDto> days;

  // ── Tipos por defecto ──────────────────────────────────────────────
  /// Tipos de microciclo predefinidos. Se usan como fallback cuando
  /// la API no está disponible. Solo los porcentajes son editables.
  static const List<MicrocycleTypeDto> defaultTypes = [
    MicrocycleTypeDto(
      microcycleTypeId: 'ordinario',
      name: 'Ordinario',
      description: 'Microciclo de entrenamiento regular con carga moderada.',
      status: true,
      days: [
        MicrocycleDayDto(dayOfWeek: 'Lunes',     throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Martes',    throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Miercoles', throwPercentage: 15),
        MicrocycleDayDto(dayOfWeek: 'Jueves',    throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Viernes',   throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Sabado',    throwPercentage: 5),
        MicrocycleDayDto(dayOfWeek: 'Domingo',   throwPercentage: 0),
      ],
    ),
    MicrocycleTypeDto(
      microcycleTypeId: 'choque',
      name: 'Choque',
      description: 'Microciclo de alto volumen para generar adaptaciones.',
      status: true,
      days: [
        MicrocycleDayDto(dayOfWeek: 'Lunes',     throwPercentage: 25),
        MicrocycleDayDto(dayOfWeek: 'Martes',    throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Miercoles', throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Jueves',    throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Viernes',   throwPercentage: 15),
        MicrocycleDayDto(dayOfWeek: 'Sabado',    throwPercentage: 0),
        MicrocycleDayDto(dayOfWeek: 'Domingo',   throwPercentage: 0),
      ],
    ),
    MicrocycleTypeDto(
      microcycleTypeId: 'recuperacion',
      name: 'Recuperación',
      description: 'Microciclo de baja carga para recuperación activa.',
      status: true,
      days: [
        MicrocycleDayDto(dayOfWeek: 'Lunes',     throwPercentage: 15),
        MicrocycleDayDto(dayOfWeek: 'Martes',    throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Miercoles', throwPercentage: 15),
        MicrocycleDayDto(dayOfWeek: 'Jueves',    throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Viernes',   throwPercentage: 15),
        MicrocycleDayDto(dayOfWeek: 'Sabado',    throwPercentage: 5),
        MicrocycleDayDto(dayOfWeek: 'Domingo',   throwPercentage: 0),
      ],
    ),
    MicrocycleTypeDto(
      microcycleTypeId: 'activacion',
      name: 'Activación',
      description: 'Microciclo de activación previa a competencia.',
      status: true,
      days: [
        MicrocycleDayDto(dayOfWeek: 'Lunes',     throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Martes',    throwPercentage: 15),
        MicrocycleDayDto(dayOfWeek: 'Miercoles', throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Jueves',    throwPercentage: 15),
        MicrocycleDayDto(dayOfWeek: 'Viernes',   throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Sabado',    throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Domingo',   throwPercentage: 0),
      ],
    ),
    MicrocycleTypeDto(
      microcycleTypeId: 'competitivo',
      name: 'Competitivo',
      description: 'Microciclo de semana de competencia.',
      status: true,
      days: [
        MicrocycleDayDto(dayOfWeek: 'Lunes',     throwPercentage: 15),
        MicrocycleDayDto(dayOfWeek: 'Martes',    throwPercentage: 15),
        MicrocycleDayDto(dayOfWeek: 'Miercoles', throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Jueves',    throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Viernes',   throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Sabado',    throwPercentage: 20),
        MicrocycleDayDto(dayOfWeek: 'Domingo',   throwPercentage: 20),
      ],
    ),
    MicrocycleTypeDto(
      microcycleTypeId: 'transitorio',
      name: 'Transitorio',
      description: 'Microciclo de transición y descanso activo.',
      status: true,
      days: [
        MicrocycleDayDto(dayOfWeek: 'Lunes',     throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Martes',    throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Miercoles', throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Jueves',    throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Viernes',   throwPercentage: 10),
        MicrocycleDayDto(dayOfWeek: 'Sabado',    throwPercentage: 5),
        MicrocycleDayDto(dayOfWeek: 'Domingo',   throwPercentage: 5),
      ],
    ),
  ];

  const MicrocycleTypeDto({
    required this.microcycleTypeId,
    required this.name,
    this.description,
    required this.status,
    this.days = const [],
  });

  /// Ordena los días según el orden natural de la semana en español.
  List<MicrocycleDayDto> get daysOrdered {
    const order = [
      'Lunes',
      'Martes',
      'Miercoles',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sabado',
      'Sábado',
      'Domingo',
    ];
    final sorted = [...days];
    sorted.sort((a, b) {
      final ia = order.indexWhere(
          (d) => d.toLowerCase() == a.dayOfWeek.toLowerCase());
      final ib = order.indexWhere(
          (d) => d.toLowerCase() == b.dayOfWeek.toLowerCase());
      return ia.compareTo(ib);
    });
    return sorted;
  }

  Map<String, dynamic> toJson() => {
        'microcycleTypeId': microcycleTypeId,
        'name': name,
        'description': description,
        'status': status,
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory MicrocycleTypeDto.fromJson(Map<String, dynamic> json) {
    return MicrocycleTypeDto(
      microcycleTypeId: json['microcycleTypeId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as bool? ?? true,
      days: (json['days'] as List<dynamic>? ?? [])
          .map((d) => MicrocycleDayDto.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
