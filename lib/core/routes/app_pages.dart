import 'package:get/get.dart';
import 'app_routes.dart';

// ── Módulo Auth ────────────────────────────────────────────────────
import '../../modules/auth/views/splash_screen.dart';
import '../../modules/auth/views/login_screen.dart';
import '../../modules/auth/views/register_screen.dart';
import '../../modules/auth/views/forgot_password_screen.dart';
import '../../modules/auth/views/biometric_lock_screen.dart';

// ── Módulo Coach (pantallas exclusivas del entrenador) ─────────────
import '../../modules/coach/views/dashboard_screen.dart';
import '../../modules/coach/views/athletes_screen.dart';
import '../../modules/coach/views/athlete_profile_screen.dart';
import '../../modules/coach/views/athlete_selection_screen.dart';
import '../../modules/coach/views/teams_screen.dart';
import '../../modules/coach/views/team_form_screen.dart';
import '../../data/models/team.dart';
import '../../modules/coach/views/macrocycle_list_screen.dart';
import '../../modules/coach/views/macrocycle_builder_screen.dart';
import '../../modules/coach/views/macrocycle_detail_screen.dart';
import '../../modules/coach/views/training_session_list_screen.dart';
import '../../modules/coach/views/training_session_detail_screen.dart';
import '../../modules/coach/views/training_session_form_screen.dart';
import '../../modules/coach/views/section_form_screen.dart';
import '../../modules/coach/views/microcycle_overview_screen.dart';
import '../../data/models/macrocycle.dart';
import '../../data/models/microcycle.dart';
import '../../data/models/training_session.dart';

// ── Módulo Athlete (pantallas exclusivas del deportista) ───────────
import '../../modules/athlete/views/athlete_dashboard_screen.dart';
import '../../modules/athlete/views/athlete_session_calendar_screen.dart';

// ── Módulo Onboarding (carrusel de bienvenida) ─────────────────────
import '../../modules/onboarding/views/onboarding_intro_screen.dart';

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
import '../../modules/shared/views/body_map_screen.dart';
import '../auth/auth_guards.dart';
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
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.biometricLock,
      // Sin guard: la pantalla valida/renueva la sesion por su cuenta.
      page: () => const BiometricLockScreen(),
    ),

    // ── Home / Dashboard ─────────────────────────────────────────
    GetPage(
      name: AppRoutes.home,
      middlewares: RouteGuards.authenticated,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      middlewares: RouteGuards.authenticated,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.athleteDashboard,
      middlewares: RouteGuards.authenticated,
      page: () => const AthleteDashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      middlewares: RouteGuards.authenticated,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: AppRoutes.teams,
      middlewares: RouteGuards.authenticated,
      page: () => const TeamsScreen(),
    ),
    GetPage(
      name: AppRoutes.teamForm,
      middlewares: RouteGuards.authenticated,
      page: () {
        final team = Get.arguments is Team ? Get.arguments as Team : null;
        return TeamFormScreen(team: team);
      },
    ),
    GetPage(
      name: AppRoutes.profile,
      middlewares: RouteGuards.authenticated,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.evaluations,
      middlewares: RouteGuards.authenticated,
      page: () => const EvaluationsScreen(),
    ),
    GetPage(
      name: AppRoutes.statistics,
      middlewares: RouteGuards.authenticated,
      page: () => const StatisticsScreen(),
    ),
    GetPage(
      name: AppRoutes.forceTestModule,
      middlewares: RouteGuards.authenticated,
      page: () => const TestForcePanelScreen(),
    ),
    GetPage(
      name: AppRoutes.directionTestModule,
      middlewares: RouteGuards.authenticated,
      page: () => const TestDirectionPanelScreen(),
    ),
    GetPage(
      name: AppRoutes.saremasTestModule,
      middlewares: RouteGuards.authenticated,
      page: () => const SaremasPanelScreen(),
    ),

    // ── Pantallas que reciben argumentos ──────────────────────────
    GetPage(
      name: AppRoutes.athletes,
      middlewares: RouteGuards.authenticated,
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
      middlewares: RouteGuards.authenticated,
      page: () {
        final athlete = Get.arguments as Athlete;
        return AthleteProfileScreen(athlete: athlete);
      },
    ),
    GetPage(
      name: AppRoutes.athleteSelection,
      middlewares: RouteGuards.authenticated,
      page: () {
        final evaluationType = Get.arguments as String? ?? 'strength';
        return AthleteSelectionScreen(evaluationType: evaluationType);
      },
    ),
    GetPage(
      name: AppRoutes.strengthTest,
      middlewares: RouteGuards.authenticated,
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
      middlewares: RouteGuards.authenticated,
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
      middlewares: RouteGuards.authenticated,
      page: () => const MacrocycleListScreen(),
    ),
    GetPage(
      name: AppRoutes.macrocycleBuilder,
      middlewares: RouteGuards.authenticated,
      page: () => const MacrocycleBuilderScreen(),
    ),
    GetPage(
      name: AppRoutes.macrocycleDetail,
      middlewares: RouteGuards.authenticated,
      page: () {
        final macrocycle = Get.arguments as Macrocycle;
        return MacrocycleDetailScreen(macrocycle: macrocycle);
      },
    ),

    // ── Sesiones de Entrenamiento ────────────────────────────────
    GetPage(
      name: AppRoutes.trainingSessions,
      middlewares: RouteGuards.authenticated,
      page: () {
        final microcycle = Get.arguments as Microcycle;
        return TrainingSessionListScreen(microcycle: microcycle);
      },
    ),
    GetPage(
      name: AppRoutes.trainingSessionDetail,
      middlewares: RouteGuards.authenticated,
      page: () {
        final sessionId = Get.arguments as String;
        return TrainingSessionDetailScreen(sessionId: sessionId);
      },
    ),
    GetPage(
      name: AppRoutes.trainingSessionForm,
      middlewares: RouteGuards.authenticated,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        final session = args['session'] as TrainingSession?;
        final microcycleId = args['microcycleId'] as String;
        final microcycleLabel = args['microcycleLabel'] as String?;
        return TrainingSessionFormScreen(
          microcycleId: microcycleId,
          microcycleLabel: microcycleLabel,
          session: session,
        );
      },
    ),

    // ── Sección de Sesión ────────────────────────────────────────
    GetPage(
      name: AppRoutes.sectionForm,
      middlewares: RouteGuards.authenticated,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        final sessionPartId = args['sessionPartId'] as String;
        final partName = args['partName'] as String?;
        final section = args['section'] as SessionSection?;
        return SectionFormScreen(
          sessionPartId: sessionPartId,
          partName: partName,
          section: section,
        );
      },
    ),

    // ── Microciclo Overview (acceso directo) ─────────────────────
    GetPage(
      name: AppRoutes.microcycleOverview,
      middlewares: RouteGuards.authenticated,
      page: () => const MicrocycleOverviewScreen(),
    ),

    // ── Calendario del atleta ────────────────────────────────────
    GetPage(
      name: AppRoutes.athleteCalendar,
      middlewares: RouteGuards.authenticated,
      page: () => const AthleteSessionCalendarScreen(),
    ),

    // ── Onboarding (intro) ───────────────────────────────────────
    GetPage(
      name: AppRoutes.onboardingIntro,
      middlewares: RouteGuards.authenticated,
      page: () => const OnboardingIntroScreen(),
    ),

    // ── Mapa corporal interactivo ────────────────────────────────
    GetPage(
      name: AppRoutes.bodyMap,
      middlewares: RouteGuards.authenticated,
      page: () => const BodyMapScreen(),
    ),
  ];
}
