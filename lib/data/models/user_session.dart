import '../../core/constants/app_constants.dart';

class UserSession {
  final String userId;
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
  final String rolId;
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

  /// rolId de entrenador
  bool get isCoach => rolId == AppConstants.roleCoachId;

  /// rolId de deportista
  bool get isAthlete => rolId == AppConstants.roleAthleteId;

  String get fullName => '$firstName $lastName';

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'] as String,
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
      rolId: json['rolId'] as String,
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

  /// Devuelve una copia de la sesión con los campos indicados sobreescritos.
  ///
  /// Útil para refrescar la sesión localmente tras actualizar el perfil del
  /// usuario sin necesidad de volver a hacer login.
  UserSession copyWith({
    String? userId,
    String? dni,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? country,
    String? image,
    String? category,
    String? seniority,
    bool? status,
    String? rolId,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      dni: dni ?? this.dni,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      address: address ?? this.address,
      country: country ?? this.country,
      image: image ?? this.image,
      category: category ?? this.category,
      seniority: seniority ?? this.seniority,
      status: status ?? this.status,
      rolId: rolId ?? this.rolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
