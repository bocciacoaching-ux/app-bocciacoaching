import 'package:flutter/material.dart';
import 'package:boccia_coaching_app/screens/splash_screen.dart';
import 'package:boccia_coaching_app/screens/login_screen.dart';
import 'package:boccia_coaching_app/screens/register_screen.dart';
import 'package:boccia_coaching_app/screens/home_screen.dart';
import 'package:boccia_coaching_app/screens/dashboard_screen.dart';
import 'package:boccia_coaching_app/screens/notifications_screen.dart';
import 'package:boccia_coaching_app/screens/teams_screen.dart';
import 'package:boccia_coaching_app/screens/profile_screen.dart';
import 'package:boccia_coaching_app/screens/evaluations_screen.dart';
import 'package:boccia_coaching_app/screens/athlete_selection_screen.dart';
import 'package:boccia_coaching_app/screens/strength_test_screen.dart';
import 'package:boccia_coaching_app/screens/test_statistics_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boccia Coaching App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF477D9E)),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/teams': (_) => const TeamsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/evaluations': (_) => const EvaluationsScreen(),
        '/athlete-selection': (context) {
          final evaluationType = ModalRoute.of(context)?.settings.arguments as String?;
          return AthleteSelectionScreen(evaluationType: evaluationType ?? 'strength');
        },
        '/strength-test': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return StrengthTestScreen(
            evaluationType: args?['evaluationType'] ?? 'strength',
            athletes: args?['athletes'] ?? [],
          );
        },
        '/test-statistics': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return TestStatisticsScreen(
            evaluationType: args?['evaluationType'] ?? 'strength',
            athletes: args?['athletes'] ?? [],
            results: args?['results'] ?? {},
          );
        },
      },
    );
  }
}
