/// Base URL and API endpoint constants.
/// NOTE: This file is currently unused as the app uses a serverless architecture
/// (Firebase + Cloud Functions) rather than a traditional REST API.
/// Kept for reference or future hybrid use.
abstract final class ApiConstants {
  static const String baseUrl = 'https://api.arabcha.uz/api/v1';

  // Auth
  static const String otpSend = '/auth/otp/send';
  static const String otpVerify = '/auth/otp/verify';
  static const String authGoogle = '/auth/google';
  static const String authApple = '/auth/apple';
  static const String tokenRefresh = '/auth/token/refresh';
  static const String logout = '/auth/logout';

  // Users
  static const String me = '/users/me';

  // Onboarding
  static const String onboardingGoals = '/onboarding/goals';
  static const String onboardingFirstLesson = '/onboarding/first-lesson';
  static const String onboardingSync = '/onboarding/sync';
  static const String onboardingSkip = '/onboarding/skip';

  // Content
  static const String modules = '/content/modules';
  static const String lessons = '/content/lessons';
  static const String progress = '/content/progress';
}
