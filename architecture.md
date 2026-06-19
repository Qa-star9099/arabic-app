# Flutter Architecture Blueprint


---

1. Architecture Decision (ADR-001)

Status: Accepted

Decision: Feature-First folder structure + pragmatic layers + Riverpod + Firebase serverless.

Context: Texnik jihatdan yolg'iz dasturchi (PM/QA profil). 4 yillik tajribali arab tili ustozi (content). Kod sodda, tez, kengayuvchan bo'lishi kerak. Tekin MVP.

Why Feature-First: features isolated → parallel ish oson, merge conflict kam.

Why Riverpod (not BLoC, not get_it):


BLoC'dan kam boilerplate
Compile-time safety
State + DI bitta vositada (get_it kerak emas)
ProviderContainer override orqali oson test


Why Serverless (Firebase, not custom backend):


Tekin — Firebase bepul tier minglab foydalanuvchigacha yetadi
Sodda — yolg'iz dasturchi backend yozmaydi/saqlamaydi
Tez — server qurish/deploy yo'q, to'g'ridan Flutter'dan ishlaydi
Auth, Firestore, (kelajakda) Storage — barchasi Firebase SDK orqali


Consequences:


(+) Parallel ish, oson test, tez, tekin, backend xizmati shart emas
(−) Murakkab server logikasi (masalan AI Maxraj) keyin alohida xizmat sifatida qo'shiladi (Bosqich B)



2. Folder Structure (serverless)

lib/
├── main.dart                      # Entry point, Firebase init, ProviderScope
├── app/
│   ├── app.dart                   # MaterialApp.router, theme wiring
│   ├── router/
│   │   └── app_router.dart        # GoRouter config, auth-based redirect
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_typography.dart
│
├── core/
│   ├── services/
│   │   └── tts_service.dart       # flutter_tts / just_audio wrapper (audio)
│   ├── content/
│   │   └── secular_filter.dart    # Content boundary (COMPLIANCE!)
│   ├── error/
│   │   └── failures.dart          # FirebaseFailure, CacheFailure (sodda)
│   ├── storage/
│   │   └── local_store.dart       # Hive — onboarding/progress cache
│   └── widgets/
│       ├── app_button.dart
│       ├── app_loader.dart
│       └── app_error_view.dart
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   │   └── user_model.dart            # freezed + json_serializable
│   │   ├── repositories/
│   │   │   └── auth_repository.dart        # Firebase Auth + Firestore
│   │   ├── controllers/
│   │   │   └── auth_controller.dart        # Riverpod AsyncNotifier
│   │   └── presentation/pages/
│   │       ├── login_page.dart
│   │       ├── otp_page.dart
│   │       └── personal_info_page.dart
│   │
│   ├── onboarding/   # splash, welcome, goal, level, daily-goal, path
│   ├── lesson/       # 8 bosqichli spiral oqim (YADRO — qurilishi kerak)
│   ├── makhraj/      # talaffuz (Bosqich B — keyin)
│   ├── placement_test/
│   ├── home/
│   └── profile/
│
└── data/
    ├── models/                    # word, root, scenario, topic, progress
    └── repositories/
        ├── content_repository.dart    # statik JSON o'qish (assets)
        └── progress_repository.dart   # Firestore yozish/o'qish


