/// Estadísticas SAREMAS+ a nivel de equipo.
///
/// Responde al endpoint GET /api/Statistics/SaremasTeamStats/{teamId}.
class SaremasTeamStatsDto {
  final int teamId;
  final String? teamName;
  final int totalEvaluations;
  final double teamAverageScore;
  final List<SaremasAthleteStatsItemDto> athletes;

  const SaremasTeamStatsDto({
    required this.teamId,
    this.teamName,
    this.totalEvaluations = 0,
    this.teamAverageScore = 0.0,
    this.athletes = const [],
  });

  factory SaremasTeamStatsDto.fromJson(Map<String, dynamic> json) {
    return SaremasTeamStatsDto(
      teamId: json['teamId'] as int,
      teamName: json['teamName'] as String?,
      totalEvaluations: json['totalEvaluations'] as int? ?? 0,
      teamAverageScore:
          (json['teamAverageScore'] as num?)?.toDouble() ?? 0.0,
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => SaremasAthleteStatsItemDto.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'teamId': teamId,
        'teamName': teamName,
        'totalEvaluations': totalEvaluations,
        'teamAverageScore': teamAverageScore,
        'athletes': athletes.map((a) => a.toJson()).toList(),
      };
}

/// Estadísticas SAREMAS+ individuales de un atleta dentro de las stats del equipo.
class SaremasAthleteStatsItemDto {
  final int athleteId;
  final String? athleteName;
  final int totalEvaluations;
  final double averageScore;
  final double bestScore;
  final double trend;

  const SaremasAthleteStatsItemDto({
    required this.athleteId,
    this.athleteName,
    this.totalEvaluations = 0,
    this.averageScore = 0.0,
    this.bestScore = 0.0,
    this.trend = 0.0,
  });

  factory SaremasAthleteStatsItemDto.fromJson(Map<String, dynamic> json) {
    return SaremasAthleteStatsItemDto(
      athleteId: json['athleteId'] as int,
      athleteName: json['athleteName'] as String?,
      totalEvaluations: json['totalEvaluations'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      bestScore: (json['bestScore'] as num?)?.toDouble() ?? 0.0,
      trend: (json['trend'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'athleteId': athleteId,
        'athleteName': athleteName,
        'totalEvaluations': totalEvaluations,
        'averageScore': averageScore,
        'bestScore': bestScore,
        'trend': trend,
      };
}
