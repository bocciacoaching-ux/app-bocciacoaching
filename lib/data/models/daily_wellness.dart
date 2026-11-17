/// Modelo del test diario de bienestar del atleta (API v1 · Wellness).
///
/// Cada indicador (sueño, estrés, fatiga, dolor muscular) se puntúa de 1 a 7.
/// Se registra un test por atleta y por día.
class DailyWellness {
  static const int minScore = 1;
  static const int maxScore = 7;

  final String? dailyWellnessId;
  final String athleteId;
  final String? athleteName;
  final String? teamId;

  /// Fecha del test. Si es `null` al crear, el backend usa la fecha actual.
  final DateTime? assessmentDate;

  final int sleep;
  final int stress;
  final int fatigue;
  final int musclePain;
  final String? observations;

  /// Calculados por el backend (solo lectura).
  final int? totalScore;
  final double? averageScore;

  const DailyWellness({
    this.dailyWellnessId,
    required this.athleteId,
    this.athleteName,
    this.teamId,
    this.assessmentDate,
    required this.sleep,
    required this.stress,
    required this.fatigue,
    required this.musclePain,
    this.observations,
    this.totalScore,
    this.averageScore,
  });

  factory DailyWellness.fromJson(Map<String, dynamic> json) {
    return DailyWellness(
      dailyWellnessId: json['dailyWellnessId']?.toString(),
      athleteId: (json['athleteId'] ?? '').toString(),
      athleteName: json['athleteName']?.toString(),
      teamId: json['teamId']?.toString(),
      assessmentDate: json['assessmentDate'] != null
          ? DateTime.tryParse(json['assessmentDate'].toString())
          : null,
      sleep: (json['sleep'] as num?)?.toInt() ?? 0,
      stress: (json['stress'] as num?)?.toInt() ?? 0,
      fatigue: (json['fatigue'] as num?)?.toInt() ?? 0,
      musclePain: (json['musclePain'] as num?)?.toInt() ?? 0,
      observations: json['observations']?.toString(),
      totalScore: (json['totalScore'] as num?)?.toInt(),
      averageScore: (json['averageScore'] as num?)?.toDouble(),
    );
  }

  /// Cuerpo de `POST /api/v1/wellness` (AddDailyWellnessDto).
  Map<String, dynamic> toCreateJson() => {
        'athleteId': athleteId,
        if (teamId != null) 'teamId': teamId,
        if (assessmentDate != null)
          'assessmentDate': assessmentDate!.toIso8601String(),
        'sleep': sleep,
        'stress': stress,
        'fatigue': fatigue,
        'musclePain': musclePain,
        if (observations != null) 'observations': observations,
      };

  /// Cuerpo de `PUT /api/v1/wellness/{dailyWellnessId}` (UpdateDailyWellnessDto).
  Map<String, dynamic> toUpdateJson() => {
        'dailyWellnessId': dailyWellnessId,
        'sleep': sleep,
        'stress': stress,
        'fatigue': fatigue,
        'musclePain': musclePain,
        if (observations != null) 'observations': observations,
      };

  Map<String, dynamic> toJson() => {
        if (dailyWellnessId != null) 'dailyWellnessId': dailyWellnessId,
        ...toCreateJson(),
        if (athleteName != null) 'athleteName': athleteName,
        if (totalScore != null) 'totalScore': totalScore,
        if (averageScore != null) 'averageScore': averageScore,
      };

  /// `true` si todos los indicadores están en el rango 1–7.
  bool get isValid => [sleep, stress, fatigue, musclePain]
      .every((v) => v >= minScore && v <= maxScore);

  DailyWellness copyWith({
    String? dailyWellnessId,
    String? athleteId,
    String? athleteName,
    String? teamId,
    DateTime? assessmentDate,
    int? sleep,
    int? stress,
    int? fatigue,
    int? musclePain,
    String? observations,
  }) {
    return DailyWellness(
      dailyWellnessId: dailyWellnessId ?? this.dailyWellnessId,
      athleteId: athleteId ?? this.athleteId,
      athleteName: athleteName ?? this.athleteName,
      teamId: teamId ?? this.teamId,
      assessmentDate: assessmentDate ?? this.assessmentDate,
      sleep: sleep ?? this.sleep,
      stress: stress ?? this.stress,
      fatigue: fatigue ?? this.fatigue,
      musclePain: musclePain ?? this.musclePain,
      observations: observations ?? this.observations,
      totalScore: totalScore,
      averageScore: averageScore,
    );
  }
}

/// Historial de tests de bienestar de un atleta
/// (`GET /api/v1/athletes/{athleteId}/wellness`).
class WellnessAthleteHistory {
  final String athleteId;
  final String? athleteName;
  final int totalRecords;
  final double? overallAverageScore;
  final List<DailyWellness> records;

  const WellnessAthleteHistory({
    required this.athleteId,
    this.athleteName,
    required this.totalRecords,
    this.overallAverageScore,
    required this.records,
  });

  factory WellnessAthleteHistory.fromJson(Map<String, dynamic> json) {
    final records = (json['records'] as List? ?? const [])
        .map((e) => DailyWellness.fromJson(e as Map<String, dynamic>))
        .toList();
    return WellnessAthleteHistory(
      athleteId: (json['athleteId'] ?? '').toString(),
      athleteName: json['athleteName']?.toString(),
      totalRecords: (json['totalRecords'] as num?)?.toInt() ?? records.length,
      overallAverageScore: (json['overallAverageScore'] as num?)?.toDouble(),
      records: records,
    );
  }
}
