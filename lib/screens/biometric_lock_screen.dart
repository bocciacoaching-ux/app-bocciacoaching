import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../theme/app_colors.dart';

/// Pantalla de bloqueo biométrico.
/// Se muestra al abrir la app o al volver del segundo plano
/// cuando el usuario tiene activado el desbloqueo biométrico.
class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  final BiometricService _biometricService = BiometricService();
  final AuthService _authService = AuthService();
  String _biometricLabel = 'Biometría';
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLabel();
    // Lanzar autenticación automáticamente al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _loadLabel() async {
    final label = await _biometricService.getBiometricLabel();
    if (mounted) {
      setState(() => _biometricLabel = label);
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    final success = await _biometricService.authenticate(
      reason: 'Autentícate para acceder a Boccia Coaching',
    );

    if (!mounted) return;

    if (!success) {
      setState(() => _isAuthenticating = false);
      return;
    }

    // Biometría exitosa → consultar la API con las credenciales guardadas
    final sessionProvider = context.read<SessionProvider>();
    final credentials = await sessionProvider.getCredentials();

    if (credentials == null) {
      // No hay credenciales guardadas → enviar al login
      if (!mounted) return;
      setState(() => _isAuthenticating = false);
      Navigator.of(context).pushReplacementNamed('/');
      return;
    }

    // Llamar a la API de inicio de sesión para obtener datos actualizados
    final result = await _authService.signIn(
      credentials.email,
      credentials.password,
    );

    if (!mounted) return;
    setState(() => _isAuthenticating = false);

    if (result != null && result['success'] == true) {
      // Actualizar la sesión con los datos frescos del servidor
      await sessionProvider
          .saveSession(result['data'] as Map<String, dynamic>);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      // Credenciales caducadas o error → mostrar mensaje y opción de ir al login
      final message = (result != null && result['message'] != null)
          ? result['message'] as String
          : 'No se pudo verificar tu sesión.';
      setState(() => _errorMessage = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/isologo-vertical.png',
                width: 180,
                height: 180,
              ),
              const SizedBox(height: 48),

              // Icono de biometría
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 48,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Texto informativo
              Text(
                'Desbloquear con $_biometricLabel',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Usa $_biometricLabel para acceder a la aplicación',
                style: TextStyle(
                  color: AppColors.white.withAlpha(179),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Mensaje de error si la API falla
              if (_errorMessage != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withAlpha(77)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Botón para ir al login manual
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  child: const Text(
                    'Iniciar sesión con correo y contraseña',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Botón para reintentar
              if (!_isAuthenticating && _errorMessage == null)
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint),
                  label: Text('Usar $_biometricLabel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (_isAuthenticating)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
