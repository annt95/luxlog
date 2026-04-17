-- ============================================================
-- LUXLOG: Consolidated Production Migration Script
-- Run this ONCE in Supabase Dashboard → SQL Editor
-- Safe to re-run (idempotent)
-- ============================================================

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 1: Rename users → profiles                             │
-- └─────────────────────────────────────────────────────────────┘
DO $$
BEGIN
  IF to_regclass('public.users') IS NOT NULL
     AND to_regclass('public.profiles') IS NULL THEN
    EXECUTE 'ALTER TABLE public.users RENAME TO profiles';
    RAISE NOTICE 'Renamed users → profiles';
  ELSE
    RAISE NOTICE 'Table already named profiles (or users does not exist)';
  END IF;
END $$;

ALTER TABLE IF EXISTS public.profiles ENABLE ROW LEVEL SECURITY;

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 2: Fix handle_new_user() trigger for Google OAuth      │
-- └─────────────────────────────────────────────────────────────┘

-- Determine which table to use (profiles or users)
DO $$
DECLARE
  target_table TEXT;
BEGIN
  IF to_regclass('public.profiles') IS NOT NULL THEN
    target_table := 'profiles';
  ELSE
    target_table := 'users';
  END IF;

  EXECUTE format($fn$
    CREATE OR REPLACE FUNCTION public.handle_new_user()
    RETURNS TRIGGER AS $t$
    DECLARE
      generated_username TEXT;
      suffix INT := 0;
      candidate TEXT;
    BEGIN
      generated_username := COALESCE(
        NULLIF(new.raw_user_meta_data->>'username', ''),
        NULLIF(new.raw_user_meta_data->>'full_name', ''),
        NULLIF(new.raw_user_meta_data->>'name', ''),
        split_part(COALESCE(new.email, ''), '@', 1),
        'user_' || substring(new.id::text, 1, 8)
      );

      generated_username := lower(regexp_replace(generated_username, '[^a-zA-Z0-9_]', '', 'g'));
      IF generated_username = '' THEN
        generated_username := 'user_' || substring(new.id::text, 1, 8);
      END IF;

      candidate := generated_username;
      WHILE EXISTS (SELECT 1 FROM public.%I WHERE username = candidate) LOOP
        suffix := suffix + 1;
        candidate := generated_username || suffix::text;
      END LOOP;

      INSERT INTO public.%I (id, username, email, avatar_url)
      VALUES (
        new.id,
        candidate,
        new.email,
        new.raw_user_meta_data->>'avatar_url'
      )
      ON CONFLICT (id) DO UPDATE
      SET username = EXCLUDED.username,
          email = EXCLUDED.email,
          avatar_url = COALESCE(EXCLUDED.avatar_url, public.%I.avatar_url);

      RETURN new;
    END;
    $t$ LANGUAGE plpgsql SECURITY DEFINER;
  $fn$, target_table, target_table, target_table);

  RAISE NOTICE 'Trigger function updated targeting table: %', target_table;
END $$;

-- Ensure trigger exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger
    WHERE tgname = 'on_auth_user_created' AND tgrelid = 'auth.users'::regclass
  ) THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
    RAISE NOTICE 'Created trigger on_auth_user_created';
  ELSE
    RAISE NOTICE 'Trigger on_auth_user_created already exists';
  END IF;
END $$;

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 3: Comments — rename body → text                       │
-- └─────────────────────────────────────────────────────────────┘
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'comments' AND column_name = 'body'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'comments' AND column_name = 'text'
  ) THEN
    EXECUTE 'ALTER TABLE public.comments RENAME COLUMN body TO text';
    RAISE NOTICE 'Renamed comments.body → comments.text';
  END IF;
END $$;

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 4: Tags & Categories (Migration 002)                   │
-- └─────────────────────────────────────────────────────────────┘

-- Create category_status type if not exists
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'category_status') THEN
    CREATE TYPE category_status AS ENUM ('approved', 'pending', 'rejected');
  END IF;
END $$;

-- Determine FK target for suggested_by
DO $$
DECLARE
  fk_target TEXT;
