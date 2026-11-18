import 'dart:async';

import 'package:web/web.dart' as web;

import 'token_store.dart';

TokenStore createPlatformTokenStore() => WebTokenStore();

/// Tokens en `window.localStorage`, compartidos entre pestanas del mismo
/// origen. El evento `storage` solo se dispara en las OTRAS pestanas, que es
/// justo lo que se necesita para sincronizarlas.
class WebTokenStore implements TokenStore {
  final _changes = StreamController<String?>.broadcast();
  StreamSubscription<web.StorageEvent>? _subscription;

  web.Storage get _storage => web.window.localStorage;

  @override
  Future<void> init() async {
    _subscription ??= web.EventStreamProviders.storageEvent
        .forTarget(web.window)
        .listen((event) {
      final key = event.key;
      if (key == null) {
        _changes.add(null); // localStorage.clear() en otra pestana
      } else if (key.startsWith(TokenKeys.prefix)) {
        _changes.add(key);
      }
    });
  }

  @override
  String? read(String key) {
    try {
      return _storage.getItem(key);
    } catch (_) {
      return null; // Almacenamiento bloqueado (modo privado estricto, etc.)
    }
  }

  @override
  Future<void> writeAll(Map<String, String> values) async {
    try {
      // Sin tear-off: los miembros externos de interop JS no se pueden
      // pasar como funcion (falla al compilar para web / wasm).
      values.forEach((key, value) => _storage.setItem(key, value));
    } catch (_) {}
  }

  @override
  Future<void> removeAll(Iterable<String> keys) async {
    try {
      for (final key in keys) {
        _storage.removeItem(key);
      }
    } catch (_) {}
  }

  @override
  Stream<String?> get externalChanges => _changes.stream;

  @override
  bool get isShared => true;
}
