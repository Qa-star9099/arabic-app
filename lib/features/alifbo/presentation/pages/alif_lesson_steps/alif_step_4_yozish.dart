import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as ml;

import '../../../../../app/theme/app_colors.dart';

class AlifStep4Yozish extends StatefulWidget {
  final void Function(bool isSuccess) onResult;

  const AlifStep4Yozish({super.key, required this.onResult});

  @override
  State<AlifStep4Yozish> createState() => _AlifStep4YozishState();
}

class _AlifStep4YozishState extends State<AlifStep4Yozish> {
  final List<Offset?> _drawingPoints = [];
  final ml.Ink _ink = ml.Ink();
  final ml.DigitalInkRecognizer _digitalInkRecognizer = ml.DigitalInkRecognizer(languageCode: 'ar');

  @override
  void dispose() {
    _digitalInkRecognizer.close();
    super.dispose();
  }

  Future<void> _verifyDrawing() async {
    if (_ink.strokes.isEmpty) return;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var stroke in _ink.strokes) {
      for (var point in stroke.points) {
        if (point.x < minX) minX = point.x;
        if (point.x > maxX) maxX = point.x;
        if (point.y < minY) minY = point.y;
        if (point.y > maxY) maxY = point.y;
      }
    }

    final totalWidth = maxX - minX;
    final totalHeight = maxY - minY;

    if (totalHeight < 20) {
      HapticFeedback.heavyImpact();
      widget.onResult(false);
      return;
    }

    if (totalWidth > totalHeight * 0.6) {
      HapticFeedback.heavyImpact();
      widget.onResult(false);
      return;
    }

    ml.Stroke? primaryStroke;
    int maxPoints = 0;
    for (var stroke in _ink.strokes) {
      if (stroke.points.length > maxPoints) {
        maxPoints = stroke.points.length;
        primaryStroke = stroke;
      }
    }

    if (primaryStroke != null && primaryStroke.points.isNotEmpty) {
      final startY = primaryStroke.points.first.y;
      final endY = primaryStroke.points.last.y;
      
      if (startY > endY) {
        HapticFeedback.heavyImpact();
        widget.onResult(false);
        return;
      }
    }

    try {
      final candidates = await _digitalInkRecognizer.recognize(_ink);
      
      bool isAlif = false;
      for (int i = 0; i < math.min(3, candidates.length); i++) {
        final candidateText = candidates[i].text.trim();
        if (candidateText == 'ا' || candidateText == '١') {
          isAlif = true;
          break;
        }
      }

      if (isAlif) {
        HapticFeedback.lightImpact();
        widget.onResult(true);
      } else {
        HapticFeedback.heavyImpact();
        widget.onResult(false);
      }
    } catch (e) {
      debugPrint("Error recognizing ink: $e");
      HapticFeedback.heavyImpact();
      widget.onResult(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("4. Yozish", style: TextStyle(fontFamily: 'Geist', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5))),
              SizedBox(height: 24),
              Text(
                "Alifni chizing",
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Yuqoridan pastga bir chiziq tortib chizing",
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 15,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text(
                      'ا',
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 200,
                        color: Color(0xFF191D24),
                        height: 1.0,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DrawingCanvasWidget(
                      points: _drawingPoints,
                      ink: _ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _drawingPoints.clear();
                        _ink.strokes.clear();
                      });
                      HapticFeedback.lightImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF191D24),
                      foregroundColor: Colors.white.withOpacity(0.7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Tozalash",
                      style: TextStyle(fontFamily: 'Geist', fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_drawingPoints.isNotEmpty) {
                        _verifyDrawing();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: const Color(0xFF041A0E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Tekshirish",
                      style: TextStyle(fontFamily: 'Geist', fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191D24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 24),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191D24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image_outlined, color: Colors.white24, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Qog'ozda yozdingizmi? Tez orada qo'shamiz!",
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.emerald
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0
      ..isAntiAlias = true;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}

class DrawingCanvasWidget extends StatefulWidget {
  final List<Offset?> points;
  final ml.Ink ink;

  const DrawingCanvasWidget({
    super.key,
    required this.points,
    required this.ink,
  });

  @override
  State<DrawingCanvasWidget> createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  ml.Stroke? _currentStroke;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          widget.points.add(details.localPosition);
        });
        _currentStroke = ml.Stroke();
        _currentStroke!.points.add(ml.StrokePoint(
          x: details.localPosition.dx,
          y: details.localPosition.dy,
          t: DateTime.now().millisecondsSinceEpoch,
        ));
      },
      onPanUpdate: (details) {
        setState(() {
          widget.points.add(details.localPosition);
        });
        _currentStroke?.points.add(ml.StrokePoint(
          x: details.localPosition.dx,
          y: details.localPosition.dy,
          t: DateTime.now().millisecondsSinceEpoch,
        ));
      },
      onPanEnd: (details) {
        setState(() {
          widget.points.add(null);
        });
        if (_currentStroke != null) {
          widget.ink.strokes.add(_currentStroke!);
          _currentStroke = null;
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(
            points: widget.points,
          ),
        ),
      ),
    );
  }
}
