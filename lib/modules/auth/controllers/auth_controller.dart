import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';

/// Controlador del módulo de autenticación.
class AuthController extends GetxController {
  // ── Estado observable ────────────────────────────────────────────
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final errorMessage = ''.obs;

  // ── Campos de texto ──────────────────────────────────────────────
  final email = ''.obs;
  final password = ''.obs;
  final name = ''.obs;

  // ── Métodos ──────────────────────────────────────────────────────

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void clearError() {
    errorMessage.value = '';
  }

  /// Inicia sesión.
  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      errorMessage.value = 'Por favor, completa todos los campos.';
      return;
    }

    isLoading.value = true;
    clearError();

    try {
      // TODO: Integrar con AuthRepository
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = 'Error al iniciar sesión. Inténtalo de nuevo.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Registra un nuevo usuario.
  Future<void> register() async {
    isLoading.value = true;
    clearError();

    try {
      // TODO: Integrar con AuthRepository
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      errorMessage.value = 'Error al registrarse. Inténtalo de nuevo.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Cierra sesión.
  Future<void> logout() async {
    // TODO: Integrar con AuthRepository
    Get.offAllNamed(AppRoutes.login);
  }

  /// Navega al splash y luego redirige.
  Future<void> checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));
    // TODO: Verificar si hay sesión activa
    Get.offAllNamed(AppRoutes.login);
  }
}
