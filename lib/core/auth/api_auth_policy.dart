import '../constants/app_config.dart';

/// Reglas para decidir que peticiones llevan `Authorization` y cuales
/// pueden disparar un refresh ante un 401.
abstract final class ApiAuthPolicy {
  static final Uri _base = Uri.parse(AppConfig.baseUrl);
  static final String _basePath = _stripSlash(_base.path.toLowerCase());

  /// Endpoints publicos (seccion 3 del contrato), relativos a la URL base
  /// y en minusculas. Nunca llevan token y un 401 en ellos no refresca.
  static const Set<String> _publicPaths = {
    '/v1/auth/login',
    '/v1/auth/google',
    '/v1/auth/refresh',
    '/v1/auth/logout',
    '/v1/auth/password-reset/request',
    '/v1/auth/password-reset/verify',
    '/v1/auth/password-reset/confirm',
    '/user/login',
    '/user/login/google',
    '/user/verify-email/google',
    '/user/register/google',
    '/user/addinfouser',
    '/user/validateemail',
    '/user/resetpassword',
    '/email/sendcodeverify',
    '/email/validatecode',
    '/rol/getall',
    '/subscription/types',
  };

  /// Endpoints publicos con un segmento variable al final (`{id}`).
  static const List<String> _publicPrefixes = [
    '/rol/getbyid/',
    '/subscription/types/',
  ];

  static String _stripSlash(String path) =>
      path.length > 1 && path.endsWith('/')
          ? path.substring(0, path.length - 1)
          : path;

  /// `true` si [url] apunta a NUESTRA API (mismo esquema, host, puerto y
  /// prefijo de ruta). Firebase, Google, Stripe, etc. quedan fuera.
  static bool isOurApi(Uri url) {
    if (url.scheme != _base.scheme || url.host != _base.host) return false;
    if (url.port != _base.port) return false;
    final path = url.path.toLowerCase();
    return path == _basePath || path.startsWith('$_basePath/');
  }

  /// Ruta relativa a la base, en minusculas (p. ej. `/v1/auth/login`).
  static String relativePath(Uri url) =>
      _stripSlash(url.path.toLowerCase().substring(_basePath.length));

  static bool isPublic(Uri url) {
    if (!isOurApi(url)) return false;
    final path = relativePath(url);
    return _publicPaths.contains(path) ||
        _publicPrefixes.any((p) => path.startsWith(p) && path.length > p.length);
  }

  /// La peticion debe llevar `Authorization: Bearer <accessToken>`.
  static bool shouldAttachToken(Uri url) => isOurApi(url) && !isPublic(url);

  /// Un 401 en esta peticion puede resolverse renovando la sesion.
  /// No aplica a endpoints publicos ni a `/v1/auth/*` ni a `/User/login*`
  /// (ahi un 401 significa credenciales o token de reset invalidos).
  static bool canRefreshOn401(Uri url) {
    if (!shouldAttachToken(url)) return false;
    final path = relativePath(url);
    return !path.startsWith('/v1/auth/') && !path.startsWith('/user/login');
  }
}
