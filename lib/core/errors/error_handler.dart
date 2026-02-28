import 'package:get/get.dart';
import 'failures.dart';

/// Manejo centralizado de errores para mostrar mensajes al usuario.
abstract final class ErrorHandler {
  /// Muestra un Snackbar con el mensaje de error apropiado.
  static void handle(dynamic error) {
    String message;

    if (error is Failure) {
      message = error.message;
    } else if (error is Exception) {
      message = error.toString();
    } else {
      message = 'Ha ocurrido un error inesperado.';
    }

    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
