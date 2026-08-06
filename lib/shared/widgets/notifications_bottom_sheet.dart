import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/notification_message.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/providers/session_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers de icono / color según tipo de notificación
// ─────────────────────────────────────────────────────────────────────────────
IconData _iconForType(String typeId, String? typeName) {
  final name = (typeName ?? '').toLowerCase();
  if (name.contains('invit')) return Icons.group_add_outlined;
  if (name.contains('entrena') || name.contains('sesión')) {
    return Icons.fitness_center_rounded;
  }
  if (name.contains('evalua') || name.contains('prueba')) {
    return Icons.assignment_outlined;
  }
  if (name.contains('alerta') || name.contains('warning')) {
    return Icons.warning_amber_rounded;
  }
  if (name.contains('estadística') || name.contains('rendimiento')) {
    return Icons.show_chart_rounded;
  }
  switch (typeId) {
    case 1:
      return Icons.group_add_outlined;
    case 2:
      return Icons.fitness_center_rounded;
    case 3:
      return Icons.assignment_outlined;
    case 4:
      return Icons.warning_amber_rounded;
    default:
      return Icons.notifications_none_rounded;
  }
}

Color _colorForType(String typeId, String? typeName) {
  final name = (typeName ?? '').toLowerCase();
  if (name.contains('invit')) return AppColors.info;
  if (name.contains('entrena') || name.contains('sesión')) {
    return AppColors.primary;
  }
  if (name.contains('evalua') || name.contains('prueba')) {
    return AppColors.accent4;
  }
  if (name.contains('alerta') || name.contains('warning')) {
    return AppColors.warning;
  }
  if (name.contains('estadística') || name.contains('rendimiento')) {
    return AppColors.success;
  }
  switch (typeId) {
    case 1:
      return AppColors.info;
    case 2:
      return AppColors.primary;
    case 3:
      return AppColors.accent4;
    case 4:
      return AppColors.warning;
    default:
      return AppColors.neutral4;
  }
}

/// Modelo UI de notificación — mantiene compatibilidad con [NotificationsScreen].
class AppNotification {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isRead;

  const AppNotification({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });

  /// Construye un [AppNotification] desde el modelo de API.
  factory AppNotification.fromMessage(NotificationMessage m) {
    return AppNotification(
      title: m.message ?? '(Sin contenido)',
      subtitle: m.timeAgo,
      icon: _iconForType(m.notificationTypeId, m.typeName),
      iconColor: _colorForType(m.notificationTypeId, m.typeName),
      isRead: m.isRead,
    );
  }
}

/// Muestra el bottom sheet de notificaciones (carga datos reales de la API).
void showNotificationsBottomSheet(BuildContext context) {
  final session = context.read<SessionProvider>().session;
  if (session != null) {
    context.read<NotificationProvider>().fetchForUser(
          userId: session.userId,
          isCoach: session.isCoach,
        );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _NotificationsBottomSheet(),
  );
}

class _NotificationsBottomSheet extends StatelessWidget {
  const _NotificationsBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final notifications = provider.notifications;
        final unreadCount = provider.unreadCount;

        return Container(
          decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Pastilla de arrastre ────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 2),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral6,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Encabezado ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
            child: Row(
              children: [
                // Ícono de campana
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Badge de no leídas
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount nuevas',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                // Botón cerrar
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.neutral8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.neutral8),

          // ── Lista de notificaciones ─────────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: _buildContent(context, provider, notifications),
          ),

          Divider(height: 1, color: AppColors.neutral8),

          // ── Botón "Ver todas" ───────────────────────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/notifications');
                  },
                  icon: const Icon(Icons.notifications_none_rounded, size: 18),
                  label: const Text('Ver todas las notificaciones'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    NotificationProvider provider,
    List<NotificationMessage> notifications,
  ) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (provider.hasError) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.neutral6),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Error al cargar notificaciones',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    if (notifications.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_off_outlined, size: 40, color: AppColors.neutral6),
              SizedBox(height: 8),
              Text('Sin notificaciones',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1, indent: 72, endIndent: 20, color: AppColors.neutral8,
      ),
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return _NotificationTile(
          notification: notif,
          onTap: () {
            provider.markAsRead(notif);
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/notifications');
          },
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationMessage notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(notification.notificationTypeId, notification.typeName);
    final color = _colorForType(notification.notificationTypeId, notification.typeName);
    return Material(
      color: notification.isRead ? AppColors.surface : AppColors.primary10,
      child: InkWell(
        onTap: onTap,
        highlightColor: AppColors.primary10,
        splashColor: AppColors.primary20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ícono ─────────────────────────────────────────────
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withAlpha((0.13 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(icon, color: color, size: 20)),
              ),
              const SizedBox(width: 12),

              // ── Texto ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message ?? '(Sin contenido)',
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.timeAgo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Indicador de no leída ────────────────────────────
              if (!notification.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
