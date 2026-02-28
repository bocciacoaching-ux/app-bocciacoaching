import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

/// Repositorio de autenticación — encapsula las llamadas a la API de auth.
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Inicia sesión con email y contraseña.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await _apiClient.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
    );
  }

  /// Registra un nuevo usuario.
  Future<Map<String, dynamic>> register({
    required Map<String, dynamic> userData,
  }) async {
    return await _apiClient.post(
      ApiEndpoints.register,
      body: userData,
    );
  }

  /// Cierra sesión.
  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }
}
