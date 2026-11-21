// MODO DEMO — solo para la vista previa local. No se versiona.
// Arranca la app sin Firebase y con una API simulada (ver mock_api.dart).
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/app_messenger.dart';
import '../core/network/http_logger.dart';
import '../core/routes/app_pages.dart';
import '../core/routes/app_routes.dart';
import '../core/services/auth_service.dart';
import '../core/services/google_auth_service.dart';
import '../core/services/storage_service.dart';
import '../core/theme/app_theme.dart';
import '../data/providers/athlete_session_provider.dart';
import '../data/providers/direction_test_provider.dart';
import '../data/providers/force_test_provider.dart';
import '../data/providers/macrocycle_provider.dart';
import '../data/providers/microcycle_type_provider.dart';
import '../data/providers/notification_provider.dart';
import '../data/providers/onboarding_provider.dart';
import '../data/providers/saremas_provider.dart';
import '../data/providers/session_provider.dart';
import '../data/providers/statistics_provider.dart';
import '../data/providers/team_provider.dart';
import '../data/providers/training_session_provider.dart';
import '../modules/auth/views/login_screen.dart';
import 'mock_api.dart';

class _FakeFirebaseAuth implements fb.FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Google no está disponible en el modo demo.');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpLogger.client = MockApiClient();

  final storage = StorageService();
  await storage.init();
  Get.put(storage, permanent: true);
  Get.put(ApiClient(), permanent: true);
  await AuthService.instance.init();

  final pages = AppPages.pages.map((p) {
    if (p.name != AppRoutes.login) return p;
    return GetPage(
      name: p.name,
      page: () => LoginScreen(
        googleAuthService: GoogleAuthService(
          firebaseAuth: _FakeFirebaseAuth(),
          googleSignIn: GoogleSignIn(),
        ),
      ),
    );
  }).toList();

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
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => MicrocycleTypeProvider()),
      ],
      child: GetMaterialApp(
        title: '${AppConstants.appName} (demo)',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: AppMessenger.key,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        getPages: pages,
        defaultTransition: Transition.cupertino,
        locale: const Locale('es', 'ES'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
        builder: (context, child) => Banner(
          message: 'DEMO',
          location: BannerLocation.topEnd,
          child: child ?? const SizedBox(),
        ),
      ),
    ),
  );
}
