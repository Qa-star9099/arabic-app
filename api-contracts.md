# API Contracts & Data Schemas

> Backend ↔ Flutter interface. Primary language: English. Comments: Russian.
> Source of truth for all models, endpoints, and data flow. Internal AI implementation (Makhraj) is out of scope here — only the interface.

---

## GLOBAL API RULES (apply to all modules)

1. **Localization:** client sends `Accept-Language: uz | ru | en`. Backend returns FLAT localized strings. Fallback: unsupported language → `uz`.
2. **Tracing:** every error response contains `request_id`.
3. **Idempotency:** side-effecting operations accept `Idempotency-Key` header (client UUID). Retry with same key → same result, no duplicate.
4. **Time:** backend NEVER trusts client time for calculations (streak, XP). Uses `server_received_at`.
5. **API versioning:** `/api/v1/`. v1 supported min 12 months after v2. Deprecated endpoints return `Deprecation: true` + `Sunset: {date}`.

---

# MODULE 1 — Auth & User

## Data Schemas

### User
```json
{
  "id": "string (UUID v4)",
  "phone": "string (+998XXXXXXXXX)",
  "email": "string | null",
  "full_name": "string | null",
  "avatar_url": "string | null",
  "auth_provider": "phone | google | apple",
  "learning_goal": "business | travel | academic | null",
  "subscription_status": "free | premium",
  "subscription_expires_at": "ISO8601 | null",
  "fcm_token": "string | null",
  "device_id": "string | null",
  "created_at": "ISO8601",
  "updated_at": "ISO8601"
}
```

### Tokens
```json
{ "access_token": "JWT", "refresh_token": "JWT", "token_type": "Bearer" }
```

## Endpoints

### POST /api/v1/auth/otp/send
Request: `{ "phone": "+998901234567" }`
Response 200: `{ "success": true, "data": { "session_id": "uuid", "expires_at": "ISO8601", "attempts_left": 3, "resend_after": 60 } }`
Errors: `OTP_RATE_LIMITED` (429, progressive block), `INVALID_PHONE_FORMAT` (400). Errors carry localized `display_message`.

### POST /api/v1/auth/otp/verify
Request: `{ "session_id": "uuid", "code": "123456", "fcm_token": "string|null", "device_id": "string|null" }`
Response 200: `{ "success": true, "data": { "is_new_user": true, "next_screen": "onboarding|home", "tokens": {...}, "user": {...} } }`
Errors: `INVALID_OTP_CODE` (400, +attempts_left), `OTP_EXPIRED` (400), `OTP_SESSION_BLOCKED` (400).

### POST /api/v1/auth/google
Request: `{ "id_token": "string", "fcm_token": "string|null", "device_id": "string|null" }`
Response 200: same shape as verify. Error: `INVALID_GOOGLE_TOKEN` (401).

### POST /api/v1/auth/apple
Request: `{ "identity_token": "string", "authorization_code": "string", "full_name": {"given_name":"string|null","family_name":"string|null"}, "fcm_token": "string|null", "device_id": "string|null" }`
NOTE: Apple sends full_name ONLY on first login. Backend must persist it and not overwrite with null later.

### POST /api/v1/auth/token/refresh
Request: `{ "refresh_token": "string" }`
Response 200: new tokens (rotation). Error: `INVALID_REFRESH_TOKEN` (401).
CLIENT NOTE: use Mutex lock so simultaneous 401s trigger only one refresh. Backend grace period: old token valid 30s after rotation.

### POST /api/v1/auth/logout
Request: `{ "refresh_token": "string", "all_devices": false }`

### GET /api/v1/users/me
Headers: `Cache-Control: private, max-age=300`, `ETag`. Returns full user object.

### PATCH /api/v1/users/me
Request: `{ "full_name": "string", "avatar_url": "string", "learning_goal": "business|travel|academic", "fcm_token": "string|null" }`
NOTE: avatar_url — HTTPS only, domain whitelist (anti-SSRF).

