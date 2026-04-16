# Luxlog — Photography Platform
> Dựa trên thiết kế **"The Darkroom Editorial"** từ Stitch Project `6660914350535156406`

Xây dựng một nền tảng nhiếp ảnh tích hợp 4 chức năng trong một sản phẩm duy nhất, lấy cảm hứng từ Flickr, Instagram và Behance, với design system tối giản cao cấp — dark mode, vintage gold accent, glassmorphism.

---

## Màn hình thiết kế gốc từ Stitch

| Screen | Loại | Kích thước |
|---|---|---|
| Luxlog Feed - Desktop | 🖥️ Desktop | 2560×4648 |
| Photo Detail - Desktop Web View | 🖥️ Desktop | 2560×2048 |
| Luxlog Feed - Mobile | 📱 Mobile | 780×3538 |
| Photo Detail - Mobile App View | 📱 Mobile | 780×2622 |

---

## 4 Modules chức năng

### 📸 Module 1 — Gallery (Flickr-like)
Nơi đăng ảnh đẹp chất lượng cao, hiển thị đầy đủ EXIF metadata.
- Upload ảnh RAW/JPEG, tự động đọc EXIF (ISO, Aperture, Shutter Speed, Focal Length, Camera, Lens, GPS)
- Hiển thị metadata dạng badge monospace (Space Grotesk font)
- Masonry layout / Grid layout toggle
- Collections & Albums
- Download original / license

### 🌀 Module 2 — Social Feed (Instagram-like)
Mạng xã hội cho cộng đồng yêu nhiếp ảnh.
- Feed ảnh cuộn vô tận (infinite scroll)
- Like, comment, save, share
- Follow / Unfollow photographers
- Stories / Moments (short-lived content)
- Explore / Discover tab
- Notifications

### 🎨 Module 3 — Portfolio Builder (Behance-like)
Công cụ tạo portfolio chuyên nghiệp cho thợ ảnh.
- Tạo project portfolio với cover image
- Drag-and-drop layout editor
- Sections: About, Works, Contact
- Custom domain hỗ trợ
- Analytics: views, likes, saves
- PDF export
- Client inquiry form

### 🖼️ Module 4 — Discover Feed (Curated)
Nơi xem ảnh được chọn lọc chất lượng cao.
- Algorithmic feed + Editor's Pick
- Filter by: Genre, Camera, Lens, Location
- Sort: Trending, Latest, Most Viewed
- Full-screen immersive view
- Mood boards / Collections

---

## Tech Stack

### Frontend — Flutter 3.41+
```
Framework    : Flutter 3.41 (Dart 3.11)
Platform     : Android, iOS, Web (responsive)
State        : Riverpod 2 (code generation)
Navigation   : Go Router 14
Network      : Dio + Retrofit
Image        : cached_network_image + image_picker
Animations   : flutter_animate
Icons        : Material Symbols / lucide_icons
EXIF Parse   : native_exif (mobile) + exif (dart)
Storage local: drift (SQLite)
```

### Backend
```
Runtime      : Node.js (Fastify) hoặc Supabase Edge Functions
Database     : PostgreSQL (Supabase)
Auth         : Supabase Auth (Google, Apple, Email)
Storage      : Supabase Storage (ảnh + video)
EXIF server  : sharp + exifr (Node.js)
Search       : Supabase Full Text Search / Meilisearch
Realtime     : Supabase Realtime (notifications, feed)
```

### Infrastructure
```
Hosting BFF  : Supabase (DB + Auth + Storage + Realtime)
CDN          : Supabase CDN (built-in)
Push Notif   : Firebase Cloud Messaging
Monitoring   : Sentry Flutter SDK
CI/CD        : GitHub Actions + Fastlane
```

---

## Cấu trúc Project Flutter

```
lib/
├── main.dart
├── app/
│   ├── router.dart              ← GoRouter config
│   └── theme.dart               ← Darkroom design tokens
│
├── features/
│   ├── auth/                    ← Login, Register
│   │   ├── presentation/
│   │   ├── data/
│   │   └── domain/
│   │
│   ├── discover/                ← Module 4: Discover Feed
│   │   ├── presentation/
│   │   │   ├── discover_screen.dart
│   │   │   └── widgets/
│   │   ├── data/
│   │   └── domain/
│   │
│   ├── feed/                    ← Module 2: Social Feed
│   │   ├── presentation/
│   │   │   ├── feed_screen.dart
│   │   │   └── widgets/
│   │   ├── data/
│   │   └── domain/
│   │
│   ├── gallery/                 ← Module 1: Gallery + EXIF
│   │   ├── presentation/
│   │   │   ├── photo_detail_screen.dart
│   │   │   ├── upload_screen.dart
│   │   │   ├── gallery_grid_screen.dart
│   │   │   └── widgets/
│   │   │       ├── exif_badge.dart
│   │   │       └── masonry_grid.dart
│   │   ├── data/
│   │   └── domain/
│   │
│   ├── portfolio/               ← Module 3: Portfolio Builder
│   │   ├── presentation/
│   │   │   ├── portfolio_screen.dart
│   │   │   ├── portfolio_editor_screen.dart
│   │   │   └── widgets/
│   │   ├── data/
│   │   └── domain/
│   │
│   ├── profile/                 ← User Profile
│   ├── explore/                 ← Search + Explore
│   └── notifications/           ← Notification center
│
├── shared/
│   ├── widgets/
│   │   ├── app_bar.dart         ← Glassmorphism AppBar
│   │   ├── bottom_nav.dart      ← Bottom navigation
│   │   ├── photo_card.dart      ← Shared photo card
│   │   └── glass_container.dart ← Glassmorphism wrapper
│   ├── providers/
│   └── utils/
│
supabase/
├── migrations/
│   └── 001_initial.sql
└── functions/
    └── exif-process/            ← Edge function: EXIF + resize
```

