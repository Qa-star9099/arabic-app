import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:app_settings/app_settings.dart';
import 'package:arabcha/data/models/lesson_models.dart';
import 'package:arabcha/data/repositories/progress_repository.dart';
import 'package:arabcha/core/services/tts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum PronounceState {
  initial,
  recording,
  evaluating,
  resultCorrect,
  resultClose,
  resultWrong,
  permissionDenied,
}

class PronounceStep extends ConsumerStatefulWidget {
  final LessonTopic topic;
  final LessonWord word;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const PronounceStep({
    super.key,
    required this.topic,
    required this.word,
    this.onNext,
    this.onBack,
  });

  @override
  ConsumerState<PronounceStep> createState() => _PronounceStepState();
}

class _PronounceStepState extends ConsumerState<PronounceStep> {
  late stt.SpeechToText _speech;
  bool _isSpeechAvailable = false;

  PronounceState _state = PronounceState.initial;
  String _recognizedText = "";
  double _holdDuration = 0;
  DateTime? _pressStartTime;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool hasSpeech = await _speech.initialize(
      onError: (val) {
        if (mounted) {
          if (val.errorMsg == "error_permission") {
            setState(() => _state = PronounceState.permissionDenied);
          }
        }
      },
      onStatus: (val) {
        if (val == 'done' && _state == PronounceState.recording) {
          _stopListening();
        }
      },
    );
    if (mounted) {
      setState(() {
        _isSpeechAvailable = hasSpeech;
        if (!hasSpeech &&
            _speech.hasError &&
            _speech.lastError?.errorMsg == "error_permission") {
          _state = PronounceState.permissionDenied;
        }
      });
    }
  }

  void _startListening() async {
    if (!_isSpeechAvailable) {
      await _initSpeech();
      if (!_isSpeechAvailable) return;
    }

    _pressStartTime = DateTime.now();
    setState(() {
      _state = PronounceState.recording;
      _recognizedText = "";
    });

    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: stt.SpeechListenOptions(
        localeId: 'ar-SA',
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        partialResults: true,
      ),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    if (_state != PronounceState.recording &&
        _state != PronounceState.evaluating) return;

    setState(() {
      _recognizedText = result.recognizedWords;
    });

    if (result.finalResult) {
      _evaluateResult();
    }
  }

  void _stopListening() async {
    if (_state != PronounceState.recording) return;

    await _speech.stop();

    if (_pressStartTime != null) {
      _holdDuration =
          DateTime.now().difference(_pressStartTime!).inMilliseconds / 1000;
    }

    if (_holdDuration < 0.5 && _recognizedText.isEmpty) {
      setState(() => _state = PronounceState.initial);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Juda qisqa — qaytadan urining",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            backgroundColor: const Color(0xFFD64242),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      _state = PronounceState.evaluating;
    });

    // Fallback: If STT doesn't fire finalResult within 1.5s, force evaluate.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _state == PronounceState.evaluating) {
        _evaluateResult();
      }
    });
  }

  void _evaluateResult() {
    if (_state == PronounceState.resultCorrect ||
        _state == PronounceState.resultWrong ||
        _state == PronounceState.resultClose) {
      return; // Already evaluated
    }
    String spoken = _recognizedText.toLowerCase().trim();
    String expected = widget.word.transliteration.toLowerCase().trim();
    String expectedArabicStripped =
        _stripArabicDiacritics(widget.word.arabic).trim();

    int distLatin = _levenshteinDistance(spoken, expected);
    int distArabic = _levenshteinDistance(spoken, expectedArabicStripped);
    int bestDist = math.min(distLatin, distArabic);

    PronounceState nextState;

    if (spoken.isEmpty) {
      nextState = PronounceState.resultWrong;
    } else if (bestDist == 0 ||
        spoken == expected ||
        spoken == expectedArabicStripped) {
      nextState = PronounceState.resultCorrect;
    } else if (bestDist <= 2 && spoken.length >= 3) {
      nextState = PronounceState.resultClose;
    } else {
      nextState = PronounceState.resultWrong;
    }

    setState(() {
      _state = nextState;
    });
  }

  String _stripArabicDiacritics(String text) {
    // Range U+064B to U+0652 are standard Arabic diacritics
    return text.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  }

  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> v0 = List.filled(b.length + 1, 0);
    List<int> v1 = List.filled(b.length + 1, 0);

    for (int i = 0; i <= b.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < b.length; j++) {
        int cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = math.min(v1[j] + 1, math.min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j <= b.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[b.length];
  }

  void _onSkip() {
    if (widget.onNext != null) {
      widget.onNext!();
    } else {
      _showNextStepSnackbar();
    }
  }

  void _onContinue() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      ref
          .read(progressRepositoryProvider)
          .markStepCompleted(uid, widget.word.id, 5);
    }

    if (widget.onNext != null) {
      widget.onNext!();
    } else {
      _showNextStepSnackbar();
    }
  }

  void _showNextStepSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Step 6 - coming next",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF3DD68C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine background gradient color based on state
    Color gradColor = const Color(0xFF3DD68C);
    if (_state == PronounceState.resultClose) {
      gradColor = const Color(0xFFF59E0B);
    } else if (_state == PronounceState.resultWrong) {
      gradColor = const Color(0xFFD64242);
    }
    double gradOpacity = _state == PronounceState.resultClose
        ? 0.12
        : (_state == PronounceState.resultWrong ? 0.10 : 0.14);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1218),
      body: Stack(
        children: [
          // Background Gradient at 45% vertical
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, -0.1), // roughly 45% vertical
              child: AnimatedContainer(
                duration: 400.ms,
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      gradColor.withValues(alpha: gradOpacity),
                      gradColor.withValues(alpha: gradOpacity * 0.5),
                      gradColor.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.25, 0.55],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopNavigation(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStepHeader(),
                        _buildNativeCard(),

                        const SizedBox(height: 28),

                        // State Content
                        AnimatedSwitcher(
                          duration: 350.ms,
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          child: _buildStateContent(),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildBottomActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Padding(
      padding: const EdgeInsets.only(top: 22, left: 22, right: 22),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else {
                context.pop();
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(61, 214, 140, 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E2D3A), width: 0.5),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_rounded,
                    size: 17, color: Color(0xFF6B7A88)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Progress Bar
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF15202A),
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.625, // 5 of 8 = 62.5%
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3DD68C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Step Counter
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            alignment: Alignment.centerRight,
            child: Text(
              "5/8",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7A88),
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 22, right: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "5-QADAM",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF6B7A88),
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Endi ",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    color: const Color(0xFFE8EEF4),
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                ),
                TextSpan(
                  text: "o'zingiz ",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    color: const Color(0xFF3DD68C),
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                ),
                TextSpan(
                  text: "ayting",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    color: const Color(0xFFE8EEF4),
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms, curve: Curves.easeOut);
  }

  Widget _buildNativeCard() {
    // Generate styled syllables for sa-FAR formatting
    List<TextSpan> syllableSpans = [];
    if (widget.word.stressSyllable >= 0) {
      List<String> parts = widget.word.transliteration.split('-');
      if (parts.length > 1) {
        // simple parsing
        for (int i = 0; i < parts.length; i++) {
          bool isStressed = i == widget.word.stressSyllable;
          syllableSpans.add(TextSpan(
            text: parts[i] + (i < parts.length - 1 ? "-" : ""),
            style: isStressed
                ? GoogleFonts.inter(
                    color: const Color(0xFFE8EEF4),
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal)
                : GoogleFonts.inter(
                    color: const Color(0xFF8FA4B8),
                    fontStyle: FontStyle.italic),
          ));
        }
      } else {
        syllableSpans.add(TextSpan(text: widget.word.transliteration));
      }
    } else {
      syllableSpans.add(TextSpan(text: widget.word.transliteration));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.025),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E2D3A), width: 0.5),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(ttsServiceProvider).speak(widget.word.arabic);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(61, 214, 140, 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color.fromRGBO(61, 214, 140, 0.2),
                            width: 0.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.volume_up_rounded,
                            size: 18, color: Color(0xFF3DD68C)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            widget.word.arabic,
                            style: GoogleFonts.notoNaskhArabic(
                              fontSize: 30,
                              color: const Color(0xFFF4F8FC),
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 12),
                            children: syllableSpans,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "avval namunani eshiting",
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF6B7A88),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildStateContent() {
    switch (_state) {
      case PronounceState.initial:
      case PronounceState.recording:
      case PronounceState.evaluating:
        return _buildMicState(key: const ValueKey('mic'));
      case PronounceState.resultCorrect:
        return _buildResultState(
          key: const ValueKey('correct'),
          icon: Icons.check_rounded,
          iconColor: const Color(0xFF3DD68C),
          title: "Ajoyib!",
          subtitle: "Talaffuzingiz to'g'ri",
          showCheckmark: true,
        );
      case PronounceState.resultClose:
        return _buildResultState(
          key: const ValueKey('close'),
          icon: Icons.warning_rounded,
          iconColor: const Color(0xFFF59E0B),
          title: "Yaqin",
          subtitle: "Yana bir bor urinib ko'ring",
          showCheckmark: false,
        );
      case PronounceState.resultWrong:
        return _buildResultState(
          key: const ValueKey('wrong'),
          icon: Icons.close_rounded,
          iconColor: const Color(0xFFD64242),
          title: "Tushunarsiz",
          subtitle: "Sekinroq va aniqroq ayting",
          showCheckmark: false,
        );
      case PronounceState.permissionDenied:
        return _buildPermissionState(key: const ValueKey('permission'));
    }
  }

  Widget _buildMicState({required Key key}) {
    bool isRecording = _state == PronounceState.recording ||
        _state == PronounceState.evaluating;
    bool isEvaluating = _state == PronounceState.evaluating;

    return Container(
      key: key,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Waveform
              if (isRecording && !isEvaluating)
                SizedBox(
                  width: 200,
                  height: 60,
                  child: CustomPaint(
                    painter: MicWaveformPainter(),
                  ),
                ).animate().fadeIn(duration: 200.ms),

              // Mic Button
              GestureDetector(
                onLongPressStart: (_) => _startListening(),
                onLongPressEnd: (_) => _stopListening(),
                child: AnimatedContainer(
                  duration: 200.ms,
                  width: 96,
                  height: 96,
                  transform: Matrix4.diagonal3Values(
                      isRecording ? 1.06 : 1.0, isRecording ? 1.06 : 1.0, 1.0),
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isEvaluating
                          ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                          : isRecording
                              ? [
                                  const Color(0xFFE54B4B),
                                  const Color(0xFFC13838)
                                ]
                              : [
                                  const Color(0xFF3DD68C),
                                  const Color(0xFF2EB876)
                                ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isEvaluating
                            ? const Color.fromRGBO(245, 158, 11, 0.08)
                            : isRecording
                                ? const Color.fromRGBO(229, 75, 75, 0.08)
                                : const Color.fromRGBO(61, 214, 140, 0.06),
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: isEvaluating
                            ? const Color.fromRGBO(245, 158, 11, 0.04)
                            : isRecording
                                ? const Color.fromRGBO(229, 75, 75, 0.04)
                                : const Color.fromRGBO(61, 214, 140, 0.03),
                        spreadRadius: 16,
                      ),
                      BoxShadow(
                        color: isEvaluating
                            ? const Color.fromRGBO(245, 158, 11, 0.25)
                            : isRecording
                                ? const Color.fromRGBO(229, 75, 75, 0.25)
                                : const Color.fromRGBO(61, 214, 140, 0.22),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isEvaluating
                        ? const CircularProgressIndicator(
                            color: Color(0xFF0B1218))
                        : Icon(
                            isRecording
                                ? Icons.mic_none_rounded
                                : Icons.mic_rounded,
                            size: 38,
                            color: const Color(0xFF0B1218)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            isEvaluating
                ? "Kutib turing..."
                : isRecording
                    ? "Yozib olinmoqda..."
                    : "Bosib ushlab turing",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isEvaluating
                  ? const Color(0xFFF59E0B)
                  : isRecording
                      ? const Color(0xFFE54B4B)
                      : const Color(0xFFE8EEF4),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEvaluating
                ? "natija tekshirilmoqda"
                : isRecording
                    ? "gapiring"
                    : "va so'zni ayting",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF6B7A88),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState({
    required Key key,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showCheckmark,
  }) {
    return Container(
      key: key,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 2),
            ),
            child: Center(
              child: Icon(icon, size: 36, color: iconColor),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 17,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7A88),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    "eshitildi:",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF6B7A88),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _recognizedText.isEmpty
                            ? "— hech narsa —"
                            : _recognizedText,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _recognizedText.isEmpty
                              ? const Color(0xFF8FA4B8)
                              : const Color(0xFFE8EEF4),
                          fontWeight: FontWeight.w500,
                          fontStyle: _recognizedText.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                      if (showCheckmark)
                        Text(
                          " ✓",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF3DD68C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionState({required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(214, 66, 66, 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFFD64242).withValues(alpha: 0.3),
              width: 0.5),
        ),
        child: Column(
          children: [
            const Icon(Icons.mic_off_rounded,
                size: 36, color: Color(0xFFD64242)),
            const SizedBox(height: 14),
            Text(
              "Talaffuz mashqi uchun mikrofon va ovoz tanish ruxsati kerak",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFFE8EEF4),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                AppSettings.openAppSettings();
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFFD64242).withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    "Sozlamalarni ochish",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFD64242),
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

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.only(left: 22, right: 22, bottom: 24, top: 20),
      child: AnimatedSwitcher(
        duration: 300.ms,
        child: _getBottomButtons(),
      ),
    );
  }

  Widget _getBottomButtons() {
    if (_state == PronounceState.resultCorrect) {
      return InkWell(
        key: const ValueKey('correct_btn'),
        onTap: _onContinue,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3DD68C), Color(0xFF2EB876)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(61, 214, 140, 0.3),
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Davom etish",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0B1218),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded,
                  size: 17, color: Color(0xFF0B1218)),
            ],
          ),
        ),
      );
    } else if (_state == PronounceState.resultClose) {
      return Column(
        key: const ValueKey('close_btn'),
        children: [
          InkWell(
            onTap: () => setState(() => _state = PronounceState.initial),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: const Color.fromRGBO(245, 158, 11, 0.3), width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded,
                      size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  Text(
                    "Qaytadan urinish",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _onContinue,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1E2D3A), width: 0.5),
              ),
              child: Center(
                child: Text(
                  "Davom etish",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7A88),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_state == PronounceState.resultWrong) {
      return Column(
        key: const ValueKey('wrong_btn'),
        children: [
          InkWell(
            onTap: () => setState(() => _state = PronounceState.initial),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF3DD68C), Color(0xFF2EB876)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(61, 214, 140, 0.3),
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic_rounded,
                      size: 17, color: Color(0xFF0B1218)),
                  const SizedBox(width: 10),
                  Text(
                    "Qaytadan urinish",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0B1218),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _onSkip,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1E2D3A), width: 0.5),
              ),
              child: Center(
                child: Text(
                  "O'tkazib yuborish",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7A88),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Initial / Recording / Permission
      return InkWell(
        key: const ValueKey('skip_btn'),
        onTap: _onSkip,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1E2D3A), width: 0.5),
          ),
          child: Center(
            child: Text(
              "O'tkazib yuborish",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6B7A88),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
    }
  }
}

