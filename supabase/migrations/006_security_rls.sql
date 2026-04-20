-- Luxlog: Security Hardening - Missing RLS Policies
-- Migration 006 (idempotent — safe to re-run)

-- 1. Photos: DELETE policy (only owner)
DROP POLICY IF EXISTS "Users can delete own photos" ON public.photos;
CREATE POLICY "Users can delete own photos" ON public.photos
  FOR DELETE USING (auth.uid() = user_id);

-- 2. Comments: INSERT + DELETE + SELECT
DROP POLICY IF EXISTS "Authenticated users can comment" ON public.comments;
CREATE POLICY "Authenticated users can comment" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own comments" ON public.comments;
CREATE POLICY "Users can delete own comments" ON public.comments
  FOR DELETE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Comments viewable by all" ON public.comments;
CREATE POLICY "Comments viewable by all" ON public.comments
  FOR SELECT USING (true);

-- 3. Likes: INSERT + DELETE + SELECT
DROP POLICY IF EXISTS "Authenticated users can like" ON public.likes;
CREATE POLICY "Authenticated users can like" ON public.likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Authenticated users can unlike" ON public.likes;
CREATE POLICY "Authenticated users can unlike" ON public.likes
  FOR DELETE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Likes viewable by all" ON public.likes;
CREATE POLICY "Likes viewable by all" ON public.likes
  FOR SELECT USING (true);

-- 4. Follows: full RLS
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Follows viewable by all" ON public.follows;
CREATE POLICY "Follows viewable by all" ON public.follows
  FOR SELECT USING (true);
DROP POLICY IF EXISTS "Users can follow" ON public.follows;
CREATE POLICY "Users can follow" ON public.follows
  FOR INSERT WITH CHECK (auth.uid() = follower_id);
DROP POLICY IF EXISTS "Users can unfollow" ON public.follows;
CREATE POLICY "Users can unfollow" ON public.follows
  FOR DELETE USING (auth.uid() = follower_id);

-- 5. Portfolios: SELECT (public), INSERT, DELETE
DROP POLICY IF EXISTS "Public portfolios viewable" ON public.portfolios;
CREATE POLICY "Public portfolios viewable" ON public.portfolios
  FOR SELECT USING (is_public = true OR auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can create portfolios" ON public.portfolios;
CREATE POLICY "Users can create portfolios" ON public.portfolios
  FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own portfolios" ON public.portfolios;
CREATE POLICY "Users can delete own portfolios" ON public.portfolios
  FOR DELETE USING (auth.uid() = user_id);

-- 6. Portfolio Projects
DROP POLICY IF EXISTS "Portfolio projects viewable" ON public.portfolio_projects;
CREATE POLICY "Portfolio projects viewable" ON public.portfolio_projects
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM public.portfolios
    WHERE id = portfolio_id AND (is_public = true OR user_id = auth.uid())
  ));
DROP POLICY IF EXISTS "Users can manage own projects" ON public.portfolio_projects;
CREATE POLICY "Users can manage own projects" ON public.portfolio_projects
  FOR INSERT WITH CHECK (EXISTS (
    SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()
  ));
DROP POLICY IF EXISTS "Users can update own projects" ON public.portfolio_projects;
CREATE POLICY "Users can update own projects" ON public.portfolio_projects
  FOR UPDATE USING (EXISTS (
    SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()
  ));
DROP POLICY IF EXISTS "Users can delete own projects" ON public.portfolio_projects;
CREATE POLICY "Users can delete own projects" ON public.portfolio_projects
  FOR DELETE USING (EXISTS (
    SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()
  ));

-- 7. Tags: INSERT (any authenticated user can create tags)
DROP POLICY IF EXISTS "Authenticated users can create tags" ON public.tags;
CREATE POLICY "Authenticated users can create tags" ON public.tags
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
