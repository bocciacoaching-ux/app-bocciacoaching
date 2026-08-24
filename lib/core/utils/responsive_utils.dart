import 'package:flutter/material.dart';

/// Utilidades para el manejo de diseño responsivo (Móvil, Tablet, Desktop).
abstract final class ResponsiveUtils {
  /// Umbral para considerar que un dispositivo es Tablet o superior.
  static const double tabletBreakpoint = 600.0;

  /// Umbral para considerar que un dispositivo es Desktop.
  static const double desktopBreakpoint = 1024.0;

  /// Determina si el ancho de pantalla actual corresponde a un móvil.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletBreakpoint;

  /// Determina si el ancho de pantalla actual corresponde a una tablet.
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  /// Determina si el ancho de pantalla actual corresponde a un desktop.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  /// Determina si el ancho de pantalla es mayor o igual a tablet.
  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Retorna un valor basado en el tipo de dispositivo.
  static T valueByDevice<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return desktop ?? tablet ?? mobile;
    if (width >= tabletBreakpoint) return tablet ?? mobile;
    return mobile;
  }

  /// Limita el ancho máximo del contenido para evitar que se estire demasiado en pantallas anchas.
  static Widget constrainedContainer({
    required Widget child,
    double maxWidth = 1200,
    EdgeInsetsGeometry? padding,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
