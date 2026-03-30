import 'active_saremas_evaluation.dart';

/// Detalles completos de una evaluación SAREMAS+.
///
/// Responde al endpoint GET /api/AssessSaremas/GetEvaluationDetails/{saremasEvalId}.
class SaremasEvaluationDetailsDto {
  final int saremasEvalId;
  final DateTime evaluationDate;
  final String? description;
  final int teamId;
  final String? teamName;
  final int coachId;
  final String? coachName;
  final String? state;
  final List<SaremasAthleteDetailDto> athletes;

  const SaremasEvaluationDetailsDto({
    required this.saremasEvalId,
    required this.evaluationDate,
    this.description,
    required this.teamId,
    this.teamName,
    required this.coachId,
    this.coachName,
    this.state,
    this.athletes = const [],
  });

  factory SaremasEvaluationDetailsDto.fromJson(Map<String, dynamic> json) {
    return SaremasEvaluationDetailsDto(
      saremasEvalId: json['saremasEvalId'] as int,
      evaluationDate: DateTime.parse(json['evaluationDate'] as String),
      description: json['description'] as String?,
      teamId: json['teamId'] as int,
      teamName: json['teamName'] as String?,
      coachId: json['coachId'] as int,
      coachName: json['coachName'] as String?,
      state: json['state'] as String?,
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => SaremasAthleteDetailDto.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'saremasEvalId': saremasEvalId,
        'evaluationDate': evaluationDate.toIso8601String(),
        'description': description,
        'teamId': teamId,
        'teamName': teamName,
        'coachId': coachId,
        'coachName': coachName,
        'state': state,
        'athletes': athletes.map((a) => a.toJson()).toList(),
      };
}

/// Detalle de un atleta dentro de la evaluación (incluye lanzamientos).
class SaremasAthleteDetailDto {
  final int athleteId;
  final String? name;
  final List<SaremasThrowApiDto> throws_;

  const SaremasAthleteDetailDto({
    required this.athleteId,
    this.name,
    this.throws_ = const [],
  });

  factory SaremasAthleteDetailDto.fromJson(Map<String, dynamic> json) {
    return SaremasAthleteDetailDto(
      athleteId: json['athleteId'] as int,
      name: json['name'] as String?,
      throws_: (json['throws'] as List<dynamic>?)
              ?.map((e) =>
                  SaremasThrowApiDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'athleteId': athleteId,
        'name': name,
        'throws': throws_.map((t) => t.toJson()).toList(),
      };
}
