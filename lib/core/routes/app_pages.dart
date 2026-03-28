import 'package:get/get.dart';
import 'app_routes.dart';

// ── Módulo Auth ────────────────────────────────────────────────────
import '../../modules/auth/views/splash_screen.dart';
import '../../modules/auth/views/login_screen.dart';
import '../../modules/auth/views/register_screen.dart';
import '../../modules/auth/views/biometric_lock_screen.dart';

// ── Módulo Coach (pantallas exclusivas del entrenador) ─────────────
import '../../modules/coach/views/dashboard_screen.dart';
import '../../modules/coach/views/athletes_screen.dart';
import '../../modules/coach/views/athlete_profile_screen.dart';
import '../../modules/coach/views/athlete_selection_screen.dart';
import '../../modules/coach/views/teams_screen.dart';
import '../../modules/coach/views/macrocycle_list_screen.dart';
import '../../modules/coach/views/macrocycle_builder_screen.dart';
import '../../modules/coach/views/macrocycle_detail_screen.dart';
import '../../data/models/macrocycle.dart';

// ── Módulo Athlete (pantallas exclusivas del deportista) ───────────
import '../../modules/athlete/views/athlete_dashboard_screen.dart';

// ── Módulo Shared (pantallas compartidas por ambos roles) ──────────
import '../../modules/shared/views/home_screen.dart';
import '../../modules/shared/views/notifications_screen.dart';
import '../../modules/shared/views/profile_screen.dart';
import '../../modules/shared/views/evaluations_screen.dart';
import '../../modules/shared/views/statistics_screen.dart';
import '../../modules/shared/views/test_force_panel_screen.dart';
import '../../modules/shared/views/test_direction_panel_screen.dart';
import '../../modules/shared/views/saremas_panel_screen.dart';
import '../../modules/shared/views/strength_test_screen.dart';
import '../../modules/shared/views/test_statistics_screen.dart';

/// Páginas de la aplicación registradas con GetX.
/// Usa las pantallas originales (*_screen.dart) para mantener la funcionalidad.
abstract final class AppPages {
  static final List<GetPage> pages = [
    // ── Auth ─────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.biometricLock,
      page: () => const BiometricLockScreen(),
    ),

    // ── Home / Dashboard ─────────────────────────────────────────
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.athleteDashboard,
      page: () => const AthleteDashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: AppRoutes.teams,
      page: () => const TeamsScreen(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.evaluations,
      page: () => const EvaluationsScreen(),
    ),
    GetPage(
      name: AppRoutes.statistics,
      page: () => const StatisticsScreen(),
    ),
    GetPage(
      name: AppRoutes.forceTestModule,
      page: () => const TestForcePanelScreen(),
    ),
    GetPage(
      name: AppRoutes.directionTestModule,
      page: () => const TestDirectionPanelScreen(),
    ),
    GetPage(
      name: AppRoutes.saremasTestModule,
      page: () => const SaremasPanelScreen(),
    ),

    // ── Pantallas que reciben argumentos ──────────────────────────
    GetPage(
      name: AppRoutes.athletes,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return AthletesScreen(
          teamName: args?['teamName'] ?? 'Sin equipo',
          teamFlag: args?['teamFlag'] ?? '',
          teamSubtitle: args?['teamSubtitle'] ?? '',
        );
      },
    ),
    GetPage(
      name: AppRoutes.athleteProfile,
      page: () {
        final athlete = Get.arguments as Athlete;
        return AthleteProfileScreen(athlete: athlete);
      },
    ),
    GetPage(
      name: AppRoutes.athleteSelection,
      page: () {
        final evaluationType = Get.arguments as String? ?? 'strength';
        return AthleteSelectionScreen(evaluationType: evaluationType);
      },
    ),
    GetPage(
      name: AppRoutes.strengthTest,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return StrengthTestScreen(
          evaluationType: args?['evaluationType'] ?? 'strength',
          athletes: args?['athletes'] ?? [],
        );
      },
    ),
    GetPage(
      name: AppRoutes.testStatistics,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return TestStatisticsScreen(
          evaluationType: args?['evaluationType'] ?? 'strength',
          athletes: args?['athletes'] ?? [],
          results: args?['results'] ?? {},
        );
      },
    ),

    // ── Macrociclos ──────────────────────────────────────────────
    GetPage(
      name: AppRoutes.macrocycles,
      page: () => const MacrocycleListScreen(),
    ),
    GetPage(
      name: AppRoutes.macrocycleBuilder,
      page: () => const MacrocycleBuilderScreen(),
    ),
    GetPage(
      name: AppRoutes.macrocycleDetail,
      page: () {
        final macrocycle = Get.arguments as Macrocycle;
        return MacrocycleDetailScreen(macrocycle: macrocycle);
      },
    ),
  ];
}
