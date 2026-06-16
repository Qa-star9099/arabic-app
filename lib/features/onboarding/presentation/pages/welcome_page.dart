import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  // ── Entrance & Fill Animations ─────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final AnimationController _fillCtrl; // For score circle & accuracy bar

  // ── Card Floating Controllers ──────────────────────────────────────────────
  late final AnimationController _card1FloatCtrl;
  late final AnimationController _card2FloatCtrl;
  late final AnimationController _card3FloatCtrl;

  // ── Ambient Orb Controllers ────────────────────────────────────────────────
  late final AnimationController _orbFloatCtrl;

  // ── Entrance Animations (Intervals of _entranceCtrl) ──────────────────────


  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleSlide;



  late final Animation<double> _feature1Opacity;
  late final Animation<double> _feature1Slide;

  late final Animation<double> _feature2Opacity;
  late final Animation<double> _feature2Slide;

  late final Animation<double> _feature3Opacity;
  late final Animation<double> _feature3Slide;

  late final Animation<double> _buttonOpacity;
  late final Animation<double> _buttonSlide;

  late final Animation<double> _footerOpacity;
  late final Animation<double> _footerSlide;

  // ── Fill Progress Animations ───────────────────────────────────────────────
  late final Animation<double> _makhrajAccuracyProgress;
  late final Animation<double> _todayScoreProgress;

  // ── Card Float Animations ──────────────────────────────────────────────────
  late final Animation<double> _card1Offset;
  late final Animation<double> _card2Offset;
  late final Animation<double> _card3Offset;

  // ── Orb Animations ─────────────────────────────────────────────────────────
  late final Animation<double> _orb1Scale;
  late final Animation<double> _orb1Opacity;
  late final Animation<double> _orb2Scale;
  late final Animation<double> _orb2Opacity;

  @override
  void initState() {
    super.initState();

    // ── 1. Initialize Animation Controllers ─────────────────────────────────
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _card1FloatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _card2FloatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _card3FloatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _orbFloatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // ── 2. Configure Entrance Animations (Staggered Fade-Up) ─────────────────


    // Title ("The Arabic app...")
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );



    // Feature 1 (AI Makhraj evaluation)
    _feature1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );
    _feature1Slide = Tween<double>(begin: -20.0, end: 0.0).animate( // Horizontal slide-in
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );

    // Feature 2 (Uzbek-Arab connections)
    _feature2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );
    _feature2Slide = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );

    // Feature 3 (Gamified learning)
    _feature3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );
    _feature3Slide = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );

    // Get Started Button
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Sign in footer
    _footerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );
    _footerSlide = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    // ── 3. Configure Progress Fills ──────────────────────────────────────────
    _makhrajAccuracyProgress = Tween<double>(begin: 0.0, end: 0.87).animate(
      CurvedAnimation(parent: _fillCtrl, curve: Curves.fastOutSlowIn),
    );

    _todayScoreProgress = Tween<double>(begin: 0.0, end: 0.77).animate( // (220-50)/220 = ~0.77 fill
      CurvedAnimation(parent: _fillCtrl, curve: Curves.fastOutSlowIn),
    );

    // ── 4. Configure Card Floats (Infinite up/down floating) ─────────────────
    _card1Offset = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _card1FloatCtrl, curve: Curves.easeInOut),
    );
    _card2Offset = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _card2FloatCtrl, curve: Curves.easeInOut),
    );
    _card3Offset = Tween<double>(begin: 0.0, end: -5.0).animate(
      CurvedAnimation(parent: _card3FloatCtrl, curve: Curves.easeInOut),
    );

    // ── 5. Configure Orb Breathing ───────────────────────────────────────────
    _orb1Scale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _orbFloatCtrl, curve: Curves.easeInOut),
    );
    _orb1Opacity = Tween<double>(begin: 0.08, end: 0.14).animate(
      CurvedAnimation(parent: _orbFloatCtrl, curve: Curves.easeInOut),
    );

    _orb2Scale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _orbFloatCtrl,
        curve: const Interval(0.375, 1.0, curve: Curves.easeInOut), // Delayed start simulation
      ),
    );
    _orb2Opacity = Tween<double>(begin: 0.08, end: 0.14).animate(
      CurvedAnimation(
        parent: _orbFloatCtrl,
        curve: const Interval(0.375, 1.0, curve: Curves.easeInOut),
      ),
    );

    // ── 6. Start Animations ──────────────────────────────────────────────────
    _entranceCtrl.forward();
    _fillCtrl.forward();

    _card1FloatCtrl.repeat(reverse: true);
    // Add staggered offsets for the other two cards
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _card2FloatCtrl.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _card3FloatCtrl.repeat(reverse: true);
    });

    _orbFloatCtrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _fillCtrl.dispose();
    _card1FloatCtrl.dispose();
    _card2FloatCtrl.dispose();
    _card3FloatCtrl.dispose();
    _orbFloatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Layer 0: Dot Grid Background ───────────────────────────────────
          const _DotGridPainterWidget(),

          // ── Layer 1: Ambient Glowing Orbs ──────────────────────────────────
          _AmbientWelcomeOrbs(
            orb1Scale: _orb1Scale,
            orb1Opacity: _orb1Opacity,
            orb2Scale: _orb2Scale,
            orb2Opacity: _orb2Opacity,
          ),

          // ── Layer 2: Main Welcome Interface ─────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Showcase Floating Cards Area ───────────────────────────────
                const Spacer(flex: 1),
                _CardsShowcaseContainer(
                    card1Offset: _card1Offset,
                    card2Offset: _card2Offset,
                    card3Offset: _card3Offset,
                    makhrajAccuracyProgress: _makhrajAccuracyProgress,
                    todayScoreProgress: _todayScoreProgress,
                  ),

                  // ── Middle Copy & Features Section ─────────────────────────────
                  const Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title heading
                        AnimatedBuilder(
                          animation: _entranceCtrl,
                          builder: (context, _) {
                            return Opacity(
                              opacity: _titleOpacity.value,
                              child: Transform.translate(
                                offset: Offset(0, _titleSlide.value),
                                child: const Text(
                                  'Arab tilini oson o\'rganing!\n🌟 يلا نتعلم',
                                  style: TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),


                        // Features List (slide in horizontally)
                        _AnimatedFeatureItem(
                          opacity: _feature1Opacity,
                          slide: _feature1Slide,
                          icon: Icons.mic_rounded,
                          iconColor: AppColors.emeraldLight,
                          iconBg: const Color(0x261D9E75),
                          iconBorder: const Color(0x401D9E75),
                          title: 'Maxrajni SI bilan tekshirish ',
                          subtitle: 'Talaffuzingiz to\'g\'riligini baholaymiz!',
                        ),
                        const SizedBox(height: 12),
                        _AnimatedFeatureItem(
                          opacity: _feature2Opacity,
                          slide: _feature2Slide,
                          icon: Icons.local_fire_department_rounded,
                          iconColor: AppColors.goldLight,
                          iconBg: const Color(0x26BA7517),
                          iconBorder: const Color(0x40BA7517),
                          title: 'O\'zaro bog\'liq O\'zbek-Arab so\'zlari ',
                          subtitle: 'Umumiy so\'zlar orqali 2x tez o\'rganing!',
                        ),
                        const SizedBox(height: 12),
                        _AnimatedFeatureItem(
                          opacity: _feature3Opacity,
                          slide: _feature3Slide,
                          icon: Icons.emoji_events_rounded,
                          iconColor: AppColors.violetLight,
                          iconBg: const Color(0x26533AB7),
                          iconBorder: const Color(0x40533AB7),
                          title: 'Interaktiv o\'rganish metodikasi',
                          subtitle: 'XP yig\'ing va peshqadam bo\'ling! ممتاز',
                        ),
                      ],
                    ),
                  ),

                  // ── Bottom Action Button Section ────────────────────────────────
                  const Spacer(flex: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Get Started Button
                        AnimatedBuilder(
                          animation: _entranceCtrl,
                          builder: (context, _) {
                            return Opacity(
                              opacity: _buttonOpacity.value,
                              child: Transform.translate(
                                offset: Offset(0, _buttonSlide.value),
                                child: _GetStartedButton(
                                  onPressed: () => context.go(AppRoutes.goalSelection),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Footer Sign-in Link
                        AnimatedBuilder(
                          animation: _entranceCtrl,
                          builder: (context, _) {
                            return Opacity(
                              opacity: _footerOpacity.value,
                              child: Transform.translate(
                                offset: Offset(0, _footerSlide.value),
                                child: Center(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'Allaqachon akkauntingiz bormi? ',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: const Color(0x40FFFFFF),
                                        fontSize: 12,
                                      ),
                                      children: [
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: GestureDetector(
                                            onTap: () => context.push(AppRoutes.login),
                                            child: Text(
                                              'Tizimga kirish',
                                              style: TextStyle(
                                                color: AppColors.emeraldLight,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
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
// _AmbientWelcomeOrbs — two breathing background orbs (matching HTML layout)
// ─────────────────────────────────────────────────────────────────────────────
class _AmbientWelcomeOrbs extends StatelessWidget {
  const _AmbientWelcomeOrbs({
    required this.orb1Scale,
    required this.orb1Opacity,
    required this.orb2Scale,
    required this.orb2Opacity,
  });

  final Animation<double> orb1Scale;
  final Animation<double> orb1Opacity;
  final Animation<double> orb2Scale;
  final Animation<double> orb2Opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([orb1Scale, orb2Scale]),
      builder: (context, _) {
        return Stack(
          children: [
            // Orb 1 — top-right violet orb
            Positioned(
              top: -60,
              right: -60,
              child: Transform.scale(
                scale: orb1Scale.value,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.violet.withValues(alpha: orb1Opacity.value),
                  ),
                ),
              ),
            ),

            // Orb 2 — middle-left green/emerald orb
            Positioned(
              top: 80,
              left: -80,
              child: Transform.scale(
                scale: orb2Scale.value,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emerald.withValues(alpha: orb2Opacity.value),
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
// _CardsShowcaseContainer — absolute positioned floating cards canvas
// ─────────────────────────────────────────────────────────────────────────────
class _CardsShowcaseContainer extends StatelessWidget {
  const _CardsShowcaseContainer({
    required this.card1Offset,
    required this.card2Offset,
    required this.card3Offset,
    required this.makhrajAccuracyProgress,
    required this.todayScoreProgress,
  });

  final Animation<double> card1Offset;
  final Animation<double> card2Offset;
  final Animation<double> card3Offset;
  final Animation<double> makhrajAccuracyProgress;
  final Animation<double> todayScoreProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Card 1 (Left): Makhraj (float1) ────────────────────────────────
          AnimatedBuilder(
            animation: card1Offset,
            builder: (context, _) {
              return Positioned(
                top: 15 + card1Offset.value,
                left: 16,
                child: Transform.rotate(
                  angle: -1.5 * math.pi / 180,
                  child: _MakhrajCard(
                    accuracyProgress: makhrajAccuracyProgress,
                  ),
                ),
              );
            },
          ),

          // ── Card 2 (Right): Today's Score (float2) ─────────────────────────
          AnimatedBuilder(
            animation: card2Offset,
            builder: (context, _) {
              return Positioned(
                top: 20 + card2Offset.value,
                right: 16,
                child: Transform.rotate(
                  angle: 2.0 * math.pi / 180,
                  child: _TodayScoreCard(
                    scoreProgress: todayScoreProgress,
                  ),
                ),
              );
            },
          ),

          // ── Card 3 (Center/Lower): Uzbek Learners (float3) ─────────────────
          AnimatedBuilder(
            animation: card3Offset,
            builder: (context, _) {
              return Positioned(
                bottom: 12 + card3Offset.value,
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.rotate(
                    angle: -0.5 * math.pi / 180,
                    child: const _UzbekLearnersCard(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MakhrajCard — visual representation of AI Makhraj evaluation card
// ─────────────────────────────────────────────────────────────────────────────
class _MakhrajCard extends StatelessWidget {
  const _MakhrajCard({required this.accuracyProgress});
  final Animation<double> accuracyProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF), // white 4%
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0x1AFFFFFF), // white 10%
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Rounded icon + text
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0x331D9E75), // emerald 20%
                  border: Border.all(
                    color: const Color(0x4D1D9E75), // emerald 30%
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.mic_rounded,
                  size: 20,
                  color: AppColors.emeraldLight,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maxraj مخرج',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'AI tekshiruvi',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 10.5,
                        color: Color(0x66FFFFFF), // white 40%
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: "ع" + accuracy slider
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'ع',
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedBuilder(
                  animation: accuracyProgress,
                  builder: (context, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Slide container
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0x14FFFFFF), // white 8%
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: accuracyProgress.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.emerald,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(accuracyProgress.value * 100).toInt()}% aniq',
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.emeraldLight,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: Waveform animation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WaveformBar(height: 13, opacity: 0.4),
              _WaveformBar(height: 18, opacity: 0.6),
              _WaveformBar(height: 26, opacity: 1.0),
              _WaveformBar(height: 21, opacity: 0.7),
              _WaveformBar(height: 16, opacity: 0.5),
              _WaveformBar(height: 23, opacity: 0.8),
              _WaveformBar(height: 13, opacity: 0.4),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaveformBar extends StatelessWidget {
  const _WaveformBar({required this.height, required this.opacity});
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TodayScoreCard — visual representation of Today's score card
// ─────────────────────────────────────────────────────────────────────────────
class _TodayScoreCard extends StatelessWidget {
  const _TodayScoreCard({required this.scoreProgress});
  final Animation<double> scoreProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circle score animation
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ProgressCirclePainter(
                      progress: scoreProgress,
                      backgroundColor: const Color(0x12FFFFFF),
                      color: AppColors.gold,
                    ),
                  ),
                ),
                Center(
                  child: const Text(
                    '94',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Score text
          Text(
            'Bugungi Natija 🏆',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(height: 3),

          // Streak text
          const Text(
            '🔥 7 kunlik seriya',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 11,
              color: Color(0x59FFFFFF), // white 35%
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCirclePainter extends CustomPainter {
  _ProgressCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color backgroundColor;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// _UzbekLearnersCard — social proof card containing "12,400+ Uzbek learners"
// ─────────────────────────────────────────────────────────────────────────────
class _UzbekLearnersCard extends StatelessWidget {
  const _UzbekLearnersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 215,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x26533AB7), // rgba(83,58,183,0.15)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x4D533AB7), // rgba(83,58,183,0.3)
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Circle
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.violet,
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              size: 19,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),

          // Count Text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '12,400+',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'O\'zbek o\'quvchilari 🇺🇿',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 11.5,
                    color: Color(0x66FFFFFF),
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

// ─────────────────────────────────────────────────────────────────────────────
// _AnimatedFeatureItem — beautiful glassmorphic rows for value propositions
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedFeatureItem extends StatelessWidget {
  const _AnimatedFeatureItem({
    required this.opacity,
    required this.slide,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.iconBorder,
    required this.title,
    required this.subtitle,
  });

  final Animation<double> opacity;
  final Animation<double> slide;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color iconBorder;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([opacity, slide]),
      builder: (context, _) {
        return Opacity(
          opacity: opacity.value,
          child: Transform.translate(
            offset: Offset(slide.value, 0.0), // slide horizontally
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF), // white 3%
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0x12FFFFFF), // white 7%
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: iconBg,
                      border: Border.all(
                        color: iconBorder,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 12,
                            color: Color(0x66FFFFFF),
                          ),
                        ),
                      ],
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// _GetStartedButton — primary animated action button with angled glass banner
// ─────────────────────────────────────────────────────────────────────────────
class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.emerald,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Angled shimmer polygon (right side of button)
            Positioned(
              top: 0,
              right: 0,
              width: 100,
              height: 54,
              child: CustomPaint(
                painter: _AngledShimmerPainter(
                  color: const Color(0x12FFFFFF),
                ),
              ),
            ),

            // Button content
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Boshlash — mutlaqo bepul! انطلق',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AngledShimmerPainter extends CustomPainter {
  const _AngledShimmerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
