import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/services/azure_tts_service.dart';
import '../../../../../core/services/pronunciation_service.dart';

enum TalaffuzState { initial, recording, analyzing, success, failure }

class AlifStep3Talaffuz extends StatefulWidget {
  final void Function(bool isSuccess, {int? score}) onResult;

  const AlifStep3Talaffuz({super.key, required this.onResult});

  @override
  State<AlifStep3Talaffuz> createState() => _AlifStep3TalaffuzState();
}

class _AlifStep3TalaffuzState extends State<AlifStep3Talaffuz> with TickerProviderStateMixin {
  final _audioPlayer = AudioPlayer();
  final _audioRecorder = AudioRecorder();
  final _pronunciationService = PronunciationService();
  
  bool _isPlayingAudio = false;
  bool _isLoadingAudio = false;
  String? _alifAudioPath;
  String? _recordedAudioPath;

  TalaffuzState _talaffuzState = TalaffuzState.initial;

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
    _preloadAudio();
  }

  Future<void> _preloadAudio() async {
    try {
      _alifAudioPath = await AzureTTSService.synthesizeArabicSpeech("أَلِف");
    } catch (e) {
      debugPrint("Audio preload error: $e");
    }
  }

  Future<void> _playAlifAudio() async {
    if (_isPlayingAudio || _isLoadingAudio) return;
    
    setState(() => _isLoadingAudio = true);

    try {
      if (_alifAudioPath == null) {
        _alifAudioPath = await AzureTTSService.synthesizeArabicSpeech("أَلِف");
      }

      if (_alifAudioPath != null && mounted) {
        await _audioPlayer.setFilePath(_alifAudioPath!);
        setState(() {
          _isLoadingAudio = false;
          _isPlayingAudio = true;
          _waveController.repeat();
        });
        
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed && mounted) {
            setState(() {
              _isPlayingAudio = false;
              _waveController.stop();
            });
          }
        });
        
        await _audioPlayer.play();
      } else if (mounted) {
        setState(() => _isLoadingAudio = false);
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
          _isPlayingAudio = false;
          _waveController.stop();
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _performAnalysis() async {
    if (_recordedAudioPath == null) {
      setState(() => _talaffuzState = TalaffuzState.initial);
      return;
    }

    try {
      final file = File(_recordedAudioPath!);
      final bytes = await file.readAsBytes();

      final result = await _pronunciationService.assess(
        audioBytes: bytes,
        referenceText: 'ألف', // The word 'Alif' in Arabic
      );

      if (!mounted) return;

      setState(() {
        _talaffuzState = TalaffuzState.initial;
      });

      bool isSuccess = false;
      int displayScore = result.pronunciationScore;

      if (result.verdict == PronunciationVerdict.correct || result.verdict == PronunciationVerdict.close) {
        if (result.accuracyScore >= 80) {
          isSuccess = true;
          displayScore = result.pronunciationScore;
        }
      }

      if (!isSuccess) {
        displayScore = 0;
      }

      if (isSuccess) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.heavyImpact();
      }

      widget.onResult(isSuccess, score: displayScore);

    } catch (e) {
      debugPrint("Pronunciation verification failed: $e");
      if (mounted) {
        setState(() => _talaffuzState = TalaffuzState.initial);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ovozni tekshirishda xatolik yuz berdi. Iltimos, qayta urinib ko'ring.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text("3. Talaffuz", style: TextStyle(fontFamily: 'Geist', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5))),
                const SizedBox(height: 24),
                const Text(
                  "Endi o'zingiz ayting",
                  style: TextStyle(fontFamily: 'Geist', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 32),
                _buildAudioWave(),
                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.emerald.withValues(alpha: 0.15)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/pronunciation_alif.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.face_retouching_natural_rounded, size: 80, color: AppColors.emerald.withValues(alpha: 0.3)),
                                const SizedBox(height: 20),
                                Text(
                                  "Talaffuz sxemasi",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontFamily: 'Geist', color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTalaffuzInteractiveArea(),
                      const SizedBox(height: 14),
                      Text(
                        "Mikrofon tugmasini bosib turing va aytib bering",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioWave() {
    return Row(
      children: [
        GestureDetector(
          onTap: _playAlifAudio,
          child: Container(
            width: 48, height: 48,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF191D24)),
            child: _isLoadingAudio 
                ? const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: CircularProgressIndicator(color: AppColors.emerald, strokeWidth: 2),
                  )
                : Icon(_isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.emerald),
          ),
        ),
        const SizedBox(width: 12),
        ...List.generate(7, (index) {
           final heights = [6.0, 10.0, 16.0, 22.0, 16.0, 10.0, 6.0];
           return AnimatedBuilder(
             animation: _waveController,
             builder: (context, child) {
               double multiplier = 1.0;
               if (_isPlayingAudio) {
                 final phase = index * 0.5;
                 multiplier = 1.0 + 0.6 * math.sin((_waveController.value * 2 * math.pi) + phase).abs();
               }
               return Container(
                 margin: const EdgeInsets.symmetric(horizontal: 3),
                 width: 20, 
                 height: heights[index] * multiplier,
                 decoration: BoxDecoration(
                   color: _isPlayingAudio ? AppColors.emerald.withValues(alpha: 0.8) : const Color(0xFF2A303C),
                   borderRadius: BorderRadius.circular(4),
                 ),
               );
             },
           );
        }),
        const Spacer(),
        Text("0:02", style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      ],
    );
  }

  Widget _buildTalaffuzInteractiveArea() {
    Widget child;
    switch (_talaffuzState) {
      case TalaffuzState.initial:
      case TalaffuzState.recording:
        child = Listener(
          key: const ValueKey('mic'),
          onPointerDown: (_) async {
            try {
              if (await _audioRecorder.hasPermission()) {
                if (_talaffuzState == TalaffuzState.recording) return;
                setState(() => _talaffuzState = TalaffuzState.recording);
                HapticFeedback.lightImpact();
                _pulseController.repeat(reverse: true);
                
                final tempDir = await getTemporaryDirectory();
                _recordedAudioPath = '${tempDir.path}/talaffuz_alif_${DateTime.now().millisecondsSinceEpoch}.wav';
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
            if (_talaffuzState != TalaffuzState.recording) return;
            setState(() => _talaffuzState = TalaffuzState.analyzing);
            _pulseController.stop();
            _pulseController.value = 0.0;
            try {
              if (await _audioRecorder.isRecording()) {
                await _audioRecorder.stop();
              }
            } catch (e) {
              debugPrint("Failed to stop recording: $e");
            }
            _performAnalysis();
          },
          onPointerCancel: (_) async {
            if (_talaffuzState != TalaffuzState.recording) return;
            setState(() => _talaffuzState = TalaffuzState.initial);
            _pulseController.stop();
            _pulseController.value = 0.0;
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
              final isRec = _talaffuzState == TalaffuzState.recording;
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
        break;
      case TalaffuzState.analyzing:
        child = const SizedBox(
          key: ValueKey('analyzing'),
          width: 140,
          height: 140,
          child: Center(
            child: SizedBox(
              width: 56, height: 56,
              child: CircularProgressIndicator(color: AppColors.emerald, strokeWidth: 4),
            )
          ),
        );
        break;
      case TalaffuzState.success:
      case TalaffuzState.failure:
        child = const SizedBox.shrink();
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      child: child,
    );
  }
}
