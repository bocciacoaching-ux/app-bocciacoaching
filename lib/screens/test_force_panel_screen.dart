import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/force_test_provider.dart';
import '../widgets/force_target_widget.dart';
import '../widgets/statistics_panel.dart';
import '../models/athlete.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Test de Fuerza - Inicio',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Configurar Nueva Evaluación',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _evalNameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la Evaluación',
                filled: true,
                fillColor: Colors.grey[50],
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
                color: Color(0xFF34495E),
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
                    color: Colors.orange[800],
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
                      backgroundColor: const Color(0xFFE8F0F5),
                      labelStyle: const TextStyle(color: Color(0xFF477D9E)),
                      deleteIconColor: const Color(0xFF477D9E),
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
                      _evalNameController.text.isEmpty
                  ? null
                  : () async {
                      try {
                        await provider.startNewEvaluation(
                          _evalNameController.text,
                          1,
                          1,
                        );
                      } catch (_) {
                        if (mounted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Iniciando en modo local (API no disponible)',
                              ),
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF477D9E),
                foregroundColor: Colors.white,
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
                        color: Colors.white,
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
    );
  }

  Widget _buildAthleteSearch(ForceTestProvider provider) {
    return TextField(
      controller: _athleteSearchController,
      decoration: InputDecoration(
        hintText: 'Escribe un nombre y presiona el "+" o Enter',
        prefixIcon: const Icon(Icons.person_add),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add_circle, color: Color(0xFF477D9E)),
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
        fillColor: Colors.grey[50],
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test de Fuerza',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Tiro ${provider.currentShotNumber} de ${provider.totalShots}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          // Stats drawer toggle for narrow screens
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: 'Estadísticas',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${(progressPct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF477D9E),
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: LayoutBuilder(
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
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF477D9E),
                      ),
                      minHeight: 5,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Target ──
                            LayoutBuilder(
                              builder: (context, innerConstraints) {
                                final targetSize =
                                    (innerConstraints.maxWidth * 0.85)
                                        .clamp(200.0, 420.0);
                                return ForceTargetWidget(
                                  key: _targetKey,
                                  size: targetSize,
                                  selection: provider.currentSelection,
                                  onTargetTap: provider.setSelection,
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // ── Shot info card ──
                            _buildShotInfoCard(provider, config),

                            const SizedBox(height: 20),

                            // ── Score selector ──
                            const Text(
                              'Puntaje obtenido *',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildScoreSelector(provider),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '0-2: Fallo',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red[300],
                                    ),
                                  ),
                                  Text(
                                    '3-5: Acierto',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Observations ──
                            Row(
                              children: [
                                const Text(
                                  'Observaciones',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_isObservationRequired(provider))
                                  const Text(
                                    ' (requerida)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontStyle: FontStyle.italic,
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
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _shouldHighlightObs(provider)
                                        ? Colors.red
                                        : Colors.grey.shade300,
                                    width: _shouldHighlightObs(provider)
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _shouldHighlightObs(provider)
                                        ? Colors.red
                                        : Colors.grey.shade300,
                                    width: _shouldHighlightObs(provider)
                                        ? 2
                                        : 1,
                                  ),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),

                            const SizedBox(height: 28),

                            // ── Navigation buttons ──
                            _buildNavigationButtons(provider, config),

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
                    color: Colors.white,
                    child: StatisticsPanel(stats: provider.stats),
                  ),
                ),
            ],
          );
        },
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
        gradient: const LinearGradient(
          colors: [Color(0xFF477D9E), Color(0xFF3A6B89)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF477D9E).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Box number
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${config.boxNumber}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cajón n° ${config.boxNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.straighten, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Distancia: ${config.targetDistance.toStringAsFixed(1)} m',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score badge
          if (provider.currentScore != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _scoreColor(provider.currentScore!),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '${provider.currentScore}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Score selector row ─────────────────────────────────────────────

  Widget _buildScoreSelector(ForceTestProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final isSelected = provider.currentScore == index;
        final color = _scoreColor(index);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == 5 ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => provider.setSelection(
                provider.currentSelection?.dx ?? 50,
                provider.currentSelection?.dy ?? 50,
                index,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Navigation buttons ─────────────────────────────────────────────

  Widget _buildNavigationButtons(ForceTestProvider provider, config) {
    return Row(
      children: [
        // Previous
        Expanded(
          child: Column(
            children: [
              if (config.prevBox != null)
                Text(
                  'Cajón n° ${config.prevBox}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: provider.currentShotNumber > 1
                    ? () => provider.previousShot()
                    : null,
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: const Text('Anterior'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                  foregroundColor: Colors.grey[700],
                ),
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              if (config.nextBox == null) const SizedBox(height: 14),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed:
                    provider.canGoNext && !provider.isLoading
                        ? () {
                            // Validate observation requirement
                            if (_isObservationRequired(provider) &&
                                provider.observationsController.text
                                    .trim()
                                    .isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Para puntajes 0-2, la observación es obligatoria.',
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            provider.nextShot();
                          }
                        : null,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        provider.currentShotNumber == provider.totalShots
                            ? Icons.check_circle_outline
                            : Icons.arrow_forward_ios,
                        size: 16,
                      ),
                label: Text(
                  provider.currentShotNumber == provider.totalShots
                      ? 'Finalizar'
                      : 'Siguiente',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF477D9E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Helper methods ─────────────────────────────────────────────────

  bool _isObservationRequired(ForceTestProvider provider) {
    return provider.currentScore != null && provider.currentScore! <= 2;
  }

  bool _shouldHighlightObs(ForceTestProvider provider) {
    return _isObservationRequired(provider) &&
        provider.observationsController.text.trim().isEmpty;
  }

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
        return Colors.grey;
    }
  }
}
