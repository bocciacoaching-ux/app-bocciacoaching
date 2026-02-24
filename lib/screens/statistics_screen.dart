import 'dart:convert';
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
    final description =
        evaluation['description'] ?? 'Evaluación #$id';
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

    final stats = statsProvider.evaluationStats;
    final details = statsProvider.evaluationDetails;

    if (stats == null && details == null) {
      return _buildErrorState('No hay datos disponibles para esta evaluación.',
          onRetry: () => statsProvider
              .fetchFullEvaluationData(statsProvider.selectedEvaluationId!));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Resumen general ──────────────────────────────
          if (stats != null) ...[
            _sectionTitle('Resumen General'),
            const SizedBox(height: 12),
            _buildStatsOverviewGrid(stats),
            const SizedBox(height: 24),
          ],

          // ── Estadísticas por distancia ───────────────────
          if (stats != null) ...[
            _sectionTitle('Rendimiento por Distancia'),
            const SizedBox(height: 12),
            _buildDistanceCards(stats),
            const SizedBox(height: 24),
          ],

          // ── Detalles de tiros ────────────────────────────
          if (details != null) ...[
            _sectionTitle('Detalles de la Evaluación'),
            const SizedBox(height: 12),
            _buildDetailsSection(details),
            const SizedBox(height: 24),
          ],

          // ── Datos crudos (debug/fallback) ────────────────
          if (stats != null) ...[
            _sectionTitle('Datos Completos'),
            const SizedBox(height: 12),
            _buildRawDataCard('Estadísticas', stats),
          ],
          if (details != null) ...[
            const SizedBox(height: 12),
            _buildRawDataCard('Detalles', details),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // WIDGETS DE ESTADÍSTICAS
  // ════════════════════════════════════════════════════════════════════

  Widget _buildStatsOverviewGrid(Map<String, dynamic> stats) {
    // Extraer datos - adaptable a la estructura de la API
    final effectiveness = _extractDouble(stats, 'generalEffectiveness') ??
        _extractDouble(stats, 'effectiveness') ??
        _extractDouble(stats, 'efectividad');
    final precision = _extractDouble(stats, 'precision') ??
        _extractDouble(stats, 'precisión');
    final totalThrows = _extractInt(stats, 'totalThrows') ??
        _extractInt(stats, 'totalTiros') ??
        _extractInt(stats, 'total');
    final effectiveThrows = _extractInt(stats, 'effectiveThrows') ??
        _extractInt(stats, 'tirosEfectivos') ??
        _extractInt(stats, 'hits');
    final failedThrows = _extractInt(stats, 'failedThrows') ??
        _extractInt(stats, 'tirosFallidos') ??
        _extractInt(stats, 'misses');
    final avgScore = _extractDouble(stats, 'averageScore') ??
        _extractDouble(stats, 'promedioScore') ??
        _extractDouble(stats, 'avgScore');

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        if (effectiveness != null)
          _statCard(
            icon: Icons.trending_up_rounded,
            label: 'Efectividad',
            value: '${effectiveness.toStringAsFixed(1)}%',
            color: AppColors.primary,
            bgColor: AppColors.primary10,
          ),
        if (precision != null)
          _statCard(
            icon: Icons.gps_fixed_rounded,
            label: 'Precisión',
            value: '${precision.toStringAsFixed(1)}%',
            color: AppColors.accent5,
            bgColor: AppColors.accent5x25,
          ),
        if (totalThrows != null)
          _statCard(
            icon: Icons.sports_handball_rounded,
            label: 'Total Tiros',
            value: '$totalThrows',
            color: AppColors.accent3,
            bgColor: AppColors.accent3x23,
          ),
        if (effectiveThrows != null)
          _statCard(
            icon: Icons.check_circle_outline,
            label: 'Tiros Efectivos',
            value: '$effectiveThrows',
            color: AppColors.success,
            bgColor: AppColors.successBg,
          ),
        if (failedThrows != null)
          _statCard(
            icon: Icons.cancel_outlined,
            label: 'Tiros Fallidos',
            value: '$failedThrows',
            color: AppColors.error,
            bgColor: AppColors.errorBg,
          ),
        if (avgScore != null)
          _statCard(
            icon: Icons.star_outline_rounded,
            label: 'Puntuación Prom.',
            value: avgScore.toStringAsFixed(2),
            color: AppColors.accent2,
            bgColor: AppColors.accent2x10,
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
            style: const TextStyle(
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

  Widget _buildDistanceCards(Map<String, dynamic> stats) {
    // Intentar extraer datos de distancia de la respuesta
    final shortStats = stats['shortStats'] ?? stats['shortDistance'];
    final mediumStats = stats['mediumStats'] ?? stats['mediumDistance'];
    final longStats = stats['longStats'] ?? stats['longDistance'];

    if (shortStats == null && mediumStats == null && longStats == null) {
      // Si no hay estructura de distancia, buscar en listas
      final distances = stats['distances'] ?? stats['distanceStats'];
      if (distances is List && distances.isNotEmpty) {
        return Column(
          children: distances
              .map<Widget>((d) => _buildDistanceRow(
                    d as Map<String, dynamic>,
                    d['label'] ?? d['distance'] ?? 'Distancia',
                    AppColors.primary,
                  ))
              .toList(),
        );
      }

      return _buildNoDataCard('No hay datos de distancia disponibles.');
    }

    return Column(
      children: [
        if (shortStats != null)
          _buildDistanceRow(
            shortStats is Map<String, dynamic> ? shortStats : {},
            'Corta',
            AppColors.success,
          ),
        if (mediumStats != null)
          _buildDistanceRow(
            mediumStats is Map<String, dynamic> ? mediumStats : {},
            'Media',
            AppColors.warning,
          ),
        if (longStats != null)
          _buildDistanceRow(
            longStats is Map<String, dynamic> ? longStats : {},
            'Larga',
            AppColors.error,
          ),
      ],
    );
  }

  Widget _buildDistanceRow(
      Map<String, dynamic> data, String label, Color color) {
    final hits = _extractInt(data, 'hits') ?? _extractInt(data, 'aciertos') ?? 0;
    final total = _extractInt(data, 'total') ?? _extractInt(data, 'totalTiros') ?? 0;
    final effectiveness = total > 0 ? (hits / total) * 100 : 0.0;
    final totalPoints =
        _extractInt(data, 'totalPoints') ?? _extractInt(data, 'puntos') ?? 0;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Distancia $label',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${effectiveness.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: effectiveness / 100,
              minHeight: 6,
              backgroundColor: AppColors.neutral8,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat('Aciertos', '$hits/$total'),
              _miniStat('Puntos', '$totalPoints'),
              _miniStat('Efect.', '${effectiveness.toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> details) {
    // Intentar extraer atletas/detalles de tiros
    final athletes =
        details['athletes'] ?? details['atletas'] ?? details['data'];

    if (athletes is List && athletes.isNotEmpty) {
      return Column(
        children: athletes.map<Widget>((athlete) {
          final athleteData = athlete as Map<String, dynamic>;
          return _buildAthleteDetailCard(athleteData);
        }).toList(),
      );
    }

    // Si los detalles tienen tiros directamente
    final throws =
        details['throws'] ?? details['tiros'] ?? details['details'];
    if (throws is List && throws.isNotEmpty) {
      return _buildThrowsTable(throws);
    }

    // Mostrar los datos disponibles como tarjeta informativa
    return _buildInfoCard(details);
  }

  Widget _buildAthleteDetailCard(Map<String, dynamic> athleteData) {
    final name = athleteData['athleteName'] ??
        athleteData['nombre'] ??
        athleteData['name'] ??
        'Atleta';
    final throws = athleteData['throws'] ??
        athleteData['tiros'] ??
        athleteData['details'];

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.secondary,
                child: Text(
                  _getInitials(name),
                  style: const TextStyle(
                    color: AppColors.actionSecondaryInverted,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (throws is List && throws.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.neutral8),
            const SizedBox(height: 8),
            _buildThrowsTable(throws),
          ],
        ],
      ),
    );
  }

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
          ],
        ),
        // Rows
        ...throws.map((t) {
          final throwData = t as Map<String, dynamic>;
          return TableRow(
            children: [
              _TableCell(
                  '${throwData['boxNumber'] ?? throwData['cajon'] ?? '-'}'),
              _TableCell(
                  '${throwData['throwOrder'] ?? throwData['orden'] ?? '-'}'),
              _TableCell(
                  '${throwData['targetDistance'] ?? throwData['distancia'] ?? '-'}'),
              _TableCell(
                '${throwData['scoreObtained'] ?? throwData['score'] ?? '-'}',
                color: _getScoreColor(throwData['scoreObtained'] ??
                    throwData['score']),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> data) {
    final entries = data.entries.where((e) =>
        e.value != null &&
        e.value is! List &&
        e.value is! Map);

    if (entries.isEmpty) {
      return _buildNoDataCard('No hay detalles disponibles.');
    }

    return Container(
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
        children: entries
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _formatKey(e.key),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          '${e.value}',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRawDataCard(String title, Map<String, dynamic> data) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.neutral8),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.neutral8),
      ),
      backgroundColor: AppColors.surface,
      collapsedBackgroundColor: AppColors.surface,
      title: Row(
        children: [
          Icon(Icons.data_object, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.neutral9,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            _prettyJson(data),
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: AppColors.textPrimary,
            ),
          ),
        ),
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
              onPressed: () =>
                  Navigator.of(context).pushNamed('/evaluations'),
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

  Widget _buildNoDataCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.neutral5, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
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

  String _formatKey(String key) {
    // camelCase → Title Case
    final result = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  String _prettyJson(Map<String, dynamic> json) {
    final encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  double? _extractDouble(Map<String, dynamic> map, String key) {
    final val = map[key];
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }

  int? _extractInt(Map<String, dynamic> map, String key) {
    final val = map[key];
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val);
    return null;
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
