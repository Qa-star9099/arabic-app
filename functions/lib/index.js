"use strict";
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
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.assessPronunciation = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const node_fetch_1 = __importDefault(require("node-fetch"));
admin.initializeApp();
const db = admin.firestore();
// ── Constants ──────────────────────────────────────────────────
const RATE_LIMIT_MAX = 10;
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // 1 minute
const ALLOWED_LOCALES = ["ar-SA", "ar-AE", "ar-EG", "ar"];
const MAX_AUDIO_BASE64_LENGTH = 2000000; // ~1.5MB audio
const MAX_REFERENCE_TEXT_LENGTH = 50;
// Arabic Unicode range + basic Latin alphanumeric + spaces
const REFERENCE_TEXT_REGEX = /^[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF\u0020-\u007Ea-zA-Z0-9 ]+$/;
// ── Cloud Function ─────────────────────────────────────────────
exports.assessPronunciation = functions
    .region("europe-west1")
    .https.onCall(async (data, context) => {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l;
    // ── Layer 1: Firebase Auth ─────────────────────
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Autentifikatsiya talab qilinadi.");
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
        const { count, windowStart } = doc.data();
        // Window expired → reset
        if (now - windowStart > RATE_LIMIT_WINDOW_MS) {
            tx.update(rateLimitRef, { count: 1, windowStart: now });
            return;
        }
        // Within window and at limit → reject
        if (count >= RATE_LIMIT_MAX) {
            throw new functions.https.HttpsError("resource-exhausted", "Minutiga 10 tadan ko'p baholash mumkin emas. Biroz kuting.");
        }
        // Within window, under limit → increment
        tx.update(rateLimitRef, { count: count + 1 });
    });
    // ── Layer 3: Input Validation ──────────────────
    const { audioBase64, referenceText, locale } = data;
    // audioBase64
    if (typeof audioBase64 !== "string" || audioBase64.length === 0) {
        throw new functions.https.HttpsError("invalid-argument", "audioBase64 majburiy.");
    }
    if (audioBase64.length > MAX_AUDIO_BASE64_LENGTH) {
        throw new functions.https.HttpsError("invalid-argument", "Audio fayl juda katta (max 1.5MB).");
    }
    // referenceText
    if (typeof referenceText !== "string" || referenceText.length === 0) {
        throw new functions.https.HttpsError("invalid-argument", "referenceText majburiy.");
    }
    if (referenceText.length > MAX_REFERENCE_TEXT_LENGTH) {
        throw new functions.https.HttpsError("invalid-argument", "referenceText juda uzun (max 50 harf).");
    }
    if (!REFERENCE_TEXT_REGEX.test(referenceText)) {
        throw new functions.https.HttpsError("invalid-argument", "referenceText noto'g'ri belgilar o'z ichiga olgan.");
    }
    // locale — fallback to ar-SA if invalid
    const safeLocale = ALLOWED_LOCALES.includes(locale) ? locale : "ar-SA";
    // ── Azure API Call ─────────────────────────────
    const apiKey = (_a = functions.config().azure) === null || _a === void 0 ? void 0 : _a.speech_key;
    const region = (_c = (_b = functions.config().azure) === null || _b === void 0 ? void 0 : _b.speech_region) !== null && _c !== void 0 ? _c : "eastus";
    if (!apiKey) {
        functions.logger.error("Azure speech_key not configured");
        throw new functions.https.HttpsError("internal", "Server konfiguratsiya xatosi.");
    }
    const audioBuffer = Buffer.from(audioBase64, "base64");
    const pronunciationConfig = Buffer.from(JSON.stringify({
        ReferenceText: referenceText,
        GradingSystem: "HundredMark",
        Granularity: "Word",
        EnableMiscue: false,
    })).toString("base64");
    const endpoint = `https://${region}.stt.speech.microsoft.com` +
        `/speech/recognition/conversation/cognitiveservices/v1` +
        `?language=${safeLocale}&format=detailed`;
    try {
        const response = await (0, node_fetch_1.default)(endpoint, {
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
            throw new functions.https.HttpsError("internal", `Azure xatosi: ${response.status}`);
        }
        const result = (await response.json());
        const nBest = (_d = result.NBest) === null || _d === void 0 ? void 0 : _d[0];
        const pronunciationScore = Math.round((_f = (_e = nBest === null || nBest === void 0 ? void 0 : nBest.PronunciationAssessment) === null || _e === void 0 ? void 0 : _e.PronScore) !== null && _f !== void 0 ? _f : 0);
        const accuracyScore = Math.round((_h = (_g = nBest === null || nBest === void 0 ? void 0 : nBest.PronunciationAssessment) === null || _g === void 0 ? void 0 : _g.AccuracyScore) !== null && _h !== void 0 ? _h : 0);
        const fluencyScore = Math.round((_k = (_j = nBest === null || nBest === void 0 ? void 0 : nBest.PronunciationAssessment) === null || _j === void 0 ? void 0 : _j.FluencyScore) !== null && _k !== void 0 ? _k : 0);
        return {
            success: true,
            pronunciationScore,
            accuracyScore,
            fluencyScore,
            recognizedText: (_l = result.DisplayText) !== null && _l !== void 0 ? _l : "",
        };
    }
    catch (error) {
        if (error instanceof functions.https.HttpsError)
            throw error;
        functions.logger.error("Unexpected error:", error);
        throw new functions.https.HttpsError("internal", "Baholash xatosi.");
    }
});
//# sourceMappingURL=index.js.map