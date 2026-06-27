import re

file_path = 'lib/features/alifbo/presentation/pages/alif_lesson_steps/alif_step_7_talaffuz_sinovi.dart'

with open(file_path, 'r') as file:
    content = file.read()

# 1. Update the `onTap` of HarakatChip to play audio
old_on_tap = """      onTap: () {
        setState(() {
          _kalimaSelectedHarakatIndex = index;
          _kalimaTalaffuzState = TalaffuzState.initial;
        });
      },"""
new_on_tap = """      onTap: () {
        setState(() {
          _kalimaSelectedHarakatIndex = index;
          _kalimaTalaffuzState = TalaffuzState.initial;
        });
        _playKalimaReferenceAudio();
      },"""
content = content.replace(old_on_tap, new_on_tap)

# 2. Restructure the build method children
# We need to replace everything from `const SizedBox(height: 24),` after the HarakatChips Row
# to the end of the children array `const SizedBox(height: 40),`
# Wait, let's find the Exact match.

old_build_middle = """        const SizedBox(height: 24),
        
        Center(
          child: GestureDetector(
            onTap: _playKalimaReferenceAudio,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2A3142), width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF4ADE80), Color(0xFF34D399)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: const Color(0xFF0A0E1A),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Avval eshiting",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const Spacer(),
        
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildKalimaMicInteractiveArea(),
              const SizedBox(height: 14),
              const Text(
                "Bosib turing va talaffuz qiling",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        _buildKalimaCenterWaveform(),
        
        const SizedBox(height: 20),
        
        const Center(
          child: Text(
            "AI natijangizni tahlil qiladi",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        
        const SizedBox(height: 40),"""

new_build_middle = """        const Spacer(flex: 2),
        
        _buildKalimaCenterWaveform(),
        
        const Spacer(flex: 3),
        
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "AI natijangizni tahlil qiladi",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              _buildKalimaMicInteractiveArea(),
              const SizedBox(height: 14),
              const Text(
                "Bosib turing va talaffuz qiling",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),"""

if old_build_middle in content:
    content = content.replace(old_build_middle, new_build_middle)
else:
    print("Warning: old_build_middle not found!")

with open(file_path, 'w') as file:
    file.write(content)
