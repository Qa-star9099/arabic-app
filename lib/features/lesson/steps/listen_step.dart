import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:arabcha/data/models/lesson_models.dart';
import 'package:arabcha/data/repositories/progress_repository.dart';
import 'package:arabcha/core/services/tts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListenStep extends ConsumerStatefulWidget {
  final LessonTopic topic;
  final LessonWord word;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const ListenStep({
    super.key,
    required this.topic,
    required this.word,
    this.onNext,
    this.onBack,
  });

  @override
  ConsumerState<ListenStep> createState() => _ListenStepState();
}

class _ListenStepState extends ConsumerState<ListenStep> {
  late List<ListenOption> _shuffledOptions;
  ListenOption? _selectedOption;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    // Shuffle options on mount
    _shuffledOptions = List<ListenOption>.from(widget.word.listenOptions)
      ..shuffle();

    // Auto-play target word after 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(ttsServiceProvider).speak(widget.word.arabic);
      }
    });
  }

  void _onOptionSelected(ListenOption option) {
    if (_isChecked) return; // Prevent changing after confirmed

    // Pronounce the word when selecting
    ref.read(ttsServiceProvider).speak(option.arabic);

    setState(() {
      _selectedOption = option;
    });
  }

  void _onConfirm() {
    if (_selectedOption == null || _isChecked) return;

    setState(() {
      _isChecked = true;
    });

    if (_selectedOption!.isCorrect) {
      // Correct answer logic
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        ref.read(progressRepositoryProvider).markWordSeen(uid, widget.word.id);
      }
      // Announce correct
      ref.read(ttsServiceProvider).speak(widget.word.arabic);
    } else {
      // Incorrect answer logic - announce correct word anyway
      ref.read(ttsServiceProvider).speak(widget.word.arabic);
    }

    // Auto-advance after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _onContinue();
      }
    });
  }

  void _onContinue() {
    if (widget.onNext != null) {
      widget.onNext!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Step 5 (Pronounce) - coming next",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color(0xFF3DD68C),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelected = _selectedOption != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1218),
      body: Stack(
        children: [
          // Background Gradient at 35% vertical
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, -0.3),
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3DD68C).withValues(alpha: 0.18),
                      const Color(0xFF1F4D3F).withValues(alpha: 0.08),
                      const Color(0xFF1F4D3F).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.25, 0.55],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Navigation Row
                Padding(
                  padding: const EdgeInsets.only(top: 22, left: 22, right: 22),
                  child: Row(
                    children: [
                      // Back Button
                      InkWell(
                        onTap: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else {
                            context.pop();
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(61, 214, 140, 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFF1E2D3A), width: 0.5),
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_back_rounded,
                                size: 17, color: Color(0xFF6B7A88)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Progress Bar
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF15202A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.5, // 4 of 8 = 50%
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF3DD68C),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Step Counter
                      Container(
                        constraints: const BoxConstraints(minWidth: 28),
                        alignment: Alignment.centerRight,
                        child: Text(
                          "4/8",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7A88),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Step header
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 28, left: 22, right: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "4-QADAM",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7A88),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Quloqni ",
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        color: const Color(0xFFE8EEF4),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "o'rgating",
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        color: const Color(0xFF3DD68C),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 200.ms, curve: Curves.easeOut),

                        // Central audio button section
                        Padding(
                          padding: const EdgeInsets.only(top: 28, bottom: 20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Waveform Background
                              SizedBox(
                                width: double.infinity,
                                height: 100,
                                child: CustomPaint(
                                  painter: WaveformPainter(),
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: 100.ms),

                              // Main Audio Button
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      ref
                                          .read(ttsServiceProvider)
                                          .speak(widget.word.arabic);
                                    },
                                    borderRadius: BorderRadius.circular(42),
                                    child: Container(
                                      width: 84,
                                      height: 84,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFF3DD68C),
                                            Color(0xFF2EB876)
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                61, 214, 140, 0.08),
                                            spreadRadius: 6,
                                          ),
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                61, 214, 140, 0.04),
                                            spreadRadius: 12,
                                          ),
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                61, 214, 140, 0.2),
                                            blurRadius: 24,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.volume_up_rounded,
                                            size: 32, color: Color(0xFF0B1218)),
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(
                                          duration: 200.ms,
                                          curve: Curves.easeOut)
                                      .scale(
                                          begin: const Offset(0.8, 0.8),
                                          duration: 200.ms,
                                          curve: Curves.easeOutBack),
                                  const SizedBox(height: 14),
                                  Text(
                                    "qayta tinglash uchun bosing",
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF6B7A88),
                                      letterSpacing: 1.2,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 200.ms, delay: 100.ms),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Options section
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 28, left: 22, right: 22),
                          child: Column(
                            children: [
                              Text(
                                "SIZ ESHITGAN SO'Z QAYSI?",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7A88),
                                  letterSpacing: 1.2,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 150.ms, delay: 200.ms),
                              const SizedBox(height: 12),
                              for (int i = 0; i < _shuffledOptions.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child:
                                      _buildOptionCard(_shuffledOptions[i], i),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Button
                Padding(
                  padding: const EdgeInsets.only(
                      left: 22, right: 22, bottom: 24, top: 20),
                  child: AnimatedSwitcher(
                    duration: 300.ms,
                    child: hasSelected
                        ? InkWell(
                            key: const ValueKey('tasdiqlash'),
                            onTap: _onConfirm,
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: _isChecked
                                      ? [
                                          const Color(0xFF1F4D3F),
                                          const Color(0xFF15202A)
                                        ]
                                      : [
                                          const Color(0xFF3DD68C),
                                          const Color(0xFF2EB876)
                                        ],
                                ),
                                boxShadow: _isChecked
                                    ? null
                                    : const [
                                        BoxShadow(
                                          color:
                                              Color.fromRGBO(61, 214, 140, 0.3),
                                          spreadRadius: 0.5,
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isChecked
                                        ? "Kutib turing..."
                                        : "Tasdiqlash",
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: _isChecked
                                          ? const Color(0xFF6B7A88)
                                          : const Color(0xFF0B1218),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (!_isChecked) ...[
                                    const SizedBox(width: 10),
                                    const Icon(Icons.check_rounded,
                                        size: 17, color: Color(0xFF0B1218)),
                                  ],
                                ],
                              ),
                            ),
                          )
                        : InkWell(
                            key: const ValueKey('sekinroq_tinglash'),
                            onTap: () {
                              // temporary: slower rate 0.3
                              ref
                                  .read(ttsServiceProvider)
                                  .speak(widget.word.arabic, slow: true);
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.transparent,
                                border: Border.all(
                                    color: const Color(0xFF1E2D3A), width: 0.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.replay_circle_filled_rounded,
                                      size: 14,
                                      color: Color(
                                          0xFF6B7A88)), // Or any suitable icon
                                  const SizedBox(width: 8),
                                  Text(
                                    "sekinroq tinglash",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6B7A88),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(ListenOption option, int index) {
    final isSelected = _selectedOption == option;

    // Determine colors
    Color borderColor = const Color(0xFF2A3E4F);
    Color bgColor = const Color.fromRGBO(255, 255, 255, 0.03);

    if (_isChecked) {
      if (option.isCorrect) {
        borderColor = const Color(0xFF3DD68C);
        bgColor = const Color.fromRGBO(61, 214, 140, 0.08);
      } else if (isSelected && !option.isCorrect) {
        borderColor = const Color(0xFFD64242);
        bgColor = const Color.fromRGBO(214, 66, 66, 0.08);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFFF4F8FC); // Bright white for clear focus
      bgColor = const Color.fromRGBO(255, 255, 255, 0.1);
    }

    Widget cardContent = AnimatedContainer(
      duration: 200.ms,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          // Small Audio Button
          GestureDetector(
            onTap: () {
              ref.read(ttsServiceProvider).speak(option.arabic);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(61, 214, 140, 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color.fromRGBO(61, 214, 140, 0.2), width: 0.5),
              ),
              child: const Center(
                child: Icon(Icons.volume_up_rounded,
                    size: 14, color: Color(0xFF3DD68C)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    option.arabic,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF4F8FC),
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.meaning,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B7A88),
                  ),
                ),
              ],
            ),
          ),

          // Status Icon
          if (_isChecked && (option.isCorrect || isSelected))
            Icon(
              option.isCorrect
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: option.isCorrect
                  ? const Color(0xFF3DD68C)
                  : const Color(0xFFD64242),
              size: 20,
            ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
        ],
      ),
    );

    // Apply hit animation if just selected
    if (isSelected) {
      cardContent = cardContent
          .animate()
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.02, 1.02),
            duration: 100.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.02, 1.02),
            end: const Offset(1.0, 1.0),
            duration: 100.ms,
            curve: Curves.easeIn,
          );
    }

    return GestureDetector(
      onTap: () => _onOptionSelected(option),
      child: cardContent,
    ).animate().fadeIn(duration: 300.ms, delay: (200 + index * 60).ms).slideY(
        begin: 0.1, end: 0, duration: 300.ms, delay: (200 + index * 60).ms);
  }
}

