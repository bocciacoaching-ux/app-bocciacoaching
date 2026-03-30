/// Modelo de una evaluación SAREMAS+ activa devuelta por la API.
///
/// Responde al endpoint GET /api/AssessSaremas/GetActiveEvaluation/{teamId}/{coachId}.
class ActiveSaremasEvaluation {
  final int saremasEvalId;
  final DateTime evaluationDate;
  final String? description;
  final int teamId;
  final int coachId;
  final String? state;
  final List<SaremasAthleteInEvaluationDto> athletes;

  const ActiveSaremasEvaluation({
    required this.saremasEvalId,
    required this.evaluationDate,
    this.description,
    required this.teamId,
    required this.coachId,
    this.state,
    this.athletes = const [],
  });

  factory ActiveSaremasEvaluation.fromJson(Map<String, dynamic> json) {
    return ActiveSaremasEvaluation(
      saremasEvalId: json['saremasEvalId'] as int,
      evaluationDate: DateTime.parse(json['evaluationDate'] as String),
      description: json['description'] as String?,
      teamId: json['teamId'] as int,
      coachId: json['coachId'] as int,
      state: json['state'] as String?,
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => SaremasAthleteInEvaluationDto.fromJson(
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
        'coachId': coachId,
        'state': state,
        'athletes': athletes.map((a) => a.toJson()).toList(),
      };
}

/// Atleta dentro de una evaluación SAREMAS+ activa.
class SaremasAthleteInEvaluationDto {
  final int athleteId;
  final String? name;
  final List<SaremasThrowApiDto> throws_;

  const SaremasAthleteInEvaluationDto({
    required this.athleteId,
    this.name,
    this.throws_ = const [],
  });

  factory SaremasAthleteInEvaluationDto.fromJson(Map<String, dynamic> json) {
    return SaremasAthleteInEvaluationDto(
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

/// Lanzamiento SAREMAS+ tal como lo devuelve la API.
class SaremasThrowApiDto {
  final int? saremasThrowId;
  final int throwNumber;
  final String? diagonal;
  final String? technicalComponent;
  final int scoreObtained;
  final String? observations;
  final String? failureTags;
  final String? status;
  final int? athleteId;
  final String? athleteName;
  final int? saremasEvalId;
  final double? whiteBallX;
  final double? whiteBallY;
  final double? colorBallX;
  final double? colorBallY;
  final double? estimatedDistance;
  final double? launchPointX;
  final double? launchPointY;
  final double? distanceToLaunchPoint;

  const SaremasThrowApiDto({
    this.saremasThrowId,
    required this.throwNumber,
    this.diagonal,
    this.technicalComponent,
    required this.scoreObtained,
    this.observations,
    this.failureTags,
    this.status,
    this.athleteId,
    this.athleteName,
    this.saremasEvalId,
    this.whiteBallX,
    this.whiteBallY,
    this.colorBallX,
    this.colorBallY,
    this.estimatedDistance,
    this.launchPointX,
    this.launchPointY,
    this.distanceToLaunchPoint,
  });

  /// Convierte el failureTags (String separado por comas) a lista.
  List<String> get failureTagsList {
    if (failureTags == null || failureTags!.isEmpty) return [];
    return failureTags!.split(',').map((e) => e.trim()).toList();
  }

  factory SaremasThrowApiDto.fromJson(Map<String, dynamic> json) {
    return SaremasThrowApiDto(
      saremasThrowId: json['saremasThrowId'] as int?,
      throwNumber: json['throwNumber'] as int? ?? 0,
      diagonal: json['diagonal'] as String?,
      technicalComponent: json['technicalComponent'] as String?,
      scoreObtained: json['scoreObtained'] as int? ?? 0,
      observations: json['observations'] as String?,
      failureTags: json['failureTags'] as String?,
      status: json['status'] as String?,
      athleteId: json['athleteId'] as int?,
      athleteName: json['athleteName'] as String?,
      saremasEvalId: json['saremasEvalId'] as int?,
      whiteBallX: (json['whiteBallX'] as num?)?.toDouble(),
      whiteBallY: (json['whiteBallY'] as num?)?.toDouble(),
      colorBallX: (json['colorBallX'] as num?)?.toDouble(),
      colorBallY: (json['colorBallY'] as num?)?.toDouble(),
      estimatedDistance: (json['estimatedDistance'] as num?)?.toDouble(),
      launchPointX: (json['launchPointX'] as num?)?.toDouble(),
      launchPointY: (json['launchPointY'] as num?)?.toDouble(),
      distanceToLaunchPoint:
          (json['distanceToLaunchPoint'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'saremasThrowId': saremasThrowId,
        'throwNumber': throwNumber,
        'diagonal': diagonal,
        'technicalComponent': technicalComponent,
        'scoreObtained': scoreObtained,
        'observations': observations,
        'failureTags': failureTags,
        'status': status,
        'athleteId': athleteId,
        'athleteName': athleteName,
        'saremasEvalId': saremasEvalId,
        'whiteBallX': whiteBallX,
        'whiteBallY': whiteBallY,
        'colorBallX': colorBallX,
        'colorBallY': colorBallY,
        'estimatedDistance': estimatedDistance,
        'launchPointX': launchPointX,
        'launchPointY': launchPointY,
        'distanceToLaunchPoint': distanceToLaunchPoint,
      };
}
