-- Luxlog: Storage bucket and RLS for photo uploads
-- Migration 004

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'photos',
  'photos',
  true,
  20971520,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
)
ON CONFLICT (id) DO NOTHING;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Public can read photos bucket'
  ) THEN
    CREATE POLICY "Public can read photos bucket"
      ON storage.objects FOR SELECT
      USING (bucket_id = 'photos');
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Users can upload own photos'
  ) THEN
    CREATE POLICY "Users can upload own photos"
      ON storage.objects FOR INSERT
      WITH CHECK (
        bucket_id = 'photos'
        AND auth.uid()::text = (storage.foldername(name))[2]
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Users can update own photos'
  ) THEN
    CREATE POLICY "Users can update own photos"
      ON storage.objects FOR UPDATE
      USING (
        bucket_id = 'photos'
        AND auth.uid()::text = (storage.foldername(name))[2]
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
      AND policyname = 'Users can delete own photos'
  ) THEN
    CREATE POLICY "Users can delete own photos"
      ON storage.objects FOR DELETE
      USING (
        bucket_id = 'photos'
        AND auth.uid()::text = (storage.foldername(name))[2]
      );
  END IF;
END $$;
