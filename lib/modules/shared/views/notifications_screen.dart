import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/notification_message.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>().session;
      if (session != null) {
        context.read<NotificationProvider>().fetchForUser(
              userId: session.userId,
              isCoach: session.isCoach,
            );
      }
    });
  }

  int get _unreadCount =>
      context.watch<NotificationProvider>().unreadCount;

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
              onPressed: () =>
                  context.read<NotificationProvider>().markAllAsRead(),
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
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (provider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 48, color: AppColors.neutral6),
                    const SizedBox(height: 12),
                    Text(
                      provider.errorMessage ??
                          'Error al cargar notificaciones.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        final session =
                            context.read<SessionProvider>().session;
                        if (session != null) {
                          provider.fetchForUser(
                            userId: session.userId,
                            isCoach: session.isCoach,
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (provider.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 56, color: AppColors.neutral7),
                  SizedBox(height: 12),
                  Text(
                    'Sin notificaciones',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral5,
                        fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final today = provider.todayNotifications;
          final earlier = provider.earlierNotifications;

          return SafeArea(
            top: false,
            bottom: false,
            child: ResponsiveUtils.constrainedContainer(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                    0, 16, 0, 16 + MediaQuery.of(context).padding.bottom),
                children: [
                if (today.isNotEmpty) ...[
                  _SectionHeader(label: 'Hoy'),
                  const SizedBox(height: 8),
                  ...today.map((n) => _NotificationCard(
                        notification: n,
                        onTap: () => provider.markAsRead(n),
                      )),
                ],
                if (earlier.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionHeader(label: 'Anteriores'),
                  const SizedBox(height: 8),
                  ...earlier.map((n) => _NotificationCard(
                        notification: n,
                        onTap: () => provider.markAsRead(n),
                      )),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
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
class _NotificationCard extends StatefulWidget {
  final NotificationMessage notification;
  final VoidCallback? onTap;
  const _NotificationCard({required this.notification, this.onTap});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  /// `null` = pendiente, `true` = aceptada, `false` = rechazada
  bool? _invitationResult;
  bool _actionLoading = false;

  bool get _isInvitation => widget.notification.notificationTypeId == 2;

  Future<void> _accept() async {
    setState(() => _actionLoading = true);
    final session = context.read<SessionProvider>().session;
    final teamProvider = context.read<TeamProvider>();
    final ok = await context
        .read<NotificationProvider>()
        .acceptInvitation(
          widget.notification,
          teamProvider: teamProvider,
          userId: session?.userId ?? '',
        );
    if (mounted) {
      setState(() {
        _actionLoading = false;
        _invitationResult = ok ? true : null;
      });
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Invitación aceptada! Ya eres parte del equipo.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo aceptar la invitación. Intenta de nuevo.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _decline() async {
    setState(() => _actionLoading = true);
    final ok = await context
        .read<NotificationProvider>()
        .declineInvitation(widget.notification);
    if (mounted) {
      setState(() {
        _actionLoading = false;
        _invitationResult = ok ? false : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(widget.notification.notificationTypeId, widget.notification.typeName);
    final color = _colorForType(widget.notification.notificationTypeId, widget.notification.typeName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: widget.notification.isRead ? AppColors.surface : AppColors.primary10,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primary20,
          highlightColor: AppColors.primary10,
          onTap: _isInvitation ? null : widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.notification.isRead
                    ? AppColors.neutral8
                    : AppColors.primary30,
                width: 1,
              ),
              boxShadow: widget.notification.isRead
                  ? [
                      const BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Ícono ────────────────────────────────────────────
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withAlpha((0.13 * 255).round()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Icon(icon, color: color, size: 22)),
                    ),
                    const SizedBox(width: 12),

                    // ── Contenido ─────────────────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.notification.message ?? '(Sin contenido)',
                            style: TextStyle(
                              fontWeight: widget.notification.isRead
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
                              const Icon(Icons.access_time_rounded,
                                  size: 11, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                widget.notification.timeAgo,
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
                    if (!widget.notification.isRead && !_isInvitation) ...[
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

                // ── Botones de invitación (solo tipo 2) ──────────────────
                if (_isInvitation) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.neutral8),
                  const SizedBox(height: 12),
                  _buildInvitationActions(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvitationActions() {
    // Ya se tomó una acción
    if (_invitationResult != null) {
      final accepted = _invitationResult!;
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accepted ? AppColors.success.withAlpha(30) : AppColors.neutral8,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accepted ? AppColors.success : AppColors.neutral6,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  accepted ? Icons.check_circle_outline : Icons.cancel_outlined,
                  size: 14,
                  color: accepted ? AppColors.success : AppColors.neutral4,
                ),
                const SizedBox(width: 6),
                Text(
                  accepted ? 'Invitación aceptada' : 'Invitación rechazada',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accepted ? AppColors.success : AppColors.neutral4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Cargando
    if (_actionLoading) {
      return const Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        ),
      );
    }

    // Botones Aceptar / Rechazar
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _decline,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Rechazar',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _accept,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Aceptar',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

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
}
