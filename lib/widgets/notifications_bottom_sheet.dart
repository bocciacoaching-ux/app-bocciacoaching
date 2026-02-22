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
    icon: Icons.check_circle,
    iconColor: AppColors.success,
    isRead: false,
  ),
  const AppNotification(
    title: 'Nueva prueba disponible',
    subtitle: 'Hace 5 horas',
    icon: Icons.description,
    iconColor: AppColors.info,
    isRead: false,
  ),
  const AppNotification(
    title: 'Carlos Jiménez no realizó su sesión',
    subtitle: 'Hace 1 día',
    icon: Icons.warning,
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

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pastilla de arrastre
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral7,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Encabezado
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Notificaciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Cantidad de no leídas
                if (notifications.any((n) => !n.isRead))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${notifications.where((n) => !n.isRead).length} nuevas',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Lista de notificaciones
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _NotificationTile(notification: notif);
              },
            ),
          ),

          const Divider(height: 1),

          // Botón "Ver todas"
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // cierra el bottom sheet
                    Navigator.of(context).pushNamed('/notifications');
                  },
                  child: const Text(
                    'Ver todas las notificaciones',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
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
    return InkWell(
      onTap: () {
        // Acción al tocar una notificación individual (puede expandirse)
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/notifications');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notification.iconColor.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(notification.icon, color: notification.iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 12),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.subtitle,
                    style: TextStyle(color: AppColors.neutral5, fontSize: 11),
                  ),
                ],
              ),
            ),

            // Indicador de no leída
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
