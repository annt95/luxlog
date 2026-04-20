# Database Schema Reference

Luxlog uses Supabase (PostgreSQL) as the backend database. Migrations are in `supabase/migrations/`.

## Tables

### `profiles`
User profile information, synced from Supabase Auth.
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK) | References `auth.users.id` |
| `username` | TEXT UNIQUE | Public handle |
| `full_name` | TEXT | Display name |
| `bio` | TEXT | User biography |
| `avatar_url` | TEXT | Profile image URL |
| `links` | JSONB | Social/website links |
| `created_at` | TIMESTAMPTZ | |

### `photos`
Core content table for uploaded photographs.
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK) | |
| `user_id` | UUID (FK→profiles) | Uploader |
| `title` | TEXT | Photo title |
| `caption` | TEXT | Description |
| `image_url` | TEXT | Supabase Storage public URL |
| `camera` | TEXT | Camera body |
| `lens` | TEXT | Lens used |
| `iso` | INT | ISO speed |
| `aperture` | TEXT | f-stop |
| `shutter_speed` | TEXT | |
| `focal_length` | TEXT | |
| `is_film` | BOOL | Film vs digital |
| `film_stock` | TEXT | Film stock name |
| `film_camera` | TEXT | Film camera body |
| `likes_count` | INT | Auto-updated via trigger |
| `views_count` | INT | |
| `is_public` | BOOL | Visibility |
| `allow_download` | BOOL | |
| `latitude` | FLOAT | GPS (opt-in) |
| `longitude` | FLOAT | GPS (opt-in) |
| `created_at` | TIMESTAMPTZ | |

### `likes`
Join table for photo likes. PK = `(user_id, photo_id)`.
| Column | Type |
|--------|------|
| `user_id` | UUID (FK→profiles) |
| `photo_id` | UUID (FK→photos) |
| `created_at` | TIMESTAMPTZ |

**Trigger**: `trigger_update_likes_count` auto-increments/decrements `photos.likes_count` on INSERT/DELETE.

### `comments`
| Column | Type |
|--------|------|
| `id` | UUID (PK) |
| `photo_id` | UUID (FK→photos) |
| `user_id` | UUID (FK→profiles) |
| `text` | TEXT (max 1000 chars) |
| `created_at` | TIMESTAMPTZ |

### `follows`
| Column | Type |
|--------|------|
| `follower_id` | UUID (FK→profiles) |
| `following_id` | UUID (FK→profiles) |
| `created_at` | TIMESTAMPTZ |

PK = `(follower_id, following_id)`. Self-follow prevented at application level.

### `categories`
| Column | Type |
|--------|------|
| `id` | UUID (PK) |
| `name` | TEXT |
| `slug` | TEXT UNIQUE |

### `photo_categories`
Join table: `(photo_id, category_id)`.

### `tags`
| Column | Type |
|--------|------|
| `id` | UUID (PK) |
| `name` | TEXT UNIQUE |

### `photo_tags`
Join table: `(photo_id, tag_id)`. Max 30 tags per photo, max 50 chars per tag.

### `notifications`
| Column | Type |
|--------|------|
| `id` | UUID (PK) |
| `user_id` | UUID (FK→profiles) |
| `type` | TEXT |
| `data` | JSONB |
| `read` | BOOL |
| `created_at` | TIMESTAMPTZ |

### `portfolios`
| Column | Type |
|--------|------|
| `id` | UUID (PK) |
| `user_id` | UUID (FK→profiles) |
| `title` | TEXT |
| `slug` | TEXT UNIQUE |
| `photos` | JSONB |
| `created_at` | TIMESTAMPTZ |

## Migrations

| # | File | Description |
|---|------|-------------|
| 001 | `001_initial.sql` | profiles, photos, likes, comments, follows |
| 002 | `002_tags_categories.sql` | tags, categories, join tables |
| 003 | `003_schema_hybrid.sql` | Schema refinements |
| 004 | `004_storage_photos_bucket.sql` | Storage bucket + policies |
| 005 | `005_film_fields.sql` | Film photography columns |
| 006 | `006_security_rls.sql` | Row Level Security policies |
| 007 | `007_notifications.sql` | Notifications table |
| 008 | `008_likes_count_trigger.sql` | Auto-update likes_count trigger |

## Row Level Security (RLS)

All tables have RLS enabled. Key policies:
- **photos**: Public read, owner write
- **likes**: Authenticated insert/delete own rows
- **comments**: Authenticated insert, owner delete
- **follows**: Authenticated insert/delete own rows
- **profiles**: Public read, owner update
- **Storage (photos bucket)**: Authenticated upload, public read
