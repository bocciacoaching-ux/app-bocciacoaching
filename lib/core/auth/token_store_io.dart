import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_store.dart';

TokenStore createPlatformTokenStore() => SecureTokenStore();

/// Tokens en el almacenamiento seguro del sistema (Keychain / Keystore).
/// Se cargan en memoria en [init] para poder leerlos de forma sincrona.
/// Si el almacenamiento seguro no esta disponible (pruebas, entitlements),
/// se sigue funcionando solo en memoria.
class SecureTokenStore implements TokenStore {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  final Map<String, String> _cache = {};
  bool _available = true;

  @override
  Future<void> init() async {
    try {
      for (final key in [...TokenKeys.tokens]) {
        final value = await _secure.read(key: key);
        if (value != null) _cache[key] = value;
      }
    } catch (_) {
      _available = false;
    }
  }

  @override
  String? read(String key) => _cache[key];

  @override
  Future<void> writeAll(Map<String, String> values) async {
    _cache.addAll(values);
    if (!_available) return;
    try {
      for (final entry in values.entries) {
        await _secure.write(key: entry.key, value: entry.value);
      }
    } catch (_) {
      _available = false;
    }
  }

  @override
  Future<void> removeAll(Iterable<String> keys) async {
    final list = keys.toList();
    for (final key in list) {
      _cache.remove(key);
    }
    if (!_available) return;
    try {
      for (final key in list) {
        await _secure.delete(key: key);
      }
    } catch (_) {
      _available = false;
    }
  }

  // Una sola instancia de la app: no hay otras pestanas.
  @override
  Stream<String?> get externalChanges => const Stream.empty();

  @override
  bool get isShared => false;
}
