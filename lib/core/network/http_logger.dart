import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
class HttpLogger {
  HttpLogger._();

  /// Activa o desactiva globalmente la impresión por consola.
  /// Las peticiones se siguen ejecutando con normalidad.
  static bool enabled = true;

  /// Máximo de caracteres a imprimir del body de la petición/respuesta.
  /// Evita saturar la consola con payloads grandes (imágenes base64, etc.).
  static int maxBodyLength = 4000;

  // ── GET ──────────────────────────────────────────────────────────
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    _logRequest('GET', url, headers, null);
    final sw = Stopwatch()..start();
    try {
      final response = await http.get(url, headers: headers);
      sw.stop();
      _logResponse('GET', url, response, sw.elapsedMilliseconds);
      return response;
    } catch (e) {
      sw.stop();
      _logError('GET', url, e, sw.elapsedMilliseconds);
      rethrow;
    }
  }

  // ── POST ─────────────────────────────────────────────────────────
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    _logRequest('POST', url, headers, body);
    final sw = Stopwatch()..start();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      sw.stop();
      _logResponse('POST', url, response, sw.elapsedMilliseconds);
      return response;
    } catch (e) {
      sw.stop();
      _logError('POST', url, e, sw.elapsedMilliseconds);
      rethrow;
    }
  }

  // ── PUT ──────────────────────────────────────────────────────────
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    _logRequest('PUT', url, headers, body);
    final sw = Stopwatch()..start();
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      sw.stop();
      _logResponse('PUT', url, response, sw.elapsedMilliseconds);
      return response;
    } catch (e) {
      sw.stop();
      _logError('PUT', url, e, sw.elapsedMilliseconds);
      rethrow;
    }
  }

  // ── PATCH ────────────────────────────────────────────────────────
  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    _logRequest('PATCH', url, headers, body);
    final sw = Stopwatch()..start();
    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      sw.stop();
      _logResponse('PATCH', url, response, sw.elapsedMilliseconds);
      return response;
    } catch (e) {
      sw.stop();
      _logError('PATCH', url, e, sw.elapsedMilliseconds);
      rethrow;
    }
  }

  // ── DELETE ───────────────────────────────────────────────────────
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    _logRequest('DELETE', url, headers, body);
    final sw = Stopwatch()..start();
    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      sw.stop();
      _logResponse('DELETE', url, response, sw.elapsedMilliseconds);
      return response;
    } catch (e) {
      sw.stop();
      _logError('DELETE', url, e, sw.elapsedMilliseconds);
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
