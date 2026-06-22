import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:arabcha/data/models/lesson_models.dart';
import 'package:arabcha/data/repositories/progress_repository.dart';
import 'package:arabcha/core/services/tts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpandStep extends ConsumerStatefulWidget {
  final LessonTopic topic;
  final LessonWord word;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const ExpandStep({
    super.key,
    required this.topic,
    required this.word,
    this.onNext,
    this.onBack,
  });

  @override
  ConsumerState<ExpandStep> createState() => _ExpandStepState();
}

class _ExpandStepState extends ConsumerState<ExpandStep> {
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
      // Placeholder for Step 4
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Step 4 (Listen) - coming next",
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

  @override
  Widget build(BuildContext context) {
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
                            widthFactor: 0.375, // Step 3 = ~37.5%
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
                          "3/8",
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
                          padding: const EdgeInsets.only(top: 28, left: 22, right: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "3-QADAM",
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
                                      text: "Bitta o'zak, ",
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        color: const Color(0xFFE8EEF4),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "ko'p so'zlar",
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

                        // Intro text
                        Padding(
                          padding: const EdgeInsets.only(top: 28, left: 36, right: 36),
                          child: Text(
                            "O'zak bir xil qolsa-da, unga harflar qo'shish orqali yangi so'zlar yasaladi.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF6B7A88),
                              letterSpacing: 0.3,
                              height: 1.6,
                            ),
                          ),
                        ).animate().fadeIn(duration: 200.ms, curve: Curves.easeOut),

                        // The Root display (Small context)
                        Padding(
                          padding: const EdgeInsets.only(top: 24, left: 22, right: 22),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(61, 214, 140, 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color.fromRGBO(61, 214, 140, 0.15), width: 0.5),
                              ),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  widget.word.root.letters.join(' - '),
                                  style: GoogleFonts.notoNaskhArabic(
                                    fontSize: 24,
                                    color: const Color(0xFF3DD68C),
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                        // Family words list
                        Padding(
                          padding: const EdgeInsets.only(top: 24, left: 22, right: 22),
                          child: Column(
                            children: [
                              for (int i = 0; i < widget.word.family.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildFamilyCard(widget.word.family[i], i),
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

  Widget _buildFamilyCard(FamilyWord familyWord, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(ttsServiceProvider).speak(familyWord.arabic);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.025),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E2D3A), width: 0.5),
          ),
          child: Row(
            children: [
              // Audio Button (visual only now, or keeps its own tap)
              Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF3DD68C), Color(0xFF2EB876)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(61, 214, 140, 0.3),
                    spreadRadius: 0.5,
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFF0B1218)),
              ),
            ),
          const SizedBox(width: 16),
          // Uzbek Meaning & Transliteration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  familyWord.meaning,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFFE8EEF4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  familyWord.transliteration,
                  style: GoogleFonts.notoSerif(
                    fontSize: 13,
                    color: const Color(0xFF8FA4B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Arabic Word
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              familyWord.arabic,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF4F8FC),
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (100 + index * 100).ms, curve: Curves.easeOut).slideX(begin: 0.05, end: 0, duration: 300.ms, delay: (100 + index * 100).ms);
  }
}
