# E4. Photo Upload + Film Mode & Security Hardening

Kế hoạch triển khai hai mục tiêu song song: hoàn thiện luồng Upload ảnh (bao gồm chế độ "Film Shot") và rà soát bảo mật toàn diện cho Luxlog.

---

## User Review Required

> [!IMPORTANT]
> **Supabase Storage Bucket**: Cần tạo một Storage bucket tên `photos` trên Supabase Dashboard (Settings → Storage) với policy cho phép authenticated users upload. Bạn đã tạo bucket này chưa?

> [!IMPORTANT]
> **Film Photography fields**: Plan đề xuất thêm 2 cột mới vào bảng `photos` (`film_stock TEXT`, `film_camera TEXT`). Điều này yêu cầu chạy migration SQL trên Supabase. Bạn đồng ý không?

> [!WARNING]
> **Security headers**: Hiện tại `vercel.json` không có security headers nào. Plan sẽ thêm CSP, X-Frame-Options, etc. Điều này có thể ảnh hưởng nếu bạn embed site ở nơi khác.

---

## Phần 1: E4 — Implement Photo Upload + Film Mode

### Tổng quan luồng Upload
```mermaid
flowchart LR
    A[Pick Image] --> B[Parse EXIF]
    B --> C{Film Mode?}
    C -->|Yes| D[Manual Input:<br/>Camera + Film Stock]
    C -->|No| E[Auto EXIF Data]
    D --> F[Fill Details:<br/>Title, Caption, Tags, Categories]
    E --> F
    F --> G[Upload to<br/>Supabase Storage]
    G --> H[Get Public URL]
    H --> I[Insert into<br/>photos table]
    I --> J[Attach Tags<br/>& Categories]
    J --> K[Navigate Back<br/>+ Invalidate Feed]
```

---

### 1.1 Database Migration — Film Fields

#### [NEW] `supabase/migrations/003_film_fields.sql`
Thêm cột cho film photography:
```sql
ALTER TABLE public.photos ADD COLUMN film_stock TEXT;
ALTER TABLE public.photos ADD COLUMN film_camera TEXT;
ALTER TABLE public.photos ADD COLUMN is_film BOOLEAN DEFAULT false;
ALTER TABLE public.photos ADD COLUMN caption TEXT;
ALTER TABLE public.photos ADD COLUMN license TEXT DEFAULT 'CC BY 4.0';
ALTER TABLE public.photos ADD COLUMN allow_download BOOLEAN DEFAULT true;
```

---

### 1.2 Update PhotoModel

#### [MODIFY] [photo_model.dart](file:///Users/uyn/Desktop/An/35mm/luxlog/lib/shared/models/photo_model.dart)
Thêm các field mới vào Freezed model:
- `filmStock` (`film_stock`) — Tên cuộn film (VD: "Kodak Portra 400", "Fuji Superia 400")
- `filmCamera` (`film_camera`) — Tên máy film (VD: "Contax G2", "Nikon FM2")
- `isFilm` (`is_film`) — Boolean flag
- `caption` — Mô tả ngắn
- `license` — Loại license
- `allowDownload` (`allow_download`) — Cho phép tải

---

### 1.3 Implement `uploadPhoto()` in Repository

#### [MODIFY] [photo_repository.dart](file:///Users/uyn/Desktop/An/35mm/luxlog/lib/features/gallery/data/repositories/photo_repository.dart)
Thay thế placeholder bằng logic thật:

```dart
Future<String> uploadPhoto({
  required Uint8List fileBytes,
  required String fileName,
  required String title,
  String? caption,
  String? license,
  bool allowDownload = true,
  // EXIF (auto-parsed or manual for film)
  bool isFilm = false,
  String? filmStock,
  String? filmCamera,
  String? camera,
  String? lens,
  int? iso,
  String? aperture,
  String? shutterSpeed,
  double? focalLength,
  double? latitude,
  double? longitude,
  bool shareGps = false,
}) async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) throw const AuthException();
  
  // 1. Upload bytes to Supabase Storage bucket "photos"
  final path = 'uploads/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
  await _client.storage.from('photos').uploadBinary(path, fileBytes, ...);
  
  // 2. Get public URL
  final imageUrl = _client.storage.from('photos').getPublicUrl(path);
  
  // 3. Insert row into photos table
  final response = await _client.from('photos').insert({...}).select().single();
  
  return response['id'];
}
```

