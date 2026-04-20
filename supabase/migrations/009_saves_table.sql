-- Migration 009: Saves/Bookmarks table
-- Users can save photos for later viewing

CREATE TABLE IF NOT EXISTS public.saves (
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  photo_id UUID REFERENCES public.photos(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, photo_id)
);

ALTER TABLE public.saves ENABLE ROW LEVEL SECURITY;

-- Users can only save for themselves
CREATE POLICY "Users can save photos" ON public.saves
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can only unsave their own
CREATE POLICY "Users can unsave photos" ON public.saves
  FOR DELETE USING (auth.uid() = user_id);

-- Users can only view their own saves
CREATE POLICY "Users can view own saves" ON public.saves
  FOR SELECT USING (auth.uid() = user_id);

-- Index for fast lookup
CREATE INDEX IF NOT EXISTS idx_saves_user_id ON public.saves(user_id);
CREATE INDEX IF NOT EXISTS idx_saves_photo_id ON public.saves(photo_id);
