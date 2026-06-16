import re

file_path = '/Users/abdulbasitswe/arabic_app/lib/features/placement_test/screens/placement_test_screen.dart'
with open(file_path, 'r') as f:
    content = f.read()

if "package:just_audio/just_audio.dart" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:just_audio/just_audio.dart';")

new_state = """class _AudioTestWidgetState extends ConsumerState<_AudioTestWidget> {
  late TextEditingController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedAnswer);
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
        // Fallback generic sound if not a valid network URL
        await _audioPlayer.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
      }
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void didUpdateWidget(covariant _AudioTestWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAnswer != _controller.text && widget.selectedAnswer == null) {
      _controller.clear();
    }
    if (oldWidget.question.audioUrl != widget.question.audioUrl) {
      _initAudio();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
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
        TextField(
          controller: _controller,
          enabled: !widget.isSubmitted,
          textAlign: TextAlign.center,
          style: AppTypography.heading2.copyWith(color: Colors.white),
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
}"""

content = re.sub(r'class _AudioTestWidgetState extends ConsumerState<_AudioTestWidget> \{.*?(?=\nclass _MatchPairsWidget)', new_state + "\n", content, flags=re.DOTALL)

with open(file_path, 'w') as f:
    f.write(content)
