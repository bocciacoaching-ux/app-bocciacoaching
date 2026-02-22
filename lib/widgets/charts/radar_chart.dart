import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BoxRadarChart extends StatelessWidget {
  final List<double> effectivenessByBox; // 6 boxes

  const BoxRadarChart({super.key, required this.effectivenessByBox});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.circle,
          dataSets: [
            RadarDataSet(
              fillColor: Colors.blue.withOpacity(0.4),
              borderColor: Colors.blue,
              entryRadius: 3,
              dataEntries: effectivenessByBox
                  .map((e) => RadarEntry(value: e))
                  .toList(),
            ),
          ],
          radarBorderData: const BorderSide(color: Colors.grey, width: 1),
          tickBorderData: const BorderSide(color: Colors.grey, width: 1),
          gridBorderData: const BorderSide(color: Colors.grey, width: 1),
          getTitle: (index, angle) {
            return RadarChartTitle(text: 'C${index + 1}', angle: angle);
          },
          ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.black54),
          titlePositionPercentageOffset: 0.15,
        ),
      ),
    );
  }
}
