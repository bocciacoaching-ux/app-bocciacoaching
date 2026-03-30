import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/training_session.dart';
import '../../../data/providers/training_session_provider.dart';

/// Pantalla de formulario para crear o editar una sesión de entrenamiento.
///
/// Si se recibe un [TrainingSession] existente, se usa en modo edición.
/// Si no, se crea una nueva sesión con las 4 partes predeterminadas.
class TrainingSessionFormScreen extends StatefulWidget {
  /// ID del microciclo al que pertenece la sesión.
  final int microcycleId;

  /// Nombre descriptivo del microciclo (para mostrar en header).
  final String? microcycleLabel;

  /// Sesión existente para editar (null = modo creación).
  final TrainingSession? session;

  const TrainingSessionFormScreen({
    super.key,
    required this.microcycleId,
    this.microcycleLabel,
    this.session,
  });

  @override
  State<TrainingSessionFormScreen> createState() =>
      _TrainingSessionFormScreenState();
}

class _TrainingSessionFormScreenState
    extends State<TrainingSessionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedDay;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _throwPercentageCtrl;
  late final TextEditingController _totalThrowsBaseCtrl;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSaving = false;

  bool get _isEditing => widget.session != null;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _selectedDay = s?.dayOfWeek ?? DayOfWeek.lunes.label;
    _durationCtrl = TextEditingController(
      text: s != null ? '${s.duration}' : '120',
    );
    _throwPercentageCtrl = TextEditingController(
      text: s != null ? s.throwPercentage.toStringAsFixed(0) : '100',
    );
    _totalThrowsBaseCtrl = TextEditingController(
      text: s != null ? '${s.totalThrowsBase}' : '60',
    );
    if (s?.startTime != null) {
      _startTime =
          TimeOfDay(hour: s!.startTime!.hour, minute: s.startTime!.minute);
    }
    if (s?.endTime != null) {
      _endTime =
          TimeOfDay(hour: s!.endTime!.hour, minute: s.endTime!.minute);
    }
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _throwPercentageCtrl.dispose();
    _totalThrowsBaseCtrl.dispose();
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
        title: Text(
          _isEditing ? 'Editar Sesión' : 'Nueva Sesión',
          style: AppTextStyles.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.microcycleLabel != null) ...[
                _buildMicrocycleInfo(),
                const SizedBox(height: 20),
              ],
              _buildDaySelector(),
              const SizedBox(height: 20),
              _buildDurationField(),
              const SizedBox(height: 20),
              _buildTimeFields(),
              const SizedBox(height: 20),
              _buildThrowsSection(),
              const SizedBox(height: 20),
              _buildThrowsPreview(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Info del microciclo ──────────────────────────────────────────

  Widget _buildMicrocycleInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary20),
      ),
      child: Row(
        children: [
          const Icon(Icons.grid_view_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            widget.microcycleLabel!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Selector de día ──────────────────────────────────────────────

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Día de la semana'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DayOfWeek.values.map((day) {
            final isSelected = day.label == _selectedDay;
            return GestureDetector(
              onTap: () => setState(() => _selectedDay = day.label),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.neutral7,
                  ),
                ),
                child: Text(
                  day.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Duración ─────────────────────────────────────────────────────

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Duración (minutos)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _durationCtrl,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Requerido';
            final n = int.tryParse(v);
            if (n == null || n <= 0) return 'Debe ser mayor a 0';
            return null;
          },
          decoration: _inputDecoration(
            hint: 'Ej. 120',
            prefixIcon: Icons.timer_outlined,
          ),
        ),
      ],
    );
  }

  // ── Horarios ─────────────────────────────────────────────────────

  Widget _buildTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Horario (opcional)'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _timePicker(
                label: 'Inicio',
                value: _startTime,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _startTime ?? const TimeOfDay(hour: 8, minute: 0),
                  );
                  if (picked != null) setState(() => _startTime = picked);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _timePicker(
                label: 'Fin',
                value: _endTime,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _endTime ?? const TimeOfDay(hour: 10, minute: 0),
                  );
                  if (picked != null) setState(() => _endTime = picked);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _timePicker({
    required String label,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(
              value != null ? Icons.access_time_filled : Icons.access_time,
              size: 20,
              color: value != null ? AppColors.primary : AppColors.neutral5,
            ),
            const SizedBox(width: 8),
            Text(
              value != null
                  ? '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                  : label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: value != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Lanzamientos ─────────────────────────────────────────────────

  Widget _buildThrowsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_baseball_outlined,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Lanzamientos',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _totalThrowsBaseCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Requerido';
              final n = int.tryParse(v);
              if (n == null || n < 0) return 'Debe ser un número válido';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Ej. 60',
              label: 'Base total de lanzamientos',
              prefixIcon: Icons.sports_baseball,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _throwPercentageCtrl,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Requerido';
              final n = double.tryParse(v);
              if (n == null || n < 0 || n > 100) {
                return 'Debe ser entre 0 y 100';
              }
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Ej. 100',
              label: 'Porcentaje de lanzamientos (%)',
              prefixIcon: Icons.percent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThrowsPreview() {
    final base = int.tryParse(_totalThrowsBaseCtrl.text) ?? 0;
    final pct = double.tryParse(_throwPercentageCtrl.text) ?? 0;
    final calculated = ((pct / 100.0) * base).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent5.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent5.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calculate_outlined,
              color: AppColors.accent5, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Máximo de lanzamientos calculado',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accent5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$calculated lanzamientos',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.accent5,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Botón guardar ────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveSession,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(_isEditing ? Icons.save_outlined : Icons.add),
        label: Text(_isEditing ? 'Guardar Cambios' : 'Crear Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionPrimaryDefault,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.actionPrimaryDisabled,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Guardar ──────────────────────────────────────────────────────

  Future<void> _saveSession() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TrainingSessionProvider>();
    final duration = int.tryParse(_durationCtrl.text) ?? 0;
    final pct = double.tryParse(_throwPercentageCtrl.text) ?? 0;
    final base = int.tryParse(_totalThrowsBaseCtrl.text) ?? 0;
    final now = DateTime.now();

    DateTime? startDt;
    if (_startTime != null) {
      startDt = DateTime(
          now.year, now.month, now.day, _startTime!.hour, _startTime!.minute);
    }
    DateTime? endDt;
    if (_endTime != null) {
      endDt = DateTime(
          now.year, now.month, now.day, _endTime!.hour, _endTime!.minute);
    }

    String? error;

    if (_isEditing) {
      final updated = widget.session!.copyWith(
        dayOfWeek: _selectedDay,
        duration: duration,
        throwPercentage: pct,
        totalThrowsBase: base,
        startTime: startDt,
        endTime: endDt,
      );
      error = await provider.updateSession(updated);
    } else {
      error = await provider.createSessionWithDefaultParts(
        microcycleId: widget.microcycleId,
        dayOfWeek: _selectedDay,
        duration: duration,
        throwPercentage: pct,
        totalThrowsBase: base,
        startTime: startDt,
        endTime: endDt,
      );
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Sesión actualizada exitosamente'
              : 'Sesión creada exitosamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    String? label,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.primary, size: 20)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: AppColors.surface,
    );
  }
}
