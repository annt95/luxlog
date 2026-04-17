# Luxlog — Enterprise-Ready Implementation Plan

> Bản kế hoạch toàn diện nhằm nâng cấp Luxlog từ giai đoạn MVP Frontend lên chuẩn **Enterprise-Ready**, bao gồm hệ thống xác thực người dùng đầy đủ, kiến trúc Clean Architecture, và bộ kiểm thử chuyên nghiệp.
>
> **Cập nhật lần cuối:** 2026-04-17 — E1+E2 done, fixing Vercel build errors.

---

## 📊 Rà soát Hiện trạng (Feature Audit)

| Module | Trạng thái | Ghi chú |
|:---|:---:|:---|
| **Discover Feed** | 🟡 UI + Mock | UI hoàn thiện. Dùng `_mockPhotos`. Cần wire `ref.watch(photoFeedProvider)` |
| **Social Feed** | 🟡 UI + Mock | Tabs For You / Following hoạt động. `_MockPost` hardcoded |
| **Photo Detail** | 🟡 UI + Mock | EXIF, tag chips, zoom, share. Mock EXIF data |
| **Upload** | 🟡 UI + Stub | UI form hoàn thiện. Web-compatible (XFile/Uint8List). `uploadPhoto()` repo placeholder |
| **Portfolio Editor** | 🟡 UI Only | JSON block builder. Repo `savePortfolio()` sẵn sàng nhưng chưa kết nối |
| **Public Portfolio** | 🟡 UI Only | Read-only renderer. Repo `fetchPublicPortfolio()` sẵn sàng |
| **Profile** | 🟡 UI + Mock | Follow/Unfollow optimistic. Repo sẵn sàng, chưa wire |
| **Explore/Search** | 🟡 UI + Mock | `_mockTrendingTags`. Categories từ DB nhưng phần khác dùng mock |
| **Tags & Categories** | ✅ Done | DB Schema + Real Repos + Riverpod Providers + UI. Fully operational |
| **Notifications** | 🟡 Skeleton | UI skeleton. Không có backend logic |
| **Bottom Nav** | ✅ Done | Redesigned: 4 tabs đối xứng + FAB trung tâm |
| **Auth (Login)** | ✅ Wired | UI glassmorphism + `authRepositoryProvider.signIn()` + Google/Facebook OAuth |
| **Auth (Register)** | ✅ Wired | UI form wired to `authRepositoryProvider.signUp()` với error handling |
| **Auth (Social Login)** | ✅ Wired | `signInWithGoogle()` / `signInWithFacebook()` connected in login_screen |
| **Auth State Management** | ✅ Done | `authStateProvider` (Stream) + `currentUserProvider` trong Riverpod |
| **Auth Repository** | ✅ Done | signUp, signIn, OAuth, signOut, resetPassword — real Supabase |
| **Auth Remote Datasource** | ✅ Done | Auto-sync user profile sau đăng ký / OAuth |
| **Router Guards** | ✅ Done | Anonymous browsing allowed; only `/upload`, `/notifications` require login |
| **Database Layer** | ✅ Done | SQL migrations + 7 repositories kết nối Supabase |
| **Repository Layer** | ✅ Done | Photo, Portfolio, User, Tag, Category, Auth, AuthRemote |
| **Error Handling** | ✅ Done | Sealed `AppException` hierarchy + `ErrorBoundary` widget |
| **Environment Config** | ✅ Done | `Env` class đọc `--dart-define`, không hardcode |
| **Supabase Service** | ✅ Done | `SupabaseService.initialize()` + config check |
| **Shared Models** | ✅ Done | Freezed: UserModel, PhotoModel, PortfolioModel, TagModel, CategoryModel |
| **Vercel Build** | 🟡 Fixing | build_runner codegen added; fixing dart:io web compat |
| **Unit Tests** | 🟡 Partial | ~14 tests: auth repo, exceptions, follow state, login, scaffold, smoke |
| **E2E Tests** | 🟡 Partial | 1 integration test: Feed → Follow → Comment → Profile |
| **CI/CD** | ✅ Done | Vercel auto-deploy on push + Vercel Analytics/Speed Insights |

---

## 📈 Tổng quan Tiến độ

