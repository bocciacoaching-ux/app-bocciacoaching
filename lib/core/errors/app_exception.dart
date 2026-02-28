/// Excepción base de la aplicación.
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

/// Error de red (sin conexión a Internet).
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Error del servidor (5xx, etc.).
class ServerException extends AppException {
  final int? statusCode;
  ServerException(super.message, {this.statusCode});
}

/// No autorizado (401).
class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

/// No encontrado (404).
class NotFoundException extends AppException {
  NotFoundException(super.message);
}

/// Error de validación.
class ValidationException extends AppException {
  final Map<String, String>? errors;
  ValidationException(super.message, {this.errors});
}

/// Error de caché / almacenamiento local.
class CacheException extends AppException {
  CacheException(super.message);
}
