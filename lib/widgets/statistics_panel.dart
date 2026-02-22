import 'package:flutter/material.dart';
import '../models/statistics.dart';
import 'charts/line_chart.dart';
import 'charts/radar_chart.dart';

class StatisticsPanel extends StatelessWidget {
  final Statistics stats;

  const StatisticsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTADÍSTICAS PARCIALES',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildMetric('Efectividad General', '${stats.generalEffectiveness.toStringAsFixed(1)}%'),
          _buildMetric('Precisión', '${stats.precision.toStringAsFixed(1)}%'),
          _buildMetric('Tiros Efectivos', '${stats.effectiveThrows} / ${stats.effectiveThrows + stats.failedThrows}'),
          _buildMetric('Tiros Fallidos', '${stats.failedThrows}'),
          const SizedBox(height: 20),
          const Text('POR DISTANCIA', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDistanceStats(stats.shortStats),
          _buildDistanceStats(stats.mediumStats),
          _buildDistanceStats(stats.longStats),
          const SizedBox(height: 20),
          const Text('FATIGA POR BLOQUE', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FatigueLineChart(data: stats.scoreByBlock),
          const SizedBox(height: 20),
          const Text('EFECTIVIDAD POR CAJÓN', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Placeholder for radar chart data (effectiveness by box)
          BoxRadarChart(effectivenessByBox: List.generate(6, (index) => 4.0)), // Dummy data for now
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDistanceStats(DistanceStats dStats) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${dStats.label}:', style: const TextStyle(fontWeight: FontWeight.w500)),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: [
                _buildMetric('Aciertos', '${dStats.hits} / ${dStats.total} (${dStats.effectiveness.toStringAsFixed(1)}%)'),
                _buildMetric('Precisión', '${dStats.precision.toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
