import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/direction_test_provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/direction_target_widget.dart';
import '../../../shared/widgets/statistics_panel.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../data/models/athlete.dart';
import '../../../data/models/team_member.dart';

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
  //  START NEW EVALUATION
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _startNewEvaluation(
    BuildContext context,
    DirectionTestProvider provider,
  ) async {
    final sessionProvider = context.read<SessionProvider>();
    final teamProvider = context.read<TeamProvider>();

    final coachId = sessionProvider.session?.userId ?? '';
    final teamId = teamProvider.selectedTeam?.teamId ?? '';

    // ── 1) Validar si ya existe una evaluación de dirección pendiente ──
    final activeEval = await provider.checkForActiveEvaluation(teamId, coachId);
    if (!mounted || !context.mounted) return;

    if (activeEval != null) {
      final shouldResume = await AppDialog.warning(
        context,
        title: 'Evaluación pendiente',
        message:
            'Ya existe una evaluación de control de dirección pendiente para este equipo. '
            '¿Deseas continuar con la evaluación pendiente? '
            'No es posible crear una nueva mientras exista una pendiente; '
            'si deseas iniciar otra, primero debes descartar la activa desde la pantalla de evaluaciones.',
        confirmLabel: 'Continuar pendiente',
        cancelLabel: 'Cancelar',
        icon: Icons.assignment_late_outlined,
      );
      if (!mounted || !context.mounted) return;

      if (shouldResume) {
        await provider.resumeEvaluation(activeEval);
      }
      // Si el usuario cancela, no hacemos nada (no se crea nueva).
      return;
    }

    // ── 2) No hay pendiente → crear la nueva evaluación ──────────────
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
    final members = context.watch<TeamProvider>().members;

    // Si no hay miembros cargados, mostrar aviso en lugar del buscador
    if (members.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withAlpha(80)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No hay atletas registrados en el equipo. Agrega atletas al equipo antes de crear una evaluación.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.warning, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    // Solo mostrar atletas que aún no fueron seleccionados
    final available = members
        .where((m) => !provider.selectedAthletes.any((a) => a.id == m.userId))
        .toList();

    return Autocomplete<TeamMember>(
      displayStringForOption: (m) => m.fullName,
      optionsBuilder: (textValue) {
        if (textValue.text.isEmpty) return available;
        return available.where((m) =>
            m.fullName.toLowerCase().contains(textValue.text.toLowerCase()));
      },
      onSelected: (TeamMember selected) {
        provider.addAthlete(
          Athlete(id: selected.userId, name: selected.fullName),
        );
        _athleteSearchController.clear();
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        _athleteSearchController
          ..text = controller.text
          ..selection = controller.selection;
        controller.addListener(() {
          _athleteSearchController.text = controller.text;
        });
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Buscar atleta del equipo…',
            prefixIcon: const Icon(Icons.person_search_outlined),
            filled: true,
            fillColor: AppColors.neutral9,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: AppColors.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final member = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.infoBg,
                      child: Text(
                        member.fullName.isNotEmpty
                            ? member.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                    title: Text(member.fullName,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: member.category != null
                        ? Text(member.category!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary))
                        : null,
                    onTap: () => onSelected(member),
                  );
                },
              ),
            ),
          ),
        );
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

                              // ── Cause chips (Dirección / Fuerza / Trayectoria / Cadencia) ──
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Zona chip
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.neutral8,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Zona ${config.boxNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Distance chip
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.neutral8,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.straighten,
                      size: 15, color: AppColors.neutral3),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${config.targetDistance.toStringAsFixed(1)} m.',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Puntuación label + circle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Puntuación:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: provider.currentScore != null
                      ? _zoneColor(provider.currentScore!)
                      : AppColors.neutral6,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    provider.currentScore != null
                        ? '${provider.currentScore}'
                        : '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Cause chips (igual que la prueba de fuerza) ────────────────────

  Widget _buildCauseChips(DirectionTestProvider provider) {
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

  Widget _buildNavigationButtons(DirectionTestProvider provider, config) {
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
                        _targetKey.currentState?.reset();
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