| Khu vực | Hoàn thành | Ghi chú |
|:---|:---:|:---|
| Core Infrastructure | **100%** | Env, Supabase, Errors, Models |
| Data Layer (Repositories) | **90%** | Chỉ thiếu `uploadPhoto()` file upload |
| Auth System | **95%** | ✅ UI wired, guards active, social OAuth connected |
| Frontend UI | **95%** | Tất cả màn hình polished với animations |
| UI ↔ Data Wiring | **85%** | ✅ All screens wired to Supabase providers; mock data as fallback |
| Router Guards | **100%** | ✅ Anonymous browsing; /upload + /notifications protected |
| Vercel Build | **80%** | build_runner added; fixing web compat issues |
| Testing | **35%** | ~14 tests. Cần mở rộng cho repos + features |

---

## 🔧 Phase E: Wiring & Remaining Work (Ưu tiên hiện tại)

> Các Phase A–D đã hoàn thành phần lớn. Phase E tập trung **kết nối UI với Data Layer** đã có sẵn.

### E1. Wire Auth UI → Repository ✅ DONE
- `signup_screen.dart` → ConsumerStatefulWidget, wired to `authRepositoryProvider.signUp()`
- `login_screen.dart` → ConsumerStatefulWidget, wired signIn + Google + Facebook + forgotPassword

### E2. Activate Auth Guards ✅ DONE
- `router.dart` → Anonymous browsing allowed; only `/upload` and `/notifications` require login
- Logged-in users at `/login` redirect to `/`

### E3. Wire Feature Screens → Repositories ✅ DONE
**Created providers:**
- `lib/features/gallery/providers/photo_provider.dart` — photoRepositoryProvider, photoFeedProvider, photoDetailProvider
- `lib/features/portfolio/providers/portfolio_provider.dart` — portfolioRepositoryProvider, portfolioBlocksProvider, publicPortfolioProvider
- `lib/features/profile/providers/user_provider.dart` — userRepositoryProvider, userProfileProvider

**Wired screens:**
| Screen | Status | Changes |
|:---|:---:|:---|
| Discover Feed | ✅ | ConsumerStatefulWidget, `photoFeedProvider` + `categoriesProvider` for filter chips |
| Social Feed | ✅ | ConsumerStatefulWidget, `photoFeedProvider`, pull-to-refresh invalidates |
| Photo Detail | ✅ | ConsumerStatefulWidget, `photoDetailProvider(photoId)` |
| Profile | ✅ | Added `userProfileProvider` import (already ConsumerStatefulWidget) |
| Portfolio Dashboard | ✅ | ConsumerWidget, `portfolioBlocksProvider(userId)` + `currentUserProvider` |
| Portfolio Editor | ✅ | ConsumerStatefulWidget, save → `portfolioRepositoryProvider.savePortfolio()` |
| Public Portfolio | ✅ | ConsumerWidget, `publicPortfolioProvider(slug)` with loading/error states |
| Explore | ✅ | ConsumerStatefulWidget, `trendingTagsProvider` with fallback to mock |

### E4. Implement Photo Upload (File → Storage → DB)
#### [MODIFY] `lib/features/gallery/data/repositories/photo_repository.dart`
- Hoàn thiện `uploadPhoto()`: pick file → Supabase Storage upload → insert DB row
- Kết nối Upload screen → repository

### E5. Notifications Backend
#### [NEW] Backend logic cho notifications
- Notification model + repository
- Trigger notifications cho: like, comment, follow, tag

---

## 🧪 Phase C: Testing Suite Mở rộng

### Đã có (✅)
- `test/features/auth/data/auth_repository_test.dart` — 3 tests (signUp success/failure, signIn)
- `test/core/errors/app_exception_test.dart` — 6 tests (exception hierarchy + messages)
- `test/features/profile/providers/follow_state_provider_test.dart` — 4 tests
- `test/features/auth/presentation/login_screen_test.dart` — widget tests
- `test/shared/widgets/main_scaffold_test.dart` — bottom nav tests
- `test/widget_test.dart` — smoke test
- `integration_test/app_flow_test.dart` — E2E scaffold

### Cần bổ sung (🟡)
#### [NEW] `test/features/gallery/data/photo_repository_test.dart`
- Test fetch feed pagination
- Test upload flow (mocked Supabase)
- Test like/unlike toggle

#### [NEW] `test/features/portfolio/data/portfolio_repository_test.dart`
- Test fetch/save portfolio
- Test public portfolio slug lookup

#### [NEW] `test/features/tags/data/tag_repository_test.dart`
- Test search, trending, attach tags

#### [MODIFY] `integration_test/app_flow_test.dart`
- Thêm luồng: Login → Feed → Upload → Profile
- Test full auth flow (với mock Supabase)

