import 'package:flutter/material.dart';
import 'evaluations_screen.dart';
import '../widgets/notifications_bottom_sheet.dart';
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
          _buildProfileMenu(),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
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

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.of(context).pushNamed('/profile');
        } else if (value == 'logout') {
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
      color: AppColors.surface,
      elevation: 4,
      shadowColor: AppColors.black.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral8),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        // ── Encabezado: info del usuario ──────────────────────────────
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.secondary,
                  child: const Text(
                    'OB',
                    style: TextStyle(
                      color: AppColors.actionSecondaryInverted,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Oscar Barragán',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'oscar.barragan@email.com',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // ── Plan activo ───────────────────────────────────────────────
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_membership_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plan Premium Pro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'Válido hasta 31 dic 2026',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 12),
        // ── Mi Perfil ─────────────────────────────────────────────────
        PopupMenuItem<String>(
          value: 'profile',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.neutral8,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_outline, size: 18, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mi Perfil',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 12),
        // ── Cerrar sesión ─────────────────────────────────────────────
        PopupMenuItem<String>(
          value: 'logout',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout, size: 18, color: AppColors.error),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.secondary,
        child: const Text(
          'OB',
          style: TextStyle(
            color: AppColors.actionSecondaryInverted,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
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

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header con logo y botón de cierre ──────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
              color: AppColors.white,
              child: Row(
                children: [
                  const Expanded(child: BocciaLogo(size: 40)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.neutral4, size: 22),
                    tooltip: 'Cerrar menú',
                  ),
                ],
              ),
            ),
            // Acento de color en la parte inferior del header
            Container(height: 3, color: AppColors.primary),

            // ── Navegación principal ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // — Sección principal
                    _drawerSectionLabel('PRINCIPAL'),
                    _drawerItem(
                      context,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Inicio',
                      active: _selectedIndex == 0,
                      onTap: () {
                        setState(() => _selectedIndex = 0);
                        Navigator.of(context).pop();
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.assignment_outlined,
                      activeIcon: Icons.assignment,
                      label: 'Evaluaciones',
                      active: _selectedIndex == 1,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                        Navigator.of(context).pop();
                      },
                    ),

                    const SizedBox(height: 8),
                    // — Sección análisis
                    _drawerSectionLabel('ANÁLISIS'),
                    _drawerItem(
                      context,
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart,
                      label: 'Estadísticas',
                      badge: 'Próximo',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer: perfil del usuario ──────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.neutral8)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/profile');
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.secondary,
                      child: const Text(
                        'OB',
                        style: TextStyle(
                          color: AppColors.actionSecondaryInverted,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Oscar Barragán',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Coach · Plan Premium',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.neutral5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: AppColors.neutral5,
          letterSpacing: 1.2,
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

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    IconData? activeIcon,
    required String label,
    bool active = false,
    String? badge,
    VoidCallback? onTap,
  }) {
    final Color iconColor = active ? AppColors.primary : AppColors.neutral4;
    final Color textColor = active ? AppColors.primary : AppColors.neutral2;
    final IconData displayIcon = active && activeIcon != null ? activeIcon : icon;

    return InkWell(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: active ? AppColors.primary10 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Barra de acento lateral
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Ícono con fondo cuando está activo
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: active ? AppColors.primary20 : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(displayIcon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ),
            if (badge != null) ...[
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent2x10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent2,
                  ),
                ),
              ),
            ] else if (!active) ...[
              const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.neutral6),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(Icons.circle, size: 8, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
