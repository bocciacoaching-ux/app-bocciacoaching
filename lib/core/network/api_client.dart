import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

/// Cliente HTTP centralizado para todas las llamadas a la API.
class ApiClient {
  final String _baseUrl = AppConstants.baseUrl;
  String? _authToken;

  /// Establece el token de autorización.
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Headers comunes para cada petición.
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // ── GET ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint')
          .replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: _headers)
          .timeout(AppConstants.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(
          'Sin conexión a Internet. Comprueba tu red e inténtalo de nuevo.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error inesperado: $e');
    }
  }

  // ── POST ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(
          'Sin conexión a Internet. Comprueba tu red e inténtalo de nuevo.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error inesperado: $e');
    }
  }

  // ── PUT ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(
          'Sin conexión a Internet. Comprueba tu red e inténtalo de nuevo.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error inesperado: $e');
    }
  }

  // ── DELETE ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl$endpoint'), headers: _headers)
          .timeout(AppConstants.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(
          'Sin conexión a Internet. Comprueba tu red e inténtalo de nuevo.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error inesperado: $e');
    }
  }

  // ── Response handler ─────────────────────────────────────────────
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = switch (response.statusCode) {
      401 => 'No autorizado. Inicia sesión de nuevo.',
      403 => 'No tienes permiso para realizar esta acción.',
      404 => 'Recurso no encontrado.',
      429 => 'Demasiados intentos. Espera unos minutos.',
      >= 500 => 'Error en el servidor. Inténtalo más tarde.',
      _ => body['message'] ?? 'Error desconocido (${response.statusCode}).',
    };

    if (response.statusCode == 401) {
      throw UnauthorizedException(message);
    }
    throw ServerException(message, statusCode: response.statusCode);
  }
}