BEGIN
  IF to_regclass('public.profiles') IS NOT NULL THEN
    fk_target := 'profiles';
  ELSE
    fk_target := 'users';
  END IF;

  IF to_regclass('public.categories') IS NULL THEN
    EXECUTE format($sql$
      CREATE TABLE public.categories (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        slug TEXT UNIQUE NOT NULL,
        icon TEXT,
        cover_image TEXT,
        display_order INT DEFAULT 0,
        status category_status DEFAULT 'pending',
        suggested_by UUID REFERENCES public.%I(id) ON DELETE SET NULL,
        created_at TIMESTAMPTZ DEFAULT now()
      )
    $sql$, fk_target);
    RAISE NOTICE 'Created categories table';
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.tags (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  usage_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.photo_tags (
  photo_id UUID REFERENCES public.photos(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES public.tags(id) ON DELETE CASCADE,
  PRIMARY KEY (photo_id, tag_id)
);

CREATE TABLE IF NOT EXISTS public.photo_categories (
  photo_id UUID REFERENCES public.photos(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE CASCADE,
  PRIMARY KEY (photo_id, category_id)
);

ALTER TABLE IF EXISTS public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.photo_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.photo_categories ENABLE ROW LEVEL SECURITY;

-- Seed categories (idempotent — ON CONFLICT DO NOTHING)
INSERT INTO public.categories (name, slug, icon, display_order, status) VALUES
  ('Portrait', 'portrait', 'person_outline', 1, 'approved'),
  ('Landscape', 'landscape', 'landscape', 2, 'approved'),
  ('Street', 'street', 'location_city', 3, 'approved'),
  ('Wildlife', 'wildlife', 'pets', 4, 'approved'),
  ('Architecture', 'architecture', 'apartment', 5, 'approved'),
  ('Black & White', 'black-and-white', 'contrast', 6, 'approved'),
  ('Macro', 'macro', 'zoom_in', 7, 'approved'),
  ('Film', 'film', 'camera_roll', 8, 'approved'),
  ('Night', 'night', 'nights_stay', 9, 'approved'),
  ('Aerial', 'aerial', 'flight', 10, 'approved')
ON CONFLICT (name) DO NOTHING;

-- Tag RPCs
CREATE OR REPLACE FUNCTION public.increment_tag_usage(tag_name TEXT)
RETURNS UUID AS $$
DECLARE result_id UUID;
BEGIN
  INSERT INTO public.tags (name, usage_count)
  VALUES (lower(trim(tag_name)), 1)
  ON CONFLICT (name) DO UPDATE SET usage_count = tags.usage_count + 1
  RETURNING id INTO result_id;
  RETURN result_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.decrement_tag_usage(p_tag_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.tags SET usage_count = GREATEST(usage_count - 1, 0) WHERE id = p_tag_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 5: Portfolios — add blocks column                      │
-- └─────────────────────────────────────────────────────────────┘
ALTER TABLE IF EXISTS public.portfolios
ADD COLUMN IF NOT EXISTS blocks JSONB NOT NULL DEFAULT '[]'::jsonb;

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 6: Storage bucket for photos (Migration 004)           │
-- └─────────────────────────────────────────────────────────────┘
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'photos', 'photos', true, 20971520,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
) ON CONFLICT (id) DO NOTHING;

-- Storage RLS
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Public can read photos bucket') THEN
    CREATE POLICY "Public can read photos bucket" ON storage.objects FOR SELECT USING (bucket_id = 'photos');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Users can upload own photos') THEN
    CREATE POLICY "Users can upload own photos" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'photos' AND auth.uid()::text = (storage.foldername(name))[2]);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Users can update own photos') THEN
    CREATE POLICY "Users can update own photos" ON storage.objects FOR UPDATE USING (bucket_id = 'photos' AND auth.uid()::text = (storage.foldername(name))[2]);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname='Users can delete own photos') THEN
    CREATE POLICY "Users can delete own photos" ON storage.objects FOR DELETE USING (bucket_id = 'photos' AND auth.uid()::text = (storage.foldername(name))[2]);
  END IF;
END $$;

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 7: Film fields + upload metadata (Migration 005)       │
-- └─────────────────────────────────────────────────────────────┘
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS film_stock TEXT;
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS film_camera TEXT;
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS is_film BOOLEAN DEFAULT false;
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS caption TEXT;
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS license TEXT DEFAULT 'CC BY 4.0';
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS allow_download BOOLEAN DEFAULT true;
CREATE INDEX IF NOT EXISTS idx_photos_is_film ON public.photos(is_film) WHERE is_film = true;

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 8: RLS policies (Migration 006)                        │
-- └─────────────────────────────────────────────────────────────┘

-- Profiles
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename IN ('profiles','users') AND policyname='Public profiles are viewable by everyone.') THEN
    CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename IN ('profiles','users') AND policyname='Users can insert their own profile.') THEN
    CREATE POLICY "Users can insert their own profile." ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename IN ('profiles','users') AND policyname='Users can update own profile.') THEN
    CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);
  END IF;
END $$;

-- Photos
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='photos' AND policyname='Users can delete own photos') THEN
    CREATE POLICY "Users can delete own photos" ON public.photos FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- Comments
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='comments' AND policyname='Authenticated users can comment') THEN
    CREATE POLICY "Authenticated users can comment" ON public.comments FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='comments' AND policyname='Users can delete own comments') THEN
    CREATE POLICY "Users can delete own comments" ON public.comments FOR DELETE USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='comments' AND policyname='Comments viewable by all') THEN
    CREATE POLICY "Comments viewable by all" ON public.comments FOR SELECT USING (true);
  END IF;