### DELETE /api/v1/users/me
Request: `{ "confirmation": "DELETE" }`. MANDATORY (App Store 5.1.1). Soft delete: anonymize after 30 days, invalidate all tokens immediately.

---

# MODULE 2 — Onboarding

Guest does first lesson locally (Option B), syncs after login.

### GET /api/v1/onboarding/goals  (PUBLIC)
Response: list of `{ code, title, description, icon_url }`. Cache 1h. Rate limit 60/min per IP.

### GET /api/v1/onboarding/first-lesson?goal={code}  (PUBLIC)
Response: `{ lesson_id, goal, title, estimated_minutes, content_version, updated_at, content_url (Signed URL TTL 10min) }`
Error: `INVALID_GOAL_CODE` (400).

### POST /api/v1/onboarding/sync  (PRIVATE, Idempotency-Key)
Request: `{ "selected_goal": "travel", "first_lesson_id": "uuid", "first_lesson_completed": true }`
NOTE: XP computed server-side from lesson_id (no first_lesson_xp from client — anti-spoofing).
Response: `{ "sync_resolution": "applied|ignored", "user": {...}, "next_screen": "home" }`
- applied = new user, local data saved
- ignored = existing user, local data dropped, DB state returned

### POST /api/v1/onboarding/skip  (PRIVATE)
Request: `{ "selected_goal": "business" }`. For users who login via SSO directly.

---

# MODULE 3 — Lesson & Content

Hierarchy: Goal → Module (4) → Lesson (5) → Exercise.
Access determined at MODULE level (`is_free`), first 3 modules free.
Metadata via API; heavy content (exercises, audio) via CDN Signed URLs.

## Single sources of truth
- free/premium → Module.is_free only
- XP → lesson.xp_reward on backend only
- lock → computed on backend only
- time → server_received_at only

## Schemas

### Module
```json
{ "module_id":"uuid", "goal":"...", "order":1, "title":"str", "description":"str", "lesson_count":5, "is_free":true, "icon_url":"str" }
```

### Lesson (metadata)
```json
{ "lesson_id":"uuid", "module_id":"uuid", "order":1, "title":"str", "type":"phonetics|grammar|vocabulary|makhraj", "estimated_minutes":5, "xp_reward":15, "exercise_count":5, "content_version":3, "updated_at":"ISO8601", "is_locked":false, "content_url":"Signed URL|null" }
```

### Lesson Progress
```json
{ "lesson_id":"uuid", "status":"not_started|in_progress|completed", "xp_earned":15, "completed_at":"ISO8601|null", "resume_exercise_id":"uuid|null", "resume_content_version":"int|null" }
```

## Endpoints

### GET /api/v1/content/modules?goal={code}  (PRIVATE)
Returns modules with is_free + completed_lessons/total_lessons.

### GET /api/v1/content/modules/{module_id}/lessons  (PRIVATE)
Returns module_is_free + lessons list (with is_locked, status, content_version).

### GET /api/v1/content/lessons/{lesson_id}  (PRIVATE)  ⭐
Checks access → generates Signed URLs.
Response: `{ lesson_id, title, type, xp_reward, exercise_count, content_version, content_url (Signed), audio_files:[{file_id, signed_url}], resume_exercise_id, content_token_issued_at }`
Errors: `PREMIUM_REQUIRED` (403, +paywall_module_id), `LESSON_LOCKED` (423, +required_lesson_id).
NOTE: each audio file signed individually. Exercises reference file_id → client resolves to signed_url.

