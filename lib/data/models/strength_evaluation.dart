import 'active_evaluation.dart';

/// Estadísticas de un atleta en una evaluación de fuerza.
class AthleteStatisticsDto {
  final int athleteId;
  final String athleteName;
  final int assessStrengthId;
  final String evaluationDate;
  final double effectivenessPercentage;
  final double accuracyPercentage;
  final int effectiveThrow;
  final int failedThrow;
  final int shortThrow;
  final int mediumThrow;
  final double longThrow;
  final double shortEffectivenessPercentage;
  final double mediumEffectivenessPercentage;
  final double longEffectivenessPercentage;
  final int shortThrowAccuracy;
  final int mediumThrowAccuracy;
  final int longThrowAccuracy;
  final double shortAccuracyPercentage;
  final double mediumAccuracyPercentage;
  final double longAccuracyPercentage;

  const AthleteStatisticsDto({
    required this.athleteId,
    required this.athleteName,
    required this.assessStrengthId,
    required this.evaluationDate,
    required this.effectivenessPercentage,
    required this.accuracyPercentage,
    required this.effectiveThrow,
    required this.failedThrow,
    required this.shortThrow,
    required this.mediumThrow,
    required this.longThrow,
    required this.shortEffectivenessPercentage,
    required this.mediumEffectivenessPercentage,
    required this.longEffectivenessPercentage,
    required this.shortThrowAccuracy,
    required this.mediumThrowAccuracy,
    required this.longThrowAccuracy,
    required this.shortAccuracyPercentage,
    required this.mediumAccuracyPercentage,
    required this.longAccuracyPercentage,
  });

