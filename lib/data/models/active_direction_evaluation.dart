/// Modelo del atleta dentro de una evaluación de dirección activa.
class AthleteInDirectionEvaluationDto {
  final int athleteId;
  final String athleteName;
  final String athleteEmail;
  final int coachId;
  final String coachName;

  const AthleteInDirectionEvaluationDto({
    required this.athleteId,
    required this.athleteName,
    required this.athleteEmail,
    required this.coachId,
    required this.coachName,
  });

  factory AthleteInDirectionEvaluationDto.fromJson(Map<String, dynamic> json) {
    return AthleteInDirectionEvaluationDto(
      athleteId: (json['athleteId'] as num?)?.toInt() ?? 0,
      athleteName: json['athleteName'] as String? ?? '',
      athleteEmail: json['athleteEmail'] as String? ?? '',
      coachId: (json['coachId'] as num?)?.toInt() ?? 0,
      coachName: json['coachName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'athleteId': athleteId,
        'athleteName': athleteName,
        'athleteEmail': athleteEmail,
        'coachId': coachId,
        'coachName': coachName,
      };
}

/// Modelo de un lanzamiento dentro de una evaluación de dirección.
class DirectionEvaluationThrowDto {
  final int evaluationDetailDirectionId;
  final int boxNumber;
  final int throwOrder;
  final double? targetDistance;
  final double? scoreObtained;
  final String? observations;
  final bool status;
  final int athleteId;
  final String athleteName;
  final bool deviatedRight;
  final bool deviatedLeft;
  final String? createdAt;
  final String? updatedAt;

  const DirectionEvaluationThrowDto({
    required this.evaluationDetailDirectionId,
    required this.boxNumber,
    required this.throwOrder,
    this.targetDistance,
    this.scoreObtained,
    this.observations,
    required this.status,
    required this.athleteId,
    required this.athleteName,
    required this.deviatedRight,
    required this.deviatedLeft,
    this.createdAt,
    this.updatedAt,
  });

  factory DirectionEvaluationThrowDto.fromJson(Map<String, dynamic> json) {
    return DirectionEvaluationThrowDto(
      evaluationDetailDirectionId:
          (json['evaluationDetailDirectionId'] as num?)?.toInt() ?? 0,
      boxNumber: (json['boxNumber'] as num?)?.toInt() ?? 0,
      throwOrder: (json['throwOrder'] as num?)?.toInt() ?? 0,
      targetDistance: (json['targetDistance'] as num?)?.toDouble(),
      scoreObtained: (json['scoreObtained'] as num?)?.toDouble(),
      observations: json['observations'] as String?,
      status: json['status'] as bool? ?? true,
      athleteId: (json['athleteId'] as num?)?.toInt() ?? 0,
      athleteName: json['athleteName'] as String? ?? '',
      deviatedRight: json['deviatedRight'] as bool? ?? false,
      deviatedLeft: json['deviatedLeft'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'evaluationDetailDirectionId': evaluationDetailDirectionId,
        'boxNumber': boxNumber,
        'throwOrder': throwOrder,
        'targetDistance': targetDistance,
        'scoreObtained': scoreObtained,
        'observations': observations,
        'status': status,
        'athleteId': athleteId,
        'athleteName': athleteName,
        'deviatedRight': deviatedRight,
        'deviatedLeft': deviatedLeft,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

/// Evaluación de dirección activa completa.
class ActiveDirectionEvaluation {
  final int assessDirectionId;
  final String evaluationDate;
  final String description;
  final String state;
  final int teamId;
  final String teamName;
  final int createdByCoachId;
  final String createdByCoachName;
  final String createdByCoachEmail;
  final String? createdAt;
  final String? updatedAt;
  final List<AthleteInDirectionEvaluationDto> athletes;
  final List<DirectionEvaluationThrowDto> throws;

  const ActiveDirectionEvaluation({
    required this.assessDirectionId,
    required this.evaluationDate,
    required this.description,
    required this.state,
    required this.teamId,
    required this.teamName,
    required this.createdByCoachId,
    required this.createdByCoachName,
    required this.createdByCoachEmail,
    this.createdAt,
    this.updatedAt,
    this.athletes = const [],
    this.throws = const [],
  });

  factory ActiveDirectionEvaluation.fromJson(Map<String, dynamic> json) {
    return ActiveDirectionEvaluation(
      assessDirectionId: (json['assessDirectionId'] as num?)?.toInt() ?? 0,
      evaluationDate: json['evaluationDate'] as String? ?? '',
      description: json['description'] as String? ?? '',
      state: json['state'] as String? ?? '',
      teamId: (json['teamId'] as num?)?.toInt() ?? 0,
      teamName: json['teamName'] as String? ?? '',
      createdByCoachId: (json['createdByCoachId'] as num?)?.toInt() ?? 0,
      createdByCoachName: json['createdByCoachName'] as String? ?? '',
      createdByCoachEmail: json['createdByCoachEmail'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      athletes: (json['athletes'] as List?)
              ?.map((a) => AthleteInDirectionEvaluationDto.fromJson(
                  a as Map<String, dynamic>))
              .toList() ??
          [],
      throws: (json['throws'] as List?)
              ?.map((t) => DirectionEvaluationThrowDto.fromJson(
                  t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'assessDirectionId': assessDirectionId,
        'evaluationDate': evaluationDate,
        'description': description,
        'state': state,
        'teamId': teamId,
        'teamName': teamName,
        'createdByCoachId': createdByCoachId,
        'createdByCoachName': createdByCoachName,
        'createdByCoachEmail': createdByCoachEmail,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'athletes': athletes.map((a) => a.toJson()).toList(),
        'throws': throws.map((t) => t.toJson()).toList(),
      };

  /// Número de lanzamientos ya completados.
  int get completedThrowsCount => throws.length;
}
