import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/views/evaluations_screen.dart';
import '../../../shared/widgets/notifications_bottom_sheet.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/profile_menu_button.dart';
import '../../../shared/widgets/team_selector_chip.dart';
import '../../../shared/widgets/team_end_drawer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';

/// Dashboard específico para el rol de **atleta** (rolId == 3).
///
/// Tiene la misma estructura visual que [DashboardScreen] (coach) pero con:
/// - Título «Panel Deportista».
/// - Estadísticas orientadas al rendimiento personal.
/// - Acciones rápidas relevantes para un atleta.
/// - El [TeamEndDrawer] sin la sección de administración.
/// - El [AppDrawer] con opciones limitadas para el atleta.
class AthleteDashboardScreen extends StatefulWidget {
  final String parentLabel;
  const AthleteDashboardScreen({
    super.key,
    this.parentLabel = 'Panel Deportista',
  });

  @override
  State<AthleteDashboardScreen> createState() =>
      _AthleteDashboardScreenState();
}

class _AthleteDashboardScreenState extends State<AthleteDashboardScreen> {
  int _notificationCount = 1;

  // 0 = Inicio (Dashboard), 1 = Evaluaciones
  int _selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Datos simulados del dashboard del atleta ───────────────────────
  final bool _isNewUser = false;

  // Stats personales
  final int _totalEvaluations = 5;
  final double _avgEffectiveness = 72.3;
  final int _pendingEvaluations = 1;
  final int _completedSessions = 12;

  // Mis evaluaciones recientes
  final List<Map<String, dynamic>> _recentActivity = [
    {
      'type': 'evaluation',
      'title': 'Evaluación de Fuerza completada',
      'subtitle': '78% efectividad · 36 tiros',
      'time': 'Hace 2 horas',
      'icon': Icons.check_circle_outline,
      'color': AppColors.primary,
    },
    {
      'type': 'evaluation',
      'title': 'Evaluación de Dirección en curso',
      'subtitle': '18/36 tiros completados',
      'time': 'Ayer',
      'icon': Icons.timer_outlined,
      'color': AppColors.info,
    },
    {
      'type': 'result',
      'title': 'Nuevo récord personal',
      'subtitle': 'Fuerza: mejor puntaje en cajón 3',
      'time': 'Hace 3 días',
      'icon': Icons.emoji_events_outlined,
      'color': AppColors.accent2,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTeams());
  }