  factory AthleteStatisticsDto.fromJson(Map<String, dynamic> json) {
    return AthleteStatisticsDto(
      athleteId: (json['athleteId'] as num?)?.toInt() ?? 0,
      athleteName: json['athleteName'] as String? ?? '',
      assessStrengthId: (json['assessStrengthId'] as num?)?.toInt() ?? 0,
      evaluationDate: json['evaluationDate'] as String? ?? '',
      effectivenessPercentage:
          (json['effectivenessPercentage'] as num?)?.toDouble() ?? 0.0,
      accuracyPercentage:
          (json['accuracyPercentage'] as num?)?.toDouble() ?? 0.0,
      effectiveThrow: (json['effectiveThrow'] as num?)?.toInt() ?? 0,
      failedThrow: (json['failedThrow'] as num?)?.toInt() ?? 0,
      shortThrow: (json['shortThrow'] as num?)?.toInt() ?? 0,
      mediumThrow: (json['mediumThrow'] as num?)?.toInt() ?? 0,
      longThrow: (json['longThrow'] as num?)?.toDouble() ?? 0.0,
      shortEffectivenessPercentage:
          (json['shortEffectivenessPercentage'] as num?)?.toDouble() ?? 0.0,
      mediumEffectivenessPercentage:
          (json['mediumEffectivenessPercentage'] as num?)?.toDouble() ?? 0.0,
      longEffectivenessPercentage:
          (json['longEffectivenessPercentage'] as num?)?.toDouble() ?? 0.0,
      shortThrowAccuracy: (json['shortThrowAccuracy'] as num?)?.toInt() ?? 0,
      mediumThrowAccuracy: (json['mediumThrowAccuracy'] as num?)?.toInt() ?? 0,
      longThrowAccuracy: (json['longThrowAccuracy'] as num?)?.toInt() ?? 0,
      shortAccuracyPercentage:
          (json['shortAccuracyPercentage'] as num?)?.toDouble() ?? 0.0,
      mediumAccuracyPercentage:
          (json['mediumAccuracyPercentage'] as num?)?.toDouble() ?? 0.0,
      longAccuracyPercentage:
          (json['longAccuracyPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'athleteId': athleteId,
        'athleteName': athleteName,
        'assessStrengthId': assessStrengthId,
        'evaluationDate': evaluationDate,
        'effectivenessPercentage': effectivenessPercentage,
        'accuracyPercentage': accuracyPercentage,
        'effectiveThrow': effectiveThrow,
        'failedThrow': failedThrow,
        'shortThrow': shortThrow,
        'mediumThrow': mediumThrow,
        'longThrow': longThrow,
        'shortEffectivenessPercentage': shortEffectivenessPercentage,
        'mediumEffectivenessPercentage': mediumEffectivenessPercentage,
        'longEffectivenessPercentage': longEffectivenessPercentage,
        'shortThrowAccuracy': shortThrowAccuracy,
        'mediumThrowAccuracy': mediumThrowAccuracy,
        'longThrowAccuracy': longThrowAccuracy,
        'shortAccuracyPercentage': shortAccuracyPercentage,
        'mediumAccuracyPercentage': mediumAccuracyPercentage,
        'longAccuracyPercentage': longAccuracyPercentage,
      };
}

/// Resumen de una evaluación de fuerza.
class EvaluationSummaryDto {
  final int assessStrengthId;
  final String evaluationDate;
  final String? description;
  final String? state;
  final String? stateName;
  final int teamId;
  final String? teamName;
  final int coachId;
  final String? coachName;
  final int athletesCount;
  final int throwsCount;
  final String? createdAt;
  final String? updatedAt;

  const EvaluationSummaryDto({
    required this.assessStrengthId,
    required this.evaluationDate,
    this.description,
    this.state,
    this.stateName,
    required this.teamId,
    this.teamName,
    required this.coachId,
    this.coachName,
    required this.athletesCount,
    required this.throwsCount,
    this.createdAt,
    this.updatedAt,
  });

  factory EvaluationSummaryDto.fromJson(Map<String, dynamic> json) {
    return EvaluationSummaryDto(
      assessStrengthId: (json['assessStrengthId'] as num?)?.toInt() ?? 0,
      evaluationDate: json['evaluationDate'] as String? ?? '',
      description: json['description'] as String?,
      state: json['state'] as String?,
      stateName: json['stateName'] as String?,
      teamId: (json['teamId'] as num?)?.toInt() ?? 0,
      teamName: json['teamName'] as String?,
      coachId: (json['coachId'] as num?)?.toInt() ?? 0,
      coachName: json['coachName'] as String?,
      athletesCount: (json['athletesCount'] as num?)?.toInt() ?? 0,
      throwsCount: (json['throwsCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'assessStrengthId': assessStrengthId,
        'evaluationDate': evaluationDate,
        'description': description,
        'state': state,
        'stateName': stateName,
        'teamId': teamId,
        'teamName': teamName,
        'coachId': coachId,
        'coachName': coachName,
        'athletesCount': athletesCount,
        'throwsCount': throwsCount,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

/// Detalle completo de una evaluación de fuerza.
class EvaluationDetailsDto {
  final int assessStrengthId;
  final String evaluationDate;
  final String? description;
  final String? state;
  final String? stateName;
  final int teamId;
  final String? teamName;
  final int coachId;
  final String? coachName;
  final String? coachEmail;
  final String? createdAt;
  final String? updatedAt;
  final List<ActiveEvaluationAthlete> athletes;
  final List<ActiveEvaluationThrow> throws;
  final List<AthleteStatisticsDto> statistics;

  const EvaluationDetailsDto({
    required this.assessStrengthId,
    required this.evaluationDate,
    this.description,
    this.state,
    this.stateName,
    required this.teamId,
    this.teamName,
    required this.coachId,
    this.coachName,
    this.coachEmail,
    this.createdAt,
    this.updatedAt,
    this.athletes = const [],
    this.throws = const [],
    this.statistics = const [],
  });

  factory EvaluationDetailsDto.fromJson(Map<String, dynamic> json) {
    return EvaluationDetailsDto(
      assessStrengthId: (json['assessStrengthId'] as num?)?.toInt() ?? 0,
      evaluationDate: json['evaluationDate'] as String? ?? '',
      description: json['description'] as String?,
      state: json['state'] as String?,
      stateName: json['stateName'] as String?,
      teamId: (json['teamId'] as num?)?.toInt() ?? 0,
      teamName: json['teamName'] as String?,
      coachId: (json['coachId'] as num?)?.toInt() ?? 0,
      coachName: json['coachName'] as String?,
      coachEmail: json['coachEmail'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      athletes: (json['athletes'] as List?)
              ?.map((a) =>
                  ActiveEvaluationAthlete.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      throws: (json['throws'] as List?)
              ?.map((t) =>
                  ActiveEvaluationThrow.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      statistics: (json['statistics'] as List?)
              ?.map((s) =>
                  AthleteStatisticsDto.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'assessStrengthId': assessStrengthId,
        'evaluationDate': evaluationDate,
        'description': description,
        'state': state,
        'stateName': stateName,
        'teamId': teamId,
        'teamName': teamName,
        'coachId': coachId,
        'coachName': coachName,
        'coachEmail': coachEmail,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
