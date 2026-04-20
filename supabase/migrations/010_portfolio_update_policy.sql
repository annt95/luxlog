-- Migration 010: Add UPDATE RLS policy for portfolios table
-- Required for savePortfolio() upsert to work on existing rows

DROP POLICY IF EXISTS "Users can update own portfolios" ON public.portfolios;
CREATE POLICY "Users can update own portfolios" ON public.portfolios
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
