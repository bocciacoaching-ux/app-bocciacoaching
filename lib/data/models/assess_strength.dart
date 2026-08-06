import 'athlete.dart';

class AssessStrength {
  final String id;
  final String evaluationName;
  final String teamId;
  final String coachId;
  final List<Athlete> athletes;
  final int completedThrows;
  final int totalShots;

  AssessStrength({
    required this.id,
    required this.evaluationName,
    required this.teamId,
    required this.coachId,
    this.athletes = const [],
    this.completedThrows = 0,
    this.totalShots = 36,
  });

  factory AssessStrength.fromJson(Map<String, dynamic> json) {
    return AssessStrength(
      id: (json['id'] ?? '').toString(),
      evaluationName: json['evaluationName'] ?? '',
      teamId: json['teamId'],
      coachId: json['coachId'],
      athletes: (json['athletes'] as List?)
              ?.map((a) => Athlete.fromJson(a))
              .toList() ??
          [],
      completedThrows: json['completedThrows'] ?? 0,
      totalShots: json['totalShots'] ?? 36,
    );
  }
}
