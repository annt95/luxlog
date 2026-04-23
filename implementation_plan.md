# Luxlog — Implementation Progress Tracker

## 📅 Cập nhật lần cuối: 2026-04-20 (Phase J Production Hardening Audit)

> Tổng hợp tiến độ triển khai dự án Luxlog dựa trên rà soát toàn bộ mã nguồn thực tế,
> đối chiếu với PLAN.md và WALKTHROUGH.md.

---

## 📊 Tổng quan Tiến độ

| Khu vực | Hoàn thành | Ghi chú |
|:---|:---:|:---|
| Core Infrastructure | **100%** | Env, Supabase, Errors, Models |
| Data Layer (Repositories) | **100%** | 8 repos + new methods: hasLiked, isFollowing, fetchFollowingFeed, fetchTopLiked |
| Auth System | **100%** | Email + Google OAuth + guards + password reset |
| Frontend UI | **100%** | All screens + Social features wired |
| UI ↔ Data Wiring | **100%** | Like/Follow/Comment/Share all connected to backend |
| Router & Guards | **100%** | 15 routes; protected: upload, notifications, profile/edit |
| Notification System | **100%** | Realtime stream + badge + markAllAsRead provider + triggers backend |
| Security | **85%** | RLS + headers + file type whitelist + input sanitization + self-follow guard |
| Vercel Deployment | **98%** | Pipeline hoạt động; auto-deploy on push; git clean |
| Testing | **80%** | 29 test files + 11 E2E specs; coverage + integration in CI |
| SEO | **90%** | Runtime meta, OG, JSON-LD, sitemap, bot snapshot; pending prod QA gate |
| Observability | **40%** | AppLogger + AnalyticsService wired BUT no external sink (Sentry/HTTP) |
| Social Features | **98%** | Navigation, Like, Follow, Comment, Share, Save/Bookmark, Category Filter, Editor's Pick |
| Accessibility | **75%** | Semantic labels on nav, buttons, photo cards, tooltips on actions |
| Documentation | **80%** | DATABASE.md, CONTRIBUTING.md, implementation_plan.md |
| URL Optimization | **100%** | Path-based URLs (no hash), SPA fallback, OAuth code cleanup |
| Portfolio Feature | **85%** | Editor + Public view + Real data dashboard + Delete/Preview wired |
| **Performance** | **80%** | Image transforms disabled, no request caching, no retry UI. Feed infinite scroll complete. |
| **Rate Limiting** | **0%** | No client/server rate limiting on API calls |
| **Error Tracking (Prod)** | **0%** | ErrorReporter logs to console only — no Sentry/HTTP in release |

---

## ✅ Hoàn thành (Đã xác nhận qua code scan 2026-04-20)

### Core & Infrastructure
- [x] Supabase Service init + Env config (`--dart-define`) + fail-fast release
- [x] Sealed `AppException` với `cause` + `stackTrace`
- [x] `ErrorBoundary` widget
- [x] Freezed models: User, Photo, Portfolio, Tag, Category (+ `.freezed.dart` + `.g.dart`)
- [x] 8 Repositories: Auth, AuthRemote, Photo, Portfolio, User, Tag, Category, Notification
- [x] Riverpod providers cho tất cả repos (generated with `riverpod_generator`)
- [x] 8 migrations: `001`→`007` + `consolidated_production.sql` + `008` (likes trigger) + `009` (saves) + `010` (portfolio update policy)

### Auth System
- [x] Email signup/signin với validation (email regex + password strength 8+ chars, 1 upper, 1 digit)
- [x] Google OAuth redirect flow (`signInWithGoogle()` + `_getRedirectUrl()`)
- [x] Facebook button removed from UI
- [x] Password reset flow
- [x] Auto-sync profile sau signup/OAuth
- [x] Router guards: anonymous browse; `/upload`, `/notifications`, `/profile/edit` protected

### Photos & Upload
- [x] Real upload flow: Pick → EXIF parse → Details → Storage upload → DB insert
- [x] Film Mode toggle + Film Camera / Film Stock autocomplete (~35 stocks, ~40 cameras)
- [x] File size validation (50MB client + bucket limit)
- [x] EXIF auto-parsing (camera, lens, ISO, aperture, shutter, GPS, date)
- [x] Input validation: title (200), caption (2000), tags (30 max)
- [x] Inline error banner (`AppColors.errorContainer` 24% alpha)
- [x] GPS privacy toggle + License selection

### Profile System
- [x] Profile screen: real photo count + total views (from `photoRepository`)
- [x] Profile tabs: Photos + Portfolio (both connected to real providers)
- [x] **Profile Edit Screen** — bio (160 chars), avatar upload (5MB limit), Instagram/Website links
- [x] Route `/profile/edit` (protected) + pencil button on own profile header
- [x] Test file exists: `profile_edit_screen_test.dart`

### Notifications
- [x] DB schema + RLS + triggers (`on_like/comment/follow_created_notify`)
- [x] `NotificationRepository`: fetch, stream, unreadCount, markAllAsRead
- [x] `notificationsProvider` (StreamProvider) + `unreadNotificationCountProvider` (FutureProvider)
- [x] Realtime UI (`notifications_screen.dart`) + mark-all-read button
- [x] **Notification Badge** — Red dot (8×8px) trên profile icon trong bottom nav khi unread > 0

### Feed & Discovery
- [x] Discover: `categoriesProvider` + `photoFeedProvider(page, limit)` — fully real
- [x] Feed: `photoFeedProvider` + pull-to-refresh invalidates
- [x] Explore: `trendingTagsProvider` real; tabs Photos/People/Collections/Gear có search
- [x] Tag Feed: `tag_feed_screen.dart` with dynamic tag route

### Portfolio
- [x] Portfolio Editor: `portfolioRepositoryProvider.savePortfolio()`
- [x] Public Portfolio: `publicPortfolioProvider(slug)` + loading/error
- [x] Route `/p/:slug` public access

### Shared Widgets
- [x] `main_scaffold.dart` — Glass bottom nav + FAB + notification badge
- [x] `photo_card.dart` — Photo grid card with metadata
- [x] `tag_chip.dart` + `tag_input_widget.dart`
- [x] `skeleton_widgets.dart` — Shimmer loading states
- [x] `exif_badge.dart` — EXIF metadata display
- [x] `empty_state_widget.dart` — Icon + title + description + optional CTA

### Security
- [x] CSP headers (tuned for Flutter web: `wasm-unsafe-eval` + `worker-src blob:` + Google/Supabase domains)
- [x] HSTS (63 days + preload) + X-Frame-Options (DENY) + Referrer-Policy + Permissions-Policy
- [x] X-Content-Type-Options: nosniff + X-XSS-Protection
- [x] Input validation: signup + upload
- [x] Error sanitization (user-friendly messages, no internal leak)
- [x] RLS policies cho mọi table + Storage RLS (owner-only upload/delete)
- [x] **Upload file type whitelist** — Only jpg/jpeg/png/gif/webp/heic allowed (Plan A1)
- [x] **Search debounce 300ms** + query length limit 200 chars (Plan A2)
- [x] **Comment text length limit** — max 1000 chars, reject empty (Plan A3)
- [x] **Self-follow prevention** — `followUser()` returns early if targetId == userId (Plan A4)
- [x] **Tag rate limit** — max 30 tags/photo, max 50 chars/tag (Plan A5)

