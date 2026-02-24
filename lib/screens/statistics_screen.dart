import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/session_provider.dart';
import '../providers/team_provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/profile_menu_button.dart';
import '../widgets/team_selector_chip.dart';
import '../widgets/team_end_drawer.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final teamProvider = context.read<TeamProvider>();
    final session = context.read<SessionProvider>().session;
    if (session == null) return;

    // Cargar equipos si no se han cargado
    if (teamProvider.teams.isEmpty) {
      await teamProvider.fetchTeams(session.userId);
    }

    // Cargar evaluaciones del equipo seleccionado
    final selectedTeam = teamProvider.selectedTeam;
    if (selectedTeam != null) {
      await context
          .read<StatisticsProvider>()
          .fetchTeamEvaluations(selectedTeam.teamId);
    }
  }

  Future<void> _onTeamChanged() async {
    final teamProvider = context.read<TeamProvider>();
    final selectedTeam = teamProvider.selectedTeam;
    if (selectedTeam != null) {
      final statsProvider = context.read<StatisticsProvider>();
      statsProvider.clear();
      await statsProvider.fetchTeamEvaluations(selectedTeam.teamId);
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
        actions: const [
          ProfileMenuButton(),
          SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(
        activeRoute: AppDrawerRoute.estadisticas,
        teamName: selectedName,
        teamFlag: '',
      ),
      endDrawer: TeamEndDrawer(
        onTeamSelected: (team) {
          teamProvider.selectTeam(team);
          _onTeamChanged();
        },
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final statsProvider = context.watch<StatisticsProvider>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Si se seleccionó una evaluación, mostrar su detalle
    if (statsProvider.selectedEvaluationId != null) {
      return _buildEvaluationDetail(statsProvider, bottomPadding);
    }

    // Mostrar lista de evaluaciones
    return _buildEvaluationsList(statsProvider, bottomPadding);
  }

  // ════════════════════════════════════════════════════════════════════
  // LISTA DE EVALUACIONES
  // ════════════════════════════════════════════════════════════════════

  Widget _buildEvaluationsList(
      StatisticsProvider statsProvider, double bottomPadding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estadísticas',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona una evaluación para ver sus estadísticas',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Contenido
        Expanded(
          child: _buildEvaluationsContent(statsProvider, bottomPadding),
        ),
      ],
    );
  }

  Widget _buildEvaluationsContent(
      StatisticsProvider statsProvider, double bottomPadding) {
    if (statsProvider.isLoadingEvaluations) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (statsProvider.evaluationsStatus == StatsLoadingStatus.error) {
      return _buildErrorState(
        statsProvider.evaluationsError ?? 'Error desconocido',
        onRetry: _loadData,
      );
    }

    if (statsProvider.evaluations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPadding),
        itemCount: statsProvider.evaluations.length,
        itemBuilder: (context, index) {
          final eval = statsProvider.evaluations[index];
          return _buildEvaluationCard(eval);
        },
      ),
    );
  }

  Widget _buildEvaluationCard(Map<String, dynamic> evaluation) {
    final id = evaluation['id'] ?? evaluation['assessStrengthId'] ?? 0;
    final description = evaluation['description'] ?? 'Evaluación #$id';
    final date = evaluation['evaluationDate'] ?? evaluation['createdAt'] ?? '';
    final state = evaluation['state'] ?? 'Completada';
    final teamId = evaluation['teamId'];

    // Determinar color del estado
    Color stateColor;
    Color stateBgColor;
    IconData stateIcon;
    switch (state.toString().toLowerCase()) {
      case 'activa':
      case 'active':
      case 'en curso':
        stateColor = AppColors.warning;
        stateBgColor = AppColors.warningBg;
        stateIcon = Icons.timer_outlined;
        break;
      case 'completada':
      case 'completed':
      case 'finalizada':
        stateColor = AppColors.success;
        stateBgColor = AppColors.successBg;
        stateIcon = Icons.check_circle_outline;
        break;
      default:
        stateColor = AppColors.info;
        stateBgColor = AppColors.infoBg;
        stateIcon = Icons.info_outline;
    }

    // Formatear fecha
    String formattedDate = '';
    if (date.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(date);
        formattedDate =
            '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
      } catch (_) {
        formattedDate = date;
      }
    }

    return GestureDetector(
      onTap: () {
        context.read<StatisticsProvider>().fetchFullEvaluationData(id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Row(
          children: [
            // Ícono
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.assessment_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (formattedDate.isNotEmpty) ...[
                        Icon(Icons.calendar_today_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (teamId != null) ...[
                        Icon(Icons.group_outlined,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Equipo #$teamId',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Estado badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: stateBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(stateIcon, size: 12, color: stateColor),
                  const SizedBox(width: 4),
                  Text(
                    state,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: stateColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.neutral6),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // DETALLE DE EVALUACIÓN
  // ════════════════════════════════════════════════════════════════════

  Widget _buildEvaluationDetail(
      StatisticsProvider statsProvider, double bottomPadding) {
    return Column(
      children: [
        // Barra de navegación de vuelta
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.neutral8),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  context.read<StatisticsProvider>().clearSelectedEvaluation();
                },
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: AppColors.textPrimary),
              ),
              Text(
                'Evaluación #${statsProvider.selectedEvaluationId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        // Contenido
        Expanded(
          child: _buildDetailContent(statsProvider, bottomPadding),
        ),
      ],
    );
  }

  Widget _buildDetailContent(
      StatisticsProvider statsProvider, double bottomPadding) {
    final isLoading =
        statsProvider.isLoadingStats || statsProvider.isLoadingDetails;

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Cargando estadísticas...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (statsProvider.statsStatus == StatsLoadingStatus.error) {
      return _buildErrorState(
        statsProvider.statsError ?? 'Error al cargar estadísticas',
        onRetry: () => statsProvider
            .fetchFullEvaluationData(statsProvider.selectedEvaluationId!),
      );
    }

    final statsList = statsProvider.evaluationStatsList;
    final details = statsProvider.evaluationDetails;

    if (statsList.isEmpty && details == null) {
      return _buildErrorState('No hay datos disponibles para esta evaluación.',
          onRetry: () => statsProvider
              .fetchFullEvaluationData(statsProvider.selectedEvaluationId!));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info de la evaluación (desde details) ─────────
          if (details != null) ...[
            _buildEvaluationInfoHeader(details),
            const SizedBox(height: 24),
          ],

          // ── Estadísticas por atleta ──────────────────────
          if (statsList.isNotEmpty) ...[
            _sectionTitle('Resumen por Atleta'),
            const SizedBox(height: 12),
            ...statsList
                .map((athleteStats) => _buildAthleteStatsCard(athleteStats)),
            const SizedBox(height: 24),
          ],

          // ── Detalles de tiros ────────────────────────────
          if (details != null) ...[
            _buildThrowsSection(details),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // HEADER DE EVALUACIÓN
  // ════════════════════════════════════════════════════════════════════

  Widget _buildEvaluationInfoHeader(Map<String, dynamic> details) {
    final description = details['description'] ?? '';
    final teamName = details['teamName'] ?? '';
    final coachName = details['coachName'] ?? '';
    final stateName = details['stateName'] ?? details['state'] ?? '';
    final dateStr = details['evaluationDate'] ?? '';
    String formattedDate = '';
    if (dateStr.isNotEmpty) {
      try {
        final d = DateTime.parse(dateStr);
        formattedDate =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      } catch (_) {
        formattedDate = dateStr;
      }
    }

    final athletes = details['athletes'] as List<dynamic>? ?? [];

    // State badge colors
    Color stateColor;
    Color stateBgColor;
    IconData stateIcon;
    switch (stateName.toString().toLowerCase()) {
      case 'activa':
      case 'active':
      case 'en curso':
        stateColor = AppColors.warning;
        stateBgColor = AppColors.warningBg;
        stateIcon = Icons.timer_outlined;
        break;
      case 'completada':
      case 'completed':
      case 'finalizada':
        stateColor = AppColors.success;
        stateBgColor = AppColors.successBg;
        stateIcon = Icons.check_circle_outline;
        break;
      default:
        stateColor = AppColors.info;
        stateBgColor = AppColors.infoBg;
        stateIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assessment_rounded,
                    color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description.isNotEmpty
                          ? description
                          : 'Evaluación de Fuerza',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    if (formattedDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: stateBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(stateIcon, size: 13, color: stateColor),
                    const SizedBox(width: 4),
                    Text(
                      stateName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: stateColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.neutral8, height: 1),
          const SizedBox(height: 16),
          // Info row: Equipo + Entrenador
          Row(
            children: [
              Expanded(
                child:
                    _headerInfoChip(Icons.group_outlined, 'Equipo', teamName),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _headerInfoChip(
                    Icons.person_outline, 'Entrenador', coachName),
              ),
            ],
          ),
          if (athletes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _headerInfoChip(
              Icons.sports_rounded,
              'Atletas',
              athletes
                  .map((a) => a['athleteName'] ?? '')
                  .where((n) => n.isNotEmpty)
                  .join(', '),
            ),
          ],
        ],
      ),
    );
  }

  Widget _headerInfoChip(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : '—',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // TARJETA DE ESTADÍSTICAS POR ATLETA
  // ════════════════════════════════════════════════════════════════════

  Widget _buildAthleteStatsCard(Map<String, dynamic> stats) {
    final athleteName = stats['athleteName'] ?? 'Atleta';
    final effectiveness =
        ((stats['effectivenessPercentage'] as num?)?.toDouble() ?? 0) * 100;
    final accuracy =
        ((stats['accuracyPercentage'] as num?)?.toDouble() ?? 0) * 100;
    final effectiveThrow = (stats['effectiveThrow'] as num?)?.toInt() ?? 0;
    final failedThrow = (stats['failedThrow'] as num?)?.toInt() ?? 0;
    final totalThrows = effectiveThrow + failedThrow;

    final shortThrow = (stats['shortThrow'] as num?)?.toInt() ?? 0;
    final mediumThrow = (stats['mediumThrow'] as num?)?.toInt() ?? 0;
    final longThrow = (stats['longThrow'] as num?)?.toInt() ?? 0;

    final shortEffectiveness =
        ((stats['shortEffectivenessPercentage'] as num?)?.toDouble() ?? 0) *
            100;
    final mediumEffectiveness =
        ((stats['mediumEffectivenessPercentage'] as num?)?.toDouble() ?? 0) *
            100;
    final longEffectiveness =
        ((stats['longEffectivenessPercentage'] as num?)?.toDouble() ?? 0) * 100;

    final shortAccuracy =
        ((stats['shortAccuracyPercentage'] as num?)?.toDouble() ?? 0) * 100;
    final mediumAccuracy =
        ((stats['mediumAccuracyPercentage'] as num?)?.toDouble() ?? 0) * 100;
    final longAccuracy =
        ((stats['longAccuracyPercentage'] as num?)?.toDouble() ?? 0) * 100;

    final shortThrowAccuracy =
        (stats['shortThrowAccuracy'] as num?)?.toDouble() ?? 0;
    final mediumThrowAccuracy =
        (stats['mediumThrowAccuracy'] as num?)?.toDouble() ?? 0;
    final longThrowAccuracy =
        (stats['longThrowAccuracy'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header del atleta ─────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.actionPrimaryActive],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary20,
                  child: Text(
                    _getInitials(athleteName),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    athleteName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalThrows tiros',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Indicadores principales ──────────────────
                Row(
                  children: [
                    Expanded(
                      child: _circularIndicator(
                        'Efectividad',
                        effectiveness,
                        AppColors.primary,
                        AppColors.primary10,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _circularIndicator(
                        'Precisión',
                        accuracy,
                        AppColors.accent5,
                        AppColors.accent5x25,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Tiros efectivos vs fallidos ──────────────
                _buildThrowsSummaryRow(effectiveThrow, failedThrow),
                const SizedBox(height: 20),

                // ── Rendimiento por distancia ────────────────
                const Text(
                  'Rendimiento por Distancia',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDistanceStatRow(
                  'Corta',
                  shortThrow,
                  shortEffectiveness,
                  shortAccuracy,
                  shortThrowAccuracy,
                  AppColors.success,
                ),
                const SizedBox(height: 10),
                _buildDistanceStatRow(
                  'Media',
                  mediumThrow,
                  mediumEffectiveness,
                  mediumAccuracy,
                  mediumThrowAccuracy,
                  AppColors.warning,
                ),
                const SizedBox(height: 10),
                _buildDistanceStatRow(
                  'Larga',
                  longThrow,
                  longEffectiveness,
                  longAccuracy,
                  longThrowAccuracy,
                  AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // WIDGETS DE INDICADORES
  // ════════════════════════════════════════════════════════════════════

  Widget _circularIndicator(
      String label, double percentage, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 8,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThrowsSummaryRow(int effective, int failed) {
    final total = effective + failed;
    final effectivePercent = total > 0 ? effective / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral9,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _throwCountChip(
                  Icons.check_circle_rounded,
                  'Efectivos',
                  effective,
                  AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.neutral7,
              ),
              Expanded(
                child: _throwCountChip(
                  Icons.cancel_rounded,
                  'Fallidos',
                  failed,
                  AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: effectivePercent,
              minHeight: 8,
              backgroundColor: AppColors.errorBg,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  Widget _throwCountChip(IconData icon, String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistanceStatRow(
    String label,
    int throws,
    double effectiveness,
    double accuracy,
    double throwAccuracy,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Distancia $label',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$throws tiros',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de efectividad
          Row(
            children: [
              const SizedBox(
                width: 75,
                child: Text(
                  'Efectividad',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: effectiveness / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.neutral8,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                child: Text(
                  '${effectiveness.toStringAsFixed(1)}%',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Barra de precisión
          Row(
            children: [
              const SizedBox(
                width: 75,
                child: Text(
                  'Precisión',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: accuracy / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.neutral8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        color.withValues(alpha: 0.7)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                child: Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          if (throwAccuracy > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const SizedBox(width: 75),
                Expanded(
                  child: Text(
                    'Puntaje prom: ${throwAccuracy.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // SECCIÓN DE TIROS (desde GetEvaluationDetails)
  // ════════════════════════════════════════════════════════════════════

  Widget _buildThrowsSection(Map<String, dynamic> details) {
    final throws = details['throws'] as List<dynamic>? ?? [];

    if (throws.isEmpty) return const SizedBox.shrink();

    // Agrupar por atleta
    final Map<String, List<Map<String, dynamic>>> throwsByAthlete = {};
    for (final t in throws) {
      final data = t as Map<String, dynamic>;
      final name = data['athleteName'] ?? 'Atleta';
      throwsByAthlete.putIfAbsent(name, () => []).add(data);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Detalle de Lanzamientos'),
        const SizedBox(height: 12),
        ...throwsByAthlete.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                // Header del atleta
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.secondary,
                        child: Text(
                          _getInitials(entry.key),
                          style: const TextStyle(
                            color: AppColors.actionSecondaryInverted,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${entry.value.length} tiros',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.neutral8, height: 1),
                // Tabla de tiros
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                  child: _buildThrowsTable(entry.value),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // TABLA DE TIROS
  // ════════════════════════════════════════════════════════════════════

  Widget _buildThrowsTable(List<dynamic> throws) {
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(color: AppColors.neutral8, width: 1),
      ),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.2),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(6),
          ),
          children: const [
            _TableHeader('Cajón'),
            _TableHeader('Tiro'),
            _TableHeader('Distancia'),
            _TableHeader('Score'),
            _TableHeader('Estado'),
          ],
        ),
        // Rows
        ...throws.map((t) {
          final throwData = t as Map<String, dynamic>;
          final score = throwData['scoreObtained'];
          final status = throwData['status'];
          return TableRow(
            children: [
              _TableCell('${throwData['boxNumber'] ?? '-'}'),
              _TableCell('${throwData['throwOrder'] ?? '-'}'),
              _TableCell('${throwData['targetDistance'] ?? '-'}'),
              _TableCell(
                '${score ?? '-'}',
                color: _getScoreColor(score),
              ),
              _TableCell(
                status == true ? '✓' : '✗',
                color: status == true ? AppColors.success : AppColors.error,
              ),
            ],
          );
        }),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // ESTADOS VACÍO Y ERROR
  // ════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.bar_chart_outlined,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin evaluaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aún no hay evaluaciones para este equipo.\nRealiza una evaluación para ver las estadísticas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/evaluations'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nueva Evaluación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  Color _getScoreColor(dynamic score) {
    if (score == null) return AppColors.textPrimary;
    final val = double.tryParse('$score') ?? 0;
    if (val >= 4) return AppColors.success;
    if (val >= 2) return AppColors.warning;
    return AppColors.error;
  }
}

// ══════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES PARA TABLA
// ══════════════════════════════════════════════════════════════════════

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final Color? color;
  const _TableCell(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
          color: color ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
