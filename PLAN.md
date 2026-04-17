# Luxlog — Enterprise-Ready Implementation Plan

> Bản kế hoạch toàn diện nhằm nâng cấp Luxlog từ giai đoạn MVP Frontend lên chuẩn **Enterprise-Ready**, bao gồm hệ thống xác thực người dùng đầy đủ, kiến trúc Clean Architecture, và bộ kiểm thử chuyên nghiệp.
>
> **Cập nhật lần cuối:** 2026-04-17 — E1→E5 done + security hardening, đang chặn ở verify (môi trường Flutter local hỏng) và 3 phase hoàn thiện (stabilize → polish → ship).

---

## 🚦 Handoff cho session kế tiếp (đọc trước)

### Trạng thái repo hiện tại

- **Code đã commit/chỉnh**: Đã fix white-screen (fallback screen + CSP nới rộng), consolidate migrations (`003→007`), thêm notifications backend + UI realtime, hardening exception, thay mock profile stats, wire profile portfolio tab, thêm error banner inline cho upload.
- **Chưa commit**: Hầu hết thay đổi ở trên đang là working tree modifications (chưa `git commit`). Kiểm tra bằng `git status`.
- **File `lib/features/notifications/data/` và `lib/features/notifications/providers/`**: chưa được track bởi git (untracked). Cần `git add` khi commit.

### Blocker hiện tại (phải xử lý đầu session sau)

> [!CAUTION]
> `flutter analyze` và `flutter build web` đều fail với lỗi:
> ```
> Because flutter_tools depends on test 1.30.0 which doesn't match any versions,
> version solving failed.
> ```
> Đây là **môi trường local bị hỏng**, KHÔNG phải code. Nguyên nhân phổ biến: bị ghi đè `PUB_HOSTED_URL` / `FLUTTER_STORAGE_BASE_URL` bằng mirror không đồng bộ, hoặc Flutter channel bị pin vào phiên bản cũ.

**Các bước verify cần chạy ngay khi mở session mới:**

```bash
# 1. Reset env pub mirror (nếu có)
unset PUB_HOSTED_URL
unset FLUTTER_STORAGE_BASE_URL

# 2. Kiểm tra Flutter version + upgrade nếu cần
flutter --version
flutter upgrade         # hoặc: flutter channel stable && flutter upgrade

# 3. Dọn cache nếu vẫn lỗi pub solve
flutter clean
flutter pub cache repair
flutter pub get

# 4. Regenerate Riverpod/Freezed code (CI cũng đang làm bước này)
dart run build_runner build --delete-conflicting-outputs

# 5. Analyze + build + test
flutter analyze
flutter test
flutter build web --release
```

### Nếu build vẫn trắng sau khi deploy

1. Mở DevTools → Console → chụp log đầu tiên (có thể là CSP block hoặc `late` init error).
2. Kiểm tra `SUPABASE_URL` / `SUPABASE_ANON_KEY` đã được truyền vào build qua `--dart-define` trên Vercel chưa (`vercel-build.sh` + project env vars).
3. Verify bucket `photos` trên Supabase Dashboard đã tạo và có RLS đúng (migration `004_storage_photos_bucket.sql`).

---

## 📊 Rà soát Hiện trạng (Feature Audit)

