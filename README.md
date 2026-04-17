# Luxlog 📷

> A photography platform built with Flutter — inspired by Flickr, Instagram & Behance.

## What is Luxlog?

Luxlog is a multi-feature photography platform with 4 core modules:

| Module | Description |
|--------|-------------|
| 📸 **Gallery** | Post beautiful photos with full EXIF metadata (like Flickr) |
| 🌀 **Social Feed** | Follow photographers, like & comment (like Instagram) |
| 🎨 **Portfolio** | Create professional portfolios with drag-and-drop editor (like Behance) |
| 🖼️ **Discover** | Curated algorithmic feed with Editor's Pick |

## Design System

**"The Darkroom Editorial"** — based on Stitch design project.

- **Background**: `#0E0E0E` Deepest Charcoal
- **Accent**: `#E2C19B` Vintage Gold
- **Fonts**: Manrope (display) · Inter (body) · Space Grotesk (EXIF data)
- **Shape**: Sharp `4px` radius — professional, not playful
- **Style**: Glassmorphism nav · No border lines · Color-shift section demarcation

## Tech Stack

- **Flutter 3.41** (Dart 3.11)
- **Go Router 14** — navigation
- **Riverpod 2** — state management
- **Supabase** — backend (auth, db, storage, realtime)
- **flutter_animate** — micro-animations
- **flutter_staggered_grid_view** — masonry layout
- **exif** — real EXIF data parsing

## Screens

- `discover_screen.dart` — Masonry grid + glass AppBar + hero section
- `feed_screen.dart` — Stories, post cards, EXIF strip, double-tap like
- `upload_screen.dart` — Image picker + real EXIF parse + GPS privacy toggle
- `explore_screen.dart` — Search, genre tiles, trending masonry
- `photo_detail_screen.dart` — Full EXIF display, comments, related photos
- `profile_screen.dart` — Collapsing cover, 4 tabs (Photos/Portfolio/Collections/Gear)
- `portfolio_screen.dart` — Dashboard with analytics stats, project cards
- `portfolio_editor_screen.dart` — Drag-reorder block editor (text/grid/divider/form)
- `login_screen.dart` — Glass card, social login, photo collage background

## Getting Started

```bash
flutter pub get
flutter run
```

### Run on web
```bash
flutter run -d chrome
```

### Required environment variables
Run with:

```bash
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### Database migrations
Apply Supabase migrations in order:

- `001_initial.sql`
- `002_tags_categories.sql`
- `003_schema_hybrid.sql` (renames `users` -> `profiles`, `comments.body` -> `comments.text`, adds `portfolios.blocks`)
- `004_storage_photos_bucket.sql` (creates public `photos` storage bucket + RLS policies)
- `005_film_fields.sql` (adds film metadata + upload metadata fields on `photos`)
- `006_security_rls.sql` (adds missing RLS policies for photos/comments/likes/follows/portfolio/tags)
- `007_notifications.sql` (creates notifications table, RLS, and DB triggers for like/comment/follow events)

Upload flow expects a `photos` storage bucket and authenticated write policies from migration `004`.

### Run on iOS simulator
```bash
flutter run -d iphone
```

## Project Structure

```
lib/
├── app/
│   ├── theme.dart          # Darkroom design system tokens
│   └── router.dart         # GoRouter config
├── features/
│   ├── auth/               # Login / Register
│   ├── discover/           # Discover feed (home)
│   ├── feed/               # Social feed
│   ├── gallery/            # Photo detail + Upload
│   ├── portfolio/          # Portfolio dashboard + Editor
│   ├── profile/            # User profile
│   └── explore/            # Search + Explore
└── shared/
    └── widgets/
        ├── main_scaffold.dart   # Glass bottom nav + FAB
        ├── photo_card.dart      # Shared photo card with hover
        └── exif_badge.dart      # EXIF metadata display
```

## Roadmap

- [x] Supabase auth integration
- [x] Real photo upload to Supabase Storage
- [x] Feed/Profile/Explore wired to backend providers
- [ ] Push notifications (FCM)
- [ ] PDF portfolio export
- [ ] Custom portfolio domain
