import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Notificaciones', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
        children: [
          _notificationItem(
            title: 'María González completó entrenamiento',
            subtitle: 'Hace 2 horas',
            icon: Icons.check_circle,
            iconColor: AppColors.success,
          ),
          const SizedBox(height: 12),
          _notificationItem(
            title: 'Nueva prueba disponible',
            subtitle: 'Hace 5 horas',
            icon: Icons.description,
            iconColor: AppColors.info,
          ),
          const SizedBox(height: 12),
          _notificationItem(
            title: 'Carlos Jiménez no realizó su sesión',
            subtitle: 'Hace 1 día',
            icon: Icons.warning,
            iconColor: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _notificationItem(
            title: 'Análisis de rendimiento actualizado',
            subtitle: 'Hace 2 días',
            icon: Icons.show_chart,
            iconColor: AppColors.accent4,
          ),
          const SizedBox(height: 12),
          _notificationItem(
            title: 'Nuevo equipo agregado',
            subtitle: 'Hace 3 días',
            icon: Icons.group,
            iconColor: AppColors.secondary,
          ),
        ],
      ),
      ),
    );
  }

  Widget _notificationItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: AppColors.neutral4, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