| Module | Trạng thái | Ghi chú |
|:---|:---:|:---|
| **Discover Feed** | ✅ Wired | `photoFeedProvider` + `categoriesProvider` (mock chỉ làm fallback khi empty) |
| **Social Feed** | ✅ Wired | `photoFeedProvider` + pull-to-refresh invalidates |
| **Photo Detail** | ✅ Wired | `photoDetailProvider(photoId)` |
| **Upload** | ✅ Wired | Real `uploadPhoto()` + Film Mode + validation + inline error banner |
| **Portfolio Editor** | ✅ Wired | `portfolioRepositoryProvider.savePortfolio()` |
| **Public Portfolio** | ✅ Wired | `publicPortfolioProvider(slug)` + loading/error |
| **Profile** | 🟡 Partial | Stats (photos/views) + portfolio tab đã thật; Collections/Gear vẫn hardcode |
| **Profile Edit** | ❌ Missing | `UserRepository.updateProfile()` đã có nhưng KHÔNG có UI |
| **Explore/Search** | 🟡 Partial | `trendingTagsProvider` thật; một số query khác còn mock fallback |
| **Tags & Categories** | ✅ Done | DB + Repo + Providers + UI fully operational |
| **Notifications** | ✅ Wired | Realtime stream + mark-read + triggers backend |
| **Notifications Badge** | ❌ Missing | Chưa có unread dot trên bottom nav |
| **Bottom Nav** | ✅ Done | 4 tabs đối xứng + FAB trung tâm |
| **Auth (Login/Signup/OAuth)** | ✅ Wired | Full email + Google + Facebook + password reset |
| **Auth State** | ✅ Done | `authStateProvider` + `currentUserProvider` |
| **Router Guards** | ✅ Done | Anonymous browse; `/upload` + `/notifications` protected |
| **Database Layer** | ✅ Done | 7 migrations (`001`→`007`) + 8 repositories |
| **Error Handling** | ✅ Done | Sealed `AppException` với `cause` + `stackTrace`, không nuốt lỗi |
| **Environment Config** | ✅ Done | `Env` đọc `--dart-define`, không hardcode |
| **Supabase Service** | ✅ Hardened | Fail-fast release + debug fallback screen + init-error display |
| **Shared Models** | ✅ Done | Freezed: User, Photo, Portfolio, Tag, Category |
| **Security Headers** | ✅ Done | CSP + HSTS + X-Frame-Options (nới `wasm-unsafe-eval` cho Flutter web) |
| **Storage RLS** | ✅ Done | Bucket `photos` + owner-only upload/delete policies |
| **Vercel Build** | 🟡 Blocked locally | Pipeline ổn định; verify bị chặn bởi env Flutter local hỏng |
| **Unit Tests** | 🟡 Partial | ~14 tests repo + widget; thiếu notifications + profile-edit |
| **E2E Tests** | 🟡 Partial | 1 integration test scaffold |
| **CI/CD** | ✅ Done | GitHub Actions analyze+test + Vercel auto-deploy |

---

## 📈 Tổng quan Tiến độ

| Khu vực | Hoàn thành | Ghi chú |
|:---|:---:|:---|
| Core Infrastructure | **100%** | Env, Supabase, Errors, Models |
| Data Layer (Repositories) | **100%** | Upload, auth/profile, notifications, tags/categories đều wired |
| Auth System | **95%** | UI wired, guards active, OAuth connected |
| Frontend UI | **95%** | Tất cả màn hình polished với animations |
| UI ↔ Data Wiring | **90%** | Profile còn 2 tab mock; Explore còn mock fallback |
| Router Guards | **100%** | Anonymous browse; protected routes hoạt động |
| Vercel Build | **95%** | Pipeline xanh; env local đang chặn verify lần cuối |
| Testing | **55%** | Repo + contract tests; cần notifications + profile edit + expanded E2E |
| Security | **90%** | RLS + headers + input validation; cần secrets rotation policy |

---

## 🎯 Phase F — Stabilization & Ship (ƯU TIÊN HIỆN TẠI)

> Tất cả Phase A–E đã gần xong. Phase F tập trung **verify lại, trám nốt UX mock, test coverage, và ship bản stable**.

### F0. Unblock môi trường Flutter local 🔴 CRITICAL
- [ ] Reset env `PUB_HOSTED_URL` / `FLUTTER_STORAGE_BASE_URL`
- [ ] `flutter upgrade` về stable mới
- [ ] `flutter clean && flutter pub cache repair && flutter pub get`
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter analyze` pass (0 errors, warnings cho phép)
- [ ] `flutter test` pass
- [ ] `flutter build web --release` thành công
- [ ] Deploy Vercel và verify không còn trắng trang

### F1. Commit & Push các thay đổi của session trước 🟡 NEXT
**Files modified (chưa commit):**
- `lib/main.dart` — try/catch quanh init + fallback screen truyền error
- `lib/core/errors/app_exception.dart` — thêm `cause` + `stackTrace`
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` — preserve cause
- `lib/features/auth/data/repositories/auth_repository.dart` — preserve cause
- `lib/features/gallery/data/repositories/photo_repository.dart` — preserve cause + `fetchByUser` + `countByUser` + `totalViewsByUser`
- `lib/features/gallery/presentation/upload_screen.dart` — inline error banner
- `lib/features/notifications/presentation/notifications_screen.dart` — realtime stream + mark-all-read
- `lib/features/portfolio/data/repositories/portfolio_repository.dart` — preserve cause + handle blocks as List|String
- `lib/features/profile/data/repositories/user_repository.dart` — preserve cause
- `lib/features/profile/presentation/profile_screen.dart` — stats thật + portfolio tab thật
- `lib/features/tags/data/repositories/tag_repository.dart` — preserve cause
- `vercel.json` — CSP: `wasm-unsafe-eval` + `worker-src blob:` + gstatic
- `PLAN.md`, `README.md` — cập nhật docs