**Key decisions:**
- Dùng `uploadBinary()` thay vì `upload()` vì Flutter Web không hỗ trợ `File` (dart:io)
- Storage path format: `uploads/{userId}/{timestamp}_{filename}` → tránh trùng tên
- GPS chỉ lưu khi `shareGps = true` → bảo vệ privacy

---

### 1.4 Add Upload Provider

#### [MODIFY] [photo_provider.dart](file:///Users/uyn/Desktop/An/35mm/luxlog/lib/features/gallery/providers/photo_provider.dart)
Thêm provider wrapper cho upload:
```dart
@riverpod
Future<String> uploadPhoto(UploadPhotoRef ref, {...params}) {
  final repo = ref.watch(photoRepositoryProvider);
  return repo.uploadPhoto(...);
}
```

---

### 1.5 Update Upload Screen — Film Mode UI

#### [MODIFY] [upload_screen.dart](file:///Users/uyn/Desktop/An/35mm/luxlog/lib/features/gallery/presentation/upload_screen.dart)

**Thay đổi chính:**

1. **Convert to `ConsumerStatefulWidget`** — để dùng Riverpod providers
2. **Thêm Film toggle** — Checkbox/Switch "Shot on Film" ngay dưới EXIF section
3. **Film input fields** (hiện khi `_isFilm = true`):
   - `_filmCameraCtrl` — TextField "Film Camera" (VD: "Contax G2")
   - `_filmStockCtrl` — TextField "Film Stock" (VD: "Kodak Portra 400")
   - Hiển thị với animation slide-down khi toggle bật
4. **Wire `_upload()` method** — thay `Future.delayed` bằng logic thật:
   ```dart
   Future<void> _upload() async {
     setState(() => _currentStep = 2);
     try {
       final photoId = await ref.read(photoRepositoryProvider).uploadPhoto(
         fileBytes: _selectedImageBytes!,
         fileName: _selectedImage!.name,
         title: _titleCtrl.text,
         caption: _captionCtrl.text,
         isFilm: _isFilm,
         filmStock: _isFilm ? _filmStockCtrl.text : null,
         filmCamera: _isFilm ? _filmCameraCtrl.text : null,
         // ... EXIF fields from _parsedExif
       );
       // Attach tags & categories
       // Invalidate feed
       ref.invalidate(photoFeedProvider);
       if (mounted) Navigator.of(context).pop();
     } catch (e) {
       // Show error, go back to step 1
     }
   }
   ```
5. **File size validation** — Giới hạn 20MB trước khi upload
6. **Upload progress** — Hiển thị progress indicator (nếu Supabase SDK hỗ trợ)

