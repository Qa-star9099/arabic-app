import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:arabcha/data/models/lesson_models.dart';
import 'package:arabcha/features/lesson/providers/lesson_providers.dart';
import 'package:arabcha/core/services/tts_service.dart';

class LessonAgendaPage extends ConsumerStatefulWidget {
  final String id;
  const LessonAgendaPage({super.key, required this.id});

  @override
  ConsumerState<LessonAgendaPage> createState() => _LessonAgendaPageState();
}

class _LessonAgendaPageState extends ConsumerState<LessonAgendaPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final topicAsync = ref.watch(topicProvider(widget.id));

    return Scaffold(
      backgroundColor: const Color(0xFF0B1218), // Deep blue-black
      body: topicAsync.when(
        data: (topic) => Stack(
          children: [
            // Background Radial Gradients
            Positioned(
              top: -150,
              left: -100,
              right: -100,
              height: 500,
              child: Container(
                decoration: BoxDecoration(
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
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35 - 200,
              left: -100,
              right: -100,
              height: 400,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3DD68C).withValues(alpha: 0.08),
                      const Color(0xFF3DD68C).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
            ),
            
            // Main Content
            SafeArea(
              child: _buildContent(context, topic),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF3DD68C)),
        ),
        error: (err, stack) => const Center(
          child: Text(
            'Xatolik yuz berdi',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LessonTopic topic) {
    final wordObj = topic.words.isNotEmpty ? topic.words.first : null;
    final String cognateRaw = wordObj?.uzbekCognate ?? 'safar';
    final String cognate = cognateRaw.toLowerCase();
    
    final totalWords = topic.words.fold<int>(0, (sum, w) => sum + w.family.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Row
        Padding(
          padding: const EdgeInsets.only(left: 22, right: 22, top: 22),
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3DD68C).withValues(alpha: 0.04),
                    border: Border.all(color: const Color(0xFF1E2D3A), width: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 17,
                      color: Color(0xFF6B7A88),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3DD68C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "birinchi dars",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF6B7A88),
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40), // Balance right side
            ],
          ),
        ),

        // Main middle section (no scroll)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    Text(
                      "«$cognate» so'zi va",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE8EEF4),
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "uning oilasi",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8FA4B8),
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms, curve: Curves.easeOut),

              const Spacer(flex: 3),

              // Hero Arabic Word
              SizedBox(
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // SVG-like Waves background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: HeroWavesPainter(),
                      ),
                    ),
                    
                    // Text Elements
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          wordObj?.arabic ?? 'سَفَر',
                          style: GoogleFonts.notoNaskhArabic(
                            fontSize: 88,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFF4F8FC),
                            height: 1.0,
                            // Removed letterSpacing because it breaks Arabic letter connections!
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          wordObj?.transliteration.toLowerCase() ?? 'safar',
                          style: GoogleFonts.notoSerif(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF6B7A88),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms, curve: Curves.easeOut),

              const Spacer(flex: 3),

              // Description Paragraph
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8FA4B8),
                      height: 1.7,
                    ),
                    children: [
                      const TextSpan(text: "Bu darsda "),
                      TextSpan(
                        text: cognate,
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFE8EEF4)),
                      ),
                      const TextSpan(text: " so'zining ildizidan "),
                      TextSpan(
                        text: "$totalWords",
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFE8EEF4)),
                      ),
                      const TextSpan(text: " ta yangi so'z ochasiz. So'ngida ulardan gap tuzib, suhbatda erkin ishlatasiz."),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms, delay: 200.ms),

              const Spacer(flex: 3),

              // Three Info Points (flowing, no container)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    _buildInfoRow("$totalWords ta yangi arab so'zi", "bitta ildizdan o'sgan", 300),
                    const SizedBox(height: 18),
                    _buildInfoRow("gap tuzish mashqi", "suhbatda erkin ishlatish uchun", 400),
                    const SizedBox(height: 18),
                    _buildInfoRow("talaffuz va tinglash", "native ohang bilan", 500),
                  ],
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),

        // CTA Button and Context Line (Pinned to bottom)
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CTA Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D3DD68C), // 0.3 opacity glow
                      blurRadius: 0,
                      spreadRadius: 0.5,
                    ),
                  ],
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF3DD68C), Color(0xFF2EB876)],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => context.push('/lesson/${topic.id}'),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "boshlash",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              color: const Color(0xFF0B1218),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Color(0xFF0B1218),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Context Line (under the button)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildContextText(topic.title.toLowerCase()),
                  _buildContextDot(),
                  _buildContextText("5 daqiqa"),
                  _buildContextDot(),
                  Text(
                    topic.isFree ? "bepul" : "premium",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: const Color(0xFF3DD68C), // Selling point
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String main, String sub, int delay) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFF3DD68C),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                main,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFE8EEF4),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                sub,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7A88),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate(delay: delay.ms).fadeIn(duration: 200.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildContextText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF6B7A88),
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildContextDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 2,
        height: 2,
        decoration: const BoxDecoration(
          color: Color(0xFF3D4955),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Custom painter that replicates the exact SVG paths and control points from the design
class HeroWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = const Color(0xFF3DD68C);
    
    // Center it vertically in the available space, assuming original viewBox was 180h
    final double verticalShift = (size.height / 2) - 90; 

    // Helper function to map the SVG's M, Q, and T path commands
    void drawWave({
      required double yOffset,
      required double cpY1Offset,
      required double strokeWidth,
      required double opacityMultiplier,
    }) {
      final paint = Paint()
        ..color = baseColor.withValues(alpha: 0.18 * opacityMultiplier)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true;

      final path = Path();
      
      // X Coordinates based on the SVG
      const double startX = -20;
      const double cp1X = 60;
      const double midX = 140;
      const double endX = 340;

      // Calculate reflection manually for the 'T' command:
      const double cp2X = midX + (midX - cp1X); // 220
      final double cp2Y = yOffset + (yOffset - cpY1Offset);

      // We shift everything down by verticalShift so it centers in our container
      final shiftedYOffset = yOffset + verticalShift;
      final shiftedCpY1Offset = cpY1Offset + verticalShift;
      final shiftedCpY2Offset = cp2Y + verticalShift;

      // Start path (M)
      path.moveTo(startX, shiftedYOffset);
      
      // First curve (Q)
      path.quadraticBezierTo(cp1X, shiftedCpY1Offset, midX, shiftedYOffset);
      
      // Second smooth curve (T)
      path.quadraticBezierTo(cp2X, shiftedCpY2Offset, endX, shiftedYOffset);

      // Third smooth curve (T) to cover very wide mobile screens
      const double cp3X = endX + (endX - cp2X); // 460
      final double cp3Y = shiftedYOffset + (shiftedYOffset - shiftedCpY2Offset);
      path.quadraticBezierTo(cp3X, cp3Y, 540, shiftedYOffset);

      canvas.drawPath(path, paint);
    }

    // Replicating the exact lines from the <path> tags
    
    // Wave 1 (Center)
    drawWave(yOffset: 90, cpY1Offset: 50, strokeWidth: 0.8, opacityMultiplier: 1.0);
    
    // Wave 2 (Lower 1)
    drawWave(yOffset: 105, cpY1Offset: 65, strokeWidth: 0.6, opacityMultiplier: 0.7);
    
    // Wave 3 (Lower 2)
    drawWave(yOffset: 120, cpY1Offset: 80, strokeWidth: 0.5, opacityMultiplier: 0.5);
    
    // Wave 4 (Upper 1 - inverted control points)
    drawWave(yOffset: 75, cpY1Offset: 115, strokeWidth: 0.6, opacityMultiplier: 0.6);
    
    // Wave 5 (Upper 2)
    drawWave(yOffset: 60, cpY1Offset: 100, strokeWidth: 0.5, opacityMultiplier: 0.4);

    // Draw the two glowing dots floating on the center line
    final dotPaint = Paint()..color = baseColor.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(40, 90 + verticalShift), 1.5, dotPaint);
    canvas.drawCircle(Offset(280, 90 + verticalShift), 1.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
