import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/session_provider.dart';
import '../routes/app_routes.dart';

/// Utilidades de navegación centralizada.
abstract final class NavigationHelper {
  /// Devuelve la ruta del dashboard según el rol del usuario.
  /// - Coach (rolId == 1) → `/dashboard`
  /// - Atleta (rolId == 3) → `/athlete-dashboard`
  /// - Otro → `/dashboard` (fallback)
  static String dashboardRoute(BuildContext context) {
    final session = context.read<SessionProvider>().session;
    if (session != null && session.isAthlete) {
      return AppRoutes.athleteDashboard;
    }
    return AppRoutes.dashboard;
  }

  /// Navega al dashboard correspondiente al rol usando pushReplacementNamed.
  static void goToDashboard(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(dashboardRoute(context));
  }
}
