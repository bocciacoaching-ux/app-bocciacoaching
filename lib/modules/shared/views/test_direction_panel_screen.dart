import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/direction_test_provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/direction_target_widget.dart';
import '../../../shared/widgets/statistics_panel.dart';
import '../../../data/models/athlete.dart';

class TestDirectionPanelScreen extends StatefulWidget {
  const TestDirectionPanelScreen({super.key});

  @override
  State<TestDirectionPanelScreen> createState() =>
      _TestDirectionPanelScreenState();
}

class _TestDirectionPanelScreenState extends State<TestDirectionPanelScreen> {
  final TextEditingController _athleteSearchController =
      TextEditingController();
  final TextEditingController _evalNameController =
      TextEditingController(text: 'Evaluación de Dirección');
  final GlobalKey<DirectionTargetWidgetState> _targetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<DirectionTestProvider>(
      builder: (context, provider, child) {
        if (provider.assessDirectionId == null) {
          return _buildSetupScreen(context, provider);
        }
        return _buildEvaluationScreen(context, provider);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SETUP SCREEN – Select athletes & start
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSetupScreen(
      BuildContext context, DirectionTestProvider provider) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Test de Dirección - Inicio',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Configurar Nueva Evaluación',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral1,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _evalNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Evaluación',
                  filled: true,
                  fillColor: AppColors.neutral9,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Seleccionar Atletas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral2,
                ),
              ),
              const SizedBox(height: 12),
              _buildAthleteSearch(provider),
              const SizedBox(height: 16),
              if (provider.selectedAthletes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Agrega al menos un atleta para comenzar',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: provider.selectedAthletes
                    .map<Widget>(
                      (athlete) => InputChip(
                        label: Text(athlete.name),
                        onDeleted: () => provider.removeAthlete(athlete.id),
                        backgroundColor: AppColors.infoBg,
                        labelStyle:
                            const TextStyle(color: AppColors.primary),
                        deleteIconColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: provider.selectedAthletes.isEmpty ||
                        _evalNameController.text.isEmpty ||
                        provider.isLoading
                    ? null
                    : () => _startNewEvaluation(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'INICIAR EVALUACIÓN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  START NEW EVALUATION
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _startNewEvaluation(
    BuildContext context,
    DirectionTestProvider provider,
  ) async {
    final sessionProvider = context.read<SessionProvider>();
    final teamProvider = context.read<TeamProvider>();

    final coachId = sessionProvider.session?.userId ?? 1;
    final teamId = teamProvider.selectedTeam?.teamId ?? 1;

    try {
      await provider.startNewEvaluation(
        _evalNameController.text,
        teamId,
        coachId,
      );
    } catch (_) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Iniciando en modo local (API no disponible)'),
          ),
        );
      }
    }
  }

