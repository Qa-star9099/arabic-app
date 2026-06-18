import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';

// ─── Data model ───────────────────────────────────────────────────────────────
class _DailyGoalOption {
  const _DailyGoalOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.accentLight,
    required this.wordsPerDay,
    required this.wordsPerMonth,
    required this.grammarRules,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color accentLight;
  final int wordsPerDay;
  final int wordsPerMonth;
  final int grammarRules;
}

const _goals = [
  _DailyGoalOption(
    title: '10 daqiqa / kuniga',
    subtitle: 'Sekin, ammo barqaror o\'sish',
    icon: Icons.access_time_rounded,
    accentColor: AppColors.emerald,
    accentLight: AppColors.emeraldLight,
    wordsPerDay: 10,
    wordsPerMonth: 300,
    grammarRules: 20,
  ),
  _DailyGoalOption(
    title: '30 daqiqa / kuniga',
    subtitle: 'Sog\'lom va muntazam o\'rganish',
    icon: Icons.timelapse_rounded,
    accentColor: AppColors.gold,
    accentLight: AppColors.goldLight,
    wordsPerDay: 25,
    wordsPerMonth: 750,
    grammarRules: 60,
  ),
  _DailyGoalOption(
    title: '1+ soat / kuniga',
    subtitle: 'Tezkor natija va chuqur bilim',
    icon: Icons.timer_rounded,
    accentColor: AppColors.violet,
    accentLight: AppColors.violetLight,
    wordsPerDay: 50,
    wordsPerMonth: 1500,
    grammarRules: 120,
  ),
];

// ═════════════════════════════════════════════════════════════════════════════
class DailyGoalSelectionPage extends StatefulWidget {
  const DailyGoalSelectionPage({
    super.key,
    required this.selectedGoal,
    required this.selectedLevel,
  });
  
  final String selectedGoal;
  final String selectedLevel;

  @override
  State<DailyGoalSelectionPage> createState() => _DailyGoalSelectionPageState();
}

