import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:boccia_coaching_app/core/auth/api_auth_policy.dart';
import 'package:boccia_coaching_app/core/auth/auth_guards.dart';
import 'package:boccia_coaching_app/core/auth/auth_tokens.dart';
import 'package:boccia_coaching_app/core/auth/token_store.dart';
import 'package:boccia_coaching_app/core/constants/app_config.dart';
import 'package:boccia_coaching_app/core/network/http_logger.dart';
import 'package:boccia_coaching_app/core/services/auth_service.dart';

// ── Utilidades ─────────────────────────────────────────────────────────────

const String base = AppConfig.baseUrl;
Uri api(String path) => Uri.parse('$base$path');

/// JWT sin firma valida (el cliente no la verifica).
String jwt({Object role = 'Coach', Duration ttl = const Duration(minutes: 15)}) {
  String enc(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  final exp = DateTime.now().add(ttl).millisecondsSinceEpoch ~/ 1000;
  return '${enc({'alg': 'HS256'})}.'
      '${enc({'sub': 'user-1', 'email': 'a@b.com', 'role': role, 'exp': exp})}.'
      'firma';
}

Map<String, dynamic> tokensJson(String access, String refresh,
        {Duration accessTtl = const Duration(minutes: 15)}) =>
    {
      'tokenType': 'Bearer',
      'accessToken': access,
      'accessTokenExpiresAt':
          DateTime.now().toUtc().add(accessTtl).toIso8601String(),
      'refreshToken': refresh,
      'refreshTokenExpiresAt':
          DateTime.now().toUtc().add(const Duration(days: 14)).toIso8601String(),
    };

http.Response jsonResponse(int status, Object body) =>
    http.Response(jsonEncode(body), status,
        headers: {'content-type': 'application/json'});

/// Guarda una sesion en el almacenamiento antes de `init()`.
void seedSession(MemoryTokenStore store, String access, String refresh,
    {Duration accessTtl = const Duration(minutes: 15)}) {
  final t = tokensJson(access, refresh, accessTtl: accessTtl);
  store.values.addAll({
    TokenKeys.accessToken: access,
    TokenKeys.refreshToken: refresh,
    TokenKeys.accessTokenExpiresAt: t['accessTokenExpiresAt'] as String,
    TokenKeys.refreshTokenExpiresAt: t['refreshTokenExpiresAt'] as String,
  });
}

late MemoryTokenStore store;
final List<http.Request> requests = [];
late Future<http.Response> Function(http.Request) handler;

Future<void> startAuth() async {
  await AuthService.resetForTesting(store: store);
  await AuthService.instance.init(store: store);
  await AuthService.ready;
}

void main() {
  setUp(() {
    store = MemoryTokenStore();
    requests.clear();
    HttpLogger.enabled = false;
    HttpLogger.client = MockClient((request) async {
      requests.add(request);
      return handler(request);
    });
  });

  tearDown(() async {
    await AuthService.resetForTesting();
  });

  int refreshCalls() =>
      requests.where((r) => r.url.path.endsWith('/v1/auth/refresh')).length;

  // ── Interceptor: cabecera Authorization ─────────────────────────────────
  group('Authorization', () {
    test('se envia a la API, no a endpoints publicos ni a otros dominios',
        () async {
      final access = jwt();
      seedSession(store, access, 'r1');
      await startAuth();
      handler = (_) async => jsonResponse(200, {'success': true});

      await HttpLogger.get(api('/v1/users/u/teams'));
      await HttpLogger.post(api('/v1/auth/login'), body: '{}');
      await HttpLogger.get(api('/Rol/GetAll'));
      await HttpLogger.get(api('/Rol/GetById/123'));
      await HttpLogger.get(Uri.parse('https://firebase.googleapis.com/x'));

      expect(requests[0].headers['Authorization'], 'Bearer $access');
      for (final r in requests.skip(1)) {
        expect(r.headers.containsKey('Authorization'), isFalse,
            reason: r.url.toString());
      }
    });

    test('politica: rutas publicas y que no refrescan', () {
      expect(ApiAuthPolicy.isPublic(api('/v1/auth/refresh')), isTrue);
      expect(ApiAuthPolicy.isPublic(api('/Subscription/types/9')), isTrue);
      expect(ApiAuthPolicy.isPublic(api('/v1/auth/logout-all')), isFalse);
      expect(ApiAuthPolicy.shouldAttachToken(api('/v1/auth/logout-all')),
          isTrue);
      expect(ApiAuthPolicy.canRefreshOn401(api('/v1/auth/change-password')),
          isFalse);
      expect(ApiAuthPolicy.canRefreshOn401(api('/User/UpdateUserInfo')),
          isTrue);
      expect(ApiAuthPolicy.isOurApi(Uri.parse('https://api.stripe.com/v1')),
          isFalse);
    });
  });

  // ── Refresh ─────────────────────────────────────────────────────────────
  group('Refresh', () {
    test('5 peticiones simultaneas con 401 → UN solo /refresh y reintento',
        () async {
      final oldAccess = jwt(), newAccess = jwt(role: ['Coach', 'Admin']);
      seedSession(store, oldAccess, 'r1');
      await startAuth();

      handler = (request) async {
        if (request.url.path.endsWith('/v1/auth/refresh')) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          expect(jsonDecode(request.body)['refreshToken'], 'r1');
          return jsonResponse(
              200, {'success': true, 'data': tokensJson(newAccess, 'r2')});
        }
        return request.headers['Authorization'] == 'Bearer $newAccess'
            ? jsonResponse(200, {'success': true, 'data': []})
            : jsonResponse(401, {'success': false});
      };

      final responses = await Future.wait(List.generate(
          5, (i) => HttpLogger.get(api('/v1/teams/team-$i'))));

      expect(responses.map((r) => r.statusCode), everyElement(200));
      expect(refreshCalls(), 1);
      // 5 intentos con el token viejo + 5 reintentos + 1 refresh.
      expect(requests.length, 11);
      // Se guardaron LOS DOS tokens nuevos.
      expect(store.values[TokenKeys.accessToken], newAccess);
      expect(store.values[TokenKeys.refreshToken], 'r2');
      expect(AuthService.instance.hasRole('Admin'), isTrue);
    });

    test('un 401 tras el reintento no vuelve a refrescar (sin bucles)',
        () async {
      seedSession(store, jwt(), 'r1');
      await startAuth();
      handler = (request) async => request.url.path.endsWith('/refresh')
          ? jsonResponse(200, {'success': true, 'data': tokensJson(jwt(), 'r2')})
          : jsonResponse(401, {'success': false});

      final response = await HttpLogger.get(api('/v1/teams/x'));
      expect(response.statusCode, 401);
      expect(refreshCalls(), 1);
      expect(requests.length, 3); // original + refresh + 1 reintento
    });

    test('access token expirado: se renueva antes de la peticion', () async {
      final newAccess = jwt();
      seedSession(store, jwt(ttl: const Duration(minutes: -1)), 'r1',
          accessTtl: const Duration(minutes: -1));
      handler = (request) async => request.url.path.endsWith('/refresh')
          ? jsonResponse(
              200, {'success': true, 'data': tokensJson(newAccess, 'r2')})
          : jsonResponse(200, {'success': true});
      // init() restaura la sesion (APP_INITIALIZER) con un unico refresh.
      await startAuth();
      expect(refreshCalls(), 1);
      expect(AuthService.instance.accessToken, newAccess);

      final response = await HttpLogger.get(api('/v1/teams/x'));
      expect(response.statusCode, 200);
      expect(requests.last.headers['Authorization'], 'Bearer $newAccess');
      expect(refreshCalls(), 1);
    });

    test('/refresh devuelve 401 → se borra la sesion local', () async {
      seedSession(store, jwt(), 'r1');
      await startAuth();
      final events = <AuthEvent>[];
      final sub = AuthService.events.listen(events.add);
      handler = (_) async => jsonResponse(401, {'success': false});

      final response = await HttpLogger.get(api('/v1/teams/x'));
      await Future<void>.delayed(Duration.zero);

      expect(response.statusCode, 401);
      expect(AuthService.instance.isAuthenticated(), isFalse);
      expect(store.values.keys.where((k) => k.startsWith('bc_')), isEmpty);
      expect(events, contains(AuthEvent.loggedOut));
      await sub.cancel();
    });

    test('un 401 en /v1/auth/* o en el login no intenta refresh', () async {
      seedSession(store, jwt(), 'r1');
      await startAuth();
      handler = (_) async =>
          jsonResponse(401, {'success': false, 'message': 'Credenciales inválidas'});

      final result =
          await AuthService.instance.login('a@b.com', 'mala-clave');
      await HttpLogger.post(api('/v1/auth/change-password'), body: '{}');
      await HttpLogger.post(api('/User/login'), body: '{}');

      expect(result['success'], isFalse);
      expect(result['statusCode'], 401);
      expect(result['message'], 'Credenciales inválidas');
      expect(refreshCalls(), 0);
    });

    test('403 y 429 no cierran la sesion', () async {
      seedSession(store, jwt(), 'r1');
      await startAuth();
      handler = (request) async => jsonResponse(
          request.url.path.endsWith('a') ? 403 : 429, {'success': false});

      expect((await HttpLogger.get(api('/v1/a'))).statusCode, 403);
      expect((await HttpLogger.get(api('/v1/b'))).statusCode, 429);
      expect(AuthService.instance.isAuthenticated(), isTrue);
      expect(refreshCalls(), 0);
    });
  });

  // ── Varias pestanas ─────────────────────────────────────────────────────
  group('Varias pestanas', () {
    test('otra pestana renueva: esta adopta los tokens sin cerrar sesion',
        () async {
      seedSession(store, jwt(), 'r1');
      await startAuth();
      final fromOtherTab = jwt();
      final t = tokensJson(fromOtherTab, 'r2');
      store.simulateExternalChange(
          TokenKeys.accessTokenExpiresAt, t['accessTokenExpiresAt'] as String);
      store.simulateExternalChange(TokenKeys.refreshToken, 'r2');
      store.simulateExternalChange(TokenKeys.accessToken, fromOtherTab);
      await Future<void>.delayed(Duration.zero);

      expect(AuthService.instance.accessToken, fromOtherTab);
      expect(AuthService.instance.isAuthenticated(), isTrue);
    });

    test('401 con un token que otra pestana ya renovo: no llama a /refresh',
        () async {
      final oldAccess = jwt();
      seedSession(store, oldAccess, 'r1');
      await startAuth();
      final fromOtherTab = jwt();
      // La otra pestana guardo tokens nuevos; esta aun no proceso el evento.
      store.values[TokenKeys.accessToken] = fromOtherTab;
      store.values[TokenKeys.refreshToken] = 'r2';

      handler = (request) async =>
          request.headers['Authorization'] == 'Bearer $fromOtherTab'
              ? jsonResponse(200, {'success': true})
              : jsonResponse(401, {'success': false});

      final response = await HttpLogger.get(api('/v1/teams/x'));
      expect(response.statusCode, 200);
      expect(refreshCalls(), 0);
    });

    test('logout en otra pestana cierra la sesion en esta', () async {
      seedSession(store, jwt(), 'r1');
      await startAuth();
      final events = <AuthEvent>[];
      final sub = AuthService.events.listen(events.add);

      store.simulateExternalChange(TokenKeys.accessToken, null);
      store.simulateExternalChange(TokenKeys.refreshToken, null);
      await Future<void>.delayed(Duration.zero);

      expect(AuthService.instance.isAuthenticated(), isFalse);
      expect(events, contains(AuthEvent.loggedOut));
      await sub.cancel();
    });
  });

  // ── Login / logout ──────────────────────────────────────────────────────
  group('Login y logout', () {
    test('login guarda los tokens y devuelve el usuario sin ellos', () async {
      await startAuth();
      final access = jwt();
      handler = (_) async => jsonResponse(200, {
            'success': true,
            'message': 'Inicio de sesión exitoso',
            'data': {
              'userId': 'u1',
              'email': 'a@b.com',
              'tokens': tokensJson(access, 'r1'),
            },
          });

      final result = await AuthService.instance.login('a@b.com', 'x');

      expect(result['success'], isTrue);
      expect((result['data'] as Map).containsKey('tokens'), isFalse);
      expect(store.values[TokenKeys.accessToken], access);
      expect(store.values[TokenKeys.refreshToken], 'r1');
      expect(requests.single.url.path, endsWith('/v1/auth/login'));
      expect(AuthService.instance.isAuthenticated(), isTrue);
    });

    test('logout llama al backend (ignora errores) y borra todo', () async {
      seedSession(store, jwt(), 'r1');
      await startAuth();
      handler = (_) async => jsonResponse(500, {'success': false});

      await AuthService.instance.logout(navigate: false);

      final call = requests.single;
      expect(call.url.path, endsWith('/v1/auth/logout'));
      expect(jsonDecode(call.body)['refreshToken'], 'r1');
      expect(call.headers.containsKey('Authorization'), isFalse);
      expect(store.values, isEmpty);
      expect(AuthService.instance.isAuthenticated(), isFalse);
    });
  });

  // ── Roles y guards ──────────────────────────────────────────────────────
  group('Roles y guards', () {
    test('role como string o como array', () {
      expect(JwtPayload.decode(jwt(role: 'Admin'))!.roles, ['Admin']);
      expect(JwtPayload.decode(jwt(role: ['Coach', 'Athlete']))!.roles,
          ['Coach', 'Athlete']);
    });

    test('AuthGuard redirige al login con returnUrl', () async {
      await startAuth();
      final settings = AuthGuard().redirect('/statistics');
      expect(settings?.name, '/?returnUrl=%2Fstatistics');
    });

    test('RoleGuard: sin el rol redirige; con el rol deja pasar', () async {
      seedSession(store, jwt(role: 'Coach'), 'r1');
      await startAuth();
      expect(AuthGuard().redirect('/x'), isNull);
      expect(RoleGuard(const [AppRoles.admin]).redirect('/admin')?.name,
          '/dashboard');
      expect(RoleGuard(const [AppRoles.coach]).redirect('/x'), isNull);
    });
  });

  test('AuthTokens.tryParse lee data.tokens', () {
    final parsed = AuthTokens.tryParse({'tokens': tokensJson(jwt(), 'r')});
    expect(parsed?.refreshToken, 'r');
    expect(parsed?.isAccessTokenExpired, isFalse);
  });
}
