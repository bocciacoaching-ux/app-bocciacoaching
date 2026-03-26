/// Estadísticas de un atleta en una evaluación de dirección.
class DirectionAthleteStatisticsDto {
  final int athleteId;
  final String athleteName;
  final int assessDirectionId;
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
  final int totalDeviatedRight;
  final int totalDeviatedLeft;
  final double deviatedRightPercentage;
  final double deviatedLeftPercentage;
  final int shortDeviatedRight;
  final int shortDeviatedLeft;
  final int mediumDeviatedRight;
  final int mediumDeviatedLeft;
  final int longDeviatedRight;
  final int longDeviatedLeft;

  const DirectionAthleteStatisticsDto({
    required this.athleteId,
    required this.athleteName,
    required this.assessDirectionId,
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
    required this.totalDeviatedRight,
    required this.totalDeviatedLeft,
    required this.deviatedRightPercentage,
    required this.deviatedLeftPercentage,
    required this.shortDeviatedRight,
    required this.shortDeviatedLeft,
    required this.mediumDeviatedRight,
    required this.mediumDeviatedLeft,
    required this.longDeviatedRight,
    required this.longDeviatedLeft,
  });

  factory DirectionAthleteStatisticsDto.fromJson(Map<String, dynamic> json) {
    return DirectionAthleteStatisticsDto(
      athleteId: (json['athleteId'] as num?)?.toInt() ?? 0,
      athleteName: json['athleteName'] as String? ?? '',
      assessDirectionId: (json['assessDirectionId'] as num?)?.toInt() ?? 0,
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
      totalDeviatedRight: (json['totalDeviatedRight'] as num?)?.toInt() ?? 0,
      totalDeviatedLeft: (json['totalDeviatedLeft'] as num?)?.toInt() ?? 0,
      deviatedRightPercentage:
          (json['deviatedRightPercentage'] as num?)?.toDouble() ?? 0.0,
      deviatedLeftPercentage:
          (json['deviatedLeftPercentage'] as num?)?.toDouble() ?? 0.0,
      shortDeviatedRight: (json['shortDeviatedRight'] as num?)?.toInt() ?? 0,
      shortDeviatedLeft: (json['shortDeviatedLeft'] as num?)?.toInt() ?? 0,
      mediumDeviatedRight: (json['mediumDeviatedRight'] as num?)?.toInt() ?? 0,
      mediumDeviatedLeft: (json['mediumDeviatedLeft'] as num?)?.toInt() ?? 0,
      longDeviatedRight: (json['longDeviatedRight'] as num?)?.toInt() ?? 0,
      longDeviatedLeft: (json['longDeviatedLeft'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'athleteId': athleteId,
        'athleteName': athleteName,
        'assessDirectionId': assessDirectionId,
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
        'totalDeviatedRight': totalDeviatedRight,
        'totalDeviatedLeft': totalDeviatedLeft,
        'deviatedRightPercentage': deviatedRightPercentage,
        'deviatedLeftPercentage': deviatedLeftPercentage,
        'shortDeviatedRight': shortDeviatedRight,
        'shortDeviatedLeft': shortDeviatedLeft,
        'mediumDeviatedRight': mediumDeviatedRight,
        'mediumDeviatedLeft': mediumDeviatedLeft,
        'longDeviatedRight': longDeviatedRight,
        'longDeviatedLeft': longDeviatedLeft,
      };
}
