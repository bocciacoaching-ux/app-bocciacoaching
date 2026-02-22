class EvaluationThrow {
  final int boxNumber;
  final int throwOrder;
  final double targetDistance;
  final int scoreObtained;
  final String observations;
  final bool status;
  final int athleteId;
  final int assessStrengthId;
  final double coordinateX;
  final double coordinateY;

  EvaluationThrow({
    required this.boxNumber,
    required this.throwOrder,
    required this.targetDistance,
    required this.scoreObtained,
    required this.observations,
    required this.status,
    required this.athleteId,
    required this.assessStrengthId,
    required this.coordinateX,
    required this.coordinateY,
  });

  Map<String, dynamic> toJson() => {
    'boxNumber': boxNumber,
    'throwOrder': throwOrder,
    'targetDistance': targetDistance,
    'scoreObtained': scoreObtained,
    'observations': observations,
    'status': status,
    'athleteId': athleteId,
    'assessStrengthId': assessStrengthId,
    'coordinateX': coordinateX,
    'coordinateY': coordinateY,
  };

  factory EvaluationThrow.fromJson(Map<String, dynamic> json) {
    return EvaluationThrow(
      boxNumber: json['boxNumber'],
      throwOrder: json['throwOrder'],
      targetDistance: (json['targetDistance'] as num).toDouble(),
      scoreObtained: json['scoreObtained'],
      observations: json['observations'] ?? '',
      status: json['status'] ?? true,
      athleteId: json['athleteId'],
      assessStrengthId: json['assessStrengthId'],
      coordinateX: (json['coordinateX'] as num).toDouble(),
      coordinateY: (json['coordinateY'] as num).toDouble(),
    );
  }
}
