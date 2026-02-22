import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/notifications_bottom_sheet.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Copia mutable de las notificaciones para marcar como leída
  late final List<AppNotification> _today;
  late final List<AppNotification> _earlier;

  @override
  void initState() {
    super.initState();
    _today = [
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
    ];
    _earlier = [
      const AppNotification(
        title: 'Carlos Jiménez no realizó su sesión',
        subtitle: 'Hace 1 día',
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.warning,
        isRead: true,
      ),
      const AppNotification(
        title: 'Análisis de rendimiento actualizado',
        subtitle: 'Hace 2 días',
        icon: Icons.show_chart_rounded,
        iconColor: AppColors.accent4,
        isRead: true,
      ),
      const AppNotification(
        title: 'Nuevo equipo agregado',
        subtitle: 'Hace 3 días',
        icon: Icons.group_outlined,
        iconColor: AppColors.secondary,
        isRead: true,
      ),
    ];
  }

  int get _unreadCount => _today.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.neutral8,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.textSecondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Text(
              'Notificaciones',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: () {
                // Marcar todas como leídas (en un caso real actualizaría el provider)
              },
              child: const Text(
                'Marcar leídas',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // ── Sección: Hoy ──────────────────────────────────────────
            _SectionHeader(label: 'Hoy'),
            const SizedBox(height: 8),
            ..._today.map((n) => _NotificationCard(notification: n)),

            // ── Sección: Anteriores ───────────────────────────────────
            const SizedBox(height: 20),
            _SectionHeader(label: 'Anteriores'),
            const SizedBox(height: 8),
            ..._earlier.map((n) => _NotificationCard(notification: n)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Encabezado de sección
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de notificación
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: notification.isRead ? AppColors.surface : AppColors.primary10,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primary20,
          highlightColor: AppColors.primary10,
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: notification.isRead
                    ? AppColors.neutral8
                    : AppColors.primary30,
                width: 1,
              ),
              boxShadow: notification.isRead
                  ? [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Ícono ──────────────────────────────────────────────
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: notification.iconColor.withAlpha((0.13 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      notification.icon,
                      color: notification.iconColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Contenido ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.subtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Punto de no leída ──────────────────────────────────
                if (!notification.isRead) ...[
                  const SizedBox(width: 8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