**Files deleted:**
- `supabase/migrations/003_film_fields.sql` (moved to `005_*`)
- `supabase/migrations/004_security_rls.sql` (moved to `006_*`)

**Files added (chưa track):**
- `lib/features/notifications/data/repositories/notification_repository.dart`
- `lib/features/notifications/providers/notification_provider.dart`
- `supabase/migrations/005_film_fields.sql`
- `supabase/migrations/006_security_rls.sql`
- `supabase/migrations/007_notifications.sql`

**Suggested commit structure:**
```bash
git add supabase/migrations/
git commit -m "chore(db): reorder migrations 003-007; add notifications schema"

git add lib/features/notifications/
git commit -m "feat(E5): notifications backend + realtime stream + mark-read UI"

git add lib/core/errors/app_exception.dart lib/features/**/data/
git commit -m "refactor(errors): preserve cause/stackTrace; stop swallowing exceptions"

git add lib/features/profile/presentation/profile_screen.dart
git commit -m "feat(profile): real photo/view counts + portfolio tab from provider"

git add lib/features/gallery/presentation/upload_screen.dart
git commit -m "feat(upload): render inline error banner on upload failure"

git add lib/main.dart vercel.json
git commit -m "fix(web): prevent white screen via init error fallback + CSP fix"

git add PLAN.md README.md
git commit -m "docs: sync plan and migration docs with current state"
```

### F2. Apply migrations trên Supabase 🟡 REQUIRED TO DEPLOY

> [!IMPORTANT]
> Migrations `005`, `006`, `007` chưa được apply trên DB thật.

- [ ] Chạy `005_film_fields.sql` (thêm cột film_stock/film_camera/is_film/caption/license/allow_download)
- [ ] Chạy `006_security_rls.sql` (RLS policies cho photos/comments/likes/follows/portfolios)
- [ ] Chạy `007_notifications.sql` (table + triggers like/comment/follow)
- [ ] Verify trigger `on_like_created_notify`, `on_comment_created_notify`, `on_follow_created_notify` active
- [ ] Test insert notification thủ công (insert dummy like → check notification row xuất hiện)

### F3. Profile — trám nốt mock còn lại 🟡 UX DEBT
- [ ] `_CollectionsTab` — hoặc xóa đi, hoặc thêm bảng `collections` + repository
- [ ] `_GearTab` — hoặc xóa đi, hoặc thêm bảng `user_gear` (item_type, brand, model) + repository
- [ ] Quyết định: ẩn 2 tab này trong v1, expose lại khi có data model

### F4. Profile Edit Screen — MISSING FEATURE ❌
- [ ] `lib/features/profile/presentation/profile_edit_screen.dart` (mới)
  - Form: bio (max 160), avatar (upload qua `photos` bucket → path `avatars/{userId}/...`), links (JSON)
  - Dùng `UserRepository.updateProfile()` đã sẵn
- [ ] Thêm route `/profile/edit` (protected)
- [ ] Thêm nút bút chì trên `_ProfileHeader` khi `isOwnProfile == true`
- [ ] Test: `test/features/profile/presentation/profile_edit_screen_test.dart`

### F5. Notifications Badge trên Bottom Nav 🟡 POLISH
- [ ] `main_scaffold.dart`: watch `unreadNotificationCountProvider`
- [ ] Hiển thị dot đỏ khi count > 0 (trên icon Bell/Profile tuỳ UX chọn)
- [ ] Invalidate provider sau khi `markAllAsRead()`

### F6. Tests mở rộng 🟡 COVERAGE
**Đã có:**
- `test/features/auth/data/auth_repository_test.dart`
- `test/core/errors/app_exception_test.dart` (cần update vì AppException đã đổi signature với `cause`/`stackTrace`)
- `test/features/profile/providers/follow_state_provider_test.dart`
- `test/features/profile/data/user_repository_test.dart`
- `test/features/gallery/data/photo_repository_test.dart`
- `test/features/portfolio/data/portfolio_repository_test.dart`
- `test/features/tags/data/tag_repository_test.dart`
- `test/features/auth/presentation/login_screen_test.dart`
- `test/shared/widgets/main_scaffold_test.dart`
- `test/core/contracts/schema_contract_test.dart`
- `test/widget_test.dart`
- `integration_test/app_flow_test.dart`

