import 'dart:convert';

/// Par de tokens devuelto por el backend en `data.tokens` (login, Google,
/// refresh y cambio de contraseña).
class AuthTokens {
  final String tokenType;
  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;

  const AuthTokens({
    this.tokenType = 'Bearer',
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  /// Margen para considerar el access token vencido un poco antes de su
  /// expiracion real (latencia de red / desfase de reloj).
  static const Duration expirySkew = Duration(seconds: 15);

  bool get isAccessTokenExpired => DateTime.now()
      .toUtc()
      .isAfter(accessTokenExpiresAt.toUtc().subtract(expirySkew));

  bool get isRefreshTokenExpired =>
      DateTime.now().toUtc().isAfter(refreshTokenExpiresAt.toUtc());

  /// Construye los tokens a partir de `data.tokens` (o de un `data` que ya
  /// sea el objeto de tokens). Devuelve `null` si falta algun campo.
  static AuthTokens? tryParse(Object? json) {
    if (json is! Map) return null;
    final map = json['tokens'] is Map ? json['tokens'] as Map : json;
    final access = map['accessToken'];
    final refresh = map['refreshToken'];
    if (access is! String || refresh is! String) return null;
    if (access.isEmpty || refresh.isEmpty) return null;

    final accessExp = _parseDate(map['accessTokenExpiresAt']) ??
        JwtPayload.decode(access)?.expiresAt ??
        DateTime.now().toUtc().add(const Duration(minutes: 15));
    final refreshExp = _parseDate(map['refreshTokenExpiresAt']) ??
        DateTime.now().toUtc().add(const Duration(days: 14));

    return AuthTokens(
      tokenType: (map['tokenType'] as String?) ?? 'Bearer',
      accessToken: access,
      accessTokenExpiresAt: accessExp,
      refreshToken: refresh,
      refreshTokenExpiresAt: refreshExp,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  @override
  String toString() => 'AuthTokens(access exp: $accessTokenExpiresAt, '
      'refresh exp: $refreshTokenExpiresAt)';
}

/// Lectura del payload de un JWT (sin validar la firma: eso lo hace el
/// backend; en el cliente solo se usa para mostrar u ocultar opciones).
class JwtPayload {
  final Map<String, dynamic> claims;
  const JwtPayload(this.claims);

  /// Claim de rol que emite ASP.NET cuando no se mapea a `role`.
  static const _msRoleClaim =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

  static JwtPayload? decode(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      return json is Map<String, dynamic> ? JwtPayload(json) : null;
    } catch (_) {
      return null;
    }
  }

  String? get subject => claims['sub']?.toString();
  String? get email => claims['email']?.toString();

  DateTime? get expiresAt {
    final exp = claims['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000,
        isUtc: true);
  }

  /// `role` puede ser un string o un array; siempre se devuelve una lista.
  List<String> get roles {
    final raw = claims['role'] ?? claims[_msRoleClaim];
    if (raw is String) return raw.isEmpty ? const [] : [raw];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}
