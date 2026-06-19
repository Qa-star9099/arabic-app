# CLAUDE.md — Project Constitution

> This file is read automatically by Claude Code. It defines WHAT we build and the RULES we build by. Read this fully before writing any code. Also read `architecture.md`.

---

## 1. Project Overview

**Product:** AI-powered Arabic language learning mobile app for the Uzbekistan market.

**Platform:** Flutter (iOS + Android), mobile-first.

**Module:** "Survival Arabic for Saudi Arabia" — amaliy sayohat tili. Foydalanuvchilar Saudiya Arabistoniga borganda survival logistika (aeroport, taksi, mehmonxona, dorixona, favqulodda) uchun arab tilini o'rganadi.

**Core differentiator:** Cognate-First Spiral methodology — o'zbek tilidagi ~3000+ arab kelib chiqishli so'zlardan foydalanib, foydalanuvchini "noldan" emas, "allaqachon bilgan narsadan" boshlab o'rgatish. Bu xalqaro raqobatchilar (AlifBee) tomonidan nusxalab bo'lmaydigan unfair advantage.

**Future differentiator (Bosqich B):** AI Makhraj Evaluation — talaffuz baholash, o'zbek so'zlovchining nuqsonlariga moslangan. MVP'da (Bosqich A) bu YO'Q — foydalanuvchi o'zini yozib, native bilan solishtiradi.

**Target segments:** Saudiyaga sayohatchi/ziyoratchi, biznes sayohatchi, mehnat migranti.

**Monetization:** Freemium. Free: Arrival + Emergency bloklar. Premium: barcha 16 mavzu.

**Status:** Pre-MVP (Bosqich A). Onboarding + Google Auth tayyor. Lesson yadrosi qurilishi kerak.

**Developer reality:** YOLG'IZ dasturchi (PM/QA profil, Flutter o'rganmoqda). Kod SODDA, KAM FAYL bo'lishi SHART. Ortiqcha boilerplate loyihani o'ldiradi. Pragmatik > mukammal.

---

## 2. CRITICAL LEGAL CONSTRAINT (non-negotiable)

This is a **SECULAR FOREIGN LANGUAGE** app. Arabic is taught strictly as a modern language (grammar, phonetics, conversation, business vocabulary) — exactly like English or German in public schools.

**NEVER generate, include, or scaffold any of the following:**
- Religious education content (Quran, Hadith, Fiqh, Aqida, theology)
- Prayer, dua, zikr, or any religious instruction
- Religious terminology as learning material
- Any feature that interprets or teaches religion

**The app must actively block/deflect religious queries** via `core/content/secular_filter.dart`. All learning content uses only secular vocabulary.

**Secular travel examples that ARE allowed:**
- "Halol restoran qayerda?" = amaliy dietary/travel savol (ALLOW)
- "Aeroportga qanday boraman?" = survival logistika (ALLOW)
- "Qanday ibodat qilinadi?" = diniy savol (BLOCK + deflect)

---

## 3. Architecture Rules (MUST follow)

**Pattern:** Feature-First folder structure + **Pragmatic layered** (NOT full Clean Architecture) + **Riverpod** state management.

**ARXITEKTURA: SERVERLESS.**
- Custom backend YO'Q. Dio YO'Q. JWT YO'Q. REST API YO'Q.
- Firebase Auth + Cloud Firestore + Statik JSON (assets).
- Ortiqcha qatlamlar (domain/, usecases/, abstract repositories) YO'Q — yolg'iz dasturchi uchun boilerplate.

**Data manbalari:**
1. **Statik JSON (assets/content/)** — o'quv kontent (so'zlar, ildizlar, sahnalar, mavzular). TEKIN, offline.
2. **Cloud Firestore** — foydalanuvchi progress, streak, SRS holati. Bepul tier.
3. **Firebase Auth** — Google Sign-In (tayyor va ishlaydi).
4. **Qurilma TTS (flutter_tts)** — audio. TEKIN, offline.

**Folder structure:**
```
lib/
├── main.dart
├── app/              # MaterialApp, router (go_router), theme
├── core/
│   ├── services/tts_service.dart       # flutter_tts wrapper
│   ├── content/secular_filter.dart     # Compliance filter (MUHIM!)
│   ├── error/failures.dart
│   ├── storage/local_store.dart        # Hive
│   └── widgets/                        # Umumiy widgetlar
├── features/
│   ├── auth/          # Firebase Auth + Google Sign-In (TAYYOR)
│   ├── onboarding/    # splash → welcome → goal → level → path (TAYYOR)
│   ├── home/          # mavzular ro'yxati
│   ├── lesson/        # 8 bosqichli spiral oqim (QURILISHI KERAK)
│   ├── placement_test/ # cognate awareness test (MOSLASHTIRISH KERAK)
│   └── profile/
├── data/
│   ├── models/        # word, root, scenario, topic, progress
│   └── repositories/
│       ├── content_repository.dart     # JSON o'qish
│       └── progress_repository.dart    # Firestore yozish/o'qish
└── assets/content/    # Statik kontent JSON
    ├── topics/t01_aeroport.json
    └── ...
```

**Layer flow (sodda):**
```
UI (ConsumerWidget)
  ↓ ref.read(provider.notifier).action()
Controller (AsyncNotifier)
  ↓ calls
Repository (to'g'ridan — domain/usecase qatlamsiz)
  ↓
Firebase / JSON
```

---

## 4. State Management (Riverpod)

