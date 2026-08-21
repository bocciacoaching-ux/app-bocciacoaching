import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/email_service.dart';
import 'widgets/responsive_auth_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _showPassword = false;

  final List<TextEditingController> _codeCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeNodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  String? _errorMessage;
  int _step = 0; // 0 = email, 1 = code, 2 = new password

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    for (var i = 0; i < _codeCtrls.length; i++) {
      _codeCtrls[i].addListener(() {
        final text = _codeCtrls[i].text;
        if (text.isNotEmpty && i < _codeCtrls.length - 1) {
          _codeNodes[i + 1].requestFocus();
        }
        if (_codeCtrls.every((c) => c.text.trim().isNotEmpty)) {
          _verifyCode();
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    for (final c in _codeCtrls) c.dispose();
    for (final n in _codeNodes) n.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _animController.reset();
    setState(() {
      _step = step;
      _errorMessage = null;
    });
    _animController.forward();
  }

  bool get _emailValid {
    final v = _emailCtrl.text.trim();
    return RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v);
  }

  bool get _pwValid => _passwordCtrl.text.length >= 6;
  bool get _pwMatch => _passwordCtrl.text == _confirmPasswordCtrl.text;

  Future<void> _sendCode() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final code = (100000 + Random().nextInt(900000)).toString();
    final result = await EmailService().sendCodeVerify(
      toEmail: _emailCtrl.text.trim(),
      code: code,
      minutesValid: 10,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result != null) {
      _goToStep(1);
    } else {
      setState(() => _errorMessage = 'No se pudo enviar el código.');
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeCtrls.map((c) => c.text.trim()).join();
    if (code.length < 6) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final result = await EmailService().validateCode(
      toEmail: _emailCtrl.text.trim(),
      code: code,
      minutesValid: 10,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result != null) {
      _goToStep(2);
    } else {
      setState(() => _errorMessage = 'Código inválido o expirado.');
    }
  }

  Future<void> _resetPassword() async {
    if (!_pwMatch) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden.');
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await UserService().resetPassword(
      email: _emailCtrl.text.trim(),
      newPassword: _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña restablecida correctamente.')),
      );
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ResponsiveAuthLayout(
      logo: Image.asset(
        'assets/images/isologo-horizontal.png',
        height: 80,
        fit: BoxFit.contain,
      ),
      mobileHeaderExtra: Padding(
        padding: EdgeInsets.only(top: topPadding + 12, left: 16),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      fadeIn: _fadeIn,
      slideUp: _slideUp,
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _step == 0
                ? 'Recuperar contraseña'
                : _step == 1
                    ? 'Verifica tu correo'
                    : 'Nueva contraseña',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _step == 0
                ? 'Introduce tu correo para recibir un código de verificación.'
                : _step == 1
                    ? 'Introduce el código de 6 dígitos enviado a ${_emailCtrl.text}.'
                    : 'Crea una nueva contraseña segura.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          if (_step == 0) _buildStepEmail(),
          if (_step == 1) _buildStepCode(),
          if (_step == 2) _buildStepPassword(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _errorBanner(_errorMessage!),
          ],
        ],
      ),
    );
  }

  Widget _buildStepEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('Tu correo electrónico'),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hint: 'ejemplo@correo.com',
            prefixIcon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 24),
        _btn(
          label: 'Enviar código',
          onPressed: _emailValid ? _sendCode : null,
          loading: _loading,
        ),
      ],
    );
  }

  Widget _buildStepCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 44,
              height: 52,
              child: TextField(
                controller: _codeCtrls[i],
                focusNode: _codeNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        _btn(
          label: 'Verificar código',
          onPressed: _codeCtrls.every((c) => c.text.length == 1) ? _verifyCode : null,
          loading: _loading,
        ),
        TextButton(
          onPressed: _loading ? null : _sendCode,
          child: const Text('Reenviar código'),
        ),
      ],
    );
  }

  Widget _buildStepPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('Nueva contraseña'),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: !_showPassword,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _label('Confirmar contraseña'),
        TextFormField(
          controller: _confirmPasswordCtrl,
          obscureText: !_showPassword,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
          ),
        ),
        const SizedBox(height: 24),
        _btn(
          label: 'Restablecer contraseña',
          onPressed: _pwValid && _pwMatch ? _resetPassword : null,
          loading: _loading,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            child: const Text(
              'Regresar al inicio de sesión',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, color: AppColors.neutral5, size: 20),
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.inputBorder)),
      suffixIcon: suffixIcon,
    );
  }

  Widget _btn({required String label, required VoidCallback? onPressed, bool loading = false}) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionPrimaryDefault,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: loading ? null : onPressed,
        child: loading ? const CircularProgressIndicator(color: AppColors.white) : Text(label),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(12)),
      child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 13)),
    );
  }
}
