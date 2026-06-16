import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/onboarding/presentation/pages/goal_selection_page.dart';
import '../../features/placement_test/screens/placement_test_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/personal_info_page.dart';

/// Route names — используем constants чтобы избежать строковых опечаток.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String goalSelection = '/onboarding/goal';
  static const String placementTest = '/placement-test';
  static const String placementTestResult = '/placement-test/result';
  static const String login = '/auth/login';
  static const String otp = '/auth/otp';
  static const String personalInfo = '/auth/personal-info';
  static const String home = '/home';
  static const String lesson = '/lesson/:id';
  static const String makhraj = '/makhraj/:id';
  static const String profile = '/profile';
}

/// GoRouter provider — доступен через ref.read(appRouterProvider)
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.goalSelection,
        name: 'goal-selection',
        builder: (context, state) => const GoalSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.placementTest,
        name: 'placement-test',
        builder: (context, state) => const PlacementTestScreen(),
      ),
      GoRoute(
        path: AppRoutes.placementTestResult,
        name: 'placement-test-result',
        builder: (context, state) {
          return const TestResultScreen(score: "A1");
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        builder: (context, state) => const OtpPage(),
      ),
      GoRoute(
        path: AppRoutes.personalInfo,
        name: 'personal-info',
        builder: (context, state) => const PersonalInfoPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
});
