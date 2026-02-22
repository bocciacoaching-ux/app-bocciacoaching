import 'package:flutter/material.dart';
import '../models/assess_strength.dart';

class PendingEvaluationsCard extends StatelessWidget {
  final AssessStrength evaluation;
  final VoidCallback onContinue;
  final VoidCallback onNew;

  const PendingEvaluationsCard({
    super.key,
    required this.evaluation,
    required this.onContinue,
    required this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    double progress = evaluation.completedThrows / evaluation.totalShots;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evaluación Activa Encontrada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Atletas: ${evaluation.athletes.map((a) => a.name).join(", ")}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progreso: ${evaluation.completedThrows} / ${evaluation.totalShots}'),
                Text('${(progress * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onNew,
                  child: const Text('NUEVA EVALUACIÓN', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('CONTINUAR'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
