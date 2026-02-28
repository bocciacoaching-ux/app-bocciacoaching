import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Binding del módulo Home.
/// Inyecta las dependencias necesarias al navegar a rutas de home.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
