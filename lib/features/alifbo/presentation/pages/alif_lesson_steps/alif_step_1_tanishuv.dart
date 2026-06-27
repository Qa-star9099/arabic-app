import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/services/azure_tts_service.dart';

class AlifStep1Tanishuv extends StatefulWidget {
  final void Function({required bool isReady}) onStepStateChanged;

  const AlifStep1Tanishuv({super.key, required this.onStepStateChanged});

  @override
  State<AlifStep1Tanishuv> createState() => _AlifStep1TanishuvState();
}

class _AlifStep1TanishuvState extends State<AlifStep1Tanishuv> {
  final _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;
  bool _isLoadingAudio = false;
  String? _alifAudioPath;

  @override
  void initState() {
    super.initState();
    _preloadAudio();
    // Tanishuv step requires no interactive validation, so it's immediately ready to advance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStepStateChanged(isReady: true);
    });
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
        });
        
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed && mounted) {
            setState(() {
              _isPlayingAudio = false;
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
        });
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text("1. Tanishuv", style: TextStyle(fontFamily: 'Geist', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 24),
          _buildGlowingLetter(),
          const SizedBox(height: 28),
          _buildListenButton(),
          const SizedBox(height: 28),
          _buildInfoCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGlowingLetter() {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8FFF2), // very pale mint-white at top
                Color(0xFF6EE8A8), // mint at bottom
              ],
              stops: [0.0, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: const Text(
            'ا',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 180,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListenButton() {
    return GestureDetector(
      onTap: _playAlifAudio,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.emerald.withValues(alpha: (_isPlayingAudio || _isLoadingAudio) ? 0.1 : 0.25),
            width: 1,
          ),
          boxShadow: [
            if (!_isPlayingAudio && !_isLoadingAudio)
              BoxShadow(
                color: AppColors.emerald.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoadingAudio)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.emerald),
                ),
              )
            else
              Icon(
                _isPlayingAudio ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                size: 22,
                color: AppColors.emerald,
              ),
            const SizedBox(width: 8),
            Text(
              _isLoadingAudio ? 'Yuklanmoqda...' : 'Eshitish',
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.emerald,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Alif',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'أَلِف',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 22,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Arab tilida eng ko\'p ishlatiladigan va alifboni boshlab beruvchi harf. Ilmiy qoidaga ko\'ra, sof Alifni talaffuz qilishda til ham, lablar ham qatnashmaydi — u faqat bo\'g\'izdan chiqadigan erkin havo orqali hosil bo\'ladi. Alif yozuvdagi yagona mutlaqo tik harf bo\'lib, o\'zidan keyingi harflarga hech qachon qo\'shilmaydi.',
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.65),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