END $$;

-- Likes
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='likes' AND policyname='Authenticated users can like') THEN
    CREATE POLICY "Authenticated users can like" ON public.likes FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='likes' AND policyname='Authenticated users can unlike') THEN
    CREATE POLICY "Authenticated users can unlike" ON public.likes FOR DELETE USING (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='likes' AND policyname='Likes viewable by all') THEN
    CREATE POLICY "Likes viewable by all" ON public.likes FOR SELECT USING (true);
  END IF;
END $$;

-- Follows
ALTER TABLE IF EXISTS public.follows ENABLE ROW LEVEL SECURITY;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='follows' AND policyname='Follows viewable by all') THEN
    CREATE POLICY "Follows viewable by all" ON public.follows FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='follows' AND policyname='Users can follow') THEN
    CREATE POLICY "Users can follow" ON public.follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='follows' AND policyname='Users can unfollow') THEN
    CREATE POLICY "Users can unfollow" ON public.follows FOR DELETE USING (auth.uid() = follower_id);
  END IF;
END $$;

-- Portfolios
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='portfolios' AND policyname='Public portfolios viewable') THEN
    CREATE POLICY "Public portfolios viewable" ON public.portfolios FOR SELECT USING (is_public = true OR auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='portfolios' AND policyname='Users can create portfolios') THEN
    CREATE POLICY "Users can create portfolios" ON public.portfolios FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='portfolios' AND policyname='Users can delete own portfolios') THEN
    CREATE POLICY "Users can delete own portfolios" ON public.portfolios FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- Portfolio Projects
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='portfolio_projects' AND policyname='Portfolio projects viewable') THEN
    CREATE POLICY "Portfolio projects viewable" ON public.portfolio_projects FOR SELECT USING (EXISTS (SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND (is_public = true OR user_id = auth.uid())));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='portfolio_projects' AND policyname='Users can manage own projects') THEN
    CREATE POLICY "Users can manage own projects" ON public.portfolio_projects FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='portfolio_projects' AND policyname='Users can update own projects') THEN
    CREATE POLICY "Users can update own projects" ON public.portfolio_projects FOR UPDATE USING (EXISTS (SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='portfolio_projects' AND policyname='Users can delete own projects') THEN
    CREATE POLICY "Users can delete own projects" ON public.portfolio_projects FOR DELETE USING (EXISTS (SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()));
  END IF;
END $$;

-- Tags & Categories RLS
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='categories' AND policyname='Approved categories viewable by all') THEN
    CREATE POLICY "Approved categories viewable by all" ON public.categories FOR SELECT USING (status = 'approved' OR suggested_by = auth.uid());
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='categories' AND policyname='Users can suggest categories') THEN
    CREATE POLICY "Users can suggest categories" ON public.categories FOR INSERT WITH CHECK (auth.uid() = suggested_by AND status = 'pending');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='tags' AND policyname='Tags viewable by all') THEN
    CREATE POLICY "Tags viewable by all" ON public.tags FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='tags' AND policyname='Authenticated users can create tags') THEN
    CREATE POLICY "Authenticated users can create tags" ON public.tags FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='photo_tags' AND policyname='Photo tags viewable by all') THEN
    CREATE POLICY "Photo tags viewable by all" ON public.photo_tags FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='photo_tags' AND policyname='Users can tag own photos') THEN
    CREATE POLICY "Users can tag own photos" ON public.photo_tags FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.photos WHERE id = photo_id AND user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='photo_tags' AND policyname='Users can remove tags from own photos') THEN
    CREATE POLICY "Users can remove tags from own photos" ON public.photo_tags FOR DELETE USING (EXISTS (SELECT 1 FROM public.photos WHERE id = photo_id AND user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='photo_categories' AND policyname='Photo categories viewable by all') THEN
    CREATE POLICY "Photo categories viewable by all" ON public.photo_categories FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='photo_categories' AND policyname='Users can categorize own photos') THEN
    CREATE POLICY "Users can categorize own photos" ON public.photo_categories FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.photos WHERE id = photo_id AND user_id = auth.uid()));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='photo_categories' AND policyname='Users can remove categories from own photos') THEN
    CREATE POLICY "Users can remove categories from own photos" ON public.photo_categories FOR DELETE USING (EXISTS (SELECT 1 FROM public.photos WHERE id = photo_id AND user_id = auth.uid()));
  END IF;
