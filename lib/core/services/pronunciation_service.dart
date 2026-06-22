import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Verdikt — talaffuz baholash natijasi turi.
enum PronunciationVerdict {
  /// 80+ ball — a'lo talaffuz.
  correct,

  /// 50–79 ball — yaqin, lekin aniq emas.
  close,

  /// 0–49 ball — noto'g'ri yoki tushunarsiz.
  wrong,

  /// Server xatosi yoki boshqa nosozlik.
  error,

  /// Minutiga 10 tadan ortiq so'rov yuborildi.
  rateLimited,
}

/// Talaffuz baholash natijasi.
class PronunciationResult {
  const PronunciationResult({
    required this.pronunciationScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.recognizedText,
    required this.verdict,
    this.errorMessage,
  });

  /// 0–100 umumiy talaffuz balli.
  final int pronunciationScore;

  /// 0–100 aniqlik balli.
  final int accuracyScore;

  /// 0–100 ravonlik balli.
  final int fluencyScore;

  /// Azure tomonidan aniqlangan matn.
  final String recognizedText;

  /// Natija verdikti (correct / close / wrong / error / rateLimited).
  final PronunciationVerdict verdict;

  /// Ixtiyoriy xato xabari (foydalanuvchiga ko'rsatish uchun).
  final String? errorMessage;

  /// Xato holati uchun factory.
  factory PronunciationResult.error({String? message}) {
    return PronunciationResult(
      pronunciationScore: 0,
      accuracyScore: 0,
      fluencyScore: 0,
      recognizedText: '',
      verdict: PronunciationVerdict.error,
      errorMessage: message ?? 'Baholashda xatolik yuz berdi.',
    );
  }

  /// Balldan verdiktni aniqlash.
  static PronunciationVerdict _verdictFromScore(int score) {
    if (score >= 80) return PronunciationVerdict.correct;
    if (score >= 50) return PronunciationVerdict.close;
    return PronunciationVerdict.wrong;
  }
}

/// Azure Pronunciation Assessment xizmati — Cloud Functions orqali.
class PronunciationService {
  PronunciationService();

  final _functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  /// Audio ma'lumotlarini Azure'ga yuboradi va talaffuz ballini qaytaradi.
  ///
  /// [audioBytes] — WAV formatidagi ovoz yozuvi (PCM 16kHz).
  /// [referenceText] — kutilgan arab matni (masalan, "سَفَر").
  /// [locale] — til kodi, default 'ar-SA'.
  Future<PronunciationResult> assess({
    required Uint8List audioBytes,
    required String referenceText,
    String locale = 'ar-SA',
  }) async {
    try {
      final audioBase64 = base64Encode(audioBytes);

      final callable = _functions.httpsCallable(
        'assessPronunciation',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
      );

      final result = await callable.call<Map<String, dynamic>>({
        'audioBase64': audioBase64,
        'referenceText': referenceText,
        'locale': locale,
      });

      final data = result.data;
      final pronScore = (data['pronunciationScore'] as num?)?.toInt() ?? 0;
      final accScore = (data['accuracyScore'] as num?)?.toInt() ?? 0;
      final fluScore = (data['fluencyScore'] as num?)?.toInt() ?? 0;
      final recognized = data['recognizedText'] as String? ?? '';

      return PronunciationResult(
        pronunciationScore: pronScore,
        accuracyScore: accScore,
        fluencyScore: fluScore,
        recognizedText: recognized,
        verdict: PronunciationResult._verdictFromScore(pronScore),
      );
    } on FirebaseFunctionsException catch (e) {
      // ── Layer 2 — rate limit xatosini aniq ushlash ──
      if (e.code == 'resource-exhausted') {
        return PronunciationResult(
          pronunciationScore: 0,
          accuracyScore: 0,
          fluencyScore: 0,
          recognizedText: '',
          verdict: PronunciationVerdict.rateLimited,
          errorMessage: 'Biroz kuting — minutiga 10 ta baholash mumkin.',
        );
      }

      if (kDebugMode) {
        print('FirebaseFunctionsException: ${e.code} — ${e.message}');
      }
      return PronunciationResult.error(
        message: e.message ?? 'Server xatosi.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('PronunciationService unexpected error: $e');
      }
      return PronunciationResult.error();
    }
  }
}

/// Riverpod provider.
final pronunciationServiceProvider = Provider<PronunciationService>((ref) {
  return PronunciationService();
});
