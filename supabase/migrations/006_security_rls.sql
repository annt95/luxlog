-- Luxlog: Security Hardening - Missing RLS Policies
-- Migration 006

-- 1. Photos: DELETE policy (only owner)
CREATE POLICY "Users can delete own photos" ON public.photos
  FOR DELETE USING (auth.uid() = user_id);

-- 2. Comments: INSERT + DELETE + SELECT
CREATE POLICY "Authenticated users can comment" ON public.comments
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON public.comments
  FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Comments viewable by all" ON public.comments
  FOR SELECT USING (true);

-- 3. Likes: INSERT + DELETE + SELECT
CREATE POLICY "Authenticated users can like" ON public.likes
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Authenticated users can unlike" ON public.likes
  FOR DELETE USING (auth.uid() = user_id);
CREATE POLICY "Likes viewable by all" ON public.likes
  FOR SELECT USING (true);

-- 4. Follows: full RLS
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Follows viewable by all" ON public.follows
  FOR SELECT USING (true);
CREATE POLICY "Users can follow" ON public.follows
  FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON public.follows
  FOR DELETE USING (auth.uid() = follower_id);

-- 5. Portfolios: SELECT (public), INSERT, DELETE
CREATE POLICY "Public portfolios viewable" ON public.portfolios
  FOR SELECT USING (is_public = true OR auth.uid() = user_id);
CREATE POLICY "Users can create portfolios" ON public.portfolios
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own portfolios" ON public.portfolios
  FOR DELETE USING (auth.uid() = user_id);

-- 6. Portfolio Projects
CREATE POLICY "Portfolio projects viewable" ON public.portfolio_projects
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM public.portfolios
    WHERE id = portfolio_id AND (is_public = true OR user_id = auth.uid())
  ));
CREATE POLICY "Users can manage own projects" ON public.portfolio_projects
  FOR INSERT WITH CHECK (EXISTS (
    SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()
  ));
CREATE POLICY "Users can update own projects" ON public.portfolio_projects
  FOR UPDATE USING (EXISTS (
    SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()
  ));
CREATE POLICY "Users can delete own projects" ON public.portfolio_projects
  FOR DELETE USING (EXISTS (
    SELECT 1 FROM public.portfolios WHERE id = portfolio_id AND user_id = auth.uid()
  ));

-- 7. Tags: INSERT (any authenticated user can create tags)
CREATE POLICY "Authenticated users can create tags" ON public.tags
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
