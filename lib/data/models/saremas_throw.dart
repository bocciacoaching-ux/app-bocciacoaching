/// Modelo de un lanzamiento individual dentro de la evaluación SAREMAS+.
class SaremasThrow {
  final int throwNumber;
  final String diagonal; // 'Roja' o 'Azul'
  final String technicalComponent;
  final int scoreObtained; // 0 – 5
  final String observations;
  final List<String> failureTags; // ['Fuerza', 'Dirección', 'Cadencia', …]
  final DateTime timestamp;

  // ── Datos de la cancha (componente "Salida") ──────────────────
  /// Posición X e Y de la bola blanca (Jack) en metros sobre la cancha.
  final double? whiteBallX;
  final double? whiteBallY;

  /// Posición X e Y de la bola de color en metros sobre la cancha.
  final double? colorBallX;
  final double? colorBallY;

  /// Distancia estimada en metros entre la bola blanca y la de color (borde a borde).
  final double? estimatedDistance;

  /// Posición X e Y del punto de lanzamiento en metros sobre la cancha.
  final double? launchPointX;
  final double? launchPointY;

  /// Distancia del punto de lanzamiento al jack (bola blanca) en metros.
  final double? distanceToLaunchPoint;

  SaremasThrow({
    required this.throwNumber,
    required this.diagonal,
    required this.technicalComponent,
    required this.scoreObtained,
    this.observations = '',
    this.failureTags = const [],
    this.whiteBallX,
    this.whiteBallY,
    this.colorBallX,
    this.colorBallY,
    this.estimatedDistance,
    this.launchPointX,
    this.launchPointY,
    this.distanceToLaunchPoint,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'throwNumber': throwNumber,
        'diagonal': diagonal,
        'technicalComponent': technicalComponent,
        'scoreObtained': scoreObtained,
        'observations': observations,
        'failureTags': failureTags,
        'timestamp': timestamp.toIso8601String(),
        'whiteBallX': whiteBallX,
        'whiteBallY': whiteBallY,
        'colorBallX': colorBallX,
        'colorBallY': colorBallY,
        'estimatedDistance': estimatedDistance,
        'launchPointX': launchPointX,
        'launchPointY': launchPointY,
        'distanceToLaunchPoint': distanceToLaunchPoint,
      };

  factory SaremasThrow.fromJson(Map<String, dynamic> json) {
    return SaremasThrow(
      throwNumber: json['throwNumber'] as int,
      diagonal: json['diagonal'] as String,
      technicalComponent: json['technicalComponent'] as String,
      scoreObtained: json['scoreObtained'] as int,
      observations: json['observations'] as String? ?? '',
      failureTags: (json['failureTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
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

  SaremasThrow copyWith({
    int? throwNumber,
    String? diagonal,
    String? technicalComponent,
    int? scoreObtained,
    String? observations,
    List<String>? failureTags,
    DateTime? timestamp,
    double? whiteBallX,
    double? whiteBallY,
    double? colorBallX,
    double? colorBallY,
    double? estimatedDistance,
    double? launchPointX,
    double? launchPointY,
    double? distanceToLaunchPoint,
  }) {
    return SaremasThrow(
      throwNumber: throwNumber ?? this.throwNumber,
      diagonal: diagonal ?? this.diagonal,
      technicalComponent: technicalComponent ?? this.technicalComponent,
      scoreObtained: scoreObtained ?? this.scoreObtained,
      observations: observations ?? this.observations,
      failureTags: failureTags ?? this.failureTags,
      timestamp: timestamp ?? this.timestamp,
      whiteBallX: whiteBallX ?? this.whiteBallX,
      whiteBallY: whiteBallY ?? this.whiteBallY,
      colorBallX: colorBallX ?? this.colorBallX,
      colorBallY: colorBallY ?? this.colorBallY,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      launchPointX: launchPointX ?? this.launchPointX,
      launchPointY: launchPointY ?? this.launchPointY,
      distanceToLaunchPoint:
          distanceToLaunchPoint ?? this.distanceToLaunchPoint,
    );
  }
}
