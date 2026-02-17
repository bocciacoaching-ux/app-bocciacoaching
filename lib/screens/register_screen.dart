import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// auth_service not required in this verification-only screen

const Color kHeaderColor = Color(0xFF477D9E);
const Color kBackground = Color(0xFFF7F8F9);
const Color kInputBorder = Color(0xFFE6E9EC);
const Color kPrimaryColor = Color(0xFF477D9E);
const Color kLinkColor = Color(0xFF477D9E);
const Color kAsteriskColor = Color(0xFFD23B4B);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;
  // last step selections
  String? _selectedRegion = 'Colombia';
  String? _selectedRole = 'Deportista';
  String? _selectedCategory = 'BC3';

  final List<String> _regions = ['Colombia', 'Argentina', 'España'];
  final List<String> _roles = ['Deportista', 'Entrenador', 'Árbitro'];
  final List<String> _categories = ['BC1', 'BC2', 'BC3'];
  // verification code controllers (6 digits)
  final List<TextEditingController> _codeCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _step = 0; // 0 = email step, 1 = full form

  // no backend auth object used in this demo verification step

  @override
  void dispose() {
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

  @override
  void initState() {
    super.initState();
    // Listen for changes on code fields to auto-advance and submit when full
    for (var i = 0; i < _codeCtrls.length; i++) {
      _codeCtrls[i].addListener(() {
        final text = _codeCtrls[i].text;
        if (text.isNotEmpty && i < _codeCtrls.length - 1) {
          _codeNodes[i + 1].requestFocus();
        }
        // if last filled, attempt submit
        if (_codeCtrls.every((c) => c.text.trim().isNotEmpty)) {
          _verifyCode();
        }
      });
    }
  }

  void _showSelectionSheet(BuildContext ctx, String title, List<String> items, ValueChanged<String> onSelected) {
    showModalBottomSheet(
      context: ctx,
      builder: (c) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(padding: const EdgeInsets.all(12), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
              const Divider(height: 1),
              ...items.map((it) => ListTile(title: Text(it), onTap: () { Navigator.of(c).pop(); onSelected(it); })),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  bool get _emailValid {
    final v = _emailCtrl.text.trim();
    final emailValid = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    return emailValid.hasMatch(v);
  }

  // registration submission handled elsewhere in this flow; kept previous logic removed

  Future<void> _verifyCode() async {
    // collect code
    final code = _codeCtrls.map((c) => c.text.trim()).join();
    if (code.length < 6) return;
    setState(() => _loading = true);
    // simulate verification delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    // For demo we accept any 6-digit code and advance to password creation step
    if (!mounted) return;
    setState(() => _step = 2);
  }

  void _resendCode() {
    // Simulate resend
    for (final c in _codeCtrls) {
      c.clear();
    }
    _codeNodes.first.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código reenviado')));
  }

  Widget _progressDots() {
    Widget dot(bool active) => Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: active ? kPrimaryColor : const Color(0xFFDDE6EA), shape: BoxShape.circle),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot(_step == 0),
        const SizedBox(width: 12),
        dot(_step == 1),
        const SizedBox(width: 12),
        dot(_step == 2),
        const SizedBox(width: 12),
        dot(_step == 3)
      ],
    );
  }

  bool get _pwAtLeast8 => _passwordCtrl.text.trim().length >= 8;
  bool get _pwHasNumber => RegExp(r'\d').hasMatch(_passwordCtrl.text);
  bool get _pwNoSpecial => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_passwordCtrl.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with logo
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kHeaderColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Material(
                      color: Colors.white,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('🇪🇸'),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Crea tu cuenta',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Wrap(
                          children: [
                            const Text('¿Ya tienes usuario? '),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacementNamed('/');
                              },
                              child: Text('Inicia sesión', style: TextStyle(color: kLinkColor)),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Progress dots for step indication
                      Center(
                        child: _progressDots(),
                      ),
                      const SizedBox(height: 28),
                      // Step 0: email only
                      if (_step == 0) ...[
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Tu correo electrónico '),
                              TextSpan(text: '*', style: TextStyle(color: kAsteriskColor)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: 'anagonzalez@email.com',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kInputBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kInputBorder)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kHeaderColor, width: 1.5)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _emailValid
                                ? () {
                                    setState(() => _step = 1);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Siguiente'),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('O regístrate con'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign-in no implementado')));
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Icon(Icons.g_translate, size: 28),
                          ),
                        ),
                      ],
                      // Step 1: verification code (6 digits)
                      if (_step == 1) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Verifica tu cuenta para continuar. Hemos enviado un código de 6 dígitos a ${_emailCtrl.text.trim().isEmpty ? "anagonzalez@email.com" : _emailCtrl.text.trim()}. Por favor, escríbelo a continuación.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 22),
                        // code boxes (responsive to available width to avoid overflow)
                        LayoutBuilder(builder: (context, constraints) {
                          const perBoxPad = 12.0;
                          final totalPad = perBoxPad * 6;
                          final available = constraints.maxWidth - totalPad;
                          var boxSize = available / 6.0;
                          if (boxSize > 56) boxSize = 56;
                          if (boxSize < 40) boxSize = 40;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (i) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: SizedBox(
                                  width: boxSize,
                                  height: boxSize * 1.15,
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
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kInputBorder)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kInputBorder)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kHeaderColor, width: 1.5)),
                                    ),
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(fontSize: 20),
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
                        const SizedBox(height: 18),
                        if (_loading) const CircularProgressIndicator(),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black54),
                              children: [
                                const TextSpan(text: '¿No recibiste el código? Revisa tu correo no deseado o '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _resendCode,
                                    child: const Text('reenviar.', style: TextStyle(decoration: TextDecoration.underline, color: Colors.black87)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => setState(() => _step = 0),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: kHeaderColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('Atrás', style: TextStyle(color: kPrimaryColor)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 160,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => setState(() => _step = 2),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Siguiente'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Step 2: create password
                      if (_step == 2) ...[
                        const SizedBox(height: 6),
                        const Center(
                          child: Text('Crea tu contraseña', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text('Crea tu contraseña.\nLa usarás más adelante para iniciar sesión.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                        ),
                        const SizedBox(height: 28),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Tu contraseña '),
                              TextSpan(text: '*', style: TextStyle(color: kAsteriskColor)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: !_showPassword,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            hintText: '********',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kInputBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kInputBorder)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kHeaderColor, width: 1.5)),
                            suffixIcon: IconButton(
                              icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Password requirements
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(_pwAtLeast8 ? Icons.check_circle : Icons.close, color: _pwAtLeast8 ? const Color(0xFF2E7D32) : const Color(0xFFB00020), size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Mínimo 8 caracteres', style: TextStyle(color: Colors.black54, fontSize: 13))),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              Icon(_pwHasNumber ? Icons.check_circle : Icons.close, color: _pwHasNumber ? const Color(0xFF2E7D32) : const Color(0xFFB00020), size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Al menos 1 número', style: TextStyle(color: Colors.black54, fontSize: 13))),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              Icon(_pwNoSpecial ? Icons.check_circle : Icons.close, color: _pwNoSpecial ? const Color(0xFF2E7D32) : const Color(0xFFB00020), size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Sin caracteres especiales', style: TextStyle(color: Colors.black54, fontSize: 13))),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => setState(() => _step = 1),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: kHeaderColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('Atrás', style: TextStyle(color: kPrimaryColor)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 160,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (_pwAtLeast8 && _pwHasNumber && _pwNoSpecial) ? () => setState(() => _step = 3) : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Siguiente'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Step 3: final profile info
                      if (_step == 3) ...[
                        const SizedBox(height: 6),
                        const Center(
                          child: Text('Último paso', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text('Completa tu región y rol dentro de Boccia Coaching.\nNos ayudará a personalizar tu experiencia.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                        ),
                        const SizedBox(height: 28),
                        // Region field
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Región '),
                              TextSpan(text: '*', style: TextStyle(color: kAsteriskColor)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showSelectionSheet(context, 'Selecciona región', _regions, (v) => setState(() => _selectedRegion = v)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            height: 48,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: kInputBorder)),
                            child: Row(children: [
                              const Icon(Icons.place, color: Colors.black54),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_selectedRegion ?? _regions.first, style: const TextStyle(color: Colors.black87))),
                              const Icon(Icons.arrow_drop_down, color: Colors.black54),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Role field
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Rol en Boccia Coaching '),
                              TextSpan(text: '*', style: TextStyle(color: kAsteriskColor)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showSelectionSheet(context, 'Selecciona rol', _roles, (v) => setState(() => _selectedRole = v)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            height: 48,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: kInputBorder)),
                            child: Row(children: [
                              const Icon(Icons.person, color: Colors.black54),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_selectedRole ?? _roles.first, style: const TextStyle(color: Colors.black87))),
                              const Icon(Icons.arrow_drop_down, color: Colors.black54),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Category field
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Categoría '),
                              TextSpan(text: '*', style: TextStyle(color: kAsteriskColor)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _showSelectionSheet(context, 'Selecciona categoría', _categories, (v) => setState(() => _selectedCategory = v)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            height: 48,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: kInputBorder)),
                            child: Row(children: [
                              const Icon(Icons.sports_score, color: Colors.black54),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_selectedCategory ?? _categories.first, style: const TextStyle(color: Colors.black87))),
                              const Icon(Icons.arrow_drop_down, color: Colors.black54),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => setState(() => _step = 2),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: kHeaderColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('Atrás', style: TextStyle(color: kPrimaryColor)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 160,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (_selectedRegion != null && _selectedRole != null && _selectedCategory != null)
                                    ? () => Navigator.of(context).pushReplacementNamed('/dashboard')
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Finalizar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
