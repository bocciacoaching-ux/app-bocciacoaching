import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Binding del módulo de autenticación.
/// Inyecta las dependencias necesarias al navegar a rutas de auth.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
