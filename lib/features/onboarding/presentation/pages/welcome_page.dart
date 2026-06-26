import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

const _kBg = Color(0xFF080F18);
const _kCard = Color(0xFF0E1620);
const _kBorder = Color(0xFF15202C);
const _kGreen = Color(0xFF3DD68C);
const _kTextPrimary = Color(0xFFEAF2F8);
const _kTextSecondary = Color(0xFF7B8C9C);
const _kDarkGreen = Color(0xFF041A0E);

// ─────────────────────────────────────────────────────────────────────────────
// STATE & DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class WelcomeFeature {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? arabicSubtitle;

  WelcomeFeature({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.arabicSubtitle,
  });
}

final welcomeFeaturesProvider = Provider<List<WelcomeFeature>>((ref) {
  return [
    WelcomeFeature(
      icon: Icons.mic_rounded,
      color: _kGreen,
      title: "Maxrajni SI bilan tekshirish",
      subtitle: "Talaffuzingiz to'g'riligini baholaymiz!",
    ),
    WelcomeFeature(
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFF5A623),
      title: "O'zaro bog'liq O'zbek-Arab so'zlari",
      subtitle: "Umumiy so'zlar orqali 2x tez o'rganing!",
    ),
    WelcomeFeature(
      icon: Icons.chat_bubble_outline_rounded,
      color: const Color(0xFF9580FF),
      title: "Interaktiv o'rganish metodikasi",
      subtitle: "XP yig'ing va peshqadam bo'ling! ",
      arabicSubtitle: "ممتاز",
    ),
  ];
});

final selectedFeatureProvider = StateProvider<int>((ref) => 0);

// ─────────────────────────────────────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────────────────────────────────────

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // ── Ghost Watermark ────────────────────────────────────────────────
          Positioned(
            top: -40,
            right: -20,
            child: IgnorePointer(
              child: Text(
                'ع',
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 180,
                  fontWeight: FontWeight.w700,
                  color: _kGreen.withValues(alpha: 0.07),
                  height: 1.0,
                ),
              ),
            ),
          ),

          // ── Main Content ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                  // HERO ROW — two stat cards
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: _HeroRow(),
                  ),

                  // SOCIAL PROOF ROW
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: _SocialProofRow(),
                  ),

                  // DIVIDER
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 1,
                    color: _kBorder,
                  ),

                  // TITLE BLOCK
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: _TitleBlock(),
                  ),

                  // FEATURE LIST (Riverpod Integrated)
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: _FeatureList(),
                  ),

                  // PRIMARY CTA
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.home),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Boshlash — mutlaqo bepul! ',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kDarkGreen,
                              ),
                            ),
                            Text(
                              'انطلق',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: 'NotoNaskhArabic',
                                fontSize: 15,
                                color: _kDarkGreen.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // SECONDARY LINK
                  const SizedBox(height: 14),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.login),
                      behavior: HitTestBehavior.opaque,
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: _kTextSecondary,
                          ),
                          children: [
                            TextSpan(text: "Allaqachon ro'yhatdan o'tganmisiz?"),
                            TextSpan(
                              text: " Kirish",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _kGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // WORDMARK & VERSION
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0, top: 4.0),
                    child: Text(
                      'Kalima 1.0',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A4A54),
                        letterSpacing: 0.5,
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

// ─────────────────────────────────────────────────────────────────────────────
// FEATURE LIST (Interactive)
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureList extends ConsumerWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(welcomeFeaturesProvider);

    return Column(
      children: List.generate(features.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == features.length - 1 ? 0 : 10),
          child: _FeatureItem(
            index: index,
            feature: features[index],
          ),
        );
      }),
    );
  }
}

class _FeatureItem extends ConsumerWidget {
  final int index;
  final WelcomeFeature feature;

