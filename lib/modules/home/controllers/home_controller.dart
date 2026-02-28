import 'package:get/get.dart';

/// Controlador principal del módulo Home.
class HomeController extends GetxController {
  // ── Estado observable ────────────────────────────────────────────
  final currentIndex = 0.obs;
  final isLoading = false.obs;

  // ── Navegación del bottom nav ────────────────────────────────────
  void changeTab(int index) {
    currentIndex.value = index;
  }

  // TODO: Implementar onInit para cargar datos iniciales del dashboard.
}
