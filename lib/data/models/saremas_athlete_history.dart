/// Historial de evaluaciones SAREMAS+ de un atleta.
///
/// Responde al endpoint GET /api/AssessSaremas/GetAthleteHistory/{athleteId}.
class SaremasAthleteHistoryDto {
  final int athleteId;
  final String? athleteName;
  final List<SaremasHistoryItemDto> evaluations;
  final SaremasAthleteEvolutionDto? evolution;

  const SaremasAthleteHistoryDto({
    required this.athleteId,
    this.athleteName,
    this.evaluations = const [],
    this.evolution,
  });

  factory SaremasAthleteHistoryDto.fromJson(Map<String, dynamic> json) {
    return SaremasAthleteHistoryDto(
      athleteId: json['athleteId'] as int,
      athleteName: json['athleteName'] as String?,
      evaluations: (json['evaluations'] as List<dynamic>?)
              ?.map((e) => SaremasHistoryItemDto.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      evolution: json['evolution'] != null
          ? SaremasAthleteEvolutionDto.fromJson(
              json['evolution'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'athleteId': athleteId,
        'athleteName': athleteName,
        'evaluations': evaluations.map((e) => e.toJson()).toList(),
        'evolution': evolution?.toJson(),
      };
}

/// Elemento del historial de evaluaciones SAREMAS+.
class SaremasHistoryItemDto {
  final int saremasEvalId;
  final DateTime evaluationDate;
  final String? description;
  final String? teamName;
  final int totalThrows;
  final double averageScore;
  final String? state;

  const SaremasHistoryItemDto({
    required this.saremasEvalId,
    required this.evaluationDate,
    this.description,
    this.teamName,
    this.totalThrows = 0,
    this.averageScore = 0.0,
    this.state,
  });

  factory SaremasHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return SaremasHistoryItemDto(
      saremasEvalId: json['saremasEvalId'] as int,
      evaluationDate: DateTime.parse(json['evaluationDate'] as String),
      description: json['description'] as String?,
      teamName: json['teamName'] as String?,
      totalThrows: json['totalThrows'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      state: json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'saremasEvalId': saremasEvalId,
        'evaluationDate': evaluationDate.toIso8601String(),
        'description': description,
        'teamName': teamName,
        'totalThrows': totalThrows,
        'averageScore': averageScore,
        'state': state,
      };
}

/// Evolución del atleta a lo largo de evaluaciones SAREMAS+.
class SaremasAthleteEvolutionDto {
  final List<SaremasEvolutionPointDto> points;
  final double trend;

  const SaremasAthleteEvolutionDto({
    this.points = const [],
    this.trend = 0.0,
  });

  factory SaremasAthleteEvolutionDto.fromJson(Map<String, dynamic> json) {
    return SaremasAthleteEvolutionDto(
      points: (json['points'] as List<dynamic>?)
              ?.map((e) => SaremasEvolutionPointDto.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      trend: (json['trend'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'points': points.map((p) => p.toJson()).toList(),
        'trend': trend,
      };
}

/// Punto de evolución en el historial SAREMAS+.
class SaremasEvolutionPointDto {
  final DateTime date;
  final double averageScore;
  final int totalThrows;

  const SaremasEvolutionPointDto({
    required this.date,
    this.averageScore = 0.0,
    this.totalThrows = 0,
  });

  factory SaremasEvolutionPointDto.fromJson(Map<String, dynamic> json) {
    return SaremasEvolutionPointDto(
      date: DateTime.parse(json['date'] as String),
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      totalThrows: json['totalThrows'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'averageScore': averageScore,
        'totalThrows': totalThrows,
      };
}
