import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/services/pronunciation_service.dart';

enum TalaffuzState { initial, recording, analyzing, success, failure }

class AlifStep7TalaffuzSinovi extends StatefulWidget {
  final void Function(bool isSuccess, {int? score, VoidCallback? onRetry}) onResult;

  const AlifStep7TalaffuzSinovi({super.key, required this.onResult});

  @override
  State<AlifStep7TalaffuzSinovi> createState() => _AlifStep7TalaffuzSinoviState();
}

class _AlifStep7TalaffuzSinoviState extends State<AlifStep7TalaffuzSinovi> with TickerProviderStateMixin {
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  final _pronunciationService = PronunciationService();
  
  int _kalimaSelectedHarakatIndex = 0;
  TalaffuzState _kalimaTalaffuzState = TalaffuzState.initial;
  String? _recordedAudioPath;
  bool _isPlayingAudio = false;
  final Set<int> _passedHarakat = {};

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playKalimaReferenceAudio() async {
    if (_isPlayingAudio) return;
    setState(() => _isPlayingAudio = true);
    _waveController.repeat();
    
    String assetName = '';
    if (_kalimaSelectedHarakatIndex == 0) assetName = 'fatha.mp3';
    else if (_kalimaSelectedHarakatIndex == 1) assetName = 'kasra.mp3';
    else if (_kalimaSelectedHarakatIndex == 2) assetName = 'damma.mp3';

    try {
      await _audioPlayer.setAsset('assets/audio/$assetName');
      await _audioPlayer.seek(Duration.zero);
      
      // Start playing and wait for it to finish, ensuring at least some delay for the animation
      await Future.any([
        _audioPlayer.play(),
        Future.delayed(const Duration(milliseconds: 1500)),
      ]);
      
      // If audio is very short, add a slight delay for better visual feedback
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint("Error playing audio: $e");
      // Fallback delay if audio fails completely on Simulator
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    
    if (mounted) {
      setState(() {
        _isPlayingAudio = false;
        _waveController.stop();
      });
    }
  }

  Future<void> _performKalimaAnalysis() async {
    if (_recordedAudioPath == null) {
      setState(() => _kalimaTalaffuzState = TalaffuzState.initial);
      return;
    }

    try {
      final file = File(_recordedAudioPath!);
      final bytes = await file.readAsBytes();

      String referenceText = 'أَ';
      if (_kalimaSelectedHarakatIndex == 1) referenceText = 'إِ';
      if (_kalimaSelectedHarakatIndex == 2) referenceText = 'أُ';

      final result = await _pronunciationService.assess(
        audioBytes: bytes,
        referenceText: referenceText,
      );
      
      if (!mounted) return;

      setState(() {
        _kalimaTalaffuzState = TalaffuzState.initial;
      });

      bool isSuccess = false;
      int displayScore = result.pronunciationScore;

      if (result.verdict == PronunciationVerdict.correct || result.verdict == PronunciationVerdict.close) {
        if (result.accuracyScore >= 80) {
          isSuccess = true;
          displayScore = result.pronunciationScore;
        }
      }

      // Add special check for single harakahs where pronunciationScore might be 0
      if (!isSuccess) {
        if (result.lexicalText?.trim() == referenceText.trim() && result.accuracyScore >= 75) {
          isSuccess = true;
          displayScore = result.accuracyScore;
        }
      }

      if (!isSuccess) {
        displayScore = 0;
      }

      if (isSuccess) {
        HapticFeedback.lightImpact();
        _passedHarakat.add(_kalimaSelectedHarakatIndex);
        
        if (_passedHarakat.length == 3) {
          widget.onResult(true, score: displayScore);
        } else {
          int nextIndex = [0, 1, 2].firstWhere((i) => !_passedHarakat.contains(i), orElse: () => 0);
          setState(() {
            _kalimaSelectedHarakatIndex = nextIndex;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Barakalla! Endi keyingisini talaffuz qiling."),
              backgroundColor: AppColors.emerald,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Auto play the new harakah audio after a tiny delay to let the UI update and snackbar show
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _playKalimaReferenceAudio();
          });
        }
      } else {
        HapticFeedback.heavyImpact();
        widget.onResult(false, score: displayScore, onRetry: () {
          if (mounted) _playKalimaReferenceAudio();
        });
      }

    } catch (e) {
      debugPrint("Pronunciation verification failed: $e");
      if (mounted) {
        setState(() => _kalimaTalaffuzState = TalaffuzState.initial);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ovozni tekshirishda xatolik yuz berdi. Iltimos, qayta urinib ko'ring.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("7. Talaffuz sinovi", style: TextStyle(fontFamily: 'Geist', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5))),
              const SizedBox(height: 16),
              const Text(
                "Harakat tanlang, eshiting va talaffuz qiling",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AF),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(child: _buildKalimaHarakatChip(0, "Fatha", "اَ", AppColors.emerald)),
              const SizedBox(width: 10),
              Expanded(child: _buildKalimaHarakatChip(1, "Kasra", "اِ", const Color(0xFFA78BFA))),
              const SizedBox(width: 10),
              Expanded(child: _buildKalimaHarakatChip(2, "Damma", "اُ", const Color(0xFFE8B339))),
            ],
          ),
        ),
        
        const Spacer(flex: 2),
        
        _buildKalimaCenterWaveform(),
        
        const Spacer(flex: 3),
        
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "AI natijangizni tahlil qiladi",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              _buildKalimaMicInteractiveArea(),
              const SizedBox(height: 14),
              const Text(
                "Bosib turing va talaffuz qiling",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildKalimaHarakatChip(int index, String label, String letter, Color highlightColor) {
    final isSelected = _kalimaSelectedHarakatIndex == index;
    final isPassed = _passedHarakat.contains(index);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _kalimaSelectedHarakatIndex = index;
          _kalimaTalaffuzState = TalaffuzState.initial;
        });
        _playKalimaReferenceAudio();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? highlightColor.withOpacity(0.08) : const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? highlightColor : const Color(0xFF2A3142),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Text(
                  letter,
                  style: TextStyle(
                    fontFamily: 'Noto Naskh Arabic',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? highlightColor : highlightColor.withValues(alpha: 0.8),
                    height: 1,
                  ),
                ),
                if (isSelected && _isPlayingAudio)
                  Positioned(
                    right: -20,
                    top: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(3, (barIndex) {
                        return AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            final phase = barIndex * 0.5;
                            final height = 4.0 + 8.0 * math.sin((_waveController.value * 2 * math.pi) + phase).abs();
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 3,
                              height: height,
                              decoration: BoxDecoration(
                                color: highlightColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPassed) ...[
                  const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 12),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPassed ? AppColors.emerald : (isSelected ? highlightColor : const Color(0xFF9CA3AF)),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKalimaMicInteractiveArea() {
    Widget child;
    if (_kalimaTalaffuzState == TalaffuzState.initial || _kalimaTalaffuzState == TalaffuzState.recording || _kalimaTalaffuzState == TalaffuzState.success || _kalimaTalaffuzState == TalaffuzState.failure) {
      child = Listener(
        onPointerDown: (_) async {
          try {
            if (await _audioRecorder.hasPermission()) {
              if (_kalimaTalaffuzState == TalaffuzState.recording) return;
              setState(() => _kalimaTalaffuzState = TalaffuzState.recording);
              HapticFeedback.lightImpact();
              _pulseController.repeat(reverse: true);
              _waveController.repeat();
              
              final tempDir = await getTemporaryDirectory();
              _recordedAudioPath = '${tempDir.path}/talaffuz_kalima_${DateTime.now().millisecondsSinceEpoch}.wav';
              try {
                await _audioRecorder.start(
                  const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
                  path: _recordedAudioPath!,
                );
              } catch (e) {
                debugPrint("Failed to start recording: $e");
              }
            }
          } catch (e) {
            debugPrint("hasPermission error: $e");
          }
        },
        onPointerUp: (_) async {
          if (_kalimaTalaffuzState != TalaffuzState.recording) return;
          setState(() => _kalimaTalaffuzState = TalaffuzState.analyzing);
          _pulseController.stop();
          _pulseController.value = 0.0;
          _waveController.stop();
          try {
            if (await _audioRecorder.isRecording()) {
              await _audioRecorder.stop();
            }
          } catch (e) {
            debugPrint("Failed to stop recording: $e");
          }
          _performKalimaAnalysis();
        },
        onPointerCancel: (_) async {
          if (_kalimaTalaffuzState != TalaffuzState.recording) return;
          setState(() => _kalimaTalaffuzState = TalaffuzState.initial);
          _pulseController.stop();
          _pulseController.value = 0.0;
          _waveController.stop();
          try {
            if (await _audioRecorder.isRecording()) {
              await _audioRecorder.stop();
            }
          } catch (e) {
            debugPrint("Failed to cancel recording: $e");
          }
        },
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final isRec = _kalimaTalaffuzState == TalaffuzState.recording;
            final scale = isRec ? _pulseAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: isRec ? 100 : 88,
                height: isRec ? 100 : 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ADE80), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ADE80).withOpacity(0.35 * scale),
                      blurRadius: 28 * scale,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic_none_rounded,
                  color: Color(0xFF0A0E1A),
                  size: 32,
                ),
              ),
            );
          },
        ),
      );
    } else if (_kalimaTalaffuzState == TalaffuzState.analyzing) {
      child = Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A1F2E),
          border: Border.all(color: AppColors.emerald, width: 2),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.emerald,
            strokeWidth: 3,
          ),
        ),
      );
    } else {
      child = const SizedBox(width: 88, height: 88);
    }

    return SizedBox(width: 120, height: 120, child: Center(child: child));
  }

  Widget _buildKalimaCenterWaveform() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(10, (index) {
          final isRecording = _kalimaTalaffuzState == TalaffuzState.recording;
          
          return AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              double heightPercent = 0.2;
              if (index == 1) heightPercent = 0.35;
              if (index == 8) heightPercent = 0.25;
              if (index == 9) heightPercent = 0.15;
              
              if (index >= 2 && index <= 7) {
                heightPercent = 0.1;
                if (isRecording) {
                  final phase = index * 0.7;
                  heightPercent = 0.2 + 0.8 * math.sin((_waveController.value * 2 * math.pi) + phase).abs();
                }
              }

              final color = (index >= 2 && index <= 7) 
                  ? ((index % 2 == 0) ? const Color(0xFF34D399) : const Color(0xFF4ADE80)) 
                  : const Color(0xFF1A2A20);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                width: 8,
                height: 60 * heightPercent,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
