/// Modelo que representa un Rol del sistema (backend controlador Rol).
class Rol {
  final String id;
  final String name;
  final String? description;

  Rol({required this.id, required this.name, this.description});

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: (json['id'] ?? json['rolId'] ?? '').toString(),
      name: (json['name'] ?? json['rolName'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
      };
}
