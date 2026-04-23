import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/team_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/team.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';

/// Pantalla de formulario para crear o editar un equipo.
///
/// Si recibe un [Team] existente se usa en modo edición, en caso contrario
/// se utiliza para crear un nuevo equipo.
class TeamFormScreen extends StatefulWidget {
  /// Equipo existente a editar. Si es `null` se trata de creación.
  final Team? team;

  const TeamFormScreen({super.key, this.team});

  @override
  State<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends State<TeamFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _imageCtrl;

  String? _selectedCountry;
  String? _selectedRegion;

  // Categorías
  bool _bc1 = false;
  bool _bc2 = false;
  bool _bc3 = false;
  bool _bc4 = false;
  bool _pairs = false;
  bool _teams = false;

  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.team != null;

  // Listas de selección (alineadas con register_screen).
  static const List<String> _countries = [
    'Colombia',
    'Argentina',
    'España',
    'México',
    'Chile',
    'Perú',
    'Ecuador',
    'Brasil',
    'Estados Unidos',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.team;
    _nameCtrl = TextEditingController(text: t?.nameTeam ?? '');
    _descriptionCtrl = TextEditingController(text: t?.description ?? '');
    _imageCtrl = TextEditingController(text: t?.image ?? '');
    _selectedCountry = t?.country;
    _selectedRegion = t?.region;
    _bc1 = t?.bc1 ?? false;
    _bc2 = t?.bc2 ?? false;
    _bc3 = t?.bc3 ?? false;
    _bc4 = t?.bc4 ?? false;
    _pairs = t?.pairs ?? false;
    _teams = t?.teams ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Editar Equipo' : 'Nuevo Equipo',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 20),
                _buildSectionTitle('Información general'),
                const SizedBox(height: 12),
                _buildGeneralCard(),
                const SizedBox(height: 20),
                _buildSectionTitle('Ubicación'),
                const SizedBox(height: 12),
                _buildLocationCard(),
                const SizedBox(height: 20),
                _buildSectionTitle('Categorías habilitadas'),
                const SizedBox(height: 12),
                _buildCategoriesCard(),
                const SizedBox(height: 20),
                _buildSectionTitle('Modalidades'),
                const SizedBox(height: 12),
                _buildModalitiesCard(),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  _buildErrorBanner(_errorMessage!),
                  const SizedBox(height: 14),
                ],
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header card ─────────────────────────────────────────────────────────

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isEditing
                  ? Icons.edit_outlined
                  : Icons.group_add_outlined,
              color: AppColors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? 'Editar información del equipo'
                      : 'Crear nuevo equipo',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing
                      ? 'Actualiza los datos generales, ubicación y categorías habilitadas.'
                      : 'Completa los datos para registrar un nuevo equipo de boccia.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Información general ─────────────────────────────────────────────────