**UI Mockup cho Film section:**
```
┌─────────────────────────────────────┐
│ ▌ CAMERA DATA (EXIF)                │
│  [No EXIF data found]               │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🎞️  Shot on Film           [✓] │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ▌ FILM DETAILS                      │
│  ┌──────────────────────────────┐   │
│  │ 📷 Film Camera               │   │
│  │ Contax G2                    │   │
│  └──────────────────────────────┘   │
│  ┌──────────────────────────────┐   │
│  │ 🎞️ Film Stock                │   │
│  │ Kodak Portra 400             │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

### 1.6 Update ExifInfo Model

#### [MODIFY] [exif_badge.dart](file:///Users/uyn/Desktop/An/35mm/luxlog/lib/shared/widgets/exif_badge.dart)
Thêm `filmStock` và `filmCamera` vào `ExifInfo` class:
```dart
class ExifInfo {
  // ... existing fields
  final String? filmStock;
  final String? filmCamera;
  final bool isFilm;
}
```

---

## Phần 2: Security Audit & Hardening

### 🔍 Kết quả Rà soát

| Hạng mục | Mức độ | Phát hiện |
|:---|:---:|:---|
| **RLS Policies** | 🟡 Trung bình | Thiếu DELETE policy cho `photos`, `comments`, `likes`. Thiếu INSERT policy cho `comments`, `likes`. `follows` table chưa có RLS policies |
| **Input Validation** | 🔴 Cao | Signup: không validate email format, password strength. Upload: không giới hạn file size. Comment: không sanitize input |
| **Secrets Management** | ✅ Tốt | Sử dụng `--dart-define`, không hardcode |
| **Security Headers** | 🔴 Cao | `vercel.json` không có headers: CSP, X-Frame-Options, HSTS |
| **Debug Logging** | 🟡 Trung bình | `print()` còn trong production code (`supabase_service.dart`) |
| **Error Exposure** | 🟡 Trung bình | `e.toString()` hiển thị raw exception cho user (có thể leak internal info) |
| **Photo DELETE** | 🔴 Cao | Thiếu RLS policy cho DELETE trên photos — user không thể xóa ảnh của mình, nhưng nếu thêm API cũng không có policy bảo vệ |
| **Storage Policies** | 🟡 Chưa rõ | Cần verify bucket `photos` có RLS đúng trên Supabase Dashboard |

---

### 2.1 Fix Missing RLS Policies

#### [NEW] `supabase/migrations/004_security_rls.sql`

```sql
-- Photos: DELETE policy (chỉ owner)
CREATE POLICY "Users can delete own photos" ON public.photos
  FOR DELETE USING (auth.uid() = user_id);

-- Comments: INSERT + DELETE
CREATE POLICY "Authenticated users can comment" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON public.comments
  FOR DELETE USING (auth.uid() = user_id);

-- Likes: INSERT + DELETE
CREATE POLICY "Authenticated users can like" ON public.likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Authenticated users can unlike" ON public.likes
  FOR DELETE USING (auth.uid() = user_id);

-- Comments + Likes: SELECT
CREATE POLICY "Comments viewable by all" ON public.comments
  FOR SELECT USING (true);
CREATE POLICY "Likes viewable by all" ON public.likes
  FOR SELECT USING (true);

-- Follows: full RLS
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Follows viewable by all" ON public.follows
  FOR SELECT USING (true);
CREATE POLICY "Users can follow" ON public.follows
  FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON public.follows
  FOR DELETE USING (auth.uid() = follower_id);

-- Portfolios: SELECT (public), INSERT, UPDATE, DELETE
CREATE POLICY "Public portfolios viewable" ON public.portfolios
  FOR SELECT USING (is_public = true OR auth.uid() = user_id);
CREATE POLICY "Users can create portfolios" ON public.portfolios
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own portfolios" ON public.portfolios
  FOR DELETE USING (auth.uid() = user_id);

-- Portfolio Projects
CREATE POLICY "Portfolio projects viewable" ON public.portfolio_projects
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM public.portfolios
    WHERE id = portfolio_id AND (is_public = true OR user_id = auth.uid())
  ));
CREATE POLICY "Users can manage own projects" ON public.portfolio_projects
  FOR INSERT WITH CHECK (EXISTS (
    SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()
  ));
CREATE POLICY "Users can update own projects" ON public.portfolio_projects
  FOR UPDATE USING (EXISTS (
    SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()
  ));
CREATE POLICY "Users can delete own projects" ON public.portfolio_projects
  FOR DELETE USING (EXISTS (
    SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()
  ));

-- Tags: INSERT (any authenticated user can create tags)
CREATE POLICY "Authenticated users can create tags" ON public.tags
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
```

---

### 2.2 Add Security Headers

#### [MODIFY] [vercel.json](file:///Users/uyn/Desktop/An/35mm/luxlog/vercel.json)

```json
{
  "buildCommand": "./vercel-build.sh",
  "outputDirectory": "build/web",
  "framework": null,
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-XSS-Protection", "value": "1; mode=block" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
        { "key": "Permissions-Policy", "value": "camera=(self), microphone=(), geolocation=(self)" },
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://_vercel/; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: blob: https://*.supabase.co https://picsum.photos https://images.unsplash.com https://i.pravatar.cc; connect-src 'self' https://*.supabase.co wss://*.supabase.co;"
        },
        { "key": "Strict-Transport-Security", "value": "max-age=63072000; includeSubDomains; preload" }
      ]
    }
  ]
}
```

---

### 2.3 Input Validation

#### [MODIFY] [signup_screen.dart](file:///Users/uyn/Desktop/An/35mm/luxlog/lib/features/auth/presentation/signup_screen.dart)
Thêm validation trước khi gọi `signUp()`:
- **Email format**: RegExp check `r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'`
- **Password strength**: Tối thiểu 8 ký tự, ít nhất 1 chữ hoa + 1 số
- **Display name**: Không rỗng, max 50 ký tự

