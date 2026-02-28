/// Extensiones numéricas a nivel de app.
extension NumExtensions on num {
  /// Convierte a formato de porcentaje (ej: "85.5%").
  String toPercentage({int decimals = 1}) =>
      '${toStringAsFixed(decimals)}%';

  /// Convierte a formato con separador de miles.
  String toFormattedString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
