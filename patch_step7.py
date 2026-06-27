with open('lib/features/alifbo/presentation/pages/alif_lesson_steps/alif_step_7_talaffuz_sinovi.dart', 'r') as f:
    content = f.read()

# 1. Update the central waveform to ignore _isPlayingAudio
content = content.replace("if (isRecording || _isPlayingAudio) {", "if (isRecording) {")
content = content.replace("if (isRecording || _isPlayingAudio) {", "if (isRecording) {")

# 2. Add `isPlayingThis` logic and tiny volume icon to HarakatChip
old_chip_content = """        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              letter,
              style: TextStyle(
                fontFamily: 'Noto Naskh Arabic',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: isSelected ? highlightColor : highlightColor.withValues(alpha: 0.8),
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? highlightColor : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),"""

new_chip_content = """        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Text(
                  letter,
                  style: TextStyle(
                    fontFamily: 'Noto Naskh Arabic',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? highlightColor : highlightColor.withValues(alpha: 0.8),
                    height: 1,
                  ),
                ),
                if (isSelected && _isPlayingAudio)
                  Positioned(
                    right: -20,
                    top: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(3, (barIndex) {
                        return AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            final phase = barIndex * 0.5;
                            final height = 4.0 + 8.0 * __math.sin((_waveController.value * 2 * __math.pi) + phase).abs();
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 3,
                              height: height,
                              decoration: BoxDecoration(
                                color: highlightColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? highlightColor : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),"""

# Note: The file already has `import 'dart:math' as math;`. We should use `math.sin` and `math.pi`. Let's fix the __math to math
new_chip_content = new_chip_content.replace("__math", "math")

content = content.replace(old_chip_content, new_chip_content)

with open('lib/features/alifbo/presentation/pages/alif_lesson_steps/alif_step_7_talaffuz_sinovi.dart', 'w') as f:
    f.write(content)
