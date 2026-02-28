import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_constants.dart';

/// Widget raíz de la aplicación — usa GetMaterialApp.
/// Las pantallas existentes siguen usando Navigator estándar,
/// que es compatible con GetMaterialApp.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      locale: const Locale('es', 'ES'),
    );
  }
}