  Widget _buildAthleteSearch(DirectionTestProvider provider) {
    return TextField(
      controller: _athleteSearchController,
      decoration: InputDecoration(
        hintText: 'Escribe un nombre y presiona el "+" o Enter',
        prefixIcon: const Icon(Icons.person_add),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.primary),
          onPressed: () {
            if (_athleteSearchController.text.isNotEmpty) {
              provider.addAthlete(
                Athlete(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: _athleteSearchController.text,
                ),
              );
              _athleteSearchController.clear();
            }
          },
        ),
        filled: true,
        fillColor: AppColors.neutral9,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          provider.addAthlete(
            Athlete(
              id: DateTime.now().millisecondsSinceEpoch,
              name: value,
            ),
          );
          _athleteSearchController.clear();
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  EVALUATION SCREEN – Court + controls
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildEvaluationScreen(
    BuildContext context,
    DirectionTestProvider provider,
  ) {
    final config = provider.currentShotConfig;
    if (config == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final progressPct = provider.currentShotNumber / provider.totalShots;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evaluación de Dirección',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Tiro ${provider.currentShotNumber} de ${provider.totalShots}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Progress percentage
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '${(progressPct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          // Stats drawer toggle
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: 'Estadísticas',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
        backgroundColor: AppColors.surface,
        elevation: 0.5,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            return Row(
              children: [
                Expanded(
                  flex: isWide ? 2 : 1,
                  child: Column(
                    children: [
                      // Progress bar
                      LinearProgressIndicator(
                        value: progressPct,
                        backgroundColor: AppColors.neutral8,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 5,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            16,
                            16,
                            16 + MediaQuery.of(context).padding.bottom,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Direction court ──
                              LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final targetSize =
                                      (innerConstraints.maxWidth * 0.92)
                                          .clamp(200.0, 420.0);
                                  return Column(
                                    children: [
                                      DirectionTargetWidget(
                                        key: _targetKey,
                                        size: targetSize,
                                        selection:
                                            provider.currentSelection,
                                        onTargetTap: provider.setSelection,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: targetSize,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.neutral2,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'VISTA DEL ATLETA',
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              // ── Shot info card ──
                              _buildShotInfoCard(provider, config),

                              const SizedBox(height: 20),

                              // ── Causa y observaciones ──
                              Row(
                                children: [
                                  const Text(
                                    'Causa y observaciones',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Text(
                                    '*',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // ── Deviation chips ──
                              _buildDeviationChips(provider),

                              const SizedBox(height: 16),

                              // ── Observations text field ──
                              TextField(
                                controller:
                                    provider.observationsController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'Agrega tus comentarios...',
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.neutral7,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.neutral7,
                                    ),
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),

                              const SizedBox(height: 28),

                              // ── Navigation buttons ──
                              _buildNavigationButtons(
                                  provider, config),

                              // ── Current box label ──
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Cajón n° ${config.boxNumber}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Side statistics panel for wide screens
                if (isWide) const VerticalDivider(width: 1),
                if (isWide)
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: AppColors.surface,
                      child: StatisticsPanel(stats: provider.stats),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      endDrawer: MediaQuery.of(context).size.width <= 900
          ? Drawer(
              width: 400,
              child: StatisticsPanel(stats: provider.stats),
            )
          : null,
    );
  }

  // ── Shot information card ──────────────────────────────────────────

  Widget _buildShotInfoCard(DirectionTestProvider provider, config) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral7),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Zone number badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${provider.currentScore ?? '-'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Distance badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.neutral8,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.straighten, size: 16, color: AppColors.neutral3),
                const SizedBox(width: 6),
                Text(
                  '${config.targetDistance.toStringAsFixed(1)}m',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Zone info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zona n°${provider.currentScore ?? '-'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Distancia: ${config.targetDistance.toStringAsFixed(1)} m.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Score circle
          if (provider.currentScore != null)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _zoneColor(provider.currentScore!),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _zoneColor(provider.currentScore!)
                        .withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${provider.currentScore}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Deviation chips ────────────────────────────────────────────────

  Widget _buildDeviationChips(DirectionTestProvider provider) {
    return Row(
      children: [
        // Desviación izquierda
        Expanded(
          child: GestureDetector(
            onTap: provider.toggleDeviatedLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: provider.deviatedLeft
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: provider.deviatedLeft
                      ? AppColors.primary
                      : AppColors.neutral7,
                  width: provider.deviatedLeft ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (provider.deviatedLeft)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      'Desviación izquierda',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: provider.deviatedLeft
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Desviación derecha
        Expanded(
          child: GestureDetector(
            onTap: provider.toggleDeviatedRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: provider.deviatedRight
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: provider.deviatedRight
                      ? AppColors.primary
                      : AppColors.neutral7,
                  width: provider.deviatedRight ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (provider.deviatedRight)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.white,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      'Desviación derecha',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: provider.deviatedRight
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Navigation buttons ─────────────────────────────────────────────

  Widget _buildNavigationButtons(
      DirectionTestProvider provider, config) {
    return Row(
      children: [
        // Previous
        Expanded(
          child: Column(
            children: [
              if (config.prevBox != null)
                Text(
                  'Cajón n° ${config.prevBox}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: provider.currentShotNumber > 1
                    ? () => provider.previousShot()
                    : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: AppColors.neutral7),
                  foregroundColor: AppColors.neutral4,
                ),
                child: const Text('Anterior'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Next / Finish
        Expanded(
          child: Column(
            children: [
              if (config.nextBox != null)
                Text(
                  'Cajón n° ${config.nextBox}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              if (config.nextBox == null) const SizedBox(height: 14),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: provider.canGoNext && !provider.isLoading
                    ? () {
                        // Validate: at least one deviation must be selected
                        if (!provider.deviatedLeft &&
                            !provider.deviatedRight) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Selecciona una causa de desviación.',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        provider.nextShot();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        provider.currentShotNumber ==
                                provider.totalShots
                            ? 'Finalizar'
                            : 'Siguiente',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helper methods ─────────────────────────────────────────────────

  Color _zoneColor(int score) {
    switch (score) {
      case 0:
        return const Color(0xFFEF4444);
      case 1:
        return const Color(0xFFF97316);
      case 2:
        return const Color(0xFFFBBF24);
      case 3:
        return const Color(0xFF38BDF8);
      case 4:
        return const Color(0xFF34D399);
      case 5:
        return const Color(0xFF22C55E);
      default:
        return AppColors.neutral5;
    }
  }
}
