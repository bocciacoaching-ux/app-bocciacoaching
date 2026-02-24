class TeamMember {
  final int userId;
  final String dni;
  final String firstName;
  final String lastName;
  final String? email;
  final String? address;
  final String? country;
  final String? image;
  final String? category;
  final String? seniority;
  final bool status;
  final String? createdAt;
  final String? updatedAt;

  const TeamMember({
    required this.userId,
    required this.dni,
    required this.firstName,
    required this.lastName,
    this.email,
    this.address,
    this.country,
    this.image,
    this.category,
    this.seniority,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  /// Estado legible: true → 'Activo', false → 'Inactivo'.
  String get statusLabel => status ? 'Activo' : 'Inactivo';

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      dni: json['dni'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      image: json['image'] as String?,
      category: json['category'] as String?,
      seniority: json['seniority'] as String?,
      status: json['status'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'dni': dni,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'address': address,
        'country': country,
        'image': image,
        'category': category,
        'seniority': seniority,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
