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
    {
      'name': 'Selección de Córdoba',
      'country': 'Argentina',
      'flag': '🇦🇷',
      'subtitle': 'Solo Córdoba',
      'athletes': 8
    },
    {
      'name': 'Equipo Bogotá',
      'country': 'Colombia',
      'flag': '🇨🇴',
      'subtitle': 'Solo Bogotá',
      'athletes': 6
    },
    {
      'name': 'Equipo Madrid',
      'country': 'España',
      'flag': '🇪🇸',
      'subtitle': 'Solo Madrid',
      'athletes': 5
    },
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Datos simulados del dashboard ──────────────────────────────────
  // Cambiar a true para simular un usuario nuevo sin datos
  final bool _isNewUser = false;

  // Stats resumen (cuando hay datos)
  final int _totalAthletes = 8;
  final int _totalEvaluations = 12;
  final double _avgEffectiveness = 68.5;
  final int _pendingEvaluations = 2;

  // Actividad reciente (cuando hay datos)
  final List<Map<String, dynamic>> _recentActivity = [
    {
      'type': 'evaluation',
      'title': 'Evaluación de Fuerza completada',
      'subtitle': 'María García · 78% efectividad',
      'time': 'Hace 2 horas',
      'icon': Icons.check_circle_outline,
      'color': AppColors.primary,
    },
    {
      'type': 'athlete',
      'title': 'Nuevo atleta registrado',
      'subtitle': 'Carlos López agregado al equipo',
      'time': 'Hace 5 horas',
      'icon': Icons.person_add_outlined,
      'color': AppColors.primary70,
    },
    {
      'type': 'evaluation',
      'title': 'Evaluación de Dirección en curso',
      'subtitle': 'Juan Pérez · 18/36 tiros',
      'time': 'Ayer',
      'icon': Icons.timer_outlined,
      'color': AppColors.info,
    },
    {
      'type': 'team',
      'title': 'Equipo actualizado',
      'subtitle': 'Se modificó la formación del equipo',
      'time': 'Hace 2 días',
      'icon': Icons.group_outlined,
      'color': AppColors.secondary,
    },
  ];

  // Atletas destacados (cuando hay datos)
  final List<Map<String, dynamic>> _topAthletes = [
    {
      'name': 'María García',
      'initials': 'MG',
      'effectiveness': 85.2,
      'trend': 'up'
    },
    {
      'name': 'Juan Pérez',
      'initials': 'JP',
      'effectiveness': 72.1,
      'trend': 'up'
    },
    {
      'name': 'Carlos López',
      'initials': 'CL',
      'effectiveness': 65.8,
      'trend': 'down'
    },
  ];

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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedTeam,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  Text(
                    _selectedSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down,
                color: AppColors.textSecondary, size: 20),
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
          icon: const Icon(Icons.notifications_none,
              color: AppColors.textSecondary),
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
                style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
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
                    child: const Icon(Icons.group_outlined,
                        color: AppColors.primary, size: 20),
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
                          style: TextStyle(
                              fontSize: 11, color: AppColors.neutral2),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close,
                        color: AppColors.neutral2, size: 20),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
      child: _isNewUser ? _buildEmptyStateContent() : _buildContent(),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CONTENIDO CON DATOS (usuario con evaluaciones)
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // ── Saludo ─────────────────────────────────────────────────
        Text('¡Hola, Oscar! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 4),
        Text('Resumen general de tus atletas y actividades',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // ── Tarjetas de estadísticas rápidas ────────────────────────
        _buildStatsGrid(),
        const SizedBox(height: 20),

        // ── Acciones rápidas ────────────────────────────────────────
        _buildQuickActions(),
        const SizedBox(height: 20),

        // ── Atletas destacados ──────────────────────────────────────
        _buildTopAthletesSection(),
        const SizedBox(height: 20),

        // ── Actividad reciente ──────────────────────────────────────
        _buildRecentActivitySection(),
        const SizedBox(height: 20),

        // ── Próximas evaluaciones ───────────────────────────────────
        _buildUpcomingSection(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _statCard(
          icon: Icons.group_outlined,
          label: 'Atletas',
          value: '$_totalAthletes',
          color: AppColors.primary,
          bgColor: AppColors.primary10,
        ),
        _statCard(
          icon: Icons.assignment_outlined,
          label: 'Evaluaciones',
          value: '$_totalEvaluations',
          color: AppColors.primary70,
          bgColor: AppColors.primary20,
        ),
        _statCard(
          icon: Icons.trending_up_rounded,
          label: 'Efectividad Prom.',
          value: '${_avgEffectiveness.toStringAsFixed(1)}%',
          color: AppColors.secondary,
          bgColor: AppColors.secondary20,
        ),
        _statCard(
          icon: Icons.pending_actions_outlined,
          label: 'Pendientes',
          value: '$_pendingEvaluations',
          color: AppColors.info,
          bgColor: AppColors.infoBg,
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Acciones Rápidas'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickActionButton(
                icon: Icons.bolt_rounded,
                label: 'Nueva\nEvaluación',
                color: AppColors.primary,
                bgColor: AppColors.primary10,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionButton(
                icon: Icons.person_add_outlined,
                label: 'Agregar\nAtleta',
                color: AppColors.primary70,
                bgColor: AppColors.primary20,
                onTap: () => Navigator.of(context).pushNamed(
                  '/athletes',
                  arguments: {
                    'teamName': _selectedTeam,
                    'teamFlag': _selectedFlag,
                    'teamSubtitle': _selectedSubtitle,
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionButton(
                icon: Icons.group_outlined,
                label: 'Ver\nEquipo',
                color: AppColors.info,
                bgColor: AppColors.infoBg,
                onTap: () => Navigator.of(context).pushNamed(
                  '/athletes',
                  arguments: {
                    'teamName': _selectedTeam,
                    'teamFlag': _selectedFlag,
                    'teamSubtitle': _selectedSubtitle,
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral8),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAthletesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Rendimiento del Equipo', actionLabel: 'Ver todos',
            onAction: () {
          Navigator.of(context).pushNamed(
            '/athletes',
            arguments: {
              'teamName': _selectedTeam,
              'teamFlag': _selectedFlag,
              'teamSubtitle': _selectedSubtitle,
            },
          );
        }),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _topAthletes.length; i++) ...[
                _athleteRow(_topAthletes[i], rank: i + 1),
                if (i < _topAthletes.length - 1)
                  Divider(color: AppColors.neutral8, height: 20),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _athleteRow(Map<String, dynamic> athlete, {required int rank}) {
    final bool isUp = athlete['trend'] == 'up';
    final double effectiveness = athlete['effectiveness'];
    final Color progressColor = effectiveness >= 75
        ? AppColors.success
        : effectiveness >= 50
            ? AppColors.warning
            : AppColors.error;

    return Row(
      children: [
        // Rank badge
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: rank == 1 ? AppColors.accent2x10 : AppColors.neutral9,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: rank == 1 ? AppColors.accent2 : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Avatar
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.secondary,
          child: Text(
            athlete['initials'],
            style: const TextStyle(
              color: AppColors.actionSecondaryInverted,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name + trend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                athlete['name'],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    isUp
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 14,
                    color: isUp ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isUp ? 'En progreso' : 'Necesita atención',
                    style: TextStyle(
                      fontSize: 11,
                      color: isUp ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Effectiveness with mini progress
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${effectiveness.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: effectiveness / 100,
                  minHeight: 4,
                  backgroundColor: AppColors.neutral8,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Actividad Reciente'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _recentActivity.length; i++) ...[
                _activityTile(_recentActivity[i]),
                if (i < _recentActivity.length - 1)
                  Divider(
                    color: AppColors.neutral8,
                    height: 1,
                    indent: 68,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityTile(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity['subtitle'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.neutral5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary80],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Evaluaciones pendientes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tienes $_pendingEvaluations evaluaciones por completar esta semana',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Ver',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EMPTY STATE (usuario nuevo sin evaluaciones)
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyStateContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // ── Saludo ─────────────────────────────────────────────────
        Text('¡Bienvenido a Boccia Coaching! 🎉',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.black)),
        const SizedBox(height: 4),
        Text('Comienza a configurar tu equipo y tus evaluaciones',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        // ── Onboarding progress ─────────────────────────────────────
        _buildOnboardingProgress(),
        const SizedBox(height: 24),

        // ── Pasos para empezar ──────────────────────────────────────
        _buildGettingStartedSteps(),
        const SizedBox(height: 24),

        // ── Empty stats placeholders ────────────────────────────────
        _buildEmptyStatsGrid(),
        const SizedBox(height: 24),

        // ── CTA principal ───────────────────────────────────────────
        _buildEmptyStateCTA(),
        const SizedBox(height: 24),

        // ── Tip informativo ─────────────────────────────────────────
        _buildTipCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOnboardingProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary10,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu progreso de configuración',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '1 de 4 pasos completados',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent2x10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '25%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.25,
              minHeight: 8,
              backgroundColor: AppColors.neutral8,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGettingStartedSteps() {
    final steps = [
      {
        'title': 'Crear tu cuenta',
        'subtitle': 'Ya tienes tu perfil de coach activo',
        'icon': Icons.check_circle_rounded,
        'completed': true,
        'color': AppColors.success,
      },
      {
        'title': 'Configurar tu equipo',
        'subtitle': 'Personaliza los datos del equipo',
        'icon': Icons.group_add_outlined,
        'completed': false,
        'color': AppColors.primary,
        'onTap': () => Navigator.of(context).pushNamed('/teams'),
      },
      {
        'title': 'Agregar atletas',
        'subtitle': 'Registra a tus atletas para evaluar',
        'icon': Icons.person_add_alt_1_outlined,
        'completed': false,
        'color': AppColors.primary70,
        'onTap': () => Navigator.of(context).pushNamed(
              '/athletes',
              arguments: {
                'teamName': _selectedTeam,
                'teamFlag': _selectedFlag,
                'teamSubtitle': _selectedSubtitle,
              },
            ),
      },
      {
        'title': 'Realizar tu primera evaluación',
        'subtitle': 'Mide el rendimiento de tus atletas',
        'icon': Icons.assignment_outlined,
        'completed': false,
        'color': AppColors.info,
        'onTap': () => setState(() => _selectedIndex = 1),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Primeros Pasos'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _onboardingStep(steps[i], stepNumber: i + 1),
                if (i < steps.length - 1)
                  Divider(color: AppColors.neutral8, height: 1, indent: 68),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _onboardingStep(Map<String, dynamic> step, {required int stepNumber}) {
    final bool completed = step['completed'] as bool;
    final Color color = step['color'] as Color;

    return InkWell(
      onTap: completed ? null : step['onTap'] as VoidCallback?,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: completed
                    ? AppColors.successBg
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                step['icon'] as IconData,
                color: completed ? AppColors.success : color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['title'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: completed
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step['subtitle'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (completed)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 22)
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Iniciar',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Tu Resumen'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            _emptyStatCard(
              icon: Icons.group_outlined,
              label: 'Atletas',
              value: '0',
              color: AppColors.primary,
              bgColor: AppColors.primary10,
            ),
            _emptyStatCard(
              icon: Icons.assignment_outlined,
              label: 'Evaluaciones',
              value: '0',
              color: AppColors.primary70,
              bgColor: AppColors.primary20,
            ),
            _emptyStatCard(
              icon: Icons.trending_up_rounded,
              label: 'Efectividad',
              value: '—',
              color: AppColors.neutral5,
              bgColor: AppColors.neutral9,
            ),
            _emptyStatCard(
              icon: Icons.pending_actions_outlined,
              label: 'Pendientes',
              value: '0',
              color: AppColors.neutral5,
              bgColor: AppColors.neutral9,
            ),
          ],
        ),
      ],
    );
  }

  Widget _emptyStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral8, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCTA() {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 1),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary80],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary40,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: AppColors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comienza tu primera evaluación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Evalúa la fuerza y dirección de tus atletas con nuestro módulo especializado',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 ¿Sabías que…?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'La evaluación de fuerza consiste en 36 tiros distribuidos en 6 cajones '
                  'con 3 distancias diferentes. Esto permite analizar la efectividad, '
                  'precisión y fatiga de cada atleta.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HELPERS compartidos
  // ════════════════════════════════════════════════════════════════════════════

  Widget _sectionHeader(String title,
      {String? actionLabel, VoidCallback? onAction}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
