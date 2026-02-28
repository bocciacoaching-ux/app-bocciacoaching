import 'package:flutter/foundation.dart';

/// Utilidades generales de la aplicación.
abstract final class AppUtils {
  /// Logger para debug — solo imprime en modo desarrollo.
  static void log(String message, {String tag = 'APP'}) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  /// Valida formato de email.
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Valida que la contraseña tenga al menos 6 caracteres.
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Formatea una fecha a formato legible.
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Formatea una fecha con hora.
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