// Custom Painter for Waveform
class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3DD68C)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;

    // 8 bars pattern heights
    final heights = [4.0, 8.0, 16.0, 32.0, 50.0, 24.0, 12.0, 6.0];
    final opacities = [0.3, 0.4, 0.5, 0.7, 0.9, 0.7, 0.5, 0.3];

    // Draw Left Side
    double startXLeft = size.width / 2 - 100; // starting far left from center
    for (int i = 0; i < heights.length; i++) {
      paint.color = const Color(0xFF3DD68C)
          .withValues(alpha: opacities[i] * 0.5); // Global opacity 0.5
      canvas.drawLine(
        Offset(startXLeft + (i * 8), centerY - heights[i] / 2),
        Offset(startXLeft + (i * 8), centerY + heights[i] / 2),
        paint,
      );
    }

    // Draw Right Side
    double startXRight =
        size.width / 2 + 100 - (heights.length * 8); // starting far right
    for (int i = 0; i < heights.length; i++) {
      int revIdx = heights.length - 1 - i;
      paint.color =
          const Color(0xFF3DD68C).withValues(alpha: opacities[revIdx] * 0.5);
      canvas.drawLine(
        Offset(startXRight + (i * 8), centerY - heights[revIdx] / 2),
        Offset(startXRight + (i * 8), centerY + heights[revIdx] / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
