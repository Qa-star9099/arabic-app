import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../features/auth/controllers/auth_controller.dart';

// ─── Data model ───────────────────────────────────────────────────────────────
class _GoalOption {
  const _GoalOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.accentLight,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color accentLight;
}

const _goals = [
  _GoalOption(
    title: 'Biznes uchun  Arab Tili',
    subtitle: 'Kelishuvlar · Shartnomalar · Uchrashuvlar',
    icon: Icons.business_center_rounded,
    accentColor: AppColors.emerald,
    accentLight: AppColors.emeraldLight,
  ),
  _GoalOption(
    title: 'Sayohat uchun Arab Tili ',
    subtitle: 'Mehmonxonalar · Aeroportlar · Kundalik hayot',
    icon: Icons.flight_rounded,
    accentColor: AppColors.gold,
    accentLight: AppColors.goldLight,
  ),
  _GoalOption(
    title: 'Akademik Arab Tili ',
    subtitle: 'Universitet · Imtihonlar · Izlanishlar',
    icon: Icons.school_rounded,
    accentColor: AppColors.violet,
    accentLight: AppColors.violetLight,
  ),
];

// ─── Tagline cycling data ─────────────────────────────────────────────────────
const _taglineLabels = [
  'kasb egalari uchun 👨‍💼',
  'sayohatsevarlar uchun 🌍',
  'talabalar uchun 🎓',
];
const _taglineColors = [
  AppColors.emeraldLight,
  AppColors.goldLight,
  AppColors.violetLight,
];

// ═════════════════════════════════════════════════════════════════════════════
class GoalSelectionPage extends StatefulWidget {
  const GoalSelectionPage({super.key});

  @override
  State<GoalSelectionPage> createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<GoalSelectionPage>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  int _selectedGoal = 0;

  // ── Tagline cycling ────────────────────────────────────────────────────────
  int _taglineIndex = 0;
  bool _taglineVisible = true;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final AnimationController _heroFloatCtrl;
  late final AnimationController _orbSpinCtrl;
  late final AnimationController _ring1Ctrl;
  late final AnimationController _ring2Ctrl;
  late final AnimationController _ring3Ctrl;

  late final Animation<double> _headerFade;
  late final Animation<double> _heroFade;
  late final Animation<double> _cardsFade;
  late final Animation<double> _buttonFade;

  late final Animation<double> _heroFloat;
  late final Animation<double> _ring1Scale;
  late final Animation<double> _ring1Opacity;
  late final Animation<double> _ring2Scale;
  late final Animation<double> _ring2Opacity;
  late final Animation<double> _ring3Scale;
  late final Animation<double> _ring3Opacity;

