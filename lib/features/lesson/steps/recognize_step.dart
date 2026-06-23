import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:arabcha/data/models/lesson_models.dart';
import 'package:arabcha/data/repositories/progress_repository.dart';
import 'package:arabcha/core/services/tts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecognizeStep extends ConsumerStatefulWidget {
  final LessonTopic topic;
  final LessonWord word;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const RecognizeStep({
    super.key,
    required this.topic,
    required this.word,
    this.onNext,
    this.onBack,
  });

  @override
  ConsumerState<RecognizeStep> createState() => _RecognizeStepState();
}

class _RecognizeStepState extends ConsumerState<RecognizeStep> {
  @override
  void initState() {
    super.initState();
  }

  void _onContinue() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await ref
            .read(progressRepositoryProvider)
            .markWordSeen(uid, widget.word.id);
      } catch (e) {
        debugPrint("Progress save error: \$e");
      }
    }

    if (!mounted) return;

    if (widget.onNext != null) {
      widget.onNext!();
    } else {
      // Placeholder for Step 2
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Step 2 (Reveal) - coming next",
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

  List<String> _getSyllableParts() {
    String text = widget.word.transliteration;
    if (text.toLowerCase() == 'safar') {
      return ['sa-', 'FAR'];
    }

    // Basic fallback for other words
    int mid = text.length ~/ 2;
    if (mid == 0) return ['', text.toUpperCase()];
    return ['${text.substring(0, mid)}-', text.substring(mid).toUpperCase()];
  }

  @override
  Widget build(BuildContext context) {
    final uzbekCapitalized = widget.word.uzbekCognate.isNotEmpty
        ? widget.word.uzbekCognate[0].toUpperCase() +
            widget.word.uzbekCognate.substring(1)
        : '';

    final syllableParts = _getSyllableParts();

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
                            widthFactor: 0.14, // Step 1 = ~14%
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
                        alignment: Alignment.center,
                        child: Text(
                          "1/8",
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

                // Topic Badge
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 22, right: 22),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(61, 214, 140, 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: const Color.fromRGBO(61, 214, 140, 0.15),
                            width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flight_takeoff_rounded,
                              size: 12, color: Color(0xFF3DD68C)),
                          const SizedBox(width: 6),
                          Text(
                            "${widget.topic.title} · tanish",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF3DD68C),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Uzbek Word Hero Section
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 48, left: 36, right: 36),
                          child: Column(
                            children: [
                              Text(
                                "Bu so'zni siz allaqachon bilasiz",
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF6B7A88),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                uzbekCapitalized,
                                style: GoogleFonts.inter(
                                  fontSize: 44,
                                  color: const Color(0xFFE8EEF4),
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 14),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "o'zbekcha",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF6B7A88),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "  ·  ",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF3D4955),
                                      ),
                                    ),
                                    TextSpan(
                                      text: widget.word.uzbekMeaning,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF6B7A88),
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

                        // Arabic Word Card
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 36, left: 22, right: 22),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                ref
                                    .read(ttsServiceProvider)
                                    .speak(widget.word.arabic);
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 28, horizontal: 22),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(
                                      255, 255, 255, 0.025),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color: const Color(0xFF1E2D3A),
                                      width: 0.5),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "arab tilida ham xuddi shu so'z",
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF3DD68C),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                        widget.word.arabic,
                                        style: GoogleFonts.notoNaskhArabic(
                                          fontSize: 72,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFF4F8FC),
                                          height: 1.0,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: syllableParts[0],
                                                style: GoogleFonts.notoSerif(
                                                  fontSize: 14,
                                                  color:
                                                      const Color(0xFF8FA4B8),
                                                  letterSpacing: 1.0,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              TextSpan(
                                                text: syllableParts.length > 1
                                                    ? syllableParts[1]
                                                    : '',
                                                style: GoogleFonts.notoSerif(
                                                  fontSize: 14,
                                                  color:
                                                      const Color(0xFFE8EEF4),
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        InkWell(
                                          onTap: () {
                                            ref
                                                .read(ttsServiceProvider)
                                                .speak(widget.word.arabic);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(19),
                                          child: Container(
                                            width: 38,
                                            height: 38,
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
                                                      61, 214, 140, 0.3),
                                                  spreadRadius: 0.5,
                                                  blurRadius: 0,
                                                ),
                                              ],
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                  Icons.volume_up_rounded,
                                                  size: 18,
                                                  color: Color(0xFF0B1218)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(
                            duration: 300.ms,
                            delay: 100.ms,
                            curve: Curves.easeOut),

                        // Hint line
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 24, left: 22, right: 22),
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
                                  "Siz noldan boshlamayapsiz — o'zbek tilidagi yuzlab so'z arab tilidan kelgan.",
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
                  padding:
                      const EdgeInsets.only(left: 22, right: 22, bottom: 24),
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
                          const Icon(Icons.arrow_forward_rounded,
                              size: 17, color: Color(0xFF0B1218)),
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
}
