import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_session.dart';

class SessionProvider extends ChangeNotifier {
  static const _kSessionKey = 'user_session';

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
    notifyListeners();
  }
}
