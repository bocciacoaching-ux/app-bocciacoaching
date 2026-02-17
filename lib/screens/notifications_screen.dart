import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notificaciones', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _notificationItem(
            title: 'María González completó entrenamiento',
            subtitle: 'Hace 2 horas',
            icon: Icons.check_circle,
            iconColor: Colors.green,
          ),
          const SizedBox(height: 12),
          _notificationItem(
            title: 'Nueva prueba disponible',
            subtitle: 'Hace 5 horas',
            icon: Icons.description,
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 12),
          _notificationItem(
            title: 'Carlos Jiménez no realizó su sesión',
            subtitle: 'Hace 1 día',
            icon: Icons.warning,
            iconColor: Colors.orange,
          ),
          const SizedBox(height: 12),
          _notificationItem(
            title: 'Análisis de rendimiento actualizado',
            subtitle: 'Hace 2 días',
            icon: Icons.show_chart,
            iconColor: Colors.purple,
          ),
          const SizedBox(height: 12),
          _notificationItem(
            title: 'Nuevo equipo agregado',
            subtitle: 'Hace 3 días',
            icon: Icons.group,
            iconColor: Colors.teal,
          ),
        ],
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
        color: Colors.white,
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
