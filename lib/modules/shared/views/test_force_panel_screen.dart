import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/force_test_provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/force_target_widget.dart';
import '../../../shared/widgets/statistics_panel.dart';
import '../../../data/models/athlete.dart';

class TestForcePanelScreen extends StatefulWidget {
  const TestForcePanelScreen({super.key});

  @override
  State<TestForcePanelScreen> createState() => _TestForcePanelScreenState();
}

class _TestForcePanelScreenState extends State<TestForcePanelScreen> {
  final TextEditingController _athleteSearchController = TextEditingController();
  final TextEditingController _evalNameController =
      TextEditingController(text: 'Evaluación de Prueba');
  final GlobalKey<ForceTargetWidgetState> _targetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<ForceTestProvider>(
      builder: (context, provider, child) {
        if (provider.assessStrengthId == null) {
          return _buildSetupScreen(context, provider);
        }
        return _buildEvaluationScreen(context, provider);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SETUP SCREEN – Select athletes & start
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSetupScreen(BuildContext context, ForceTestProvider provider) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Test de Fuerza - Inicio',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
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
                      labelStyle: const TextStyle(color: AppColors.primary),
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
  //  ACTIVE EVALUATION CHECK – Validate before creating
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _startNewEvaluation(
    BuildContext context,
    ForceTestProvider provider,
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

  Widget _buildAthleteSearch(ForceTestProvider provider) {
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
  //  EVALUATION SCREEN – Target + controls
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildEvaluationScreen(
    BuildContext context,
    ForceTestProvider provider,
  ) {
    final config = provider.currentShotConfig;
    if (config == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final progressPct =
        provider.currentShotNumber / provider.totalShots;

    final athleteName = provider.currentAthleteName;
    final evalTitle = athleteName.isNotEmpty
        ? 'Evaluación de Fuerza de $athleteName'
        : 'Evaluación de Fuerza';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evalTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Tiro ${provider.currentShotNumber} de ${provider.totalShots}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
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
                            // ── Target + VISTA DEL ATLETA ──
                            LayoutBuilder(
                              builder: (context, innerConstraints) {
                                final targetSize =
                                    (innerConstraints.maxWidth * 0.92)
                                        .clamp(200.0, 420.0);
                                return Column(
                                  children: [
                                    ForceTargetWidget(
                                      key: _targetKey,
                                      size: targetSize,
                                      selection: provider.currentSelection,
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

                            // ── Cause chips ──
                            _buildCauseChips(provider),

                            const SizedBox(height: 16),

                            // ── Observations text field ──
                            TextField(
                              controller: provider.observationsController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Agrega tus comentarios...',
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.neutral7,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.neutral7,
                                  ),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),

                            const SizedBox(height: 28),

                            // ── Navigation buttons ──
                            _buildNavigationButtons(provider, config),

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

  Widget _buildShotInfoCard(ForceTestProvider provider, config) {
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
                color: _scoreColor(provider.currentScore!),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _scoreColor(provider.currentScore!)
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

  // ── Cause chips ─────────────────────────────────────────────────

  Widget _buildCauseChips(ForceTestProvider provider) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildSingleCauseChip(
          label: 'Dirección',
          isSelected: provider.causeDirection,
          onTap: provider.toggleCauseDirection,
        ),
        _buildSingleCauseChip(
          label: 'Fuerza',
          isSelected: provider.causeForce,
          onTap: provider.toggleCauseForce,
        ),
        _buildSingleCauseChip(
          label: 'Trayectoria',
          isSelected: provider.causeTrajectory,
          onTap: provider.toggleCauseTrajectory,
        ),
        _buildSingleCauseChip(
          label: 'Cadencia',
          isSelected: provider.causeCadence,
          onTap: provider.toggleCauseCadence,
        ),
      ],
    );
  }

  Widget _buildSingleCauseChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral7,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation buttons ─────────────────────────────────────────────

  Widget _buildNavigationButtons(ForceTestProvider provider, config) {
    return Row(
      children: [
        // Previous
        Expanded(
          child: OutlinedButton(
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
        ),
        const SizedBox(width: 16),
        // Next / Finish
        Expanded(
          child: ElevatedButton(
            onPressed:
                provider.canGoNext && !provider.isLoading
                    ? () {
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
                    provider.currentShotNumber == provider.totalShots
                        ? 'Finalizar'
                        : 'Siguiente',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Helper methods ─────────────────────────────────────────────────

  Color _scoreColor(int score) {
    switch (score) {
      case 0:
        return const Color(0xFFEF4444); // red
      case 1:
        return const Color(0xFFF97316); // orange
      case 2:
        return const Color(0xFFFBBF24); // amber
      case 3:
        return const Color(0xFF38BDF8); // sky
      case 4:
        return const Color(0xFF34D399); // emerald
      case 5:
        return const Color(0xFF22C55E); // green
      default:
        return AppColors.neutral5;
    }
  }
}
