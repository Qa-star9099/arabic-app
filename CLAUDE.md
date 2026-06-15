# CLAUDE.md — Project Constitution

> This file is read automatically by Claude Code. It defines WHAT we build and the RULES we build by. Read this fully before writing any code. Also read `docs/architecture.md` and `docs/api-contracts.md`.

---

## 1. Project Overview

**Product:** AI-powered Arabic language learning mobile app for the Uzbekistan market.

**Platform:** Flutter (iOS + Android), mobile-first. Web comes later (post-MVP).

**Core differentiator:** Real-time AI Makhraj Evaluation — evaluates the user's Arabic pronunciation and gives corrective feedback, tuned for native Uzbek speakers.

**Learning tracks:** Business Arabic, Travel Arabic, Academic Arabic. Gamified, Duolingo-style.

**Status:** Pre-MVP. Building from scratch.

**Developer reality:** Solo developer (Flutter), with a co-developer expected to join. Code MUST be clean, consistent, and onboarding-friendly. Balance: ship fast, but no stupid architectural mistakes.

---

## 2. CRITICAL LEGAL CONSTRAINT (non-negotiable)

This is a SECULAR FOREIGN LANGUAGE app. Arabic is taught strictly as a modern language (grammar, phonetics, conversation, business vocabulary) — exactly like English or German in public schools.

**NEVER generate, include, or scaffold any of the following:**
- Religious education content (Quran, Hadith, Fiqh, Aqida, theology)
- Prayer, dua, zikr, or any religious instruction
- Religious terminology as learning material
- Any feature that interprets or teaches religion

**The app must actively block/deflect religious queries** via a content filter layer. All learning content (including Makhraj practice words) uses only secular vocabulary. When building any content-handling or AI-input feature, implement the negative-case filter.

---

## 3. Architecture Rules (MUST follow)

**Pattern:** Feature-First folder structure + Clean Architecture layers + **Riverpod** state management.

**State management:** `flutter_riverpod` + `riverpod_generator`. Riverpod also serves as Dependency Injection — do NOT add get_it.

**Dependency Rule:** dependencies point INWARD only.
- `presentation` → `domain` ← `data`
- `domain` depends on nothing (pure Dart, no Flutter, no packages)

**Folder structure (every feature follows this):**
```
lib/
├── main.dart
├── app/              # MaterialApp, router, theme
├── core/             # shared: constants, error, network, utils, widgets
├── features/
│   └── <feature>/
│       ├── data/         # datasources, models, repository impl
│       ├── domain/       # entities, repository interfaces, usecases
│       └── presentation/ # providers (Riverpod), pages, widgets
```

**Pragmatic simplicity (YAGNI):** For trivial CRUD screens, a UseCase that only forwards to a repository may be skipped — the provider can call the repository directly. But the FOLDER STRUCTURE stays identical everywhere. Add complexity as it grows, not preemptively.

---

## 4. State Management Conventions (Riverpod)

```
Each feature's presentation/providers/ contains:
- <feature>_provider.dart   # AsyncNotifier (for async/API) or Notifier (simple state)
- <feature>_state.dart      # State class via freezed

Use:
- AsyncNotifierProvider  → async operations (API calls)
- NotifierProvider       → simple synchronous state
- Provider               → dependencies (repositories, usecases, dio)

State is always immutable (freezed). No setState in feature logic.
```

---

## 5. Networking Rules

**HTTP client:** `dio` with interceptors in `core/network/`.

Interceptors MUST implement these global API rules (see `docs/api-contracts.md`):
- `auth_interceptor` — adds `Authorization: Bearer {token}` to private endpoints
- `error_interceptor` — converts API errors into `Failure` objects
- `refresh_interceptor` — handles 401 with token refresh, using a **Mutex lock** so simultaneous requests don't all trigger refresh at once
- `Accept-Language` header (uz/ru/en) on every request, fallback to `uz`
- Generate `Idempotency-Key` (client UUID) for side-effecting POSTs
- Log `request_id` from error responses

---

## 6. Error Handling

**Never let exceptions reach the UI.** Use `Either<Failure, Success>` (package: `fpdart`).

```
Flow:
DataSource throws exception
  → Repository converts to Failure (Either.left)
  → UseCase returns Either
  → Provider reads Failure, emits matching state
  → UI shows the localized display_message from API Contract
```

`core/error/` holds `failures.dart` (ServerFailure, NetworkFailure, CacheFailure) and `exceptions.dart`.

---

## 7. Naming Conventions

```
Files:        snake_case      → auth_provider.dart, login_page.dart
Classes:      PascalCase      → AuthNotifier, LoginPage
Variables:    camelCase       → accessToken, isLoading
Private:      _prefix         → _handleLogin()

Screens:      *_page.dart
Sub-widgets:  *_widget.dart
Providers:    *_provider.dart, *_state.dart
Models:       *_model.dart (data layer), *_entity.dart (domain layer)
UseCases:     verb-based      → login_user.dart, get_lessons.dart
```

---

## 8. Core Packages

| Package | Purpose |
|---|---|
| `flutter_riverpod` + `riverpod_generator` | State management + DI |
| `dio` | HTTP client with interceptors |
| `fpdart` | Either for error handling |
| `freezed` + `json_serializable` | Immutable models, JSON parsing |
| `hive` / `hive_flutter` | Local storage (offline lessons, tokens) |
| `go_router` | Type-safe navigation |
| `flutter_secure_storage` | Store JWT tokens securely |

---

## 9. Key Domain Concepts (from API Contracts)

- **Auth:** OTP (phone), Google/Apple SSO. JWT access (15 min) + refresh (30 days, rotation + 30s grace period). FCM token + device_id captured at login.
- **Onboarding:** Guest does first lesson locally (Hive), syncs after login (Option B). `sync_resolution`: applied/ignored.
- **Content hierarchy:** Goal → Module (4) → Lesson (5) → Exercise. Access is determined at MODULE level (`is_free`), first 3 modules free.
- **Content security:** Lesson content + audio served via Signed URLs (TTL 10 min). Offline: ignore signed_url, use local files by `file_id` (Local Asset Mapping — critical to avoid crashes).
- **Anti-cheat:** XP is server-authoritative (never trust client). Streak uses monotonic timer (`seconds_since_last_sync`), not wall-clock.
- **Makhraj:** records audio, sends to backend AI, returns score (0-100) + verdict + feedback. Online-only. Internal AI implementation is the AI Engineer's domain — the app only handles the interface.

See `docs/api-contracts.md` for full request/response schemas.

---

## 10. Git Workflow

```
main         # stable, working code only — NO direct push
develop      # main working branch
feature/*    # one branch per feature (feature/auth, feature/makhraj)

Commits: feat: / fix: / refactor: / docs: prefixes
Merge to main only via Pull Request.
```

---

## 11. How to Work With Me (Claude Code)

- Work incrementally, feature by feature. Scaffold structure first, then one reference feature (Auth or Onboarding) as the gold-standard pattern, then expand.
- After scaffolding, STOP and let me review before mass-generating screens.
- Always follow the folder structure and naming above — consistency over cleverness.
- When unsure about a product decision, ASK rather than assume.
- Respect the legal constraint (Section 2) in every content-related feature.
- Write code a co-developer can understand in 6 months.
