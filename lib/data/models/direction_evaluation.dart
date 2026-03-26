import 'active_direction_evaluation.dart';
import 'direction_statistics.dart';

/// Resumen de una evaluación de dirección.
class DirectionEvaluationSummaryDto {
  final int assessDirectionId;
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

  const DirectionEvaluationSummaryDto({
    required this.assessDirectionId,
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

  factory DirectionEvaluationSummaryDto.fromJson(Map<String, dynamic> json) {
    return DirectionEvaluationSummaryDto(
      assessDirectionId: (json['assessDirectionId'] as num?)?.toInt() ?? 0,
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
        'assessDirectionId': assessDirectionId,
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

/// Detalle completo de una evaluación de dirección.
class DirectionEvaluationDetailsDto {
  final int assessDirectionId;
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
  final List<AthleteInDirectionEvaluationDto> athletes;
  final List<DirectionEvaluationThrowDto> throws;
  final List<DirectionAthleteStatisticsDto> statistics;

  const DirectionEvaluationDetailsDto({
    required this.assessDirectionId,
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

  factory DirectionEvaluationDetailsDto.fromJson(Map<String, dynamic> json) {
    return DirectionEvaluationDetailsDto(
      assessDirectionId: (json['assessDirectionId'] as num?)?.toInt() ?? 0,
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
              ?.map((a) => AthleteInDirectionEvaluationDto.fromJson(
                  a as Map<String, dynamic>))
              .toList() ??
          [],
      throws: (json['throws'] as List?)
              ?.map((t) => DirectionEvaluationThrowDto.fromJson(
                  t as Map<String, dynamic>))
              .toList() ??
          [],
      statistics: (json['statistics'] as List?)
              ?.map((s) => DirectionAthleteStatisticsDto.fromJson(
                  s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'assessDirectionId': assessDirectionId,
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
        'athletes': athletes.map((a) => a.toJson()).toList(),
        'throws': throws.map((t) => t.toJson()).toList(),
        'statistics': statistics.map((s) => s.toJson()).toList(),
      };
}
