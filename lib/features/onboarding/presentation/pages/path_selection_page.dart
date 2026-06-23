import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../features/auth/controllers/auth_controller.dart';

// ═════════════════════════════════════════════════════════════════════════════
class PathSelectionPage extends StatefulWidget {
  const PathSelectionPage({
    super.key,
    required this.selectedGoal,
    required this.selectedLevel,
    required this.selectedDailyGoal,
  });

  final String selectedGoal;
  final String selectedLevel;
  final String selectedDailyGoal;

  @override
  State<PathSelectionPage> createState() => _PathSelectionPageState();
}

class _PathSelectionPageState extends State<PathSelectionPage>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  int _selectedPath = 0; // 0 = Level Test, 1 = Fresh Start

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final AnimationController _orbSpinCtrl;
  late final Animation<double> _headerFade;
  late final Animation<double> _cardsFade;
  late final Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    // Entrance stagger
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _entranceCtrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _cardsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _entranceCtrl,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _entranceCtrl,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    // Orb slow spin
    _orbSpinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _orbSpinCtrl.dispose();
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
                // Progress bar header (Almost done - 3/4)
                FadeTransition(
                  opacity: _headerFade,
                  child: _ProgressHeader(onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.dailyGoalSelection, extra: {
                        'goal': widget.selectedGoal,
                        'level': widget.selectedLevel,
                      });
                    }
                  }),
                ),

                const Spacer(flex: 1),

                // Cards
                FadeTransition(
                  opacity: _cardsFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _PathCard(
                          isSelected: _selectedPath == 0,
                          title: 'Darajani aniqlash',
                          subtitle:
                              'Siz bilgan mavzularni o\'tkazib yuboring.\nAynan o\'z darajangizdan boshlang.',
                          icon: Icons.checklist_rtl_rounded,
                          accentColor: AppColors.emerald,
                          pills: const ['A1 -> B2 aniqlash', '10 ta savol'],
                          tag: '~3 daq',
                          onTap: () => setState(() => _selectedPath = 0),
                        ),
                        const SizedBox(height: 16),
                        _PathCard(
                          isSelected: _selectedPath == 1,
                          title: 'Noldan boshlash',
                          subtitle:
                              'Arab tilini eng boshidan,\nalifbodan boshlab o\'rganing.',
                          icon: Icons.auto_stories_rounded,
                          accentColor: AppColors.violet,
                          pills: const ['Alifbo', 'Boshlang\'ich sozlar'],
                          tag: null,
                          onTap: () => setState(() => _selectedPath = 1),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // CTA button
                FadeTransition(
                  opacity: _buttonFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _StartButton(
                      selectedPath: _selectedPath,
                      widget: widget,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Page dots (3/4)
                FadeTransition(
                  opacity: _buttonFade,
                  child: const _PageDots(),
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

// ─── Path Card ────────────────────────────────────────────────────────────────
class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.isSelected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.pills,
    required this.tag,
    required this.onTap,
  });

  final bool isSelected;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<String> pills;
  final String? tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Optional Tag
                if (tag != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag!,
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Pills
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pills.map((p) => _buildPill(p)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Geist',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

// ─── Button ───────────────────────────────────────────────────────────────────
class _StartButton extends ConsumerWidget {
  const _StartButton({required this.selectedPath, required this.widget});
  final int selectedPath;
  final PathSelectionPage widget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        if (selectedPath == 0) {
          // Route to Placement Test
          context.go(AppRoutes.placementTest, extra: {
            'goal': widget.selectedGoal,
            'level': widget.selectedLevel,
            'dailyGoal': widget.selectedDailyGoal,
          });
        } else {
          // Route to Home directly, save data
          try {
            if (ref.read(authControllerProvider).value != null) {
              await ref.read(authControllerProvider.notifier).updateUserData(
                    learningGoal: widget.selectedGoal,
                    level: widget.selectedLevel,
                    dailyGoal: widget.selectedDailyGoal,
                  );
              if (context.mounted) context.go(AppRoutes.home);
            } else {
              ref.read(pendingOnboardingDataProvider.notifier).state = {
                'learningGoal': widget.selectedGoal,
                'level': widget.selectedLevel,
                'dailyGoal': widget.selectedDailyGoal,
              };
              if (context.mounted) context.go(AppRoutes.home);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Xatolik: $e')),
              );
            }
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            selectedPath == 0 ? 'Darajani aniqlash' : 'Noldan boshlash',
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, size: 20),
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

// ─── Progress bar header (3/4) ────────────────────────────────────────────────
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
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
          // Filled segments
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
          const SizedBox(width: 6),
          // Empty segment
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
          Text(
            'Qariyb tayyor',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page dots ────────────────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  const _PageDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final isCurrent = i == 3;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.emerald
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
