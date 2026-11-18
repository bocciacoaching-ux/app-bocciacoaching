import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../auth/api_auth_policy.dart';
import '../services/auth_service.dart';
import 'app_messenger.dart';

/// Wrapper centralizado sobre `package:http/http.dart` que registra en la
/// consola la URL, el método, los headers, el body que se envía y la
/// respuesta de cada petición a la API.
///
/// La API es idéntica a la de `package:http` para que migrar un servicio
/// solo consista en cambiar el prefijo:
///
/// ```dart
/// // Antes
/// final response = await http.post(uri, headers: {...}, body: ...);
///
/// // Después
/// final response = await HttpLogger.post(uri, headers: {...}, body: ...);
/// ```
///
/// El logger se puede silenciar en producción asignando
/// `HttpLogger.enabled = false` desde `main.dart`.
///
/// Además actúa como interceptor de autenticación (ver [_send]): todas las
/// peticiones de la app pasan por aquí.
class HttpLogger {
  HttpLogger._();

  /// Activa o desactiva globalmente la impresión por consola.
  /// Las peticiones se siguen ejecutando con normalidad.
  static bool enabled = true;

  /// Máximo de caracteres a imprimir del body de la petición/respuesta.
  /// Evita saturar la consola con payloads grandes (imágenes base64, etc.).
  static int maxBodyLength = 4000;

  /// Cliente HTTP usado por todas las peticiones. Se puede sustituir en
  /// pruebas (p. ej. por un `MockClient` de `package:http/testing.dart`).
  static http.Client client = http.Client();

