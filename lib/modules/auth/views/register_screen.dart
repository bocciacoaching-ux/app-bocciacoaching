import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;

  // Step 3 selections
  String? _selectedRegion = 'Colombia';
  String? _selectedRole = 'Deportista';
  String? _selectedCategory = 'BC3';

  final List<String> _regions = ['Colombia', 'Argentina', 'España'];
  final List<String> _roles = ['Deportista', 'Entrenador', 'Árbitro'];
  final List<String> _categories = ['BC1', 'BC2', 'BC3'];

  // Verification code (6 digits)
  final List<TextEditingController> _codeCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeNodes = List.generate(6, (_) => FocusNode());

  // bool _loading = false; // Usado por step 1 (verificación de correo) — comentado
  bool _loading = false;
  String? _errorMessage;
  int _step = 0; // 0 = email, 1 = code (comentado), 2 = password, 3 = profile

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  // ── Lifecycle ─────────────────────────────────────────────────────
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

    // Step 1 (verificación de correo) comentado — listeners de código desactivados
    // for (var i = 0; i < _codeCtrls.length; i++) {
    //   _codeCtrls[i].addListener(() {
    //     final text = _codeCtrls[i].text;
    //     if (text.isNotEmpty && i < _codeCtrls.length - 1) {
    //       _codeNodes[i + 1].requestFocus();
    //     }
    //     if (_codeCtrls.every((c) => c.text.trim().isNotEmpty)) {
    //       _verifyCode();
    //     }
    //   });
    // }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    for (final c in _codeCtrls) {
      c.dispose();
    }
    for (final n in _codeNodes) {
      n.dispose();
    }
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────
  void _goToStep(int step) {
    _animController.reset();
    setState(() => _step = step);
    _animController.forward();
  }

  // ── Validation ────────────────────────────────────────────────────
  bool get _emailValid {
    final v = _emailCtrl.text.trim();
    return RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v);
  }

  bool get _pwAtLeast8 => _passwordCtrl.text.trim().length >= 8;
  bool get _pwHasNumber => RegExp(r'\d').hasMatch(_passwordCtrl.text);
  bool get _pwNoSpecial =>
      RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_passwordCtrl.text);
  bool get _pwValid => _pwAtLeast8 && _pwHasNumber && _pwNoSpecial;

  // Step 1 (verificación de correo) comentado
  // Future<void> _verifyCode() async {
  //   final code = _codeCtrls.map((c) => c.text.trim()).join();
  //   if (code.length < 6) return;
  //   setState(() => _loading = true);
  //   await Future.delayed(const Duration(seconds: 1));
  //   setState(() => _loading = false);
  //   if (!mounted) return;
  //   _goToStep(2);
  // }

  // void _resendCode() {
  //   for (final c in _codeCtrls) {
  //     c.clear();
  //   }
  //   _codeNodes.first.requestFocus();
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: const Text('Código reenviado'),
  //       backgroundColor: AppColors.success,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     ),
  //   );
  // }

  // ── Mapeo de rol ──────────────────────────────────────────────────
  int _roleToInt(String? role) {
    switch (role) {
      case 'Entrenador':
        return 1;
      case 'Árbitro':
        return 2;
      case 'Deportista':
      default:
        return 3;
    }
  }

  // ── Registro ──────────────────────────────────────────────────────
  Future<void> _register() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await UserService().addInfoUser(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        region: _selectedRegion,
        rol: _roleToInt(_selectedRole),
        category: _selectedCategory,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (result != null && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Cuenta creada exitosamente!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        final message = (result != null && result['message'] != null)
            ? result['message'] as String
            : 'No se pudo crear la cuenta. Inténtalo de nuevo.';
        setState(() => _errorMessage = message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Error de conexión. Verifica tu internet e inténtalo de nuevo.';
      });
    }
  }

  void _showSelectionSheet(BuildContext ctx, String title, List<String> items,      ValueChanged<String> onSelected) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) {
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
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const Divider(height: 1),
              ...items.map((it) => ListTile(
                    title: Text(it),
                    onTap: () {
                      Navigator.of(c).pop();
                      onSelected(it);
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Reusable widgets ──────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, color: AppColors.neutral5, size: 20),
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      suffixIcon: suffixIcon,
    );
  }

  Widget _label(String text, {bool required = true}) {
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
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w600),
            ),
        ]),
      ),
    );
  }

  // ── Progress stepper ──────────────────────────────────────────────
  Widget _buildStepper() {
    const totalSteps = 4;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        // Even indices → dot, odd → connector line
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < _step;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: isCompleted ? AppColors.primary : AppColors.neutral7,
            ),
          );
        }
        final i = index ~/ 2;
        final isActive = i == _step;
        final isCompleted = i < _step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 16 : 12,
          height: isActive ? 16 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.primary
                : isActive
                    ? AppColors.primary
                    : AppColors.neutral7,
            border: isActive
                ? Border.all(color: AppColors.primary30, width: 3)
                : null,
          ),
        );
      }),
    );
  }

  // ── Navigation buttons ────────────────────────────────────────────
  Widget _buildNavButtons({
    required VoidCallback? onNext,
    VoidCallback? onBack,
    String nextLabel = 'Siguiente',
    bool loading = false,
  }) {
    return Row(
      children: [
        if (onBack != null)
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: loading ? null : onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Atrás',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        if (onBack != null) const SizedBox(width: 12),
        Expanded(
          flex: onBack != null ? 2 : 1,
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: loading ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionPrimaryDefault,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.actionPrimaryDisabled,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : Text(nextLabel),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step body builders ────────────────────────────────────────────
  Widget _buildStep0Email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('Tu correo electrónico'),
        const SizedBox(height: 2),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hint: 'anagonzalez@email.com',
            prefixIcon: Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 24),
        _buildNavButtons(
          onNext: _emailValid ? () => _goToStep(2) : null, // Step 1 (verificación de correo) comentado
        ),
        const SizedBox(height: 28),

        // ── Social divider ────────────────────────────────────────
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.neutral7)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('O regístrate con',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
            const Expanded(child: Divider(color: AppColors.neutral7)),
          ],
        ),
        const SizedBox(height: 18),
        Center(
          child: SizedBox(
            height: 48,
            width: 48,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Google sign-in no implementado')),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: AppColors.neutral7),
              ),
              child: SvgPicture.asset(
                'assets/images/google-logo.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 1: Verificación de correo (COMENTADO) ───────────────────
  // Widget _buildStep1Code() {
  //   final email =
  //       _emailCtrl.text.trim().isEmpty ? 'tu correo' : _emailCtrl.text.trim();
  //   // ... (paso de verificación de correo desactivado temporalmente)
  // }

  Widget _buildStep2Password() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icono representativo
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline,
                size: 32, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Crea tu contraseña',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        const Text(
          'La usarás más adelante para iniciar sesión.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),

        _label('Tu contraseña'),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: !_showPassword,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration(
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.neutral5,
                size: 20,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password requirements
        _buildRequirement('Mínimo 8 caracteres', _pwAtLeast8),
        const SizedBox(height: 6),
        _buildRequirement('Al menos 1 número', _pwHasNumber),
        const SizedBox(height: 6),
        _buildRequirement('Sin caracteres especiales', _pwNoSpecial),

        const SizedBox(height: 28),
        _buildNavButtons(
          onBack: () => _goToStep(0),
          onNext: _pwValid ? () => _goToStep(3) : null,
        ),
      ],
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: met ? AppColors.success : AppColors.neutral8,
          ),
          child: Icon(
            met ? Icons.check : Icons.close,
            size: 12,
            color: met ? AppColors.white : AppColors.neutral5,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: met ? AppColors.success : AppColors.textSecondary,
              fontWeight: met ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Profile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icono representativo
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline,
                size: 32, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '¡Último paso!',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        const Text(
          'Completa tu perfil para personalizar\ntu experiencia.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),

        _label('Región'),
        _buildSelector(
          icon: Icons.public_outlined,
          value: _selectedRegion ?? _regions.first,
          onTap: () => _showSelectionSheet(context, 'Selecciona región',
              _regions, (v) => setState(() => _selectedRegion = v)),
        ),
        const SizedBox(height: 16),

        _label('Rol en Boccia Coaching'),
        _buildSelector(
          icon: Icons.badge_outlined,
          value: _selectedRole ?? _roles.first,
          onTap: () => _showSelectionSheet(context, 'Selecciona rol', _roles,
              (v) => setState(() => _selectedRole = v)),
        ),
        const SizedBox(height: 16),

        _label('Categoría'),
        _buildSelector(
          icon: Icons.sports_outlined,
          value: _selectedCategory ?? _categories.first,
          onTap: () => _showSelectionSheet(context, 'Selecciona categoría',
              _categories, (v) => setState(() => _selectedCategory = v)),
        ),
        const SizedBox(height: 28),

        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.errorBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        _buildNavButtons(
          onBack: () => _goToStep(2),
          nextLabel: 'Finalizar',
          onNext: (_selectedRegion != null &&
                  _selectedRole != null &&
                  _selectedCategory != null &&
                  !_loading)
              ? _register
              : null,
          loading: _loading,
        ),
      ],
    );
  }

  Widget _buildSelector({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 50,
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
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14)),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.neutral5, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    const headerHeight = 220.0;

    return Scaffold(
      backgroundColor: AppColors.headerGradientTop,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.headerGradientTop,
              AppColors.headerGradientBottom,
            ],
          ),
        ),
        child: Column(
          children: [
            // ── Header con logo (centrado) ──────────────────────
            SizedBox(
              height: headerHeight + topPadding,
              child: Column(
                children: [
                  SizedBox(height: topPadding + 12),
                  // Back button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed('/'),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: AppColors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 36, height: 36),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Image.asset(
                        'assets/images/isologo-horizontal.png',
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),

            // ── Card blanca (ocupa el resto) ─────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                          24, 24, 24, 24 + bottomPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                              const Text(
                                'Crea tu cuenta',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '¿Ya tienes usuario? ',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .pushReplacementNamed('/'),
                                    child: const Text(
                                      'Inicia sesión',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildStepper(),
                              const SizedBox(height: 24),
                              if (_step == 0) _buildStep0Email(),
                              // if (_step == 1) _buildStep1Code(),
                              if (_step == 2) _buildStep2Password(),
                              if (_step == 3) _buildStep3Profile(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
