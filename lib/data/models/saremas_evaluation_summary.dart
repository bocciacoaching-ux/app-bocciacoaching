/// Resumen de una evaluación SAREMAS+ (listado de evaluaciones del equipo).
///
/// Responde al endpoint GET /api/AssessSaremas/GetTeamEvaluations/{teamId}.
class SaremasEvaluationSummaryDto {
  final int saremasEvalId;
  final DateTime evaluationDate;
  final String? description;
  final int teamId;
  final String? teamName;
  final int coachId;
  final String? coachName;
  final String? state;
  final int athleteCount;
  final int throwCount;

  const SaremasEvaluationSummaryDto({
    required this.saremasEvalId,
    required this.evaluationDate,
    this.description,
    required this.teamId,
    this.teamName,
    required this.coachId,
    this.coachName,
    this.state,
    this.athleteCount = 0,
    this.throwCount = 0,
  });

  factory SaremasEvaluationSummaryDto.fromJson(Map<String, dynamic> json) {
    return SaremasEvaluationSummaryDto(
      saremasEvalId: json['saremasEvalId'] as int,
      evaluationDate: DateTime.parse(json['evaluationDate'] as String),
      description: json['description'] as String?,
      teamId: json['teamId'] as int,
      teamName: json['teamName'] as String?,
      coachId: json['coachId'] as int,
      coachName: json['coachName'] as String?,
      state: json['state'] as String?,
      athleteCount: json['athleteCount'] as int? ?? 0,
      throwCount: json['throwCount'] as int? ?? 0,
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
        'athleteCount': athleteCount,
        'throwCount': throwCount,
      };
}
