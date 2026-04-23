-- Migration 012: Add full_name column to profiles

DO $$
DECLARE
  target_table TEXT;
BEGIN
  -- Determine whether the table is currently named profiles or users
  IF to_regclass('public.profiles') IS NOT NULL THEN
    target_table := 'profiles';
  ELSE
    target_table := 'users';
  END IF;

  -- Add full_name column if it does not exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = target_table 
      AND column_name = 'full_name'
  ) THEN
    EXECUTE format('ALTER TABLE public.%I ADD COLUMN full_name TEXT', target_table);
    RAISE NOTICE 'Added full_name column to %', target_table;
  ELSE
    RAISE NOTICE 'Column full_name already exists in %', target_table;
  END IF;

END $$;
