import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/session_provider.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // La animación dura aprox 4 segundos (240 frames a 60fps)
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    // Cargar los datos del usuario guardados
    final sessionProvider = context.read<SessionProvider>();
    await sessionProvider.loadSession();

    // Esperar a que AuthService restaure la sesión (refresh si el access
    // token expiró). Con el servidor "dormido" no se bloquea más de 20 s:
    // si el refresh sigue en curso, las peticiones lo esperarán.
    await AuthService.ready
        .timeout(const Duration(seconds: 20), onTimeout: () {});
    if (!mounted) return;

    final auth = AuthService.instance;
    final hasUser = sessionProvider.isLoggedIn;
    final biometricService = BiometricService();
    final biometricEnabled = await biometricService.isBiometricEnabled();
    if (!mounted) return;

    if (hasUser && auth.isAuthenticated()) {
      // Sesión válida → comprobar biometría
      if (biometricEnabled) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.biometricLock);
      } else {
        NavigationHelper.goToDashboard(context);
      }
      return;
    }

    // Sin tokens válidos pero con biometría y credenciales guardadas: la
    // pantalla biométrica puede iniciar sesión de nuevo.
    if (hasUser && biometricEnabled) {
      final credentials = await sessionProvider.getCredentials();
      if (!mounted) return;
      if (credentials != null) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.biometricLock);
        return;
      }
    }

    // Sin sesión → limpiar restos y al login
    if (hasUser || auth.tokens != null) await auth.logoutLocal();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Lottie.asset(
              'assets/animations/splash_animation.json',
              width: 300,
              repeat: false,
              onLoaded: (composition) {
                // Opcional: Podrías ajustar el timer aquí basado en composition.duration
              },
            ),
          ),
        ),
      ),
    );
  }
}
