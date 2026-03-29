import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/macrocycle.dart';
import '../../../data/models/macrocycle_event.dart';
import '../../../data/models/mesocycle.dart';
import '../../../data/models/microcycle.dart';
import '../../../data/providers/macrocycle_provider.dart';
import '../../coach/services/macrocycle_excel_export.dart';

/// Pantalla de detalle de un macrociclo con vista completa,
/// opción de exportar a Excel y edición inline de todos los componentes.
class MacrocycleDetailScreen extends StatefulWidget {
  final Macrocycle macrocycle;

  const MacrocycleDetailScreen({super.key, required this.macrocycle});

  @override
  State<MacrocycleDetailScreen> createState() =>
      _MacrocycleDetailScreenState();
}

class _MacrocycleDetailScreenState extends State<MacrocycleDetailScreen> {
  late Macrocycle _macrocycle;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _macrocycle = widget.macrocycle;
  }

  void _updateMacrocycle(Macrocycle updated) {
    setState(() {
      _macrocycle = updated.copyWith(updatedAt: DateTime.now());
      _hasChanges = true;
    });
  }

  Future<void> _saveMacrocycle() async {
    await context.read<MacrocycleProvider>().updateMacrocycle(_macrocycle);
    if (!mounted) return;
    setState(() {
      _hasChanges = false;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Macrociclo actualizado exitosamente'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cambios sin guardar'),
        content: const Text('¿Deseas guardar los cambios antes de salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Descartar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveMacrocycle();
              if (ctx.mounted) Navigator.of(ctx).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.neutral3),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            _macrocycle.name,
            style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
          actions: [
            if (_isEditing) ...[
              if (_hasChanges)
                IconButton(
                  icon: const Icon(Icons.save_outlined, color: AppColors.success),
                  tooltip: 'Guardar cambios',
                  onPressed: _saveMacrocycle,
                ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.error),
                tooltip: 'Cancelar edición',
                onPressed: () {
                  setState(() {
                    _macrocycle = widget.macrocycle;
                    _isEditing = false;
                    _hasChanges = false;
                  });
                },
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                tooltip: 'Editar macrociclo',
                onPressed: () => setState(() => _isEditing = true),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.primary),
                tooltip: 'Compartir',
                onPressed: () => _shareAsExcel(context),
              ),
              IconButton(
                icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                tooltip: 'Exportar a Excel',
                onPressed: () => _exportToExcel(context),
              ),
            ],
            const SizedBox(width: 4),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEditing) ...[
                _buildEditModeBanner(),
                const SizedBox(height: 12),
              ],
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildTimelineBar(),
              const SizedBox(height: 20),
              _sectionTitle('Etapas / Períodos', Icons.layers_outlined),
              const SizedBox(height: 8),
              ..._macrocycle.periods.asMap().entries.map(
                    (entry) => _buildPeriodCard(entry.value, entry.key)),
              const SizedBox(height: 20),
              _sectionTitle('Eventos', Icons.event_outlined),
              const SizedBox(height: 8),
              if (_isEditing) ...[
                _buildAddEventButton(),
                const SizedBox(height: 8),
              ],
              if (_macrocycle.events.isEmpty)
                _emptySection('Sin eventos registrados')
              else
                ..._macrocycle.events.asMap().entries.map(
                      (entry) => _buildEventCard(entry.value, entry.key)),
              const SizedBox(height: 20),
              _sectionTitle('Mesociclos', Icons.view_week_outlined),
              const SizedBox(height: 8),
              ..._macrocycle.mesocycles.asMap().entries.map(
                    (entry) => _buildMesocycleCard(entry.value, entry.key)),
              const SizedBox(height: 20),
              _sectionTitle('Microciclos (Semanas)', Icons.grid_view_outlined),
              const SizedBox(height: 8),
              if (_isEditing) ...[
                _buildMicrocycleLegend(),
                const SizedBox(height: 8),
              ],
              _buildMicrocycleTable(),
              const SizedBox(height: 20),
              _sectionTitle('Distribución de Entrenamiento', Icons.pie_chart_outline),
              const SizedBox(height: 8),
              _buildTrainingDistributionSection(),
              const SizedBox(height: 20),
              if (_macrocycle.notes != null && _macrocycle.notes!.isNotEmpty) ...[
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
                  child: Text(_macrocycle.notes!, style: AppTextStyles.bodyMedium),
                ),
                const SizedBox(height: 20),
              ],
              if (_isEditing && _hasChanges) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveMacrocycle,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar Cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (!_isEditing)
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // BANNER DE EDICIÓN
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildEditModeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo edición activo — Toca cualquier elemento para editarlo',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
              const Icon(Icons.calendar_month, color: AppColors.white, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _macrocycle.name,
                  style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _headerInfo(Icons.person_outline, 'Atleta', _macrocycle.athleteName),
          const SizedBox(height: 6),
          _headerInfo(Icons.date_range_outlined, 'Período',
              '${_formatDateFull(_macrocycle.startDate)} — ${_formatDateFull(_macrocycle.endDate)}'),
          const SizedBox(height: 6),
          _headerInfo(Icons.timer_outlined, 'Duración',
              '${_macrocycle.totalWeeks} semanas (${_macrocycle.totalDays} días)'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _headerChip('${_macrocycle.periods.length} Etapas'),
              _headerChip('${_macrocycle.mesocycles.length} Mesociclos'),
              _headerChip('${_macrocycle.microcycles.length} Microciclos'),
              _headerChip('${_macrocycle.events.length} Eventos'),
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
        Text('$label: ', style: TextStyle(color: AppColors.white.withOpacity(0.7), fontSize: 13)),
        Expanded(
          child: Text(value, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
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
      child: Text(label, style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // TIMELINE BAR
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildTimelineBar() {
    final totalDays = _macrocycle.totalDays;
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
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 28,
              child: Row(
                children: _macrocycle.periods.map((p) {
                  final pDays = p.endDate.difference(p.startDate).inDays + 1;
                  final fraction = pDays / totalDays;
                  return Expanded(
                    flex: (fraction * 1000).round().clamp(1, 1000),
                    child: Tooltip(
                      message: '${p.name}\n${p.weeks} semanas',
                      child: Container(
                        color: _colorForPeriod(p.type),
                        child: Center(
                          child: Text(p.name.split(' ').first,
                              style: const TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: _macrocycle.periods.map((p) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: _colorForPeriod(p.type), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Text(p.name, style: const TextStyle(fontSize: 10)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // PERÍODOS (ETAPAS) — CON EDICIÓN
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildPeriodCard(MacrocyclePeriod period, int index) {
    final color = _colorForPeriod(period.type);
    return GestureDetector(
      onTap: _isEditing ? () => _showEditPeriodDialog(period, index) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.layers_outlined, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(period.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
                  const SizedBox(height: 2),
                  Text('${_formatDate(period.startDate)} — ${_formatDate(period.endDate)}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('${period.weeks} sem.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ),
            if (_isEditing) ...[
              const SizedBox(width: 4),
              Icon(Icons.edit_outlined, size: 16, color: color.withOpacity(0.6)),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditPeriodDialog(MacrocyclePeriod period, int index) {
    PeriodType selectedType = period.type;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Editar Etapa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fechas: ${_formatDate(period.startDate)} — ${_formatDate(period.endDate)}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('${period.weeks} semanas', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                const Text('Tipo de período:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...PeriodType.values.map((type) {
                  final typeColor = _colorForPeriod(type);
                  return RadioListTile<PeriodType>(
                    contentPadding: EdgeInsets.zero,
                    title: Row(children: [
                      Container(width: 14, height: 14, decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 8),
                      Text(type.label, style: const TextStyle(fontSize: 14)),
                    ]),
                    value: type,
                    groupValue: selectedType,
                    activeColor: typeColor,
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedType = value);
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final updatedPeriod = period.copyWith(type: selectedType, name: selectedType.label);
                final updatedPeriods = List<MacrocyclePeriod>.from(_macrocycle.periods);
                updatedPeriods[index] = updatedPeriod;
                _updateMacrocycle(_macrocycle.copyWith(periods: updatedPeriods));
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // EVENTOS (COMPETENCIAS) — CON EDICIÓN
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildAddEventButton() {
    return OutlinedButton.icon(
      onPressed: () => _showAddEditEventDialog(),
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Agregar evento'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 40),
      ),
    );
  }

  Widget _buildEventCard(MacrocycleEvent event, int index) {
    final color = _colorForEventType(event.type);
    return GestureDetector(
      onTap: _isEditing ? () => _showAddEditEventDialog(event: event, index: index) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neutral8),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(event.type.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                    ),
                    if (event.location != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined, size: 12, color: AppColors.neutral5),
                      Text(' ${event.location}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Text(event.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('${_formatDate(event.startDate)} – ${_formatDate(event.endDate)} (${event.durationDays} días)',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (_isEditing)
              IconButton(
                onPressed: () => _deleteEvent(index),
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                tooltip: 'Eliminar evento',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
          ],
        ),
      ),
    );
  }

  void _deleteEvent(int index) {
    final events = List<MacrocycleEvent>.from(_macrocycle.events);
    events.removeAt(index);
    _updateMacrocycle(_macrocycle.copyWith(events: events));
  }

  void _showAddEditEventDialog({MacrocycleEvent? event, int? index}) {
    final nameCtrl = TextEditingController(text: event?.name ?? '');
    final locationCtrl = TextEditingController(text: event?.location ?? '');
    final notesCtrl = TextEditingController(text: event?.notes ?? '');
    DateTime? eventStart = event?.startDate;
    DateTime? eventEnd = event?.endDate;
    EventType selectedType = event?.type ?? EventType.competencia;
    final isNew = event == null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isNew ? 'Agregar Evento' : 'Editar Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<EventType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Tipo de evento', prefixIcon: Icon(Icons.category_outlined)),
                  items: EventType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                  onChanged: (value) { if (value != null) setDialogState(() => selectedType = value); },
                ),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre del evento', hintText: 'Ej: Panamericano 2026', prefixIcon: Icon(Icons.edit))),
                const SizedBox(height: 12),
                TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Ubicación (opcional)', hintText: 'Ej: Lima, Perú', prefixIcon: Icon(Icons.location_on_outlined))),
                const SizedBox(height: 12),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notas (opcional)', prefixIcon: Icon(Icons.notes_outlined)), maxLines: 2),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _dialogDateButton(ctx: ctx, label: 'Inicio', date: eventStart, onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: eventStart ?? _macrocycle.startDate,
                        firstDate: _macrocycle.startDate.subtract(const Duration(days: 365)),
                        lastDate: _macrocycle.endDate.add(const Duration(days: 365)));
                    if (picked != null) setDialogState(() => eventStart = picked);
                  })),
                  const SizedBox(width: 8),
                  Expanded(child: _dialogDateButton(ctx: ctx, label: 'Fin', date: eventEnd, onTap: () async {
                    final picked = await showDatePicker(context: ctx, initialDate: eventEnd ?? eventStart ?? _macrocycle.startDate,
                        firstDate: eventStart ?? _macrocycle.startDate.subtract(const Duration(days: 365)),
                        lastDate: _macrocycle.endDate.add(const Duration(days: 365)));
                    if (picked != null) setDialogState(() => eventEnd = picked);
                  })),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty || eventStart == null || eventEnd == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Completa nombre y fechas del evento'),
                    backgroundColor: AppColors.warning, behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                  return;
                }
                final updatedEvent = MacrocycleEvent(
                  id: event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text.trim(), type: selectedType,
                  startDate: eventStart!, endDate: eventEnd!,
                  location: locationCtrl.text.trim().isNotEmpty ? locationCtrl.text.trim() : null,
                  notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                );
                final events = List<MacrocycleEvent>.from(_macrocycle.events);
                if (isNew) { events.add(updatedEvent); } else { events[index!] = updatedEvent; }
                _updateMacrocycle(_macrocycle.copyWith(events: events));
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(isNew ? 'Agregar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogDateButton({required BuildContext ctx, required String label, required DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(color: AppColors.neutral9, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.neutral7)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(date != null ? _formatDate(date) : 'Seleccionar',
              style: TextStyle(fontSize: 13, fontWeight: date != null ? FontWeight.w600 : FontWeight.w400, color: date != null ? AppColors.textPrimary : AppColors.neutral5)),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // MESOCICLOS — CON EDICIÓN
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildMesocycleCard(Mesocycle meso, int index) {
    return GestureDetector(
      onTap: _isEditing ? () => _showEditMesocycleDialog(meso, index) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.neutral8)),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.primary10, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('M${meso.number}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meso.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${_formatDate(meso.startDate)} – ${_formatDate(meso.endDate)} · ${meso.weeks} semanas',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: _colorForMesocycleType(meso.type).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(meso.type.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _colorForMesocycleType(meso.type))),
                  ),
                  if (meso.objective != null) ...[
                    const SizedBox(height: 2),
                    Text(meso.objective!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent6, fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
            if (_isEditing) const Icon(Icons.edit_outlined, size: 16, color: AppColors.neutral5),
          ],
        ),
      ),
    );
  }

  void _showEditMesocycleDialog(Mesocycle meso, int index) {
    MesocycleType selectedType = meso.type;
    final objectiveCtrl = TextEditingController(text: meso.objective ?? '');
    final nameCtrl = TextEditingController(text: meso.name);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Editar ${meso.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_formatDate(meso.startDate)} — ${_formatDate(meso.endDate)} · ${meso.weeks} semanas',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre del mesociclo', prefixIcon: Icon(Icons.edit))),
                const SizedBox(height: 12),
                const Text('Tipo de mesociclo:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...MesocycleType.values.map((type) {
                  return RadioListTile<MesocycleType>(
                    contentPadding: EdgeInsets.zero, dense: true,
                    title: Text(type.label, style: const TextStyle(fontSize: 13)),
                    value: type, groupValue: selectedType, activeColor: AppColors.primary,
                    onChanged: (value) { if (value != null) setDialogState(() => selectedType = value); },
                  );
                }),
                const SizedBox(height: 12),
                TextField(controller: objectiveCtrl, decoration: const InputDecoration(labelText: 'Objetivo', hintText: 'Objetivo del mesociclo', prefixIcon: Icon(Icons.flag_outlined)), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final updatedMeso = meso.copyWith(
                  name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : meso.name,
                  type: selectedType,
                  objective: objectiveCtrl.text.trim().isNotEmpty ? objectiveCtrl.text.trim() : null,
                );
                final mesocycles = List<Mesocycle>.from(_macrocycle.mesocycles);
                mesocycles[index] = updatedMeso;
                _updateMacrocycle(_macrocycle.copyWith(mesocycles: mesocycles));
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // MICROCICLOS — LEYENDA Y TABLA CON EDICIÓN
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildMicrocycleLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leyenda de Microciclos (toca una semana en la tabla para cambiar su tipo)',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 6,
            children: MicrocycleType.values.map((type) {
              final color = _colorForMicrocycleType(type);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.4))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Text(type.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                ]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMicrocycleTable() {
    if (_macrocycle.microcycles.isEmpty) return _emptySection('Sin microciclos calculados');

    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.neutral8)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.primary10),
          columnSpacing: 20, dataRowMinHeight: 40, dataRowMaxHeight: 56,
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Semana', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Período', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Mesociclo', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Fechas', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _macrocycle.microcycles.asMap().entries.map((entry) {
            final micro = entry.value;
            final idx = entry.key;
            return DataRow(cells: [
              DataCell(Text('${micro.number}')),
              DataCell(Text('Sem ${micro.weekNumber}')),
              DataCell(Text(micro.periodName ?? '-', style: const TextStyle(fontSize: 12))),
              DataCell(Text(micro.mesocycleName ?? '-', style: const TextStyle(fontSize: 12))),
              DataCell(
                GestureDetector(
                  onTap: _isEditing ? () => _showEditMicrocycleDialog(micro, idx) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _colorForMicrocycleType(micro.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: _isEditing ? Border.all(color: _colorForMicrocycleType(micro.type).withOpacity(0.5), width: 1.5) : null,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(micro.type.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _colorForMicrocycleType(micro.type))),
                      if (_isEditing) ...[const SizedBox(width: 4), Icon(Icons.edit, size: 10, color: _colorForMicrocycleType(micro.type))],
                    ]),
                  ),
                ),
              ),
              DataCell(Text('${_formatDate(micro.startDate)} – ${_formatDate(micro.endDate)}', style: const TextStyle(fontSize: 12))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _showEditMicrocycleDialog(Microcycle micro, int index) {
    MicrocycleType selectedType = micro.type;
    late TrainingDistribution distribution = micro.trainingDistribution;
    bool useCustomDistribution = false;

    final fisGenCtrl = TextEditingController(text: (distribution.fisicaGeneral * 100).round().toString());
    final fisEspCtrl = TextEditingController(text: (distribution.fisicaEspecial * 100).round().toString());
    final tecCtrl = TextEditingController(text: (distribution.tecnica * 100).round().toString());
    final tacCtrl = TextEditingController(text: (distribution.tactica * 100).round().toString());
    final teoCtrl = TextEditingController(text: (distribution.teorica * 100).round().toString());
    final psiCtrl = TextEditingController(text: (distribution.psicologica * 100).round().toString());

    void updateControllersFromType(MicrocycleType type) {
      final d = TrainingDistribution.forMicrocycleType(type);
      fisGenCtrl.text = (d.fisicaGeneral * 100).round().toString();
      fisEspCtrl.text = (d.fisicaEspecial * 100).round().toString();
      tecCtrl.text = (d.tecnica * 100).round().toString();
      tacCtrl.text = (d.tactica * 100).round().toString();
      teoCtrl.text = (d.teorica * 100).round().toString();
      psiCtrl.text = (d.psicologica * 100).round().toString();
    }

    int currentTotal() {
      return (int.tryParse(fisGenCtrl.text) ?? 0) + (int.tryParse(fisEspCtrl.text) ?? 0) +
          (int.tryParse(tecCtrl.text) ?? 0) + (int.tryParse(tacCtrl.text) ?? 0) +
          (int.tryParse(teoCtrl.text) ?? 0) + (int.tryParse(psiCtrl.text) ?? 0);
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final total = currentTotal();
          final isValid = total == 100;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Editar Micro ${micro.number} (Sem ${micro.weekNumber})'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_formatDate(micro.startDate)} — ${_formatDate(micro.endDate)}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  const Text('Tipo de microciclo:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: MicrocycleType.values.map((type) {
                      final color = _colorForMicrocycleType(type);
                      final isSelected = type == selectedType;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedType = type;
                            if (!useCustomDistribution) updateControllersFromType(type);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color, width: isSelected ? 2 : 1),
                          ),
                          child: Text(type.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? AppColors.white : color)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Distribución de entrenamiento:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Row(children: [
                      Text('Custom', style: TextStyle(fontSize: 11, color: useCustomDistribution ? AppColors.primary : AppColors.neutral5)),
                      Switch(value: useCustomDistribution, activeColor: AppColors.primary, onChanged: (value) {
                        setDialogState(() { useCustomDistribution = value; if (!value) updateControllersFromType(selectedType); });
                      }),
                    ]),
                  ]),
                  const SizedBox(height: 8),
                  _percentageField('Física General', fisGenCtrl, AppColors.accent3, enabled: useCustomDistribution, onChanged: () => setDialogState(() {})),
                  _percentageField('Física Especial', fisEspCtrl, AppColors.accent6, enabled: useCustomDistribution, onChanged: () => setDialogState(() {})),
                  _percentageField('Técnica', tecCtrl, AppColors.success, enabled: useCustomDistribution, onChanged: () => setDialogState(() {})),
                  _percentageField('Táctica', tacCtrl, AppColors.accent2, enabled: useCustomDistribution, onChanged: () => setDialogState(() {})),
                  _percentageField('Teórica', teoCtrl, AppColors.error, enabled: useCustomDistribution, onChanged: () => setDialogState(() {})),
                  _percentageField('Psicológica', psiCtrl, AppColors.accent5, enabled: useCustomDistribution, onChanged: () => setDialogState(() {})),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isValid ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, color: isValid ? AppColors.success : AppColors.error)),
                      Text('$total%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isValid ? AppColors.success : AppColors.error)),
                    ]),
                  ),
                  if (!isValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Los porcentajes deben sumar 100%', style: TextStyle(fontSize: 11, color: AppColors.error)),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: isValid ? () {
                  final newDistribution = TrainingDistribution(
                    fisicaGeneral: (int.tryParse(fisGenCtrl.text) ?? 0) / 100,
                    fisicaEspecial: (int.tryParse(fisEspCtrl.text) ?? 0) / 100,
                    tecnica: (int.tryParse(tecCtrl.text) ?? 0) / 100,
                    tactica: (int.tryParse(tacCtrl.text) ?? 0) / 100,
                    teorica: (int.tryParse(teoCtrl.text) ?? 0) / 100,
                    psicologica: (int.tryParse(psiCtrl.text) ?? 0) / 100,
                  );
                  final updatedMicro = micro.copyWith(type: selectedType, trainingDistribution: newDistribution);
                  final microcycles = List<Microcycle>.from(_macrocycle.microcycles);
                  microcycles[index] = updatedMicro;
                  _updateMacrocycle(_macrocycle.copyWith(microcycles: microcycles));
                  Navigator.of(ctx).pop();
                } : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _percentageField(String label, TextEditingController controller, Color color, {required bool enabled, required VoidCallback onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: enabled ? AppColors.textPrimary : AppColors.textSecondary))),
        SizedBox(
          width: 60,
          child: TextField(
            controller: controller, enabled: enabled,
            keyboardType: TextInputType.number, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: enabled ? color : AppColors.neutral5),
            decoration: InputDecoration(
              isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              suffixText: '%', suffixStyle: TextStyle(fontSize: 11, color: enabled ? color : AppColors.neutral5),
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // DISTRIBUCIÓN DE ENTRENAMIENTO
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildTrainingDistributionSection() {
    if (_macrocycle.microcycles.isEmpty) return _emptySection('Sin microciclos para mostrar distribución');

    final categories = [
      ('FISICA GENERAL', AppColors.accent3, (TrainingDistribution d) => d.fisicaGeneral),
      ('FISICA ESPECIAL', AppColors.accent6, (TrainingDistribution d) => d.fisicaEspecial),
      ('TÉCNICA', AppColors.success, (TrainingDistribution d) => d.tecnica),
      ('TÁTICA', AppColors.accent2, (TrainingDistribution d) => d.tactica),
      ('TEÓRICA', AppColors.error, (TrainingDistribution d) => d.teorica),
      ('PSICOLÓGICA', AppColors.accent5, (TrainingDistribution d) => d.psicologica),
    ];

    return Column(children: [
      Wrap(
        spacing: 12, runSpacing: 6,
        children: categories.map((cat) {
          return Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: cat.$2, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 4),
            Text(cat.$1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          ]);
        }).toList(),
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.neutral8)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.primary10),
            columnSpacing: 12, dataRowMinHeight: 36, dataRowMaxHeight: 44,
            columns: [
              const DataColumn(label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
              ..._macrocycle.microcycles.map((micro) => DataColumn(label: Text('S${micro.number}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
            ],
            rows: categories.map((cat) {
              return DataRow(cells: [
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: cat.$2.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                  child: Text(cat.$1, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cat.$2)),
                )),
                ..._macrocycle.microcycles.map((micro) {
                  final value = cat.$3(micro.trainingDistribution);
                  return DataCell(Text('${(value * 100).round()}%', style: TextStyle(fontSize: 10, color: value > 0 ? AppColors.neutral2 : AppColors.neutral6)));
                }),
              ]);
            }).toList(),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.neutral8)),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Distribución por Semana', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._macrocycle.microcycles.map((micro) {
              final dist = micro.trainingDistribution;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  SizedBox(width: 38, child: Text('S${micro.number}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(height: 18, child: Row(children: [
                        _stackedSegment(dist.fisicaGeneral, categories[0].$2),
                        _stackedSegment(dist.fisicaEspecial, categories[1].$2),
                        _stackedSegment(dist.tecnica, categories[2].$2),
                        _stackedSegment(dist.tactica, categories[3].$2),
                        _stackedSegment(dist.teorica, categories[4].$2),
                        _stackedSegment(dist.psicologica, categories[5].$2),
                      ])),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(width: 28, child: Text(micro.type.label.substring(0, 3), style: const TextStyle(fontSize: 8, color: AppColors.neutral4))),
                ]),
              );
            }),
          ],
        ),
      ),
    ]);
  }

  Widget _stackedSegment(double fraction, Color color) {
    if (fraction <= 0) return const SizedBox.shrink();
    return Expanded(flex: (fraction * 100).round(), child: Container(color: color));
  }

  // ══════════════════════════════════════════════════════════════════════
  // EXPORT
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _exportToExcel(BuildContext context) async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (ctx) => const AlertDialog(
        content: Row(children: [CircularProgressIndicator(color: AppColors.primary), SizedBox(width: 20), Text('Exportando a Excel...')]),
      ));
      final filePath = await MacrocycleExcelExport.exportToExcel(_macrocycle);
      if (context.mounted) { Navigator.of(context).pop(); _showExportSuccessDialog(context, filePath); }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al exportar: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      }
    }
  }

  Future<void> _shareAsExcel(BuildContext context) async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (ctx) => const AlertDialog(
        content: Row(children: [CircularProgressIndicator(color: AppColors.primary), SizedBox(width: 20), Text('Preparando archivo...')]),
      ));
      final filePath = await MacrocycleExcelExport.exportToExcel(_macrocycle);
      if (context.mounted) {
        Navigator.of(context).pop();
        await SharePlus.instance.share(ShareParams(
          files: [XFile(filePath)],
          subject: 'Macrociclo: ${_macrocycle.name}',
          text: 'Macrociclo de ${_macrocycle.athleteName} — '
              '${_macrocycle.startDate.day}/${_macrocycle.startDate.month}/${_macrocycle.startDate.year} '
              'al ${_macrocycle.endDate.day}/${_macrocycle.endDate.month}/${_macrocycle.endDate.year}',
        ));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al compartir: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      }
    }
  }

  void _showExportSuccessDialog(BuildContext context, String filePath) {
    final fileName = filePath.split('/').last;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.check_circle, color: AppColors.success), SizedBox(width: 8), Expanded(child: Text('Exportado exitosamente'))]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('El archivo se ha guardado correctamente:'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.neutral9, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.description_outlined, size: 20, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(child: Text(fileName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ]),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cerrar')),
          Row(mainAxisSize: MainAxisSize.min, children: [
            TextButton.icon(onPressed: () { Navigator.of(ctx).pop(); _openExcelFile(filePath); }, icon: const Icon(Icons.open_in_new, size: 18), label: const Text('Abrir')),
            const SizedBox(width: 4),
            FilledButton.icon(onPressed: () { Navigator.of(ctx).pop(); _shareFile(context, filePath); },
              icon: const Icon(Icons.share_outlined, size: 18), label: const Text('Compartir'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary)),
          ]),
        ],
      ),
    );
  }

  Future<void> _openExcelFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) debugPrint('Error al abrir archivo: ${result.message}');
    } catch (e) { debugPrint('Error al abrir archivo: $e'); }
  }

  Future<void> _shareFile(BuildContext context, String filePath) async {
    try {
      await SharePlus.instance.share(ShareParams(
        files: [XFile(filePath)],
        subject: 'Macrociclo: ${_macrocycle.name}',
        text: 'Macrociclo de ${_macrocycle.athleteName} — '
            '${_macrocycle.startDate.day}/${_macrocycle.startDate.month}/${_macrocycle.startDate.year} '
            'al ${_macrocycle.endDate.day}/${_macrocycle.endDate.month}/${_macrocycle.endDate.year}',
      ));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al compartir: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════

  Widget _sectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
    ]);
  }

  Widget _emptySection(String message) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.neutral9, borderRadius: BorderRadius.circular(10)),
      child: Center(child: Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))),
    );
  }

  Color _colorForPeriod(PeriodType type) {
    switch (type) {
      case PeriodType.preparatorioGeneral: return AppColors.accent3;
      case PeriodType.preparatorioEspecial: return AppColors.accent6;
      case PeriodType.competitivo: return AppColors.error;
      case PeriodType.transicion: return AppColors.success;
    }
  }

  Color _colorForEventType(EventType type) {
    switch (type) {
      case EventType.competencia: return AppColors.error;
      case EventType.concentracion: return AppColors.accent6;
      case EventType.campus: return AppColors.accent5;
      case EventType.evaluacion: return AppColors.accent3;
      case EventType.descanso: return AppColors.success;
      case EventType.otro: return AppColors.neutral4;
    }
  }

  Color _colorForMicrocycleType(MicrocycleType type) {
    switch (type) {
      case MicrocycleType.ordinario: return AppColors.primary;
      case MicrocycleType.choque: return AppColors.accent4;
      case MicrocycleType.recuperacion: return AppColors.success;
      case MicrocycleType.activacion: return AppColors.accent2;
      case MicrocycleType.competitivo: return AppColors.error;
      case MicrocycleType.transitorio: return AppColors.accent5;
    }
  }

  Color _colorForMesocycleType(MesocycleType type) {
    switch (type) {
      case MesocycleType.introductorio: return AppColors.accent3;
      case MesocycleType.desarrollador: return AppColors.primary;
      case MesocycleType.estabilizador: return AppColors.accent6;
      case MesocycleType.competitivo: return AppColors.error;
      case MesocycleType.recuperacion: return AppColors.success;
      case MesocycleType.precompetitivo: return AppColors.accent2;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDateFull(DateTime date) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
