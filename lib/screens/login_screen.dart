import 'package:flutter/material.dart';
import 'package:boccia_coaching_app/services/auth_service.dart';
import 'package:boccia_coaching_app/screens/dashboard_screen.dart';
import 'package:boccia_coaching_app/theme/app_colors.dart';

// Color tokens to match the provided design system
const Color kHeaderColor = AppColors.primary;
const Color kBackground = AppColors.background;
const Color kInputBorder = AppColors.inputBorder;
const Color kPrimaryButton = AppColors.actionPrimaryDefault;
const Color kLinkColor = AppColors.primary;
const Color kAsteriskColor = AppColors.error;

class LoginScreen extends StatefulWidget {
  final AuthService? authService;
  const LoginScreen({super.key, this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  AuthService get _auth => widget.authService ?? AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final ok = await _auth.signIn(email, password);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => const DashboardScreen(),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Credenciales incorrectas'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // use defined tokens
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                      color: AppColors.white,
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
                            'Hola de nuevo!',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Wrap(
                            children: [
                              const Text('¿Primera vez en Boccia Coaching? '),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/register');
                                },
                                child: Text('Regístrate', style: TextStyle(color: kLinkColor)),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox.shrink(),
                              // Label with red asterisk
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
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  hintText: 'anagonzalez@email.com',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kInputBorder)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kInputBorder)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kHeaderColor, width: 1.5)),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Introduce tu correo';
                                  if (!v.contains('@')) return 'Correo no válido';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              const SizedBox(height: 0),
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
                                controller: _passwordController,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  hintText: '********',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kInputBorder)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kInputBorder)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kHeaderColor, width: 1.5)),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Introduce la contraseña';
                                  if (v.length < 6) return 'La contraseña es muy corta';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: kLinkColor)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryButton,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: _loading ? null : _submit,
                                  child: _loading
                                      ? const CircularProgressIndicator(color: AppColors.white)
                                      : const Text('Iniciar sesión'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: const [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('O inicia sesión con'),
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
                          ),
                        )
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