// Simple randomized waveform painter
class MicWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE54B4B)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;

    // Simulate active waveform with slightly random heights around a base pattern
    final rnd = math.Random();
    List<double> baseHeights = [4.0, 16.0, 32.0, 50.0, 50.0, 32.0, 16.0, 4.0];
    List<double> opacities = [0.3, 0.5, 0.7, 0.9, 1.0, 0.7, 0.5, 0.3];

    // Draw Left Side
    double startXLeft = size.width / 2 - 80;
    for (int i = 0; i < baseHeights.length; i++) {
      double randomJitter = (rnd.nextDouble() * 0.4 + 0.8); // 0.8x to 1.2x
      double height = baseHeights[i] * randomJitter;

      paint.color =
          const Color(0xFFE54B4B).withValues(alpha: opacities[i] * 0.5);
      canvas.drawLine(
        Offset(startXLeft + (i * 8), centerY - height / 2),
        Offset(startXLeft + (i * 8), centerY + height / 2),
        paint,
      );
    }

    // Draw Right Side
    double startXRight = size.width / 2 + 80 - (baseHeights.length * 8);
    for (int i = 0; i < baseHeights.length; i++) {
      int revIdx = baseHeights.length - 1 - i;
      double randomJitter = (rnd.nextDouble() * 0.4 + 0.8);
      double height = baseHeights[revIdx] * randomJitter;

      paint.color =
          const Color(0xFFE54B4B).withValues(alpha: opacities[revIdx] * 0.5);
      canvas.drawLine(
        Offset(startXRight + (i * 8), centerY - height / 2),
        Offset(startXRight + (i * 8), centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      true; // Re-paint continuously if animation controller was provided
}
