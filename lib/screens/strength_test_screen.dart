import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StrengthTestScreen extends StatefulWidget {
  final String evaluationType;
  final List<String> athletes;

  const StrengthTestScreen({
    super.key,
    required this.evaluationType,
    required this.athletes,
  });

  @override
  State<StrengthTestScreen> createState() => _StrengthTestScreenState();
}

class _StrengthTestScreenState extends State<StrengthTestScreen> {
  late int currentAthleteIndex;
  late Map<String, List<Map<String, dynamic>>> athleteResults;
  
  // Distancias disponibles para la prueba
  final List<String> distances = ['Corta', 'Media', 'Larga'];
  late Map<String, TextEditingController> distanceControllers;

  @override
  void initState() {
    super.initState();
    currentAthleteIndex = 0;
    athleteResults = {
      for (var athlete in widget.athletes) athlete: [],
    };
    distanceControllers = {
      'Corta': TextEditingController(),
      'Media': TextEditingController(),
      'Larga': TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (var controller in distanceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String get currentAthlete => widget.athletes[currentAthleteIndex];

  void _saveResult() {
    final corta = distanceControllers['Corta']?.text;
    final media = distanceControllers['Media']?.text;
    final larga = distanceControllers['Larga']?.text;

    if (corta?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa la distancia corta'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    athleteResults[currentAthlete]?.add({
      'corta': corta,
      'media': media,
      'larga': larga,
      'timestamp': DateTime.now(),
    });

    _clearFields();

    if (currentAthleteIndex < widget.athletes.length - 1) {
      setState(() {
        currentAthleteIndex++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resultado guardado. Siguiente atleta: $currentAthlete'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      _showCompletionDialog();
    }
  }

  void _clearFields() {
    distanceControllers['Corta']?.clear();
    distanceControllers['Media']?.clear();
    distanceControllers['Larga']?.clear();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Prueba Completada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultados guardados para ${widget.athletes.length} atleta(s)',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Resultados:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.athletes.map((athlete) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '• $athlete: ${athleteResults[athlete]?.length ?? 0} prueba(s)',
                style: const TextStyle(fontSize: 13),
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Volver al inicio'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Mostrar estadísticas
              _showStatistics();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text(
              'Ver Estadísticas',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatistics() {
    Navigator.of(context).pushNamed('/test-statistics', arguments: {
      'evaluationType': widget.evaluationType,
      'athletes': widget.athletes,
      'results': athleteResults,
    });
  }

  String _getEvaluationTitle() {
    return widget.evaluationType == 'strength'
        ? 'Prueba de control de fuerza'
        : 'Prueba de control de dirección';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getEvaluationTitle()),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Athlete info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Atleta actual',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentAthlete,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${currentAthleteIndex + 1} de ${widget.athletes.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (currentAthleteIndex + 1) / widget.athletes.length,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFD1D5DB),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Title
            const Text(
              'Modulación de fuerza en distancias cortas, medias y largas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Form fields
            ..._buildDistanceFields(),
            const SizedBox(height: 32),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionPrimaryDefault,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Resultado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
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

  List<Widget> _buildDistanceFields() {
    return distances.map((distance) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              distance,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: distanceControllers[distance],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Ingresa el valor en metros',
                hintStyle: const TextStyle(color: AppColors.neutral7),
                filled: true,
                fillColor: AppColors.neutral9,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
