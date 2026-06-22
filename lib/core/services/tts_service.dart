import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

class TtsService {
  TtsService() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isAvailable = true;

  Future<void> _initTts() async {
    try {
      // Allow audio to play even if physical silent switch is on (iOS)
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );

      // Find any available Arabic voice (ar-SA, ar-AE, etc.)
      final List<dynamic>? languages = await _flutterTts.getLanguages;
      String? targetLang;

      if (languages != null) {
        for (var lang in languages) {
          if (lang.toString().toLowerCase().startsWith('ar')) {
            targetLang = lang.toString();
            break;
          }
        }
      }

      if (targetLang != null) {
        await _flutterTts.setLanguage(targetLang);
        await _flutterTts.setSpeechRate(0.45); // Slow down for learners
      } else {
        _isAvailable = false;
        if (kDebugMode) {
          print("TTS: No Arabic language found. Please download an Arabic voice in iOS Settings > Accessibility > Spoken Content > Voices.");
        }
      }
    } catch (e) {
      _isAvailable = false;
      if (kDebugMode) {
        print("TTS Init Error: $e");
      }
    }
  }

  Future<void> speak(String arabicText, {bool slow = false}) async {
    if (!_isAvailable) {
      if (kDebugMode) {
        print("TTS is not available. Skipping audio for: $arabicText");
      }
      return;
    }

    if (slow) {
      await _flutterTts.setSpeechRate(0.25);
    } else {
      await _flutterTts.setSpeechRate(0.45);
    }

    try {
      await _flutterTts.speak(arabicText);
    } catch (e) {
      if (kDebugMode) {
        print("TTS Speak Error: $e");
      }
      // Gracefully handle error without crashing
    }
  }
}
