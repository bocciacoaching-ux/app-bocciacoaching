import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/training_session.dart';
import '../../../data/providers/training_session_provider.dart';

/// Pantalla completa para agregar o editar una sección de sesión.
///
/// Incluye todos los campos: nombre, lanzamientos, diagonal propia/rival,
/// hora inicio/fin, observación y (en edición) estado.
class SectionFormScreen extends StatefulWidget {
  /// ID de la parte de sesión a la que pertenece la sección.
  final int sessionPartId;

  /// Nombre de la parte (para mostrar en header, ej. "Propulsion").
  final String? partName;

  /// Sección existente (null = modo creación).
  final SessionSection? section;

  const SectionFormScreen({
    super.key,
    required this.sessionPartId,
    this.partName,
    this.section,
  });

  @override
  State<SectionFormScreen> createState() => _SectionFormScreenState();
}

class _SectionFormScreenState extends State<SectionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _throwsCtrl;
  late final TextEditingController _obsCtrl;

  late bool _isOwnDiagonal;
  String? _selectedStatus;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSaving = false;

  bool get _isEditing => widget.section != null;

  @override
  void initState() {
    super.initState();
    final s = widget.section;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _throwsCtrl =
        TextEditingController(text: s?.numberOfThrows.toString() ?? '0');
    _obsCtrl = TextEditingController(text: s?.observation ?? '');
    _isOwnDiagonal = s?.isOwnDiagonal ?? true;
    _selectedStatus = s?.status;

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
    _nameCtrl.dispose();
    _throwsCtrl.dispose();
    _obsCtrl.dispose();
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
          _isEditing ? 'Editar Sección' : 'Nueva Sección',
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
              if (widget.partName != null) ...[
                _buildPartInfo(),
                const SizedBox(height: 20),
              ],
              _buildNameField(),
              const SizedBox(height: 20),
              _buildThrowsField(),
              const SizedBox(height: 20),
              _buildDiagonalSelector(),
              const SizedBox(height: 20),
              _buildTimeFields(),
              const SizedBox(height: 20),
              if (_isEditing) ...[
                _buildStatusSelector(),
                const SizedBox(height: 20),
              ],
              _buildObservationField(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Part info banner ─────────────────────────────────────────────

  Widget _buildPartInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary20),
      ),
      child: Row(
        children: [
          const Icon(Icons.view_agenda_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            widget.partName!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Nombre ───────────────────────────────────────────────────────

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Nombre de la sección'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameCtrl,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Requerido' : null,
          decoration: _inputDecoration(
            hint: 'Ej. Fase 1 – Corta distancia',
            prefixIcon: Icons.label_outline,
          ),
        ),
      ],
    );
  }

  // ── Lanzamientos ─────────────────────────────────────────────────

  Widget _buildThrowsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Número de lanzamientos'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _throwsCtrl,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Requerido';
            final n = int.tryParse(v);
            if (n == null || n < 0) return 'Debe ser un número válido';
            return null;
          },
          decoration: _inputDecoration(
            hint: 'Ej. 12',
            prefixIcon: Icons.sports_baseball_outlined,
          ),
        ),
      ],
    );
  }

  // ── Diagonal ─────────────────────────────────────────────────────

  Widget _buildDiagonalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Tipo de diagonal'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _diagonalOption(
                icon: Icons.person,
                label: 'Diagonal propia',
                isSelected: _isOwnDiagonal,
                onTap: () => setState(() => _isOwnDiagonal = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _diagonalOption(
                icon: Icons.person_outline,
                label: 'Diagonal rival',
                isSelected: !_isOwnDiagonal,
                onTap: () => setState(() => _isOwnDiagonal = false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _diagonalOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral7,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
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
                    initialTime:
                        _startTime ?? const TimeOfDay(hour: 8, minute: 0),
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
                    initialTime:
                        _endTime ?? const TimeOfDay(hour: 9, minute: 0),
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

  // ── Estado (solo edición) ────────────────────────────────────────

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Estado de la sección'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SessionSectionStatus.values.map((status) {
            final isSelected = status.label == _selectedStatus;
            final color = _statusColor(status.label);
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedStatus = status.label),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : AppColors.neutral9,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : AppColors.neutral7,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Observación ──────────────────────────────────────────────────

  Widget _buildObservationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Observación (opcional)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _obsCtrl,
          maxLines: 4,
          decoration: _inputDecoration(
            hint: 'Notas, comentarios o instrucciones...',
            prefixIcon: Icons.notes_outlined,
          ),
        ),
      ],
    );
  }

  // ── Botón guardar ────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveSection,
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
        label: Text(_isEditing ? 'Guardar Cambios' : 'Agregar Sección'),
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

  Future<void> _saveSection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TrainingSessionProvider>();
    final throws = int.tryParse(_throwsCtrl.text) ?? 0;
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

    dynamic result;

    if (_isEditing) {
      final updated = widget.section!.copyWith(
        name: _nameCtrl.text.trim(),
        numberOfThrows: throws,
        isOwnDiagonal: _isOwnDiagonal,
        status: _selectedStatus,
        startTime: startDt,
        endTime: endDt,
        observation: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      );
      result = await provider.updateSection(updated);
    } else {
      result = await provider.addSection(
        sessionPartId: widget.sessionPartId,
        name: _nameCtrl.text.trim(),
        numberOfThrows: throws,
        isOwnDiagonal: _isOwnDiagonal,
        startTime: startDt,
        endTime: endDt,
        observation: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Sección actualizada exitosamente'
              : 'Sección agregada exitosamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop(true); // true = hubo cambios
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al guardar la sección'),
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
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
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
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: AppColors.surface,
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'Programada':
        return AppColors.accent2;
      case 'EnProceso':
        return AppColors.accent3;
      case 'Terminada':
        return AppColors.accent5;
      case 'Finalizada':
        return AppColors.success;
      case 'Cancelada':
        return AppColors.error;
      default:
        return AppColors.neutral5;
    }
  }
}
