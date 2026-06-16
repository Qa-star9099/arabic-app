content = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../controllers/placement_test_controller.dart';
import '../models/test_question.dart';

class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placementTestControllerProvider);

    ref.listen<PlacementTestState>(
      placementTestControllerProvider,
      (previous, current) {
        if (previous?.currentIndex != current.currentIndex && !current.isFinished) {
          _animController.forward(from: 0.0);
        }
        if (current.isFinished && previous?.isFinished != true) {
          context.go('/placement_test_result');
        }
      },
    );

    if (state.isFinished || state.questions.isEmpty) {
      return const Scaffold(backgroundColor: AppColors.background);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              progress: state.progress,
              onClose: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.welcome);
                }
              },
            ),
            Expanded(
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: _QuestionBody(
                    question: state.currentQuestion,
                    selectedAnswer: state.selectedAnswer,
                    isSubmitted: state.isAnswerSubmitted,
                  ),
                ),
              ),
            ),
            _BottomActionArea(
              isAnswerSelected: state.selectedAnswer != null,
              isSubmitted: state.isAnswerSubmitted,
              isCorrect: state.isCorrect,
              correctAnswerText: _getCorrectAnswerText(state.currentQuestion),
              onSubmit: () => ref.read(placementTestControllerProvider.notifier).submitAnswer(),
              onNext: () => ref.read(placementTestControllerProvider.notifier).advance(),
            ),
          ],
        ),
      ),
    );
  }

  String _getCorrectAnswerText(TestQuestion q) {
    switch(q.type) {
      case QuestionType.multipleChoice:
      case QuestionType.visualId:
      case QuestionType.fillInBlank:
      case QuestionType.errorId:
        return q.correctAnswerIndex != null ? q.options[q.correctAnswerIndex!] : '';
      case QuestionType.audioTest:
        return q.correctAnswerString ?? '';
      case QuestionType.matchPairs:
        return "Mos keladigan juftliklar";
      case QuestionType.sentenceScramble:
        return q.options.join(" ");
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress, required this.onClose});

  final double progress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
            onPressed: onClose,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emerald),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    required this.question,
    required this.selectedAnswer,
    required this.isSubmitted,
  });

  final TestQuestion question;
  final Object? selectedAnswer;
  final bool isSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            question.difficulty,
            style: AppTypography.caption.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            question.questionText,
            style: AppTypography.h3.copyWith(color: Colors.white),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _buildDynamicWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicWidget() {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _MultipleChoiceWidget(question: question, selectedAnswer: selectedAnswer as int?, isSubmitted: isSubmitted);
      case QuestionType.visualId:
        return _VisualIdWidget(question: question, selectedAnswer: selectedAnswer as int?, isSubmitted: isSubmitted);
      case QuestionType.audioTest:
        return _AudioTestWidget(question: question, selectedAnswer: selectedAnswer as String?, isSubmitted: isSubmitted);
      case QuestionType.matchPairs:
        return _MatchPairsWidget(question: question, selectedAnswer: selectedAnswer as Map<String, String>?, isSubmitted: isSubmitted);
      case QuestionType.fillInBlank:
        return _FillInBlankWidget(question: question, selectedAnswer: selectedAnswer as int?, isSubmitted: isSubmitted);
      case QuestionType.sentenceScramble:
        return _SentenceScrambleWidget(question: question, selectedAnswer: selectedAnswer as List<String>?, isSubmitted: isSubmitted);
      case QuestionType.errorId:
        return _ErrorIdWidget(question: question, selectedAnswer: selectedAnswer as int?, isSubmitted: isSubmitted);
    }
  }
}

class _MultipleChoiceWidget extends ConsumerWidget {
  const _MultipleChoiceWidget({required this.question, required this.selectedAnswer, required this.isSubmitted});
  final TestQuestion question;
  final int? selectedAnswer;
  final bool isSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount: question.options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final isSelected = selectedAnswer == index;
        final isCorrectOption = index == question.correctAnswerIndex;
        
        Color bgColor = const Color(0xFF1E293B);
        Color borderColor = Colors.white10;

