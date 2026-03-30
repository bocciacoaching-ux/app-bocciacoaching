/// Dashboard completo de un atleta con todas sus estadísticas.
///
/// Responde al endpoint GET /api/Statistics/AthleteFullDashboard/{athleteId}.
class AthleteFullDashboardDto {
  final int athleteId;
  final String? athleteName;
  final String? teamName;
  final AthleteStrengthSummaryDto? strengthSummary;
  final AthleteDirectionSummaryDto? directionSummary;
  final AthleteSaremasSummaryDto? saremasSummary;
  final AthleteMacrocycleSummaryDto? macrocycleSummary;
  final List<AthleteRecentEvaluationDto> recentEvaluations;

  const AthleteFullDashboardDto({
    required this.athleteId,
    this.athleteName,
    this.teamName,
    this.strengthSummary,
    this.directionSummary,
    this.saremasSummary,
    this.macrocycleSummary,
    this.recentEvaluations = const [],
  });

  factory AthleteFullDashboardDto.fromJson(Map<String, dynamic> json) {
    return AthleteFullDashboardDto(
      athleteId: json['athleteId'] as int,
      athleteName: json['athleteName'] as String?,
      teamName: json['teamName'] as String?,
      strengthSummary: json['strengthSummary'] != null
          ? AthleteStrengthSummaryDto.fromJson(
              json['strengthSummary'] as Map<String, dynamic>)
          : null,
      directionSummary: json['directionSummary'] != null
          ? AthleteDirectionSummaryDto.fromJson(
              json['directionSummary'] as Map<String, dynamic>)
          : null,
      saremasSummary: json['saremasSummary'] != null
          ? AthleteSaremasSummaryDto.fromJson(
              json['saremasSummary'] as Map<String, dynamic>)
          : null,
      macrocycleSummary: json['macrocycleSummary'] != null
          ? AthleteMacrocycleSummaryDto.fromJson(
              json['macrocycleSummary'] as Map<String, dynamic>)
          : null,
      recentEvaluations: (json['recentEvaluations'] as List<dynamic>?)
              ?.map((e) => AthleteRecentEvaluationDto.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'athleteId': athleteId,
        'athleteName': athleteName,
        'teamName': teamName,
        'strengthSummary': strengthSummary?.toJson(),
        'directionSummary': directionSummary?.toJson(),
        'saremasSummary': saremasSummary?.toJson(),
        'macrocycleSummary': macrocycleSummary?.toJson(),
        'recentEvaluations':
            recentEvaluations.map((e) => e.toJson()).toList(),
      };
}

/// Resumen de fuerza del atleta.
class AthleteStrengthSummaryDto {
  final int totalEvaluations;
  final double averageScore;
  final double bestScore;
  final double trend;

  const AthleteStrengthSummaryDto({
    this.totalEvaluations = 0,
    this.averageScore = 0.0,
    this.bestScore = 0.0,
    this.trend = 0.0,
  });

  factory AthleteStrengthSummaryDto.fromJson(Map<String, dynamic> json) {
    return AthleteStrengthSummaryDto(
      totalEvaluations: json['totalEvaluations'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      bestScore: (json['bestScore'] as num?)?.toDouble() ?? 0.0,
      trend: (json['trend'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalEvaluations': totalEvaluations,
        'averageScore': averageScore,
        'bestScore': bestScore,
        'trend': trend,
      };
}

/// Resumen de dirección del atleta.
class AthleteDirectionSummaryDto {
  final int totalEvaluations;
  final double averageScore;
  final double bestScore;
  final double trend;

  const AthleteDirectionSummaryDto({
    this.totalEvaluations = 0,
    this.averageScore = 0.0,
    this.bestScore = 0.0,
    this.trend = 0.0,
  });

  factory AthleteDirectionSummaryDto.fromJson(Map<String, dynamic> json) {
    return AthleteDirectionSummaryDto(
      totalEvaluations: json['totalEvaluations'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      bestScore: (json['bestScore'] as num?)?.toDouble() ?? 0.0,
      trend: (json['trend'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalEvaluations': totalEvaluations,
        'averageScore': averageScore,
        'bestScore': bestScore,
        'trend': trend,
      };
}

/// Resumen SAREMAS+ del atleta.
class AthleteSaremasSummaryDto {
  final int totalEvaluations;
  final double averageScore;
  final double bestScore;
  final double trend;

  const AthleteSaremasSummaryDto({
    this.totalEvaluations = 0,
    this.averageScore = 0.0,
    this.bestScore = 0.0,
    this.trend = 0.0,
  });

  factory AthleteSaremasSummaryDto.fromJson(Map<String, dynamic> json) {
    return AthleteSaremasSummaryDto(
      totalEvaluations: json['totalEvaluations'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      bestScore: (json['bestScore'] as num?)?.toDouble() ?? 0.0,
      trend: (json['trend'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalEvaluations': totalEvaluations,
        'averageScore': averageScore,
        'bestScore': bestScore,
        'trend': trend,
      };
}

/// Resumen de macrociclo del atleta.
class AthleteMacrocycleSummaryDto {
  final int activeMacrocycles;
  final String? currentPeriod;
  final String? currentMicrocycleType;
  final double progressPercentage;

  const AthleteMacrocycleSummaryDto({
    this.activeMacrocycles = 0,
    this.currentPeriod,
    this.currentMicrocycleType,
    this.progressPercentage = 0.0,
  });

  factory AthleteMacrocycleSummaryDto.fromJson(Map<String, dynamic> json) {
    return AthleteMacrocycleSummaryDto(
      activeMacrocycles: json['activeMacrocycles'] as int? ?? 0,
      currentPeriod: json['currentPeriod'] as String?,
      currentMicrocycleType: json['currentMicrocycleType'] as String?,
      progressPercentage:
          (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'activeMacrocycles': activeMacrocycles,
        'currentPeriod': currentPeriod,
        'currentMicrocycleType': currentMicrocycleType,
        'progressPercentage': progressPercentage,
      };
}

/// Evaluación reciente del atleta (cualquier tipo).
class AthleteRecentEvaluationDto {
  final int evaluationId;
  final String? type;
  final DateTime evaluationDate;
  final double score;
  final String? state;

  const AthleteRecentEvaluationDto({
    required this.evaluationId,
    this.type,
    required this.evaluationDate,
    this.score = 0.0,
    this.state,
  });

  factory AthleteRecentEvaluationDto.fromJson(Map<String, dynamic> json) {
    return AthleteRecentEvaluationDto(
      evaluationId: json['evaluationId'] as int,
      type: json['type'] as String?,
      evaluationDate: DateTime.parse(json['evaluationDate'] as String),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      state: json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'evaluationId': evaluationId,
        'type': type,
        'evaluationDate': evaluationDate.toIso8601String(),
        'score': score,
        'state': state,
      };
}