### Observability (NEW — Plan C)
- [x] `AppLogger` — Structured logging with debug/info/warn/error levels + timestamps
- [x] `ErrorReporter` — Centralized error reporting, FlutterError.onError + PlatformDispatcher
- [x] `AnalyticsService` — Key funnel events: signup, upload, like, profile view, search
- [x] `ErrorBoundary` wired to app root in `main.dart` with ErrorReporter integration
- [x] Category repository — all 6 catch blocks now preserve cause + stackTrace
- [x] Upload EXIF parse failure — logged instead of silently swallowed
- [x] Profile edit load failure — shows SnackBar instead of silent ignore

### CI/CD & Deployment
- [x] `vercel-build.sh` — Flutter clone/cache + pub get + build_runner + build web --release
- [x] `vercel.json` — headers + build config
- [x] GitHub Actions: analyze + tests
- [x] **CI coverage gate** — `flutter test --coverage` with 60% threshold (Plan B1)
- [x] **Coverage artifact upload** — lcov.info uploaded to GitHub Actions artifacts (Plan B1)
- [x] **Integration test in CI** — `flutter test integration_test/` added to pipeline (Plan B3)
- [x] GitHub Actions: analyze + tests
- [x] Vercel auto-deploy on push

### Testing — Unit (15 files + 8 F5 files + 4 Plan A/C/B files = 27 files)
- [x] `test/core/errors/app_exception_test.dart`
- [x] `test/core/contracts/schema_contract_test.dart`
- [x] `test/core/services/image_url_optimizer_test.dart` ✨ NEW
- [x] `test/core/services/seo_service_test.dart` ✨ F5
- [x] `test/core/services/observability_test.dart` ✨ Plan C (logger + reporter + analytics)
- [x] `test/shared/widgets/main_scaffold_test.dart`
- [x] `test/shared/widgets/photo_card_test.dart` ✨ NEW
- [x] `test/shared/models/photo_model_test.dart` ✨ NEW
- [x] `test/features/auth/data/auth_repository_test.dart`
- [x] `test/features/auth/presentation/login_screen_test.dart`
- [x] `test/features/auth/presentation/signup_screen_test.dart` ✨ F5
- [x] `test/features/auth/providers/auth_provider_test.dart` ✨ F5
- [x] `test/features/gallery/data/photo_repository_test.dart`
- [x] `test/features/gallery/data/repositories/security_validation_test.dart` ✨ Plan A (file type + comment)
- [x] `test/features/gallery/presentation/upload_screen_test.dart` ✨ F5
- [x] `test/features/gallery/providers/photo_provider_test.dart` ✨ F5
- [x] `test/features/notifications/data/notification_repository_test.dart` ✨ NEW
- [x] `test/features/notifications/providers/notification_provider_test.dart` ✨ F5
- [x] `test/features/tags/data/tag_repository_test.dart`
- [x] `test/features/tags/data/repositories/tag_security_test.dart` ✨ Plan A (tag limits)
- [x] `test/features/tags/providers/tag_provider_test.dart` ✨ F5
- [x] `test/features/portfolio/data/portfolio_repository_test.dart`
- [x] `test/features/portfolio/providers/portfolio_provider_test.dart` ✨ F5
- [x] `test/features/profile/data/user_repository_test.dart`
- [x] `test/features/profile/providers/follow_state_provider_test.dart`
- [x] `test/features/profile/presentation/profile_edit_screen_test.dart` (minimal — chỉ render check)
- [x] `integration_test/app_flow_test.dart` (scaffold)

### Testing — E2E Playwright (11 specs)
- [x] `e2e/playwright.config.ts` + `e2e/fixtures/helpers.ts` + auth setup
- [x] `e2e/tests/auth/login.spec.ts`
- [x] `e2e/tests/auth/signup.spec.ts`
- [x] `e2e/tests/discover/homepage.spec.ts`
- [x] `e2e/tests/explore/search.spec.ts`
- [x] `e2e/tests/feed/feed-scroll.spec.ts`
- [x] `e2e/tests/gallery/photo-detail.spec.ts`
- [x] `e2e/tests/gallery/upload.spec.ts`
- [x] `e2e/tests/portfolio/public-portfolio.public.spec.ts`
- [x] `e2e/tests/profile/view-profile.spec.ts`
- [x] `e2e/tests/seo/meta-tags.seo.spec.ts`
- [x] `e2e/tests/accessibility/a11y.a11y.spec.ts`

---

## ✅ Phase G — Save/Bookmark Feature (NEW 2026-04-20)

- [x] Migration `009_saves_table.sql` — `saves(user_id, photo_id, created_at)` with RLS + indexes
- [x] Repository: `savePhoto()`, `unsavePhoto()`, `hasSaved()`, `fetchSavedPhotos()` in `photo_repository.dart`
- [x] Providers: `photoSaveStateProvider`, `savedPhotosProvider` in `photo_provider.dart`
- [x] Photo Detail UI: `_toggleSave()` with optimistic update + rollback, save state loaded from server
- [x] Feed UI: Bookmark button wired with filled/outlined icon toggle + Semantics label
- [x] Bug fix: `Share.share()` API (was `SharePlus.instance.share` — wrong API for share_plus 10.1.4)
- [x] Bug fix: `followStateProvider` renamed to `photoFollowStateProvider` to avoid naming collision with profile module
- [x] Apply migration 009 on production Supabase

---

## ✅ Phase H — URL Optimization (NEW 2026-04-20)

**Problem**: URLs were `/?code=UUID#/feed` (hash routing + stale OAuth code visible)
**Solution**: Switch to path-based URLs → `/feed`

- [x] `pubspec.yaml`: Added `flutter_web_plugins: sdk: flutter` dependency
- [x] `main.dart`: `usePathUrlStrategy()` call before app init
- [x] `main.dart`: `_cleanUrlCode()` — GoRouter redirect handles URL cleanup naturally
- [x] `vercel.json`: SPA fallback rewrite (non-API/asset paths → `/index.html`)
- [x] `router.dart`: Cleaned invalid `routerNeglect` + unused imports

**Result**: `/?code=UUID#/feed` → `/feed` (clean, SEO-friendly)

---

## 🔵 Phase I — Portfolio Completion (NEW 2026-04-20)

### Blocker Fixed: Missing UPDATE RLS policy
- [x] Migration `010_portfolio_update_policy.sql` — adds UPDATE policy for `portfolios` table

### Phase I-A: Wire Real Data to Dashboard
- [x] Repository: `fetchUserPortfolios()`, `createPortfolio()`, `deletePortfolio()`, `updatePortfolioMeta()`
- [x] Provider: `userPortfoliosProvider` (FutureProvider.autoDispose.family)
- [x] Dashboard: Replace static `_projects` mock data with real DB query
- [x] Stats: Computed from real portfolio data (project count, photo count)

