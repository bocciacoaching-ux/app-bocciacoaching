class Statistics {
  final double generalEffectiveness;
  final double precision;
  final int effectiveThrows;
  final int failedThrows;
  final DistanceStats shortStats;
  final DistanceStats mediumStats;
  final DistanceStats longStats;
  final List<double> scoreByBlock; // 6 blocks of 6 throws
  final List<int> scoreDistribution; // 0-5
  final List<Map<String, double>> coordinates;

  Statistics({
    required this.generalEffectiveness,
    required this.precision,
    required this.effectiveThrows,
    required this.failedThrows,
    required this.shortStats,
    required this.mediumStats,
    required this.longStats,
    required this.scoreByBlock,
    required this.scoreDistribution,
    required this.coordinates,
  });
}

class DistanceStats {
  final String label;
  final int hits;
  final int total;
  final int totalPoints;
  
  DistanceStats({
    required this.label,
    required this.hits,
    required this.total,
    required this.totalPoints,
  });

  double get effectiveness => total == 0 ? 0 : (hits / total) * 100;
  double get precision => total == 0 ? 0 : (totalPoints / (total * 5)) * 100;
}
