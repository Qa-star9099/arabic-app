import re

file_path = '/Users/abdulbasitswe/arabic_app/lib/features/placement_test/screens/placement_test_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# 1. MultipleChoiceWidget
# Remove Directionality.rtl and change to Wrap
mc_pattern = r'Directionality\(\s*textDirection: TextDirection\.rtl,\s*child: Column\(\s*children: List\.generate\(question\.options\.length, \(index\) \{.*?(?=return Padding\(\n)'
mc_replacement = r'''Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(question.options.length, (index) {'''

# Change the button inside MultipleChoiceWidget to not be double.infinity if it's short, or just use a nice flex. Actually, for a Grid-like look:
mc_item_pattern = r'return Padding\(\s*padding: const EdgeInsets\.only\(bottom: 12\),\s*child: InkWell\((.*?)\s*width: double\.infinity,\s*padding: const EdgeInsets\.symmetric\(horizontal: 20, vertical: 18\),'
mc_item_replacement = r'''return InkWell(\1
                  constraints: const BoxConstraints(minWidth: 140),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),'''

# It's safer to rewrite the classes completely using string replacement since regex can be brittle here.

mc_widget_new = """class _MultipleChoiceWidget extends ConsumerWidget {
  const _MultipleChoiceWidget({required this.question, required this.selectedAnswer, required this.isSubmitted});
  final TestQuestion question;
  final int? selectedAnswer;
  final bool isSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (question.imageUrl != null) ...[
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(question.imageUrl!, height: 160, width: double.infinity, fit: BoxFit.contain),
          ),
        ],
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
}"""

content = re.sub(r'class _MultipleChoiceWidget extends ConsumerWidget \{.*?(?=\nclass _AudioTestWidget)', mc_widget_new + "\n", content, flags=re.DOTALL)


audio_widget_new = """class _AudioTestWidget extends ConsumerStatefulWidget {
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
}"""

content = re.sub(r'class _AudioTestWidget extends ConsumerStatefulWidget \{.*?(?=\nclass _MatchPairsWidget)', audio_widget_new + "\n", content, flags=re.DOTALL)

# In FillInBlankWidget and SentenceScrambleWidget, add `alignment: WrapAlignment.center` to all Wraps so they are centered instead of pushed to the right.
# Also remove Directionality from MatchPairsWidget left column and just set TextAlign.right if needed, actually MatchPairs should just use Wrap/Column safely.
# Wait, for Arabic text, we DO want it centered.
# FillInBlank options Wrap
content = content.replace("Directionality(\n          textDirection: TextDirection.rtl,\n          child: Wrap(\n            spacing: 12,\n            runSpacing: 12,\n            children: List.generate(question.options.length",
                          "Wrap(\n          spacing: 12,\n          runSpacing: 12,\n          alignment: WrapAlignment.center,\n          children: List.generate(question.options.length")

# SentenceScramble assembled wrap
content = content.replace("child: Wrap(\n              spacing: 8,\n              runSpacing: 8,\n              children: _assembled",
                          "child: Wrap(\n              alignment: WrapAlignment.center,\n              spacing: 8,\n              runSpacing: 8,\n              children: _assembled")

# SentenceScramble available wrap
content = content.replace("child: Wrap(\n            spacing: 8,\n            runSpacing: 8,\n            children: _available",
                          "child: Wrap(\n            alignment: WrapAlignment.center,\n            spacing: 8,\n            runSpacing: 8,\n            children: _available")

# FillInBlank top wrap
content = content.replace("child: Wrap(\n              alignment: WrapAlignment.center,\n              crossAxisAlignment: WrapCrossAlignment.center,\n              spacing: 8,\n              runSpacing: 12,",
                          "child: Wrap(\n              alignment: WrapAlignment.center,\n              crossAxisAlignment: WrapCrossAlignment.center,\n              spacing: 8,\n              runSpacing: 12,")

with open(file_path, 'w') as f:
    f.write(content)