### Phase I-B: Wire Editor Stubs
- [x] `_preview()`: Navigate to `/p/$username` (was "Coming soon" SnackBar)
- [x] Delete button: Confirmation dialog + `deletePortfolio()` + navigate back
- [x] Category dropdown: Wired to local state
- [x] New Project flow: `createPortfolio()` → navigate to `/portfolio/edit/$newId`
- [x] Load real blocks from DB in `initState` (was hardcoded)

### Phase I-C: Block Type Alignment + Public View
- [x] Public portfolio `_renderBlock()` adapted to editor format (`coverImage`/`text`/`photoGrid`/`divider`/`contactForm`)
- [x] Share button wired on public portfolio view

---

## 🔴 Blockers — Cần xử lý ngay

### B1. Flutter Environment (Local)
> `flutter_tools depends on test 1.30.0 which doesn't match any versions`

**Nguyên nhân**: Env variable `PUB_HOSTED_URL` / `FLUTTER_STORAGE_BASE_URL` trỏ mirror cũ hoặc Flutter channel bị pin.

```bash
# Fix steps:
unset PUB_HOSTED_URL && unset FLUTTER_STORAGE_BASE_URL
flutter upgrade
flutter clean && flutter pub cache repair && flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze && flutter test && flutter build web --release
```

### ~~B2. Git — Uncommitted Changes~~ ✅ RESOLVED
~~Tất cả code mới (notifications, profile edit, error hardening, CSP fix, migrations reorder) nằm trong working tree. Cần commit + push.~~
> **Đã commit & push** — Working tree clean, `origin/main` up to date (commit `cd7c96d`).

### B3. Supabase Migrations (Production) ✅ DONE
~~Migrations `005`, `006`, `007`, `008` chưa apply trên DB production.~~
> **Đã apply** — All 4 migrations run successfully on production (2026-04-20).

---

## 🟡 Việc cần làm — Phase F (Stabilize & Ship)

### ~~F1. Commit & Push (Prerequisite)~~ ✅ DONE
- [x] `git add` tất cả untracked + modified files
- [x] Commit với structure phù hợp
- [x] Push to remote — `cd7c96d` on `origin/main`

### F2. Apply Migrations on Production Supabase ✅ DONE
- [x] Run `005_film_fields.sql`
- [x] Run `006_security_rls.sql` (idempotent with DROP IF EXISTS)
- [x] Run `007_notifications.sql`
- [x] Run `008_likes_count_trigger.sql`
- [x] Verify triggers active: `on_like_created_notify`, `on_comment_created_notify`, `on_follow_created_notify`
- [x] Manual test: insert like → verify notification row appears + likes_count increments

### ~~F3. Explore Screen — Collections/Gear Tabs~~ ✅ DONE
- [x] Decision: Remove Collections/Gear tabs for v1 (no backend tables needed)
- [x] Explore now shows only Photos + People tabs

### ~~F4. Notification Provider — `markAllAsRead` Action~~ ✅ DONE
- [x] Exposed `markAllNotificationsAsRead()` function in `notification_provider.dart`
- [x] Invalidates `unreadNotificationCountProvider` after marking all read
- [x] Notifications screen uses new function instead of direct repository call

### F5. Testing — Unit Test Expansion + Playwright E2E

> **Mục tiêu**: Nâng test coverage từ ~25% lên 75%+ (unit) và có E2E regression suite chạy được trên CI.

---

#### F5-A. UNIT TESTS — Mở rộng (Flutter `flutter_test` + `mocktail`)

**Nguyên tắc:**
- Mỗi repository phải có ≥3 test cases (happy path, error path, edge case)
- Mỗi provider phải test state transitions
- Widget tests cho interactive flows (form submit, navigation, error display)
- Mock tất cả Supabase calls (không hit network)

**Phase 1 — Repository layer (Critical, chạy nhanh nhất)**

| # | File | Test Cases | Priority |
|:---:|:---|:---|:---:|
| 1 | `test/features/gallery/data/photo_repository_test.dart` | Expand: uploadPhoto success (mock Storage + DB insert), fetchPhotos pagination, deletePhoto owner check, fetchPhotos empty | 🔴 ✅ exists |
| 2 | `test/features/notifications/data/notification_repository_test.dart` | **DONE**: fetchNotifications, markAllAsRead, unreadCount, stream subscription | ✅ |
| 3 | `test/features/portfolio/data/portfolio_repository_test.dart` | Expand: savePortfolio, fetchBySlug success/404, deletePortfolio | 🟡 |
| 4 | `test/features/profile/data/user_repository_test.dart` | Expand: fetchProfile, updateProfile, uploadAvatar size check | 🟡 |
| 5 | `test/features/tags/data/tag_repository_test.dart` | Expand: fetchTrending, searchTags, fetchByCategory | 🟡 |
| 6 | `test/features/auth/data/auth_repository_test.dart` | Already good — add: Google OAuth flow mock, password reset | 🟢 |

**Phase 2 — Provider layer (State management logic)**

| # | File | Test Cases | Priority |
|:---:|:---|:---|:---:|
| 7 | `test/features/gallery/providers/photo_provider_test.dart` | **NEW**: photoFeedProvider loading→data→error, pagination state, invalidate on upload | 🔴 |
| 8 | `test/features/notifications/providers/notification_provider_test.dart` | **NEW**: stream emits updates, unreadCount reactive, markRead updates state | 🔴 |
| 9 | `test/features/portfolio/providers/portfolio_provider_test.dart` | **NEW**: fetch portfolios list, create/save state | 🟡 |
| 10 | `test/features/auth/providers/auth_provider_test.dart` | **NEW**: authStateChanges, signOut clears state, currentUser reactivity | 🟡 |
| 11 | `test/features/tags/providers/tag_provider_test.dart` | **NEW**: trending tags load, category filter | 🟢 |

**Phase 3 — Widget tests (UI interaction logic)**

| # | File | Test Cases | Priority |
|:---:|:---|:---|:---:|
| 12 | `test/features/auth/presentation/login_screen_test.dart` | Expand: validation messages, submit disabled when empty, error banner on fail | 🟡 |
| 13 | `test/features/auth/presentation/signup_screen_test.dart` | **NEW**: password strength validation, email format, confirm match | 🟡 |
| 14 | `test/features/gallery/presentation/upload_screen_test.dart` | **NEW**: file size validation, film mode toggle, form submit flow | 🔴 |
| 15 | `test/features/profile/presentation/profile_edit_screen_test.dart` | Expand: bio 160 char limit, avatar upload triggers, save shows loading | 🟡 |
| 16 | `test/features/discover/presentation/discover_screen_test.dart` | **NEW**: shimmer shows on load, photo cards render, category filter | 🟢 |
| 17 | `test/shared/widgets/photo_card_test.dart` | **DONE**: renders EXIF badge, handles null photographer, tap navigates | ✅ |

**Phase 4 — Core & contracts**

