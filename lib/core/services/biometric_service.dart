import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio que encapsula toda la lógica de autenticación biométrica
/// (huella digital / Face ID).
class BiometricService {
  static const _kBiometricEnabledKey = 'biometric_enabled';

  final LocalAuthentication _auth = LocalAuthentication();

  // ────────────────────────────────────────────────────────────────
  // Capacidad del dispositivo
  // ────────────────────────────────────────────────────────────────

  /// Devuelve `true` si el dispositivo soporta autenticación biométrica.
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Devuelve `true` si hay al menos una biometría registrada en el dispositivo.
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Lista los tipos de biometría disponibles (fingerprint, face, iris…).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Devuelve `true` si el dispositivo soporta biometría Y tiene al menos
  /// una huella/rostro registrado.
  Future<bool> isBiometricAvailable() async {
    final supported = await isDeviceSupported();
    final canCheck = await canCheckBiometrics();
    return supported && canCheck;
  }

  // ────────────────────────────────────────────────────────────────
  // Preferencia del usuario (activar / desactivar)
  // ────────────────────────────────────────────────────────────────

  /// Devuelve `true` si el usuario ha activado el desbloqueo biométrico.
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kBiometricEnabledKey) ?? false;
  }

  /// Activa o desactiva el desbloqueo biométrico.
  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometricEnabledKey, value);
  }

  // ────────────────────────────────────────────────────────────────
  // Autenticación
  // ────────────────────────────────────────────────────────────────

  /// Muestra el diálogo nativo de biometría.
  /// Devuelve `true` si la autenticación fue exitosa.
  Future<bool> authenticate({
    String reason = 'Autentícate para acceder a la aplicación',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false, // permite PIN/patrón como fallback
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  /// Devuelve una etiqueta descriptiva de los métodos biométricos disponibles.
  Future<String> getBiometricLabel() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Huella digital';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Reconocimiento de iris';
    }
    return 'Biometría';
  }

  /// Devuelve `true` si la funcionalidad debería mostrarse al usuario
  /// (dispositivo compatible Y usuario logueado).
  Future<bool> shouldShowBiometricOption() async {
    return await isBiometricAvailable();
  }
}
