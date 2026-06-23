import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arabcha/app/theme/app_colors.dart';
import 'package:arabcha/app/theme/app_typography.dart';

import 'package:arabcha/features/lesson/steps/recognize_step.dart';
import 'package:arabcha/features/lesson/steps/reveal_step.dart';
import 'package:arabcha/features/lesson/steps/expand_step.dart';
import 'package:arabcha/features/lesson/steps/listen_step.dart';
import 'package:arabcha/features/lesson/steps/pronounce_step.dart';

import 'package:arabcha/features/lesson/providers/lesson_providers.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String id;
  const LessonScreen({super.key, required this.id});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final PageController _pageController = PageController();

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    if (_pageController.page != null && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topicAsync = ref.watch(topicProvider(widget.id));

    return Scaffold(
      backgroundColor: const Color(0xFF0B1218),
      body: topicAsync.when(
        data: (topic) {
          // We assume there's at least one word
          final currentWord = topic.words.first;
          return PageView(
            controller: _pageController,
            physics:
                const NeverScrollableScrollPhysics(), // Only move on button tap
            children: [
              RecognizeStep(
                topic: topic,
                word: currentWord,
                onNext: _nextPage,
                onBack: _prevPage,
              ),
              RevealStep(
                topic: topic,
                word: currentWord,
                onNext: _nextPage,
                onBack: _prevPage,
              ),
              ExpandStep(
                topic: topic,
                word: currentWord,
                onNext: _nextPage,
                onBack: _prevPage,
              ),
              ListenStep(
                topic: topic,
                word: currentWord,
                onNext: _nextPage,
                onBack: _prevPage,
              ),
              PronounceStep(
                topic: topic,
                word: currentWord,
                onNext: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Step 6 (Combine) - soon",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: const Color(0xFF3DD68C),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onBack: _prevPage,
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.emerald),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