  const _FeatureItem({
    required this.index,
    required this.feature,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(selectedFeatureProvider) == index;
    final themeColor = feature.color;

    return GestureDetector(
      onTap: () {
        ref.read(selectedFeatureProvider.notifier).state = index;
      },
      child: Stack(
        children: [
          // Outer container to provide the left colored border for active item
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isActive ? themeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          
          // Inner container
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(left: isActive ? 3.0 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF141A20) : const Color(0xFF10151A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature.icon,
                    color: themeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        feature.title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (feature.arabicSubtitle != null)
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: _kTextSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: feature.subtitle,
                                style: const TextStyle(fontFamily: 'Inter'),
                              ),
                              TextSpan(
                                text: feature.arabicSubtitle,
                                style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          feature.subtitle,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: _kTextSecondary,
                          ),
                        ),
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
// HERO ROW — Two stat cards matching the design image
// ─────────────────────────────────────────────────────────────────────────────
class _HeroRow extends StatelessWidget {
  const _HeroRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left card: Pronunciation checker ──
          Expanded(
            flex: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row — icon + labels
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _kGreen.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: _kGreen.withValues(alpha: 0.25),
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: _kGreen,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Maxraj ',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _kTextPrimary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'مخرج',
                                    style: TextStyle(
                                      fontFamily: 'NotoNaskhArabic',
                                      fontSize: 15,
                                      color: _kTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'AI tekshiruvi',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: _kTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Middle row — Arabic letter + accuracy
                  const Row(
                    children: [
                      Text(
                        'ع',
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 38,
                          fontWeight: FontWeight.w600,
                          color: _kTextPrimary,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '87%',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _kGreen,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'aniq',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _kTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Bottom row — animated waveform bars (fixed height so
                  // bar height changes don't shift ع and 87% above)
                  const SizedBox(
                    height: 16,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: _AnimatedWaveform(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Right card: XP + Daily goal ──
          Expanded(
            flex: 10,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // XP value
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '240',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        TextSpan(
                          text: ' XP',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _kGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'bugun',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: _kTextSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Daily goal label + percentage
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kunlik maqsad',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          color: _kTextSecondary,
                        ),
                      ),
                      Text(
                        '80%',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _kGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Progress bar
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      return Container(
                        width: totalWidth,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _kBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: totalWidth * 0.8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _kGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED WAVEFORM — voice line bars that pulse/dance continuously
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedWaveform extends StatefulWidget {
  const _AnimatedWaveform();

  @override
  State<_AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<_AnimatedWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Base heights for each bar — these get modulated by the animation
  static const List<double> _baseHeights = [
    0.30, 0.55, 0.80, 1.0, 0.60, 0.40, 0.75, 0.35,
  ];

  // Phase offsets to stagger each bar's animation
  static const List<double> _phaseOffsets = [
    0.0, 0.4, 0.8, 1.2, 1.6, 2.0, 2.4, 2.8,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _barHeight(int index, double animValue) {
    final base = _baseHeights[index];
    final phase = _phaseOffsets[index];
    // Sine wave oscillation with per-bar phase offset
    final wave = math.sin((animValue * 2 * math.pi) + phase);
    // Modulate between 25% and 100% of the base height
    final modulator = 0.625 + 0.375 * wave;
    return (base * modulator).clamp(0.15, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(_baseHeights.length, (i) {
            final h = _barHeight(i, _ctrl.value);
            return Padding(
              padding: EdgeInsets.only(right: i < _baseHeights.length - 1 ? 2 : 0),
              child: Container(
                width: 4,
                height: 16 * h,
                decoration: BoxDecoration(
                  color: _kGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SOCIAL PROOF ROW
// ─────────────────────────────────────────────────────────────────────────────
class _SocialProofRow extends StatelessWidget {
  const _SocialProofRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.people_alt_outlined,
          size: 18,
          color: _kTextSecondary,
        ),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '12,400+',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kTextPrimary,
                ),
              ),
              TextSpan(
                text: " o'quvchilar o'rganmoqda",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: _kTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TITLE BLOCK
// ─────────────────────────────────────────────────────────────────────────────
class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'ع',
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: _kGreen,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Arab tili biz bilan osonroq!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'هيا نتعلم',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: _kTextSecondary,
          ),
        ),
      ],
    );
  }
}
