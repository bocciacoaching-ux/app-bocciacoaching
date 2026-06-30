class DirectionEvaluationThrow {
  final int boxNumber;
  final int throwOrder;
  final double targetDistance;
  final int scoreObtained;
  final String observations;
  final bool status;
  final int athleteId;
  final int assessDirectionId;
  final double coordinateX;
  final double coordinateY;
  final bool deviatedRight;
  final bool deviatedLeft;
  final bool isStrength;
  final bool isCadence;
  final bool isDirection;
  final bool isTrajectory;

  DirectionEvaluationThrow({
    required this.boxNumber,
    required this.throwOrder,
    required this.targetDistance,
    required this.scoreObtained,
    required this.observations,
    required this.status,
    required this.athleteId,
    required this.assessDirectionId,
    required this.coordinateX,
    required this.coordinateY,
    required this.deviatedRight,
    required this.deviatedLeft,
    this.isStrength = false,
    this.isCadence = false,
    this.isDirection = false,
    this.isTrajectory = false,
  });

  Map<String, dynamic> toJson() => {
        'boxNumber': boxNumber,
        'throwOrder': throwOrder,
        'targetDistance': targetDistance,
        'scoreObtained': scoreObtained,
        'observations': observations,
        'status': status,
        'athleteId': athleteId,
        'assessDirectionId': assessDirectionId,
        'coordinateX': coordinateX,
        'coordinateY': coordinateY,
        'deviatedRight': deviatedRight,
        'deviatedLeft': deviatedLeft,
        'isStrength': isStrength,
        'isCadence': isCadence,
        'isDirection': isDirection,
        'isTrajectory': isTrajectory,
      };

  factory DirectionEvaluationThrow.fromJson(Map<String, dynamic> json) {
    return DirectionEvaluationThrow(
      boxNumber: json['boxNumber'],
      throwOrder: json['throwOrder'],
      targetDistance: (json['targetDistance'] as num).toDouble(),
      scoreObtained: json['scoreObtained'],
      observations: json['observations'] ?? '',
      status: json['status'] ?? true,
      athleteId: json['athleteId'],
      assessDirectionId: json['assessDirectionId'],
      coordinateX: (json['coordinateX'] as num).toDouble(),
      coordinateY: (json['coordinateY'] as num).toDouble(),
      deviatedRight: json['deviatedRight'] ?? false,
      deviatedLeft: json['deviatedLeft'] ?? false,
      isStrength: json['isStrength'] ?? false,
      isCadence: json['isCadence'] ?? false,
      isDirection: json['isDirection'] ?? false,
      isTrajectory: json['isTrajectory'] ?? false,
    );
  }
}
