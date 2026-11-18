import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_tokens.dart';
import '../auth/token_store.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_config.dart';
import '../network/app_messenger.dart';
import '../network/http_logger.dart';
import '../routes/app_routes.dart';

/// Eventos de sesion. [SessionProvider] los escucha para borrar o recargar
/// los datos del usuario (incluido cuando ocurren en otra pestana).
enum AuthEvent {
  loggedIn,
  tokensRefreshed,
  loggedOut,

  /// Otra pestana inicio sesion (esta no tenia sesion): hay que recargar
  /// los datos del usuario desde el almacenamiento.
  loggedInElsewhere,
}

/// Error al renovar la sesion.
class AuthException implements Exception {
  final String message;
  final int? statusCode;
  const AuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AuthException($statusCode): $message';
}

/// Autenticacion con JWT (access token de 15 min + refresh token rotativo
/// de 14 dias).
///
/// El estado es compartido: `AuthService()`, `AuthService.instance` y las
/// subclases usadas en pruebas ven la misma sesion.
///
/// Respuestas de los metodos de login / contrasena (para las pantallas):
///   `{'success': true,  'data': {...}, 'message': '...'}`
///   `{'success': false, 'message': '...', 'statusCode': 401}`
class AuthService {
  AuthService();

  static final AuthService instance = AuthService();

  // ── Estado compartido ─────────────────────────────────────────────────
  static TokenStore _store = createTokenStore();
  static AuthTokens? _tokens;
  static Future<AuthTokens>? _refreshing;
  static Timer? _proactiveTimer;
  static StreamSubscription<String?>? _storeSubscription;
  static StreamController<AuthEvent> _events =
      StreamController<AuthEvent>.broadcast();
  static Completer<void> _ready = Completer<void>();
  static bool _initialized = false;
  static final Random _random = Random();
  static final String _tabId =
      '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

  /// Tiempo maximo que una pestana espera a que otra termine su refresh.
  static const Duration _crossTabWait = Duration(seconds: 10);

  /// Eventos de sesion (login, renovacion, cierre).
  static Stream<AuthEvent> get events => _events.stream;

  /// Se completa cuando termino de restaurarse la sesion al arrancar.
  static Future<void> get ready => _ready.future;

  final String _base = AppConfig.baseUrl;
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  Uri _uri(String path) => Uri.parse('$_base$path');

  // ═══════════════════════════════════════════════════════════════════════
  //  Arranque (equivalente a APP_INITIALIZER)
  // ═══════════════════════════════════════════════════════════════════════

  /// Carga los tokens guardados y, si hay refresh token pero el access token
  /// falta o expiro, renueva la sesion sin pedir login. No bloquea: la
  /// renovacion continua en segundo plano y [ready] avisa cuando termina.
  Future<void> init({TokenStore? store}) async {
    if (_initialized) return;
    _initialized = true;
    if (store != null) _store = store;
    await _store.init();
    _tokens = _readStoredTokens();
    _storeSubscription = _store.externalChanges.listen(_onExternalChange);
    unawaited(_restoreSession());
  }

