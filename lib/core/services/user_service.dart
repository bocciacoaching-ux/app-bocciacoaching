import 'dart:convert';
import 'dart:io';
import '../network/http_logger.dart';
import '../constants/app_config.dart';
import '../constants/app_constants.dart';

class UserService {
  final String _base = AppConfig.baseUrl;

  // GET /api/User
  Future<Map<String, dynamic>?> getInfoUser() async {
    try {
      final response = await HttpLogger.get(Uri.parse('$_base/User'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/User/AddInfoUser
  Future<Map<String, dynamic>?> addInfoUser({
    String? name,
    String? email,
    String? region,
    String? password,
    required String rol,
    String? category,
  }) async {
    // El backend solo acepta Coach o Athlete en el registro (nunca Admin).
    final String roleValue;
    switch (rol.toLowerCase()) {
      case 'entrenador':
      case AppConstants.roleCoachId:
        roleValue = AppConstants.roleCoachId;
      case 'deportista':
      case AppConstants.roleAthleteId:
        roleValue = AppConstants.roleAthleteId;
      default:
        return {
          'success': false,
          'message': 'Solo puedes registrarte como entrenador o deportista.',
        };
    }

    try {
      final response = await HttpLogger.post(
        Uri.parse('$_base/User/AddInfoUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          if (region != null && region.isNotEmpty) 'region': region,
          'password': password,
          'rol': roleValue,
          'category': category,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/User/ValidateEmail
  Future<Map<String, dynamic>?> validateEmail(String email) async {
    try {
      final response = await HttpLogger.post(
        Uri.parse('$_base/User/ValidateEmail'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Cambio y restablecimiento de contraseña: ver AuthService
  // (`/api/v1/auth/change-password` y `/api/v1/auth/password-reset/*`).

  // PUT /api/User/UpdateUserInfo
  //
  // Actualiza la información de perfil del usuario autenticado.
  //
  // El campo [image] debe enviarse como string Base64 puro (sin el prefijo
  // `data:image/...;base64,`). Si se quiere "limpiar" la foto basta con
  // enviar un string vacío o `null`.
  //
  // Devuelve siempre un Map con la siguiente forma:
  //   {'success': true,  'data': {...}}            → perfil actualizado OK
  //   {'success': false, 'message': 'Texto...'}    → error con mensaje legible
  Future<Map<String, dynamic>> updateUserInfo({
    required String userId,
    String? dni,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? country,
    String? image,
    String? category,
    DateTime? seniority,
    bool? status,
  }) async {
    try {
      final response = await HttpLogger.put(
        Uri.parse('$_base/User/UpdateUserInfo'),
        headers: {'Content-Type': 'application/json'},
        // El 403 tiene un mensaje propio (abajo): sin el aviso genérico.
        showErrorNotices: false,
        body: jsonEncode({
          'userId': userId,
          if (dni != null) 'dni': dni,
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (email != null) 'email': email,
          if (address != null) 'address': address,
          if (country != null) 'country': country,
          if (image != null) 'image': image,
          if (category != null) 'category': category,
          if (seniority != null) 'seniority': seniority.toIso8601String(),
          if (status != null) 'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};

        // Si la API devuelve explícitamente success=false, lo propagamos.
        if (body['success'] == false) {
          return {
            'success': false,
            'message': body['message'] as String? ??
                'No se pudo actualizar el perfil.',
          };
        }
        return {'success': true, 'data': body};
      }

      final String message = switch (response.statusCode) {
        400 => 'Los datos enviados no son válidos.',
        401 => 'Sesión expirada. Inicia sesión de nuevo.',
        // Solo se puede editar el propio perfil (salvo Admin).
        403 => 'Solo puedes modificar tu propio perfil',
        404 => 'Usuario no encontrado.',
        413 => 'La imagen es demasiado grande. Prueba con una más pequeña.',
        429 => 'Espera un minuto e inténtalo de nuevo',
        >= 500 => 'Error en el servidor. Inténtalo más tarde.',
        _ => 'No se pudo actualizar el perfil (código ${response.statusCode}).',
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
}
