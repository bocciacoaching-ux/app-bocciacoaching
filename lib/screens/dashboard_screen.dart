import 'package:flutter/material.dart';

// Widget para el logo BOCCIA COACHING
class BocciaLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const BocciaLogo({
    super.key,
    this.size = 56,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/isologo-horizontal.png',
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String parentLabel;
  const DashboardScreen({super.key, this.parentLabel = 'Panel Coach'});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _notificationCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildTeamSelector(),
        actions: [
          _buildNotificationButton(),
          _buildProfileMenu(),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildMobileLayout(),
    );
  }

  Widget _buildTeamSelector() {
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed('/teams');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇦🇷', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Selección de Córdoba', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('Solo Córdoba', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/notifications');
          },
          icon: const Icon(Icons.notifications_none, color: Colors.black54),
        ),
        if (_notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$_notificationCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.of(context).pushNamed('/profile');
        } else if (value == 'logout') {
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          enabled: false,
          value: 'plan',
          child: Row(
            children: [
              Icon(Icons.card_membership, size: 20),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan Premium Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Válido hasta 31 dic 2026', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: 12),
              Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
            ],
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFF7DA5D1),
        child: const Text('OB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              color: Colors.white,
              child: Center(
                child: const BocciaLogo(size: 120),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _drawerItem(context, icon: Icons.home_outlined, label: 'Inicio', active: true, onTap: () => Navigator.of(context).pop()),
                    _drawerItem(context, icon: Icons.fitness_center_outlined, label: 'Entrenamiento', onTap: () {
                      Navigator.of(context).pushNamed('/evaluations');
                    }),
                    _drawerItem(context, icon: Icons.notifications_none, label: 'Notificaciones', onTap: () {
                      Navigator.of(context).pushNamed('/notifications');
                    }),
                    _drawerItem(context, icon: Icons.group_outlined, label: 'Atletas', onTap: () {
                      Navigator.of(context).pushNamed('/teams');
                    }),
                    _drawerItem(context, icon: Icons.bar_chart_outlined, label: 'Análisis y estadísticas', onTap: () {}),
                    _drawerItem(context, icon: Icons.person_outline, label: 'Perfil', onTap: () {
                      Navigator.of(context).pushNamed('/profile');
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.close, color: Color(0xFF0F2336)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(widget.parentLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
        const SizedBox(height: 8),
        Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Resumen general de tus atletas y actividades', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _drawerItem(BuildContext context, {required IconData icon, required String label, bool active = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        color: active ? const Color.fromRGBO(0, 0, 0, 0.04) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 6,
              height: 56,
              color: active ? const Color(0xFF0F2336) : Colors.transparent,
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF304150)),
                  const SizedBox(width: 16),
                  Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF304150))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