DEAD CODE eslatma: lib/core/constants/api_constants.dart va dio paketi ishlatilmaydi (auth allaqachon Firebase'da). Keyin tozalanadi.




3. Layer Flow (serverless — soddalashgan)

UI (Page / ConsumerWidget)
   ↓ ref.read(provider.notifier).action()
Controller / Provider (AsyncNotifier / Notifier)
   ↓ calls
Repository (to'g'ridan — domain/usecase qatlamsiz, solo-friendly)
   ↓ calls
Manba:
   - Firebase (Auth, Firestore)   → progress, user
   - Statik JSON (assets)          → kontent (so'z, ildiz, sahna)

Eslatma: Custom API, Dio, interceptors YO'Q. Repository to'g'ridan Firebase
SDK yoki JSON o'qiydi.


Pragmatik qaror: To'liq Clean Architecture'dagi domain/, usecases/, abstract repository interface qatlamlari yolg'iz dasturchi uchun ATAYIN qo'shilmaydi. Repository to'g'ridan controller'ga ma'lumot beradi. Keyin jamoa o'ssa qo'shilishi mumkin.




4. Riverpod Provider Patterns

dart// Repository providers (DI)
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(),  // assets/JSON o'qiydi
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(FirebaseFirestore.instance),
);

// State (AsyncNotifier for async work)
final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(AuthController.new);

RULES:
- Repositories → plain Provider (lazy singleton)
- Screen state → AsyncNotifierProvider (async) / NotifierProvider (sync)
- State classes → freezed, immutable
- UI → ConsumerWidget / ConsumerStatefulWidget
- @riverpod generator ishlatilmoqda (boilerplate kam)


5. Pragmatic Simplicity

TO'LIQ logika (Repository + controller logikasi) — qachon:
- Lesson progress, Spaced Repetition, Auth, (kelajak) Makhraj

SODDALASHTIRISH — qachon:
- Oddiy statik ekran (Settings)
- Controller to'g'ridan repository chaqiradi

QOIDA: papka strukturasi bir xil qoladi. Murakkablik kerak bo'lganда qo'shiladi.


6. Error Handling (sodda)

typedef Result<T> = Either<Failure, T>;   // fpdart

Repository Firebase/JSON xatosini ushlaydi
  → Either.left(Failure) qaytaradi
  → Controller folds → success yoki error state
  → UI lokalizatsiya qilingan xabar ko'rsatadi

Raw exception hech qachon UI'ga chiqmaydi.
Failure turlari: FirebaseFailure, CacheFailure, ContentFailure


7. Data Manbalari (Networking O'RNIGA)

Custom API / Dio / interceptors YO'Q.

Ma'lumot manbalari:
1. Firebase Auth        → kirish, ro'yxat (Google Sign-In tayyor)
2. Cloud Firestore      → user, progress, streak, SRS holati
3. Statik JSON (assets) → so'z, ildiz, sahna, mavzu (tekin, offline)
4. Qurilma TTS          → audio (flutter_tts / just_audio)

Firestore collections:
- users/{uid}           → profil, learningGoal, level, dailyGoal
- user_progress/{uid}   → tugatilgan bloklar, streak
- word_states/{uid}/... → spaced repetition holati


8. Local Storage (Hive)

Uses:
- Onboarding/guest holati → Hive
- User progress cache (offline) → Hive
- Kontent JSON → assets ichida (Hive kerak emas, ilova ichida)

Eslatma: Audio fayllar — qurilma TTS generatsiya qiladi (oldindan yuklash shart emas).
Signed URL / remote audio yo'q (serverless).


9. Navigation (go_router)

app/router/app_router.dart:
- Declarative routes (AppRoutes constants)
- Auth-based redirect: token yo'q → /welcome; onboarding tugamagan → /onboarding/goal
- Guest routes (onboarding) token'siz ochiq
- Navigatsiya app holatига qarab (learningGoal == null → onboarding)


10. Testing Strategy

- Repository tests: fake Firebase / fake JSON
- Provider tests: ProviderContainer override
- Widget tests: kritik ekranlar (lesson bosqichlari, placement test)
- Integration: onboarding → lesson → progress sync

Riverpod override orqali oson.


11. Git Workflow

main      → barqaror, PR-only
develop   → asosiy ishchi branch
feature/* → har feature uchun

Commit prefiks: feat: fix: refactor: docs: test:


12. Compliance qatlami (MUHIM — secular boundary)

core/content/secular_filter.dart — markazlashgan compliance.

- Har content ko'rsatilishidan oldin filterdan o'tadi
- Diniy element bo'lsa → bloklaydi/deflect
- PRD Negative Test Cases bilan bog'liq
- Audit: deflect loglanadi

Bu bir joyda markazlashgan — har feature o'zi tekshirmaydi.
