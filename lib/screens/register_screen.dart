import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:boccia_coaching_app/theme/app_colors.dart';

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

  bool _loading = false;
  int _step = 0; // 0 = email, 1 = code, 2 = password, 3 = profile

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

  Future<void> _verifyCode() async {
    final code = _codeCtrls.map((c) => c.text.trim()).join();
    if (code.length < 6) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (!mounted) return;
    _goToStep(2);
  }

  void _resendCode() {
    for (final c in _codeCtrls) {
      c.clear();
    }
    _codeNodes.first.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Código reenviado'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSelectionSheet(BuildContext ctx, String title, List<String> items,
      ValueChanged<String> onSelected) {
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
    const labels = ['Correo', 'Código', 'Contraseña', 'Perfil'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(labels.length, (i) {
        final isActive = i == _step;
        final isCompleted = i < _step;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 32 : 26,
                  height: isActive ? 32 : 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.success
                        : isActive
                            ? AppColors.primary
                            : AppColors.neutral8,
                    border: isActive
                        ? Border.all(color: AppColors.primary30, width: 3)
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check,
                            color: AppColors.white, size: 14)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.white
                                  : AppColors.neutral5,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive || isCompleted
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (i < labels.length - 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SizedBox(
                  width: 28,
                  child: Divider(
                    thickness: 2,
                    color: i < _step ? AppColors.success : AppColors.neutral7,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  // ── Navigation buttons ────────────────────────────────────────────
  Widget _buildNavButtons({
    required VoidCallback? onNext,
    VoidCallback? onBack,
    String nextLabel = 'Siguiente',
  }) {
    return Row(
      children: [
        if (onBack != null)
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: onBack,
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
              onPressed: onNext,
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
              child: Text(nextLabel),
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
          onNext: _emailValid ? () => _goToStep(1) : null,
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

  Widget _buildStep1Code() {
    final email =
        _emailCtrl.text.trim().isEmpty ? 'tu correo' : _emailCtrl.text.trim();

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
            child: const Icon(Icons.mark_email_read_outlined,
                size: 32, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Verifica tu correo',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          'Enviamos un código de 6 dígitos a\n$email',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),

        // Code boxes
        LayoutBuilder(builder: (context, constraints) {
          const gap = 8.0;
          final totalGap = gap * 5;
          var boxW = (constraints.maxWidth - totalGap) / 6;
          boxW = boxW.clamp(40.0, 52.0);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Padding(
                padding: EdgeInsets.only(right: i < 5 ? gap : 0),
                child: SizedBox(
                  width: boxW,
                  height: boxW * 1.2,
                  child: TextField(
                    controller: _codeCtrls[i],
                    focusNode: _codeNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.inputBorder)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.inputBorder)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5)),
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                    onChanged: (v) {
                      if (v.isEmpty && i > 0) {
                        _codeNodes[i - 1].requestFocus();
                      }
                    },
                  ),
                ),
              );
            }),
          );
        }),

        const SizedBox(height: 16),
        if (_loading)
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.primary),
            ),
          ),
        const SizedBox(height: 12),

        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              children: [
                const TextSpan(text: '¿No recibiste el código? '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: _resendCode,
                    child: const Text(
                      'Reenviar',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        _buildNavButtons(
          onBack: () => _goToStep(0),
          onNext: () => _goToStep(2),
        ),
      ],
    );
  }

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
          onBack: () => _goToStep(1),
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

        _buildNavButtons(
          onBack: () => _goToStep(2),
          nextLabel: 'Finalizar',
          onNext: (_selectedRegion != null &&
                  _selectedRole != null &&
                  _selectedCategory != null)
              ? () => Navigator.of(context).pushReplacementNamed('/dashboard')
              : null,
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: topPadding + 16, bottom: 40),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Language + back button row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back arrow to login
                        GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushReplacementNamed('/'),
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
                        // Language selector
                        Material(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🇪🇸', style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_drop_down,
                                      size: 18, color: AppColors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/isologo-vertical-1tinta.png',
                    height: 80,
                    fit: BoxFit.contain,
                    color: AppColors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ],
              ),
            ),

            // ── Card body ─────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Material(
                      elevation: 4,
                      shadowColor: AppColors.primary20,
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.white,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title
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

                            // Stepper
                            _buildStepper(),
                            const SizedBox(height: 24),

                            // Step content
                            if (_step == 0) _buildStep0Email(),
                            if (_step == 1) _buildStep1Code(),
                            if (_step == 2) _buildStep2Password(),
                            if (_step == 3) _buildStep3Profile(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
