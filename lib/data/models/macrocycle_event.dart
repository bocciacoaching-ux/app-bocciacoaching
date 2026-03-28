/// Evento dentro de un macrociclo (competencias, concentraciones, campus, etc.).
class MacrocycleEvent {
  final String id;
  final String name;
  final EventType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final String? notes;

  const MacrocycleEvent({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.location,
    this.notes,
  });

  /// Duración del evento en días.
  int get durationDays => endDate.difference(startDate).inDays + 1;

  MacrocycleEvent copyWith({
    String? id,
    String? name,
    EventType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? notes,
  }) {
    return MacrocycleEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'location': location,
        'notes': notes,
      };

  factory MacrocycleEvent.fromJson(Map<String, dynamic> json) {
    return MacrocycleEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.competencia,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// Tipos de evento en el macrociclo.
enum EventType {
  competencia('Competencia'),
  concentracion('Concentración'),
  campus('Campus'),
  evaluacion('Evaluación'),
  descanso('Descanso'),
  otro('Otro');

  final String label;
  const EventType(this.label);
}
