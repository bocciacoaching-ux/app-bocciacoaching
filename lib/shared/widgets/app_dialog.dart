import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Tipos de diálogo disponibles.
enum AppDialogType {
  /// Confirmación de acción (ej. "¿Deseas eliminar este registro?").
  confirm,

  /// Alerta informativa (solo botón "Aceptar").
  alert,

  /// Advertencia que requiere atención antes de continuar.
  warning,

  /// Notificación de error.
  error,

  /// Acción exitosa completada.
  success,

  /// Acción destructiva (eliminar, resetear, etc.). Estilo rojo.
  destructive,
}

/// Diálogo reutilizable que se adapta según su [AppDialogType].
///
/// Uso rápido con los métodos estáticos:
/// ```dart
/// // Confirmación
/// final ok = await AppDialog.confirm(
///   context,
///   title: '¿Eliminar atleta?',
///   message: 'Esta acción no se puede deshacer.',
/// );
///
/// // Alerta simple
/// AppDialog.alert(
///   context,
///   title: 'Sesión expirada',
///   message: 'Tu sesión ha expirado, inicia sesión de nuevo.',
/// );
///
/// // Acción destructiva
/// final deleted = await AppDialog.destructive(
///   context,
///   title: 'Eliminar evaluación',
///   message: '¿Estás seguro de que deseas eliminar esta evaluación? Esta acción es irreversible.',
///   confirmLabel: 'Eliminar',
/// );
/// ```
class AppDialog extends StatelessWidget {
  /// Tipo de diálogo.
  final AppDialogType type;

  /// Título del diálogo.
  final String title;

  /// Mensaje / cuerpo del diálogo.
  final String message;

  /// Texto del botón de confirmación. Si es `null`, usa un valor por defecto.
  final String? confirmLabel;

  /// Texto del botón de cancelar. Si es `null`, usa "Cancelar".
  final String? cancelLabel;

  /// Si es `true`, solo muestra un botón (Aceptar). Útil para alertas.
  final bool singleAction;

  /// Ícono personalizado (si es `null` se usa el del tipo).
  final IconData? icon;

  const AppDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.singleAction = false,
    this.icon,
  });

  // ── Métodos estáticos de conveniencia ────────────────────────────

  /// Muestra un diálogo de **confirmación** y devuelve `true` si el usuario
  /// acepta.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    IconData? icon,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => AppDialog(
        type: AppDialogType.confirm,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
      ),
      transitionBuilder: _transitionBuilder,
    );
    return result ?? false;
  }

  /// Muestra una **alerta** informativa con un solo botón.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    IconData? icon,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => AppDialog(
        type: AppDialogType.alert,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        singleAction: true,
        icon: icon,
      ),
      transitionBuilder: _transitionBuilder,
    );
  }

  /// Muestra un diálogo de **advertencia** y devuelve `true` si el usuario
  /// acepta.
  static Future<bool> warning(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    IconData? icon,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => AppDialog(
        type: AppDialogType.warning,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
      ),
      transitionBuilder: _transitionBuilder,
    );
    return result ?? false;
  }

  /// Muestra un diálogo de **error** con un solo botón.
  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    IconData? icon,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => AppDialog(
        type: AppDialogType.error,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        singleAction: true,
        icon: icon,
      ),
      transitionBuilder: _transitionBuilder,
    );
  }

  /// Muestra un diálogo de **éxito** con un solo botón.
  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    IconData? icon,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => AppDialog(
        type: AppDialogType.success,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        singleAction: true,
        icon: icon,
      ),
      transitionBuilder: _transitionBuilder,
    );
  }

  /// Muestra un diálogo de **acción destructiva** y devuelve `true` si el
  /// usuario confirma.
  static Future<bool> destructive(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    IconData? icon,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => AppDialog(
        type: AppDialogType.destructive,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
      ),
      transitionBuilder: _transitionBuilder,
    );
    return result ?? false;
  }

  /// Animación compartida para todos los diálogos.
  static Widget _transitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  // ── Helpers de estilo ────────────────────────────────────────────

  _DialogStyle get _style => switch (type) {
        AppDialogType.confirm => const _DialogStyle(
            accent: AppColors.primary,
            background: AppColors.infoBg,
            icon: Icons.help_outline_rounded,
            defaultConfirmLabel: 'Confirmar',
          ),
        AppDialogType.alert => const _DialogStyle(
            accent: AppColors.info,
            background: AppColors.infoBg,
            icon: Icons.info_outline_rounded,
            defaultConfirmLabel: 'Aceptar',
          ),
        AppDialogType.warning => const _DialogStyle(
            accent: AppColors.warning,
            background: AppColors.warningBg,
            icon: Icons.warning_amber_rounded,
            defaultConfirmLabel: 'Continuar',
          ),
        AppDialogType.error => const _DialogStyle(
            accent: AppColors.error,
            background: AppColors.errorBg,
            icon: Icons.error_outline_rounded,
            defaultConfirmLabel: 'Aceptar',
          ),
        AppDialogType.success => const _DialogStyle(
            accent: AppColors.success,
            background: AppColors.successBg,
            icon: Icons.check_circle_outline_rounded,
            defaultConfirmLabel: 'Aceptar',
          ),
        AppDialogType.destructive => const _DialogStyle(
            accent: AppColors.error,
            background: AppColors.errorBg,
            icon: Icons.delete_outline_rounded,
            defaultConfirmLabel: 'Eliminar',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final effectiveIcon = icon ?? style.icon;
    final effectiveConfirmLabel = confirmLabel ?? style.defaultConfirmLabel;
    final effectiveCancelLabel = cancelLabel ?? 'Cancelar';
    final isSingle = singleAction ||
        type == AppDialogType.alert ||
        type == AppDialogType.error ||
        type == AppDialogType.success;

    final mq = MediaQuery.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: mq.viewInsets.bottom > 0 ? 16 : 24,
        ),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight:
                    mq.size.height - mq.padding.top - mq.padding.bottom - 48,
              ),
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Cabecera con ícono ──────────────────────────────
                      const SizedBox(height: 28),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: style.background,
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(effectiveIcon, color: style.accent, size: 28),
                      ),
                      const SizedBox(height: 16),

                      // ── Título ─────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Mensaje ────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Separador ──────────────────────────────────────
                      const Divider(height: 1, color: AppColors.neutral8),

                      // ── Botones ────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: isSingle
                            ? _buildSingleButton(
                                context, effectiveConfirmLabel, style)
                            : _buildDoubleButtons(
                                context,
                                effectiveConfirmLabel,
                                effectiveCancelLabel,
                                style,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleButton(
    BuildContext context,
    String label,
    _DialogStyle style,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: style.accent,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildDoubleButtons(
    BuildContext context,
    String confirmLabel,
    String cancelLabel,
    _DialogStyle style,
  ) {
    return Row(
      children: [
        // Cancelar
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.neutral7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyles.buttonLarge,
              ),
              child: Text(cancelLabel),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Confirmar
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: style.accent,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyles.buttonLarge,
              ),
              child: Text(confirmLabel),
            ),
          ),
        ),
      ],
    );
  }
}

/// Clase interna con los tokens de estilo para cada tipo de diálogo.
class _DialogStyle {
  final Color accent;
  final Color background;
  final IconData icon;
  final String defaultConfirmLabel;

  const _DialogStyle({
    required this.accent,
    required this.background,
    required this.icon,
    required this.defaultConfirmLabel,
  });
}