        if (isSubmitted) {
          if (isSelected && isCorrectOption) {
            bgColor = AppColors.emerald.withOpacity(0.2);
            borderColor = AppColors.emerald;
          } else if (isSelected && !isCorrectOption) {
            bgColor = AppColors.error.withOpacity(0.2);
            borderColor = AppColors.error;
          } else if (isCorrectOption) {
            borderColor = AppColors.emerald;
          }
        } else if (isSelected) {
          bgColor = const Color(0xFF334155);
          borderColor = AppColors.emerald;
        }

        return InkWell(
          onTap: isSubmitted ? null : () => ref.read(placementTestControllerProvider.notifier).selectAnswer(index),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Text(
              question.options[index],
              style: AppTypography.body.copyWith(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VisualIdWidget extends ConsumerWidget {
  const _VisualIdWidget({required this.question, required this.selectedAnswer, required this.isSubmitted});
  final TestQuestion question;
  final int? selectedAnswer;
  final bool isSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (question.imageUrl != null)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(question.imageUrl!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.0,
            ),
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              final isSelected = selectedAnswer == index;
              final isCorrectOption = index == question.correctAnswerIndex;
              Color bgColor = const Color(0xFF1E293B);
              Color borderColor = Colors.white10;

              if (isSubmitted) {
                if (isSelected && isCorrectOption) {
                  bgColor = AppColors.emerald.withOpacity(0.2);
                  borderColor = AppColors.emerald;
                } else if (isSelected && !isCorrectOption) {
                  bgColor = AppColors.error.withOpacity(0.2);
                  borderColor = AppColors.error;
                } else if (isCorrectOption) {
                  borderColor = AppColors.emerald;
                }
              } else if (isSelected) {
                bgColor = const Color(0xFF334155);
                borderColor = AppColors.emerald;
              }

              return InkWell(
                onTap: isSubmitted ? null : () => ref.read(placementTestControllerProvider.notifier).selectAnswer(index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Text(
                    question.options[index],
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class _AudioTestWidget extends ConsumerStatefulWidget {
  const _AudioTestWidget({required this.question, required this.selectedAnswer, required this.isSubmitted});
  final TestQuestion question;
  final String? selectedAnswer;
  final bool isSubmitted;

  @override
  ConsumerState<_AudioTestWidget> createState() => _AudioTestWidgetState();
}

class _AudioTestWidgetState extends ConsumerState<_AudioTestWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedAnswer);
  }

  @override
  void didUpdateWidget(covariant _AudioTestWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAnswer != _controller.text && widget.selectedAnswer == null) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        InkWell(
          onTap: () {
            // Mock Audio Playback
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio o\\'ynalmoqda...'), duration: Duration(seconds: 1)));
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.emerald.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.volume_up_rounded, color: AppColors.emerald, size: 40),
          ),
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _controller,
          enabled: !widget.isSubmitted,
          textAlign: TextAlign.center,
          style: AppTypography.h3.copyWith(color: Colors.white),
          onChanged: (val) {
            if (val.trim().isNotEmpty) {
              ref.read(placementTestControllerProvider.notifier).selectAnswer(val.trim());
            } else {
              ref.read(placementTestControllerProvider.notifier).selectAnswer(null);
            }
          },
          decoration: InputDecoration(
            hintText: 'Yozing...',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchPairsWidget extends ConsumerStatefulWidget {
  const _MatchPairsWidget({required this.question, required this.selectedAnswer, required this.isSubmitted});
  final TestQuestion question;
  final Map<String, String>? selectedAnswer;
  final bool isSubmitted;

  @override
  ConsumerState<_MatchPairsWidget> createState() => _MatchPairsWidgetState();
}

class _MatchPairsWidgetState extends ConsumerState<_MatchPairsWidget> {
  String? selectedLeft;
  String? selectedRight;
  Map<String, String> matched = {};

  @override
  void initState() {
    super.initState();
    if (widget.selectedAnswer != null) {
      matched = Map.from(widget.selectedAnswer!);
    }
  }

  void _onTapLeft(String word) {
    if (widget.isSubmitted || matched.containsKey(word)) return;
    setState(() {
      selectedLeft = word;
      _checkMatch();
    });
  }

  void _onTapRight(String word) {
    if (widget.isSubmitted || matched.containsValue(word)) return;
    setState(() {
      selectedRight = word;
      _checkMatch();
    });
  }

  void _checkMatch() {
    if (selectedLeft != null && selectedRight != null) {
      matched[selectedLeft!] = selectedRight!;
      selectedLeft = null;
      selectedRight = null;
      
      if (matched.length == widget.question.matchingPairs!.length) {
        ref.read(placementTestControllerProvider.notifier).selectAnswer(matched);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leftWords = widget.question.matchingPairs!.keys.toList();
    final rightWords = widget.question.matchingPairs!.values.toList();
    // Shuffle right visually
    rightWords.sort((a, b) => b.compareTo(a)); 

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Column(
            children: leftWords.map((word) => _buildPairButton(
              word: word,
              isSelected: selectedLeft == word,
              isMatched: matched.containsKey(word),
              onTap: () => _onTapLeft(word),
            )).toList(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: rightWords.map((word) => _buildPairButton(
              word: word,
              isSelected: selectedRight == word,
              isMatched: matched.containsValue(word),
              onTap: () => _onTapRight(word),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPairButton({required String word, required bool isSelected, required bool isMatched, required VoidCallback onTap}) {
    Color bgColor = const Color(0xFF1E293B);
    Color borderColor = Colors.white10;

    if (isMatched) {
      bgColor = AppColors.emerald.withOpacity(0.2);
      borderColor = AppColors.emerald;
    } else if (isSelected) {
      bgColor = const Color(0xFF334155);
      borderColor = Colors.white54;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Text(word, style: AppTypography.body.copyWith(color: isMatched ? Colors.white54 : Colors.white)),
        ),
      ),
    );
  }
}

class _FillInBlankWidget extends ConsumerWidget {
  const _FillInBlankWidget({required this.question, required this.selectedAnswer, required this.isSubmitted});
  final TestQuestion question;
  final int? selectedAnswer;
  final bool isSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                question.questionText.split('___').first.replaceAll('Bo\\'sh joyni to\\'ldiring: ', ''),
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 8),
              DragTarget<int>(
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 80,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedAnswer != null ? AppColors.emerald.withOpacity(0.2) : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: selectedAnswer != null ? AppColors.emerald : Colors.white24, width: 2),
                    ),
                    child: selectedAnswer != null
                        ? Text(question.options[selectedAnswer!], style: AppTypography.body.copyWith(color: AppColors.emerald, fontWeight: FontWeight.bold))
                        : null,
                  );
                },
                onAcceptWithDetails: (details) {
                  if (!isSubmitted) {
                    ref.read(placementTestControllerProvider.notifier).selectAnswer(details.data);
                  }
                },
              ),
              const SizedBox(width: 8),
              Text(
                question.questionText.split('___').last,
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(question.options.length, (index) {
            final isSelected = selectedAnswer == index;
            if (isSelected) return const SizedBox(width: 80, height: 40); // Placeholder
            return Draggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: _buildChip(question.options[index], isDragging: true),
              ),
              childWhenDragging: Opacity(opacity: 0.3, child: _buildChip(question.options[index])),
              child: InkWell(
                 onTap: isSubmitted ? null : () => ref.read(placementTestControllerProvider.notifier).selectAnswer(index),
                 child: _buildChip(question.options[index]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildChip(String text, {bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDragging ? [const BoxShadow(color: Colors.black26, blurRadius: 10)] : null,
      ),
      child: Text(text, style: AppTypography.body.copyWith(color: Colors.white)),
    );
  }
}

class _SentenceScrambleWidget extends ConsumerStatefulWidget {
  const _SentenceScrambleWidget({required this.question, required this.selectedAnswer, required this.isSubmitted});
  final TestQuestion question;
  final List<String>? selectedAnswer;
  final bool isSubmitted;

  @override
  ConsumerState<_SentenceScrambleWidget> createState() => _SentenceScrambleWidgetState();
}

class _SentenceScrambleWidgetState extends ConsumerState<_SentenceScrambleWidget> {
  List<String> _assembled = [];
  List<String> _available = [];

  @override
  void initState() {
    super.initState();
    if (widget.selectedAnswer != null) {
      _assembled = List.from(widget.selectedAnswer!);
      _available = widget.question.scrambledWords!.where((w) => !_assembled.contains(w)).toList();
    } else {
      _available = List.from(widget.question.scrambledWords!);
    }
  }

  void _onTapAvailable(String word) {
    if (widget.isSubmitted) return;
    setState(() {
      _available.remove(word);
      _assembled.add(word);
      ref.read(placementTestControllerProvider.notifier).selectAnswer(_assembled.isNotEmpty ? _assembled : null);
    });
  }

  void _onTapAssembled(String word) {
    if (widget.isSubmitted) return;
    setState(() {
      _assembled.remove(word);
      _available.add(word);
      ref.read(placementTestControllerProvider.notifier).selectAnswer(_assembled.isNotEmpty ? _assembled : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 100),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _assembled.map((word) => InkWell(
              onTap: () => _onTapAssembled(word),
              child: _buildChip(word),
            )).toList(),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _available.map((word) => InkWell(
            onTap: () => _onTapAvailable(word),
            child: _buildChip(word),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF334155),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: AppTypography.body.copyWith(color: Colors.white)),
    );
  }
}

class _ErrorIdWidget extends ConsumerWidget {
  const _ErrorIdWidget({required this.question, required this.selectedAnswer, required this.isSubmitted});
  final TestQuestion question;
  final int? selectedAnswer;
  final bool isSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Wrap(
        spacing: 12,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: List.generate(question.options.length, (index) {
          final isSelected = selectedAnswer == index;
          final isCorrectOption = index == question.errorWordIndex;
          Color bgColor = const Color(0xFF1E293B);
          Color borderColor = Colors.transparent;

          if (isSubmitted) {
            if (isSelected && isCorrectOption) {
              bgColor = AppColors.emerald.withOpacity(0.2);
              borderColor = AppColors.emerald;
            } else if (isSelected && !isCorrectOption) {
              bgColor = AppColors.error.withOpacity(0.2);
              borderColor = AppColors.error;
            } else if (isCorrectOption) {
              borderColor = AppColors.emerald;
            }
          } else if (isSelected) {
            bgColor = AppColors.error.withOpacity(0.4);
            borderColor = AppColors.error;
          }

          return InkWell(
            onTap: isSubmitted ? null : () => ref.read(placementTestControllerProvider.notifier).selectAnswer(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Text(
                question.options[index],
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BottomActionArea extends StatelessWidget {
  const _BottomActionArea({
    required this.isAnswerSelected,
    required this.isSubmitted,
    required this.isCorrect,
    required this.correctAnswerText,
    required this.onSubmit,
    required this.onNext,
  });

  final bool isAnswerSelected;
  final bool isSubmitted;
  final bool isCorrect;
  final String correctAnswerText;
  final VoidCallback onSubmit;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: isSubmitted
            ? (isCorrect ? AppColors.emerald.withOpacity(0.1) : AppColors.error.withOpacity(0.1))
            : Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSubmitted) ...[
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isCorrect ? AppColors.emerald : AppColors.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCorrect ? 'Barakalla!' : 'Noto\\'g\\'ri',
                        style: AppTypography.h3.copyWith(
                          color: isCorrect ? AppColors.emerald : AppColors.error,
                        ),
                      ),
                      if (!isCorrect && correctAnswerText.isNotEmpty)
                        Text(
                          'To\\'g\\'ri javob: $correctAnswerText',
                          style: AppTypography.body.copyWith(
                            color: AppColors.error.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSubmitted
                    ? (isCorrect ? AppColors.emerald : AppColors.error)
                    : (isAnswerSelected ? AppColors.emerald : const Color(0xFF334155)),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w600),
              ),
              onPressed: isSubmitted ? onNext : (isAnswerSelected ? onSubmit : null),
              child: Text(isSubmitted ? 'DAVOM ETISH' : 'TEKSHIRISH'),
            ),
          ),
        ],
      ),
    );
  }
}
"""

with open('/Users/abdulbasitswe/arabic_app/lib/features/placement_test/screens/placement_test_screen.dart', 'w') as f:
    f.write(content)
