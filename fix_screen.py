import re

with open('/Users/abdulbasitswe/arabic_app/lib/features/placement_test/screens/placement_test_screen.dart', 'r') as f:
    content = f.read()

content = content.replace('AppTypography.h3', 'AppTypography.heading2')
content = content.replace('AppTypography.h1', 'AppTypography.display1')

result_screen = """

class TestResultScreen extends ConsumerWidget {
  const TestResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(placementTestControllerProvider);
    final level = state.accuracy > 0.8 ? "B1" : (state.accuracy > 0.5 ? "A2" : "Boshlang'ich");
    
    // Also consider early finish
    final finalLevel = state.isFinished && state.correctCount < 3 ? "Boshlang'ich (A1)" : level;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Sizning darajangiz', textAlign: TextAlign.center, style: AppTypography.caption.copyWith(color: Colors.white54)),
              const SizedBox(height: 12),
              Text(finalLevel, textAlign: TextAlign.center, style: AppTypography.display1.copyWith(color: AppColors.emerald)),
              const SizedBox(height: 48),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () => context.go(AppRoutes.personalInfo),
                  child: const Text("Arab tili dunyosiga sho'ng'ish"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
"""

if "class TestResultScreen" not in content:
    content += result_screen

with open('/Users/abdulbasitswe/arabic_app/lib/features/placement_test/screens/placement_test_screen.dart', 'w') as f:
    f.write(content)
