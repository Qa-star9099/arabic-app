import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/services/azure_tts_service.dart';

class AlifStep8Tekshirish extends StatefulWidget {
  final void Function(bool isPassed, {int? score}) onResult;

  const AlifStep8Tekshirish({
    super.key,
    required this.onResult,
  });

  @override
  State<AlifStep8Tekshirish> createState() => _AlifStep8TekshirishState();
}

class _AlifStep8TekshirishState extends State<AlifStep8Tekshirish> {
  final _audioPlayer = AudioPlayer();
  
  int _currentRound = 1;
  int _correctCount = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _isPlaying = false;
  String? _letterAudioPath;

  @override
  void initState() {
    super.initState();
    _preloadAudio();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudioForRound();
    });
  }

  Future<void> _preloadAudio() async {
    try {
      _letterAudioPath = await AzureTTSService.synthesizeArabicSpeech("أَلِف");
    } catch (e) {
      debugPrint("Audio preload error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudioForRound() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);
    
    try {
      if (_currentRound == 1) {
        if (_letterAudioPath == null) await _preloadAudio();
        if (_letterAudioPath != null) {
          await _audioPlayer.setFilePath(_letterAudioPath!);
          await _audioPlayer.play();
        }
      } else if (_currentRound == 2) {
        // Round 2 target is Fatha
        await _audioPlayer.setAsset('assets/audio/fatha.mp3');
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  void _handleSubmit() {
    setState(() => _answered = true);
    
    // Check answer correctness based on round
    bool isCorrect = false;
    if (_currentRound == 1) {
      // 0 is Alif in the letters grid
      isCorrect = _selectedOption == 0;
    } else if (_currentRound == 2) {
      // 0 is Fatha in the harakats row
      isCorrect = _selectedOption == 0;
    } else if (_currentRound == 3) {
      // 1 is Final Alif in the shapes grid
      isCorrect = _selectedOption == 1;
    }

    if (isCorrect) {
      _correctCount++;
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Text("To'g'ri!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 20, right: 20),
          duration: const Duration(seconds: 2),
          elevation: 0,
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.close_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Text("Noto'g'ri!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 20, right: 20),
          duration: const Duration(seconds: 2),
          elevation: 0,
        ),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      if (_currentRound < 3) {
        setState(() {
          _currentRound++;
          _selectedOption = null;
          _answered = false;
        });
        _playAudioForRound();
      } else {
        // Finished all 3 rounds
        bool isPassed = _correctCount >= 2;
        widget.onResult(isPassed, score: _correctCount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const Spacer(flex: 1),
          _buildPlayButton(),
          const Spacer(flex: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildRoundContent(key: ValueKey(_currentRound)),
          ),
          const Spacer(flex: 2),
          _buildSubmitButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title = "";
    if (_currentRound == 1) title = "Harfni toping";
    if (_currentRound == 2) title = "Belgini toping";
    if (_currentRound == 3) title = "Shakl sinovi";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          "Savol $_currentRound / 3",
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.emerald,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    String subtitle = "";
    if (_currentRound == 1) subtitle = "Quyidagi harflar orasidan Alifni toping";
    if (_currentRound == 2) subtitle = "Eshiting va mos keladigan belgini tanlang";
    if (_currentRound == 3) subtitle = "Alifning to'g'ri ko'rinishini tanlang";

    return Text(
      subtitle,
      style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
    );
  }

  Widget _buildPlayButton() {
    if (_currentRound == 3) return const SizedBox.shrink();

    return Center(
      child: GestureDetector(
        onTap: _playAudioForRound,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2433),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.emerald,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.stop : Icons.play_arrow,
                  color: const Color(0xFF0A0E1A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Tovushni eshiting",
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundContent({Key? key}) {
    if (_currentRound == 1) {
      return _buildLettersGrid(key: key);
    } else if (_currentRound == 2) {
      return _buildHarakatsRow(key: key);
    } else {
      return _buildShapesGrid(key: key);
    }
  }

  Widget _buildLettersGrid({Key? key}) {
    final letters = [
      {"label": "Alif", "text": "ا"}, // Index 0 (Correct)
      {"label": "Lam", "text": "ل"},  // Index 1
      {"label": "Ba", "text": "ب"},   // Index 2
      {"label": "Ta", "text": "ت"},   // Index 3
    ];

    return GridView.builder(
      key: key,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 156 / 120,
      ),
      itemBuilder: (context, index) {
        final letter = letters[index];
        final isSelected = _selectedOption == index;
        return GestureDetector(
          onTap: () {
            if (!_answered) setState(() => _selectedOption = index);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2A3142) : const Color(0xFF1E2433),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? Colors.white.withOpacity(0.5) : const Color(0xFF2A3142),
                width: isSelected ? 2.0 : 0.5,
              ),
            ),
            child: Center(
              child: Text(
                letter["text"]!,
                style: TextStyle(
                  fontFamily: 'Noto Naskh Arabic',
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  height: 1.20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHarakatsRow({Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildHarakatOption(0, "Fatha", "َ")), // Correct
              const SizedBox(width: 12),
              Expanded(child: _buildHarakatOption(1, "Kasra", "ِ")),
              const SizedBox(width: 12),
              Expanded(child: _buildHarakatOption(2, "Damma", "ُ")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHarakatOption(int index, String label, String symbol) {
    final isSelected = _selectedOption == index;
    return GestureDetector(
      onTap: () {
        if (!_answered) setState(() => _selectedOption = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2A3142) : const Color(0xFF1E2433),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white.withOpacity(0.5) : Colors.transparent,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                symbol,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShapesGrid({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question card: "So'z oxirida"
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E),
            border: Border.all(color: const Color(0xFF2A3142), width: 0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFA78BFA).withValues(alpha: 0.12),
                      border: Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.25)),
                    ),
                    child: const Center(
                      child: Icon(Icons.menu_rounded, color: Color(0xFFA78BFA), size: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Alif so'z oxirida qanday yoziladi?",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Visual example: word context
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1f2738), width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 16, decoration: BoxDecoration(color: const Color(0xFF2A3142), borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 6),
                    Container(width: 30, height: 16, decoration: BoxDecoration(color: const Color(0xFF2A3142), borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 6),
                    Text(
                      "?",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5EEAD4),
                        height: 1,
                        shadows: [Shadow(color: const Color(0xFF5EEAD4).withValues(alpha: 0.3), blurRadius: 8)],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Two large answer cards
              Row(
                children: [
                  Expanded(child: _buildShapeOption(0, "Alohida", "ا")),
                  const SizedBox(width: 14),
                  Expanded(child: _buildShapeOption(1, "Oxirida", "ـا")),
                ],
              ),
            ],
          ),
        ),
        
      ],
    );
  }

  Widget _buildShapeOption(int index, String label, String shapeText) {
    final isSelected = _selectedOption == index;

    return GestureDetector(
      onTap: () {
        if (!_answered) setState(() => _selectedOption = index);
      },
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4ADE80).withValues(alpha: 0.08) : const Color(0xFF141824),
          border: Border.all(
            color: isSelected ? const Color(0xFF4ADE80) : const Color(0xFF2A3142),
            width: isSelected ? 2 : 0.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  shapeText,
                  style: TextStyle(
                    fontFamily: 'Noto Naskh Arabic',
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? const Color(0xFF4ADE80) : const Color(0xFF6B7280),
                    height: 1,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Color(0xFF0A0E1A), size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = _selectedOption != null;
    
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: canSubmit && !_answered ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          disabledBackgroundColor: const Color(0xFF2A3142),
          foregroundColor: const Color(0xFF0A0E1A),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text(
          'Davom etish >',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
