import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:arabcha/data/models/lesson_models.dart';
import 'package:arabcha/data/repositories/progress_repository.dart';
import 'package:arabcha/core/services/tts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RevealStep extends ConsumerStatefulWidget {
  final LessonTopic topic;
  final LessonWord word;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const RevealStep({
    super.key,
    required this.topic,
    required this.word,
    this.onNext,
    this.onBack,
  });

  @override
  ConsumerState<RevealStep> createState() => _RevealStepState();
}

class _RevealStepState extends ConsumerState<RevealStep> {
  @override
  void initState() {
    super.initState();
  }

  void _onContinue() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await ref.read(progressRepositoryProvider).markWordSeen(uid, widget.word.id);
      } catch (e) {
        debugPrint("Progress save error: \$e");
      }
    }

    if (!mounted) return;
    
    if (widget.onNext != null) {
      widget.onNext!();
    } else {
      // Placeholder for Step 3
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Step 3 (Expand) - coming next",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF3DD68C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
    }
  }

  String _getLatin(String arabicLetter) {
    const map = {
      'س': 's',
      'ف': 'f',
      'ر': 'r',
    };
    return map[arabicLetter] ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    // Generate the "s — f — r" string dynamically
    final latinLettersList = widget.word.root.letters.map((l) => _getLatin(l)).toList();
    // Reversing is not needed for the combined string, we want left-to-right s - f - r
    final combinedLatin = latinLettersList.join(' — ');

    return Scaffold(
      backgroundColor: const Color(0xFF0B1218),
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: -200,
            left: -100,
            right: -100,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1F4D3F).withValues(alpha: 0.5),
                    const Color(0xFF1F4D3F).withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.6],
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
                            border: Border.all(color: const Color(0xFF1E2D3A), width: 0.5),
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_back_rounded, size: 17, color: Color(0xFF6B7A88)),
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
                            widthFactor: 0.25, // Step 2 = 25%
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
                          "2/8",
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
                        // Step header (after 28px from top nav)
                        Padding(
                          padding: const EdgeInsets.only(top: 28, left: 22, right: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "2-QADAM",
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
                                      text: "Arab yozuvi va ",
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        color: const Color(0xFFE8EEF4),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "ildiz",
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
                        ).animate().fadeIn(duration: 200.ms, curve: Curves.easeOut),

                        // Intro text (after 28px from header)
                        Padding(
                          padding: const EdgeInsets.only(top: 28, left: 36, right: 36),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF6B7A88),
                                letterSpacing: 0.3,
                                height: 1.6,
                              ),
                              children: [
                                const TextSpan(text: "Har arab so'zi "),
                                TextSpan(
                                  text: "3 harfli ildiz",
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFE8EEF4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(text: "dan o'sadi"),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 200.ms, curve: Curves.easeOut),

                        // Root card (after 24px from intro)
                        Padding(
                          padding: const EdgeInsets.only(top: 24, left: 22, right: 22),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 28, left: 22, right: 22, bottom: 24),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 255, 255, 0.025),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF1E2D3A), width: 0.5),
                            ),
                            child: Column(
                              children: [
                                // Full Arabic word
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Text(
                                    widget.word.arabic,
                                    style: GoogleFonts.notoNaskhArabic(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFF4F8FC),
                                      // letterSpacing omitted here because 3px breaks cursive connection
                                      height: 1.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // Tap hint
                                Text(
                                  "harfni bosib tinglang",
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: const Color(0xFF6B7A88),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Three letter tiles
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (int i = 0; i < widget.word.root.letters.length; i++) ...[
                                        _buildLetterTile(
                                          widget.word.root.letters[i],
                                          _getLatin(widget.word.root.letters[i]),
                                        ),
                                        if (i < widget.word.root.letters.length - 1)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Text(
                                              "·",
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: const Color(0xFF3D4955),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // Dashed Divider
                                SizedBox(
                                  width: double.infinity,
                                  height: 1,
                                  child: CustomPaint(
                                    painter: DashedLinePainter(color: const Color(0xFF1E2D3A)),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Root meaning summary
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: combinedLatin,
                                        style: GoogleFonts.notoSerif(
                                          fontSize: 13,
                                          color: const Color(0xFF3DD68C),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "  →  ", // 6px margin approximation
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF3D4955),
                                        ),
                                      ),
                                      TextSpan(
                                        text: widget.word.root.meaning,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFFE8EEF4),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " ma'nosi",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF8FA4B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 100.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.05, end: 0, duration: 300.ms, delay: 100.ms, curve: Curves.easeOut),

                        // Hint line
                        Padding(
                          padding: const EdgeInsets.only(top: 24, left: 22, right: 22),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 7),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF3DD68C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Bitta ildizdan o'nlab so'z o'sadi. Keyingi qadamda ko'rasiz.",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF8FA4B8),
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Bottom CTA Button
                Padding(
                  padding: const EdgeInsets.only(left: 22, right: 22, bottom: 24),
                  child: InkWell(
                    onTap: _onContinue,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF3DD68C), Color(0xFF2EB876)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(61, 214, 140, 0.3),
                            spreadRadius: 0.5,
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Davom etish",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0B1218),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded, size: 17, color: Color(0xFF0B1218)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterTile(String arabic, String latin) {
    bool isPressed = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) {
            setState(() => isPressed = false);
            ref.read(ttsServiceProvider).speak(arabic);
          },
          onTapCancel: () => setState(() => isPressed = false),
          child: AnimatedScale(
            scale: isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: const BoxConstraints(minWidth: 56),
              padding: const EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(11, 18, 24, 0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPressed ? const Color(0xFF3DD68C) : const Color(0xFF2A3E4F),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    arabic,
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 32,
                      color: const Color(0xFFF4F8FC),
                      height: 1.0,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volume_up_rounded, size: 10, color: Color(0xFF3DD68C)),
                      const SizedBox(width: 4),
                      Text(
                        latin,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF3DD68C),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    double dashWidth = 4;
    double dashSpace = 4;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
