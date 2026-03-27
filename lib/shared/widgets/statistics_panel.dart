import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/statistics.dart';
import 'charts/line_chart.dart';
import 'charts/radar_chart.dart';

class StatisticsPanel extends StatelessWidget {
  final Statistics stats;

  const StatisticsPanel({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.0, 20.0 + topPadding, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────
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
                Text(
                  'Estadísticas Parciales',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── General metrics card ───────────────────────────────
            _buildSectionCard(
              children: [
                _buildCircularMetricRow(
                  label: 'Efectividad General',
                  value: stats.generalEffectiveness,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                _buildCircularMetricRow(
                  label: 'Precisión',
                  value: stats.precision,
                  color: AppColors.accent5,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: AppColors.neutral8, height: 1),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip(
                        icon: Icons.check_circle_outline,
                        label: 'Efectivos',
                        value: '${stats.effectiveThrows}',
                        color: AppColors.success,
                        bgColor: AppColors.successBg,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatChip(
                        icon: Icons.cancel_outlined,
                        label: 'Fallidos',
                        value: '${stats.failedThrows}',
                        color: AppColors.error,
                        bgColor: AppColors.errorBg,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Distance section ───────────────────────────────────
            _buildSectionHeader('Por Distancia'),
            const SizedBox(height: 10),
            _buildSectionCard(
              children: [
                _buildDistanceRow(
                  stats.shortStats,
                  AppColors.distanceShort,
                  AppColors.distanceShortBg,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.neutral8, height: 1),
                ),
                _buildDistanceRow(
                  stats.mediumStats,
                  AppColors.distanceMedium,
                  AppColors.distanceMediumBg,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.neutral8, height: 1),
                ),
                _buildDistanceRow(
                  stats.longStats,
                  AppColors.distanceLong,
                  AppColors.distanceLongBg,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Fatigue section ────────────────────────────────────
            _buildSectionHeader('Fatiga por Bloque'),
            const SizedBox(height: 10),
            _buildSectionCard(
              children: [
                FatigueLineChart(data: stats.scoreByBlock),
              ],
            ),
            const SizedBox(height: 16),

            // ── Radar section ──────────────────────────────────────
            _buildSectionHeader('Efectividad por Cajón'),
            const SizedBox(height: 10),
            _buildSectionCard(
              children: [
                BoxRadarChart(
                  effectivenessByBox: List.generate(6, (index) => 4.0),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Helper builders
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCircularMetricRow({
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: (value / 100).clamp(0.0, 1.0),
                strokeWidth: 5,
                backgroundColor: AppColors.neutral8,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Text(
                '${value.toStringAsFixed(0)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceRow(
    DistanceStats dStats,
    Color color,
    Color bgColor,
  ) {
    final eff = dStats.effectiveness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dStats.label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${dStats.hits}/${dStats.total}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Effectiveness bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (eff / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.neutral8,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Efect. ${eff.toStringAsFixed(0)}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Prec. ${dStats.precision.toStringAsFixed(0)}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
