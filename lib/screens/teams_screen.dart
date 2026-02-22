import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  String _selectedTeam = 'Selección de Córdoba';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Mis Equipos', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
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
          const Text('Equipos activos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _teamCard(
            name: 'Selección de Córdoba',
            country: 'Argentina',
            flag: '🇦🇷',
            athletes: 8,
            isSelected: _selectedTeam == 'Selección de Córdoba',
            onTap: () {
              setState(() => _selectedTeam = 'Selección de Córdoba');
              Navigator.of(context).pop(_selectedTeam);
            },
          ),
          const SizedBox(height: 12),
          _teamCard(
            name: 'Equipo Bogotá',
            country: 'Colombia',
            flag: '🇨🇴',
            athletes: 6,
            isSelected: _selectedTeam == 'Equipo Bogotá',
            onTap: () {
              setState(() => _selectedTeam = 'Equipo Bogotá');
              Navigator.of(context).pop(_selectedTeam);
            },
          ),
          const SizedBox(height: 12),
          _teamCard(
            name: 'Equipo Madrid',
            country: 'España',
            flag: '🇪🇸',
            athletes: 5,
            isSelected: _selectedTeam == 'Equipo Madrid',
            onTap: () {
              setState(() => _selectedTeam = 'Equipo Madrid');
              Navigator.of(context).pop(_selectedTeam);
            },
          ),
          const SizedBox(height: 24),
          const Text('Administración', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _adminCard(
            title: 'Crear nuevo equipo',
            icon: Icons.add_circle_outline,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de crear equipo en desarrollo')),
              );
            },
          ),
          const SizedBox(height: 12),
          _adminCard(
            title: 'Administrar equipos',
            icon: Icons.settings_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de administrar equipos en desarrollo')),
              );
            },
          ),
        ],
      ),
      ),
    );
  }

  Widget _teamCard({
    required String name,
    required String country,
    required String flag,
    required int athletes,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
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
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(country, style: TextStyle(color: AppColors.neutral4, fontSize: 12)),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.group, size: 20, color: AppColors.neutral5),
                const SizedBox(height: 4),
                Text('$athletes', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 16),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _adminCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.neutral5),
          ],
        ),
      ),
    );
  }
}
