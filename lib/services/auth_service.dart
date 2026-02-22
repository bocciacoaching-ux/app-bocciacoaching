import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthService {
  final String _base = AppConfig.baseUrl;

  // POST /api/User/login
  //
  // Retorna un Map con:
  //   {'success': true,  'data': {...}}          → inicio de sesión OK
  //   {'success': false, 'message': 'Texto...'}  → error con mensaje legible
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/User/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      // Mensajes de error según código HTTP
      final String message = switch (response.statusCode) {
        401 => 'Correo o contraseña incorrectos. Revísalos e inténtalo de nuevo.',
        403 => 'Tu cuenta no tiene permiso para acceder. Contacta con soporte.',
        404 => 'No existe una cuenta con ese correo electrónico.',
        429 => 'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.',
        >= 500 => 'Error en el servidor. Inténtalo más tarde.',
        _ => 'No se pudo iniciar sesión (código ${response.statusCode}).',
      };

      return {'success': false, 'message': message};
    } on SocketException {
      return {
        'success': false,
        'message':
            'Sin conexión a Internet. Comprueba tu red e inténtalo de nuevo.',
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Ocurrió un error inesperado. Inténtalo de nuevo.',
      };
    }
  }

  Future<void> signOut() async {
    // Limpia la sesión local; extender con llamada al servidor si la API lo requiere.
  }
}
