import 'package:flutter/material.dart';
import 'evaluations_screen.dart';
import '../widgets/notifications_bottom_sheet.dart';
import '../widgets/app_drawer.dart';
import '../widgets/profile_menu_button.dart';
import '../theme/app_colors.dart';

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
  String _selectedTeam = 'Selección de Córdoba';
  String _selectedFlag = '🇦🇷';
  String _selectedSubtitle = 'Solo Córdoba';

  // 0 = Inicio (Dashboard), 1 = Entrenamiento (Evaluaciones)
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _teams = [
    {'name': 'Selección de Córdoba', 'country': 'Argentina', 'flag': '🇦🇷', 'subtitle': 'Solo Córdoba', 'athletes': 8},
    {'name': 'Equipo Bogotá', 'country': 'Colombia', 'flag': '🇨🇴', 'subtitle': 'Solo Bogotá', 'athletes': 6},
    {'name': 'Equipo Madrid', 'country': 'España', 'flag': '🇪🇸', 'subtitle': 'Solo Madrid', 'athletes': 5},
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: _buildTeamSelector(),
        actions: [
          _buildNotificationButton(),
          const ProfileMenuButton(),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(
        activeRoute: _selectedIndex == 1
            ? AppDrawerRoute.evaluaciones
            : AppDrawerRoute.inicio,
        teamName: _selectedTeam,
        teamFlag: _selectedFlag,
        onHomeSelected: () => setState(() => _selectedIndex = 0),
        onEvaluationsSelected: () => setState(() => _selectedIndex = 1),
      ),
      endDrawer: _buildTeamEndDrawer(),
      body: SafeArea(
        top: false,
        child: _selectedIndex == 1
            ? const EvaluationsBody()
            : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildTeamSelector() {
    return GestureDetector(
      onTap: () {
        _scaffoldKey.currentState?.openEndDrawer();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.neutral7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedFlag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedTeam, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(_selectedSubtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 20),
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
            showNotificationsBottomSheet(context);
          },
          icon: const Icon(Icons.notifications_none, color: AppColors.textSecondary),
        ),
        if (_notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$_notificationCount',
                style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTeamEndDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header — mismo fondo oscuro que el drawer principal usa como acento
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.group_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cambiar equipo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          'Selecciona tu equipo activo',
                          style: TextStyle(fontSize: 11, color: AppColors.neutral2),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.neutral2, size: 20),
                  ),
                ],
              ),
            ),
            // Línea separadora con el acento de color primario
            Container(height: 3, color: AppColors.primary),

            // Lista de equipos y administración
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 20, bottom: 16),
                children: [
                  // — Sección: Equipos activos
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Text(
                      'EQUIPOS ACTIVOS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.neutral5,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ..._teams.map((team) {
                    final bool isSelected = _selectedTeam == team['name'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTeam = team['name'];
                          _selectedFlag = team['flag'];
                          _selectedSubtitle = team['subtitle'];
                        });
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          // Acento lateral igual que el _drawerItem activo
                          Container(
                            width: 4,
                            height: 72,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary10,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Text(team['flag'],
                                      style: const TextStyle(fontSize: 26)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          team['name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isSelected
                                                ? AppColors.black
                                                : AppColors.neutral2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          team['country'],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.neutral5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Contador de atletas
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary10
                                          : AppColors.neutral9,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.person_outline,
                                            size: 12,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.neutral5),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${team['athletes']}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.neutral5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 10),
                                    const Icon(Icons.check_circle,
                                        color: AppColors.primary, size: 20),
                                  ] else ...[
                                    const SizedBox(width: 10),
                                    const Icon(Icons.radio_button_unchecked,
                                        color: AppColors.neutral5, size: 20),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                  // — Separador con etiqueta, igual al estilo de sección
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Text(
                      'ADMINISTRACIÓN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.neutral5,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _endDrawerAdminItem(
                    icon: Icons.add_circle_outline,
                    label: 'Crear nuevo equipo',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Función de crear equipo en desarrollo')),
                      );
                    },
                  ),
                  _endDrawerAdminItem(
                    icon: Icons.settings_outlined,
                    label: 'Administrar equipos',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/teams');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _endDrawerAdminItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.neutral2,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 13, color: AppColors.primary),
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
        Text(widget.parentLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Resumen general de tus atletas y actividades', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
      ],
    );
  }
}
