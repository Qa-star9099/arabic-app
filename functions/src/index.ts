// ============================================================
// assessPronunciation — Azure Speech Pronunciation Assessment
// Serverless Cloud Function (Firebase Functions v1)
//
// 4 SECURITY LAYERS:
//   1. Firebase Auth — reject unauthenticated requests
//   2. Rate Limiting — max 10 per minute per user (Firestore tx)
//   3. Input Validation — type, length, locale whitelist
//   4. Azure Budget — manual $5/month alert (see comment below)
//
// IMPORTANT: Set Azure budget alert at $5/month in Azure Portal
// Azure Portal → Cost Management + Billing → Budgets → Create
// This is the last line of defense against unexpected charges
// ============================================================

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import fetch from "node-fetch";

admin.initializeApp();
const db = admin.firestore();

// ── Constants ──────────────────────────────────────────────────
const RATE_LIMIT_MAX = 10;
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // 1 minute

const ALLOWED_LOCALES = ["ar-SA", "ar-AE", "ar-EG", "ar"];
const MAX_AUDIO_BASE64_LENGTH = 2_000_000; // ~1.5MB audio
const MAX_REFERENCE_TEXT_LENGTH = 50;

// Arabic Unicode range + basic Latin alphanumeric + spaces
const REFERENCE_TEXT_REGEX = /^[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF\u0020-\u007Ea-zA-Z0-9 ]+$/;

// ── Cloud Function ─────────────────────────────────────────────
export const assessPronunciation = functions
  .region("europe-west1")
  .https.onCall(async (data, context) => {

    // ── Layer 1: Firebase Auth ─────────────────────
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Autentifikatsiya talab qilinadi."
      );
    }
    const uid = context.auth.uid;

    // ── Layer 2: Rate Limiting (Firestore Transaction) ──
    const rateLimitRef = db.doc(`users/${uid}/limits/pronunciation`);
    await db.runTransaction(async (tx) => {
      const doc = await tx.get(rateLimitRef);
      const now = Date.now();

      if (!doc.exists) {
        tx.set(rateLimitRef, { count: 1, windowStart: now });
        return;
      }

      const { count, windowStart } = doc.data() as {
        count: number;
        windowStart: number;
      };

      // Window expired → reset
      if (now - windowStart > RATE_LIMIT_WINDOW_MS) {
        tx.update(rateLimitRef, { count: 1, windowStart: now });
        return;
      }

      // Within window and at limit → reject
      if (count >= RATE_LIMIT_MAX) {
        throw new functions.https.HttpsError(
          "resource-exhausted",
          "Minutiga 10 tadan ko'p baholash mumkin emas. Biroz kuting."
        );
      }

      // Within window, under limit → increment
      tx.update(rateLimitRef, { count: count + 1 });
    });

    // ── Layer 3: Input Validation ──────────────────
    const { audioBase64, referenceText, locale } = data;

    // audioBase64
    if (typeof audioBase64 !== "string" || audioBase64.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "audioBase64 majburiy."
      );
    }
    if (audioBase64.length > MAX_AUDIO_BASE64_LENGTH) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Audio fayl juda katta (max 1.5MB)."
      );
    }

    // referenceText
    if (typeof referenceText !== "string" || referenceText.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "referenceText majburiy."
      );
    }
    if (referenceText.length > MAX_REFERENCE_TEXT_LENGTH) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "referenceText juda uzun (max 50 harf)."
      );
    }
    if (!REFERENCE_TEXT_REGEX.test(referenceText)) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "referenceText noto'g'ri belgilar o'z ichiga olgan."
      );
    }

    // locale — fallback to ar-SA if invalid
    const safeLocale = ALLOWED_LOCALES.includes(locale) ? locale : "ar-SA";

    // ── Azure API Call ─────────────────────────────
    const apiKey = functions.config().azure?.speech_key;
    const region = functions.config().azure?.speech_region ?? "eastus";

    if (!apiKey) {
      functions.logger.error("Azure speech_key not configured");
      throw new functions.https.HttpsError(
        "internal",
        "Server konfiguratsiya xatosi."
      );
    }

    const audioBuffer = Buffer.from(audioBase64, "base64");

    const pronunciationConfig = Buffer.from(
      JSON.stringify({
        ReferenceText: referenceText,
        GradingSystem: "HundredMark",
        Granularity: "Word",
        EnableMiscue: false,
      })
    ).toString("base64");

    const endpoint =
      `https://${region}.stt.speech.microsoft.com` +
      `/speech/recognition/conversation/cognitiveservices/v1` +
      `?language=${safeLocale}&format=detailed`;

    try {
      const response = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Ocp-Apim-Subscription-Key": apiKey,
          "Content-Type": "audio/wav; codecs=audio/pcm; samplerate=16000",
          "Pronunciation-Assessment": pronunciationConfig,
          "Accept": "application/json",
        },
        body: audioBuffer,
      });

      if (!response.ok) {
        const errorBody = await response.text();
        functions.logger.error("Azure error:", response.status, errorBody);
        throw new functions.https.HttpsError(
          "internal",
          `Azure xatosi: ${response.status}`
        );
      }

      const result = (await response.json()) as AzureResponse;
      const nBest = result.NBest?.[0];

      const pronunciationScore = Math.round(
        nBest?.PronunciationAssessment?.PronScore ?? 0
      );
      const accuracyScore = Math.round(
        nBest?.PronunciationAssessment?.AccuracyScore ?? 0
      );
      const fluencyScore = Math.round(
        nBest?.PronunciationAssessment?.FluencyScore ?? 0
      );

      return {
        success: true,
        pronunciationScore,
        accuracyScore,
        fluencyScore,
        recognizedText: result.DisplayText ?? "",
      };
    } catch (error) {
      if (error instanceof functions.https.HttpsError) throw error;
      functions.logger.error("Unexpected error:", error);
      throw new functions.https.HttpsError("internal", "Baholash xatosi.");
    }
  });

// ── Azure Response Type ────────────────────────────────────────
interface AzureResponse {
  DisplayText?: string;
  NBest?: Array<{
    PronunciationAssessment?: {
      PronScore?: number;
      AccuracyScore?: number;
      FluencyScore?: number;
    };
    Words?: Array<{
      Word: string;
      PronunciationAssessment?: { AccuracyScore?: number };
    }>;
  }>;
}
