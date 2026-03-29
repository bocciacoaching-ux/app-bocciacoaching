import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/macrocycle.dart';
import '../../../data/models/macrocycle_event.dart';
import '../../../data/models/mesocycle.dart';
import '../../../data/models/microcycle.dart';
import '../../coach/services/macrocycle_excel_export.dart';

/// Pantalla de detalle de un macrociclo con vista completa
/// y opción de exportar a Excel.
class MacrocycleDetailScreen extends StatelessWidget {
  final Macrocycle macrocycle;

  const MacrocycleDetailScreen({super.key, required this.macrocycle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral3),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          macrocycle.name,
          style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: AppColors.primary),
            tooltip: 'Compartir',
            onPressed: () => _shareAsExcel(context),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined,
                color: AppColors.primary),
            tooltip: 'Exportar a Excel',
            onPressed: () => _exportToExcel(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header info ──────────────────────────────────
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // ── Timeline horizontal visual ───────────────────
            _buildTimelineBar(),
            const SizedBox(height: 20),

            // ── Etapas / Períodos ────────────────────────────
            _sectionTitle('Etapas / Períodos', Icons.layers_outlined),
            const SizedBox(height: 8),
            ...macrocycle.periods.map(_buildPeriodCard),
            const SizedBox(height: 20),

            // ── Eventos ──────────────────────────────────────
            _sectionTitle('Eventos', Icons.event_outlined),
            const SizedBox(height: 8),
            if (macrocycle.events.isEmpty)
              _emptySection('Sin eventos registrados')
            else
              ...macrocycle.events.map(_buildEventCard),
            const SizedBox(height: 20),

            // ── Mesociclos ───────────────────────────────────
            _sectionTitle('Mesociclos', Icons.view_week_outlined),
            const SizedBox(height: 8),
            ...macrocycle.mesocycles.map(_buildMesocycleCard),
            const SizedBox(height: 20),

            // ── Microciclos (tabla) ──────────────────────────
            _sectionTitle('Microciclos (Semanas)', Icons.grid_view_outlined),
            const SizedBox(height: 8),
            _buildMicrocycleTable(),
            const SizedBox(height: 20),

            // ── Distribución de Entrenamiento ────────────────
            _sectionTitle(
              'Distribución de Entrenamiento',
              Icons.pie_chart_outline,
            ),
            const SizedBox(height: 8),
            _buildTrainingDistributionSection(),
            const SizedBox(height: 20),

            // ── Notas ────────────────────────────────────────
            if (macrocycle.notes != null &&
                macrocycle.notes!.isNotEmpty) ...[
              _sectionTitle('Notas', Icons.notes_outlined),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neutral8),
                ),
                child: Text(
                  macrocycle.notes!,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Botones de acción ─────────────────────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportToExcel(context),
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Exportar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareAsExcel(context),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Compartir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.headerGradientTop, AppColors.headerGradientBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month,
                  color: AppColors.white, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  macrocycle.name,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _headerInfo(Icons.person_outline, 'Atleta',
              macrocycle.athleteName),
          const SizedBox(height: 6),
          _headerInfo(Icons.date_range_outlined, 'Período',
              '${_formatDateFull(macrocycle.startDate)} — ${_formatDateFull(macrocycle.endDate)}'),
          const SizedBox(height: 6),
          _headerInfo(Icons.timer_outlined, 'Duración',
              '${macrocycle.totalWeeks} semanas (${macrocycle.totalDays} días)'),
          const SizedBox(height: 12),
          // Chips de resumen
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _headerChip('${macrocycle.periods.length} Etapas'),
              _headerChip('${macrocycle.mesocycles.length} Mesociclos'),
              _headerChip('${macrocycle.microcycles.length} Microciclos'),
              _headerChip('${macrocycle.events.length} Eventos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerInfo(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.white.withOpacity(0.8), size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // TIMELINE BAR
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildTimelineBar() {
    final totalDays = macrocycle.totalDays;
    if (totalDays <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribución del Macrociclo',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              )),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 28,
              child: Row(
                children: macrocycle.periods.map((p) {
                  final pDays =
                      p.endDate.difference(p.startDate).inDays + 1;
                  final fraction = pDays / totalDays;
                  return Expanded(
                    flex: (fraction * 1000).round().clamp(1, 1000),
                    child: Tooltip(
                      message:
                          '${p.name}\n${p.weeks} semanas',
                      child: Container(
                        color: _colorForPeriod(p.type),
                        child: Center(
                          child: Text(
                            p.name.split(' ').first,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Leyenda
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: macrocycle.periods.map((p) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _colorForPeriod(p.type),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    p.name,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // PERÍODOS
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildPeriodCard(MacrocyclePeriod period) {
    final color = _colorForPeriod(period.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.layers_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(period.startDate)} — ${_formatDate(period.endDate)}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${period.weeks} sem.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // EVENTOS
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildEventCard(MacrocycleEvent event) {
    final color = _colorForEventType(event.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.type.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    if (event.location != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.neutral5),
                      Text(
                        ' ${event.location}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_formatDate(event.startDate)} – ${_formatDate(event.endDate)} (${event.durationDays} días)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // MESOCICLOS
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildMesocycleCard(Mesocycle meso) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'M${meso.number}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meso.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(meso.startDate)} – ${_formatDate(meso.endDate)} · ${meso.weeks} semanas',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                if (meso.objective != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    meso.objective!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // MICROCICLOS (TABLA)
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildMicrocycleTable() {
    if (macrocycle.microcycles.isEmpty) {
      return _emptySection('Sin microciclos calculados');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.all(AppColors.primary10),
          columnSpacing: 20,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 56,
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Semana', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Período', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Mesociclo', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Fechas', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: macrocycle.microcycles.map((micro) {
            return DataRow(
              cells: [
                DataCell(Text('${micro.number}')),
                DataCell(Text('Sem ${micro.weekNumber}')),
                DataCell(Text(micro.periodName ?? '-',
                    style: const TextStyle(fontSize: 12))),
                DataCell(Text(micro.mesocycleName ?? '-',
                    style: const TextStyle(fontSize: 12))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _colorForMicrocycleType(micro.type)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      micro.type.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _colorForMicrocycleType(micro.type),
                      ),
                    ),
                  ),
                ),
                DataCell(Text(
                  '${_formatDate(micro.startDate)} – ${_formatDate(micro.endDate)}',
                  style: const TextStyle(fontSize: 12),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // DISTRIBUCIÓN DE ENTRENAMIENTO
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildTrainingDistributionSection() {
    if (macrocycle.microcycles.isEmpty) {
      return _emptySection('Sin microciclos para mostrar distribución');
    }

    final categories = [
      ('FISICA GENERAL', AppColors.accent3, (TrainingDistribution d) => d.fisicaGeneral),
      ('FISICA ESPECIAL', AppColors.accent6, (TrainingDistribution d) => d.fisicaEspecial),
      ('TÉCNICA', AppColors.success, (TrainingDistribution d) => d.tecnica),
      ('TÁTICA', AppColors.accent2, (TrainingDistribution d) => d.tactica),
      ('TEÓRICA', AppColors.error, (TrainingDistribution d) => d.teorica),
      ('PSICOLÓGICA', AppColors.accent5, (TrainingDistribution d) => d.psicologica),
    ];

    return Column(
      children: [
        // ── Leyenda de colores ──────────────────────────────
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: categories.map((cat) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: cat.$2,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  cat.$1,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // ── Tabla de distribución ────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.neutral8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.primary10),
              columnSpacing: 12,
              dataRowMinHeight: 36,
              dataRowMaxHeight: 44,
              columns: [
                const DataColumn(
                  label: Text('Categoría',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                ...macrocycle.microcycles.map((micro) => DataColumn(
                      label: Text(
                        'S${micro.number}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    )),
              ],
              rows: categories.map((cat) {
                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cat.$2.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cat.$1,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: cat.$2,
                          ),
                        ),
                      ),
                    ),
                    ...macrocycle.microcycles.map((micro) {
                      final value = cat.$3(micro.trainingDistribution);
                      return DataCell(
                        Text(
                          '${(value * 100).round()}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: value > 0
                                ? AppColors.neutral2
                                : AppColors.neutral6,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Barras apiladas por microciclo ────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.neutral8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Distribución por Semana',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...macrocycle.microcycles.map((micro) {
                final dist = micro.trainingDistribution;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 38,
                        child: Text(
                          'S${micro.number}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 18,
                            child: Row(
                              children: [
                                _stackedSegment(
                                    dist.fisicaGeneral, categories[0].$2),
                                _stackedSegment(
                                    dist.fisicaEspecial, categories[1].$2),
                                _stackedSegment(
                                    dist.tecnica, categories[2].$2),
                                _stackedSegment(
                                    dist.tactica, categories[3].$2),
                                _stackedSegment(
                                    dist.teorica, categories[4].$2),
                                _stackedSegment(
                                    dist.psicologica, categories[5].$2),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 28,
                        child: Text(
                          micro.type.label.substring(0, 3),
                          style: const TextStyle(
                              fontSize: 8, color: AppColors.neutral4),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stackedSegment(double fraction, Color color) {
    if (fraction <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: (fraction * 100).round(),
      child: Container(color: color),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // EXPORT
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(width: 20),
              Text('Exportando a Excel...'),
            ],
          ),
        ),
      );

      final filePath =
          await MacrocycleExcelExport.exportToExcel(macrocycle);

      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo

        _showExportSuccessDialog(context, filePath);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de carga
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareAsExcel(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(width: 20),
              Text('Preparando archivo...'),
            ],
          ),
        ),
      );

      final filePath =
          await MacrocycleExcelExport.exportToExcel(macrocycle);

      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath)],
            subject: 'Macrociclo: ${macrocycle.name}',
            text:
                'Macrociclo de ${macrocycle.athleteName} — '
                '${macrocycle.startDate.day}/${macrocycle.startDate.month}/${macrocycle.startDate.year} '
                'al ${macrocycle.endDate.day}/${macrocycle.endDate.month}/${macrocycle.endDate.year}',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showExportSuccessDialog(BuildContext context, String filePath) {
    final fileName = filePath.split('/').last;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Expanded(child: Text('Exportado exitosamente')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('El archivo se ha guardado correctamente:'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.neutral9,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined,
                      size: 20, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _openExcelFile(filePath);
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Abrir'),
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _shareFile(context, filePath);
                },
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Compartir'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openExcelFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        debugPrint('Error al abrir archivo: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error al abrir archivo: $e');
    }
  }

  Future<void> _shareFile(BuildContext context, String filePath) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          subject: 'Macrociclo: ${macrocycle.name}',
          text:
              'Macrociclo de ${macrocycle.athleteName} — '
              '${macrocycle.startDate.day}/${macrocycle.startDate.month}/${macrocycle.startDate.year} '
              'al ${macrocycle.endDate.day}/${macrocycle.endDate.month}/${macrocycle.endDate.year}',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
        ),
      ],
    );
  }

  Widget _emptySection(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.neutral9,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Color _colorForPeriod(PeriodType type) {
    switch (type) {
      case PeriodType.preparatorioGeneral:
        return AppColors.accent3;
      case PeriodType.preparatorioEspecial:
        return AppColors.accent6;
      case PeriodType.competitivo:
        return AppColors.error;
      case PeriodType.transicion:
        return AppColors.success;
    }
  }

  Color _colorForEventType(EventType type) {
    switch (type) {
      case EventType.competencia:
        return AppColors.error;
      case EventType.concentracion:
        return AppColors.accent6;
      case EventType.campus:
        return AppColors.accent5;
      case EventType.evaluacion:
        return AppColors.accent3;
      case EventType.descanso:
        return AppColors.success;
      case EventType.otro:
        return AppColors.neutral4;
    }
  }

  Color _colorForMicrocycleType(MicrocycleType type) {
    switch (type) {
      case MicrocycleType.ordinario:
        return AppColors.primary;
      case MicrocycleType.choque:
        return AppColors.accent4;
      case MicrocycleType.recuperacion:
        return AppColors.success;
      case MicrocycleType.activacion:
        return AppColors.accent2;
      case MicrocycleType.competitivo:
        return AppColors.error;
      case MicrocycleType.transitorio:
        return AppColors.accent5;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDateFull(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
