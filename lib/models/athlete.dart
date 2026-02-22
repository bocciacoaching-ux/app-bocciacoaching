class Athlete {
  final int id;
  final String name;
  final int? teamId;

  Athlete({required this.id, required this.name, this.teamId});

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      teamId: json['teamId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'teamId': teamId,
  };
}
