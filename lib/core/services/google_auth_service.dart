import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../network/http_logger.dart';
import '../constants/app_config.dart';
import '../constants/api_endpoints.dart';

/// Servicio encargado de iniciar sesión con Google a través de Firebase
/// Authentication y de intercambiar el `idToken` resultante con el backend
/// propio (endpoint `POST /api/User/login/google`).
class GoogleAuthService {
  final String _base = AppConfig.baseUrl;

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const ['email'],
              // Debe coincidir con el "ID de cliente web" configurado en
              // Firebase Console > Authentication > Sign-in method > Google.
              serverClientId:
                  '492594867983-ggod61bakp64jgolr1o3mokmc3rlnqci.apps.googleusercontent.com',
            );

  /// Lanza el flujo de Google Sign-In, autentica contra Firebase y envía el
  /// `idToken` de Firebase al backend.
  ///
  /// Retorna un Map con la misma forma que el resto de servicios de auth:
  ///   {'success': true,  'data': {...}}          → inicio de sesión OK
  ///   {'success': false, 'message': 'Texto...'}  → error con mensaje legible
  ///   {'success': false, 'cancelled': true}      → el usuario canceló el flujo
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // 1. Selección de cuenta de Google.
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario cerró el selector de cuentas sin elegir ninguna.
        return {'success': false, 'cancelled': true};
      }

      // 2. Obtener credenciales de Google y autenticar con Firebase.
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // 3. Obtener el idToken de Firebase (JWT) para enviarlo al backend.
      final firebaseIdToken = await userCredential.user?.getIdToken();
      if (firebaseIdToken == null) {
        return {
          'success': false,
          'message': 'No se pudo obtener el token de Firebase.',
        };
      }

      // 4. Intercambiar el idToken con nuestro backend.
      return await _loginWithBackend(firebaseIdToken);
    } on fb.FirebaseAuthException catch (e, st) {
      developer.log('FirebaseAuthException en signInWithGoogle',
          error: e, stackTrace: st, name: 'GoogleAuthService');
      return {
        'success': false,
        'message': e.message ?? 'Error al autenticar con Firebase.',
      };
    } on SocketException {
      return {
        'success': false,
        'message':
            'Sin conexión a Internet. Comprueba tu red e inténtalo de nuevo.',
      };
    } catch (e, st) {
      developer.log('Error inesperado en signInWithGoogle',
          error: e, stackTrace: st, name: 'GoogleAuthService');
      return {
        'success': false,
        'message':
            'Ocurrió un error inesperado al iniciar sesión con Google. '
            '($e)',
      };
    }
  }

  Future<Map<String, dynamic>> _loginWithBackend(String idToken) async {
    final response = await HttpLogger.post(
      Uri.parse('$_base${ApiEndpoints.loginGoogle}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'success': body['success'] ?? true,
        'message': body['message'],
        'data': body['data'],
      };
    }

    final String message = switch (response.statusCode) {
      401 => 'No se pudo verificar tu cuenta de Google. Inténtalo de nuevo.',
      403 => 'Tu cuenta no tiene permiso para acceder. Contacta con soporte.',
      404 => 'No existe una cuenta asociada a este correo de Google.',
      >= 500 => 'Error en el servidor. Inténtalo más tarde.',
      _ => 'No se pudo iniciar sesión con Google (código ${response.statusCode}).',
    };

    return {'success': false, 'message': message};
  }

  /// Cierra la sesión de Google y Firebase (usar junto al logout general).
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
