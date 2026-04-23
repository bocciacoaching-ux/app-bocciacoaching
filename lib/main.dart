import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'core/services/storage_service.dart';
import 'data/providers/direction_test_provider.dart';
import 'data/providers/force_test_provider.dart';
import 'data/providers/macrocycle_provider.dart';
import 'data/providers/saremas_provider.dart';
import 'data/providers/session_provider.dart';
import 'data/providers/team_provider.dart';
import 'data/providers/statistics_provider.dart';
import 'data/providers/training_session_provider.dart';
import 'data/providers/athlete_session_provider.dart';
import 'data/providers/onboarding_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Inyección de dependencias globales (GetX) ──────────────────
  await _initServices();

  // ── MultiProvider para compatibilidad con pantallas existentes ─
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ForceTestProvider()),
        ChangeNotifierProvider(create: (_) => DirectionTestProvider()),
        ChangeNotifierProvider(create: (_) => SaremasProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => MacrocycleProvider()),
        ChangeNotifierProvider(create: (_) => TrainingSessionProvider()),
        ChangeNotifierProvider(create: (_) => AthleteSessionProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: const App(),
    ),
  );
}

/// Registra servicios globales en GetX antes de iniciar la app.
Future<void> _initServices() async {
  // Almacenamiento local
  final storage = StorageService();
  await storage.init();
  Get.put(storage, permanent: true);

  // Cliente HTTP
  Get.put(ApiClient(), permanent: true);
}
