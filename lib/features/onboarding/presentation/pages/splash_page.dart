import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arabcha/app/router/app_router.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  
  late final AnimationController _mainCtrl;
  late final AnimationController _orbCtrl;
  late final AnimationController _orb2Ctrl;
  late final AnimationController _orb3Ctrl;
  late final Animation<double> _orb1Scale;
  late final Animation<double> _orb1Opacity;
  late final Animation<double> _orb2Scale;
  late final Animation<double> _orb2Opacity;
  late final Animation<double> _orb3Scale;
  late final Animation<double> _orb3Opacity;

  late final AnimationController _pulseCtrl;
  late final AnimationController _dotsCtrl;

  // 0.0 - 0.8s
  late final Animation<double> _kafFadeIn;
  late final Animation<double> _kafInitialScale;
  late final Animation<double> _inkDropFadeIn;

  // 0.8 - 1.0s
  late final Animation<double> _kafBreath;

  // 1.0 - 2.0s
  late final Animation<double> _wordTranslateX;
  late final Animation<double> _wordScaleDown;

  late final Animation<double> _wordStage1Opacity; // ك
  late final Animation<double> _wordStage2Opacity; // كل
  late final Animation<double> _wordStage3Opacity; // كلم
  late final Animation<double> _wordStage4Opacity; // كلمة

  // 1.8 - 2.0s
  late final Animation<double> _bottomElementsOpacity;
  late final Animation<double> _subLabelTranslateY;

  // Continuous
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  bool _isDownloadingModel = false;
  String _downloadStatusText = "Preparing learning materials...";

  @override
  void initState() {
    super.initState();

    
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _orbCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
    _orb2Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
    _orb3Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _orb2Ctrl.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _orb3Ctrl.repeat(reverse: true);
    });



    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _setupAnimations();

    _mainCtrl.forward();

    _initializeApp();

    // Start continuous loops at correct times

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _pulseCtrl.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) _dotsCtrl.repeat();
    });
  }

  Future<void> _initializeApp() async {
    final minimumDuration = Future.delayed(const Duration(milliseconds: 2600));

    try {
      final modelManager = DigitalInkRecognizerModelManager();
      final isDownloaded = await modelManager.isModelDownloaded('ar');
      
      if (!isDownloaded) {
        if (mounted) {
          setState(() {
            _isDownloadingModel = true;
            _downloadStatusText = "Preparing learning materials (20MB)...";
          });
        }
        await modelManager.downloadModel('ar');
        if (mounted) {
          setState(() {
            _downloadStatusText = "Ready to learn!";
            _isDownloadingModel = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to download model: $e");
    }

    await minimumDuration;

    if (mounted) {
      context.go(AppRoutes.welcome);
    }
  }

  
  void _setupAnimations() {
    _orb1Scale = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));
    _orb1Opacity = Tween<double>(begin: 0.06, end: 0.025).animate(CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));
    
    _orb2Scale = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _orb2Ctrl, curve: Curves.easeInOut));
    _orb2Opacity = Tween<double>(begin: 0.10, end: 0.04).animate(CurvedAnimation(parent: _orb2Ctrl, curve: Curves.easeInOut));
    
    _orb3Scale = Tween<double>(begin: 1.0, end: 1.25).animate(CurvedAnimation(parent: _orb3Ctrl, curve: Curves.easeInOut));
    _orb3Opacity = Tween<double>(begin: 0.08, end: 0.025).animate(CurvedAnimation(parent: _orb3Ctrl, curve: Curves.easeInOut));

    // 0.0 - 0.8s
    _kafFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic)),
    );
    _kafInitialScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic)),
    );
    _inkDropFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.25, 0.40, curve: Curves.easeOutCubic)), // Starts at 0.5s
    );

    // 0.8 - 1.0s
    _kafBreath = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10), // before 0.8s
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.02).chain(CurveTween(curve: Curves.easeOut)), weight: 5), // 0.8-0.9
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 5), // 0.9-1.0
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 80), // after 1.0s
    ]).animate(_mainCtrl);

    // 1.0 - 2.0s transformation
    _wordTranslateX = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
    );
    _wordScaleDown = Tween<double>(begin: 1.0, end: 128.0 / 180.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic)),
    );

    // Individual letters fade in and stay visible
    _wordStage1Opacity = Tween<double>(begin: 1.0, end: 1.0).animate(_mainCtrl);

    _wordStage2Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 50), // 0.0-1.0s
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15), // 1.0-1.3s
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 35), // 1.3-2.0s
    ]).animate(_mainCtrl);

    _wordStage3Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 65), // 0.0-1.3s
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12.5), // 1.3-1.55s
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 22.5), // 1.55-2.0s
    ]).animate(_mainCtrl);

    _wordStage4Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 77.5), // 0.0-1.55s
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12.5), // 1.55-1.8s
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 10), // 1.8-2.0s
    ]).animate(_mainCtrl);

    // 1.8 - 2.0s Settle
    _bottomElementsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.9, 1.0, curve: Curves.easeOutCubic)),
    );
    _subLabelTranslateY = Tween<double>(begin: 8.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.9, 1.0, curve: Curves.easeOutCubic)),
    );

    // Continuous loops

    _pulseScale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.9, end: 0.5).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  
  @override
  void dispose() {
    _orbCtrl.dispose();
    _orb2Ctrl.dispose();
    _orb3Ctrl.dispose();

    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D14),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF080F18), Color(0xFF0A131D)],
                ),
              ),
            ),
          ),
          
          const _DotGridPainterWidget(),
          _AmbientOrbs(
            orb1Scale: _orb1Scale,
            orb1Opacity: _orb1Opacity,
            orb2Scale: _orb2Scale,
            orb2Opacity: _orb2Opacity,
            orb3Scale: _orb3Scale,
            orb3Opacity: _orb3Opacity,
          ),
          
          // Center hero — the word

          Center(
            child: FractionalTranslation(
              translation: const Offset(0.0, -0.08), // ~46% of screen height
              child: AnimatedBuilder(
                animation: _mainCtrl,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_wordTranslateX.value, 0),
                    child: Transform.scale(
                      scale: (_mainCtrl.value < 0.4)
                          ? _kafInitialScale.value
                          : (_mainCtrl.value < 0.5)
                              ? _kafBreath.value
                              : _wordScaleDown.value,
                      child: Opacity(
                        opacity: _kafFadeIn.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFF3F8FC), Color(0xFF3DD68C)],
                          ).createShader(bounds),
                          child: RichText(
                            textDirection: TextDirection.rtl,
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'NotoNaskhArabic',
                                fontWeight: FontWeight.w600,
                                fontSize: 180,
                                height: 1.0,
                                letterSpacing: -1,
                                
                              ),
                              children: [
                                TextSpan(
                                  text: 'ك',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(_wordStage1Opacity.value),
                                  ),
                                ),
                                TextSpan(
                                  text: 'ل',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(_wordStage2Opacity.value),
                                  ),
                                ),
                                TextSpan(
                                  text: 'م',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(_wordStage3Opacity.value),
                                  ),
                                ),
                                TextSpan(
                                  text: 'ة',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(_wordStage4Opacity.value),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Ink-drop accent
          AnimatedBuilder(
            animation: Listenable.merge([_mainCtrl, _pulseCtrl]),
            builder: (context, child) {
              // Positioned just below the right side (where kaf is)
              return Opacity(
                opacity: _inkDropFadeIn.value,
                child: Center(
                  child: FractionalTranslation(
                    translation: const Offset(0.35, 0.05), // below kaf
                    child: Transform.scale(
                      scale: _pulseScale.value,
                      child: Opacity(
                        opacity: _pulseOpacity.value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3DD68C),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Color(0xF23DD68C), blurRadius: 16),
                              BoxShadow(color: Color(0x803DD68C), blurRadius: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Bottom Elements
          AnimatedBuilder(
            animation: _mainCtrl,
            builder: (context, child) {
              return Opacity(
                opacity: _bottomElementsOpacity.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Sub-label
                    Transform.translate(
                      offset: Offset(0, _subLabelTranslateY.value),
                      child: Center(
                        child: FractionalTranslation(
                          translation: const Offset(0.0, -5.0), // relative to bottom
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                letterSpacing: 1.5,
                                color: Color(0xFF7A9BB0), // Brightened from 3A5868
                                fontWeight: FontWeight.w600, // Increased weight
                              ),
                              children: [
                                TextSpan(text: '1 '),
                                TextSpan(
                                    text: 'SO‘Z',
                                    style: TextStyle(
                                        color: Color(0xFF48EEA0), // Brightened to primary light
                                        fontWeight: FontWeight.w700)),
                                TextSpan(text: ' · 1 '),
                                TextSpan(
                                    text: 'DUNYO',
                                    style: TextStyle(
                                        color: Color(0xFF48EEA0),
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 120),

                    // Brand mark
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 32,
                            height: 1.0, // Made line slightly thicker
                            color: const Color(0x803DD68C)), // Increased opacity
                        const SizedBox(width: 14),
                        const Text(
                          'KALIMA',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.white, // Pure white for max pop
                            letterSpacing: 4.5,
                            fontWeight: FontWeight.w900, // Max weight
                            shadows: [
                              Shadow(
                                color: Color(0x663DD68C), // Subtle brand glow
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                            width: 32,
                            height: 1.0,
                            color: const Color(0x803DD68C)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Tagline
                    const Text(
                      'HAR SO‘Z — BIR KASHFIYOT',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9.5,
                        color: Color(0xFF8BA5B8), // Brightened from 2A4050
                        letterSpacing: 3.0, // Slightly wider
                        fontWeight: FontWeight.w600, // Increased weight
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Loading indicator or download progress
                    if (_isDownloadingModel)
                      Column(
                        children: [
                          const SizedBox(
                            width: 100,
                            child: LinearProgressIndicator(
                              color: Color(0xFF3DD68C),
                              backgroundColor: Color(0x333DD68C),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _downloadStatusText,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: Color(0xFF8BA5B8),
                            ),
                          ),
                        ],
                      )
                    else
                      AnimatedBuilder(
                        animation: _dotsCtrl,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _BlinkingDot(
                                  controller: _dotsCtrl, delayOffset: 0.0),
                              const SizedBox(width: 6),
                              _BlinkingDot(
                                  controller: _dotsCtrl,
                                  delayOffset: 0.2,
                                  isPrimary: true),
                              const SizedBox(width: 6),
                              _BlinkingDot(
                                  controller: _dotsCtrl, delayOffset: 0.4),
                            ],
                          );
                        },
                      ),

                    const SizedBox(height: 30), // From bottom
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class _BlinkingDot extends StatelessWidget {
  final AnimationController controller;
  final double delayOffset;
  final bool isPrimary;

  const _BlinkingDot({
    required this.controller,
    required this.delayOffset,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1.4s period. 0.4 to 1.0 opacity blink.
    // Calculate local progress based on delay offset.
    double progress = (controller.value - delayOffset) % 1.0;
    if (progress < 0) progress += 1.0;

    // Triangle wave for blinking 0.4 -> 1.0 -> 0.4
    double opacity = 0.4;
    if (progress < 0.5) {
      opacity = 0.4 + (progress / 0.5) * 0.6;
    } else {
      opacity = 1.0 - ((progress - 0.5) / 0.5) * 0.6;
    }

    return Opacity(
      opacity: opacity,
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF3DD68C) : const Color(0xFF1E3040),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

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
        canvas.drawCircle(Offset(c * spacing, r * spacing), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
                    color: const Color(0xFF48EEA0).withValues(alpha: orb3Opacity.value),
                  ),
                ),
              ),
            ),
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
                    color: const Color(0xFF28C87A).withValues(alpha: orb2Opacity.value),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Transform.scale(
                  scale: orb1Scale.value,
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3DD68C).withValues(alpha: orb1Opacity.value),
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