END $$;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_tags_name ON public.tags(name);
CREATE INDEX IF NOT EXISTS idx_tags_usage ON public.tags(usage_count DESC);
CREATE INDEX IF NOT EXISTS idx_photo_tags_tag ON public.photo_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_photo_tags_photo ON public.photo_tags(photo_id);
CREATE INDEX IF NOT EXISTS idx_photo_categories_cat ON public.photo_categories(category_id);
CREATE INDEX IF NOT EXISTS idx_photo_categories_photo ON public.photo_categories(photo_id);
CREATE INDEX IF NOT EXISTS idx_categories_slug ON public.categories(slug);
CREATE INDEX IF NOT EXISTS idx_categories_status ON public.categories(status);

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 9: Notifications (Migration 007)                       │
-- └─────────────────────────────────────────────────────────────┘

-- Determine FK target
DO $$
DECLARE fk_target TEXT;
BEGIN
  IF to_regclass('public.profiles') IS NOT NULL THEN fk_target := 'profiles';
  ELSE fk_target := 'users';
  END IF;

  IF to_regclass('public.notifications') IS NULL THEN
    EXECUTE format($sql$
      CREATE TABLE public.notifications (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        recipient_id UUID REFERENCES public.%I(id) ON DELETE CASCADE NOT NULL,
        actor_id UUID REFERENCES public.%I(id) ON DELETE CASCADE,
        type TEXT NOT NULL CHECK (type IN ('like', 'comment', 'follow', 'tag')),
        photo_id UUID REFERENCES public.photos(id) ON DELETE CASCADE,
        comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
        read_at TIMESTAMPTZ,
        created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
      )
    $sql$, fk_target, fk_target);
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_notifications_recipient_created ON public.notifications(recipient_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(recipient_id, read_at) WHERE read_at IS NULL;

ALTER TABLE IF EXISTS public.notifications ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='notifications' AND policyname='Recipients can view own notifications') THEN
    CREATE POLICY "Recipients can view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = recipient_id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='notifications' AND policyname='Recipients can mark notifications as read') THEN
    CREATE POLICY "Recipients can mark notifications as read" ON public.notifications FOR UPDATE USING (auth.uid() = recipient_id) WITH CHECK (auth.uid() = recipient_id);
  END IF;
END $$;

-- Notification trigger functions
CREATE OR REPLACE FUNCTION public.create_like_notification()
RETURNS TRIGGER AS $$
DECLARE photo_owner UUID;
BEGIN
  SELECT user_id INTO photo_owner FROM public.photos WHERE id = NEW.photo_id;
  IF photo_owner IS NOT NULL AND photo_owner <> NEW.user_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type, photo_id)
    VALUES (photo_owner, NEW.user_id, 'like', NEW.photo_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.create_comment_notification()
RETURNS TRIGGER AS $$
DECLARE photo_owner UUID;
BEGIN
  SELECT user_id INTO photo_owner FROM public.photos WHERE id = NEW.photo_id;
  IF photo_owner IS NOT NULL AND photo_owner <> NEW.user_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type, photo_id, comment_id)
    VALUES (photo_owner, NEW.user_id, 'comment', NEW.photo_id, NEW.id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.create_follow_notification()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.following_id <> NEW.follower_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type)
    VALUES (NEW.following_id, NEW.follower_id, 'follow');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'on_like_created_notify') THEN
    CREATE TRIGGER on_like_created_notify AFTER INSERT ON public.likes FOR EACH ROW EXECUTE PROCEDURE public.create_like_notification();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'on_comment_created_notify') THEN
    CREATE TRIGGER on_comment_created_notify AFTER INSERT ON public.comments FOR EACH ROW EXECUTE PROCEDURE public.create_comment_notification();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'on_follow_created_notify') THEN
    CREATE TRIGGER on_follow_created_notify AFTER INSERT ON public.follows FOR EACH ROW EXECUTE PROCEDURE public.create_follow_notification();
  END IF;
END $$;

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 10: Reload PostgREST schema cache                      │
-- └─────────────────────────────────────────────────────────────┘
NOTIFY pgrst, 'reload schema';

-- ┌─────────────────────────────────────────────────────────────┐
-- │ STEP 11: Cleanup — delete orphan auth user that failed       │
-- │          (the user who got "Database error saving new user") │
-- └─────────────────────────────────────────────────────────────┘
-- This deletes the auth.users entry that was created by Google OAuth
-- but whose profile trigger failed. The user can re-login fresh.
DO $$
DECLARE
  target_table TEXT;
BEGIN
  IF to_regclass('public.profiles') IS NOT NULL THEN
    target_table := 'profiles';
  ELSE
    target_table := 'users';
  END IF;

  -- Delete auth users that have no matching profile
  EXECUTE format($sql$
    DELETE FROM auth.users au
    WHERE NOT EXISTS (
      SELECT 1 FROM public.%I p WHERE p.id = au.id
    )
    AND au.created_at > now() - interval '7 days'
  $sql$, target_table);

  RAISE NOTICE 'Cleaned up orphan auth users';
END $$;

-- ============================================================
-- ✅ DONE! All migrations applied successfully.
-- ============================================================
