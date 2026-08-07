import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/session_provider.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/navigation_helper.dart';

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

    // Cargar sesión guardada
    final sessionProvider = context.read<SessionProvider>();
    await sessionProvider.loadSession();

    if (!mounted) return;

    if (sessionProvider.isLoggedIn) {
      // El usuario tiene sesión activa → comprobar biometría
      final biometricService = BiometricService();
      final biometricEnabled = await biometricService.isBiometricEnabled();

      if (!mounted) return;

      if (biometricEnabled) {
        // Redirigir a la pantalla de desbloqueo biométrico
        Navigator.of(context).pushReplacementNamed('/biometric-lock');
      } else {
        // Ir directamente al dashboard
        NavigationHelper.goToDashboard(context);
      }
    } else {
      // Sin sesión → ir al login
      Navigator.of(context).pushReplacementNamed('/');
    }
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
