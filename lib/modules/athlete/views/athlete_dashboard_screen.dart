import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'athlete_session_calendar_screen.dart';
import '../../../shared/widgets/notifications_bottom_sheet.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/profile_menu_button.dart';
import '../../../shared/widgets/team_selector_chip.dart';
import '../../../shared/widgets/team_end_drawer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/training_session.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';
import '../../../data/providers/statistics_provider.dart';
import '../../../data/providers/athlete_session_provider.dart';

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
  State<AthleteDashboardScreen> createState() => _AthleteDashboardScreenState();
}

class _AthleteDashboardScreenState extends State<AthleteDashboardScreen> {
  int _notificationCount = 1;

  // 0 = Inicio (Dashboard), 1 = Mi Calendario
  int _selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Datos del dashboard del atleta desde la API ─────────────────────
  bool get _isNewUser {
    final dashboard = context.read<StatisticsProvider>().athleteDashboard;
    if (dashboard == null) return false;
    final total = (dashboard['totalEvaluations'] as num?) ?? 0;
    return total == 0;
  }

  // Stats personales desde la API
  int get _totalEvaluations =>
      (context.read<StatisticsProvider>().athleteDashboard?['totalEvaluations']
              as num?)
          ?.toInt() ??
      0;
  double get _avgEffectiveness =>
      (context.read<StatisticsProvider>().athleteDashboard?['avgEffectiveness']
              as num?)
          ?.toDouble() ??
      0.0;
  int get _completedSessions =>
      (context.read<StatisticsProvider>().athleteDashboard?['completedSessions']
              as num?)
          ?.toInt() ??
      0;

  // Evaluaciones recientes desde la API
  List<Map<String, dynamic>> get _recentActivity {
    final dashboard = context.read<StatisticsProvider>().athleteDashboard;
    final recent = dashboard?['recentEvaluations'];
    if (recent is! List || recent.isEmpty) return [];
    return recent.map<Map<String, dynamic>>((e) {
      final item = e as Map<String, dynamic>;
      return {
        'type': 'evaluation',
        'title': item['testType'] ?? 'Evaluación',
        'subtitle': '${item['score'] ?? ''}% efectividad',
        'time': item['date'] ?? '',
        'icon': Icons.check_circle_outline,
        'color': AppColors.primary,
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeams();
      _loadAthleteDashboard();
      _loadAthleteSessions();
    });
  }

  Future<void> _loadTeams() async {
    final session = context.read<SessionProvider>().session;
    if (session == null) return;
    final teamProvider = context.read<TeamProvider>();
    if (teamProvider.teams.isEmpty) {
      await teamProvider.fetchTeams(session.userId);
    }
  }

  Future<void> _loadAthleteDashboard() async {
    final session = context.read<SessionProvider>().session;
    if (session == null) return;
    final stats = context.read<StatisticsProvider>();
    await stats.fetchAthleteFullDashboard(session.userId);
  }

  Future<void> _loadAthleteSessions() async {
    final session = context.read<SessionProvider>().session;
    if (session == null) return;
    await context
        .read<AthleteSessionProvider>()
        .loadAthletesSessions(session.userId);
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();
    // Watch statistics for reactive updates
    context.watch<StatisticsProvider>();
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
          teamImageUrl: selected?.image,
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
            ? AppDrawerRoute.miCalendario
            : AppDrawerRoute.inicio,
        teamName: selectedName,
        teamFlag: '',
        onHomeSelected: () => setState(() => _selectedIndex = 0),
        onCalendarSelected: () => setState(() => _selectedIndex = 1),
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
            ? const AthleteSessionCalendarScreen(embedded: true)
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

        // ── Próximas sesiones ─────────────────────────────────────────
        _buildUpcomingSessionsSection(),
        const SizedBox(height: 20),

        // ── Actividad reciente ──────────────────────────────────────
        _buildRecentActivitySection(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final sessionProv = context.watch<AthleteSessionProvider>();
    final upcomingCount = sessionProv.upcomingSessions.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _statCard(
          icon: Icons.calendar_today_outlined,
          label: 'Próximas Sesiones',
          value: '$upcomingCount',
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
          label: 'Sesiones Completadas',
          value: '$_completedSessions',
          color: AppColors.primary70,
          bgColor: AppColors.primary20,
        ),
        _statCard(
          icon: Icons.assignment_outlined,
          label: 'Evaluaciones',
          value: '$_totalEvaluations',
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
                onTap: () => Navigator.of(context).pushNamed('/statistics'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickActionButton(
                icon: Icons.calendar_month_outlined,
                label: 'Mi\nCalendario',
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
                onTap: () => Navigator.of(context).pushNamed('/profile'),
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

  // ── Próximas Sesiones ────────────────────────────────────────────────

  Widget _buildUpcomingSessionsSection() {
    final sessionProvider = context.watch<AthleteSessionProvider>();
    final upcoming = sessionProvider.upcomingSessions.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Próximas Sesiones', actionLabel: 'Ver calendario',
            onAction: () {
          setState(() => _selectedIndex = 1);
        }),
        const SizedBox(height: 12),
        if (sessionProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          )
        else if (upcoming.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.neutral8),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_available_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Sin sesiones próximas',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral4,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tu entrenador te asignará sesiones pronto',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
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
                for (int i = 0; i < upcoming.length; i++) ...[
                  _upcomingSessionItem(upcoming[i]),
                  if (i < upcoming.length - 1)
                    Divider(color: AppColors.neutral8, height: 1, indent: 68),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _upcomingSessionItem(AthleteSessionSummary session) {
    final scheduledDate = AthleteSessionProvider.scheduledDateOf(session);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay =
        DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    final diff = sessionDay.difference(today).inDays;

    String dateLabel;
    if (diff == 0) {
      dateLabel = 'Hoy';
    } else if (diff == 1) {
      dateLabel = 'Mañana';
    } else if (diff < 7) {
      dateLabel = 'En $diff días';
    } else {
      dateLabel = '${scheduledDate.day}/${scheduledDate.month}';
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/training-session-detail',
          arguments: session.trainingSessionId,
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session.dayOfWeek ?? "Sesión"} · ${session.duration} min',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${session.macrocycleName ?? 'Macrociclo'} · Micro ${session.microcycleNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: diff == 0 ? AppColors.primary10 : AppColors.neutral9,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: diff == 0 ? AppColors.primary : AppColors.neutral5,
                ),
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
          childAspectRatio: 1.3,
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
            maxLines: 1,
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
