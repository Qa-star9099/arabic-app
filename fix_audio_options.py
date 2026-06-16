import re

file_path = '/Users/abdulbasitswe/arabic_app/lib/features/placement_test/screens/placement_test_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

# Fix the call
content = content.replace("selectedAnswer as String?,", "selectedAnswer as int?,")

new_audio_widget = """class _AudioTestWidget extends ConsumerStatefulWidget {
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
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: widget.question.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Text(
                    widget.question.options[index],
                    style: AppTypography.body.copyWith(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}"""

content = re.sub(r'class _AudioTestWidget extends ConsumerStatefulWidget \{.*?(?=\nclass _MatchPairsWidget)', new_audio_widget + "\n", content, flags=re.DOTALL)

with open(file_path, 'w') as f:
    f.write(content)