---

## Database Schema (Drizzle ORM)

```typescript
// Users
users { id, username, email, avatar, bio, website, createdAt }
follows { followerId, followingId, createdAt }

// Photos
photos {
  id, userId, title, description,
  url, thumbnailUrl, width, height, fileSize,
  // EXIF
  camera, lens, iso, aperture, shutterSpeed,
  focalLength, flashUsed, whiteBalance,
  takenAt, latitude, longitude,
  // Meta
  views, likes, downloads,
  license, tags, isPublic, createdAt
}

// Social
likes { userId, photoId, createdAt }
comments { id, userId, photoId, body, createdAt }
saves { userId, photoId, collectionId }
collections { id, userId, name, coverPhotoId, isPublic }

// Portfolio
portfolios { id, userId, title, slug, coverImage, bio, isPublic }
portfolio_projects {
  id, portfolioId, title, description,
  coverImage, blocks (JSONB), order, publishedAt
}

// Feed
notifications { id, userId, type, fromUserId, photoId, read, createdAt }
```

---

## Design System (từ Stitch Darkroom Editorial)

```css
:root {
  /* Colors */
  --background: #0e0e0e;
  --surface: #0e0e0e;
  --surface-container: #191919;
  --surface-container-high: #1f1f1f;
  --primary: #e2c19b;        /* Vintage Gold */
  --on-primary: #523c1f;
  --secondary: #9f9d9d;      /* Muted Silver */
  --on-surface: #e5e5e5;
  --outline: #757575;
  --outline-variant: #484848;

  /* Typography */
  --font-display: 'Manrope', sans-serif;
  --font-body: 'Inter', sans-serif;
  --font-mono: 'Space Grotesk', monospace;  /* EXIF data */

  /* Shape */
  --radius: 4px;             /* Sharp, professional */

  /* Glassmorphism */
  --glass-bg: rgba(44, 44, 44, 0.6);
  --glass-blur: blur(12px);
  --glass-border: 1px solid rgba(255, 255, 255, 0.05);
}
```

---

## Phased Roadmap

### Phase 1 — Foundation (2 tuần)
- [ ] Project setup: Next.js 15 + TypeScript + Tailwind
- [ ] Design system: CSS variables từ Stitch tokens
- [ ] Auth: NextAuth với Google + Email
- [ ] Database: Schema Drizzle + Neon setup
- [ ] Layout: AppBar, Sidebar, Navigation
- [ ] Stitch HTML → Components conversion

### Phase 2 — Core Gallery + Feed (3 tuần)
- [ ] Upload flow: EXIF parse + Cloudinary
- [ ] Photo Detail page (desktop + mobile theo Stitch)
- [ ] Masonry gallery grid
- [ ] Discover Feed page (desktop theo Stitch)
- [ ] Infinite scroll + skeleton loading
- [ ] Like / Save actions

### Phase 3 — Social Layer (2 tuần)
- [ ] Social Feed (following-only)
- [ ] User profile pages
- [ ] Follow / Unfollow
- [ ] Comments
- [ ] Notifications
- [ ] Explore / Search

### Phase 4 — Portfolio Builder (3 tuần)
- [ ] Portfolio dashboard
- [ ] Project editor (drag & drop blocks)
- [ ] Public portfolio view
- [ ] Analytics dashboard
- [ ] PDF export
- [ ] Custom slug

### Phase 5 — Polish & Launch (1 tuần)
- [ ] Mobile responsive (theo Stitch mobile screens)
- [ ] SEO + OG tags
- [ ] Performance: Lighthouse 90+
- [ ] Vercel deployment
- [ ] Monitoring setup

---

## Các màn hình cần tạo thêm trong Stitch

> [!NOTE]
> Stitch hiện có 4 screens. Cần tạo thêm:

| Màn hình | Module |
|---|---|
| Upload Flow | Gallery |
| User Profile Page | Social |
| Explore / Search | Social |
| Portfolio Editor | Portfolio |
| Portfolio Public View | Portfolio |
| Notifications | Social |

---

## Open Questions

> [!IMPORTANT]
> **Stack preference**: Dùng Next.js (full-stack) hay tách riêng Backend API (Express/Fastify)?

> [!IMPORTANT]
> **Mobile App**: Chỉ làm web responsive, hay có plan làm React Native / Flutter sau này?

> [!IMPORTANT]
> **Storage**: Dùng Cloudinary (có free tier) hay tự host với S3/R2?

> [!WARNING]
> **EXIF GPS**: Hiển thị vị trí GPS cần có opt-in privacy toggle — người dùng phải chọn có/không.
