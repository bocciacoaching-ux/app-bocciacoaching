/// Clase base para representar fallos en la capa de dominio.
class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => 'Failure: $message';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a Internet.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de almacenamiento local.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación.']);
}
