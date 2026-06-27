import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_router.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Arabic alphabet data
// ═══════════════════════════════════════════════════════════════════════════════
class _LetterNode {
  const _LetterNode({
    required this.letter,
    required this.name,
    required this.state, // 'completed', 'current', 'locked'
  });
  final String letter;
  final String name;
  final String state;
}

const _arabicLetters = [
  _LetterNode(letter: 'ا', name: 'Alif', state: 'current'),
  _LetterNode(letter: 'ب', name: 'Ba', state: 'locked'),
  _LetterNode(letter: 'ت', name: 'Ta', state: 'locked'),
  _LetterNode(letter: 'ث', name: 'Tha', state: 'locked'),
  _LetterNode(letter: 'ج', name: 'Jim', state: 'locked'),
  _LetterNode(letter: 'ح', name: 'Ha', state: 'locked'),
  _LetterNode(letter: 'خ', name: 'Kha', state: 'locked'),
  _LetterNode(letter: 'د', name: 'Dal', state: 'locked'),
  _LetterNode(letter: 'ذ', name: 'Dhal', state: 'locked'),
  _LetterNode(letter: 'ر', name: 'Ra', state: 'locked'),
  _LetterNode(letter: 'ز', name: 'Zay', state: 'locked'),
  _LetterNode(letter: 'س', name: 'Sin', state: 'locked'),
  _LetterNode(letter: 'ش', name: 'Shin', state: 'locked'),
  _LetterNode(letter: 'ص', name: 'Sad', state: 'locked'),
  _LetterNode(letter: 'ض', name: 'Dad', state: 'locked'),
  _LetterNode(letter: 'ط', name: 'Taa', state: 'locked'),
  _LetterNode(letter: 'ظ', name: 'Dhaa', state: 'locked'),
  _LetterNode(letter: 'ع', name: 'Ayn', state: 'locked'),
  _LetterNode(letter: 'غ', name: 'Ghayn', state: 'locked'),
  _LetterNode(letter: 'ف', name: 'Fa', state: 'locked'),
  _LetterNode(letter: 'ق', name: 'Qaf', state: 'locked'),
  _LetterNode(letter: 'ك', name: 'Kaf', state: 'locked'),
  _LetterNode(letter: 'ل', name: 'Lam', state: 'locked'),
  _LetterNode(letter: 'م', name: 'Mim', state: 'locked'),
  _LetterNode(letter: 'ن', name: 'Nun', state: 'locked'),
  _LetterNode(letter: 'ه', name: 'Ha2', state: 'locked'),
  _LetterNode(letter: 'و', name: 'Waw', state: 'locked'),
  _LetterNode(letter: 'ي', name: 'Ya', state: 'locked'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// Main Page
// ═══════════════════════════════════════════════════════════════════════════════
class AlifboMapPage extends StatefulWidget {
  const AlifboMapPage({super.key});

  @override
  State<AlifboMapPage> createState() => _AlifboMapPageState();
}

class _AlifboMapPageState extends State<AlifboMapPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _bubbleCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _entranceCtrl;
  late final ScrollController _scrollCtrl;
  bool _isHeaderVisible = true;

  // Node layout constants
  static const double _nodeSpacingY = 140.0;
  static const double _headerHeight = 240.0;
  static const double _bottomPadding = 100.0;
  static const double _nodeSize = 72.0;
  static const double _currentNodeSize = 88.0;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isHeaderVisible) setState(() => _isHeaderVisible = false);
      } else if (_scrollCtrl.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isHeaderVisible) setState(() => _isHeaderVisible = true);
      }
    });

    // Auto-scroll to current node after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentNode();
    });
  }

  void _scrollToCurrentNode() {
    final currentIndex =
        _arabicLetters.indexWhere((l) => l.state == 'current');
    if (currentIndex >= 0) {
      final targetY =
          _headerHeight + (currentIndex * _nodeSpacingY) - 200;
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          targetY.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _bubbleCtrl.dispose();
    _ringCtrl.dispose();
    _entranceCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // Calculate X position for each node (winding S-curve)
  double _nodeX(int index, double screenWidth) {
    final center = screenWidth / 2;
    final amplitude = screenWidth * 0.22;
    // Pattern: center, right, left, center, right, left...
    final positions = [0.0, 1.0, -1.0, 0.0, 1.0, -1.0];
    final pos = positions[index % positions.length];
    return center + (pos * amplitude);
  }

  double _nodeY(int index) {
    return _headerHeight + (index * _nodeSpacingY);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalHeight =
        _headerHeight + (_arabicLetters.length * _nodeSpacingY) + _bottomPadding;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Ambient Glow Orbs ─────────────────────────────────────
          Positioned(
            top: 100,
            right: -30,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.emerald.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Positioned(
            top: 480,
            left: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.violet.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // ─── Bubble Animations ─────────────────────────────────────
          ..._buildBubbles(),

          // ─── Scrollable Content ────────────────────────────────────
          GestureDetector(
            onTap: () {
              if (!_isHeaderVisible) setState(() => _isHeaderVisible = true);
            },
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: screenWidth,
                height: totalHeight,
                child: Stack(
                  children: [
                    // ─── Winding Path ──────────────────────────────────
                    CustomPaint(
                      size: Size(screenWidth, totalHeight),
                      painter: _WindingPathPainter(
                        nodes: _arabicLetters,
                        nodeX: (i) => _nodeX(i, screenWidth),
                        nodeY: _nodeY,
                      ),
                    ),

                    // ─── Letter Nodes ──────────────────────────────────
                    for (int i = 0; i < _arabicLetters.length; i++)
                      _buildNode(i, screenWidth),
                  ],
                ),
              ),
            ),
          ),

          // ─── Floating Header ───────────────────────────────────────
          _buildHeader(context),

          // ─── Fixed top safe area overlay ───────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top,
              color: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final completedCount =
        _arabicLetters.where((l) => l.state == 'completed').length;
    final total = _arabicLetters.length;
    final progress = completedCount / total;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      top: _isHeaderVisible ? 0 : -140,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 24,
          right: 24,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background,
              AppColors.background.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: Colors.white),
                  ),
                ),
                const Spacer(),
                // Title
                Column(
                  children: [
                    Text(
                      'Arab alifbosi',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completedCount / $total harf o\'rganildi',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Placeholder for symmetry
                const SizedBox(width: 34),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Container(
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white.withValues(alpha: 0.06),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [AppColors.emerald, AppColors.emeraldLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.emerald.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Node Builder ────────────────────────────────────────────────────────
  Widget _buildNode(int index, double screenWidth) {
    final node = _arabicLetters[index];
    final x = _nodeX(index, screenWidth);
    final y = _nodeY(index);

    switch (node.state) {
      case 'completed':
        return _buildCompletedNode(node, x, y);
      case 'current':
        return _buildCurrentNode(node, x, y);
      default:
        return _buildLockedNode(node, x, y);
    }
  }

  // ─── Completed Node ──────────────────────────────────────────────────────
  Widget _buildCompletedNode(_LetterNode node, double x, double y) {
    return Positioned(
      left: x - _nodeSize / 2,
      top: y - _nodeSize / 2,
      child: FadeTransition(
        opacity: _entranceCtrl,
        child: Column(
          children: [
            // Stars above
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded,
                    size: 14, color: const Color(0xFFFFD700).withValues(alpha: 0.7)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Icon(Icons.star_rounded,
                      size: 18, color: const Color(0xFFFFD700)),
                ),
                Icon(Icons.star_rounded,
                    size: 14, color: const Color(0xFFFFD700).withValues(alpha: 0.7)),
              ],
            ),
            const SizedBox(height: 4),
            // Node circle
            GestureDetector(
              onTap: () {
                if (node.name == 'Alif') {
                  context.push(AppRoutes.alifLesson);
                }
              },
              child: Container(
                width: _nodeSize,
                height: _nodeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.24, -0.4),
                    colors: [
                      AppColors.emeraldLight,
                      AppColors.emerald,
                      AppColors.emeraldDark,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.45),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        node.letter,
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00281e),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Current Node (Pulsing) ──────────────────────────────────────────────
  Widget _buildCurrentNode(_LetterNode node, double x, double y) {
    return Positioned(
      left: x - _currentNodeSize / 2,
      top: y - _currentNodeSize / 2 - 40, // extra space for BOSHLASH label
      child: FadeTransition(
        opacity: _entranceCtrl,
        child: GestureDetector(
          onTap: () {
            if (node.name == 'Alif') {
              context.push(AppRoutes.alifLesson);
            }
          },
          child: Column(
          children: [
            // "BOSHLASH" label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'BOSHLASH ›',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.emeraldLight,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Pulsing rings + node
            SizedBox(
              width: _currentNodeSize + 24,
              height: _currentNodeSize + 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ring 1
                  AnimatedBuilder(
                    animation: _ringCtrl,
                    builder: (_, __) {
                      final scale = 1.0 + (_ringCtrl.value * 1.2);
                      final opacity = (1.0 - _ringCtrl.value) * 0.6;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: _currentNodeSize,
                          height: _currentNodeSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4A853)
                                  .withValues(alpha: opacity),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Ring 2 (offset)
                  AnimatedBuilder(
                    animation: _ringCtrl,
                    builder: (_, __) {
                      final adjustedValue =
                          (_ringCtrl.value + 0.5) % 1.0;
                      final scale = 1.0 + (adjustedValue * 1.2);
                      final opacity =
                          (1.0 - adjustedValue) * 0.6;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: _currentNodeSize,
                          height: _currentNodeSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF0f0c08)
                                  .withValues(alpha: opacity),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Main node
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, child) {
                      final glowIntensity =
                          0.35 + (_pulseCtrl.value * 0.20);
                      return Container(
                        width: _currentNodeSize,
                        height: _currentNodeSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.44),
                            colors: const [
                              Color(0xFFF0E4C0),
                              Color(0xFFD4A853),
                              Color(0xFFA08030),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold
                                  .withValues(alpha: glowIntensity),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                node.letter,
                                style: const TextStyle(
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: 44,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3a2400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // ─── Locked Node ─────────────────────────────────────────────────────────
  Widget _buildLockedNode(_LetterNode node, double x, double y) {
    return Positioned(
      left: x - 34,
      top: y - 34,
      child: FadeTransition(
        opacity: _entranceCtrl,
        child: SizedBox(
          width: 68,
          height: 68,
          child: Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    node.letter,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ),
              // Lock icon
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 10,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bubble Particles ────────────────────────────────────────────────────
  List<Widget> _buildBubbles() {
    final bubbles = <_BubbleConfig>[
      _BubbleConfig(left: 60, top: 780, size: 6, duration: 5.0, delay: 0.0),
      _BubbleConfig(left: 200, top: 750, size: 4, duration: 6.5, delay: 1.5),
      _BubbleConfig(left: 300, top: 800, size: 8, duration: 7.0, delay: 3.0),
      _BubbleConfig(left: 140, top: 720, size: 5, duration: 5.5, delay: 2.0),
      _BubbleConfig(left: 340, top: 760, size: 3, duration: 6.0, delay: 4.0),
    ];

    return bubbles.map((b) {
      return _AnimatedBubble(
        config: b,
        bubbleCtrl: _bubbleCtrl,
      );
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Winding Path Painter
// ═══════════════════════════════════════════════════════════════════════════════
class _WindingPathPainter extends CustomPainter {
  _WindingPathPainter({
    required this.nodes,
    required this.nodeX,
    required this.nodeY,
  });

  final List<_LetterNode> nodes;
  final double Function(int) nodeX;
  final double Function(int) nodeY;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.length < 2) return;

    // Build control points from node centers
    final points = <Offset>[];
    for (int i = 0; i < nodes.length; i++) {
      points.add(Offset(nodeX(i), nodeY(i)));
    }

    // Draw the completed path (emerald)
    final completedPaint = Paint()
      ..color = AppColors.emerald.withValues(alpha: 0.6)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw the locked path (very dim)
    final lockedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Find where the completed section ends
    final currentIdx = nodes.indexWhere((n) => n.state == 'current');
    final splitIdx = currentIdx >= 0 ? currentIdx : 0;

    // Draw locked path first (behind)
    if (splitIdx < points.length - 1) {
      final lockedPath = _buildSmoothPath(points, splitIdx, points.length - 1);
      canvas.drawPath(lockedPath, lockedPaint);
    }

    // Draw completed path on top with glow
    if (splitIdx > 0) {
      final completedPath = _buildSmoothPath(points, 0, splitIdx);

      // Glow layer
      final glowPaint = Paint()
        ..color = AppColors.emerald.withValues(alpha: 0.20)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(completedPath, glowPaint);

      // Main line
      canvas.drawPath(completedPath, completedPaint);
    }
  }

  Path _buildSmoothPath(List<Offset> points, int startIdx, int endIdx) {
    final path = Path();
    path.moveTo(points[startIdx].dx, points[startIdx].dy);

    for (int i = startIdx; i < endIdx; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = (i + 2 < points.length) ? points[i + 2] : p2;

      final c1x = p1.dx + (p2.dx - p0.dx) / 6;
      final c1y = p1.dy + (p2.dy - p0.dy) / 6;
      final c2x = p2.dx - (p3.dx - p1.dx) / 6;
      final c2y = p2.dy - (p3.dy - p1.dy) / 6;

      path.cubicTo(c1x, c1y, c2x, c2y, p2.dx, p2.dy);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Animated Bubble Widget
// ═══════════════════════════════════════════════════════════════════════════════
class _BubbleConfig {
  const _BubbleConfig({
    required this.left,
    required this.top,
    required this.size,
    required this.duration,
    required this.delay,
  });
  final double left;
  final double top;
  final double size;
  final double duration;
  final double delay;
}

class _AnimatedBubble extends StatefulWidget {
  const _AnimatedBubble({
    required this.config,
    required this.bubbleCtrl,
  });
  final _BubbleConfig config;
  final AnimationController bubbleCtrl;

  @override
  State<_AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<_AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds: (widget.config.duration * 1000).toInt()),
    );

    // Stagger the start
    Future.delayed(
      Duration(milliseconds: (widget.config.delay * 1000).toInt()),
      () {
        if (mounted) _ctrl.repeat();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        final dy = -280 * t;
        final dx = 12 * math.sin(t * math.pi * 2);
        final scale = 0.6 + (0.4 * math.sin(t * math.pi));
        double opacity;
        if (t < 0.1) {
          opacity = t / 0.1 * 0.6;
        } else if (t > 0.8) {
          opacity = (1.0 - t) / 0.2 * 0.4;
        } else {
          opacity = 0.4 + 0.2 * math.sin(t * math.pi);
        }

        return Positioned(
          left: widget.config.left + dx,
          top: widget.config.top + dy,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: widget.config.size,
              height: widget.config.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.emeraldLight
                      .withValues(alpha: opacity.clamp(0.0, 1.0) * 0.4),
                  width: 1,
                ),
                color: AppColors.emeraldLight
                    .withValues(alpha: opacity.clamp(0.0, 1.0) * 0.08),
              ),
            ),
          ),
        );
      },
    );
  }
}
