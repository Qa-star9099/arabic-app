import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:arabcha/app/theme/app_colors.dart';
import 'package:arabcha/app/theme/app_typography.dart';
import 'package:arabcha/features/placement_test/controllers/placement_test_controller.dart';
import 'package:arabcha/features/placement_test/models/test_question.dart';
import 'package:arabcha/app/router/app_router.dart';

class PlacementTestScreen extends ConsumerWidget {
  const PlacementTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(placementTestControllerProvider);

    if (state.questions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.isFinished) {
      return TestResultScreen(score: _getScoreLevel(state.correctCount));
    }

    final progress = (state.currentIndex + 1) / state.questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              progress: progress,
              onClose: () => context.go('/welcome'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _QuestionBody(
                  question: state.currentQuestion,
                  selectedAnswer: state.selectedAnswer,
                  isSubmitted: state.isAnswerSubmitted,
                ),
              ),
            ),
            if (state.isAnswerSubmitted)
              _FeedbackBanner(
                isCorrect: state.isCorrect,
                correctAnswerText: _getCorrectAnswerText(state.currentQuestion),
              ),
            _BottomBar(
              isAnswerSelected: state.selectedAnswer != null,
              isSubmitted: state.isAnswerSubmitted,
              onTap: () {
                if (!state.isAnswerSubmitted) {
                  ref.read(placementTestControllerProvider.notifier).submitAnswer();
                } else {
                  ref.read(placementTestControllerProvider.notifier).advance();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getScoreLevel(int correct) {
    if (correct <= 3) return "Boshlang'ich (A1)";
    if (correct <= 8) return "O'rta (A2)";
    return "Ilg'or (B1)";
  }

  String _getCorrectAnswerText(TestQuestion q) {
    switch (q.type) {
      case QuestionType.multipleChoice:
      case QuestionType.visualId:
      case QuestionType.audioTest:
      case QuestionType.fillInBlank:
      case QuestionType.errorId:
        return q.correctAnswerIndex != null ? q.options[q.correctAnswerIndex!] : '';
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
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
            onPressed: onClose,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.7 * progress,
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _QuestionBody extends ConsumerWidget {
  const _QuestionBody({required this.question, required this.selectedAnswer, required this.isSubmitted});
  final TestQuestion question;
  final Object? selectedAnswer;
  final bool isSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.type != QuestionType.fillInBlank) ...[
          Text(
            question.questionText,
            style: AppTypography.heading2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
        if (question.imageUrl != null) ...[
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                question.imageUrl!,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_rounded, size: 80, color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
        if (question.imageUrl == null)
          const SizedBox(height: 8),
        _buildQuestionWidget(),
      ],
    );
  }

  Widget _buildQuestionWidget() {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _MultipleChoiceWidget(question: question, selectedAnswer: selectedAnswer as int?, isSubmitted: isSubmitted);
      case QuestionType.visualId:
        return _MultipleChoiceWidget(question: question, selectedAnswer: selectedAnswer as int?, isSubmitted: isSubmitted);
      case QuestionType.errorId:
        return _MultipleChoiceWidget(question: question, selectedAnswer: selectedAnswer as int?, isSubmitted: isSubmitted);
      case QuestionType.audioTest:
        return _AudioTestWidget(question: question, selectedAnswer: selectedAnswer as int?, isSubmitted: isSubmitted);
      case QuestionType.matchPairs:
        return _MatchPairsWidget(question: question, selectedAnswer: selectedAnswer as Map<String, String>?, isSubmitted: isSubmitted);
      case QuestionType.fillInBlank:
        return _FillInBlankWidget(question: question, selectedAnswer: selectedAnswer as int?, isSubmitted: isSubmitted);
      case QuestionType.sentenceScramble:
        return _SentenceScrambleWidget(question: question, selectedAnswer: selectedAnswer as List<String>?, isSubmitted: isSubmitted);
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
    return Column(
      children: [
        const SizedBox(height: 16),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(question.options.length, (index) {
            final isSelected = selectedAnswer == index;
            final isCorrectOption = index == question.correctAnswerIndex || (question.type == QuestionType.errorId && index == question.errorWordIndex);
            
            Color bgColor = const Color(0xFF1E293B);
            Color borderColor = Colors.white10;

            if (isSubmitted) {
              if (isSelected && isCorrectOption) {
                bgColor = AppColors.emerald.withValues(alpha: 0.2);
                borderColor = AppColors.emerald;
              } else if (isSelected && !isCorrectOption) {
                bgColor = AppColors.error.withValues(alpha: 0.2);
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
                constraints: BoxConstraints(minWidth: question.options.length > 2 ? 140 : double.infinity),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))],
                ),
                child: Text(
                  question.options[index],
                  textAlign: TextAlign.center,
                  style: AppTypography.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _AudioTestWidget extends ConsumerStatefulWidget {
  const _AudioTestWidget({required this.question, required this.selectedAnswer, required this.isSubmitted});
  final TestQuestion question;
  final int? selectedAnswer;
  final bool isSubmitted;

  @override
  ConsumerState<_AudioTestWidget> createState() => _AudioTestWidgetState();
}

class _AudioTestWidgetState extends ConsumerState<_AudioTestWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing && state.processingState != ProcessingState.completed;
          _isLoading = state.processingState == ProcessingState.loading || state.processingState == ProcessingState.buffering;
        });
      }
    });
    
    try {
      if (widget.question.audioUrl != null && widget.question.audioUrl!.startsWith('http')) {
        await _audioPlayer.setUrl(widget.question.audioUrl!);
      } else {
        await _audioPlayer.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
      }
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void didUpdateWidget(covariant _AudioTestWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.audioUrl != widget.question.audioUrl) {
      _initAudio();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        InkWell(
          onTap: () async {
            if (_isPlaying) {
              await _audioPlayer.pause();
            } else {
              if (_audioPlayer.processingState == ProcessingState.completed) {
                await _audioPlayer.seek(Duration.zero);
              }
              await _audioPlayer.play();
            }
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: _isLoading 
                ? const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppColors.emerald, strokeWidth: 3),
                  )
                : Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded, 
                    color: AppColors.emerald, 
                    size: 40
                  ),
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(widget.question.options.length, (index) {
            final isSelected = widget.selectedAnswer == index;
            final isCorrectOption = index == widget.question.correctAnswerIndex;
            
            Color bgColor = const Color(0xFF1E293B);
            Color borderColor = Colors.white10;

            if (widget.isSubmitted) {
              if (isSelected && isCorrectOption) {
                bgColor = AppColors.emerald.withValues(alpha: 0.2);
                borderColor = AppColors.emerald;
              } else if (isSelected && !isCorrectOption) {
                bgColor = AppColors.error.withValues(alpha: 0.2);
                borderColor = AppColors.error;
              } else if (isCorrectOption) {
                borderColor = AppColors.emerald;
              }
            } else if (isSelected) {
              bgColor = const Color(0xFF334155);
              borderColor = AppColors.emerald;
            }

            return InkWell(
              onTap: widget.isSubmitted ? null : () => ref.read(placementTestControllerProvider.notifier).selectAnswer(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                constraints: BoxConstraints(minWidth: widget.question.options.length > 2 ? 140 : double.infinity),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))],
                ),
                child: Text(
                  widget.question.options[index],
                  textAlign: TextAlign.center,
                  style: AppTypography.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
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
    rightWords.sort((a, b) => b.compareTo(a)); 

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: leftWords.map((word) => _buildPairButton(
                word: word,
                isSelected: selectedLeft == word,
                isMatched: matched.containsKey(word),
                onTap: () => _onTapLeft(word),
              )).toList(),
            ),
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
      bgColor = AppColors.emerald.withValues(alpha: 0.2);
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
    String firstPart = question.questionText.split('___').first;
    if (firstPart.contains(': ')) {
        firstPart = firstPart.split(': ').last;
    }
    final lastPart = question.questionText.split('___').last;

    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 12,
              children: [
                Text(
                  firstPart.trim(),
                  style: AppTypography.heading2.copyWith(color: Colors.white),
                ),
                DragTarget<int>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 80,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedAnswer != null ? AppColors.emerald.withValues(alpha: 0.2) : Colors.white10,
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
                Text(
                  lastPart.trim(),
                  style: AppTypography.heading2.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 60),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(question.options.length, (index) {
              final isSelected = selectedAnswer == index;
              if (isSelected) return const SizedBox(width: 80, height: 40); 
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
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _assembled.map((word) => InkWell(
                onTap: () => _onTapAssembled(word),
                child: _buildChip(word),
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: _available.map((word) => InkWell(
              onTap: () => _onTapAvailable(word),
              child: _buildChip(word),
            )).toList(),
          ),
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

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.isCorrect, required this.correctAnswerText});
  final bool isCorrect;
  final String correctAnswerText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.emerald.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
        border: Border(top: BorderSide(color: isCorrect ? AppColors.emerald : AppColors.error, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: isCorrect ? AppColors.emerald : AppColors.error, size: 28),
              const SizedBox(width: 12),
              Text(
                isCorrect ? "Barakalla!" : "Noto'g'ri",
                style: AppTypography.heading2.copyWith(color: isCorrect ? AppColors.emerald : AppColors.error, fontSize: 22),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 12),
            Text("To'g'ri javob:", style: AppTypography.body.copyWith(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(correctAnswerText, style: AppTypography.heading2.copyWith(color: AppColors.error)),
          ],
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.isAnswerSelected, required this.isSubmitted, required this.onTap});
  final bool isAnswerSelected;
  final bool isSubmitted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: isSubmitted 
        ? (isAnswerSelected ? AppColors.emerald.withValues(alpha: 0.05) : AppColors.error.withValues(alpha: 0.05))
        : AppColors.background,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isAnswerSelected || isSubmitted ? onTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSubmitted ? (isAnswerSelected ? AppColors.emerald : AppColors.emerald) : AppColors.emerald,
              disabledBackgroundColor: const Color(0xFF334155),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              isSubmitted ? "DAVOM ETISH" : "TEKSHIRISH",
              style: AppTypography.heading2.copyWith(color: isAnswerSelected || isSubmitted ? Colors.white : Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}

class TestResultScreen extends StatefulWidget {
  const TestResultScreen({super.key, required this.score});
  final String score;

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars_rounded, color: AppColors.emerald, size: 80),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Test Yakunlandi!',
                      textAlign: TextAlign.center,
                      style: AppTypography.heading1.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sizning arab tili darajangiz:',
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: AppColors.emerald.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Text(
                        widget.score,
                        textAlign: TextAlign.center,
                        style: AppTypography.heading1.copyWith(color: AppColors.background, fontSize: 24),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: ElevatedButton(
                  onPressed: () {
                    if (context.mounted) {
                      context.go(AppRoutes.home);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppColors.emerald.withValues(alpha: 0.5),
                  ),
                  child: Text(
                    "Arab tili dunyosiga sho'ng'ish",
                    style: AppTypography.heading2.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
