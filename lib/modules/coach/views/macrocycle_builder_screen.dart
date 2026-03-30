import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/macrocycle.dart';
import '../../../data/models/macrocycle_event.dart';
import '../../../data/models/mesocycle.dart';
import '../../../data/providers/macrocycle_provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';

/// Pantalla para construir un macrociclo nuevo.
///
/// Flujo:
/// 1. Seleccionar atleta
/// 2. Definir nombre del macrociclo
/// 3. Seleccionar fecha inicio y fecha fin del año
/// 4. Agregar eventos (competencias, concentraciones, etc.)
/// 5. Calcular y visualizar el macrociclo
class MacrocycleBuilderScreen extends StatefulWidget {
  const MacrocycleBuilderScreen({super.key});

  @override
  State<MacrocycleBuilderScreen> createState() =>
      _MacrocycleBuilderScreenState();
}

class _MacrocycleBuilderScreenState extends State<MacrocycleBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedAthleteId;
  String _selectedAthleteName = '';
  final List<MacrocycleEvent> _events = [];

  int _currentStep = 0;
  bool _isCalculating = false;
  Macrocycle? _previewMacrocycle;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
        title: const Text(
          'Crear Macrociclo',
          style: AppTextStyles.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) {
            if (step < _currentStep) {
              setState(() => _currentStep = step);
            }
          },
          type: StepperType.vertical,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionPrimaryDefault,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size(120, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _currentStep == 3 ? 'Calcular Macro' : 'Siguiente',
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Anterior'),
                    ),
                ],
              ),
            );
          },
          steps: [
            // ── Paso 1: Datos básicos ──────────────────────────────
            Step(
              title: const Text('Datos del macrociclo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: _nameController.text.isNotEmpty
                  ? Text(_nameController.text)
                  : null,
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildStep1BasicData(),
            ),

            // ── Paso 2: Fechas ─────────────────────────────────────
            Step(
              title: const Text('Período del macrociclo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: _startDate != null && _endDate != null
                  ? Text(
                      '${_formatDate(_startDate!)} — ${_formatDate(_endDate!)}')
                  : null,
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildStep2Dates(),
            ),

            // ── Paso 3: Eventos ────────────────────────────────────
            Step(
              title: const Text('Eventos del año',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: _events.isNotEmpty
                  ? Text('${_events.length} eventos')
                  : null,
              isActive: _currentStep >= 2,
              state: _currentStep > 2
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildStep3Events(),
            ),

            // ── Paso 4: Vista previa y guardar ─────────────────────
            Step(
              title: const Text('Vista previa y guardar',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              isActive: _currentStep >= 3,
              state: _currentStep > 3
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildStep4Preview(),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // PASO 1: Datos básicos
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildStep1BasicData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del macrociclo
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del macrociclo',
            hintText: 'Ej: Macrociclo 2026 – Temporada Principal',
            prefixIcon: Icon(Icons.edit_note),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Selección de atleta
        _buildAthleteSelector(),
        const SizedBox(height: 16),

        // Notas
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notas (opcional)',
            hintText: 'Observaciones generales...',
            prefixIcon: Icon(Icons.notes_outlined),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAthleteSelector() {
    final teamProvider = context.watch<TeamProvider>();
    final members = teamProvider.members;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atleta',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (members.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No hay atletas en el equipo. Ingresa el nombre manualmente.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        if (members.isNotEmpty) ...[
          DropdownButtonFormField<int>(
            value: members.any((m) => m.userId == _selectedAthleteId)
                ? _selectedAthleteId
                : null,
            decoration: const InputDecoration(
              hintText: 'Seleccionar atleta',
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: members
                .map((m) => DropdownMenuItem(
                      value: m.userId,
                      child: Text(m.fullName),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedAthleteId = value;
                _selectedAthleteName = members
                    .firstWhere((m) => m.userId == value)
                    .fullName;
              });
            },
            validator: (value) {
              if (value == null) return 'Selecciona un atleta';
              return null;
            },
          ),
        ] else ...[
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Nombre del atleta',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (value) {
              _selectedAthleteName = value;
              _selectedAthleteId = value.hashCode;
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre del atleta es requerido';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // PASO 2: Fechas
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildStep2Dates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona las dos fechas del año que definen el macrociclo.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Fecha de inicio
        _buildDateSelector(
          label: 'Fecha de inicio',
          icon: Icons.play_arrow_outlined,
          date: _startDate,
          onTap: () => _selectDate(isStart: true),
        ),
        const SizedBox(height: 12),

        // Fecha de fin
        _buildDateSelector(
          label: 'Fecha de fin',
          icon: Icons.stop_outlined,
          date: _endDate,
          onTap: () => _selectDate(isStart: false),
        ),

        if (_startDate != null && _endDate != null) ...[
          const SizedBox(height: 16),
          _buildDateSummary(),
        ],
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.neutral9,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null ? AppColors.primary : AppColors.neutral7,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: date != null
                    ? AppColors.primary
                    : AppColors.neutral5,
                size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? _formatDateFull(date)
                        : 'Seleccionar fecha',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: date != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: date != null
                          ? AppColors.textPrimary
                          : AppColors.neutral5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today,
                color: AppColors.neutral5, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSummary() {
    final days = _endDate!.difference(_startDate!).inDays + 1;
    final weeks = (days / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Duración: $days días ($weeks semanas aprox.)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? DateTime(now.year, 1, 1))
        : (_endDate ?? DateTime(now.year, 12, 31));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2, 12, 31),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Asegurar coherencia
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // PASO 3: Eventos
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildStep3Events() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agrega los eventos (competencias, campus, etc.) que se desarrollarán durante el año.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Botón agregar evento
        OutlinedButton.icon(
          onPressed: _showAddEventDialog,
          icon: const Icon(Icons.add),
          label: const Text('Agregar evento'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
        const SizedBox(height: 12),

        // Lista de eventos
        if (_events.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.neutral9,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.event_outlined,
                      color: AppColors.neutral5, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Sin eventos agregados',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(_events.length, (index) {
            final event = _events[index];
            return _buildEventCard(event, index);
          }),
      ],
    );
  }

  Widget _buildEventCard(MacrocycleEvent event, int index) {
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
            height: 48,
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
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    if (event.location != null &&
                        event.location!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.neutral5),
                      const SizedBox(width: 2),
                      Text(
                        event.location!,
                        style: AppTextStyles.bodySmall.copyWith(
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
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(event.startDate)} – ${_formatDate(event.endDate)} (${event.durationDays} días)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _events.removeAt(index));
            },
            icon: const Icon(Icons.close,
                color: AppColors.neutral5, size: 18),
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
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

  void _showAddEventDialog() {
    final nameCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    DateTime? eventStart;
    DateTime? eventEnd;
    EventType selectedType = EventType.competencia;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Agregar Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tipo de evento
                DropdownButtonFormField<EventType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de evento',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: EventType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Nombre
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del evento',
                    hintText: 'Ej: Panamericano 2026',
                    prefixIcon: Icon(Icons.edit),
                  ),
                ),
                const SizedBox(height: 12),

                // Ubicación
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación (opcional)',
                    hintText: 'Ej: Lima, Perú',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Fechas del evento
                Row(
                  children: [
                    Expanded(
                      child: _dialogDateButton(
                        label: 'Inicio',
                        date: eventStart,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate:
                                eventStart ?? _startDate ?? DateTime.now(),
                            firstDate: _startDate ??
                                DateTime(DateTime.now().year - 1),
                            lastDate: _endDate ??
                                DateTime(DateTime.now().year + 2, 12, 31),
                          );
                          if (picked != null) {
                            setDialogState(() => eventStart = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _dialogDateButton(
                        label: 'Fin',
                        date: eventEnd,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate:
                                eventEnd ?? eventStart ?? DateTime.now(),
                            firstDate: eventStart ??
                                _startDate ??
                                DateTime(DateTime.now().year - 1),
                            lastDate: _endDate ??
                                DateTime(DateTime.now().year + 2, 12, 31),
                          );
                          if (picked != null) {
                            setDialogState(() => eventEnd = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    eventStart == null ||
                    eventEnd == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Completa nombre y fechas del evento'),
                      backgroundColor: AppColors.warning,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  return;
                }

                final event = MacrocycleEvent(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),
                  name: nameCtrl.text.trim(),
                  type: selectedType,
                  startDate: eventStart!,
                  endDate: eventEnd!,
                  location: locationCtrl.text.trim().isNotEmpty
                      ? locationCtrl.text.trim()
                      : null,
                );

                setState(() => _events.add(event));
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionPrimaryDefault,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.neutral9,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neutral7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date != null ? _formatDate(date) : 'Seleccionar',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    date != null ? FontWeight.w600 : FontWeight.w400,
                color: date != null
                    ? AppColors.textPrimary
                    : AppColors.neutral5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // PASO 4: Vista previa
  // ══════════════════════════════════════════════════════════════════════

  Widget _buildStep4Preview() {
    if (_isCalculating) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Calculando macrociclo...'),
            ],
          ),
        ),
      );
    }

    if (_previewMacrocycle == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.neutral9,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Presiona "Calcular Macro" para generar el macrociclo.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final macro = _previewMacrocycle!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(macro.name, style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Atleta: ${macro.athleteName}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: 20),
              _previewRow(
                  'Duración', '${macro.totalWeeks} semanas (${macro.totalDays} días)'),
              _previewRow('Etapas', '${macro.periods.length}'),
              _previewRow('Mesociclos', '${macro.mesocycles.length}'),
              _previewRow('Microciclos', '${macro.microcycles.length}'),
              _previewRow('Eventos', '${macro.events.length}'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Períodos
        if (macro.periods.isNotEmpty) ...[
          _previewSectionTitle('Etapas / Períodos'),
          ...macro.periods.map((p) => _buildPeriodChip(p)),
          const SizedBox(height: 12),
        ],

        // Mesociclos
        if (macro.mesocycles.isNotEmpty) ...[
          _previewSectionTitle('Mesociclos'),
          ...macro.mesocycles.map((m) => _buildMesocycleChip(m)),
          const SizedBox(height: 12),
        ],

        const SizedBox(height: 20),

        // Botón guardar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveMacrocycle,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Guardar Macrociclo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _previewSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
      ),
    );
  }

  Widget _buildPeriodChip(MacrocyclePeriod period) {
    final color = _colorForPeriod(period.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                Text(
                  '${_formatDate(period.startDate)} – ${_formatDate(period.endDate)} · ${period.weeks} sem.',
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

  Widget _buildMesocycleChip(Mesocycle meso) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutral9,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${meso.number}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meso.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${meso.weeks} semanas · ${meso.type.label}',
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

  // ══════════════════════════════════════════════════════════════════════
  // NAVEGACIÓN DE STEPS
  // ══════════════════════════════════════════════════════════════════════

  void _onStepContinue() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ingresa un nombre para el macrociclo'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          return;
        }
        if (_selectedAthleteId == null &&
            _selectedAthleteName.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Selecciona o ingresa un atleta'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          return;
        }
        setState(() => _currentStep = 1);
        break;

      case 1:
        if (_startDate == null || _endDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Selecciona ambas fechas'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          return;
        }
        if (_endDate!.isBefore(_startDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'La fecha de fin debe ser posterior a la de inicio'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          return;
        }
        setState(() => _currentStep = 2);
        break;

      case 2:
        setState(() => _currentStep = 3);
        break;

      case 3:
        _calculateMacrocycle();
        break;
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _calculateMacrocycle() {
    setState(() => _isCalculating = true);

    // Obtener coachId y teamId de la sesión / equipo actual
    final session = context.read<SessionProvider>().session;
    final team = context.read<TeamProvider>().selectedTeam;
    final coachId = session?.userId ?? team?.coachId;

    // Simular un pequeño delay para UX
    Future.delayed(const Duration(milliseconds: 500), () {
      final macro = MacrocycleProvider.buildMacrocycle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        athleteId: _selectedAthleteId ?? _selectedAthleteName.hashCode,
        athleteName: _selectedAthleteName,
        name: _nameController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        events: _events,
        coachId: coachId,
        teamId: team?.teamId,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      setState(() {
        _previewMacrocycle = macro;
        _isCalculating = false;
      });
    });
  }

  Future<void> _saveMacrocycle() async {
    if (_previewMacrocycle == null) return;

    final error = await context
        .read<MacrocycleProvider>()
        .addMacrocycle(_previewMacrocycle!);

    if (!mounted) return;

    if (error != null) {
      // La API rechazó la creación → mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Macrociclo "${_previewMacrocycle!.name}" guardado exitosamente'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDateFull(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
