import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:arabcha/app/theme/app_colors.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AlifStep9Finish extends StatefulWidget {
  final int overallScore;
  final VoidCallback onFinish;

  const AlifStep9Finish({super.key, required this.overallScore, required this.onFinish});

  @override
  State<AlifStep9Finish> createState() => _AlifStep9FinishState();
}

class _AlifStep9FinishState extends State<AlifStep9Finish> with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _confettiCtrl;

  late final Animation<double> _scoreAnim;
  late final Animation<double> _starsScale1;
  late final Animation<double> _starsScale2;
  late final Animation<double> _starsScale3;
  late final Animation<double> _tabriklaymizScale;
  late final Animation<double> _unlockedScale;
  late final Animation<double> _xpScale;
  late final Animation<double> _streakScale;

  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Future<void> _shareResult() async {
    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      
      final buffer = byteData.buffer;
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/arabcha_natija.png').create();
      await file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      
      final text = "🔥 Men Arab Alifbosini o'rganishda davom etyapman!\n\nBugungi darsda ${widget.overallScore}% natija qayd etdim va 'Ba' harfini ochdim! 🚀\n\nSen ham men bilan birga o'rgan: https://play.google.com/store/apps/details?id=uz.arabcha.app";
      
      await Share.shareXFiles([XFile(file.path)], text: text);
    } catch (e) {
      debugPrint("Error sharing: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    _scoreAnim = Tween<double>(begin: 0, end: widget.overallScore.toDouble()).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.1, 0.4, curve: Curves.easeOutCubic)),
    );

    _starsScale1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.3, 0.45, curve: Curves.elasticOut)),
    );
    _starsScale2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.4, 0.55, curve: Curves.elasticOut)),
    );
    _starsScale3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.5, 0.65, curve: Curves.elasticOut)),
    );

    _tabriklaymizScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.55, 0.70, curve: Curves.elasticOut)),
    );

    _unlockedScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.65, 0.80, curve: Curves.elasticOut)),
    );

    _xpScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.75, 0.90, curve: Curves.elasticOut)),
    );

    _streakScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.85, 1.0, curve: Curves.elasticOut)),
    );

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _ringCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Uses AlifLessonPage background
      body: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: Stack(
          alignment: Alignment.center,
          children: [
          // Background Glow
          Positioned(
            top: 100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.emerald.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Expanding Rings
          Positioned(
            top: 160,
            child: AnimatedBuilder(
              animation: _ringCtrl,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (index) {
                    final delay = index * 0.33;
                    double progress = (_ringCtrl.value + delay) % 1.0;
                    double scale = 1.0 + (progress * 2.5);
                    double opacity = 1.0 - progress;
                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.emerald.withOpacity(0.3), width: 2),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          // Confetti overlay
          _buildConfetti(),

          // Main Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(flex: 1),
                
                // Score Ring
                AnimatedBuilder(
                  animation: _entranceCtrl,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: _scoreAnim.value / 100,
                            strokeWidth: 9,
                            backgroundColor: const Color(0xFF1A1F2E),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "${_scoreAnim.value.toInt()}",
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 52,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                const Text(
                                  "%",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.emerald,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "NATIJA",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Stars
                AnimatedBuilder(
                  animation: _entranceCtrl,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Transform.scale(
                          scale: _starsScale1.value,
                          child: const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 40),
                        ),
                        const SizedBox(width: 8),
                        Transform.scale(
                          scale: _starsScale2.value,
                          child: const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 54),
                        ),
                        const SizedBox(width: 8),
                        Transform.scale(
                          scale: _starsScale3.value,
                          child: const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 40),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                AnimatedBuilder(
                  animation: _tabriklaymizScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _tabriklaymizScale.value,
                      child: const Text(
                        "Tabriklaymiz!",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // New letter unlocked card
                AnimatedBuilder(
                  animation: _unlockedScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _unlockedScale.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.emerald.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Text(
                                  "ب",
                                  style: TextStyle(
                                    fontFamily: 'Noto Naskh Arabic',
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.emerald,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Yangi harf ochildi!",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Ba — keyingi dars",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.emerald,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // XP Earned
                AnimatedBuilder(
                  animation: _xpScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _xpScale.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bolt_rounded, color: Color(0xFFFACC15), size: 24),
                          SizedBox(width: 4),
                          Text(
                            "+45 XP",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFACC15),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Streak
                AnimatedBuilder(
                  animation: _streakScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _streakScale.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF8C28), size: 20),
                          SizedBox(width: 6),
                          Text(
                            "7 kunlik seriya!",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF8C28),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(flex: 2),
                
                // Bottom Buttons
                _buildCTAs(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildCTAs() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: const Color(0xFF0A0E1A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 8,
                shadowColor: AppColors.emerald.withOpacity(0.5),
              ),
              child: const Text(
                "Darsni yakunlash ›",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _shareResult,
            child: const Text(
              "Natijalarni ulashish",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiCtrl,
      builder: (context, child) {
        final height = MediaQuery.of(context).size.height;
        final width = MediaQuery.of(context).size.width;
        
        return Stack(
          children: List.generate(15, (index) {
            final random = math.Random(index * 12345);
            final double startX = random.nextDouble() * width;
            final double speed = 0.5 + random.nextDouble() * 0.5;
            final Color color = [
              AppColors.emerald,
              const Color(0xFFFACC15),
              const Color(0xFFA78BFA),
              const Color(0xFF34D399),
            ][random.nextInt(4)];
            
            // Phase loop
            final double progress = (_confettiCtrl.value * speed + random.nextDouble()) % 1.0;
            final double y = -50 + (height + 100) * progress;
            final double xOffset = math.sin(progress * math.pi * 4 + index) * 30;
            final double rotation = progress * math.pi * 4 * (index % 2 == 0 ? 1 : -1);

            return Positioned(
              left: startX + xOffset,
              top: y,
              child: Transform.rotate(
                angle: rotation,
                child: Container(
                  width: 6 + random.nextDouble() * 6,
                  height: 6 + random.nextDouble() * 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(random.nextDouble() > 0.5 ? 2 : 10),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