**Cần thêm/update:**
- [ ] [UPDATE] `test/core/errors/app_exception_test.dart` — cover `cause` + `stackTrace` mới
- [ ] [NEW] `test/features/notifications/data/notification_repository_test.dart` — fetch, stream, unreadCount, markAllAsRead
- [ ] [NEW] `test/features/profile/presentation/profile_edit_screen_test.dart` — form validation, submit flow
- [ ] [NEW] `test/features/gallery/data/photo_repository_upload_test.dart` — mock Storage + DB insert happy path + error path
- [ ] [UPDATE] `integration_test/app_flow_test.dart` — Login → Upload → Feed → Notifications flow
- [ ] [NEW] `test/contracts/notifications_contract_test.dart` — schema of `notifications` table

### F7. UI Polish (Phase D còn lại) 🟡 NICE-TO-HAVE
- [ ] Empty states: Feed trống, Portfolio trống, No notifications, No search results (illustration + CTA)
- [ ] Infinite scroll pagination cho Feed, Discover, Explore
- [ ] Accessibility: semantic labels cho mọi interactive element + screen reader test
- [ ] Tablet layout (2-column feed) + Web layout (3-column with sidebar)
- [ ] Dark/Light theme toggle (hiện chỉ có dark)

### F8. Security hardening còn lại 🟡 PRE-LAUNCH
- [ ] Rate limiting cho upload endpoint (Supabase Edge Function hoặc client throttle)
- [ ] CAPTCHA cho signup/login sau N lần fail (Supabase Auth hỗ trợ hCaptcha)
- [ ] Bucket `avatars` riêng với max size 5MB (tránh dùng chung bucket `photos` 20MB)
- [ ] Content moderation hook cho photo upload (server-side NSFW check)
- [ ] Secrets rotation policy document + alert nếu anon key lộ

### F9. Observability 🟡 POST-LAUNCH
- [ ] Error reporting (Sentry hoặc Supabase log) — hiện `cause`+`stackTrace` đã preserve ở exception, cần wire vào sink
- [ ] Upload success/fail metrics (track qua Vercel Analytics custom event)
- [ ] Auth conversion funnel (signup → first upload)
- [ ] DB query performance dashboard (Supabase built-in)

---

## 📅 Thứ tự Triển khai Đề xuất

| # | Công việc | Thời gian | Ưu tiên |
|:---:|:---|:---:|:---:|
| ~~1~~ | ~~Supabase Init (B1)~~ | — | ✅ Done |
| ~~2~~ | ~~Auth Backend (A3, A5)~~ | — | ✅ Done |
| ~~3~~ | ~~Repositories (B2)~~ | — | ✅ Done |
| ~~4~~ | ~~Error Handling (B3)~~ | — | ✅ Done |
| ~~5~~ | ~~Auth UI (A1, A2)~~ | — | ✅ Done |
| ~~6~~ | ~~Wire Auth UI (E1, E2)~~ | — | ✅ Done |
| ~~7~~ | ~~Wire Feature Screens (E3)~~ | — | ✅ Done |
| ~~8~~ | ~~Photo Upload (E4)~~ | — | ✅ Done |
| ~~9~~ | ~~Notifications Backend (E5)~~ | — | ✅ Done |
| **10** | **F0. Unblock Flutter env + verify build** | 30m | 🔴 BLOCKER |
| **11** | **F1. Commit & push toàn bộ thay đổi session trước** | 15m | 🔴 BLOCKER |
| **12** | **F2. Apply migrations 005/006/007 trên Supabase Dashboard** | 10m | 🔴 BLOCKER |
| **13** | **F4. Profile Edit Screen** | 1.5h | 🟡 High |
| **14** | **F5. Notifications Badge** | 30m | 🟡 High |
| **15** | **F6. Tests mở rộng** | 2h | 🟡 High |
| **16** | **F3. Trám mock Collections/Gear tab** | 1h | 🟢 Med |
| **17** | **F7. UI Polish (empty states + pagination + a11y)** | 3h | 🟢 Med |
| **18** | **F8. Security hardening (rate limit + CAPTCHA + avatar bucket)** | 2h | 🟢 Med |
| **19** | **F9. Observability (Sentry + analytics events)** | 2h | 🔵 Low |