---

## 🎨 Phase D: UI Polish (Enterprise Quality)

### Đã có (✅)
- [x] Skeleton shimmer loading
- [x] Pull-to-refresh trên Feed và Discover
- [x] Glassmorphism design system
- [x] Responsive layout foundations

### Cần bổ sung (🟡)
- [ ] Empty states cho: Feed trống, Portfolio trống, No results (illustration + CTA)
- [ ] Infinite scroll pagination (kết hợp khi wire repos)
- [ ] Accessibility: semantic labels cho tất cả interactive elements
- [ ] Tablet layout (2-column feed) + Web layout (3-column with sidebar)

---

## 📅 Thứ tự Triển khai (Cập nhật)

| Bước | Công việc | Trạng thái |
|:---:|:---|:---:|
| ~~1~~ | ~~Supabase Init (B1)~~ | ✅ Done |
| ~~2~~ | ~~Auth Backend (A3, A5)~~ — Repo, Provider, Datasource | ✅ Done |
| ~~3~~ | ~~Repositories (B2)~~ — Photo, Portfolio, User, Tag, Category | ✅ Done |
| ~~4~~ | ~~Error Handling (B3)~~ — Global exceptions + boundary | ✅ Done |
| ~~5~~ | ~~Auth UI (A1, A2)~~ — Signup & Login screens | ✅ Done (UI) |
| ~~6~~ | ~~Wire Auth UI (E1, E2)~~ | ✅ Done |
| ~~7~~ | ~~Wire Feature Screens (E3)~~ | ✅ Done |
| **8** | **Fix Analysis Errors** — Resolving errors in Feed & Notifications | 🔴 Next |
| **9** | **Photo Upload (E4)** — File → Storage → DB | 🟡 Next |
| **10** | **Tests Mở rộng (C)** — Repo tests + widget tests | 🟡 In Progress |
| **11** | **UI Polish (D)** — Empty states, Infinite scroll, A11y | 🟡 Partial |
| **12** | **Notifications (E5)** — Backend + real-time | ❌ Not Started |

---

## ⚙️ Cấu hình Cần thiết từ User

> [!IMPORTANT]
> **Để activate Auth (E1, E2), cần cung cấp / xác nhận:**
> 1. ✅ Supabase Project URL — đã cấu hình qua `--dart-define`
> 2. ✅ Supabase Anon Key — đã cấu hình qua `--dart-define`
> 3. 🟡 Google OAuth Client ID (từ Google Cloud Console) — cần cho social login
> 4. 🟡 Facebook App ID (từ Meta Developer Portal) — cần cho social login

---

## ✅ Đã Hoàn thành

### UI & Design
- [x] Redesign Bottom Navigation Bar (Stitch MCP "Obsidian Gold")
- [x] Fix footer lệch — layout đối xứng 2 + FAB + 2
- [x] Ẩn Search & Notification icons trên Discover
- [x] Thêm Profile tab vào bottom nav
- [x] App Icon (AI-generated, saved to assets/)
- [x] Hoàn thiện Phase D UI Polish (Pull-to-refresh, Skeleton loading)
- [x] Glassmorphism Login & Signup screens

### Architecture & Data Layer
- [x] Supabase Service initialization + Env config (không hardcode)
- [x] Sealed AppException hierarchy + ErrorBoundary widget
- [x] Freezed models: User, Photo, Portfolio, Tag, Category
- [x] Auth Repository (signUp, signIn, OAuth, signOut, resetPassword)
- [x] Auth Remote Datasource (profile auto-sync)
- [x] Auth Riverpod Providers (stream + currentUser)
- [x] Photo Repository (fetchFeed, fetchById, like, unlike, comment)
- [x] Portfolio Repository (fetch, save, public slug)
- [x] User Repository (profile, follow, followers, following)
- [x] Tag Repository (search, trending, attach, photos by tag)
- [x] Category Repository (list, suggest, photos by category)

### Tags & Categories (End-to-End)
- [x] SQL migrations (002_tags_categories.sql)
- [x] UI TagChip, TagInputWidget
- [x] Upload / Explore / Discover screens integration
- [x] User đề xuất Category (Pending / Approved status)

### Testing & CI
- [x] Unit Tests: auth repo, exceptions, follow state
- [x] Widget Tests: login screen, main scaffold
- [x] E2E Test scaffold (integration_test/)
- [x] GoRouter routes cho tất cả screens
- [x] Vercel auto-deploy on push
