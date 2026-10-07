-- Jalankan terhadap database Compose Lab 07 sebagai labadmin (pemilik DB).
-- Role ini hanya untuk demonstrasi lokal, tidak terhubung dengan Supabase Auth.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'lab_alice') THEN
    CREATE ROLE lab_alice;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'lab_bob') THEN
    CREATE ROLE lab_bob;
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS rls_demo (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_name text NOT NULL,
  note text NOT NULL
);
ALTER TABLE rls_demo ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, UPDATE, DELETE ON rls_demo TO lab_alice, lab_bob;
DROP POLICY IF EXISTS rls_demo_owner ON rls_demo;
CREATE POLICY rls_demo_owner ON rls_demo
  FOR ALL TO lab_alice, lab_bob
  USING (owner_name = current_user)
  WITH CHECK (owner_name = current_user);

TRUNCATE rls_demo;
SET ROLE lab_alice;
INSERT INTO rls_demo (owner_name, note) VALUES ('lab_alice', 'Catatan Alice');
SELECT current_user AS viewer, owner_name, note FROM rls_demo;
RESET ROLE;
SET ROLE lab_bob;
INSERT INTO rls_demo (owner_name, note) VALUES ('lab_bob', 'Catatan Bob');
SELECT current_user AS viewer, owner_name, note FROM rls_demo;
RESET ROLE;
