/// Progreso de un macrociclo.
///
/// Responde al endpoint GET /api/Statistics/MacrocycleProgress/{macrocycleId}.
/// Ajustado al swagger: macrocycleId es String, campos alineados con
/// MacrocycleProgressDto del backend.
class MacrocycleProgressDto {
  final String? macrocycleId;
  final String? name;
  final String? athleteName;
  final DateTime startDate;
  final DateTime endDate;
  final int totalWeeks;
  final int completedWeeks;
  final double progressPercentage;
  final String? currentPeriod;
  final String? currentMesocycle;
  final int currentWeekNumber;
  final int totalEvents;
  final int completedEvents;
  final int upcomingEvents;

  const MacrocycleProgressDto({
    this.macrocycleId,
    this.name,
    this.athleteName,
    required this.startDate,
    required this.endDate,
    this.totalWeeks = 0,
    this.completedWeeks = 0,
    this.progressPercentage = 0.0,
    this.currentPeriod,
    this.currentMesocycle,
    this.currentWeekNumber = 0,
    this.totalEvents = 0,
    this.completedEvents = 0,
    this.upcomingEvents = 0,
  });

  factory MacrocycleProgressDto.fromJson(Map<String, dynamic> json) {
    return MacrocycleProgressDto(
      macrocycleId: json['macrocycleId']?.toString(),
      name: json['name'] as String?,
      athleteName: json['athleteName'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalWeeks: json['totalWeeks'] as int? ?? 0,
      completedWeeks: json['completedWeeks'] as int? ?? 0,
      progressPercentage:
          (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      currentPeriod: json['currentPeriod'] as String?,
      currentMesocycle: json['currentMesocycle'] as String?,
      currentWeekNumber: json['currentWeekNumber'] as int? ?? 0,
      totalEvents: json['totalEvents'] as int? ?? 0,
      completedEvents: json['completedEvents'] as int? ?? 0,
      upcomingEvents: json['upcomingEvents'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'macrocycleId': macrocycleId,
        'name': name,
        'athleteName': athleteName,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'totalWeeks': totalWeeks,
        'completedWeeks': completedWeeks,
        'progressPercentage': progressPercentage,
        'currentPeriod': currentPeriod,
        'currentMesocycle': currentMesocycle,
        'currentWeekNumber': currentWeekNumber,
        'totalEvents': totalEvents,
        'completedEvents': completedEvents,
        'upcomingEvents': upcomingEvents,
      };
}