class _DailyGoalSelectionPageState extends State<DailyGoalSelectionPage>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  int _selectedGoalIdx = 1; // Default to 30 min

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final AnimationController _heroFloatCtrl;
  late final AnimationController _orbSpinCtrl;
  late final AnimationController _ring1Ctrl;
  late final AnimationController _ring2Ctrl;

  late final Animation<double> _headerFade;
  late final Animation<double> _heroFade;
  late final Animation<double> _cardsFade;
  late final Animation<double> _buttonFade;

  late final Animation<double> _heroFloat;
  late final Animation<double> _ring1Scale;
  late final Animation<double> _ring1Opacity;
  late final Animation<double> _ring2Scale;
  late final Animation<double> _ring2Opacity;

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

    // Start rings with stagger
    _ring1Ctrl.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _ring2Ctrl.repeat(reverse: true);
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _heroFloatCtrl.dispose();
    _orbSpinCtrl.dispose();
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
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
                  child: _ProgressHeader(onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.levelSelection, extra: widget.selectedGoal);
                    }
                  }),
                ),

                const Spacer(flex: 1),

                // Hero section with dynamic text
                FadeTransition(
                  opacity: _heroFade,
                  child: _HeroSection(
                    heroFloat: _heroFloat,
                    ring1Scale: _ring1Scale,
                    ring1Opacity: _ring1Opacity,
                    ring2Scale: _ring2Scale,
                    ring2Opacity: _ring2Opacity,
                    selectedOption: _goals[_selectedGoalIdx],
                  ),
                ),

                const Spacer(flex: 1),

                // Goal cards
                FadeTransition(
                  opacity: _cardsFade,
                  child: _GoalCardsPanel(
                    selectedIndex: _selectedGoalIdx,
                    onSelect: (i) => setState(() => _selectedGoalIdx = i),
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
                        final selectedGoalTitle = _goals[_selectedGoalIdx].title;
                        context.go(AppRoutes.pathSelection, extra: {
                          'goal': widget.selectedGoal,
                          'level': widget.selectedLevel,
                          'dailyGoal': selectedGoalTitle,
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Page dots
                FadeTransition(
                  opacity: _buttonFade,
                  child: const _PageDots(currentPage: 2),
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

// ─── Progress header (3/4) ────────────────────────────────────────────────────
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: onBack,
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
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald.withValues(alpha: 0.5),
                          blurRadius: 6,
                        )
                      ],
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
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            '3/4',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0x66FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero section (Dynamic Header) ─────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.heroFloat,
    required this.ring1Scale,
    required this.ring1Opacity,
    required this.ring2Scale,
    required this.ring2Opacity,
    required this.selectedOption,
  });

  final Animation<double> heroFloat;
  final Animation<double> ring1Scale;
  final Animation<double> ring1Opacity;
  final Animation<double> ring2Scale;
  final Animation<double> ring2Opacity;
  final _DailyGoalOption selectedOption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AnimatedBuilder(
        animation: heroFloat,
        builder: (_, child) {
          // You could use heroFloat for a subtle vertical bobbing, or just return child directly
          return Transform.translate(
            offset: Offset(0, heroFloat.value),
            child: child,
          );
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: Container(
            key: ValueKey(selectedOption.title),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220), // Dark background matching screenshot
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selectedOption.accentLight.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: selectedOption.accentColor.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_box_outline_blank_rounded, color: selectedOption.accentLight, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kuniga ${selectedOption.title.split(' / ')[0]} sarflab quyidagilarni o\'rganasiz:',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedOption.accentLight,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Data columns row
                Row(
                  children: [
                    // Column 1
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2A), // Slightly lighter inner box
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${selectedOption.wordsPerDay}',
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'ta so\'z\n(kuniga)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 11,
                                color: Colors.white54,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Column 2
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${selectedOption.wordsPerMonth}',
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.emeraldLight, // Green
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'ta so\'z\n(oyiga)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 11,
                                color: Colors.white54,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Column 3
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2A),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${selectedOption.grammarRules}',
                              style: const TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold, // Gold
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'grammatika\nqoidalari',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 11,
                                color: Colors.white54,
                                height: 1.2,
                              ),
                            ),
                          ],
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
    );
  }
}

// ─── Goal Cards Panel ────────────────────────────────────────────────────────
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
      child: Column(
        children: List.generate(_goals.length, (i) {
          final isSelected = i == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _GoalCard(
              goal: _goals[i],
              sel: isSelected,
              onTap: () => onSelect(i),
            ),
          );
        }),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.sel,
    required this.onTap,
  });

  final _DailyGoalOption goal;
  final bool sel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF1E293B) : const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? goal.accentColor : const Color(0x14FFFFFF),
            width: sel ? 2 : 1,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: goal.accentColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: -5,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: sel
                    ? goal.accentColor.withValues(alpha: 0.2)
                    : const Color(0x0DFFFFFF),
                border: Border.all(
                  color: sel
                      ? goal.accentColor.withValues(alpha: 0.3)
                      : const Color(0x14FFFFFF),
                ),
              ),
              child: Icon(
                goal.icon,
                size: 20,
                color: sel ? goal.accentLight : const Color(0x73FFFFFF),
              ),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: sel ? Colors.white : const Color(0xBFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    goal.subtitle,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      color: sel
                          ? goal.accentLight.withValues(alpha: 0.8)
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
                color: sel ? goal.accentColor : const Color(0x14FFFFFF),
                border: sel
                    ? null
                    : Border.all(color: const Color(0x1FFFFFFF), width: 1.5),
              ),
              child: sel
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CTA button ───────────────────────────────────────────────────────────────
class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.emerald,
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Davom etish استمر',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page dots ────────────────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  const _PageDots({required this.currentPage});
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final active = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.emerald : const Color(0x26FFFFFF),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
