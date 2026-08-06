class Athlete {
  final String id;
  final String name;
  final String? teamId;

  Athlete({required this.id, required this.name, this.teamId});

  factory Athlete.fromJson(Map<String, dynamic> json) {
    return Athlete(
      id: (json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      teamId: json['teamId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'teamId': teamId,
  };
}
