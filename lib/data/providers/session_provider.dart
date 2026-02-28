import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_session.dart';

class SessionProvider extends ChangeNotifier {
  static const _kSessionKey = 'user_session';
  static const _kEmailKey = 'user_email';
  static const _kPasswordKey = 'user_password';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserSession? _session;

  UserSession? get session => _session;
  bool get isLoggedIn => _session != null;

  /// Carga la sesión guardada en disco al arrancar la app.
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessionKey);
    if (raw != null) {
      try {
        _session = UserSession.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
        notifyListeners();
      } catch (_) {
        // Datos corruptos: se ignoran
        await prefs.remove(_kSessionKey);
      }
    }
  }

  /// Guarda la sesión a partir del campo "data" del response de la API.
  Future<void> saveSession(Map<String, dynamic> data) async {
    _session = UserSession.fromJson(data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSessionKey, jsonEncode(_session!.toJson()));
    notifyListeners();
  }

  /// Cierra la sesión y elimina los datos persistidos.
  Future<void> clearSession() async {
    _session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionKey);
    await _secureStorage.delete(key: _kEmailKey);
    await _secureStorage.delete(key: _kPasswordKey);
    notifyListeners();
  }

  // ── Credenciales para re-autenticación biométrica ──────────────

  /// Guarda email y contraseña de forma segura para poder
  /// re-autenticar con la API tras desbloqueo biométrico.
  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: _kEmailKey, value: email);
    await _secureStorage.write(key: _kPasswordKey, value: password);
  }

  /// Devuelve las credenciales guardadas, o `null` si no existen.
  Future<({String email, String password})?> getCredentials() async {
    final email = await _secureStorage.read(key: _kEmailKey);
    final password = await _secureStorage.read(key: _kPasswordKey);
    if (email != null && password != null) {
      return (email: email, password: password);
    }
    return null;
  }
}