  Widget _buildGeneralCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Nombre del equipo', required: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'El nombre es obligatorio';
              if (value.length < 3) return 'Mínimo 3 caracteres';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Ej. Selección Boccia Bogotá',
              prefixIcon: Icons.shield_outlined,
            ),
          ),
          const SizedBox(height: 16),
          _label('Descripción', required: false),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descriptionCtrl,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              hint: 'Describe brevemente el equipo (opcional)',
              prefixIcon: Icons.description_outlined,
            ),
          ),
          const SizedBox(height: 16),
          _label('URL de la imagen', required: false),
          const SizedBox(height: 6),
          TextFormField(
            controller: _imageCtrl,
            keyboardType: TextInputType.url,
            decoration: _inputDecoration(
              hint: 'https://...',
              prefixIcon: Icons.image_outlined,
            ),
          ),
        ],
      ),
    );
  }

  // ── Ubicación ───────────────────────────────────────────────────────────

  Widget _buildLocationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('País', required: false),
          const SizedBox(height: 6),
          _selector(
            icon: Icons.public_outlined,
            value: _selectedCountry,
            placeholder: 'Selecciona un país',
            onTap: () => _showSelectionSheet(
              title: 'Selecciona país',
              items: _countries,
              selected: _selectedCountry,
              onSelected: (v) => setState(() => _selectedCountry = v),
            ),
            onClear: _selectedCountry != null
                ? () => setState(() => _selectedCountry = null)
                : null,
          ),
          const SizedBox(height: 16),
          _label('Región / Ciudad', required: false),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: _selectedRegion,
            textCapitalization: TextCapitalization.words,
            onChanged: (v) =>
                _selectedRegion = v.trim().isEmpty ? null : v.trim(),
            decoration: _inputDecoration(
              hint: 'Ej. Bogotá D.C.',
              prefixIcon: Icons.location_on_outlined,
            ),
          ),
        ],
      ),
    );
  }

  // ── Categorías (BC1-BC4) ────────────────────────────────────────────────

  Widget _buildCategoriesCard() {
    final items = <_CategoryItem>[
      _CategoryItem('BC1', _bc1, (v) => setState(() => _bc1 = v)),
      _CategoryItem('BC2', _bc2, (v) => setState(() => _bc2 = v)),
      _CategoryItem('BC3', _bc3, (v) => setState(() => _bc3 = v)),
      _CategoryItem('BC4', _bc4, (v) => setState(() => _bc4 = v)),
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona las categorías que entrenará el equipo.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items
                .map((it) => _categoryChip(
                      label: it.label,
                      selected: it.value,
                      onTap: () => it.onChanged(!it.value),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.neutral7,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              size: 16,
              color: selected ? AppColors.white : AppColors.neutral5,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? AppColors.white : AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modalidades (Parejas / Equipos) ─────────────────────────────────────

  Widget _buildModalitiesCard() {
    return _card(
      child: Column(
        children: [
          _switchTile(
            icon: Icons.people_outline,
            title: 'Parejas',
            subtitle: 'Habilitar modalidad por parejas',
            value: _pairs,
            onChanged: (v) => setState(() => _pairs = v),
          ),
          const Divider(height: 18, color: AppColors.neutral8),
          _switchTile(
            icon: Icons.groups_outlined,
            title: 'Equipos',
            subtitle: 'Habilitar modalidad por equipos',
            value: _teams,
            onChanged: (v) => setState(() => _teams = v),
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  // ── Botón guardar ───────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _save,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Icon(_isEditing ? Icons.save_outlined : Icons.add_rounded),
        label: Text(
          _isEditing ? 'Guardar cambios' : 'Crear equipo',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionPrimaryDefault,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.actionPrimaryDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ── Banner de error ─────────────────────────────────────────────────────

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withAlpha(76)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Guardar ─────────────────────────────────────────────────────────────

  Future<void> _save() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final session = context.read<SessionProvider>().session;
    if (session == null) {
      setState(() => _errorMessage = 'Sesión no válida. Vuelve a iniciar sesión.');
      return;
    }

    setState(() => _isSaving = true);

    final service = TeamService();
    bool success = false;

    try {
      if (_isEditing) {
        final result = await service.updateTeam(
          teamId: widget.team!.teamId,
          image: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
          bc1: _bc1,
          bc2: _bc2,
          bc3: _bc3,
          bc4: _bc4,
          country: _selectedCountry,
          region: _selectedRegion,
        );
        success = result == true;
      } else {
        final result = await service.addNewTeam(
          nameTeam: _nameCtrl.text.trim(),
          description: _descriptionCtrl.text.trim().isEmpty
              ? null
              : _descriptionCtrl.text.trim(),
          coachId: session.userId,
          image: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
          bc1: _bc1,
          bc2: _bc2,
          bc3: _bc3,
          bc4: _bc4,
          pairs: _pairs,
          teams: _teams,
          country: _selectedCountry,
          region: _selectedRegion,
        );
        success = result != null && (result['success'] == true);
      }
    } catch (_) {
      success = false;
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      // Refrescar listado de equipos del coach.
      await context.read<TeamProvider>().fetchTeams(session.userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Equipo actualizado correctamente'
              : 'Equipo creado correctamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = _isEditing
            ? 'No se pudo actualizar el equipo. Intenta nuevamente.'
            : 'No se pudo crear el equipo. Intenta nuevamente.';
      });
    }
  }

  // ── Helpers de UI ───────────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.titleMedium.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _label(String text, {required bool required}) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (required)
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
      ]),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, color: AppColors.neutral5, size: 20),
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _selector({
    required IconData icon,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final hasValue = value != null && value.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neutral5, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasValue ? value : placeholder,
                style: TextStyle(
                  color: hasValue
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            if (hasValue && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.close_rounded,
                      color: AppColors.neutral5, size: 18),
                ),
              ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.neutral5, size: 22),
          ],
        ),
      ),
    );
  }

  void _showSelectionSheet({
    required String title,
    required List<String> items,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral7,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.neutral8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final isSelected = item == selected;
                    return ListTile(
                      title: Text(
                        item,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: AppColors.primary)
                          : null,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onSelected(item);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ── Modelo auxiliar para iterar categorías ─────────────────────────────────

class _CategoryItem {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _CategoryItem(this.label, this.value, this.onChanged);
}
