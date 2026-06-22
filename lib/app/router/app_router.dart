import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/onboarding/presentation/pages/goal_selection_page.dart';
import '../../features/onboarding/presentation/pages/level_selection_page.dart';
import '../../features/onboarding/presentation/pages/daily_goal_selection_page.dart';
import '../../features/onboarding/presentation/pages/path_selection_page.dart';
import '../../features/placement_test/screens/placement_test_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/lesson/lesson_screen.dart';
import '../../features/lesson/lesson_agenda_page.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/personal_info_page.dart';

import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/models/user_model.dart';

/// Route names — используем constants чтобы избежать строковых опечаток.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String goalSelection = '/onboarding/goal';
  static const String levelSelection = '/onboarding/level';
  static const String dailyGoalSelection = '/onboarding/daily-goal';
  static const String pathSelection = '/onboarding/path';
  static const String placementTest = '/placement/test';
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
  final listenable = ValueNotifier<bool>(false);
  ref.listen<AsyncValue<UserModel?>>(authControllerProvider, (_, __) {
    listenable.value = !listenable.value;
  });
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      if (authState.isLoading) return null; // Wait for initial auth state

      final isAuth = authState.value != null;
      final user = authState.value;
      
      final isSplash = state.uri.toString() == AppRoutes.splash;
      final isAuthRoute = state.uri.toString().startsWith('/auth');
      final isWelcomeRoute = state.uri.toString() == AppRoutes.welcome;
      final isOnboardingRoute = state.uri.toString().startsWith('/onboarding') || 
                                state.uri.toString().startsWith('/placement');

      // 1. Unauthenticated User Flow
      if (!isAuth) {
        // Allow them on splash, welcome, auth routes, AND onboarding routes!
        if (isSplash || isWelcomeRoute || isAuthRoute || isOnboardingRoute) {
          return null; 
        }
        // Otherwise, force them to Welcome
        return AppRoutes.welcome;
      }

      // 2. Authenticated User Flow
      final pendingData = ref.read(pendingOnboardingDataProvider);
      final hasCompletedOnboarding = user?.learningGoal != null || pendingData != null;

      if (!hasCompletedOnboarding) {
        // User needs to onboard. Allow them on onboarding routes.
        if (isOnboardingRoute) {
          return null;
        }
        // Force to Goal Selection if they try to go anywhere else (like Home, Splash, Welcome)
        return AppRoutes.goalSelection;
      }

      // 3. Fully Onboarded User Flow
      // If they try to go to splash, welcome, auth, or onboarding pages, redirect to Home
      if (isSplash || isWelcomeRoute || isAuthRoute || isOnboardingRoute) {
        return AppRoutes.home;
      }

      // Allow access to Home and inner pages
      return null;
    },
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
        path: AppRoutes.levelSelection,
        name: 'level-selection',
        builder: (context, state) {
          final selectedGoal = state.extra as String? ?? 'Umumiy';
          return LevelSelectionPage(selectedGoal: selectedGoal);
        },
      ),
      GoRoute(
        path: AppRoutes.dailyGoalSelection,
        name: 'daily-goal-selection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final goal = extra?['goal'] as String? ?? 'Umumiy';
          final level = extra?['level'] as String? ?? 'Boshlang\'ich (A1)';
          return DailyGoalSelectionPage(selectedGoal: goal, selectedLevel: level);
        },
      ),
      GoRoute(
        path: AppRoutes.pathSelection,
        name: 'path-selection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final goal = extra?['goal'] as String? ?? 'Umumiy';
          final level = extra?['level'] as String? ?? 'Boshlang\'ich (A1)';
          final dailyGoal = extra?['dailyGoal'] as String? ?? '30 daqiqa / kuniga';
          return PathSelectionPage(selectedGoal: goal, selectedLevel: level, selectedDailyGoal: dailyGoal);
        },
      ),
      GoRoute(
        path: AppRoutes.placementTest,
        name: 'placement-test',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final goal = extra?['goal'] as String? ?? 'Umumiy';
          final level = extra?['level'] as String? ?? 'Boshlang\'ich (A1)';
          final dailyGoal = extra?['dailyGoal'] as String? ?? '30 daqiqa / kuniga';
          return PlacementTestScreen(selectedGoal: goal, expectedLevel: level, dailyGoal: dailyGoal);
        },
      ),
      GoRoute(
        path: AppRoutes.placementTestResult,
        name: 'placement-test-result',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          final score = extras['score'] as String? ?? "A1";
          final goal = extras['goal'] as String?;
          return TestResultScreen(score: score, selectedGoal: goal);
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
      GoRoute(
        path: '/agenda/:id',
        name: 'agenda',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'T-01';
          return LessonAgendaPage(id: id);
        },
      ),
      GoRoute(
        path: AppRoutes.lesson,
        name: 'lesson',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'T-01';
          return LessonScreen(id: id);
        },
      ),
    ],
  );
});
