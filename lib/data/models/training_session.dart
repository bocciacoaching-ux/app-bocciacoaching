// Modelos para Sesiones de Entrenamiento (TrainingSession).
//
// Cada microciclo se compone de sesiones vinculadas a días de la semana.
// Una sesión tiene partes (Propulsion, Saremas, 2x1, Escenarios de juego),
// y cada parte tiene secciones con detalle de lanzamientos.
//
// Alineado al swagger v1 de BocciaCoaching API.

// ─────────────────────────────────────────────────────────────────────
// SessionSection — sección dentro de una parte de sesión
// ─────────────────────────────────────────────────────────────────────

/// Estado de una sección de sesión.
enum SessionSectionStatus {
  programada('Programada'),
  enProceso('EnProceso'),
  terminada('Terminada'),
  finalizada('Finalizada'),
  cancelada('Cancelada');

  final String label;
  const SessionSectionStatus(this.label);
}

/// Sección de una parte de sesión de entrenamiento.
///
/// Contiene nombre, número de lanzamientos, estado, si es diagonal propia
/// o del rival, horarios e información de observación.
class SessionSection {
  final int? sessionSectionId;
  final int sessionPartId;
  final String? name;
  final int numberOfThrows;
  final String? status;
  final bool isOwnDiagonal;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? observation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SessionSection({
    this.sessionSectionId,
    required this.sessionPartId,
    this.name,
    this.numberOfThrows = 0,
    this.status,
    this.isOwnDiagonal = true,
    this.startTime,
    this.endTime,
    this.observation,
    this.createdAt,
    this.updatedAt,
  });

