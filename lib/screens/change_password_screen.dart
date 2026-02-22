import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../services/user_service.dart';
import '../theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _loading = false;
  String? _errorMessage;
  bool _success = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // ── Enviar formulario ─────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
      _success = false;
    });

    if (!_formKey.currentState!.validate()) return;

    final session = context.read<SessionProvider>().session;
    if (session == null) {
      setState(() =>
          _errorMessage = 'Sesión no encontrada. Inicia sesión de nuevo.');
      return;
    }

    setState(() => _loading = true);

    final result = await UserService().updatePassword(
      userId: session.userId,
      currentPassword: _currentPasswordCtrl.text,
      newPassword: _newPasswordCtrl.text,
      confirmPassword: _confirmPasswordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      setState(() => _success = true);
      _currentPasswordCtrl.clear();
      _newPasswordCtrl.clear();
      _confirmPasswordCtrl.clear();
    } else {
      setState(() {
        _errorMessage = result['message'] as String? ??
            'No se pudo actualizar la contraseña.';
      });
    }
  }

  // ── Decoración de inputs ──────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, color: AppColors.neutral5, size: 20),
      hintText: hint,
      hintStyle:
          const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      suffixIcon: suffixIcon,
    );
  }

  // ── Etiqueta de campo ─────────────────────────────────────────────
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const TextSpan(
            text: ' *',
            style: TextStyle(
                color: AppColors.error, fontWeight: FontWeight.w600),
          ),
        ]),
      ),
    );
  }

  // ── Banner de error ───────────────────────────────────────────────
  Widget _errorBanner(String message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.error.withAlpha((0.35 * 255).round())),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner de éxito ───────────────────────────────────────────────
  Widget _successBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.success.withAlpha((0.35 * 255).round())),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: AppColors.success, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '¡Contraseña actualizada correctamente! Ya puedes usar tu nueva contraseña.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.success,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chip de requisito de contraseña ──────────────────────────────
  Widget _requirementChip(String label, bool met) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 14,
          color: met ? AppColors.success : AppColors.neutral5,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: met ? AppColors.success : AppColors.neutral5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final newPwd = _newPasswordCtrl.text;
    final hasMinLength = newPwd.length >= 8;
    final hasUppercase = newPwd.contains(RegExp(r'[A-Z]'));
    final hasNumber = newPwd.contains(RegExp(r'[0-9]'));
    final hasSpecial =
        newPwd.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'));

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── AppBar ──────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Cambiar contraseña',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Cabecera informativa ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary30),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary20,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.lock_reset_rounded,
                              color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Actualiza tu contraseña',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Por tu seguridad, elige una contraseña fuerte que no uses en otros sitios.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.neutral4,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Tarjeta del formulario ───────────────────────
                  Material(
                    elevation: 3,
                    shadowColor: AppColors.primary20,
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Contraseña actual ─────────────────
                            _label('Contraseña actual'),
                            TextFormField(
                              controller: _currentPasswordCtrl,
                              obscureText: _obscureCurrent,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                hint: '••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureCurrent
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.neutral5,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureCurrent = !_obscureCurrent),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Introduce tu contraseña actual';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // ── Nueva contraseña ──────────────────
                            _label('Nueva contraseña'),
                            TextFormField(
                              controller: _newPasswordCtrl,
                              obscureText: _obscureNew,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => setState(() {}),
                              decoration: _inputDecoration(
                                hint: '••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNew
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.neutral5,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureNew = !_obscureNew),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Introduce la nueva contraseña';
                                }
                                if (v.length < 8) {
                                  return 'Mínimo 8 caracteres';
                                }
                                if (v == _currentPasswordCtrl.text) {
                                  return 'La nueva contraseña debe ser diferente a la actual';
                                }
                                return null;
                              },
                            ),

                            // ── Indicadores de requisitos ─────────
                            if (_newPasswordCtrl.text.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 12,
                                runSpacing: 6,
                                children: [
                                  _requirementChip(
                                      '8 caracteres', hasMinLength),
                                  _requirementChip('Mayúscula', hasUppercase),
                                  _requirementChip('Número', hasNumber),
                                  _requirementChip('Símbolo', hasSpecial),
                                ],
                              ),
                            ],

                            const SizedBox(height: 20),

                            // ── Confirmar nueva contraseña ────────
                            _label('Confirmar nueva contraseña'),
                            TextFormField(
                              controller: _confirmPasswordCtrl,
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  _loading ? null : _submit(),
                              decoration: _inputDecoration(
                                hint: '••••••••',
                                prefixIcon: Icons.lock_outline_rounded,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.neutral5,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Confirma la nueva contraseña';
                                }
                                if (v != _newPasswordCtrl.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // ── Banner de feedback ────────────────
                            if (_errorMessage != null) ...[
                              _errorBanner(_errorMessage!),
                              const SizedBox(height: 16),
                            ],
                            if (_success) ...[
                              _successBanner(),
                              const SizedBox(height: 16),
                            ],

                            // ── Botón principal ───────────────────
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.actionPrimaryDefault,
                                  foregroundColor: AppColors.white,
                                  disabledBackgroundColor:
                                      AppColors.actionPrimaryDisabled,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.white,
                                        ),
                                      )
                                    : const Text('Actualizar contraseña'),
                              ),
                            ),

                            if (_success) ...[
                              const SizedBox(height: 12),
                              // Botón secundario para volver
                              SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                        color: AppColors.primary, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Volver al perfil'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Nota de seguridad ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 14, color: AppColors.neutral5),
                      const SizedBox(width: 6),
                      Text(
                        'Tu información viaja cifrada de forma segura.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.neutral5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
