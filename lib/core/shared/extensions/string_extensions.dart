/// Extensiones para String.
extension StringExtensions on String {
  /// Capitaliza la primera letra.
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Convierte a title case.
  String get titleCase =>
      split(' ').map((word) => word.capitalize).join(' ');

  /// Verifica si es un email válido.
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Trunca el string a un máximo de caracteres.
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}
