# Luxlog — Enterprise-Ready Implementation Plan

> Bản kế hoạch toàn diện nhằm nâng cấp Luxlog từ giai đoạn MVP Frontend lên chuẩn **Enterprise-Ready**, bao gồm hệ thống xác thực người dùng đầy đủ, kiến trúc Clean Architecture, và bộ kiểm thử chuyên nghiệp.

---

## 📊 Rà soát Hiện trạng (Feature Audit)

| Module | Trạng thái | Ghi chú |
|:---|:---:|:---|
| **Discover Feed** | ✅ UI Done | Đã ẩn Search/Noti icon. Cần kết nối API |
| **Social Feed** | ✅ UI Done | Tabs For You / Following hoạt động. Mock data |
| **Photo Detail** | ✅ UI Done | EXIF, zoom, share. Mock data |
| **Upload** | ✅ UI Done | Form có sẵn. Chưa kết nối storage |
| **Portfolio Editor** | ✅ UI Done | JSON block builder. Chưa lưu DB |
| **Public Portfolio** | ✅ UI Done | Read-only renderer |
| **Profile** | ✅ UI Done | Follow/Unfollow optimistic. Mock data |
| **Explore/Search** | ✅ UI Done | Tạm rời khỏi bottom nav |
| **Notifications** | ✅ UI Done | Tạm ẩn icon. Skeleton UI |
| **Bottom Nav** | ✅ Fixed | Redesigned: 4 tabs đối xứng + FAB trung tâm |
| **Auth (Login)** | 🟡 UI Only | Có màn hình login. Chưa kết nối backend |
| **Auth (Register)** | ❌ Missing | Chưa có màn hình đăng ký |
| **Auth (Social Login)** | ❌ Missing | Google / Facebook OAuth |
| **Auth State Management** | ❌ Missing | Session, token, auto-refresh |
| **Database Layer** | 🟡 Schema Only | SQL script có sẵn, chưa kết nối |
| **Repository Layer** | ❌ Missing | Không có data fetching thật |
| **Error Handling** | ❌ Missing | Không có global error boundary |
| **Unit Tests** | 🟡 Partial | 1 test file (FollowState). Cần mở rộng |
| **E2E Tests** | 🟡 Partial | 1 integration test scaffold |
| **CI/CD** | ✅ Done | Vercel auto-deploy on push |

---

## 🔐 Phase A: Authentication System (Ưu tiên #1)

### A1. Màn hình Đăng ký (Sign Up)
#### [NEW] `lib/features/auth/presentation/signup_screen.dart`
- Form đăng ký với các trường: Display Name, Email, Password, Confirm Password
- Validation: email format, password strength (≥8 ký tự, chứa số + chữ hoa)
- Nút "Đăng ký bằng Email"
- Divider "hoặc tiếp tục với"
- Social login buttons: Google, Facebook (Apple nếu iOS)
- Link chuyển sang Login Screen

### A2. Nâng cấp Login Screen
#### [MODIFY] `lib/features/auth/presentation/login_screen.dart`
- Thêm nút Social Login (Google, Facebook)
- Thêm link "Quên mật khẩu?" → xử lý Supabase `resetPasswordForEmail()`
- Thêm link chuyển sang Sign Up Screen
- Loading state khi đang xác thực

### A3. Auth Repository & Provider
#### [NEW] `lib/features/auth/data/repositories/auth_repository.dart`
```dart
class AuthRepository {
  final SupabaseClient _client;

  // Email/Password
  Future<AuthResponse> signUp({email, password, displayName});
  Future<AuthResponse> signIn({email, password});

  // Social OAuth
  Future<void> signInWithGoogle();
  Future<void> signInWithFacebook();

  // Session
  Future<void> signOut();
  User? get currentUser;
  Stream<AuthState> get authStateChanges;

  // Password reset
  Future<void> resetPassword(String email);
}
```

#### [NEW] `lib/features/auth/providers/auth_provider.dart`
```dart
// Riverpod providers
@riverpod AuthRepository authRepository(ref);
@riverpod Stream<AuthState> authState(ref);  // stream cho auto-login
@riverpod User? currentUser(ref);
```

### A4. Auth Guard (Route Protection)
#### [MODIFY] `lib/app/router.dart`
- Thêm `redirect` logic: nếu chưa login → redirect `/login`
- Nếu đã login nhưng đang ở `/login` → redirect `/`
- Lắng nghe `authStateChanges` để tự động refresh router

### A5. User Profile Auto-Sync
#### [NEW] `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Sau khi đăng ký thành công, tự động tạo row trong bảng `users` (Supabase trigger hoặc manual insert)
- Đồng bộ `avatar_url`, `display_name` từ OAuth provider

---

## 🏗 Phase B: Enterprise Architecture Layer

### B1. Supabase Client Initialization
#### [NEW] `lib/core/services/supabase_service.dart`
```dart
class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }
  static SupabaseClient get client => Supabase.instance.client;
}
```