  // ── GET ──────────────────────────────────────────────────────────
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool showErrorNotices = true,
  }) =>
      _send('GET', url,
          headers: headers, showErrorNotices: showErrorNotices);

  // ── POST ─────────────────────────────────────────────────────────
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool showErrorNotices = true,
  }) =>
      _send('POST', url,
          headers: headers,
          body: body,
          encoding: encoding,
          showErrorNotices: showErrorNotices);

  // ── PUT ──────────────────────────────────────────────────────────
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool showErrorNotices = true,
  }) =>
      _send('PUT', url,
          headers: headers,
          body: body,
          encoding: encoding,
          showErrorNotices: showErrorNotices);

  // ── PATCH ────────────────────────────────────────────────────────
  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool showErrorNotices = true,
  }) =>
      _send('PATCH', url,
          headers: headers,
          body: body,
          encoding: encoding,
          showErrorNotices: showErrorNotices);

  // ── DELETE ───────────────────────────────────────────────────────
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool showErrorNotices = true,
  }) =>
      _send('DELETE', url,
          headers: headers,
          body: body,
          encoding: encoding,
          showErrorNotices: showErrorNotices);

  // ─────────────────────────────────────────────────────────────────
  // Interceptor de autenticacion
  // ─────────────────────────────────────────────────────────────────

  /// Equivalente a un interceptor HTTP:
  ///
  /// 1. Si la URL es de nuestra API y no es un endpoint publico, anade
  ///    `Authorization: Bearer <accessToken>` (renovandolo antes si ya
  ///    expiro). A otros dominios (Firebase, Google...) nunca se envia.
  /// 2. Ante un 401 en un endpoint protegido (no `/v1/auth/*` ni
  ///    `/User/login*`) pide un refresh COMPARTIDO y reintenta UNA vez
  ///    ([isRetry] evita bucles). Si el refresh falla, AuthService cierra
  ///    la sesion local y lleva a `/login?returnUrl=...`.
  /// 3. 403 -> aviso "No tienes permisos" (no cierra sesion).
  /// 4. 429 -> aviso "Espera un minuto e intentalo de nuevo".
  ///
  /// La respuesta se devuelve siempre al servicio que hizo la peticion, que
  /// sigue aplicando su propio manejo de errores.
  static Future<http.Response> _send(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool showErrorNotices = true,
    bool isRetry = false,
  }) async {
    final auth = AuthService.instance;
    final requestHeaders = <String, String>{...?headers};
    String? usedToken;

    if (ApiAuthPolicy.shouldAttachToken(url) &&
        !requestHeaders.keys.any((k) => k.toLowerCase() == 'authorization')) {
      usedToken =
          isRetry ? auth.accessToken : await auth.validAccessToken();
      if (usedToken != null) {
        requestHeaders['Authorization'] = 'Bearer $usedToken';
      }
    }

    final response =
        await _execute(method, url, requestHeaders, body, encoding);

    if (!ApiAuthPolicy.isOurApi(url)) return response;

    switch (response.statusCode) {
      case 401:
        if (!isRetry && ApiAuthPolicy.canRefreshOn401(url)) {
          try {
            await auth.refresh(failedAccessToken: usedToken);
          } catch (_) {
            return response; // Sesion cerrada / sin red: se propaga el 401.
          }
          return _send(
            method,
            url,
            headers: headers,
            body: body,
            encoding: encoding,
            showErrorNotices: showErrorNotices,
            isRetry: true,
          );
        }
      case 403:
        if (showErrorNotices) AppMessenger.showForbidden();
      case 429:
        if (showErrorNotices) AppMessenger.showTooManyRequests();
    }
    return response;
  }

  static Future<http.Response> _execute(
    String method,
    Uri url,
    Map<String, String> headers,
    Object? body,
    Encoding? encoding,
  ) async {
    _logRequest(method, url, headers, body);
    final sw = Stopwatch()..start();
    try {
      final response = switch (method) {
        'GET' => await client.get(url, headers: headers),
        'POST' => await client.post(url,
            headers: headers, body: body, encoding: encoding),
        'PUT' => await client.put(url,
            headers: headers, body: body, encoding: encoding),
        'PATCH' => await client.patch(url,
            headers: headers, body: body, encoding: encoding),
        'DELETE' => await client.delete(url,
            headers: headers, body: body, encoding: encoding),
        _ => throw ArgumentError.value(method, 'method'),
      };
      sw.stop();
      _logResponse(method, url, response, sw.elapsedMilliseconds);
      return response;
    } catch (e) {
      sw.stop();
      _logError(method, url, e, sw.elapsedMilliseconds);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Helpers internos de impresión
  // ─────────────────────────────────────────────────────────────────

  static void _logRequest(
    String method,
    Uri url,
    Map<String, String>? headers,
    Object? body,
  ) {
    if (!enabled) return;
    final buffer = StringBuffer()
      ..writeln('┌── HTTP REQUEST ──────────────────────────────────────')
      ..writeln('│ ➡️  $method $url')
      ..writeln('│ Headers: ${_prettyHeaders(headers)}');
    if (body != null) {
      buffer.writeln('│ Body: ${_prettyBody(body)}');
    } else {
      buffer.writeln('│ Body: <empty>');
    }
    buffer.write('└──────────────────────────────────────────────────────');
    _print(buffer.toString());
  }

  static void _logResponse(
    String method,
    Uri url,
    http.Response response,
    int elapsedMs,
  ) {
    if (!enabled) return;
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    final emoji = ok ? '✅' : '⚠️';
    final buffer = StringBuffer()
      ..writeln('┌── HTTP RESPONSE ─────────────────────────────────────')
      ..writeln('│ $emoji $method $url')
      ..writeln('│ Status: ${response.statusCode} • ${elapsedMs}ms')
      ..writeln('│ Body: ${_prettyBody(response.body)}')
      ..write('└──────────────────────────────────────────────────────');
    _print(buffer.toString());
  }

  static void _logError(
    String method,
    Uri url,
    Object error,
    int elapsedMs,
  ) {
    if (!enabled) return;
    final buffer = StringBuffer()
      ..writeln('┌── HTTP ERROR ────────────────────────────────────────')
      ..writeln('│ ❌ $method $url')
      ..writeln('│ Duration: ${elapsedMs}ms')
      ..writeln('│ Error: $error')
      ..write('└──────────────────────────────────────────────────────');
    _print(buffer.toString());
  }

  static String _prettyHeaders(Map<String, String>? headers) {
    if (headers == null || headers.isEmpty) return '<none>';
    // Oculta parcialmente el token de autorización por seguridad.
    final masked = <String, String>{};
    headers.forEach((k, v) {
      if (k.toLowerCase() == 'authorization') {
        masked[k] = v.length > 14 ? '${v.substring(0, 14)}…' : '<set>';
      } else {
        masked[k] = v;
      }
    });
    return masked.toString();
  }

  static String _prettyBody(Object body) {
    String text;
    if (body is String) {
      text = body;
    } else {
      try {
        text = jsonEncode(body);
      } catch (_) {
        text = body.toString();
      }
    }
    // Intentamos formatear JSON cuando sea posible.
    try {
      final decoded = jsonDecode(text);
      text = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      // No es JSON; lo dejamos tal cual.
    }
    if (text.length > maxBodyLength) {
      final omitted = text.length - maxBodyLength;
      text =
          '${text.substring(0, maxBodyLength)}… [truncado: $omitted chars omitidos]';
    }
    return text;
  }

  static void _print(String message) {
    // `debugPrint` corta a ~1024 chars por línea pero soporta múltiples
    // invocaciones, así que partimos el mensaje por saltos de línea.
    if (kDebugMode) {
      for (final line in message.split('\n')) {
        debugPrint(line);
      }
    } else {
      developer.log(message, name: 'HttpLogger');
    }
  }
}
