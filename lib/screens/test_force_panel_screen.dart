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
  final TextEditingController _evalNameController = TextEditingController(text: "Evaluación de Prueba");

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

  Widget _buildSetupScreen(BuildContext context, ForceTestProvider provider) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Test de Fuerza - Inicio', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Configurar Nueva Evaluación', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 24),
            TextField(
              controller: _evalNameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la Evaluación',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Seleccionar Atletas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF34495E))),
            const SizedBox(height: 12),
            _buildAthleteSearch(provider),
            const SizedBox(height: 16),
            if (provider.selectedAthletes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Agrega al menos un atleta para comenzar', style: TextStyle(color: Colors.orange[800], fontSize: 13, fontStyle: FontStyle.italic)),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.selectedAthletes
                  .map<Widget>((athlete) => InputChip(
                        label: Text(athlete.name),
                        onDeleted: () => provider.removeAthlete(athlete.id),
                        backgroundColor: const Color(0xFFE8F0F5),
                        labelStyle: const TextStyle(color: Color(0xFF477D9E)),
                        deleteIconColor: const Color(0xFF477D9E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: provider.selectedAthletes.isEmpty || _evalNameController.text.isEmpty
                  ? null
                  : () async {
                      try {
                        await provider.startNewEvaluation(_evalNameController.text, 1, 1);
                      } catch (e) {
                        // En caso de error de API (URL falso), forzar inicio local para propósitos de demo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Iniciando en modo local (API no disponible)')),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF477D9E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: provider.isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('INICIAR EVALUACIÓN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
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
              provider.addAthlete(Athlete(id: DateTime.now().millisecondsSinceEpoch, name: _athleteSearchController.text));
              _athleteSearchController.clear();
            }
          },
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          provider.addAthlete(Athlete(id: DateTime.now().millisecondsSinceEpoch, name: value));
          _athleteSearchController.clear();
        }
      },
    );
  }

  Widget _buildEvaluationScreen(BuildContext context, ForceTestProvider provider) {
    final config = provider.currentShotConfig;
    if (config == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Progreso', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Tiro ${provider.currentShotNumber} de ${provider.totalShots}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(child: Text('${(provider.currentShotNumber / provider.totalShots * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF477D9E)))),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 900;
          return Row(
            children: [
              Expanded(
                flex: isWide ? 2 : 1,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: provider.currentShotNumber / provider.totalShots,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF477D9E)),
                      minHeight: 4,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ForceTargetWidget(
                              selection: provider.currentSelection,
                              onTargetTap: provider.setSelection,
                            ),
                            const SizedBox(height: 24),
                            Text('Zona # ${config.boxNumber}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                            Text('Distancia objetivo: ${config.targetDistance.toStringAsFixed(1)} metros', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(height: 24),
                            const Text('Puntaje obtenido*', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            _buildScoreSelector(provider),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('0-2: Fallo', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text('3-5: Acierto', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Observaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            TextField(
                              controller: provider.observationsController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Agrega tus comentarios...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 32),
                            _buildNavigationButtons(provider, config),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isWide) const VerticalDivider(width: 1),
              if (isWide) Expanded(flex: 1, child: Container(color: Colors.white, child: StatisticsPanel(stats: provider.stats))),
            ],
          );
        },
      ),
      endDrawer: MediaQuery.of(context).size.width <= 900
          ? Drawer(width: 400, child: StatisticsPanel(stats: provider.stats))
          : null,
    );
  }

  Widget _buildScoreSelector(ForceTestProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        bool isSelected = provider.currentScore == index;
        return GestureDetector(
          onTap: () => provider.setSelection(
            provider.currentSelection?.dx ?? 50,
            provider.currentSelection?.dy ?? 50,
            index,
          ),
          child: Container(
            width: 50,
            height: 45,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF477D9E) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? const Color(0xFF477D9E) : Colors.grey.shade300, width: 1.5),
              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF477D9E).withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] : null,
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons(ForceTestProvider provider, config) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text('Cajón n° ${config.prevBox ?? 0}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: provider.currentShotNumber > 1 ? () => provider.previousShot() : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text('Anterior', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              Text('Cajón n° ${config.nextBox ?? 0}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: provider.canGoNext && !provider.isLoading ? () => provider.nextShot() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D7D9A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: provider.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(provider.currentShotNumber == provider.totalShots ? 'Finalizar' : 'Siguiente'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
