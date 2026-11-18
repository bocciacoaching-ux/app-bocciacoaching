import 'dart:async';

import 'token_store_io.dart'
    if (dart.library.js_interop) 'token_store_web.dart' as platform;

/// Claves de almacenamiento de la sesion.
abstract final class TokenKeys {
  static const String prefix = 'bc_';
  static const String accessToken = 'bc_access_token';
  static const String refreshToken = 'bc_refresh_token';
  static const String accessTokenExpiresAt = 'bc_access_token_expires_at';
  static const String refreshTokenExpiresAt = 'bc_refresh_token_expires_at';

  /// Marca de "refresh en curso" para coordinar varias pestanas.
  static const String refreshLock = 'bc_refresh_lock';

  static const List<String> tokens = [
    accessToken,
    refreshToken,
    accessTokenExpiresAt,
    refreshTokenExpiresAt,
  ];
}

/// Almacenamiento de tokens.
///
/// - Web: `window.localStorage` (claves `bc_*`) y el evento `storage` para
///   enterarse de los cambios hechos en otras pestanas.
/// - Movil / escritorio: `FlutterSecureStorage` (no hay pestanas).
///
/// Las lecturas son sincronas: en web se lee siempre `localStorage` (asi se
/// ve al instante lo que guardo otra pestana) y en nativo una cache en
/// memoria cargada en [init].
abstract class TokenStore {
  Future<void> init();

  String? read(String key);

  Future<void> writeAll(Map<String, String> values);

  Future<void> removeAll(Iterable<String> keys);

  /// Claves `bc_*` modificadas por OTRA pestana. `null` = se borro todo
  /// (`localStorage.clear()`).
  Stream<String?> get externalChanges;

  /// `true` si puede haber otras instancias (pestanas) compartiendo tokens.
  bool get isShared;
}

/// Crea el almacenamiento adecuado para la plataforma actual.
TokenStore createTokenStore() => platform.createPlatformTokenStore();

/// Implementacion en memoria (pruebas y respaldo si falla el almacenamiento
/// seguro). [simulateExternalChange] emula el evento `storage` de otra
/// pestana.
class MemoryTokenStore implements TokenStore {
  final Map<String, String> values = {};
  final _changes = StreamController<String?>.broadcast();

  @override
  Future<void> init() async {}

  @override
  String? read(String key) => values[key];

  @override
  Future<void> writeAll(Map<String, String> entries) async =>
      values.addAll(entries);

  @override
  Future<void> removeAll(Iterable<String> keys) async {
    for (final k in keys) {
      values.remove(k);
    }
  }

  @override
  Stream<String?> get externalChanges => _changes.stream;

  @override
  bool get isShared => true;

  /// Emula que otra pestana escribio (o borro, si [value] es `null`) [key].
  void simulateExternalChange(String key, String? value) {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
    _changes.add(key);
  }
}
