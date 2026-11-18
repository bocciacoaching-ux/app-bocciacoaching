import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../network/app_messenger.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';

/// Roles que emite el backend en el claim `role` del access token.
abstract final class AppRoles {
  static const String admin = 'Admin';
  static const String coach = 'Coach';
  static const String athlete = 'Athlete';
}

/// `authGuard`: sin sesion valida redirige a `/?returnUrl=<ruta>` (el login
/// es la ruta `/`).
class AuthGuard extends GetMiddleware {
  AuthGuard() : super(priority: 0);

  @override
  RouteSettings? redirect(String? route) {
    if (AuthService.instance.isAuthenticated()) return null;
    if (route == null || route.isEmpty) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return RouteSettings(
      name: '${AppRoutes.login}?returnUrl=${Uri.encodeComponent(route)}',
    );
  }
}

/// `roleGuard(roles)`: si el usuario no tiene NINGUNO de [roles], muestra
/// "No tienes permisos" y lo devuelve a su inicio. Va despues de
/// [AuthGuard] (que ya resolvio el caso sin sesion).
class RoleGuard extends GetMiddleware {
  final List<String> roles;

  RoleGuard(this.roles) : super(priority: 1);

  @override
  RouteSettings? redirect(String? route) {
    final auth = AuthService.instance;
    if (!auth.isAuthenticated()) return null;
    if (auth.hasAnyRole(roles)) return null;
    AppMessenger.showForbidden();
    final home = auth.hasRole(AppRoles.athlete)
        ? AppRoutes.athleteDashboard
        : AppRoutes.dashboard;
    return RouteSettings(name: home);
  }
}

/// Combinaciones listas para usar en `GetPage(middlewares: ...)`.
abstract final class RouteGuards {
  /// Pantallas que requieren sesion.
  static List<GetMiddleware> get authenticated => [AuthGuard()];

  /// Pantallas que requieren sesion y alguno de [roles].
  static List<GetMiddleware> withRoles(List<String> roles) =>
      [AuthGuard(), RoleGuard(roles)];

  /// Administracion: roles, tipos de suscripcion, tipos de notificacion y
  /// estadisticas de admin.
  static List<GetMiddleware> get admin => withRoles(const [AppRoles.admin]);
}