  SessionSection copyWith({
    int? sessionSectionId,
    int? sessionPartId,
    String? name,
    int? numberOfThrows,
    String? status,
    bool? isOwnDiagonal,
    DateTime? startTime,
    DateTime? endTime,
    String? observation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionSection(
      sessionSectionId: sessionSectionId ?? this.sessionSectionId,
      sessionPartId: sessionPartId ?? this.sessionPartId,
      name: name ?? this.name,
      numberOfThrows: numberOfThrows ?? this.numberOfThrows,
      status: status ?? this.status,
      isOwnDiagonal: isOwnDiagonal ?? this.isOwnDiagonal,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      observation: observation ?? this.observation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// JSON completo de respuesta (SessionSectionResponseDto).
  Map<String, dynamic> toJson() => {
        'sessionSectionId': sessionSectionId,
        'sessionPartId': sessionPartId,
        'name': name,
        'numberOfThrows': numberOfThrows,
        'status': status,
        'isOwnDiagonal': isOwnDiagonal,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'observation': observation,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  /// JSON para AddSessionSectionDto (crear sección).
  Map<String, dynamic> toCreateJson() => {
        'sessionPartId': sessionPartId,
        'name': name,
        'numberOfThrows': numberOfThrows,
        'isOwnDiagonal': isOwnDiagonal,
        if (startTime != null) 'startTime': startTime!.toIso8601String(),
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        'observation': observation,
      };

  /// JSON para UpdateSessionSectionDto (actualizar sección).
  Map<String, dynamic> toUpdateJson() => {
        'sessionSectionId': sessionSectionId,
        if (name != null) 'name': name,
        'numberOfThrows': numberOfThrows,
        if (status != null) 'status': status,
        'isOwnDiagonal': isOwnDiagonal,
        if (startTime != null) 'startTime': startTime!.toIso8601String(),
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        'observation': observation,
      };

  factory SessionSection.fromJson(Map<String, dynamic> json) {
    return SessionSection(
      sessionSectionId: json['sessionSectionId'] as int?,
      sessionPartId: json['sessionPartId'] as int? ?? 0,
      name: json['name'] as String?,
      numberOfThrows: json['numberOfThrows'] as int? ?? 0,
      status: json['status'] as String?,
      isOwnDiagonal: json['isOwnDiagonal'] as bool? ?? true,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      observation: json['observation'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// SessionPart — parte de una sesión (Propulsion, Saremas, 2x1, Escenarios)
// ─────────────────────────────────────────────────────────────────────

/// Las 4 partes estándar de una sesión de entrenamiento.
enum SessionPartType {
  propulsion('Propulsion'),
  saremas('Saremas'),
  dosContraUno('2x1'),
  escenariosDeJuego('Escenarios de juego');

  final String label;
  const SessionPartType(this.label);
}

/// Parte de una sesión de entrenamiento.
///
/// Una sesión se divide en 4 partes: Propulsion, Saremas, 2x1 y
/// Escenarios de juego. Cada parte contiene múltiples secciones.
class SessionPart {
  final int? sessionPartId;
  final String? name;
  final int order;
  final DateTime? createdAt;
  final List<SessionSection> sections;

  const SessionPart({
    this.sessionPartId,
    this.name,
    required this.order,
    this.createdAt,
    this.sections = const [],
  });

  /// Número total de lanzamientos asignados en todas las secciones.
  int get totalThrows =>
      sections.fold(0, (sum, s) => sum + s.numberOfThrows);

  SessionPart copyWith({
    int? sessionPartId,
    String? name,
    int? order,
    DateTime? createdAt,
    List<SessionSection>? sections,
  }) {
    return SessionPart(
      sessionPartId: sessionPartId ?? this.sessionPartId,
      name: name ?? this.name,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      sections: sections ?? this.sections,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionPartId': sessionPartId,
        'name': name,
        'order': order,
        'createdAt': createdAt?.toIso8601String(),
        'sections': sections.map((s) => s.toJson()).toList(),
      };

  /// JSON para CreateSessionPartDto (al crear sesión).
  Map<String, dynamic> toCreateJson() => {
        'name': name,
        'order': order,
        'sections': sections.map((s) => {
              'name': s.name,
              'numberOfThrows': s.numberOfThrows,
              'isOwnDiagonal': s.isOwnDiagonal,
              if (s.startTime != null)
                'startTime': s.startTime!.toIso8601String(),
              if (s.endTime != null) 'endTime': s.endTime!.toIso8601String(),
              'observation': s.observation,
            }).toList(),
      };

  factory SessionPart.fromJson(Map<String, dynamic> json) {
    return SessionPart(
      sessionPartId: json['sessionPartId'] as int?,
      name: json['name'] as String?,
      order: json['order'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) =>
                  SessionSection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// TrainingSession — sesión de entrenamiento completa
// ─────────────────────────────────────────────────────────────────────

/// Estado de una sesión de entrenamiento.
enum TrainingSessionStatus {
  programada('Programada'),
  enProceso('EnProceso'),
  terminada('Terminada'),
  finalizada('Finalizada'),
  cancelada('Cancelada');

  final String label;
  const TrainingSessionStatus(this.label);
}

/// Días de la semana disponibles para sesiones.
enum DayOfWeek {
  lunes('Lunes'),
  martes('Martes'),
  miercoles('Miercoles'),
  jueves('Jueves'),
  viernes('Viernes'),
  sabado('Sabado'),
  domingo('Domingo');

  final String label;
  const DayOfWeek(this.label);
}

/// Sesión de entrenamiento completa (TrainingSessionResponseDto).
///
/// Vinculada a un microciclo, contiene duración, horarios, evidencias
/// fotográficas, porcentaje de lanzamientos y las 4 partes de la sesión.
///
/// El máximo de lanzamientos se calcula como:
/// `maxThrows = (throwPercentage / 100) * totalThrowsBase`
class TrainingSession {
  final int? trainingSessionId;
  final int microcycleId;
  final String? dayOfWeek;
  final int duration;
  final String? status;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? photoEvidence1;
  final String? photoEvidence2;
  final String? photoEvidence3;
  final String? photoEvidence4;
  final double throwPercentage;
  final int totalThrowsBase;
  final int maxThrows;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<SessionPart> parts;

  const TrainingSession({
    this.trainingSessionId,
    required this.microcycleId,
    this.dayOfWeek,
    this.duration = 0,
    this.status,
    this.startTime,
    this.endTime,
    this.photoEvidence1,
    this.photoEvidence2,
    this.photoEvidence3,
    this.photoEvidence4,
    this.throwPercentage = 0.0,
    this.totalThrowsBase = 0,
    this.maxThrows = 0,
    this.createdAt,
    this.updatedAt,
    this.parts = const [],
  });

  /// Calcula el máximo de lanzamientos basado en porcentaje y base.
  int get calculatedMaxThrows =>
      ((throwPercentage / 100.0) * totalThrowsBase).round();

  /// Número total de lanzamientos asignados en todas las partes/secciones.
  int get assignedThrows =>
      parts.fold(0, (sum, p) => sum + p.totalThrows);

  /// Lanzamientos restantes disponibles para asignar.
  int get remainingThrows => maxThrows - assignedThrows;

  /// Lista de evidencias fotográficas no nulas.
  List<String> get photoEvidences => [
        if (photoEvidence1 != null) photoEvidence1!,
        if (photoEvidence2 != null) photoEvidence2!,
        if (photoEvidence3 != null) photoEvidence3!,
        if (photoEvidence4 != null) photoEvidence4!,
      ];

  TrainingSession copyWith({
    int? trainingSessionId,
    int? microcycleId,
    String? dayOfWeek,
    int? duration,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    String? photoEvidence1,
    String? photoEvidence2,
    String? photoEvidence3,
    String? photoEvidence4,
    double? throwPercentage,
    int? totalThrowsBase,
    int? maxThrows,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SessionPart>? parts,
  }) {
    return TrainingSession(
      trainingSessionId: trainingSessionId ?? this.trainingSessionId,
      microcycleId: microcycleId ?? this.microcycleId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      photoEvidence1: photoEvidence1 ?? this.photoEvidence1,
      photoEvidence2: photoEvidence2 ?? this.photoEvidence2,
      photoEvidence3: photoEvidence3 ?? this.photoEvidence3,
      photoEvidence4: photoEvidence4 ?? this.photoEvidence4,
      throwPercentage: throwPercentage ?? this.throwPercentage,
      totalThrowsBase: totalThrowsBase ?? this.totalThrowsBase,
      maxThrows: maxThrows ?? this.maxThrows,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parts: parts ?? this.parts,
    );
  }

  Map<String, dynamic> toJson() => {
        'trainingSessionId': trainingSessionId,
        'microcycleId': microcycleId,
        'dayOfWeek': dayOfWeek,
        'duration': duration,
        'status': status,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'photoEvidence1': photoEvidence1,
        'photoEvidence2': photoEvidence2,
        'photoEvidence3': photoEvidence3,
        'photoEvidence4': photoEvidence4,
        'throwPercentage': throwPercentage,
        'totalThrowsBase': totalThrowsBase,
        'maxThrows': maxThrows,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'parts': parts.map((p) => p.toJson()).toList(),
      };

  /// JSON para CreateTrainingSessionDto.
  Map<String, dynamic> toCreateJson() => {
        'microcycleId': microcycleId,
        'dayOfWeek': dayOfWeek,
        'duration': duration,
        if (startTime != null) 'startTime': startTime!.toIso8601String(),
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        'throwPercentage': throwPercentage,
        'totalThrowsBase': totalThrowsBase,
        'parts': parts.map((p) => p.toCreateJson()).toList(),
      };

  /// JSON para UpdateTrainingSessionDto.
  Map<String, dynamic> toUpdateJson() => {
        'trainingSessionId': trainingSessionId,
        if (status != null) 'status': status,
        if (duration > 0) 'duration': duration,
        if (startTime != null) 'startTime': startTime!.toIso8601String(),
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        if (throwPercentage > 0) 'throwPercentage': throwPercentage,
        if (totalThrowsBase > 0) 'totalThrowsBase': totalThrowsBase,
        if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
      };

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      trainingSessionId: json['trainingSessionId'] as int?,
      microcycleId: json['microcycleId'] as int? ?? 0,
      dayOfWeek: json['dayOfWeek'] as String?,
      duration: json['duration'] as int? ?? 0,
      status: json['status'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      photoEvidence1: json['photoEvidence1'] as String?,
      photoEvidence2: json['photoEvidence2'] as String?,
      photoEvidence3: json['photoEvidence3'] as String?,
      photoEvidence4: json['photoEvidence4'] as String?,
      throwPercentage:
          (json['throwPercentage'] as num?)?.toDouble() ?? 0.0,
      totalThrowsBase: json['totalThrowsBase'] as int? ?? 0,
      maxThrows: json['maxThrows'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      parts: (json['parts'] as List<dynamic>?)
              ?.map((p) =>
                  SessionPart.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// TrainingSessionSummary — resumen liviano de una sesión
// ─────────────────────────────────────────────────────────────────────

/// Resumen de sesión de entrenamiento (TrainingSessionSummaryDto).
///
/// Se usa en listas y vistas previas donde no se necesita el detalle
/// completo de partes y secciones.
class TrainingSessionSummary {
  final int trainingSessionId;
  final int microcycleId;
  final String? dayOfWeek;
  final int duration;
  final String? status;
  final double throwPercentage;
  final int maxThrows;
  final int totalParts;
  final int totalSections;
  final DateTime? createdAt;

  const TrainingSessionSummary({
    required this.trainingSessionId,
    required this.microcycleId,
    this.dayOfWeek,
    this.duration = 0,
    this.status,
    this.throwPercentage = 0.0,
    this.maxThrows = 0,
    this.totalParts = 0,
    this.totalSections = 0,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'trainingSessionId': trainingSessionId,
        'microcycleId': microcycleId,
        'dayOfWeek': dayOfWeek,
        'duration': duration,
        'status': status,
        'throwPercentage': throwPercentage,
        'maxThrows': maxThrows,
        'totalParts': totalParts,
        'totalSections': totalSections,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory TrainingSessionSummary.fromJson(Map<String, dynamic> json) {
    return TrainingSessionSummary(
      trainingSessionId: json['trainingSessionId'] as int? ?? 0,
      microcycleId: json['microcycleId'] as int? ?? 0,
      dayOfWeek: json['dayOfWeek'] as String?,
      duration: json['duration'] as int? ?? 0,
      status: json['status'] as String?,
      throwPercentage:
          (json['throwPercentage'] as num?)?.toDouble() ?? 0.0,
      maxThrows: json['maxThrows'] as int? ?? 0,
      totalParts: json['totalParts'] as int? ?? 0,
      totalSections: json['totalSections'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// AthleteSessionSummary — resumen de sesión con contexto de macrociclo
// ─────────────────────────────────────────────────────────────────────

/// Resumen de sesión para un atleta (AthleteSessionSummaryDto).
///
/// Incluye contexto de macrociclo y microciclo, además de fechas
/// calculadas por el backend. Se obtiene vía
/// `POST /api/TrainingSession/Athlete/GetSessionsByDateRange`.
class AthleteSessionSummary {
  final int trainingSessionId;
  final int microcycleId;
  final String? macrocycleName;
  final int microcycleNumber;
  final DateTime? microcycleStartDate;
  final DateTime? microcycleEndDate;
  final String? microcycleType;
  final String? dayOfWeek;
  final int duration;
  final String? status;
  final DateTime? startTime;
  final DateTime? endTime;
  final double throwPercentage;
  final int maxThrows;
  final int totalParts;
  final int totalSections;
  final DateTime? createdAt;

  const AthleteSessionSummary({
    required this.trainingSessionId,
    required this.microcycleId,
    this.macrocycleName,
    this.microcycleNumber = 0,
    this.microcycleStartDate,
    this.microcycleEndDate,
    this.microcycleType,
    this.dayOfWeek,
    this.duration = 0,
    this.status,
    this.startTime,
    this.endTime,
    this.throwPercentage = 0.0,
    this.maxThrows = 0,
    this.totalParts = 0,
    this.totalSections = 0,
    this.createdAt,
  });

  /// True si la sesión aún no se ha completado.
  bool get isPending =>
      status == null || status == 'Programada' || status == 'EnProceso';

  /// True si la sesión ya terminó o fue finalizada.
  bool get isCompleted =>
      status == 'Terminada' || status == 'Finalizada';

  Map<String, dynamic> toJson() => {
        'trainingSessionId': trainingSessionId,
        'microcycleId': microcycleId,
        'macrocycleName': macrocycleName,
        'microcycleNumber': microcycleNumber,
        'microcycleStartDate': microcycleStartDate?.toIso8601String(),
        'microcycleEndDate': microcycleEndDate?.toIso8601String(),
        'microcycleType': microcycleType,
        'dayOfWeek': dayOfWeek,
        'duration': duration,
        'status': status,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'throwPercentage': throwPercentage,
        'maxThrows': maxThrows,
        'totalParts': totalParts,
        'totalSections': totalSections,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory AthleteSessionSummary.fromJson(Map<String, dynamic> json) {
    return AthleteSessionSummary(
      trainingSessionId: json['trainingSessionId'] as int? ?? 0,
      microcycleId: json['microcycleId'] as int? ?? 0,
      macrocycleName: json['macrocycleName'] as String?,
      microcycleNumber: json['microcycleNumber'] as int? ?? 0,
      microcycleStartDate: json['microcycleStartDate'] != null
          ? DateTime.parse(json['microcycleStartDate'] as String)
          : null,
      microcycleEndDate: json['microcycleEndDate'] != null
          ? DateTime.parse(json['microcycleEndDate'] as String)
          : null,
      microcycleType: json['microcycleType'] as String?,
      dayOfWeek: json['dayOfWeek'] as String?,
      duration: json['duration'] as int? ?? 0,
      status: json['status'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      throwPercentage:
          (json['throwPercentage'] as num?)?.toDouble() ?? 0.0,
      maxThrows: json['maxThrows'] as int? ?? 0,
      totalParts: json['totalParts'] as int? ?? 0,
      totalSections: json['totalSections'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
