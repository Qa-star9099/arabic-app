# Flutter Architecture Blueprint

> Full architecture reference for the Arabic learning app. Read alongside `CLAUDE.md` and `docs/api-contracts.md`. State management: **Riverpod** (also serves as DI).

---

## 1. Architecture Decision (ADR-001)

**Status:** Accepted

**Decision:** Feature-First folder structure + Clean Architecture layers + Riverpod.

**Context:** Solo developer starting; co-developer joining. Code must be understandable and extensible by two people. Balance speed vs quality.

**Why Feature-First:** features are isolated → parallel work is easy, merge conflicts minimal.

**Why Clean Architecture:** testable, swappable data sources (API + offline cache), clear boundaries.

**Why Riverpod (not BLoC, not Provider, not get_it):**
- Less boilerplate than BLoC
- Compile-time safety (no runtime provider-not-found)
- Serves as DI too — one tool for state + dependencies (drop get_it)
- Easy testing via `ProviderContainer` overrides

**Consequences:**
- (+) Parallel work, easy testing, fast onboarding, single tool for state+DI
- (−) More setup upfront; slight overhead for trivial screens (mitigated by pragmatic simplicity)

---

## 2. Folder Structure

```
lib/
├── main.dart                      # Entry point, ProviderScope, Hive init
├── app/
│   ├── app.dart                   # MaterialApp.router, theme wiring
│   ├── router/
│   │   └── app_router.dart        # GoRouter config, route guards
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_typography.dart
│
├── core/
│   ├── constants/
│   │   └── api_constants.dart     # base URL, endpoint paths
│   ├── error/
│   │   ├── failures.dart          # ServerFailure, NetworkFailure, CacheFailure
│   │   └── exceptions.dart        # ServerException, CacheException
│   ├── network/
│   │   ├── dio_client.dart        # base Dio setup
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── error_interceptor.dart
│   │       └── refresh_interceptor.dart  # 401 + Mutex lock
│   ├── storage/
│   │   └── secure_storage.dart    # JWT via flutter_secure_storage
│   ├── utils/
│   │   └── result.dart            # typedef for Either<Failure, T>
│   └── widgets/
│       ├── app_button.dart
│       ├── app_loader.dart
│       └── app_error_view.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart        # freezed + json_serializable
│   │   │   │   └── token_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user.dart               # pure Dart entity
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart     # abstract interface
│   │   │   └── usecases/
│   │   │       ├── send_otp.dart
│   │   │       ├── verify_otp.dart
│   │   │       └── refresh_token.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── auth_provider.dart       # AsyncNotifier
│   │       │   └── auth_state.dart          # freezed state
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── otp_page.dart
│   │       └── widgets/
│   │           └── otp_input_widget.dart
│   │
│   ├── onboarding/   # same structure
│   ├── lesson/       # same structure
│   ├── makhraj/      # same structure
│   ├── gamification/ # same structure
│   └── profile/      # same structure
│
└── injection_note.md  # (none needed — Riverpod providers handle DI)
```

---

## 3. Layer Flow

```
UI (Page / ConsumerWidget)
   ↓ ref.read(provider.notifier).someAction()
Provider (AsyncNotifier / Notifier)
   ↓ calls
UseCase (one business action)
   ↓ calls
Repository (interface in domain/, impl in data/)
   ↓ calls
DataSource (Remote: Dio / Local: Hive)
   ↓
API or local DB

Dependency Rule: presentation → domain ← data
domain is pure (no Flutter, no packages).
```

---

## 4. Riverpod Provider Patterns

```dart
// Dependency providers (DI)
final dioProvider = Provider<Dio>((ref) => DioClient.create());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);

final verifyOtpProvider = Provider(
  (ref) => VerifyOtp(ref.watch(authRepositoryProvider)),
);

// State provider (AsyncNotifier for async work)
final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
```

```
RULES:
- Dependencies (repos, usecases, dio) → plain Provider, lazy singletons by default
- Screen state → AsyncNotifierProvider (async) or NotifierProvider (sync)
- State classes → freezed, immutable
- UI uses ConsumerWidget / ConsumerStatefulWidget, never reads providers outside ref
- Prefer riverpod_generator (@riverpod) once comfortable — reduces boilerplate
```

---

## 5. Pragmatic Simplicity (when to skip layers)

```
FULL layers (UseCase + Repository) — when:
- Complex business logic (Makhraj, Payments, Lesson progress, Auth)
- Multiple data sources (API + offline cache)

SIMPLIFY — when:
- Trivial CRUD/static screen (e.g. Settings)
- UseCase would only forward to repository with no added logic
  → provider may call repository directly

RULE: folder structure stays identical. Add complexity as needed, not upfront.
```

---

## 6. Error Handling

```
typedef Result<T> = Either<Failure, T>;   // fpdart

DataSource throws exception
  → Repository catches, returns Either.left(Failure)
  → UseCase returns Result<T>
  → Provider folds Either → emits success or error state
  → UI shows localized display_message (from API Contract)

Never propagate raw exceptions to UI.
```

---

## 7. Networking

```
core/network/dio_client.dart — base config (baseUrl, timeouts, headers)

Interceptors (order matters):
1. auth_interceptor      → Bearer token on private endpoints
2. refresh_interceptor   → on 401: refresh with Mutex lock (one refresh at a time)
3. error_interceptor     → map DioException → Failure

Global rules implemented here:
- Accept-Language header (uz/ru/en, fallback uz)
- Idempotency-Key (UUID) for side-effecting POSTs
- Log request_id from error bodies
```

---

## 8. Local Storage (Hive)

```
Uses:
- JWT tokens → flutter_secure_storage (NOT Hive — security)
- Offline lessons (content JSON + audio file paths) → Hive + file system
- Guest onboarding state (Option B) → Hive
- User progress cache → Hive

Local Asset Mapping (CRITICAL):
- Downloaded lesson JSON contains EXPIRED signed_urls
- Offline: NEVER use signed_url from JSON
- Use audio_file_id → look up local file path → play locally
- If not found locally → fetch fresh GET /content/lessons/{id}
```

---

## 9. Navigation (go_router)

```
app/router/app_router.dart:
- Declarative routes
- Route guard: redirect to /login if no valid token on private routes
- Guest routes (onboarding) accessible without token
- Navigation decided by app state (e.g. learning_goal == null → onboarding)
  NOTE: next_screen from API is a hint; client owns final navigation
```

---

## 10. Testing Strategy

```
- Unit tests: domain layer (usecases, entities) — pure, fast
- Provider tests: ProviderContainer with overridden dependencies
- Widget tests: critical screens (login, lesson, makhraj)
- Integration: critical paths (onboarding → first lesson → login → sync)

Riverpod makes this easy: override providers with fakes in tests.
```

---

## 11. Git Workflow

```
main      → stable only, PR-only
develop   → main working branch
feature/* → one per feature

Commit prefixes: feat: fix: refactor: docs: test:
```