### POST /api/v1/content/lessons/{lesson_id}/complete  (PRIVATE, Idempotency-Key)  ⭐
Request: `{ "exercises_attempted":5, "exercises_correct":4, "client_completed_at":"ISO8601", "seconds_since_last_sync":3600 }`
- exercises_correct/attempted = reference stats only. XP from lesson.xp_reward.
- seconds_since_last_sync = MONOTONIC timer (Flutter Stopwatch / Android elapsedRealtime), NOT wall-clock. Server reconstructs real_time = last_server_sync + seconds_since_last_sync for streak (anti-farming).
- client_completed_at = reference only.
Response: `{ lesson_id, module_id, status, xp_earned, total_xp, current_streak, module_completed, next_lesson:{lesson_id,is_locked}, unlocked_achievements:[codes] }`
Error: `COMPLETION_TOO_FAST` (429) — time between content_token_issued_at and complete < 30s.

### PUT /api/v1/content/lessons/{lesson_id}/progress  (PRIVATE)
Request: `{ "resume_exercise_id":"uuid", "content_version":3 }`
CLIENT NOTE: call ONLY on AppLifecycleState.paused or explicit exit. NOT after every exercise (battery/data drain). In-lesson progress stays in RAM.

### GET /api/v1/content/progress  (PRIVATE)
Response: `{ goal, total_xp, current_streak, level, completed_lessons, total_lessons_all, completion_percent }`
NOTE: completion_percent from ALL lessons (incl. premium) → motivates free users.

## Offline strategy
- Download: GET each lesson → store content_url JSON + audio files locally by file_id + content_version.
- Local Asset Mapping (CRITICAL): offline play uses local file by audio_file_id, IGNORES expired signed_url in JSON. If missing → fetch fresh online.
- Sync online: queue completions, send POST /complete each with own Idempotency-Key. Compare content_version → re-download updated.
- Makhraj offline does NOT work (needs server AI).

## Exercise types (in CDN content JSON)
multiple_choice, word_matching (uz-arab pairs with associative_hint ⭐), fill_blank, listening (audio_file_id resolved to signed_url).

## Backlog (Phase 2)
Leaderboard anti-cheat: move answer validation to backend (client exercises_correct not trustworthy — Charles Proxy).

---

# MODULE 4 — AI Makhraj Evaluation (interface only)

App records audio + knows the target → sends to backend → gets evaluation.
Internal AI (model, fine-tuning) = AI Engineer's domain, NOT in this contract.

## Expected interface (to be finalized with AI Engineer)
Input: audio recording + target_id (what user should pronounce).
Output:
```json
{ "score": 0-100, "verdict": "passed|needs_improvement|failed", "wrong_phoneme": "string|null", "feedback_uz": "string", "diagram_id": "string|null" }
```

## Product rules (see AI Makhraj Evaluation Notion page for full spec)
- Tuned for Uzbek accent as learning norm (progressive bar: beginner forgiven more).
- False negatives (saying "wrong" when correct) are the worst outcome — avoid.
- Online-only. No internet → show message, offer offline lessons.
- Edge cases: noise → ask re-record; silence → don't score; wrong word → "Boshqa so'z aytdingiz"; 5 fails → offer skip, never block.
- LEGAL: only secular vocabulary as practice words. No religious content.
- Voice = personal data → consent + protection.

## Out of scope (MVP)
Full sentences with intonation, dialects (MSA only), real-time during-speech eval, conversation mode (Phase 2).

---

# MODULES NOT YET CONTRACTED
- Module 5: Payments (Payme/Click, subscription) — to be designed
- Gamification: XP/streak/badges schema — partially defined, full contract pending

## General error codes
INVALID_PHONE_FORMAT, INVALID_OTP_CODE, OTP_EXPIRED, OTP_SESSION_BLOCKED, OTP_RATE_LIMITED, INVALID_GOOGLE_TOKEN, INVALID_APPLE_TOKEN, INVALID_REFRESH_TOKEN, UNAUTHORIZED, PREMIUM_REQUIRED, LESSON_LOCKED, COMPLETION_TOO_FAST, LESSON_NOT_FOUND, MODULE_NOT_FOUND, INVALID_GOAL_CODE, SERVER_ERROR.