  Future<void> _loadTeams() async {
    final session = context.read<SessionProvider>().session;
    if (session == null) return;
    final teamProvider = context.read<TeamProvider>();
    if (teamProvider.teams.isEmpty) {
      await teamProvider.fetchTeams(session.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();
    final selected = teamProvider.selectedTeam;
    final selectedName = selected?.nameTeam ?? 'Sin equipo';
    final selectedCountry = selected?.country ?? '';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: TeamSelectorChip(
          teamName: selectedName,
          teamFlag: '',
          teamSubtitle: selectedCountry,
          onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
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
        teamName: selectedName,
        teamFlag: '',
        onHomeSelected: () => setState(() => _selectedIndex = 0),
        onEvaluationsSelected: () => setState(() => _selectedIndex = 1),
      ),
      endDrawer: TeamEndDrawer(
        showAdminSection: false,
        onTeamSelected: (team) {
          teamProvider.selectTeam(team);
        },
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _selectedIndex == 1
            ? const EvaluationsBody()
            : _buildMobileLayout(),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: () => showNotificationsBottomSheet(context),
          icon: const Icon(
            Icons.notifications_none,
            color: AppColors.textSecondary,
          ),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + bottomPadding),
      child: _isNewUser ? _buildEmptyStateContent() : _buildContent(),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CONTENIDO CON DATOS
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // ── Saludo ─────────────────────────────────────────────────
        Builder(builder: (context) {
          final firstName =
              context.watch<SessionProvider>().session?.firstName ?? 'Usuario';
          return Text(
            '¡Hola, $firstName! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
          );
        }),
        const SizedBox(height: 4),
        Text(
          'Tu resumen personal de rendimiento',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        // ── Estadísticas personales ─────────────────────────────────
        _buildStatsGrid(),
        const SizedBox(height: 20),

        // ── Acciones rápidas ────────────────────────────────────────
        _buildQuickActions(),
        const SizedBox(height: 20),

        // ── Mi rendimiento ──────────────────────────────────────────
        _buildMyPerformanceSection(),
        const SizedBox(height: 20),

        // ── Actividad reciente ──────────────────────────────────────
        _buildRecentActivitySection(),
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
      childAspectRatio: 1.4,
      children: [
        _statCard(
          icon: Icons.assignment_outlined,
          label: 'Evaluaciones',
          value: '$_totalEvaluations',
          color: AppColors.primary,
          bgColor: AppColors.primary10,
        ),
        _statCard(
          icon: Icons.trending_up_rounded,
          label: 'Efectividad Prom.',
          value: '${_avgEffectiveness.toStringAsFixed(1)}%',
          color: AppColors.secondary,
          bgColor: AppColors.secondary20,
        ),
        _statCard(
          icon: Icons.fitness_center_rounded,
          label: 'Sesiones',
          value: '$_completedSessions',
          color: AppColors.primary70,
          bgColor: AppColors.primary20,
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
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
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
                icon: Icons.bar_chart_outlined,
                label: 'Mis\nEstadísticas',
                color: AppColors.primary,
                bgColor: AppColors.primary10,
                onTap: () =>
                    Navigator.of(context).pushNamed('/statistics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionButton(
                icon: Icons.assignment_outlined,
                label: 'Mis\nEvaluaciones',
                color: AppColors.primary70,
                bgColor: AppColors.primary20,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionButton(
                icon: Icons.person_outline,
                label: 'Mi\nPerfil',
                color: AppColors.info,
                bgColor: AppColors.infoBg,
                onTap: () =>
                    Navigator.of(context).pushNamed('/profile'),
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

  // ── Mi Rendimiento (resumen visual) ────────────────────────────────────

  Widget _buildMyPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Mi Rendimiento', actionLabel: 'Ver detalle',
            onAction: () {
          Navigator.of(context).pushNamed('/statistics');
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
              _performanceRow(
                label: 'Efectividad general',
                value: '72.3%',
                progress: 0.723,
                color: AppColors.primary,
              ),
              Divider(color: AppColors.neutral8, height: 20),
              _performanceRow(
                label: 'Precisión de dirección',
                value: '68.1%',
                progress: 0.681,
                color: AppColors.primary70,
              ),
              Divider(color: AppColors.neutral8, height: 20),
              _performanceRow(
                label: 'Control de fuerza',
                value: '76.5%',
                progress: 0.765,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _performanceRow({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.neutral8,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ── Actividad reciente ─────────────────────────────────────────────────

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
                _activityItem(_recentActivity[i]),
                if (i < _recentActivity.length - 1)
                  Divider(color: AppColors.neutral8, height: 1, indent: 68),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _activityItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: item['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item['time'] as String,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.neutral5,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EMPTY STATE (atleta nuevo)
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyStateContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          '¡Bienvenido a Boccia Coaching! 🎉',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tu entrenador aún no te ha asignado evaluaciones',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        // ── Info card ───────────────────────────────────────────────
        _buildWaitingCard(),
        const SizedBox(height: 24),

        // ── Empty stats ─────────────────────────────────────────────
        _buildEmptyStatsGrid(),
        const SizedBox(height: 24),

        // ── Tip ─────────────────────────────────────────────────────
        _buildTipCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildWaitingCard() {
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.sports_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Listo para entrenar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tu entrenador te asignará evaluaciones pronto. '
                  'Mientras tanto, revisa tu perfil.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              icon: Icons.assignment_outlined,
              label: 'Evaluaciones',
              value: '0',
              color: AppColors.primary,
              bgColor: AppColors.primary10,
            ),
            _emptyStatCard(
              icon: Icons.trending_up_rounded,
              label: 'Efectividad',
              value: '—',
              color: AppColors.neutral5,
              bgColor: AppColors.neutral9,
            ),
            _emptyStatCard(
              icon: Icons.fitness_center_rounded,
              label: 'Sesiones',
              value: '0',
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
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppColors.primary,
              size: 20,
            ),
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
                  'Puedes consultar tus estadísticas detalladas desde '
                  'el menú lateral o las acciones rápidas. Allí verás tu '
                  'progreso en cada tipo de evaluación.',
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
  // HELPERS
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
