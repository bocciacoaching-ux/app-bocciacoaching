import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Diálogo de error reutilizable.
class ErrorDialog {
  static Future<void> show({
    required String message,
    String title = 'Error',
    String buttonText = 'Aceptar',
  }) {
    return Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
