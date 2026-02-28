import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de almacenamiento local (SharedPreferences + FlutterSecureStorage).
class StorageService {
  late final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Inicializa SharedPreferences. Llamar antes de usar.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── SharedPreferences ────────────────────────────────────────────
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();

  // ── Secure Storage ───────────────────────────────────────────────
  Future<String?> getSecure(String key) => _secureStorage.read(key: key);
  Future<void> setSecure(String key, String value) =>
      _secureStorage.write(key: key, value: value);
  Future<void> removeSecure(String key) => _secureStorage.delete(key: key);
  Future<void> clearSecure() => _secureStorage.deleteAll();
}
