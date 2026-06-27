import re

file_path = 'lib/features/alifbo/presentation/pages/alif_lesson_steps/alif_step_7_talaffuz_sinovi.dart'

with open(file_path, 'r') as file:
    content = file.read()

# 1. Add import
import_stmt = "import 'package:just_audio/just_audio.dart';"
if import_stmt not in content:
    content = content.replace("import 'package:flutter/material.dart';", f"import 'package:flutter/material.dart';\n{import_stmt}")

# 2. Add AudioPlayer field
content = content.replace("final _audioRecorder = AudioRecorder();", "final _audioRecorder = AudioRecorder();\n  final _audioPlayer = AudioPlayer();")

# 3. Dispose AudioPlayer
content = content.replace("_audioRecorder.dispose();", "_audioRecorder.dispose();\n    _audioPlayer.dispose();")

# 4. Update _playKalimaReferenceAudio
old_play = """  Future<void> _playKalimaReferenceAudio() async {
    if (_isPlayingAudio) return;
    setState(() => _isPlayingAudio = true);
    _waveController.repeat();
    
    // Simulate playing audio for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isPlayingAudio = false;
        _waveController.stop();
      });
    }
  }"""

new_play = """  Future<void> _playKalimaReferenceAudio() async {
    if (_isPlayingAudio) return;
    setState(() => _isPlayingAudio = true);
    _waveController.repeat();
    
    String assetName = '';
    if (_kalimaSelectedHarakatIndex == 0) assetName = 'fatha.mp3';
    else if (_kalimaSelectedHarakatIndex == 1) assetName = 'kasra.mp3';
    else if (_kalimaSelectedHarakatIndex == 2) assetName = 'damma.mp3';

    try {
      await _audioPlayer.setAsset('assets/audio/$assetName');
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
    
    if (mounted) {
      setState(() {
        _isPlayingAudio = false;
        _waveController.stop();
      });
    }
  }"""

content = content.replace(old_play, new_play)

with open(file_path, 'w') as file:
    file.write(content)
