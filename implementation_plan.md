# Luxlog — Implementation Progress Tracker

## 📅 Cập nhật lần cuối: 2026-04-21

> Tổng hợp tiến độ triển khai dự án Luxlog dựa trên rà soát toàn bộ mã nguồn thực tế,
> đối chiếu với PLAN.md và WALKTHROUGH.md.

---

## 📊 Tổng quan Tiến độ

| Khu vực | Hoàn thành | Ghi chú |
|:---|:---:|:---|
| Core Infrastructure | **100%** | Env, Supabase, Errors, Models |
| Data Layer (Repositories) | **100%** | 8 repos: Auth, AuthRemote, Photo, Portfolio, User, Tag, Category, Notification |
| Auth System | **100%** | Email + Google OAuth + guards + password reset |
| Frontend UI | **98%** | Tất cả màn hình chính + Profile Edit + Homepage uniform grid |
| UI ↔ Data Wiring | **95%** | Explore còn Collections/Gear tab mock; còn lại đã real |
| Router & Guards | **100%** | 15 routes; protected: upload, notifications, profile/edit |
| Notification System | **100%** | Realtime stream + badge + mark-read + triggers backend |
| Security | **95%** | RLS + headers + validation; còn thiếu rate-limit/CAPTCHA |
| Vercel Deployment | **95%** | Pipeline hoạt động; cần verify env local + final deploy |
| Testing | **60%** | 12 test files; profile-edit test minimal; cần mở rộng |

---

## ✅ Hoàn thành (Đã xác nhận qua code scan 2026-04-20)

### Core & Infrastructure
- [x] Supabase Service init + Env config (`--dart-define`) + fail-fast release
- [x] Sealed `AppException` với `cause` + `stackTrace`
- [x] `ErrorBoundary` widget
- [x] Freezed models: User, Photo, Portfolio, Tag, Category (+ `.freezed.dart` + `.g.dart`)
- [x] 8 Repositories: Auth, AuthRemote, Photo, Portfolio, User, Tag, Category, Notification
- [x] Riverpod providers cho tất cả repos (generated with `riverpod_generator`)
- [x] 8 migrations: `001`→`007` + `consolidated_production.sql`

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

### CI/CD & Deployment
- [x] `vercel-build.sh` — Flutter clone/cache + pub get + build_runner + build web --release
- [x] `vercel.json` — headers + build config
- [x] GitHub Actions: analyze + tests
- [x] Vercel auto-deploy on push

### Testing (12 files)
- [x] `test/core/errors/app_exception_test.dart`
- [x] `test/core/contracts/schema_contract_test.dart`
- [x] `test/shared/widgets/main_scaffold_test.dart`
- [x] `test/features/auth/data/auth_repository_test.dart`
- [x] `test/features/auth/presentation/login_screen_test.dart`
- [x] `test/features/gallery/data/photo_repository_test.dart`
- [x] `test/features/tags/data/tag_repository_test.dart`
- [x] `test/features/portfolio/data/portfolio_repository_test.dart`
- [x] `test/features/profile/data/user_repository_test.dart`
- [x] `test/features/profile/providers/follow_state_provider_test.dart`
- [x] `test/features/profile/presentation/profile_edit_screen_test.dart` (minimal — chỉ render check)
- [x] `integration_test/app_flow_test.dart` (scaffold)

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

### B2. Git — Uncommitted Changes
Tất cả code mới (notifications, profile edit, error hardening, CSP fix, migrations reorder) nằm trong working tree. Cần commit + push.

### B3. Supabase Migrations (Production)
Migrations `005`, `006`, `007` chưa apply trên DB production. Code sẽ fail nếu deploy mà chưa chạy:
- `005_film_fields.sql` — film columns
- `006_security_rls.sql` — RLS policies
- `007_notifications.sql` — notifications table + triggers

---

## 🟡 Việc cần làm — Phase F (Stabilize & Ship)

### F1. Commit & Push (Prerequisite)
- [ ] `git add` tất cả untracked + modified files
- [ ] Commit với structure phù hợp (xem PLAN.md section F1)
- [ ] Push to remote

### F2. Apply Migrations on Production Supabase
- [ ] Run `005_film_fields.sql`
- [ ] Run `006_security_rls.sql`
- [ ] Run `007_notifications.sql`
- [ ] Verify triggers active: `on_like_created_notify`, `on_comment_created_notify`, `on_follow_created_notify`
- [ ] Manual test: insert like → verify notification row appears

### F3. Explore Screen — Collections/Gear Tabs
- [ ] Decide: hide Collections/Gear tabs in v1, or connect to real data
- [ ] Nếu giữ: tạo `collections` table + `user_gear` table + repositories
- [ ] Nếu bỏ: remove 2 tabs từ Explore, chỉ giữ Photos + People

### F4. Notification Provider — `markAllAsRead` Action
- [ ] Expose `markAllAsRead()` as a provider action (hiện chỉ có trong Repository)
- [ ] Invalidate `unreadNotificationCountProvider` after marking all read
- [ ] Verify badge disappears after mark-all-read in Notifications screen

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
| 1 | `test/features/gallery/data/photo_repository_test.dart` | Expand: uploadPhoto success (mock Storage + DB insert), fetchPhotos pagination, deletePhoto owner check, fetchPhotos empty | 🔴 |
| 2 | `test/features/notifications/data/notification_repository_test.dart` | **NEW**: fetchNotifications, markAllAsRead, unreadCount, stream subscription | 🔴 |
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
| 17 | `test/shared/widgets/photo_card_test.dart` | **NEW**: renders EXIF badge, handles null photographer, tap navigates | 🟢 |

**Phase 4 — Core & contracts**

| # | File | Test Cases | Priority |
|:---:|:---|:---|:---:|
| 18 | `test/core/services/image_url_optimizer_test.dart` | **NEW**: returns original URL when disabled, format param when enabled | 🟢 |
| 19 | `test/core/services/seo_service_test.dart` | **NEW**: title/description update per route, canonical URL correct | 🟢 |
| 20 | `test/shared/models/photo_model_test.dart` | **NEW**: fromJson/toJson round-trip, nullable fields, film fields | 🟢 |

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
- [ ] Infinite scroll pagination (Feed, Discover, Explore)
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
| Testing 55% | Thực tế ~60% (thêm profile_edit_screen_test.dart) | **Tăng nhẹ** |

---

## 🗂 Cấu trúc File Hiện tại

```
lib/ (68 .dart files)
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
| 2 | B2. Commit & push all changes | 🔴 BLOCKER | Chưa xử lý |
| 3 | B3. Apply migrations 005-007 trên Supabase | 🔴 BLOCKER | Chưa xử lý |
| 4 | F3. Decide Collections/Gear tabs | 🟡 High | Chưa xử lý |
| 5 | F4. markAllAsRead provider action | 🟡 High | Chưa xử lý |
| 6 | F5. Expand test coverage | 🟡 High | Chưa xử lý |
| 7 | **F9. SEO Enterprise-Ready** | **🟡 High** | **Implemented + hardening done; pending prod QA gate** |
| 8 | F6. UI Polish (pagination, tablet, a11y) | 🟢 Med | Chưa xử lý |
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

## 📋 Dependencies (pubspec.yaml)

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
