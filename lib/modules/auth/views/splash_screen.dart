import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_colors.dart';
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
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Cargar sesión guardada
    final sessionProvider = context.read<SessionProvider>();
    await sessionProvider.loadSession();

    if (!mounted) return;

    if (sessionProvider.isLoggedIn) {
      // El usuario tiene sesión activa → comprobar biometría
      final biometricService = BiometricService();
      final biometricEnabled = await biometricService.isBiometricEnabled();

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Image.asset(
              'assets/images/isologo-horizontal.png',
              height: 90,
              fit: BoxFit.contain,
              color: AppColors.white,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
