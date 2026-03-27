import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

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
              fillColor: AppColors.primary.withValues(alpha: 0.15),
              borderColor: AppColors.primary,
              borderWidth: 2.5,
              entryRadius: 4,
              dataEntries: effectivenessByBox
                  .map((e) => RadarEntry(value: e))
                  .toList(),
            ),
          ],
          radarBorderData: const BorderSide(color: AppColors.neutral7, width: 1),
          tickBorderData: const BorderSide(color: AppColors.neutral8, width: 0.5),
          gridBorderData: const BorderSide(color: AppColors.neutral7, width: 0.5),
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: 'C${index + 1}',
              angle: angle,
            );
          },
          ticksTextStyle: AppTextStyles.bodySmall.copyWith(
            fontSize: 9,
            color: AppColors.textSecondary,
          ),
          titleTextStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titlePositionPercentageOffset: 0.18,
          tickCount: 4,
        ),
      ),
    );
  }
}
