import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Avisos globales (snackbars) que se pueden mostrar sin `BuildContext`,
/// por ejemplo desde la capa HTTP. Su [key] se asigna a
/// `GetMaterialApp.scaffoldMessengerKey`.
abstract final class AppMessenger {
  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  static const String forbiddenMessage = 'No tienes permisos';
  static const String tooManyRequestsMessage =
      'Espera un minuto e inténtalo de nuevo';

  static String? _lastMessage;
  static DateTime? _lastShownAt;

  /// Evita repetir el mismo aviso si llegan varias respuestas seguidas
  /// (p. ej. una pantalla que dispara 5 peticiones y todas dan 403).
  static const Duration _dedupeWindow = Duration(seconds: 3);

  static void showForbidden([String? message]) =>
      show(message ?? forbiddenMessage, isError: true);

  static void showTooManyRequests() =>
      show(tooManyRequestsMessage, isError: false);

  static void show(String message, {bool isError = false}) {
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) < _dedupeWindow) {
      return;
    }
    final messenger = key.currentState;
    if (messenger == null) return;
    _lastMessage = message;
    _lastShownAt = now;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }
}
