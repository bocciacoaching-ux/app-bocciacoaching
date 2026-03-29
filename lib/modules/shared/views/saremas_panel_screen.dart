import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/saremas_provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/athlete.dart';
import '../widgets/boccia_court_painter.dart';

/// Pantalla completa de evaluación SAREMAS+.
///
/// Muestra primero la pantalla de setup (nombre + atletas) y, una vez iniciada
/// la evaluación, presenta la pantalla de punteo lanzamiento a lanzamiento.
class SaremasPanelScreen extends StatefulWidget {
  const SaremasPanelScreen({super.key});

  @override
  State<SaremasPanelScreen> createState() => _SaremasPanelScreenState();
}

class _SaremasPanelScreenState extends State<SaremasPanelScreen> {
  final TextEditingController _athleteSearchController =
      TextEditingController();
  final TextEditingController _evalNameController =
      TextEditingController(text: 'Evaluación SAREMAS+');

  @override
  Widget build(BuildContext context) {
    return Consumer<SaremasProvider>(
      builder: (context, provider, _) {
        if (provider.saremasEvalId == null) {
          return _buildSetupScreen(context, provider);
        }
        if (provider.isEvaluationComplete) {
          return _buildCompletedScreen(context, provider);
        }
        return _buildEvaluationScreen(context, provider);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SETUP SCREEN
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSetupScreen(BuildContext context, SaremasProvider provider) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'SAREMAS+ - Inicio',
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
              const SizedBox(height: 8),
              const Text(
                'SAREMAS+ — 28 lanzamientos en 4 diagonales',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
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

  Widget _buildAthleteSearch(SaremasProvider provider) {
    return TextField(
      controller: _athleteSearchController,
      decoration: InputDecoration(
        hintText: 'Escribe un nombre y presiona "+" o Enter',
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

  Future<void> _startNewEvaluation(
    BuildContext context,
    SaremasProvider provider,
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

  // ═══════════════════════════════════════════════════════════════════
  //  EVALUATION SCREEN — Punteo de cada lanzamiento
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildEvaluationScreen(
    BuildContext context,
    SaremasProvider provider,
  ) {
    final diagonal = provider.currentDiagonal;
    final isDiagonalRoja = diagonal == 'Roja';
    final diagonalColor =
        isDiagonalRoja ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);
    final diagonalBgColor = isDiagonalRoja
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFDBEAFE);

    final athleteName = provider.currentAthleteName;
    final evalTitle = athleteName.isNotEmpty
        ? 'SAREMAS+ — $athleteName'
        : 'SAREMAS+';

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
              'Lanzamiento ${provider.currentThrowNumber} de ${provider.totalShotsCount}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '${(provider.progress * 100).toStringAsFixed(0)}%',
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
              tooltip: 'Estadísticas',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
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
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      endDrawer: Drawer(
        width: 360,
        child: _buildSaremasStatsDrawer(provider),
      ),
      body: Column(
        children: [
          // ── Barra de progreso ────────────────────────────────────
          LinearProgressIndicator(
            value: provider.progress,
            backgroundColor: AppColors.neutral8,
            valueColor: AlwaysStoppedAnimation<Color>(diagonalColor),
            minHeight: 5,
          ),

          // ── Franja informativa de diagonal ─────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: diagonalBgColor,
              border: Border(
                bottom: BorderSide(
                  color: diagonalColor.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: diagonalColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Diagonal $diagonal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: diagonalColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: diagonalColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Bloque ${provider.currentBlock} de 4',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: diagonalColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Contenido principal scrollable ─────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Componente técnico (etiqueta fija) ──────────────
                  const Text(
                    'Componente Técnico',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.neutral1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildComponentBadge(provider),

                  // ── Botón de cancha para componente "Salida" ────
                  if (provider.isSalidaComponent) ...[
                    const SizedBox(height: 12),
                    _buildCourtButton(provider),
                  ],

                  const SizedBox(height: 24),

                  // ── Puntaje (0 – 5) ─────────────────────────────
                  const Text(
                    'Puntaje obtenido',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.neutral1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildScoreGrid(provider),

                  const SizedBox(height: 24),

                  // ── Tags de fallo ───────────────────────────────
                  Row(
                    children: [
                      const Text(
                        'Causa del fallo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.neutral1,
                        ),
                      ),
                      if (provider.currentScore != null &&
                          provider.currentScore! <= 2)
                        const Text(
                          ' *',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildCauseChips(provider),

                  const SizedBox(height: 24),

                  // ── Observación ─────────────────────────────────
                  Row(
                    children: [
                      const Text(
                        'Observación',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.neutral1,
                        ),
                      ),
                      if (provider.currentScore != null &&
                          provider.currentScore! <= 2)
                        const Text(
                          ' * (obligatoria)',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: provider.observationsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Agrega tus comentarios...',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.neutral7),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.neutral7),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 32),

                  // ── Botones de navegación ───────────────────────
                  _buildNavigationButtons(provider),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Etiqueta fija de componente técnico ───────────────────────────

  Widget _buildComponentBadge(SaremasProvider provider) {
    final component = provider.selectedComponent ?? '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral7),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sports_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              component,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Botón y resultado de cancha de boccia (Salida) ────────────────

  Widget _buildCourtButton(SaremasProvider provider) {
    final hasData = provider.estimatedDistance != null;
    final isDiagonalRoja = provider.currentDiagonal == 'Roja';
    final teamColor =
        isDiagonalRoja ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _openBocciaCourt(context, provider, teamColor),
          icon: Icon(
            hasData ? Icons.edit_location_alt : Icons.place,
            size: 20,
          ),
          label: Text(
            hasData
                ? 'Editar posición en cancha'
                : 'Marcar posición en cancha',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: hasData
                ? AppColors.success.withOpacity(0.1)
                : AppColors.infoBg,
            foregroundColor: hasData ? AppColors.success : AppColors.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: hasData
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.primary.withOpacity(0.3),
              ),
            ),
          ),
        ),
        if (hasData) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.straighten,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distancia estimada',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${provider.estimatedDistance!.toStringAsFixed(2)} m (${(provider.estimatedDistance! * 100).toStringAsFixed(1)} cm)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral1,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    provider.clearBallPositions();
                  },
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.neutral5,
                  tooltip: 'Borrar posiciones',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openBocciaCourt(
    BuildContext context,
    SaremasProvider provider,
    Color teamColor,
  ) async {
    // Preparar posiciones iniciales si ya existen
    Offset? initialWhite;
    Offset? initialColor;
    Offset? initialLaunch;
    if (provider.whiteBallX != null && provider.whiteBallY != null) {
      initialWhite = Offset(provider.whiteBallX!, provider.whiteBallY!);
    }
    if (provider.colorBallX != null && provider.colorBallY != null) {
      initialColor = Offset(provider.colorBallX!, provider.colorBallY!);
    }
    if (provider.launchPointX != null && provider.launchPointY != null) {
      initialLaunch = Offset(provider.launchPointX!, provider.launchPointY!);
    }

    // Determinar box de lanzamiento: Roja → Box 3, Azul → Box 4
    final launchBox = provider.currentDiagonal == 'Roja' ? 3 : 4;

    BocciaCourtResult? result;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // ── Handle ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral6,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // ── Título ──────────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sports_soccer,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Cancha de Boccia — Salida',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          color: AppColors.neutral4,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // ── Cancha ──────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: BocciaCourtWidget(
                        initialWhiteBall: initialWhite,
                        initialColorBall: initialColor,
                        initialLaunchPoint: initialLaunch,
                        teamBallColor: teamColor,
                        launchBox: launchBox,
                        onResult: (r) {
                          result = r;
                        },
                      ),
                    ),
                  ),
                  // ── Botón confirmar ─────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      12 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (result != null) {
                            provider.setBallPositions(
                              whiteBallX: result!.whiteBallPosition.dx,
                              whiteBallY: result!.whiteBallPosition.dy,
                              colorBallX: result!.colorBallPosition.dx,
                              colorBallY: result!.colorBallPosition.dy,
                              estimatedDistance: result!.edgeToEdgeDistance,
                              launchPointX: result!.launchPoint.dx,
                              launchPointY: result!.launchPoint.dy,
                              distanceToLaunchPoint:
                                  result!.launchToJackDistance,
                            );
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'CONFIRMAR POSICIONES',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Grid de puntaje (0 – 5) ───────────────────────────────────────

  Widget _buildScoreGrid(SaremasProvider provider) {
    return Row(
      children: List.generate(6, (index) {
        final isSelected = provider.currentScore == index;
        final color = _scoreColor(index);
        return Expanded(
          child: GestureDetector(
            onTap: () => provider.setScore(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.neutral7,
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.white : AppColors.neutral2,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Chips de causa de fallo ────────────────────────────────────────

  Widget _buildCauseChips(SaremasProvider provider) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildSingleCauseChip(
          label: 'Fuerza',
          isSelected: provider.tagFuerza,
          onTap: provider.toggleTagFuerza,
        ),
        _buildSingleCauseChip(
          label: 'Cadencia',
          isSelected: provider.tagCadencia,
          onTap: provider.toggleTagCadencia,
        ),
        _buildSingleCauseChip(
          label: 'Dirección',
          isSelected: provider.tagDireccion,
          onTap: provider.toggleTagDireccion,
        ),
        _buildSingleCauseChip(
          label: 'Trayectoria',
          isSelected: provider.tagTrayectoria,
          onTap: provider.toggleTagTrayectoria,
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

  // ── Botones de navegación ─────────────────────────────────────────

  Widget _buildNavigationButtons(SaremasProvider provider) {
    final isLast =
        provider.currentThrowNumber == provider.totalShotsCount;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: provider.currentThrowNumber > 1
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
        Expanded(
          child: ElevatedButton(
            onPressed:
                provider.canGoNext && !provider.isLoading ? () => provider.nextShot() : null,
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
                    isLast ? 'Finalizar' : 'Siguiente',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  COMPLETED SCREEN
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildCompletedScreen(
    BuildContext context,
    SaremasProvider provider,
  ) {
    final stats = provider.summaryStats;
    final total = stats['totalScore'] ?? 0;
    final maxPossible = stats['maxPossible'] ?? 140;
    final avg = stats['averageScore'] ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'SAREMAS+ — Resultados',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ── Icono de éxito ──────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Evaluación Completada!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Se completaron los 28 lanzamientos',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // ── Resumen estadístico ─────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neutral8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _statRow('Puntaje Total', '$total / $maxPossible'),
                    const Divider(height: 24),
                    _statRow('Promedio por tiro', avg.toStringAsFixed(2)),
                    const Divider(height: 24),
                    _statRow('Lanzamientos', '${stats['throwsCompleted']}'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Detalle por diagonal ────────────────────────────
              _buildDiagonalSummary(provider),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await provider.resetForNewEvaluation();
                    if (mounted) Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'VOLVER A EVALUACIONES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral1,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagonalSummary(SaremasProvider provider) {
    final throws = provider.completedThrows;
    final diagonals = [
      {'name': 'Diagonal Roja (Bloque 1)', 'from': 1, 'to': 7, 'color': const Color(0xFFEF4444)},
      {'name': 'Diagonal Azul (Bloque 2)', 'from': 8, 'to': 14, 'color': const Color(0xFF3B82F6)},
      {'name': 'Diagonal Roja (Bloque 3)', 'from': 15, 'to': 21, 'color': const Color(0xFFEF4444)},
      {'name': 'Diagonal Azul (Bloque 4)', 'from': 22, 'to': 28, 'color': const Color(0xFF3B82F6)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen por Diagonal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral1,
          ),
        ),
        const SizedBox(height: 12),
        ...diagonals.map((d) {
          final blockThrows = throws
              .where(
                  (t) => t.throwNumber >= (d['from'] as int) && t.throwNumber <= (d['to'] as int))
              .toList();
          final blockTotal =
              blockThrows.fold<int>(0, (s, t) => s + t.scoreObtained);
          final blockMax = 7 * 5;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (d['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: d['color'] as Color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    d['name'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral1,
                    ),
                  ),
                ),
                Text(
                  '$blockTotal / $blockMax',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: d['color'] as Color,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Statistics drawer ──────────────────────────────────────────────

  Widget _buildSaremasStatsDrawer(SaremasProvider provider) {
    final throws = provider.completedThrows;
    final topPadding = MediaQuery.of(context).padding.top;

    // Distribución de puntajes (0-5)
    final scoreDist = List.filled(6, 0);
    for (final t in throws) {
      if (t.scoreObtained >= 0 && t.scoreObtained <= 5) {
        scoreDist[t.scoreObtained]++;
      }
    }

    // Totales por diagonal (4 bloques)
    final blockTotals = List.filled(4, 0);
    final blockNames = [
      'D. Roja 1',
      'D. Azul 1',
      'D. Roja 2',
      'D. Azul 2',
    ];
    for (final t in throws) {
      final block = (t.throwNumber - 1) ~/ 7;
      if (block < 4) blockTotals[block] += t.scoreObtained;
    }

    // Tags más frecuentes
    final tagCount = <String, int>{};
    for (final t in throws) {
      for (final tag in t.failureTags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }

    final total = throws.fold<int>(0, (s, t) => s + t.scoreObtained);
    final maxPossible = throws.length * 5;
    final effectPct = maxPossible == 0 ? 0.0 : total / maxPossible;

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20 + topPadding, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado ──────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Estadísticas Parciales',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Efectividad general ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.neutral8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Puntaje Total',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$total / $maxPossible',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: effectPct,
                      minHeight: 8,
                      backgroundColor: AppColors.neutral8,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Efectividad',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${(effectPct * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Distribución de puntajes ─────────────────────────
            const Text(
              'Distribución de Puntajes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.neutral8),
              ),
              child: throws.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Sin datos aún',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : Column(
                      children: List.generate(6, (score) {
                        final count = scoreDist[score];
                        final pct = throws.isEmpty ? 0.0 : count / throws.length;
                        final color = _scoreColor(score);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    '$score',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 10,
                                    backgroundColor: AppColors.neutral8,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(color),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 24,
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.neutral2,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
            ),
            const SizedBox(height: 16),

            // ── Puntaje por bloque / diagonal ────────────────────
            const Text(
              'Puntaje por Diagonal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.neutral8),
              ),
              child: Column(
                children: List.generate(4, (i) {
                  final blockMax = 7 * 5;
                  final blockPct =
                      blockMax == 0 ? 0.0 : blockTotals[i] / blockMax;
                  final isRoja = i.isEven;
                  final color = isRoja
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF3B82F6);
                  return Padding(
                    padding: EdgeInsets.only(bottom: i < 3 ? 12 : 0),
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
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                blockNames[i],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral2,
                                ),
                              ),
                            ),
                            Text(
                              '${blockTotals[i]} / $blockMax',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: blockPct,
                            minHeight: 7,
                            backgroundColor: AppColors.neutral8,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // ── Tags de fallo ────────────────────────────────────
            if (tagCount.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Causas de Fallo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.neutral8),
                ),
                child: Column(
                  children: tagCount.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                e.key,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.neutral2,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.warningBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${e.value}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Color _scoreColor(int score) {
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