  @override
  void initState() {
    super.initState();

    // Entrance stagger
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.1, 0.55, curve: Curves.easeOut),
      ),
    );
    _cardsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOut),
      ),
    );
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    // Hero letter float
    _heroFloatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);
    _heroFloat = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _heroFloatCtrl, curve: Curves.easeInOut),
    );

    // Orb slow spin
    _orbSpinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Pulse rings (staggered)
    _ring1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _ring1Scale = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _ring1Ctrl, curve: Curves.easeInOut),
    );
    _ring1Opacity = Tween<double>(begin: 0.6, end: 0.25).animate(
      CurvedAnimation(parent: _ring1Ctrl, curve: Curves.easeInOut),
    );

    _ring2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _ring2Scale = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _ring2Ctrl, curve: Curves.easeInOut),
    );
    _ring2Opacity = Tween<double>(begin: 0.6, end: 0.25).animate(
      CurvedAnimation(parent: _ring2Ctrl, curve: Curves.easeInOut),
    );

    _ring3Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _ring3Scale = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _ring3Ctrl, curve: Curves.easeInOut),
    );
    _ring3Opacity = Tween<double>(begin: 0.6, end: 0.25).animate(
      CurvedAnimation(parent: _ring3Ctrl, curve: Curves.easeInOut),
    );

    // Start rings with stagger
    _ring1Ctrl.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ring2Ctrl.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _ring3Ctrl.repeat(reverse: true);
    });

    _entranceCtrl.forward();

    // Tagline cycling every 2.2 s
    _startTaglineCycle();
  }

  void _startTaglineCycle() {
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() => _taglineVisible = false);
      Future.delayed(const Duration(milliseconds: 260), () {
        if (!mounted) return;
        setState(() {
          _taglineIndex = (_taglineIndex + 1) % _taglineLabels.length;
          _taglineVisible = true;
        });
        _startTaglineCycle();
      });
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _heroFloatCtrl.dispose();
    _orbSpinCtrl.dispose();
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
    _ring3Ctrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Layer 0: dot grid
          const _DotGrid(),

          // Layer 1: spinning ambient orbs
          _SpinningOrbs(spinCtrl: _orbSpinCtrl),

          // Layer 2: main content
          SafeArea(
            child: Column(
              children: [
                // Progress bar header
                FadeTransition(
                  opacity: _headerFade,
                  child: const _ProgressHeader(),
                ),

                const Spacer(flex: 1),

                // Hero section
                FadeTransition(
                  opacity: _heroFade,
                  child: _HeroSection(
                    heroFloat: _heroFloat,
                    ring1Scale: _ring1Scale,
                    ring1Opacity: _ring1Opacity,
                    ring2Scale: _ring2Scale,
                    ring2Opacity: _ring2Opacity,
                    ring3Scale: _ring3Scale,
                    ring3Opacity: _ring3Opacity,
                    taglineText: _taglineLabels[_taglineIndex],
                    taglineColor: _taglineColors[_taglineIndex],
                    taglineVisible: _taglineVisible,
                  ),
                ),

                const Spacer(flex: 1),

                // Goal cards
                FadeTransition(
                  opacity: _cardsFade,
                  child: _GoalCardsPanel(
                    selectedIndex: _selectedGoal,
                    onSelect: (i) => setState(() => _selectedGoal = i),
                  ),
                ),

                const SizedBox(height: 16),

                // CTA button
                FadeTransition(
                  opacity: _buttonFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _StartButton(
                      onPressed: () {
                        final selectedGoalTitle = _goals[_selectedGoal].title;
                        context.go(AppRoutes.levelSelection,
                            extra: selectedGoalTitle);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Page dots
                FadeTransition(
                  opacity: _buttonFade,
                  child: const _PageDots(currentPage: 0),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dot grid background ──────────────────────────────────────────────────────
class _DotGrid extends StatelessWidget {
  const _DotGrid();
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _DotGridPainter()));
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 28.0;
    const dotRadius = 1.0;
    final paint = Paint()..color = const Color(0x07FFFFFF);
    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(Offset(c * spacing, r * spacing), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Spinning ambient orbs ────────────────────────────────────────────────────
class _SpinningOrbs extends StatelessWidget {
  const _SpinningOrbs({required this.spinCtrl});
  final AnimationController spinCtrl;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -80,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: spinCtrl,
          builder: (_, __) {
            return Transform.rotate(
              angle: spinCtrl.value * 2 * math.pi,
              child: SizedBox(
                width: 340,
                height: 340,
                child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      left: 20,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emerald.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 10,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.violet.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: 40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressHeader extends ConsumerWidget {
  const _ProgressHeader();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: [
          // Back/Sign out button
          InkWell(
            onTap: () {
              // Sign out if they are authenticated so they can see the Welcome Page again
              ref.read(authControllerProvider.notifier).signOut();
              context.go(AppRoutes.welcome);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          // Filled segment
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [AppColors.emerald, AppColors.emeraldLight],
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          // Empty segments
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            '1/4',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 11,
              color: Color(0x4DFFFFFF),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.heroFloat,
    required this.ring1Scale,
    required this.ring1Opacity,
    required this.ring2Scale,
    required this.ring2Opacity,
    required this.ring3Scale,
    required this.ring3Opacity,
    required this.taglineText,
    required this.taglineColor,
    required this.taglineVisible,
  });

  final Animation<double> heroFloat;
  final Animation<double> ring1Scale, ring1Opacity;
  final Animation<double> ring2Scale, ring2Opacity;
  final Animation<double> ring3Scale, ring3Opacity;
  final String taglineText;
  final Color taglineColor;
  final bool taglineVisible;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated Arabic letter with pulse rings
        AnimatedBuilder(
          animation: Listenable.merge([
            heroFloat,
            ring1Scale,
            ring2Scale,
            ring3Scale,
          ]),
          builder: (_, __) {
            return SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ring 3 (outermost)
                  Transform.scale(
                    scale: ring3Scale.value,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.emerald
                              .withValues(alpha: ring3Opacity.value * 0.15),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  // Ring 2
                  Transform.scale(
                    scale: ring2Scale.value,
                    child: Container(
                      width: 106,
                      height: 106,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.emerald
                              .withValues(alpha: ring2Opacity.value * 0.25),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  // Ring 1
                  Transform.scale(
                    scale: ring1Scale.value,
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.emerald
                              .withValues(alpha: ring1Opacity.value * 0.4),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  // Center circle with Arabic letter
                  Transform.translate(
                    offset: Offset(0, heroFloat.value),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0D1F1A),
                        border: Border.all(
                          color: AppColors.emerald.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'ض',
                          style: TextStyle(
                            fontSize: 28,
                            color: AppColors.emeraldLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gold mic badge (top-right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Violet star badge (bottom-left)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.violet,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Title + cycling tagline
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Text(
                'Arab tili ',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedOpacity(
                opacity: taglineVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Text(
                  taglineText,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: taglineColor,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Maqsadingizni tanlang. Biz sizga to\'g\'ri yo\'nalish beramiz! ',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13,
                  color: Color(0x66FFFFFF),
                  height: 1.6,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Goal cards panel ─────────────────────────────────────────────────────────
class _GoalCardsPanel extends StatelessWidget {
  const _GoalCardsPanel({
    required this.selectedIndex,
    required this.onSelect,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0x07FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x12FFFFFF)),
        ),
        child: Column(
          children: List.generate(_goals.length, (i) {
            final isSelected = i == selectedIndex;
            final goal = _goals[i];
            final isLast = i == _goals.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
              child: _GoalCard(
                goal: goal,
                isSelected: isSelected,
                onTap: () => onSelect(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Single goal card ─────────────────────────────────────────────────────────
class _GoalCard extends StatefulWidget {
  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });
  final _GoalOption goal;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _scaleCtrl.reverse();
  void _onTapUp(_) {
    _scaleCtrl.forward();
    widget.onTap();
  }

  void _onTapCancel() => _scaleCtrl.forward();

  @override
  Widget build(BuildContext context) {
    final g = widget.goal;
    final sel = widget.isSelected;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: sel
                ? g.accentColor.withValues(alpha: 0.08)
                : Colors.transparent,
            border: Border.all(
              color: sel
                  ? g.accentColor.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon box
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: sel
                      ? g.accentColor.withValues(alpha: 0.2)
                      : const Color(0x0DFFFFFF),
                  border: Border.all(
                    color: sel
                        ? g.accentColor.withValues(alpha: 0.3)
                        : const Color(0x14FFFFFF),
                  ),
                ),
                child: Icon(
                  g.icon,
                  size: 20,
                  color: sel ? g.accentLight : const Color(0x73FFFFFF),
                ),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.title,
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: sel ? Colors.white : const Color(0xBFFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      g.subtitle,
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        color: sel
                            ? g.accentLight.withValues(alpha: 0.8)
                            : const Color(0x4DFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              // Check circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? g.accentColor : const Color(0x14FFFFFF),
                  border: sel
                      ? null
                      : Border.all(color: const Color(0x1FFFFFFF), width: 1.5),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: sel ? Colors.white : const Color(0x33FFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Start button ─────────────────────────────────────────────────────────────
class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.emerald,
              ),
            ),
          ),
          // Angled shimmer on the right
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: 120,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: CustomPaint(
                painter: _ShimmerPainter(color: const Color(0x12FFFFFF)),
              ),
            ),
          ),
          // Button tap target + label
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
                      'Sayohatni boshlash انطلق',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1218),
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded,
                        size: 22, color: Color(0xFF0B1218)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  const _ShimmerPainter({required this.color});
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
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Page dots ────────────────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  const _PageDots({required this.currentPage});
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.emerald : const Color(0x26FFFFFF),
          ),
        );
      }),
    );
  }
}
