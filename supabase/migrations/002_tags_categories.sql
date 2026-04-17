-- Luxlog: Tags, Hashtags & Categories
-- Migration 002

-- 1. Categories (curated, admin-managed)
CREATE TABLE public.categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  icon TEXT,
  cover_image TEXT,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Tags (user-generated, freeform)
CREATE TABLE public.tags (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  usage_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Photo ↔ Tag (many-to-many)
CREATE TABLE public.photo_tags (
  photo_id UUID REFERENCES public.photos(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES public.tags(id) ON DELETE CASCADE,
  PRIMARY KEY (photo_id, tag_id)
);

-- 4. Photo ↔ Category (many-to-many)
CREATE TABLE public.photo_categories (
  photo_id UUID REFERENCES public.photos(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id) ON DELETE CASCADE,
  PRIMARY KEY (photo_id, category_id)
);

-- 5. RLS
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photo_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Categories viewable by all" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Tags viewable by all" ON public.tags FOR SELECT USING (true);
CREATE POLICY "Photo tags viewable by all" ON public.photo_tags FOR SELECT USING (true);
CREATE POLICY "Photo categories viewable by all" ON public.photo_categories FOR SELECT USING (true);

CREATE POLICY "Users can tag own photos" ON public.photo_tags FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.photos WHERE id = photo_id AND user_id = auth.uid()));
CREATE POLICY "Users can categorize own photos" ON public.photo_categories FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.photos WHERE id = photo_id AND user_id = auth.uid()));

CREATE POLICY "Users can remove tags from own photos" ON public.photo_tags FOR DELETE
  USING (EXISTS (SELECT 1 FROM public.photos WHERE id = photo_id AND user_id = auth.uid()));
CREATE POLICY "Users can remove categories from own photos" ON public.photo_categories FOR DELETE
  USING (EXISTS (SELECT 1 FROM public.photos WHERE id = photo_id AND user_id = auth.uid()));

-- 6. Indexes for performance
CREATE INDEX idx_tags_name ON public.tags(name);
CREATE INDEX idx_tags_usage ON public.tags(usage_count DESC);
CREATE INDEX idx_photo_tags_tag ON public.photo_tags(tag_id);
CREATE INDEX idx_photo_tags_photo ON public.photo_tags(photo_id);
CREATE INDEX idx_photo_categories_cat ON public.photo_categories(category_id);
CREATE INDEX idx_photo_categories_photo ON public.photo_categories(photo_id);
CREATE INDEX idx_categories_slug ON public.categories(slug);

-- 7. Seed categories
INSERT INTO public.categories (name, slug, icon, display_order) VALUES
  ('Portrait', 'portrait', 'person_outline', 1),
  ('Landscape', 'landscape', 'landscape', 2),
  ('Street', 'street', 'location_city', 3),
  ('Wildlife', 'wildlife', 'pets', 4),
  ('Architecture', 'architecture', 'apartment', 5),
  ('Black & White', 'black-and-white', 'contrast', 6),
  ('Macro', 'macro', 'zoom_in', 7),
  ('Film', 'film', 'camera_roll', 8),
  ('Night', 'night', 'nights_stay', 9),
  ('Aerial', 'aerial', 'flight', 10);

-- 8. RPC: Upsert tag and increment usage count
CREATE OR REPLACE FUNCTION public.increment_tag_usage(tag_name TEXT)
RETURNS UUID AS $$
DECLARE
  result_id UUID;
BEGIN
  INSERT INTO public.tags (name, usage_count)
  VALUES (lower(trim(tag_name)), 1)
  ON CONFLICT (name) DO UPDATE SET usage_count = tags.usage_count + 1
  RETURNING id INTO result_id;
  RETURN result_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. RPC: Decrement tag usage (when removing tag from photo)
CREATE OR REPLACE FUNCTION public.decrement_tag_usage(p_tag_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.tags SET usage_count = GREATEST(usage_count - 1, 0)
  WHERE id = p_tag_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
