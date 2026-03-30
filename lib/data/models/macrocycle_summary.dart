/// Resumen de un macrociclo.
///
/// Responde a los endpoints:
///   GET /api/Macrocycle/GetByAthlete/{athleteId}
///   GET /api/Macrocycle/GetByTeam/{teamId}
///   GET /api/Macrocycle/GetCoachMacrocycles/{coachId}
///
/// Coincide con MacrocycleSummaryDto del swagger.
class MacrocycleSummaryDto {
  final String? macrocycleId;
  final String? name;
  final String? athleteName;
  final int athleteId;
  final DateTime startDate;
  final DateTime endDate;
  final int eventCount;
  final int coachId;
  final String? coachName;
  final int teamId;
  final String? teamName;
  final DateTime createdAt;

  const MacrocycleSummaryDto({
    this.macrocycleId,
    this.name,
    this.athleteName,
    required this.athleteId,
    required this.startDate,
    required this.endDate,
    this.eventCount = 0,
    required this.coachId,
    this.coachName,
    required this.teamId,
    this.teamName,
    required this.createdAt,
  });

  factory MacrocycleSummaryDto.fromJson(Map<String, dynamic> json) {
    return MacrocycleSummaryDto(
      macrocycleId: json['macrocycleId']?.toString(),
      name: json['name'] as String?,
      athleteName: json['athleteName'] as String?,
      athleteId: json['athleteId'] as int? ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      eventCount: json['eventCount'] as int? ?? 0,
      coachId: json['coachId'] as int? ?? 0,
      coachName: json['coachName'] as String?,
      teamId: json['teamId'] as int? ?? 0,
      teamName: json['teamName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'macrocycleId': macrocycleId,
        'name': name,
        'athleteName': athleteName,
        'athleteId': athleteId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'eventCount': eventCount,
        'coachId': coachId,
        'coachName': coachName,
        'teamId': teamId,
        'teamName': teamName,
        'createdAt': createdAt.toIso8601String(),
      };
}
