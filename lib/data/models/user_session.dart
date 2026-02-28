class UserSession {
  final int userId;
  final String dni;
  final String firstName;
  final String lastName;
  final String email;
  final String? address;
  final String? country;
  final String? image;
  final String? category;
  final String? seniority;
  final bool status;
  final int rolId;
  final String? createdAt;
  final String? updatedAt;

  const UserSession({
    required this.userId,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.address,
    this.country,
    this.image,
    this.category,
    this.seniority,
    required this.status,
    required this.rolId,
    this.createdAt,
    this.updatedAt,
  });

  /// rolId == 1 → entrenador
  bool get isCoach => rolId == 1;

  /// rolId == 3 → deportista
  bool get isAthlete => rolId == 3;

  String get fullName => '$firstName $lastName';

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'] as int,
      dni: json['dni'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      address: json['address'] as String?,
      country: json['country'] as String?,
      image: json['image'] as String?,
      category: json['category'] as String?,
      seniority: json['seniority'] as String?,
      status: json['status'] as bool,
      rolId: json['rolId'] as int,
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
        'rolId': rolId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