**Ước tính tổng thời gian còn lại: ~13h** (nếu làm tuần tự; có thể song song F3/F6/F7).

---

## ⚙️ Cấu hình Cần thiết từ User

> [!IMPORTANT]
> **Trước khi deploy production:**
> 1. ✅ Supabase Project URL — đã cấu hình qua `--dart-define`
> 2. ✅ Supabase Anon Key — đã cấu hình qua `--dart-define`
> 3. 🟡 Google OAuth Client ID — cần cho social login
> 4. 🟡 Facebook App ID — cần cho social login
> 5. 🔴 **Chạy migrations 005→007 trên Supabase Dashboard** — BẮT BUỘC để code mới không vỡ
> 6. 🔴 **Verify bucket `photos` tồn tại + RLS đúng** — BẮT BUỘC cho upload
> 7. 🟡 Google Cloud Console: enable Identity Platform + redirect URL
> 8. 🟡 Meta Developer: verify app domain

---

## 🗂 Danh sách Migrations hiện tại

| # | File | Nội dung |
|:---:|:---|:---|
| 001 | `001_initial.sql` | Schema gốc: users, photos, follows, likes, comments, portfolios, portfolio_projects |
| 002 | `002_tags_categories.sql` | Tags + Categories + photo_tags + photo_categories |
| 003 | `003_schema_hybrid.sql` | Rename `users`→`profiles`, `comments.body`→`comments.text`, add `portfolios.blocks` |
| 004 | `004_storage_photos_bucket.sql` | Bucket `photos` + owner-only RLS |
| 005 | `005_film_fields.sql` | Film metadata columns (is_film, film_stock, film_camera, caption, license, allow_download) |
| 006 | `006_security_rls.sql` | DELETE/INSERT policies còn thiếu cho photos/comments/likes/follows/portfolios/tags |
| 007 | `007_notifications.sql` | Table `notifications` + RLS + triggers like/comment/follow |

---

## ✅ Đã Hoàn thành (Cummulative)

### UI & Design
- [x] Bottom Navigation 4 tabs đối xứng + FAB (Stitch "Obsidian Gold")
- [x] Glassmorphism Login/Signup screens
- [x] App Icon (AI-generated)
- [x] Pull-to-refresh + Skeleton shimmer loading
- [x] Discover/Feed/Explore/Profile/Portfolio screens đã polish

### Architecture & Data Layer
- [x] Supabase Service init + Env config (không hardcode) + fail-fast release
- [x] Sealed AppException với `cause` + `stackTrace` (không nuốt lỗi)
- [x] ErrorBoundary widget
- [x] Freezed models: User, Photo, Portfolio, Tag, Category
- [x] Repositories: Auth, AuthRemote, Photo, Portfolio, User, Tag, Category, Notification
- [x] Riverpod providers cho tất cả repos + auth state + photo feed + photo detail + portfolio + user profile + notifications

### Auth
- [x] Email signup/signin với validation (email regex + password strength)
- [x] Google + Facebook OAuth
- [x] Password reset
- [x] Auto-sync profile sau signup/OAuth
- [x] Router guards (anonymous browse + protected `/upload` + `/notifications`)

### Photos
- [x] Real upload flow: pick → EXIF parse → Storage upload → DB insert
- [x] Film Mode (manual camera + film stock)
- [x] File size validation (20MB limit)
- [x] GPS privacy toggle
- [x] License selection (CC BY 4.0 default)
- [x] Like/unlike + Comment
- [x] Photo detail with EXIF display

### Notifications
- [x] DB schema + RLS + triggers (like/comment/follow)
- [x] Repository with stream + mark-read + unread count
- [x] Realtime UI replacing mock

### Security
- [x] CSP headers (tuned for Flutter web: wasm-unsafe-eval + worker blob)
- [x] HSTS + X-Frame-Options + Referrer-Policy + Permissions-Policy
- [x] Input validation trên signup + upload
- [x] Sanitize error messages (user-friendly, không leak internal)
- [x] RLS policies cho mọi table
- [x] Storage bucket RLS (owner-only upload/delete)

### Testing & CI
- [x] 11 test files (auth, exceptions, follow state, login, scaffold, photo repo, portfolio repo, tag repo, user repo, schema contract, integration)
- [x] GitHub Actions workflow: analyze --fatal-warnings + tests
- [x] Vercel auto-deploy on push + Speed Insights + Analytics