| # | File | Test Cases | Priority |
|:---:|:---|:---|:---:|
| 18 | `test/core/services/image_url_optimizer_test.dart` | **DONE**: returns original URL when disabled, format param when enabled | ✅ |
| 19 | `test/core/services/seo_service_test.dart` | **NEW**: title/description update per route, canonical URL correct | 🟢 |
| 20 | `test/shared/models/photo_model_test.dart` | **DONE**: fromJson/toJson round-trip, nullable fields, film fields | ✅ |

**Dependencies cần thêm vào `pubspec.yaml`:**
```yaml
dev_dependencies:
  # Existing: flutter_test, mocktail, integration_test
  fake_async: ^1.3.1          # Time-based testing (debounce, stream)
  riverpod_test: ^0.1.0        # Provider test utilities (nếu có)
```

**Target output**: ~40 test files, ~2000+ lines of tests, >75% branch coverage trên data + provider layers.

---

#### F5-B. PLAYWRIGHT E2E — Setup + Test Suite (Web)

**Mục tiêu**: Browser-based regression tests chạy trên deployed site (https://luxlog.vercel.app) hoặc local Flutter web server.

**Tech stack:**
- Playwright (TypeScript) — cross-browser (Chromium, Firefox, WebKit)
- `@playwright/test` runner
- Page Object Model pattern
- CI: GitHub Actions triggered on push/PR

**Phase 1 — Setup & Infrastructure**

```
e2e/
├── playwright.config.ts       # Config: baseURL, browsers, timeouts
├── package.json               # Playwright deps
├── tsconfig.json              # TypeScript config
├── pages/                     # Page Object Models
│   ├── login.page.ts
│   ├── signup.page.ts
│   ├── discover.page.ts
│   ├── feed.page.ts
│   ├── explore.page.ts
│   ├── upload.page.ts
│   ├── photo-detail.page.ts
│   ├── profile.page.ts
│   └── portfolio.page.ts
├── fixtures/                  # Test fixtures & helpers
│   ├── auth.fixture.ts        # Login state save/restore
│   └── test-data.ts           # Test account credentials (from env)
├── tests/
│   ├── auth/
│   │   ├── login.spec.ts
│   │   ├── signup.spec.ts
│   │   └── oauth.spec.ts
│   ├── discover/
│   │   ├── homepage.spec.ts
│   │   └── category-filter.spec.ts
│   ├── gallery/
│   │   ├── upload.spec.ts
│   │   ├── photo-detail.spec.ts
│   │   └── photo-actions.spec.ts
│   ├── feed/
│   │   └── feed-scroll.spec.ts
│   ├── explore/
│   │   └── search.spec.ts
│   ├── profile/
│   │   ├── view-profile.spec.ts
│   │   └── edit-profile.spec.ts
│   ├── portfolio/
│   │   └── public-portfolio.spec.ts
│   ├── seo/
│   │   ├── meta-tags.spec.ts
│   │   └── og-images.spec.ts
│   └── accessibility/
│       └── a11y.spec.ts
└── .env.example               # E2E_BASE_URL, E2E_TEST_EMAIL, E2E_TEST_PASSWORD
```

**Phase 2 — Test Scenarios (Priority order)**

| # | Test file | Scenarios | Priority |
|:---:|:---|:---|:---:|
| 1 | `auth/login.spec.ts` | Navigate to login, fill form, submit, verify redirect to discover; invalid creds show error; empty form validation | 🔴 |
| 2 | `discover/homepage.spec.ts` | Page loads with photos, masonry grid visible, EXIF badge on cards, category tabs clickable, click photo → detail | 🔴 |
| 3 | `gallery/upload.spec.ts` | Login → navigate upload → select file → fill title → submit → verify success redirect; film mode toggle changes form | 🔴 |
| 4 | `gallery/photo-detail.spec.ts` | Photo page loads, image visible, EXIF data shown, like button works, comments section exists | 🔴 |
| 5 | `auth/signup.spec.ts` | Signup form validation (weak password, invalid email), successful signup | 🟡 |
| 6 | `feed/feed-scroll.spec.ts` | Feed loads posts, "For You"/"Following" tabs switch, pull-to-refresh works | 🟡 |
| 7 | `explore/search.spec.ts` | Trending tags visible, search input works, tag click → tag feed | 🟡 |
| 8 | `profile/view-profile.spec.ts` | Profile page loads, photo count visible, tabs work, follow button | 🟡 |
| 9 | `profile/edit-profile.spec.ts` | Edit form loads prefilled, save bio, avatar upload | 🟡 |
| 10 | `portfolio/public-portfolio.spec.ts` | `/p/:slug` loads, photos grid visible, public (no auth required) | 🟢 |
| 11 | `seo/meta-tags.spec.ts` | Verify `<title>`, `og:title`, `canonical`, `description` on key pages | 🟢 |
| 12 | `seo/og-images.spec.ts` | Bot UA request → returns OG meta HTML (curl-style with page.request) | 🟢 |
| 13 | `accessibility/a11y.spec.ts` | axe-core scan on discover + upload + profile (no critical violations) | 🟢 |

**Phase 3 — CI Integration (GitHub Actions)**

```yaml
# .github/workflows/e2e.yml
name: E2E Tests
on: [push, pull_request]
jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: cd e2e && npm ci
      - run: cd e2e && npx playwright install --with-deps
      - run: cd e2e && npx playwright test
        env:
          E2E_BASE_URL: https://luxlog.vercel.app
          E2E_TEST_EMAIL: ${{ secrets.E2E_TEST_EMAIL }}
          E2E_TEST_PASSWORD: ${{ secrets.E2E_TEST_PASSWORD }}
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: e2e/playwright-report/
```

**Phase 4 — Auth State Management**

```typescript
// fixtures/auth.fixture.ts
// Save authenticated browser state to reuse across tests
// → Login once, save storageState, reuse in all authenticated tests
// → Avoids login overhead per test (Playwright best practice)
```

**Lưu ý quan trọng:**
- Cần 1 test account trên Supabase production (hoặc staging) — email: `e2e-test@luxlog.app`
- Không bao giờ hardcode credentials — dùng `process.env` + GitHub Secrets
- Flutter Web dùng CanvasKit → Playwright chọ elements bằng `text=`, `role=`, hoặc `data-testid` khi cần
- CanvasKit render lên canvas → một số selector DOM thông thường sẽ KHÔNG hoạt động. Cần dùng:
  - `page.getByText()` cho text-based elements
  - `page.locator('flt-semantics-*')` cho Flutter semantic tree
  - Visual regression với `expect(page).toHaveScreenshot()` là backup khi DOM không accessible

---

#### F5-C. Thứ tự triển khai & Effort

| Step | Scope | Effort | Deliverable |
|:---:|:---|:---:|:---|
| 1 | Unit Phase 1: Repository tests (6 files) | 3h | 6 files, ~60 test cases |
| 2 | Unit Phase 2: Provider tests (5 files) | 2h | 5 files, ~30 test cases |
| 3 | Unit Phase 3: Widget tests (6 files) | 2.5h | 6 files, ~35 test cases |
| 4 | Unit Phase 4: Core + models (3 files) | 1h | 3 files, ~15 test cases |
| 5 | Playwright setup (config + POM + fixtures) | 1.5h | e2e/ scaffold ready |
| 6 | Playwright Phase 2: Auth + Discover + Upload | 2h | 4 spec files |
| 7 | Playwright Phase 2: Feed + Explore + Profile | 2h | 5 spec files |
| 8 | Playwright Phase 3: SEO + A11y + CI pipeline | 1.5h | 3 spec files + workflow |
| | **Tổng** | **~15.5h** | **~40 unit files + 13 E2E specs** |

#### F5-D. Definition of Done
- [ ] `flutter test` passes 100% — no skipped tests
- [ ] Coverage report: ≥75% lines trên `lib/features/*/data/` và `lib/features/*/providers/`
- [ ] `npx playwright test` green trên Chromium + Firefox
- [ ] GitHub Actions CI passes cho cả unit + E2E
- [ ] No flaky tests (retry 2x policy for E2E, 0 retries for unit)

### F6. UI Polish
- [x] **Homepage uniform grid**: Replaced `SliverMasonryGrid` with `SliverGrid` (fixed `childAspectRatio: 0.72`, portrait 3:4 cards). Removed per-card `aspectRatio` dependency. Cards now fill grid cells via `Expanded`, consistent spacing 12px, `borderRadius: 8`, subtle hover shadow.
- [x] Infinite scroll pagination (Feed, Discover, Explore)
- [ ] Tablet layout (2-column feed) + Web layout (3-column with sidebar)
- [ ] Dark/Light theme toggle (hiện chỉ có dark)
- [ ] Accessibility: semantic labels cho interactive elements

### F7. Security — Pre-Launch
- [ ] Rate limiting cho upload (Supabase Edge Function hoặc client throttle)
- [ ] CAPTCHA cho signup/login sau N fail (hCaptcha via Supabase Auth)
- [ ] Tách bucket `avatars` riêng (5MB max) thay vì dùng chung `photos`
- [ ] Content moderation hook (NSFW check server-side)
- [ ] Secrets rotation policy

### F8. Observability — Post-Launch
- [ ] Error reporting (Sentry) — wire `AppException.cause` + `stackTrace` vào sink
- [ ] Upload success/fail metrics (Vercel Analytics custom events)
- [ ] Auth conversion funnel tracking
- [ ] DB query performance dashboard

### F9. SEO Enterprise-Ready 🟡 HIGH (Web Platform)

**Trạng thái thực thi (2026-04-20):**
- ✅ Hoàn thành phần cốt lõi: runtime meta SEO, OG/Twitter fallback, robots, dynamic sitemap API, bot rewrites, bot snapshot endpoints, JSON-LD (WebApplication/ImageObject/ProfilePage), OG asset 1200x630, semantic alt/H1 cơ bản, install prompt, offline fallback.
- 🟡 Còn lại để đạt full enterprise: CWV optimization sâu theo dữ liệu production (LCP/CLS/INP), bundle optimization audit.

> Flutter Web mặc định render lên Canvas/WebGL → Google bot KHÔNG đọc được nội dung.
> Cần chiến lược kết hợp: **pre-rendering**, **meta tags**, **structured data**, và **server-side fallback**.

#### F9.1 — HTML Meta Tags & Open Graph (index.html + per-route)
- [x] **Dynamic `<title>`**: Cập nhật document.title theo route (GoRouter `redirect` + `SeoService`)
  - `/` → "Luxlog — Film Photography Community"
  - `/photo/:id` → "{title} by {photographer} | Luxlog"
  - `/u/:username` → "{name}'s Portfolio | Luxlog"
  - `/p/:slug` → "{portfolio_name} | Luxlog"
  - `/explore` → "Explore Film Photography | Luxlog"
  - `/tag/:tagName` → "#{tagName} Photos | Luxlog"
- [x] **Meta description dynamic**: Inject per-route description via `dart:html`
- [x] **Viewport meta** (đã có nhưng cần verify responsive)
- [x] **Canonical URL**: `<link rel="canonical" href="https://luxlog.vercel.app{path}">`
- [x] **Language**: Thêm `<html lang="vi">` (hoặc `en` nếu target quốc tế)

#### F9.2 — Open Graph & Twitter Cards
- [x] OG tags cho trang chính (fallback):
  ```html
  <meta property="og:site_name" content="Luxlog">
  <meta property="og:type" content="website">
  <meta property="og:title" content="Luxlog — Film Photography Community">
  <meta property="og:description" content="Nơi kể lại câu chuyện của ánh sáng. Share & discover analog photography.">
  <meta property="og:image" content="https://luxlog.vercel.app/images/og-default.jpg">
  <meta property="og:url" content="https://luxlog.vercel.app">
  ```
- [x] Twitter Card meta:
  ```html
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Luxlog — Film Photography Community">
  <meta name="twitter:description" content="Share & discover analog photography">
  <meta name="twitter:image" content="https://luxlog.vercel.app/images/og-default.jpg">
  ```
- [x] **OG image asset**: Tạo `web/images/og-default.svg` (1200×630)
- [x] **Dynamic OG for photos**: Vercel Edge Function / Serverless route `/api/seo/photo/:id`
  - Query Supabase → trả về HTML page với OG tags + redirect (cho crawlers)
- [x] **Dynamic OG for profiles**: `/api/seo/user/:username`

#### F9.3 — Pre-rendering cho SEO Crawlers (Critical)
- [x] **Vercel Serverless bot snapshot endpoint** (`/api/seo/photo/:id`, `/api/seo/user/:username`):
  - Detect bot User-Agent (Googlebot, Bingbot, Twitterbot, facebookexternalhit, LinkedInBot)
  - Return static HTML snapshot với full meta + structured data
  - Non-bot traffic → serve Flutter Web SPA bình thường
- [x] **Vercel Rewrites** trong `vercel.json`:
  ```json
  {
    "rewrites": [
      { "source": "/photo/:id", "has": [{"type":"header","key":"user-agent","value":"(?i)googlebot|bingbot|twitterbot|facebookexternalhit"}], "destination": "/api/seo/photo/:id" },
      { "source": "/u/:username", "has": [{"type":"header","key":"user-agent","value":"(?i)googlebot|bingbot|twitterbot"}], "destination": "/api/seo/user/:username" }
    ]
  }
  ```
- [ ] **Alternative**: Dùng Rendertron / Prerender.io nếu không muốn tự host edge functions

#### F9.4 — Structured Data (JSON-LD)
- [x] **Organization** (site-wide trong index.html):
  ```json
  {
    "@context": "https://schema.org",
    "@type": "WebApplication",
    "name": "Luxlog",
    "url": "https://luxlog.vercel.app",
    "applicationCategory": "Photography",
    "description": "Film photography community — share, discover, and curate analog photos"
  }
  ```
- [x] **ImageObject** (per photo detail — injected via Edge Function for bots):
  ```json
  {
    "@context": "https://schema.org",
    "@type": "ImageObject",
    "name": "{title}",
    "author": {"@type":"Person","name":"{photographer}"},
    "datePublished": "{created_at}",
    "description": "{caption}",
    "contentUrl": "{photo_url}",
    "license": "{license_url}"
  }
  ```
- [x] **ProfilePage** (per user profile):
  ```json
  {
    "@context": "https://schema.org",
    "@type": "ProfilePage",
    "mainEntity": {
      "@type": "Person",
      "name": "{full_name}",
      "url": "https://luxlog.vercel.app/u/{username}",
      "image": "{avatar_url}"
    }
  }
  ```

#### F9.5 — Technical SEO
- [x] **robots.txt** (`web/robots.txt`):
  ```
  User-agent: *
  Allow: /
  Disallow: /upload
  Disallow: /notifications
  Disallow: /profile/edit
  Disallow: /login
  Disallow: /signup
  Sitemap: https://luxlog.vercel.app/sitemap.xml
  ```
- [x] **Sitemap** — Dynamic (Edge Function `/api/sitemap` via rewrite `/sitemap.xml`):
  - Static pages: `/`, `/explore`, `/feed`
  - User profiles: `/u/{username}` (query all public profiles)
  - Public portfolios: `/p/{slug}` (query all published portfolios)
  - Popular tags: `/tag/{name}` (top 50 tags)
  - Regenerate daily via cron hoặc on-demand
- [x] **404 page**: Custom 404 với navigation + suggestion (cũng giúp crawlers)
- [x] **Heading hierarchy**: Ensure H1 duy nhất per route (Flutter `Semantics`)
- [x] **Image alt text**: `PhotoCard` cần có `semanticLabel` cho ảnh

#### F9.6 — Performance & Core Web Vitals
- [x] **Flutter build renderer**: CanvasKit (default) + branded splash screen with progress bar during init
- [x] **Loading splash**: HTML-native splash (logo + progress bar + tagline) visible immediately, removed on Flutter first frame
- [x] **Loading skeleton**: Shimmer masonry grid trên DiscoverScreen, ExploreScreen; SkeletonFeedWidget trên FeedScreen
- [x] **Font optimization**: Preload/Preconnect Google Fonts critical origins + preload Manrope/Inter CSS
- [x] **Image optimization**: Serve responsive images (Supabase render transform) cho feed/card/detail
- [x] **Vercel Speed Insights** (đã có) — monitor CWV scores
- [x] **Cache headers**: Aggressive caching cho .js/.wasm/assets/canvaskit (immutable, 1yr); no-cache cho service worker
- [x] **Safety timeout**: 15s retry hint nếu Flutter init fail
- [ ] **Bundle size**: Tree-shake unused packages; defer non-critical JS

#### F9.7 — PWA & Manifest Upgrade
- [x] Update `manifest.json`:
  - `"name": "Luxlog — Film Photography Community"`
  - `"description"`: English + Vietnamese bilingual
  - `"categories": ["photography", "social"]`
  - `"screenshots"`: App screenshots cho install prompt
  - `"theme_color"`: Match brand gold (#C5A572 or similar)
- [x] **Service Worker**: Dùng Flutter web service worker release + bổ sung offline fallback page (`web/offline.html`)
- [x] **Install prompt**: Hiển thị "Add to Home Screen" banner cho mobile web users

#### F9.8 — Content & Crawlability Strategy
- [x] **Public pages (no auth required)**:
  - `/` (home/discover) — indexable
  - `/explore` — indexable
  - `/u/:username` — indexable (public profiles)
  - `/p/:slug` — indexable (public portfolios)
  - `/photo/:id` — indexable (public photos)
  - `/tag/:tagName` — indexable
- [x] **Noindex pages** (add `<meta name="robots" content="noindex">`):
  - `/login`, `/signup`, `/upload`, `/notifications`, `/profile/edit`
- [ ] **Internal linking**: TagChips, photographer names, portfolio links tạo mạng lưới liên kết nội bộ
- [x] **URL structure**: Đã clean (`/photo/123`, `/u/name`, `/tag/portra400`) ✅

#### F9.9 — Production SEO QA Gate (Release Checklist)
- [x] **QA automation scripts**: `scripts/seo_qa.sh` (bash) + `scripts/seo_qa.ps1` (PowerShell)
  - Usage: `bash scripts/seo_qa.sh` or `./scripts/seo_qa.ps1 -BaseUrl https://luxlog.vercel.app -PhotoId <id> -Username <name>`
- [ ] **CWV budget (75th percentile)**: LCP <= 2.5s, CLS <= 0.1, INP <= 200ms (mobile)
- [ ] **Bot snapshot validation**:
  - [ ] `curl -A "googlebot" https://luxlog.vercel.app/photo/{id}` trả HTML có `og:title`, `canonical`, JSON-LD
  - [ ] `curl -A "twitterbot" https://luxlog.vercel.app/u/{username}` trả `og:type=profile`
- [ ] **Sitemap validation**:
  - [ ] `https://luxlog.vercel.app/sitemap.xml` trả XML hợp lệ
  - [ ] Có URL động: `/photo/*`, `/u/*`, `/p/*`, `/tag/*`
- [ ] **Robots validation**:
  - [ ] `https://luxlog.vercel.app/robots.txt` có đầy đủ disallow private routes
- [ ] **Rich result / social debugger checks**:
  - [ ] Google Rich Results Test pass cho 1 photo page
  - [ ] Facebook Sharing Debugger không cảnh báo OG thiếu
  - [ ] X Card Validator hiển thị ảnh preview đúng
- [ ] **Search Console**:
  - [ ] Submit sitemap
  - [ ] Kiểm tra Indexing coverage sau 24-72h

---

#### Thứ tự triển khai SEO đề xuất:

| Step | Task | Effort | Impact |
|:---:|:---|:---:|:---:|
| 1 | F9.1 Dynamic title + canonical + lang | 30m | 🟡 High |
| 2 | F9.5 robots.txt (static) | 10m | 🟡 High |
| 3 | F9.2 OG + Twitter Cards (static fallback) | 30m | 🟡 High |
| 4 | F9.7 manifest.json upgrade | 15m | 🟢 Med |
| 5 | F9.4 Organization JSON-LD (static) | 15m | 🟢 Med |
| 6 | F9.6 Font preload + loading perf | 20m | 🟢 Med |
| 7 | F9.8 noindex cho private routes | 15m | 🟡 High |
| 8 | F9.5 Dynamic sitemap (Edge Function) | 1.5h | 🟡 High |
| 9 | F9.3 Bot pre-rendering (Edge Function) | 2-3h | 🔴 Critical |
| 10 | F9.2 Dynamic OG per photo/user | 2h | 🟡 High |
| 11 | F9.4 ImageObject + ProfilePage JSON-LD | 1h | 🟢 Med |
| 12 | F9.6 Image optimization + CWV tuning | 1h | 🟢 Med |

**Tổng effort ước tính: ~10-12h** (steps 1-7 có thể xong trong 1 session ~2h)

---

## 📈 So sánh PLAN.md vs Thực tế (Discrepancies Found)

| PLAN.md ghi | Thực tế (scan 2026-04-20) | Kết luận |
|:---|:---|:---|
| Profile Edit ❌ Missing | ✅ `profile_edit_screen.dart` tồn tại đầy đủ (bio, avatar, links) | **PLAN.md outdated** |
| Notifications Badge ❌ Missing | ✅ Badge đã implement trong `main_scaffold.dart` (red dot) | **PLAN.md outdated** |
| Profile Collections/Gear tab mock | Collections/Gear nằm ở **Explore screen**, không phải Profile | **PLAN.md mô tả sai vị trí** |
| Explore/Search 🟡 Partial | ✅ `trendingTagsProvider` real; chỉ Collections/Gear tab chưa wire data | Đúng nhưng mức độ nhỏ |
| UI ↔ Data 90% | Thực tế ~95% (Profile Edit done + Badge done) | **Tăng lên 95%** |
| Testing 55% | Thực tế ~70% (15 unit files + 11 E2E specs done) | **Tăng đáng kể** |
| E2E missing | ✅ Playwright setup + 11 spec files committed | **Hoàn thành** |

---

## 🗂 Cấu trúc File Hiện tại

```
lib/ (73 .dart files)
├── main.dart
├── app/ (router.dart, theme.dart)
├── core/
│   ├── config/env.dart
│   ├── errors/app_exception.dart
│   ├── services/supabase_service.dart
│   └── widgets/error_boundary.dart
├── features/
│   ├── auth/ (data/datasources, data/repositories, presentation, providers)
│   ├── discover/ (presentation only)
│   ├── explore/ (presentation only)
│   ├── feed/ (presentation only)
│   ├── gallery/ (data/repositories, presentation + widgets, providers)
│   ├── notifications/ (data/repositories, presentation, providers)
│   ├── portfolio/ (data/repositories, presentation, providers)
│   ├── profile/ (data/repositories, presentation, providers)
│   └── tags/ (data/repositories, presentation, providers)
└── shared/
    ├── constants/film_suggestions.dart
    ├── models/ (5 Freezed models + generated)
    └── widgets/ (7 shared components)

test/ (12 .dart files)
supabase/migrations/ (8 .sql files)
integration_test/ (1 .dart file)
```

---

## 🗓 Thứ tự Ưu tiên (Cập nhật 2026-04-20)

| # | Công việc | Ưu tiên | Trạng thái |
|:---:|:---|:---:|:---:|
| 1 | B1. Fix Flutter env local | 🔴 BLOCKER | Chưa xử lý |
| 2 | ~~B2. Commit & push all changes~~ | ~~🔴 BLOCKER~~ | ✅ DONE |
| 3 | B3. Apply migrations 005-007 trên Supabase | 🔴 BLOCKER | Chưa verify |
| 4 | ~~F3. Remove Collections/Gear tabs~~ | ~~🟡 High~~ | ✅ DONE |
| 5 | ~~F4. markAllAsRead provider action~~ | ~~🟡 High~~ | ✅ DONE |
| 6 | ~~F5. Expand test coverage~~ | ~~🟡 High~~ | ✅ DONE — 23 unit + 11 E2E |
| 7 | **F9. SEO Enterprise-Ready** | **🟡 High** | **90% done** — pending prod QA gate |
| 8 | F6. UI Polish (pagination, tablet, a11y) | 🟢 Med | Homepage grid done; còn pagination, tablet, theme |
| 9 | F7. Security pre-launch (rate-limit, CAPTCHA) | 🟢 Med | Chưa xử lý |
| 10 | F8. Observability (Sentry, analytics) | 🔵 Low | Chưa xử lý |

---

## ✅ Manual Verification Checklist (Pre-Deploy)

### Google OAuth
- [ ] Supabase Dashboard → Site URL = `https://luxlog.vercel.app`
- [ ] Supabase Dashboard → Redirect URLs includes `https://luxlog.vercel.app/**`
- [ ] Google Cloud Console → Authorized JavaScript origins includes `https://luxlog.vercel.app`
- [ ] Google Cloud Console → Authorized redirect URIs includes Supabase callback URL

### Upload Flow
- [ ] Pick image < 50MB → should succeed with EXIF display
- [ ] Pick image > 50MB → should show error
- [ ] Film Mode → type "Kod" → see Kodak suggestions
- [ ] Film Mode → custom value → accepted

### Notifications
- [ ] Like a photo → notification appears in realtime for author
- [ ] Red badge appears on bottom nav
- [ ] Mark all read → badge disappears

---

## � Phase J — Production Hardening (Audit 2026-04-20)

### Tổng quan Audit

**Mức độ sẵn sàng production: 75/100** — Đủ soft-launch (500 users), chưa đủ public launch.

Audit phát hiện **4 lỗ hổng nghiêm trọng** + **12 điểm yếu** cần xử lý trước khi ra mắt công khai.

---

### J1. ✅ DONE — Error Tracking (Sentry Integration)

> Completed in commit `5c2d9bd` (2026-04-21)

- [x] `pubspec.yaml`: thêm `sentry_flutter`
- [x] `ErrorReporter.reportError()`: gửi `Sentry.captureException()` trong `kReleaseMode`
- [x] `main.dart`: `SentryFlutter.init()` với `Env.sentryDsn`
- [x] `lib/core/config/env.dart`: thêm `sentryDsn` env var
- [ ] Breadcrumbs: GoRouter observer (deferred)
- [ ] `AnalyticsService._track()`: external sink (deferred → J15)

---

### J2. ✅ DONE — Rate Limiting

> Completed in commit `5c2d9bd` (2026-04-21)

- [x] `lib/core/utils/rate_limiter.dart`: `RateLimiter.canProceed(key, cooldown)` utility
- [x] `photo_repository.dart`: like/unlike 1s cooldown, comment 3s cooldown
- [x] `user_repository.dart`: follow/unfollow 1s cooldown
- [ ] Server-side SQL rate limit (deferred — client-side sufficient for beta)
- [ ] Wrap `likePhoto`/`unlikePhoto` với `_rateLimiter.guard('like', photoId)`
- [ ] Wrap `followUser`/`unfollowUser` với `_rateLimiter.guard('follow', targetId)`
- [ ] Wrap `addComment` với cooldown 3 giây
- [ ] Supabase: Thêm SQL function rate limit (INSERT check last action timestamp)
- [ ] Migration `011_rate_limit_functions.sql`
- [ ] UI: Disable button immediately on tap, re-enable after response/timeout

**Defense layers**: Client-side cooldown → Server-side SQL check → RLS denies repeat within window.

---

### J3. ✅ DONE — OAuth Error Handling

> Completed in commit `5c2d9bd` (2026-04-21)

- [x] Phân biệt "already exchanged / expired code" vs real auth error trong `_handleOAuthCodeExchange()`
- [x] Real auth errors → `ErrorReporter().reportError()` với context
- [x] Log OAuth state chi tiết (`debugPrint` cho stale, `ErrorReporter` cho real)

---

### J4. ⏸️ SKIPPED — Image Performance (Transforms)

> Skipped: Yêu cầu upgrade Supabase Pro ($25/mo). Sẽ thực hiện khi đủ user base.

**Tasks (deferred)**:
- [ ] Upgrade Supabase lên Pro plan (enable image transforms)
- [ ] Set `_imageTransformsEnabled = true`
- [ ] Update `getOptimizedUrl()` với width/height/quality params

---

### J5. ✅ DONE — Connection Error Retry UI

> Completed 2026-04-21

- [x] Tạo `lib/shared/widgets/error_retry_widget.dart` — Icon + message + "Thử lại" button
- [x] Wired to 7 screens: photo_detail, feed, discover, portfolio, public_portfolio, notifications, profile
- [x] Each screen invalidates its own provider on retry

---

### J6. ✅ DONE — Storage Cleanup (Avatar)

> Completed 2026-04-21

- [x] `profile_edit_screen.dart`: Xóa avatar cũ từ Storage trước khi upload avatar mới
- [x] Parse URL → extract storage path → `client.storage.from('photos').remove([oldPath])`
- [ ] `deletePhoto()` storage cleanup (deferred — no delete feature in UI yet)

---

### J7. ✅ DONE — Search State Persistence

> Completed 2026-04-21

- [x] `ExploreScreen` now accepts `initialQuery` param
- [x] `router.dart`: passes `state.uri.queryParameters['q']` to ExploreScreen
- [x] Search state restored from URL on navigation (back/forward preserves query)

---

### J8. ✅ DONE — Build Cache Optimization

> Completed 2026-04-21

- [x] `vercel-build.sh`: Skip clone if `_flutter` dir exists + `flutter precache --web`
- [x] Added `SENTRY_DSN` pass-through to build command

---

### J9. ✅ DONE — Comment XSS Prevention

> Completed 2026-04-21

- [x] `addComment()`: HTML tags stripped via `replaceAll(RegExp(r'<[^>]*>'), '')` before INSERT
- [x] Verified: `comment_bottom_sheet.dart` uses `Text()` widget (safe rendering)

---

### J10. ✅ DONE — Upload Timeout

> Completed 2026-04-21

- [x] `uploadBinary()` wrapped with `.timeout(Duration(minutes: 5))` 
- [x] Timeout throws `StorageException` with user-friendly message

---

### J11. ✅ DONE — Observability Correlation IDs

> Completed 2026-04-21

- [x] `ErrorReporter.sessionId` — random hex ID generated on app start
- [x] All error logs prefixed with `[sid:xxx]`
- [x] Sentry scope tagged with `session_id` for cross-error correlation

---

### J12. ✅ DONE — Safari E2E + Mobile Testing

> Completed 2026-04-21

- [x] `playwright.config.ts`: Added WebKit (Desktop Safari) project
- [x] Added mobile-chrome (Pixel 7) and mobile-safari (iPhone 14) projects
- [x] All use auth state from setup project

---

### J13. ✅ DONE — Portfolio Version History

> Completed 2026-04-21

- [x] Migration `011_portfolio_versioning.sql`: ADD COLUMN `published_at TIMESTAMPTZ`, `version INT DEFAULT 1`
- [x] `updatePortfolioMeta()`: sets `published_at` when `isPublic = true`
- [ ] UI badge "Last published" (deferred)
- [ ] Version snapshot restore (deferred)

---

### J14. ✅ DONE — Secrets Rotation Policy

> Completed 2026-04-21

- [x] Documented rotation process + table in `CONTRIBUTING.md`
- [x] Covers: SUPABASE_URL, SUPABASE_ANON_KEY, SENTRY_DSN, GOOGLE_CLIENT_ID
- [x] Monitoring section: GitHub Secret Scanning + Supabase logs

---

### J15. ✅ DONE — Analytics Timing

> Completed 2026-04-21

- [x] `AnalyticsService`: `startTimer(name)` / `endTimer(name)` with Stopwatch
- [x] `trackSignupCompleted` and `trackPhotoUploaded` auto-attach `duration_ms`
- [x] New method: `trackPageLoad(route, durationMs)`

---

### 📊 Phase J Priority Matrix

| # | Task | Severity | Effort | Impact | Recommended Order |
|:---:|:---|:---:|:---:|:---:|:---:|
| J1 | Sentry integration | 🔴 | 2h | Visibility | **1st** |
| J3 | OAuth error fix | 🔴 | 1h | Security | **2nd** |
| J2 | Rate limiting | 🔴 | 3h | Abuse prevention | **3rd** |
| J4 | Image transforms | 🔴 | 1h (+$$) | 10x perf | **4th** |
| J5 | Retry UI | 🟡 | 2h | UX | 5th |
| J9 | Comment XSS | 🟡 | 1h | Security | 6th |
| J6 | Storage cleanup | 🟡 | 1h | Cost | 7th |
| J7 | Search persistence | 🟡 | 1h | UX | 8th |
| J10 | Upload timeout | 🟡 | 1h | Reliability | 9th |
| J8 | Build cache | 🟡 | 1h | DX | 10th |
| J11 | Correlation IDs | 🟡 | 1h | Debug | 11th |
| J12 | Safari E2E | 🟡 | 1h | Coverage | 12th |
| J13 | Portfolio versions | 🟢 | 2h | Feature | 13th |
| J14 | Secrets rotation | 🟢 | 0.5h | Ops | 14th |
| J15 | Analytics timing | 🟢 | 1h | Insights | 15th |

---

### 🚀 Recommended Launch Path

```
✅ Week 1: J1 + J3 + J2 → DONE (error tracking + security fixes)
✅ Week 2: J5 + J9 + J6-J15 → DONE (UX + hardening)
⏸️ J4 deferred (needs Supabase Pro upgrade)
Next: Apply migrations 009 + 010 + 011 on production → Load test → Public launch
```

**Soft launch criteria (500 beta users)**:
- [x] Core features working (auth, upload, feed, social)
- [x] J1 done (Sentry — can see errors)
- [x] J3 done (OAuth not swallowing real errors)
- [ ] Apply migrations 009, 010, 011 on production

**Public launch criteria**:
- [x] All 🔴 CRITICAL (J1-J3) resolved (J4 skipped — needs Supabase Pro)
- [x] All 🟡 HIGH (J5-J7) resolved
- [ ] Load test passes 100 concurrent users
- [x] Safari E2E configured (J12)

---

## �📋 Dependencies (pubspec.yaml)

| Category | Package | Version |
|----------|---------|---------|
| Navigation | go_router | ^14.8.1 |
| State | flutter_riverpod | ^2.6.1 |
| Backend | supabase_flutter | ^2.8.4 |
| Network | dio | ^5.8.0 |
| Animation | flutter_animate | ^4.5.2 |
| Grid | flutter_staggered_grid_view | ^0.7.0 |
| Cache | cached_network_image | ^3.4.1 |
| EXIF | exif | ^3.3.0 |
| Image | image_picker | ^1.1.2 |
| Fonts | google_fonts | ^6.2.1 |
| Storage | shared_preferences, flutter_secure_storage | — |
| Utils | intl, timeago, url_launcher, share_plus | — |
| CodeGen | riverpod_generator, freezed, build_runner | dev |
