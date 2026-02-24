class ActiveEvaluationAthlete {
  final int athleteId;
  final String athleteName;
  final String athleteEmail;
  final int coachId;
  final String coachName;

  ActiveEvaluationAthlete({
    required this.athleteId,
    required this.athleteName,
    required this.athleteEmail,
    required this.coachId,
    required this.coachName,
  });

  factory ActiveEvaluationAthlete.fromJson(Map<String, dynamic> json) {
    return ActiveEvaluationAthlete(
      athleteId: json['athleteId'] ?? 0,
      athleteName: json['athleteName'] ?? '',
      athleteEmail: json['athleteEmail'] ?? '',
      coachId: json['coachId'] ?? 0,
      coachName: json['coachName'] ?? '',
    );
  }
}

class ActiveEvaluationThrow {
  final int evaluationDetailStrengthId;
  final int boxNumber;
  final int throwOrder;
  final double targetDistance;
  final double scoreObtained;
  final String observations;
  final bool status;
  final int athleteId;
  final String athleteName;
  final String? createdAt;
  final String? updatedAt;

  ActiveEvaluationThrow({
    required this.evaluationDetailStrengthId,
    required this.boxNumber,
    required this.throwOrder,
    required this.targetDistance,
    required this.scoreObtained,
    required this.observations,
    required this.status,
    required this.athleteId,
    required this.athleteName,
    this.createdAt,
    this.updatedAt,
  });

  factory ActiveEvaluationThrow.fromJson(Map<String, dynamic> json) {
    return ActiveEvaluationThrow(
      evaluationDetailStrengthId: json['evaluationDetailStrengthId'] ?? 0,
      boxNumber: json['boxNumber'] ?? 0,
      throwOrder: json['throwOrder'] ?? 0,
      targetDistance: (json['targetDistance'] as num?)?.toDouble() ?? 0.0,
      scoreObtained: (json['scoreObtained'] as num?)?.toDouble() ?? 0.0,
      observations: json['observations'] ?? '',
      status: json['status'] ?? true,
      athleteId: json['athleteId'] ?? 0,
      athleteName: json['athleteName'] ?? '',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class ActiveEvaluation {
  final int assessStrengthId;
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
  final List<ActiveEvaluationAthlete> athletes;
  final List<ActiveEvaluationThrow> throws;

  ActiveEvaluation({
    required this.assessStrengthId,
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

  factory ActiveEvaluation.fromJson(Map<String, dynamic> json) {
    return ActiveEvaluation(
      assessStrengthId: json['assessStrengthId'] ?? 0,
      evaluationDate: json['evaluationDate'] ?? '',
      description: json['description'] ?? '',
      state: json['state'] ?? '',
      teamId: json['teamId'] ?? 0,
      teamName: json['teamName'] ?? '',
      createdByCoachId: json['createdByCoachId'] ?? 0,
      createdByCoachName: json['createdByCoachName'] ?? '',
      createdByCoachEmail: json['createdByCoachEmail'] ?? '',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      athletes: (json['athletes'] as List?)
              ?.map((a) => ActiveEvaluationAthlete.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      throws: (json['throws'] as List?)
              ?.map((t) => ActiveEvaluationThrow.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Número de lanzamientos ya completados.
  int get completedThrowsCount => throws.length;
}
