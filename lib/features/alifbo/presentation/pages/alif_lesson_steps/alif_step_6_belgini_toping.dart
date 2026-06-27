import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../app/theme/app_colors.dart';

class AlifStep6BelginiToping extends StatefulWidget {
  final int currentRound;
  final int totalRounds;
  final int correctAnswer;
  final int? selectedAnswer;
  final bool answered;
  final ValueChanged<int> onOptionSelected;
  final VoidCallback onReset;

  const AlifStep6BelginiToping({
    super.key,
    required this.currentRound,
    required this.totalRounds,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.answered,
    required this.onOptionSelected,
    required this.onReset,
  });

  @override
  State<AlifStep6BelginiToping> createState() => _AlifStep6BelginiTopingState();
}

class _AlifStep6BelginiTopingState extends State<AlifStep6BelginiToping> {
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playMashqAudio();
    });
  }

  @override
  void didUpdateWidget(AlifStep6BelginiToping oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRound != widget.currentRound) {
      _playMashqAudio();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playMashqAudio() async {
    String assetName = '';
    if (widget.correctAnswer == 0) assetName = 'fatha.mp3';
    else if (widget.correctAnswer == 1) assetName = 'kasra.mp3';
    else if (widget.correctAnswer == 2) assetName = 'damma.mp3';

    try {
      await _audioPlayer.setAsset('assets/audio/$assetName');
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing mashq audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text("6. Belgini toping", style: TextStyle(fontFamily: 'Geist', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 16),
          const Text(
            "Eshiting va belgini tanlang",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Raund ${widget.currentRound} / ${widget.totalRounds}",
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: widget.onReset,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "Qayta",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _playMashqAudio,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF041A0E),
                      size: 60,
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                Row(
                  children: [
                    Expanded(child: _buildMashqOptionCard(0, "اَ", "Fatha")),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMashqOptionCard(1, "اِ", "Kasra")),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMashqOptionCard(2, "اُ", "Damma")),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMashqOptionCard(int index, String arabicChar, String label) {
    bool isSelected = widget.selectedAnswer == index;
    bool isCorrect = false;
    
    if (widget.answered) {
      if (index == widget.correctAnswer) {
        isCorrect = true;
      }
    }

    Color borderColor = Colors.white.withOpacity(0.05);
    if (!widget.answered && isSelected) {
      borderColor = Colors.white.withOpacity(0.5);
    } else if (widget.answered && isSelected) {
      borderColor = isCorrect ? AppColors.emerald : AppColors.error;
    } else if (widget.answered && !isSelected && widget.correctAnswer == index) {
      borderColor = AppColors.emerald;
    }

    return GestureDetector(
      onTap: () => widget.onOptionSelected(index),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected || (widget.answered && widget.correctAnswer == index) ? 2 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  arabicChar,
                  style: TextStyle(
                    color: isSelected && isCorrect ? AppColors.emerald : Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected && isCorrect ? AppColors.emerald : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: isSelected && isCorrect ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (isSelected && isCorrect)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.emerald,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF041A0E),
                    size: 12,
                  ),
                ),
              ),
            if (widget.answered && isSelected && !isCorrect)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
