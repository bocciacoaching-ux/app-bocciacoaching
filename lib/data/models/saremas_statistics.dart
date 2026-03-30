/// Estadísticas de una evaluación SAREMAS+.
///
/// Responde al endpoint GET /api/AssessSaremas/GetEvaluationStatistics/{saremasEvalId}.
class SaremasStatisticsDto {
  final int saremasEvalId;
  final int athleteId;
  final String? athleteName;
  final int totalThrows;
  final double averageScore;
  final double maxScore;
  final double minScore;
  final DiagonalStatsDto? redDiagonal;
  final DiagonalStatsDto? blueDiagonal;
  final List<ComponentStatsDto> componentStats;
  final List<BlockStatsDto> blockStats;
  final SalidaMetricsDto? salidaMetrics;

  const SaremasStatisticsDto({
    required this.saremasEvalId,
    required this.athleteId,
    this.athleteName,
    this.totalThrows = 0,
    this.averageScore = 0.0,
    this.maxScore = 0.0,
    this.minScore = 0.0,
    this.redDiagonal,
    this.blueDiagonal,
    this.componentStats = const [],
    this.blockStats = const [],
    this.salidaMetrics,
  });

  factory SaremasStatisticsDto.fromJson(Map<String, dynamic> json) {
    return SaremasStatisticsDto(
      saremasEvalId: json['saremasEvalId'] as int? ?? 0,
      athleteId: json['athleteId'] as int? ?? 0,
      athleteName: json['athleteName'] as String?,
      totalThrows: json['totalThrows'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 0.0,
      minScore: (json['minScore'] as num?)?.toDouble() ?? 0.0,
      redDiagonal: json['redDiagonal'] != null
          ? DiagonalStatsDto.fromJson(
              json['redDiagonal'] as Map<String, dynamic>)
          : null,
      blueDiagonal: json['blueDiagonal'] != null
          ? DiagonalStatsDto.fromJson(
              json['blueDiagonal'] as Map<String, dynamic>)
          : null,
      componentStats: (json['componentStats'] as List<dynamic>?)
              ?.map((e) =>
                  ComponentStatsDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      blockStats: (json['blockStats'] as List<dynamic>?)
              ?.map((e) => BlockStatsDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      salidaMetrics: json['salidaMetrics'] != null
          ? SalidaMetricsDto.fromJson(
              json['salidaMetrics'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'saremasEvalId': saremasEvalId,
        'athleteId': athleteId,
        'athleteName': athleteName,
        'totalThrows': totalThrows,
        'averageScore': averageScore,
        'maxScore': maxScore,
        'minScore': minScore,
        'redDiagonal': redDiagonal?.toJson(),
        'blueDiagonal': blueDiagonal?.toJson(),
        'componentStats': componentStats.map((c) => c.toJson()).toList(),
        'blockStats': blockStats.map((b) => b.toJson()).toList(),
        'salidaMetrics': salidaMetrics?.toJson(),
      };
}

/// Estadísticas por diagonal (Roja / Azul).
class DiagonalStatsDto {
  final String? diagonal;
  final int totalThrows;
  final double averageScore;
  final double maxScore;
  final double minScore;

  const DiagonalStatsDto({
    this.diagonal,
    this.totalThrows = 0,
    this.averageScore = 0.0,
    this.maxScore = 0.0,
    this.minScore = 0.0,
  });

  factory DiagonalStatsDto.fromJson(Map<String, dynamic> json) {
    return DiagonalStatsDto(
      diagonal: json['diagonal'] as String?,
      totalThrows: json['totalThrows'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 0.0,
      minScore: (json['minScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'diagonal': diagonal,
        'totalThrows': totalThrows,
        'averageScore': averageScore,
        'maxScore': maxScore,
        'minScore': minScore,
      };
}

/// Estadísticas por componente técnico.
class ComponentStatsDto {
  final String? component;
  final int totalThrows;
  final double averageScore;
  final double successRate;

  const ComponentStatsDto({
    this.component,
    this.totalThrows = 0,
    this.averageScore = 0.0,
    this.successRate = 0.0,
  });

  factory ComponentStatsDto.fromJson(Map<String, dynamic> json) {
    return ComponentStatsDto(
      component: json['component'] as String?,
      totalThrows: json['totalThrows'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'component': component,
        'totalThrows': totalThrows,
        'averageScore': averageScore,
        'successRate': successRate,
      };
}

/// Estadísticas por bloque de lanzamientos.
class BlockStatsDto {
  final int blockNumber;
  final double averageScore;
  final int totalThrows;

  const BlockStatsDto({
    this.blockNumber = 0,
    this.averageScore = 0.0,
    this.totalThrows = 0,
  });

  factory BlockStatsDto.fromJson(Map<String, dynamic> json) {
    return BlockStatsDto(
      blockNumber: json['blockNumber'] as int? ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      totalThrows: json['totalThrows'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'blockNumber': blockNumber,
        'averageScore': averageScore,
        'totalThrows': totalThrows,
      };
}

/// Métricas del componente de Salida.
class SalidaMetricsDto {
  final double averageDistance;
  final double minDistance;
  final double maxDistance;
  final double averageDistanceToLaunchPoint;
  final int totalMeasurements;

  const SalidaMetricsDto({
    this.averageDistance = 0.0,
    this.minDistance = 0.0,
    this.maxDistance = 0.0,
    this.averageDistanceToLaunchPoint = 0.0,
    this.totalMeasurements = 0,
  });

  factory SalidaMetricsDto.fromJson(Map<String, dynamic> json) {
    return SalidaMetricsDto(
      averageDistance: (json['averageDistance'] as num?)?.toDouble() ?? 0.0,
      minDistance: (json['minDistance'] as num?)?.toDouble() ?? 0.0,
      maxDistance: (json['maxDistance'] as num?)?.toDouble() ?? 0.0,
      averageDistanceToLaunchPoint:
          (json['averageDistanceToLaunchPoint'] as num?)?.toDouble() ?? 0.0,
      totalMeasurements: json['totalMeasurements'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'averageDistance': averageDistance,
        'minDistance': minDistance,
        'maxDistance': maxDistance,
        'averageDistanceToLaunchPoint': averageDistanceToLaunchPoint,
        'totalMeasurements': totalMeasurements,
      };
}
