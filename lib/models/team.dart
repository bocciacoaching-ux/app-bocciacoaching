class Team {
  final int teamId;
  final String nameTeam;
  final String? description;
  final int coachId;
  final bool status;
  final String? image;
  final bool bc1;
  final bool bc2;
  final bool bc3;
  final bool bc4;
  final bool pairs;
  final bool teams;
  final String? country;
  final String? region;
  final String? createdAt;
  final String? updatedAt;
  final int memberCount;

  const Team({
    required this.teamId,
    required this.nameTeam,
    this.description,
    required this.coachId,
    required this.status,
    this.image,
    required this.bc1,
    required this.bc2,
    required this.bc3,
    required this.bc4,
    required this.pairs,
    required this.teams,
    this.country,
    this.region,
    this.createdAt,
    this.updatedAt,
    required this.memberCount,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamId: (json['teamId'] as num?)?.toInt() ?? 0,
      nameTeam: json['nameTeam'] as String? ?? '',
      description: json['description'] as String?,
      coachId: (json['coachId'] as num?)?.toInt() ?? 0,
      status: json['status'] as bool? ?? true,
      image: json['image'] as String?,
      bc1: json['bc1'] as bool? ?? false,
      bc2: json['bc2'] as bool? ?? false,
      bc3: json['bc3'] as bool? ?? false,
      bc4: json['bc4'] as bool? ?? false,
      pairs: json['pairs'] as bool? ?? false,
      teams: json['teams'] as bool? ?? false,
      country: json['country'] as String?,
      region: json['region'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'teamId': teamId,
        'nameTeam': nameTeam,
        'description': description,
        'coachId': coachId,
        'status': status,
        'image': image,
        'bc1': bc1,
        'bc2': bc2,
        'bc3': bc3,
        'bc4': bc4,
        'pairs': pairs,
        'teams': teams,
        'country': country,
        'region': region,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'memberCount': memberCount,
      };

  /// Categorías habilitadas como lista de etiquetas.
  List<String> get enabledCategories {
    return [
      if (bc1) 'BC1',
      if (bc2) 'BC2',
      if (bc3) 'BC3',
      if (bc4) 'BC4',
      if (pairs) 'Parejas',
      if (teams) 'Equipos',
    ];
  }
}