```dart
// Repository providers (DI)
final contentRepoProvider = Provider((ref) => ContentRepository());
final progressRepoProvider = Provider((ref) => ProgressRepository(FirebaseFirestore.instance));

// State (screen-level)
final lessonControllerProvider = AsyncNotifierProvider<LessonController, LessonState>(LessonController.new);
```

Rules:
- Repositories → plain Provider
- Screen state → AsyncNotifierProvider / NotifierProvider
- @riverpod generator ishlatilmoqda
- State → freezed, immutable

---

## 5. Core Methodology: Cognate-First Spiral (8 bosqich)

**Har bir arab so'zi shu 8 bosqichdan o'tib o'rganiladi:**

```
1. RECOGNIZE  — tanish o'zbekcha so'z ko'rsatiladi ("safar")
2. REVEAL     — arab yozuvi + 3-harfli ildiz (س-ف-ر → سَفَر)
3. EXPAND     — so'zlar oilasi (musofir, safara, safariyya)
4. LISTEN     — eshitib to'g'risini tanlash (arab harfida + audio)
5. PRONOUNCE  — foydalanuvchi aytadi (MVP: AI ballsiz, solishtirish)
6. COMBINE    — gap tuzish ("men musofirman" → أنا مُسَافِر)
7. APPLY      — survival mini-scenario (ovozli sahna)
8. SPACE      — yakun + spaced repetition
```

**Skill Coverage:**
- Reading + Listening + Speaking = CORE (★★★)
- Grammar = Embedded, discovery orqali (★★)
- Writing = Minimal, faqat harf tanish (★)

**UX Core Principles:**
- Frictionless by default — sun'iy "bos" harakatlar YO'Q
- Arab yozuvi ustuvor (harakat bilan), lotin faqat yordamchi
- Audio hamma joyda — har arab so'z bosilganda eshitiladi
- So'z emas, GAP — har spiral gap tuzish bilan tugaydi
- Foydalanuvchi ovozli yoki yozma javob berishi mumkin

---

## 6. Survival Topic Map (16 mavzu)

```
ARRIVAL (free):      T-01 Aeroport, T-02 Bagaj, T-03 SIM-karta, T-04 Valyuta
TRANSPORT (premium): T-05 Taksi, T-06 Yo'l so'rash, T-07 Mehmonxona, T-08 Belgilar
DAILY (premium):     T-09 Restoran, T-10 Bozor, T-11 Raqamlar, T-12 Salomlashish
EMERGENCY (free):    T-13 Dorixona, T-14 Shifokor, T-15 Politsiya, T-16 Yo'qolish
```

---

## 7. Data Models

Lesson modeli `data/models/lesson_models.dart` da:
- `LessonTopic` — mavzu (T-01..T-16)
- `LessonWord` — bitta so'z (8 bosqich uchun barcha data)
- `LessonRoot` — 3-harfli ildiz
- `FamilyWord` — so'z oilasi a'zosi
- `ListenOption` — tinglash javob varianti
- `SentenceTask` — gap tuzish mashqi
- `ScenarioTask` — survival mini-sahna

JSON kontent `assets/content/topics/` da. Har mavzu alohida JSON fayl.

---

## 8. Onboarding Flow (metodologiyaga moslangan)

```
Splash → Welcome → Goal → Level → DailyGoal → Path → [CognateTest] → AhaMoment → Home
```

**Goal variantlari:** Saudiyaga sayohat / Biznes / Mehnat migranti
**Level framing:** "Arab harflarini bilmayman (LEKIN ko'p so'zni bilasiz!)" — A1/A2/B1 atamasi YO'Q
**Path:** "Qancha arab so'zni bilasiz?" (cognate test) / "Darhol boshlayman!" — "Noldan" so'zi YO'Q
**Aha! moment:** Test natijasidan keyin "Siz allaqachon X ta arab so'zini bilasiz!" sahifasi

---

## 9. Dead Code (tozalanishi kerak)

- `core/constants/api_constants.dart` — ishlatilmaydi (hamma narsa Firebase)
- `core/network/dio_client.dart` va interceptors — ishlatilmaydi
- `pubspec.yaml` dagi `dio` paketi — olib tashlash kerak
- Har qanday `api.arabcha.uz` ga reference — tozalash

---

## 10. Naming Conventions

```
Files:        snake_case      → lesson_models.dart
Classes:      PascalCase      → LessonWord, ContentRepository
Variables:    camelCase       → uzbekCognate, isCorrect
Private:      _prefix         → _handleAnswer()

Screens:      *_page.dart
Widgets:      *_widget.dart
Controllers:  *_controller.dart
Models:       *_model.dart
Repositories: *_repository.dart
```

---

## 11. Git Workflow

```
main         # stable only — PR-only
develop      # asosiy ishchi branch
feature/*    # har feature uchun

Commit: feat: / fix: / refactor: / docs:
```

---

## 12. How to Work With Me (Claude Code)

- **Avval CLAUDE.md va architecture.md ni o'qi.** Ular loyiha haqiqati.
- **Serverless.** Dio, JWT, custom API, interceptors ishlatMA. Firebase + JSON.
- **Sodda kod.** Yolg'iz dasturchi — ortiqcha qatlamlar, boilerplate, abstraksiya YO'Q.
- **Secular filtr.** Har qanday content feature'da secular_filter chaqirilishini tekshir.
- **Audio = flutter_tts.** Remote audio URL ishlatMA.
- **"Noldan" dema.** Foydalanuvchiga "siz allaqachon bilasiz" framing ishlat.
- Incrementally: bir narsa tugatib, so'ng keyingisiga o't.
- Xatoga yo'l qo'yganingda, acknowledg qil va tuzat.