#### [MODIFY] [upload_screen.dart](file:///Users/uyn/Desktop/An/35mm/luxlog/lib/features/gallery/presentation/upload_screen.dart)
- **File size check**: `if (bytes.length > 20 * 1024 * 1024) → show error "Max 20MB"`
- **Title length**: Max 200 ký tự
- **Caption length**: Max 2000 ký tự
- **Tag count**: Max 30 tags

---

### 2.4 Sanitize Error Messages

#### [MODIFY] [login_screen.dart](file:///Users/uyn/Desktop/An/35mm/luxlog/lib/features/auth/presentation/login_screen.dart) & [signup_screen.dart](file:///Users/uyn/Desktop/An/35mm/luxlog/lib/features/auth/presentation/signup_screen.dart)
Thay `e.toString()` bằng user-friendly message:
```dart
} catch (e) {
  final message = e is AppException ? e.message : 'Something went wrong. Please try again.';
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
```

---

### 2.5 Remove Debug Prints

#### [MODIFY] [supabase_service.dart](file:///Users/uyn/Desktop/An/35mm/luxlog/lib/core/services/supabase_service.dart)
Thay `print()` bằng `debugPrint()` (chỉ hiển thị ở debug mode) hoặc xóa hoàn toàn.

---

## Thứ tự Thực hiện

| Bước | Công việc | Ước tính |
|:---:|:---|:---:|
| 1 | Tạo migration `003_film_fields.sql` | 5 phút |
| 2 | Update `PhotoModel` + run `build_runner` | 10 phút |
| 3 | Update `ExifInfo` model (thêm film fields) | 5 phút |
| 4 | Implement `uploadPhoto()` trong `PhotoRepository` | 15 phút |
| 5 | Update `photo_provider.dart` | 5 phút |
| 6 | Update `upload_screen.dart` (Film UI + wire upload) | 25 phút |
| 7 | Tạo migration `004_security_rls.sql` | 10 phút |
| 8 | Update `vercel.json` (security headers) | 5 phút |
| 9 | Add input validation (signup + upload) | 15 phút |
| 10 | Sanitize error messages | 10 phút |
| 11 | Remove debug prints | 2 phút |
| 12 | Build & verify | 10 phút |
| **Tổng** | | **~2 giờ** |

---

## Verification Plan

### Automated
- `flutter build web --release` — Ensure no compilation errors
- `flutter analyze` — No new errors/warnings introduced

### Manual
- [ ] Mở Upload screen → chọn ảnh → EXIF tự parse
- [ ] Toggle "Film" → input fields xuất hiện
- [ ] Nhấn Share → ảnh upload lên Supabase Storage
- [ ] Kiểm tra row mới trong bảng `photos`
- [ ] Verify security headers trên [securityheaders.com](https://securityheaders.com)
- [ ] Test RLS: User A không thể DELETE ảnh User B (via Supabase Dashboard)

---

## Open Questions

> [!IMPORTANT]
> 1. **Storage bucket `photos`** đã được tạo trên Supabase Dashboard chưa? Cần bucket policies cho phép authenticated upload.
> 2. **Film Stock suggestions**: Có muốn tạo một danh sách preset film phổ biến (Portra 400, Tri-X 400, Superia 400...) để autocomplete không? Hay chỉ cần textbox tự do?
> 3. **Max file size**: 20MB có phù hợp không? Ảnh film scan thường lớn (30-50MB TIFF). Nếu cần hỗ trợ TIFF, cần tăng limit.
