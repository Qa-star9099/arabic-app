import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

part 'auth_controller.g.dart';

// Temporarily stores onboarding data (goal, level) if a user completes
// the onboarding flow BEFORE creating an account.
final pendingOnboardingDataProvider = StateProvider<Map<String, String>?>((ref) => null);

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Stream<UserModel?> build() {
    final repo = ref.watch(authRepositoryProvider);
    return repo.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await repo.getUserData(firebaseUser.uid);
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      
      // If we have pending onboarding data, save it now!
      final pendingData = ref.read(pendingOnboardingDataProvider);
      if (pendingData != null) {
        await updateUserData(
          learningGoal: pendingData['goal'],
          level: pendingData['level'],
          dailyGoal: pendingData['dailyGoal'],
        );
        ref.read(pendingOnboardingDataProvider.notifier).state = null; // Clear it
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUserData({String? learningGoal, String? level, String? dailyGoal}) async {
    try {
      await ref.read(authRepositoryProvider).updateUserData(
        learningGoal: learningGoal,
        level: level,
        dailyGoal: dailyGoal,
      );
      // We don't necessarily need to manually update state here
      // because authStateChanges is a stream, but since we map over it
      // the user document update won't automatically trigger the authStateChanges stream.
      // So let's force a refresh of the user data.
      final user = await ref.read(authRepositoryProvider).getUserData(state.value!.uid);
      if (user != null) {
        state = AsyncValue.data(user);
      }
    } catch (e) {
      // Don't override state to error if this fails, just log or rethrow if needed
      print('Error updating user data: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}
