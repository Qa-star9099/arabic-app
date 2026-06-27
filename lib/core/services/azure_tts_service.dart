import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:path_provider/path_provider.dart';

class AzureTTSService {
  /// Synthesizes Arabic text into speech securely via Firebase Cloud Functions.
  /// Returns the local file path of the generated .mp3 audio.
  static Future<String?> synthesizeArabicSpeech(String text) async {
    try {
      // 1. Check local cache first for instant playback
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/tts_${text.hashCode}.mp3');
      if (await file.exists()) {
        return file.path;
      }

      // 2. Not cached, call the Firebase Cloud Function
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('synthesizeSpeech');
      
      final result = await callable.call(<String, dynamic>{
        'text': text,
      });

      final String? base64Audio = result.data['audioBase64'];
      if (base64Audio == null) {
        print('Azure TTS Error: No audio data returned from Cloud Function');
        return null;
      }

      // Decode base64 to bytes
      final bytes = base64Decode(base64Audio);

      // Write the audio bytes to the existing file object
      await file.writeAsBytes(bytes);
      
      return file.path;
    } on FirebaseFunctionsException catch (e) {
      print('Firebase TTS Error: ${e.code} - ${e.message} - ${e.details}');
      return null;
    } catch (e) {
      print('Exception during Azure TTS Cloud Function call: $e');
      return null;
    }
  }
}