### B2. Repository Pattern (Clean Architecture)
#### [NEW] `lib/features/gallery/data/repositories/photo_repository.dart`
- `fetchFeed({tab, page, limit})` → Supabase query with pagination
- `fetchPhotoById(id)` → Single photo + EXIF + comments
- `uploadPhoto({file, title, exif})` → Storage upload + DB insert
- `likePhoto(id)` / `unlikePhoto(id)`
- `addComment(photoId, text)`

#### [NEW] `lib/features/portfolio/data/repositories/portfolio_repository.dart`
- `fetchPortfolio(userId)` → JSON blocks from DB
- `savePortfolio(userId, blocks)` → Upsert JSON
- `fetchPublicPortfolio(slug)` → Public read

#### [NEW] `lib/features/profile/data/repositories/user_repository.dart`
- `fetchProfile(username)` → User data + stats
- `updateProfile({bio, avatar, links})`
- `followUser(targetId)` / `unfollowUser(targetId)`
- `fetchFollowers(userId)` / `fetchFollowing(userId)`

### B3. Global Error Handling
#### [NEW] `lib/core/errors/app_exception.dart`
```dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}
class NetworkException extends AppException { ... }
class AuthException extends AppException { ... }
class StorageException extends AppException { ... }
class ValidationException extends AppException { ... }
```

#### [NEW] `lib/core/widgets/error_boundary.dart`
- Widget wrapper bắt lỗi render
- Hiển thị thông báo lỗi thân thiện (retry button)

### B4. Environment Configuration
#### [NEW] `lib/core/config/env.dart`
- Đọc biến môi trường từ `--dart-define`
- Tách biệt `dev` / `staging` / `production`
- Không hardcode API keys

---

## 🧪 Phase C: Testing Suite Mở rộng

### C1. Unit Tests Bổ sung
#### [NEW] `test/features/auth/providers/auth_provider_test.dart`
- Test auth state changes (logged in / logged out)
- Test sign up validation
- Test social login flow (mocked)

#### [NEW] `test/features/gallery/data/photo_repository_test.dart`
- Test fetch feed pagination
- Test upload flow (mocked Supabase)
- Test like/unlike toggle

#### [NEW] `test/core/errors/app_exception_test.dart`
- Test exception hierarchy
- Test error message formatting

### C2. Widget Tests
#### [NEW] `test/features/auth/presentation/login_screen_test.dart`
- Test form validation UI
- Test social login buttons render
- Test navigation to signup

#### [NEW] `test/shared/widgets/main_scaffold_test.dart`
- Test bottom nav tab switching
- Test FAB renders and taps

### C3. E2E Test Mở rộng
#### [MODIFY] `integration_test/app_flow_test.dart`
- Thêm luồng: Login → Feed → Upload → Profile
- Test full auth flow (với mock Supabase)

---

## 🎨 Phase D: UI Polish (Enterprise Quality)

### D1. Loading States
- Skeleton shimmer cho tất cả danh sách (Feed, Explore, Portfolio)
- Pull-to-refresh trên Feed và Discover
- Infinite scroll pagination

### D2. Empty States
- Thiết kế empty state cho: Feed trống, Portfolio trống, No results
- Illustration + CTA button

### D3. Accessibility
- Semantic labels cho tất cả interactive elements
- Contrast ratio ≥ 4.5:1 (đã đạt theo Stitch design system)
- Screen reader support

### D4. Responsive Layout
- Tablet layout (2-column feed)
- Web layout (3-column with sidebar)
- Safe area handling trên tất cả thiết bị

---

## 📅 Thứ tự Triển khai

| Bước | Công việc | Phụ thuộc |
|:---:|:---|:---|
| 1 | **Supabase Init** (B1) — Cần URL + Key từ User | Chờ User |
| 2 | **Auth System** (A1–A5) — Signup, Login, OAuth, Guards | Bước 1 |
| 3 | **Repositories** (B2) — Photo, Portfolio, User | Bước 1 |
| 4 | **Error Handling** (B3) — Global exceptions | Bước 2 |
| 5 | **Tests** (C1–C3) — Unit + Widget + E2E | Bước 2–3 |
| 6 | **UI Polish** (D1–D4) — Loading, Empty, A11y | Bước 3 |

---

## ⚙️ Cấu hình Cần thiết từ User

> [!IMPORTANT]
> **Để bắt đầu Phase A và B, cần cung cấp:**
> 1. Supabase Project URL
> 2. Supabase Anon Key
> 3. Google OAuth Client ID (từ Google Cloud Console)
> 4. Facebook App ID (từ Meta Developer Portal)

---

## ✅ Đã Hoàn thành (Commit này)

- [x] Redesign Bottom Navigation Bar (Stitch MCP "Obsidian Gold")
- [x] Fix footer lệch — layout đối xứng 2 + FAB + 2
- [x] Ẩn Search & Notification icons trên Discover
- [x] Thêm Profile tab vào bottom nav
- [x] Thêm route `/profile` vào GoRouter
- [x] App Icon (AI-generated, saved to assets/)
- [x] Unit Tests (FollowStateProvider — 4/4 pass)
- [x] E2E Test scaffold (integration_test/)
- [x] Đổi tên toàn bộ vibeshot → luxlog
