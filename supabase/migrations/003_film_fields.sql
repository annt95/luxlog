-- Luxlog: Film Photography Fields + Upload Metadata
-- Migration 003

-- 1. Film photography columns
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS film_stock TEXT;
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS film_camera TEXT;
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS is_film BOOLEAN DEFAULT false;

-- 2. Upload metadata columns
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS caption TEXT;
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS license TEXT DEFAULT 'CC BY 4.0';
ALTER TABLE public.photos ADD COLUMN IF NOT EXISTS allow_download BOOLEAN DEFAULT true;

-- 3. Index for film photos filtering
CREATE INDEX IF NOT EXISTS idx_photos_is_film ON public.photos(is_film) WHERE is_film = true;
