class ForceTestConfig {
  final int shotNumber;
  final int boxNumber;
  final double targetDistance;
  final int? nextBox;
  final int? prevBox;

  ForceTestConfig({
    required this.shotNumber,
    required this.boxNumber,
    required this.targetDistance,
    this.nextBox,
    this.prevBox,
  });

  factory ForceTestConfig.fromJson(Map<String, dynamic> json) {
    return ForceTestConfig(
      shotNumber: json['shotNumber'],
      boxNumber: json['boxNumber'],
      targetDistance: (json['targetDistance'] as num).toDouble(),
      nextBox: json['nextBox'],
      prevBox: json['prevBox'],
    );
  }
}
