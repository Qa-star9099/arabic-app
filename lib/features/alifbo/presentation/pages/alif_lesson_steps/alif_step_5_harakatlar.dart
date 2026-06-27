import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../app/theme/app_colors.dart';

class AlifStep5Harakatlar extends StatefulWidget {
  final void Function({required bool isReady}) onStepStateChanged;

  const AlifStep5Harakatlar({super.key, required this.onStepStateChanged});

  @override
  State<AlifStep5Harakatlar> createState() => _AlifStep5HarakatlarState();
}

class _AlifStep5HarakatlarState extends State<AlifStep5Harakatlar> {
  final _audioPlayer = AudioPlayer();
  int? _playingHarakatIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStepStateChanged(isReady: true);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playHarakat(int index, String assetName) async {
    if (_playingHarakatIndex == index) return;
    
    setState(() {
      _playingHarakatIndex = index;
    });

    try {
      await _audioPlayer.setAsset('assets/audio/$assetName');
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing audio: $e");
    } finally {
      if (mounted && _playingHarakatIndex == index) {
        setState(() {
          _playingHarakatIndex = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 16),
        Text("5. Harakatlar", style: TextStyle(fontFamily: 'Geist', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5))),
        const SizedBox(height: 24),
        const Text(
          "Qisqa unlilar — Harakat",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Arabchada 3 ta qisqa unli bor. Bular kichik belgilar bo'lib, harflar ustida yoki ostida yoziladi.",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        
        // Fatha
        _buildHarakatCard(
          index: 0,
          title: "Fatha «a»",
          subtitle: "Qisqa 'a' tovushi",
          arabicChar: "اَ",
          accentColor: AppColors.emerald,
          audioAsset: "fatha.mp3", 
        ),
        const SizedBox(height: 16),
        
        // Kasra
        _buildHarakatCard(
          index: 1,
          title: "Kasra «i»",
          subtitle: "Qisqa 'i' tovushi",
          arabicChar: "اِ",
          accentColor: AppColors.violetLight,
          audioAsset: "kasra.mp3",
        ),
        const SizedBox(height: 16),
        
        // Damma
        _buildHarakatCard(
          index: 2,
          title: "Damma «u»",
          subtitle: "Qisqa 'u' tovushi",
          arabicChar: "اُ",
          accentColor: AppColors.goldLight,
          audioAsset: "damma.mp3", 
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHarakatCard({
    required int index,
    required String title,
    required String subtitle,
    required String arabicChar,
    required Color accentColor,
    required String audioAsset,
  }) {
    final isPlaying = _playingHarakatIndex == index;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              arabicChar,
              style: TextStyle(
                color: accentColor,
                fontSize: 36,
                fontWeight: FontWeight.w500,
                height: 1.2,
                fontFamily: 'serif',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _playHarakat(index, audioAsset),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: isPlaying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
