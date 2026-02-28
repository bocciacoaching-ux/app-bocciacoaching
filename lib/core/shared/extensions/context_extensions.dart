import 'package:flutter/material.dart';

/// Extensiones para BuildContext.
extension ContextExtensions on BuildContext {
  /// Acceso rápido al tema.
  ThemeData get theme => Theme.of(this);

  /// Acceso rápido al TextTheme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Acceso rápido al ColorScheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Ancho de pantalla.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Alto de pantalla.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// ¿Es pantalla pequeña?
  bool get isSmallScreen => screenWidth < 600;

  /// ¿Es tablet?
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;

  /// ¿Es desktop?
  bool get isDesktop => screenWidth >= 1200;
}
