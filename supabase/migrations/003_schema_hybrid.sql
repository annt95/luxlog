-- Luxlog: Hybrid schema alignment (DB <-> app contract)
-- Migration 003

-- 1) users -> profiles (preserve data, constraints, and existing FKs)
DO $$
BEGIN
  IF to_regclass('public.users') IS NOT NULL
     AND to_regclass('public.profiles') IS NULL THEN
    EXECUTE 'ALTER TABLE public.users RENAME TO profiles';
  END IF;
END $$;

-- Ensure RLS is enabled on the canonical table name.
ALTER TABLE IF EXISTS public.profiles ENABLE ROW LEVEL SECURITY;

-- 2) comments.body -> comments.text
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'comments'
      AND column_name = 'body'
  ) AND NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'comments'
      AND column_name = 'text'
  ) THEN
    EXECUTE 'ALTER TABLE public.comments RENAME COLUMN body TO text';
  END IF;
END $$;

-- 3) Add portfolios.blocks alias for app contract
ALTER TABLE IF EXISTS public.portfolios
ADD COLUMN IF NOT EXISTS blocks JSONB NOT NULL DEFAULT '[]'::jsonb;

-- 4) Re-point auth trigger function to profiles table
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  generated_username TEXT;
BEGIN
  generated_username := COALESCE(
    NULLIF(new.raw_user_meta_data->>'username', ''),
    split_part(COALESCE(new.email, ''), '@', 1),
    'user_' || substring(new.id::text, 1, 8)
  );

  INSERT INTO public.profiles (id, username, email)
  VALUES (new.id, generated_username, new.email)
  ON CONFLICT (id) DO UPDATE
  SET username = EXCLUDED.username,
      email = EXCLUDED.email;

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Keep the trigger present and linked to the latest function body.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'on_auth_user_created'
      AND tgrelid = 'auth.users'::regclass
  ) THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
  END IF;
END $$;

-- 5) Ensure profile policies exist on renamed table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'Public profiles are viewable by everyone.'
  ) THEN
    CREATE POLICY "Public profiles are viewable by everyone."
      ON public.profiles FOR SELECT USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'Users can insert their own profile.'
  ) THEN
    CREATE POLICY "Users can insert their own profile."
      ON public.profiles FOR INSERT
      WITH CHECK (auth.uid() = id);
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'Users can update own profile.'
  ) THEN
    CREATE POLICY "Users can update own profile."
      ON public.profiles FOR UPDATE
      USING (auth.uid() = id);
  END IF;
END $$;
