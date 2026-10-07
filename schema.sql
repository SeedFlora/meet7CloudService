-- Jalankan di Supabase SQL Editor. Tabel milik user, akses dibatasi RLS.
CREATE TABLE IF NOT EXISTS public.notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL CHECK (char_length(trim(title)) BETWEEN 1 AND 120),
  content text NOT NULL CHECK (char_length(trim(content)) BETWEEN 1 AND 5000),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS notes_user_created_idx ON public.notes (user_id, created_at DESC);
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON public.notes FROM anon, authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notes TO authenticated;

DROP POLICY IF EXISTS notes_select_own ON public.notes;
CREATE POLICY notes_select_own ON public.notes
  FOR SELECT TO authenticated
  USING ((SELECT auth.uid()) IS NOT NULL AND user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS notes_insert_own ON public.notes;
CREATE POLICY notes_insert_own ON public.notes
  FOR INSERT TO authenticated
  WITH CHECK ((SELECT auth.uid()) IS NOT NULL AND user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS notes_update_own ON public.notes;
CREATE POLICY notes_update_own ON public.notes
  FOR UPDATE TO authenticated
  USING ((SELECT auth.uid()) IS NOT NULL AND user_id = (SELECT auth.uid()))
  WITH CHECK ((SELECT auth.uid()) IS NOT NULL AND user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS notes_delete_own ON public.notes;
CREATE POLICY notes_delete_own ON public.notes
  FOR DELETE TO authenticated
  USING ((SELECT auth.uid()) IS NOT NULL AND user_id = (SELECT auth.uid()));
