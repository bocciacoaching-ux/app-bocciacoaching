/// Modelo de un lanzamiento individual dentro de la evaluación SAREMAS+.
class SaremasThrow {
  final int throwNumber;
  final String diagonal; // 'Roja' o 'Azul'
  final String technicalComponent;
  final int scoreObtained; // 0 – 5
  final String observations;
  final List<String> failureTags; // ['Fuerza', 'Dirección', 'Cadencia', …]
  final DateTime timestamp;

  SaremasThrow({
    required this.throwNumber,
    required this.diagonal,
    required this.technicalComponent,
    required this.scoreObtained,
    this.observations = '',
    this.failureTags = const [],
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
  }) {
    return SaremasThrow(
      throwNumber: throwNumber ?? this.throwNumber,
      diagonal: diagonal ?? this.diagonal,
      technicalComponent: technicalComponent ?? this.technicalComponent,
      scoreObtained: scoreObtained ?? this.scoreObtained,
      observations: observations ?? this.observations,
      failureTags: failureTags ?? this.failureTags,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
