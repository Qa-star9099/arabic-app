import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SplashPage — animated logo reveal screen
//
// Animations (matches splash_screen_v3.html exactly):
//   r1  breath  3.2s ease-in-out ∞           — center orb (scale + opacity)
//   r2  breath2 3.2s ease-in-out ∞ +0.5s     — bottom-right violet orb
//   r3  breath3 3.2s ease-in-out ∞ +1.0s     — top-left green orb
//   logo-pop   0.7s cubic-bezier spring +0.3s — logo container
//   name-in    0.6s ease +0.85s               — "Arabcha" title
//   tag-in     0.6s ease +1.1s               — tagline (opacity→0.55)
//   bar-fill   2.2s cubic +1.4s              — progress bar → 72%
//   d1/d2/d3   1.2s +1.4s ∞                 — sequential loading dots
//
// Navigation: after 3800ms → AppRoutes.welcome
// ─────────────────────────────────────────────────────────────────────────────

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // ── Orb breath controllers ────────────────────────────────────────────────
  late final AnimationController _orbCtrl; // r1 — center
  late final AnimationController _orb2Ctrl; // r2 — bottom-right
  late final AnimationController _orb3Ctrl; // r3 — top-left

  // ── One-shot entrance controllers ─────────────────────────────────────────
  late final AnimationController _logoCtrl; // pop-in
  late final AnimationController _nameCtrl; // fade-up
  late final AnimationController _tagCtrl; // tag-in
  late final AnimationController _barCtrl; // bar-fill

  // ── Loading dot controller ────────────────────────────────────────────────
  late final AnimationController _dotCtrl; // d1/d2/d3 loop

  // ── Derived animations ────────────────────────────────────────────────────
  // Orb: scale
  late final Animation<double> _orb1Scale;
  late final Animation<double> _orb2Scale;
  late final Animation<double> _orb3Scale;
  // Orb: opacity
  late final Animation<double> _orb1Opacity;
  late final Animation<double> _orb2Opacity;
  late final Animation<double> _orb3Opacity;

  // Logo pop-in (spring: 0.7→1.06→1.0)
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // Name fade-up
  late final Animation<double> _nameOpacity;
  late final Animation<Offset> _nameSlide;

  // Tag fade-up (final opacity = 0.55)
  late final Animation<double> _tagOpacity;
  late final Animation<Offset> _tagSlide;

  // Progress bar (0 → 0.72)
  late final Animation<double> _barProgress;

  // Loading dots opacity (staggered via dotCtrl value)
  late final Animation<double> _dot1Opacity;
  late final Animation<double> _dot2Opacity;
  late final Animation<double> _dot3Opacity;

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _setupAnimations();
    _startSequence();
  }

  void _setupControllers() {
    // ── Infinite breath orbs (3.2s each) ─────────────────────────────────
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _orb2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _orb3Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // ── One-shot entrance ─────────────────────────────────────────────────
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _nameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _tagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // ── Dot loop (1.2s cycle) ─────────────────────────────────────────────
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  void _setupAnimations() {
    // ── Orb 1 (center): breath — scale 1→1.15, opacity 0.6→0.25 ──────────
    _orb1Scale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut),
    );
    _orb1Opacity = Tween<double>(begin: 0.06, end: 0.025).animate(
      CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut),
    );

    // ── Orb 2 (bottom-right): breath2 — scale 1→1.2, opacity 0.4→0.15 ────
    _orb2Scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _orb2Ctrl, curve: Curves.easeInOut),
    );
    _orb2Opacity = Tween<double>(begin: 0.10, end: 0.04).animate(
      CurvedAnimation(parent: _orb2Ctrl, curve: Curves.easeInOut),
    );

    // ── Orb 3 (top-left): breath3 — scale 1→1.25, opacity 0.3→0.1 ────────
    _orb3Scale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _orb3Ctrl, curve: Curves.easeInOut),
    );
    _orb3Opacity = Tween<double>(begin: 0.08, end: 0.025).animate(
      CurvedAnimation(parent: _orb3Ctrl, curve: Curves.easeInOut),
    );

    // ── Logo pop-in: cubic-bezier(0.34,1.56,0.64,1) — spring overshoot ───
    // Simulated with two-stage sequence: 0→0.7 scale 0.7→1.06, 0.7→1.0 scale 1.06→1.0
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_logoCtrl);

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // ── Name fade-up: opacity 0→1, translateY 14px→0 ─────────────────────
    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _nameCtrl, curve: Curves.easeOut),
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 14 / 600), // normalized
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _nameCtrl, curve: Curves.easeOut));

    // ── Tag-in: opacity 0→0.55, translateY 8px→0 ─────────────────────────
    _tagOpacity = Tween<double>(begin: 0.0, end: 0.55).animate(
      CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut),
    );
    _tagSlide = Tween<Offset>(
      begin: const Offset(0, 8 / 600),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut));

    // ── Bar-fill: 0 → 0.72, cubic-bezier(0.4,0,0.2,1) ────────────────────
    _barProgress = Tween<double>(begin: 0.0, end: 0.72).animate(
      CurvedAnimation(parent: _barCtrl, curve: Curves.fastOutSlowIn),
    );

    // ── Loading dots: staggered opacity via dotCtrl value ─────────────────
    // dot1 peaks at 25% of cycle, dot2 at 50%, dot3 at 75%
    _dot1Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.25), weight: 75),
    ]).animate(_dotCtrl);

    _dot2Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.25), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.25), weight: 50),
    ]).animate(_dotCtrl);

    _dot3Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 1.0), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.25), weight: 25),
    ]).animate(_dotCtrl);
  }

  Future<void> _startSequence() async {
    // Orb 2 starts with 500ms delay (CSS: 0.5s)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _orb2Ctrl.repeat(reverse: true);
    });

    // Orb 3 starts with 1000ms delay (CSS: 1.0s)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _orb3Ctrl.repeat(reverse: true);
    });

    // Logo pop-in at 300ms
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoCtrl.forward();

    // Name fade-up at 850ms
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    _nameCtrl.forward();

    // Tagline at 1100ms
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _tagCtrl.forward();

    // Bar + dots at 1400ms
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _barCtrl.forward();
    _dotCtrl.repeat();

    // Navigate at 3800ms (total from start)
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    context.go(AppRoutes.welcome);
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _orb2Ctrl.dispose();
    _orb3Ctrl.dispose();
    _logoCtrl.dispose();
    _nameCtrl.dispose();
    _tagCtrl.dispose();
    _barCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Layer 0: Dot grid background ─────────────────────────────────
          const _DotGridPainterWidget(),

          // ── Layer 1: Ambient orbs ─────────────────────────────────────────
          _AmbientOrbs(
            orb1Scale: _orb1Scale,
            orb1Opacity: _orb1Opacity,
            orb2Scale: _orb2Scale,
            orb2Opacity: _orb2Opacity,
            orb3Scale: _orb3Scale,
            orb3Opacity: _orb3Opacity,
          ),

          // ── Layer 2: Main content ─────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: Listenable.merge([_logoCtrl]),
                  builder: (context, _) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: const _LogoWidget(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // App name "Arabcha"
                AnimatedBuilder(
                  animation: _nameCtrl,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _nameOpacity.value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          _nameSlide.value.dy * 600,
                        ),
                        child: const Text(
                          'Kalima كلمة',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.8,
                            height: 1.2,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Tagline
                AnimatedBuilder(
                  animation: _tagCtrl,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _tagOpacity.value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          _tagSlide.value.dy * 600,
                        ),
                        child: const Text(
                          'Arab tilini oson va tez o\'rganing! 🚀',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 56),

                // Progress bar + loading dots
                AnimatedBuilder(
                  animation: Listenable.merge([_barCtrl, _dotCtrl]),
                  builder: (context, _) {
                    return Column(
                      children: [
                        // Progress bar
                        Container(
                          width: 180,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0x12FFFFFF),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _barProgress.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.emerald,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Loading dots
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LoadingDot(opacity: _dot1Opacity.value),
                            const SizedBox(width: 6),
                            _LoadingDot(opacity: _dot2Opacity.value),
                            const SizedBox(width: 6),
                            _LoadingDot(opacity: _dot3Opacity.value),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DotGridPainterWidget — radial dot grid (28×28 spacing, 2.5% white)
// ─────────────────────────────────────────────────────────────────────────────
class _DotGridPainterWidget extends StatelessWidget {
  const _DotGridPainterWidget();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _DotGridPainter()),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double spacing = 28.0;
    const double dotRadius = 1.0;
    final paint = Paint()..color = const Color(0x06FFFFFF);

    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(c * spacing, r * spacing),
          dotRadius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// _AmbientOrbs — three breathing blurred circles in the background
// ─────────────────────────────────────────────────────────────────────────────
class _AmbientOrbs extends StatelessWidget {
  const _AmbientOrbs({
    required this.orb1Scale,
    required this.orb1Opacity,
    required this.orb2Scale,
    required this.orb2Opacity,
    required this.orb3Scale,
    required this.orb3Opacity,
  });

  final Animation<double> orb1Scale;
  final Animation<double> orb1Opacity;
  final Animation<double> orb2Scale;
  final Animation<double> orb2Opacity;
  final Animation<double> orb3Scale;
  final Animation<double> orb3Opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([orb1Scale, orb2Scale, orb3Scale]),
      builder: (context, _) {
        return Stack(
          children: [
            // Orb 3 — top-left green, breath3 (most subtle)
            Positioned(
              top: -80,
              left: -80,
              child: Transform.scale(
                scale: orb3Scale.value,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        AppColors.emerald.withValues(alpha: orb3Opacity.value),
                  ),
                ),
              ),
            ),

            // Orb 2 — bottom-right violet, breath2
            Positioned(
              bottom: -60,
              right: -60,
              child: Transform.scale(
                scale: orb2Scale.value,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        AppColors.violet.withValues(alpha: orb2Opacity.value),
                  ),
                ),
              ),
            ),

            // Orb 1 — center green, breath (most vivid)
            Positioned.fill(
              child: Center(
                child: Transform.scale(
                  scale: orb1Scale.value,
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emerald
                          .withValues(alpha: orb1Opacity.value),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LogoWidget — three-layer glassmorphic logo with Arabic letter + badges
//
// Layer structure (outside → inside):
//   Layer 0 (110×110, r28): emerald-tinted glass, subtle border
//   Layer 1 (90×90,  r20): deeper emerald glass
//   Layer 2 (70×70,  r14): solid #0F6E56, Arabic letter "ع"
//   Badge top-right (28px): gold mic
//   Badge bottom-left (24px): violet star
// ─────────────────────────────────────────────────────────────────────────────
class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Layer 0: outermost glass ──────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: const Color(0x1F1D9E75), // rgba(29,158,117,0.12)
                border: Border.all(
                  color: const Color(0x331D9E75), // rgba(29,158,117,0.2)
                  width: 1,
                ),
              ),
            ),
          ),

          // ── Layer 1: middle glass ─────────────────────────────────────
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0x2E1D9E75), // rgba(29,158,117,0.18)
                border: Border.all(
                  color: const Color(0x4D1D9E75), // rgba(29,158,117,0.3)
                  width: 1,
                ),
              ),
            ),
          ),

          // ── Layer 2: solid inner — Arabic letter ──────────────────────
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.emeraldDark, // #0F6E56
                border: Border.all(
                  color: const Color(0x665DCAA5), // rgba(93,202,165,0.4)
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text(
                  'ع',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),

          // ── Badge top-right: gold microphone ──────────────────────────
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold, // #BA7517
                border: Border.all(
                  color: AppColors.background,
                  width: 2.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.mic_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // ── Badge bottom-left: violet star ────────────────────────────
          Positioned(
            bottom: -4,
            left: -4,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.violet, // #533AB7
                border: Border.all(
                  color: AppColors.background,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.star_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LoadingDot — single dot with given opacity
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingDot extends StatelessWidget {
  const _LoadingDot({required this.opacity});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.emerald,
        ),
      ),
    );
  }
}
