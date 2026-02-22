import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Modelo simple de notificación
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
}

/// Lista de notificaciones de ejemplo (se puede reemplazar por un provider)
final List<AppNotification> sampleNotifications = [
  const AppNotification(
    title: 'María González completó entrenamiento',
    subtitle: 'Hace 2 horas',
    icon: Icons.check_circle_outline_rounded,
    iconColor: AppColors.success,
    isRead: false,
  ),
  const AppNotification(
    title: 'Nueva prueba disponible',
    subtitle: 'Hace 5 horas',
    icon: Icons.description_outlined,
    iconColor: AppColors.info,
    isRead: false,
  ),
  const AppNotification(
    title: 'Carlos Jiménez no realizó su sesión',
    subtitle: 'Hace 1 día',
    icon: Icons.warning_amber_rounded,
    iconColor: AppColors.warning,
    isRead: true,
  ),
];

/// Muestra el bottom sheet de notificaciones
void showNotificationsBottomSheet(BuildContext context) {
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
    final notifications = sampleNotifications;
    final unreadCount = notifications.where((n) => !n.isRead).length;

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
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 72,
                endIndent: 20,
                color: AppColors.neutral8,
              ),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _NotificationTile(notification: notif);
              },
            ),
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
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead ? AppColors.surface : AppColors.primary10,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/notifications');
        },
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
                  color: notification.iconColor.withAlpha((0.13 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(notification.icon, color: notification.iconColor, size: 20),
                ),
              ),
              const SizedBox(width: 12),

              // ── Texto ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.subtitle,
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
