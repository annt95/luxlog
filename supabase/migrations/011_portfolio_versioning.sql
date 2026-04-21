-- Migration 011: Add version tracking to portfolios
-- Adds published_at timestamp and version counter for portfolio version history

ALTER TABLE public.portfolios
  ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS version INT DEFAULT 1 NOT NULL;

-- Set published_at for already-public portfolios
UPDATE public.portfolios
SET published_at = created_at
WHERE is_public = true AND published_at IS NULL;

COMMENT ON COLUMN public.portfolios.published_at IS 'Timestamp when portfolio was last published (set to public)';
COMMENT ON COLUMN public.portfolios.version IS 'Incremented each time portfolio is published';
