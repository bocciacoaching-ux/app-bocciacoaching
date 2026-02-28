import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Tipos de tarjeta informativa disponibles.
enum InfoCardType {
  /// Información general – azul primario.
  info,

  /// Éxito / operación completada – verde.
  success,

  /// Advertencia / acción requerida – naranja.
  warning,

  /// Error / problema – rojo.
  error,

  /// Neutro / genérico – gris.
  neutral,
}

/// Tarjeta informativa reutilizable que muestra un mensaje con un icono
/// lateral, con variantes de color según el tipo ([InfoCardType]).
///
/// Uso básico:
/// ```dart
/// InfoCard(
///   type: InfoCardType.info,
///   message: 'No puedes crear una nueva prueba mientras tengas una pendiente.',
/// )
/// ```
///
/// También permite título, acción y cierre opcionales:
/// ```dart
/// InfoCard(
///   type: InfoCardType.warning,
///   title: 'Atención',
///   message: 'Los cambios no guardados se perderán.',
///   actionLabel: 'Guardar',
///   onAction: () => _save(),
///   onDismiss: () => _hide(),
/// )
/// ```
class InfoCard extends StatelessWidget {
  /// Tipo de tarjeta (define colores e ícono por defecto).
  final InfoCardType type;

  /// Título opcional mostrado en negrita encima del mensaje.
  final String? title;

  /// Mensaje principal de la tarjeta.
  final String message;

  /// Icono personalizado. Si es `null`, se usa el ícono por defecto del tipo.
  final IconData? icon;

  /// Etiqueta del botón de acción (opcional).
  final String? actionLabel;

  /// Callback del botón de acción.
  final VoidCallback? onAction;

  /// Callback al cerrar/descartar la tarjeta. Si es `null`, no se muestra la X.
  final VoidCallback? onDismiss;

  /// Padding interno personalizado.
  final EdgeInsetsGeometry? padding;

  /// Margen externo personalizado.
  final EdgeInsetsGeometry? margin;

  const InfoCard({
    super.key,
    required this.type,
    required this.message,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.padding,
    this.margin,
  });

  // ── Constructores nombrados por tipo ─────────────────────────────

  /// Tarjeta de información.
  const InfoCard.info({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.padding,
    this.margin,
  }) : type = InfoCardType.info;

  /// Tarjeta de éxito.
  const InfoCard.success({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.padding,
    this.margin,
  }) : type = InfoCardType.success;

  /// Tarjeta de advertencia.
  const InfoCard.warning({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.padding,
    this.margin,
  }) : type = InfoCardType.warning;

  /// Tarjeta de error.
  const InfoCard.error({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.padding,
    this.margin,
  }) : type = InfoCardType.error;

  /// Tarjeta neutra.
  const InfoCard.neutral({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.padding,
    this.margin,
  }) : type = InfoCardType.neutral;

  // ── Helpers de estilo ────────────────────────────────────────────

  _InfoCardStyle get _style => switch (type) {
        InfoCardType.info => const _InfoCardStyle(
            foreground: AppColors.info,
            background: AppColors.infoBg,
            icon: Icons.info_outline_rounded,
          ),
        InfoCardType.success => const _InfoCardStyle(
            foreground: AppColors.success,
            background: AppColors.successBg,
            icon: Icons.check_circle_outline_rounded,
          ),
        InfoCardType.warning => const _InfoCardStyle(
            foreground: AppColors.warning,
            background: AppColors.warningBg,
            icon: Icons.warning_amber_rounded,
          ),
        InfoCardType.error => const _InfoCardStyle(
            foreground: AppColors.error,
            background: AppColors.errorBg,
            icon: Icons.error_outline_rounded,
          ),
        InfoCardType.neutral => const _InfoCardStyle(
            foreground: AppColors.neutral4,
            background: AppColors.neutral9,
            icon: Icons.info_outline_rounded,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final effectiveIcon = icon ?? style.icon;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.foreground.withAlpha(40), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono
          Icon(effectiveIcon, color: style.foreground, size: 22),
          const SizedBox(width: 12),

          // Contenido (título + mensaje + acción)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: style.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: style.foreground,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: style.foreground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        actionLabel!,
                        style: AppTextStyles.buttonSmall.copyWith(
                          color: style.foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Botón de cierre
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: style.foreground.withAlpha(150),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Clase interna con los tokens de estilo para cada tipo de tarjeta.
class _InfoCardStyle {
  final Color foreground;
  final Color background;
  final IconData icon;

  const _InfoCardStyle({
    required this.foreground,
    required this.background,
    required this.icon,
  });
}