  Future<void> _restoreSession() async {
    try {
      final current = _tokens;
      if (current == null) return;
      if (current.isRefreshTokenExpired) {
        await logoutLocal();
      } else if (current.accessToken.isEmpty || current.isAccessTokenExpired) {
        // El splash decide la navegacion: aqui no se redirige.
        await refresh(redirectOnFailure: false);
      } else {
        _scheduleProactiveRefresh();
      }
    } catch (_) {
      // Sin red: se conserva la sesion; se reintentara en la proxima peticion.
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Consultas
  // ═══════════════════════════════════════════════════════════════════════

  /// Access token en memoria (lectura rapida para el interceptor).
  String? get accessToken {
    final token = _tokens?.accessToken;
    return (token == null || token.isEmpty) ? null : token;
  }

  AuthTokens? get tokens => _tokens;

  /// Hay refresh token y no ha expirado.
  bool isAuthenticated() {
    final current = _tokens;
    return current != null &&
        current.refreshToken.isNotEmpty &&
        !current.isRefreshTokenExpired;
  }

  /// Roles del claim `role` del access token (string o array -> lista).
  List<String> getRoles() => JwtPayload.decode(accessToken)?.roles ?? const [];

  bool hasRole(String role) =>
      getRoles().any((r) => r.toLowerCase() == role.toLowerCase());

  bool hasAnyRole(Iterable<String> roles) => roles.any(hasRole);

  /// Devuelve un access token vigente, renovandolo antes si ya expiro (asi
  /// se evita un 401 seguro). `null` si no hay sesion.
  Future<String?> validAccessToken() async {
    final current = _tokens;
    if (current == null) return null;
    if (current.accessToken.isNotEmpty && !current.isAccessTokenExpired) {
      return current.accessToken;
    }
    if (current.isRefreshTokenExpired) return accessToken;
    try {
      final renewed = await refresh(failedAccessToken: accessToken);
      return renewed.accessToken;
    } catch (_) {
      return accessToken;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Login
  // ═══════════════════════════════════════════════════════════════════════

  /// `POST /api/v1/auth/login`. Guarda los tokens; `data` es el usuario.
  Future<Map<String, dynamic>> login(String email, String password) {
    return _authenticate(
      ApiEndpoints.authLogin,
      {'email': email, 'password': password},
      unauthorizedMessage: 'Correo o contraseña incorrectos. '
          'Revísalos e inténtalo de nuevo.',
    );
  }

  /// `POST /api/v1/auth/google` con el ID token de Firebase.
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) {
    return _authenticate(
      ApiEndpoints.authGoogle,
      {'idToken': idToken},
      unauthorizedMessage:
          'No se pudo verificar tu cuenta de Google. Inténtalo de nuevo.',
    );
  }

  /// Compatibilidad con el nombre anterior (pantallas y pruebas).
  Future<Map<String, dynamic>?> signIn(String email, String password) =>
      login(email, password);

  Future<Map<String, dynamic>> _authenticate(
    String path,
    Map<String, dynamic> body, {
    required String unauthorizedMessage,
  }) async {
    try {
      final response = await HttpLogger.post(
        _uri(path),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      );
      final json = _decode(response);
      final ok = _isSuccess(response, json);
      final data = json?['data'];
      final tokens = AuthTokens.tryParse(data);

      if (ok && data is Map && tokens != null) {
        await _saveTokens(tokens);
        final user = Map<String, dynamic>.from(data)..remove('tokens');
        _events.add(AuthEvent.loggedIn);
        return {'success': true, 'message': json?['message'], 'data': user};
      }
      if (ok) {
        return _failure('La respuesta del servidor no incluye la sesión.',
            response.statusCode);
      }
      return _failure(
        response.statusCode == 401
            ? (_message(json) ?? unauthorizedMessage)
            : _messageForStatus(response.statusCode, json,
                fallback: 'No se pudo iniciar sesión.'),
        response.statusCode,
      );
    } catch (e) {
      return _networkFailure(e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Refresh: un solo refresh a la vez (equivalente a shareReplay(1))
  // ═══════════════════════════════════════════════════════════════════════

  /// Renueva la sesion. Si ya hay un refresh en curso, devuelve ese mismo
  /// resultado. [failedAccessToken] es el token que recibio el 401: si otra
  /// pestana ya guardo uno distinto y vigente, se adopta sin llamar al
  /// backend. Si `/refresh` responde 401 se cierra la sesion local y, si
  /// [redirectOnFailure], se navega a `/login?returnUrl=...`.
  Future<AuthTokens> refresh({
    String? failedAccessToken,
    bool redirectOnFailure = true,
  }) {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight;

    final future = _performRefresh(failedAccessToken, redirectOnFailure);
    _refreshing = future;
    // Limpia la referencia al terminar (con exito o error).
    unawaited(future.then<void>((_) {}, onError: (_) {}).whenComplete(() {
      if (identical(_refreshing, future)) _refreshing = null;
    }));
    return future;
  }

  Future<AuthTokens> _performRefresh(
    String? failedAccessToken,
    bool redirectOnFailure,
  ) async {
    // 1. Releer el almacenamiento: otra pestana pudo haber renovado ya.
    final stored = _readStoredTokens();
    if (_isUsable(stored, failedAccessToken)) return _adopt(stored!);

    var ownsLock = false;
    try {
      // 2. Si otra pestana esta renovando, esperar su resultado.
      if (_store.isShared) {
        final adopted = await _waitForOtherTab(failedAccessToken);
        if (adopted != null) return adopted;
        await _store.writeAll({
          TokenKeys.refreshLock:
              '$_tabId:${DateTime.now().millisecondsSinceEpoch}',
        });
        ownsLock = true;
      }

      // 3. Volver a leer el refresh token justo antes de llamar a /refresh.
      final latest = _readStoredTokens();
      if (_isUsable(latest, failedAccessToken)) return _adopt(latest!);
      if (latest == null ||
          latest.refreshToken.isEmpty ||
          latest.isRefreshTokenExpired) {
        await _endSession(redirectOnFailure);
        throw const AuthException('La sesión expiró.', statusCode: 401);
      }

      final http.Response response;
      try {
        response = await HttpLogger.post(
          _uri(ApiEndpoints.authRefresh),
          headers: _jsonHeaders,
          body: jsonEncode({'refreshToken': latest.refreshToken}),
        );
      } catch (e) {
        throw AuthException('Sin conexión al renovar la sesión ($e).');
      }

      final json = _decode(response);
      final renewed = AuthTokens.tryParse(json?['data']);
      if (_isSuccess(response, json) && renewed != null) {
        await _saveTokens(renewed); // Guarda los DOS tokens nuevos.
        _events.add(AuthEvent.tokensRefreshed);
        return renewed;
      }

      if (response.statusCode == 401) {
        // Carrera entre pestanas: si otra ya roto el token, usar el suyo.
        final afterRace = _readStoredTokens();
        if (afterRace != null &&
            afterRace.refreshToken != latest.refreshToken &&
            !afterRace.isRefreshTokenExpired) {
          return _adopt(afterRace);
        }
        await _endSession(redirectOnFailure);
        throw AuthException(
          _message(json) ?? 'La sesión expiró. Inicia sesión de nuevo.',
          statusCode: 401,
        );
      }

      // 429 / 5xx: no se cierra la sesion, se podra reintentar.
      throw AuthException(
        _messageForStatus(response.statusCode, json,
            fallback: 'No se pudo renovar la sesión.'),
        statusCode: response.statusCode,
      );
    } finally {
      if (ownsLock) await _releaseLock();
    }
  }

  /// Tokens guardados distintos del que fallo y con access token vigente.
  bool _isUsable(AuthTokens? candidate, String? failedAccessToken) {
    if (candidate == null) return false;
    if (candidate.accessToken.isEmpty || candidate.isAccessTokenExpired) {
      return false;
    }
    if (candidate.isRefreshTokenExpired) return false;
    return candidate.accessToken != failedAccessToken;
  }

  AuthTokens _adopt(AuthTokens tokens) {
    final changed = _tokens?.accessToken != tokens.accessToken;
    _tokens = tokens;
    _scheduleProactiveRefresh();
    if (changed) _events.add(AuthEvent.tokensRefreshed);
    return tokens;
  }

  /// Si otra pestana tiene el candado de refresh (reciente), espera a que
  /// guarde los tokens nuevos y los adopta.
  Future<AuthTokens?> _waitForOtherTab(String? failedAccessToken) async {
    final lock = _parseLock(_store.read(TokenKeys.refreshLock));
    if (lock == null || lock.tabId == _tabId) return null;
    final age = DateTime.now().difference(lock.at);
    if (age > _crossTabWait) return null;

    final deadline = DateTime.now().add(_crossTabWait - age);
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      final stored = _readStoredTokens();
      if (_isUsable(stored, failedAccessToken)) return _adopt(stored!);
      if (_store.read(TokenKeys.refreshLock) == null) break;
    }
    final stored = _readStoredTokens();
    return _isUsable(stored, failedAccessToken) ? _adopt(stored!) : null;
  }

  Future<void> _releaseLock() async {
    final lock = _parseLock(_store.read(TokenKeys.refreshLock));
    if (lock != null && lock.tabId == _tabId) {
      await _store.removeAll([TokenKeys.refreshLock]);
    }
  }

  static ({String tabId, DateTime at})? _parseLock(String? raw) {
    if (raw == null) return null;
    final index = raw.lastIndexOf(':');
    if (index <= 0) return null;
    final ms = int.tryParse(raw.substring(index + 1));
    if (ms == null) return null;
    return (
      tabId: raw.substring(0, index),
      at: DateTime.fromMillisecondsSinceEpoch(ms),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Logout
  // ═══════════════════════════════════════════════════════════════════════

  /// `POST /api/v1/auth/logout` (ignora errores) + [logoutLocal] + login.
  Future<void> logout({bool navigate = true}) async {
    final refreshToken =
        _tokens?.refreshToken ?? _store.read(TokenKeys.refreshToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await HttpLogger.post(
          _uri(ApiEndpoints.authLogout),
          headers: _jsonHeaders,
          body: jsonEncode({'refreshToken': refreshToken}),
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        // Se ignora: la sesion local se cierra igualmente.
      }
    }
    await logoutLocal();
    if (navigate) _goToLogin(withReturnUrl: false);
  }

  /// `POST /api/v1/auth/logout-all`: cierra la sesion en TODOS los
  /// dispositivos (incluido este).
  Future<Map<String, dynamic>> logoutAll() async {
    try {
      final response = await HttpLogger.post(
        _uri(ApiEndpoints.authLogoutAll),
        headers: _jsonHeaders,
      );
      final json = _decode(response);
      if (!_isSuccess(response, json)) {
        return _failure(
          _messageForStatus(response.statusCode, json,
              fallback: 'No se pudieron cerrar las sesiones.'),
          response.statusCode,
        );
      }
    } catch (e) {
      return _networkFailure(e);
    }
    await logoutLocal();
    _goToLogin(withReturnUrl: false);
    return {'success': true};
  }

  /// Borra tokens de memoria y del almacenamiento y avisa a los oyentes
  /// (SessionProvider borra el usuario). En web, las demas pestanas reciben
  /// el evento `storage` y cierran sesion tambien.
  Future<void> logoutLocal() async {
    _tokens = null;
    _proactiveTimer?.cancel();
    _proactiveTimer = null;
    await _store.removeAll([...TokenKeys.tokens, TokenKeys.refreshLock]);
    _events.add(AuthEvent.loggedOut);
  }

  Future<void> _endSession(bool redirect) async {
    await logoutLocal();
    if (redirect) _goToLogin(withReturnUrl: true);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Contrasenas
  // ═══════════════════════════════════════════════════════════════════════

  /// `POST /api/v1/auth/change-password`. Guarda el par de tokens nuevo que
  /// devuelve el backend (las demas sesiones del usuario se cierran).
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await HttpLogger.post(
        _uri(ApiEndpoints.authChangePassword),
        headers: _jsonHeaders,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );
      final json = _decode(response);
      if (_isSuccess(response, json)) {
        final tokens = AuthTokens.tryParse(json?['data']);
        if (tokens != null) {
          await _saveTokens(tokens);
          _events.add(AuthEvent.tokensRefreshed);
        }
        return {
          'success': true,
          'message': _message(json) ?? 'Contraseña actualizada.',
        };
      }
      final message = switch (response.statusCode) {
        400 => _message(json) ?? 'La contraseña actual es incorrecta.',
        401 => 'Tu sesión expiró. Inicia sesión de nuevo.',
        _ => _messageForStatus(response.statusCode, json,
            fallback: 'No se pudo actualizar la contraseña.'),
      };
      return _failure(message, response.statusCode);
    } catch (e) {
      return _networkFailure(e);
    }
  }

  /// Paso 1: `POST /api/v1/auth/password-reset/request`. El backend responde
  /// siempre 200 (exista o no el correo).
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await HttpLogger.post(
        _uri(ApiEndpoints.authPasswordResetRequest),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email}),
      );
      final json = _decode(response);
      if (_isSuccess(response, json)) {
        return {
          'success': true,
          'message': 'Si el correo está registrado, recibirás un código',
        };
      }
      return _failure(
        _messageForStatus(response.statusCode, json,
            fallback: 'No se pudo enviar el código.'),
        response.statusCode,
      );
    } catch (e) {
      return _networkFailure(e);
    }
  }

  /// Paso 2: `POST /api/v1/auth/password-reset/verify`. Si el codigo es
  /// correcto devuelve `resetToken` (10 min, un solo uso). 400 = codigo
  /// incorrecto; tras 5 intentos el codigo se invalida (el `message` del
  /// backend lo indica).
  Future<Map<String, dynamic>> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await HttpLogger.post(
        _uri(ApiEndpoints.authPasswordResetVerify),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'code': code}),
      );
      final json = _decode(response);
      final data = json?['data'];
      final resetToken = data is Map ? data['resetToken'] as String? : null;
      if (_isSuccess(response, json) && resetToken != null) {
        return {
          'success': true,
          'resetToken': resetToken,
          'expiresAt': data is Map ? data['expiresAt'] : null,
        };
      }
      return _failure(
        response.statusCode == 400
            ? (_message(json) ?? 'El código es incorrecto.')
            : _messageForStatus(response.statusCode, json,
                fallback: 'No se pudo verificar el código.'),
        response.statusCode,
      );
    } catch (e) {
      return _networkFailure(e);
    }
  }

  /// Paso 3: `POST /api/v1/auth/password-reset/confirm`. 401 = el token de
  /// restablecimiento es invalido o expiro (hay que volver al paso 1).
  Future<Map<String, dynamic>> confirmPasswordReset({
    required String email,
    required String newPassword,
    required String resetToken,
  }) async {
    try {
      final response = await HttpLogger.post(
        _uri(ApiEndpoints.authPasswordResetConfirm),
        headers: _jsonHeaders,
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
          'resetToken': resetToken,
        }),
      );
      final json = _decode(response);
      if (_isSuccess(response, json)) {
        // El backend cerro todas las sesiones de ese usuario.
        if (_tokens != null) await logoutLocal();
        return {'success': true, 'message': _message(json)};
      }
      final message = switch (response.statusCode) {
        401 => 'El código expiró o ya se usó. Solicita uno nuevo.',
        400 => _message(json) ?? 'La nueva contraseña no es válida.',
        _ => _messageForStatus(response.statusCode, json,
            fallback: 'No se pudo restablecer la contraseña.'),
      };
      return _failure(message, response.statusCode);
    } catch (e) {
      return _networkFailure(e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Persistencia y sincronizacion entre pestanas
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _saveTokens(AuthTokens tokens) async {
    _tokens = tokens;
    await _store.writeAll({
      TokenKeys.accessToken: tokens.accessToken,
      TokenKeys.refreshToken: tokens.refreshToken,
      TokenKeys.accessTokenExpiresAt:
          tokens.accessTokenExpiresAt.toUtc().toIso8601String(),
      TokenKeys.refreshTokenExpiresAt:
          tokens.refreshTokenExpiresAt.toUtc().toIso8601String(),
    });
    _scheduleProactiveRefresh();
  }

  /// Tokens guardados. El access token puede faltar (se renovara).
  static AuthTokens? _readStoredTokens() {
    final refresh = _store.read(TokenKeys.refreshToken);
    if (refresh == null || refresh.isEmpty) return null;
    final access = _store.read(TokenKeys.accessToken) ?? '';
    DateTime? parse(String key) {
      final raw = _store.read(key);
      return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
    }

    return AuthTokens(
      accessToken: access,
      accessTokenExpiresAt: parse(TokenKeys.accessTokenExpiresAt) ??
          JwtPayload.decode(access)?.expiresAt ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      refreshToken: refresh,
      refreshTokenExpiresAt: parse(TokenKeys.refreshTokenExpiresAt) ??
          DateTime.now().toUtc().add(const Duration(days: 14)),
    );
  }

  /// Otra pestana cambio las claves `bc_*`.
  static void _onExternalChange(String? key) {
    if (key == TokenKeys.refreshLock) return;
    final stored = _readStoredTokens();
    if (stored == null) {
      // Otra pestana cerro sesion: cerrar tambien aqui.
      if (_tokens != null) {
        _tokens = null;
        _proactiveTimer?.cancel();
        _events.add(AuthEvent.loggedOut);
        _goToLogin(withReturnUrl: false);
      }
      return;
    }
    final wasLoggedOut = _tokens == null;
    final changed = _tokens?.accessToken != stored.accessToken ||
        _tokens?.refreshToken != stored.refreshToken;
    if (!changed) return;
    _tokens = stored;
    _scheduleProactiveRefresh();
    _events.add(wasLoggedOut
        ? AuthEvent.loggedInElsewhere
        : AuthEvent.tokensRefreshed);
  }

  /// Refresco proactivo ~1 minuto antes de que expire el access token. Se
  /// anade un pequeno margen aleatorio para que varias pestanas no coincidan.
  static void _scheduleProactiveRefresh() {
    _proactiveTimer?.cancel();
    _proactiveTimer = null;
    final current = _tokens;
    if (current == null ||
        current.accessToken.isEmpty ||
        current.isRefreshTokenExpired) {
      return;
    }
    var delay = current.accessTokenExpiresAt.difference(DateTime.now()) -
        const Duration(minutes: 1) -
        Duration(seconds: _random.nextInt(15));
    if (delay.isNegative) delay = Duration.zero;
    _proactiveTimer = Timer(delay, () {
      instance
          .refresh(failedAccessToken: current.accessToken)
          .then<void>((_) {}, onError: (_) {});
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Navegacion
  // ═══════════════════════════════════════════════════════════════════════

  static const Set<String> _authRoutes = {
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.splash,
  };

  /// Lleva al login (`/?returnUrl=...`). No hace nada si la app aun no
  /// tiene navegador (arranque, pruebas) o si ya se esta en una ruta
  /// publica de autenticacion.
  static void _goToLogin({required bool withReturnUrl}) {
    if (Get.key.currentState == null) return;
    final current = Get.currentRoute;
    final currentPath = Uri.tryParse(current)?.path ?? current;
    if (_authRoutes.contains(currentPath)) return;
    final target = withReturnUrl && current.isNotEmpty
        ? '${AppRoutes.login}?returnUrl=${Uri.encodeComponent(current)}'
        : AppRoutes.login;
    Get.offAllNamed(target);
    if (withReturnUrl) {
      AppMessenger.show('Tu sesión expiró. Inicia sesión de nuevo.');
    }
  }

  /// Ruta a la que volver tras el login (de `?returnUrl=`), si es valida.
  /// Se lee de los parametros de GetX o, si no, de [routeName] (el nombre
  /// de la ruta actual, p. ej. `ModalRoute.of(context)?.settings.name`).
  static String? returnUrlFromRoute([String? routeName]) {
    var raw = Get.parameters['returnUrl'];
    if ((raw == null || raw.isEmpty) && routeName != null) {
      raw = Uri.tryParse(routeName)?.queryParameters['returnUrl'];
    }
    // Solo rutas internas (evita redirecciones abiertas).
    if (raw == null || raw.isEmpty || !raw.startsWith('/')) return null;
    if (raw.startsWith('//')) return null;
    final path = Uri.tryParse(raw)?.path ?? raw;
    if (_authRoutes.contains(path) || path == AppRoutes.biometricLock) {
      return null;
    }
    return raw;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Utilidades de respuesta
  // ═══════════════════════════════════════════════════════════════════════

  static Map<String, dynamic>? _decode(http.Response response) {
    if (response.body.isEmpty) return null;
    try {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// 2xx y, si viene el contrato, `success != false`.
  static bool _isSuccess(http.Response response, Map<String, dynamic>? json) =>
      response.statusCode >= 200 &&
      response.statusCode < 300 &&
      json?['success'] != false;

  static String? _message(Map<String, dynamic>? json) {
    final message = json?['message'] ?? json?['detail'] ?? json?['title'];
    final text = message?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  static String _messageForStatus(
    int status,
    Map<String, dynamic>? json, {
    required String fallback,
  }) {
    return switch (status) {
      429 => AppMessenger.tooManyRequestsMessage,
      403 => _message(json) ?? AppMessenger.forbiddenMessage,
      >= 500 => 'Error en el servidor. Inténtalo más tarde.',
      _ => _message(json) ?? fallback,
    };
  }

  static Map<String, dynamic> _failure(String message, int? statusCode) => {
        'success': false,
        'message': message,
        if (statusCode != null) 'statusCode': statusCode,
      };

  static Map<String, dynamic> _networkFailure(Object error) {
    debugPrint('[AuthService] error de red: $error');
    return _failure(
      'Sin conexión a Internet. Comprueba tu red e inténtalo de nuevo.',
      null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  Pruebas
  // ═══════════════════════════════════════════════════════════════════════

  /// Reinicia el estado compartido (solo para pruebas).
  @visibleForTesting
  static Future<void> resetForTesting({TokenStore? store}) async {
    _proactiveTimer?.cancel();
    _proactiveTimer = null;
    await _storeSubscription?.cancel();
    _storeSubscription = null;
    _tokens = null;
    _refreshing = null;
    _initialized = false;
    _ready = Completer<void>();
    await _events.close();
    _events = StreamController<AuthEvent>.broadcast();
    _store = store ?? MemoryTokenStore();
  }
}
