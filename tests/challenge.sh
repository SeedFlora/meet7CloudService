#!/usr/bin/env bash
set -uo pipefail
passed=0
failed=0

sql() { docker compose exec -T db psql -qAt -v ON_ERROR_STOP=1 -U labadmin -d lab07 -c "$1" 2>&1; }
check_equal() {
  local name="$1" query="$2" expected="$3" output code
  output=$(sql "$query"); code=$?
  if [[ $code -eq 0 && "$output" == "$expected" ]]; then
    printf 'PASS %s\n' "$name"; ((passed+=1))
  else
    printf 'FAIL %s (got %q; exit %s)\n' "$name" "$output" "$code"; ((failed+=1))
  fi
}

check_equal 'PostgreSQL 16+' "SELECT current_setting('server_version_num')::int >= 160000" t
check_equal 'dua role demo' "SELECT count(*) FROM pg_roles WHERE rolname IN ('lab_alice','lab_bob')" 2
check_equal 'RLS aktif' "SELECT relrowsecurity FROM pg_class WHERE relname='rls_demo'" t
check_equal 'Alice hanya lihat miliknya' 'SET ROLE lab_alice; SELECT count(*) FROM rls_demo WHERE owner_name=current_user' 1
check_equal 'Bob hanya lihat miliknya' 'SET ROLE lab_bob; SELECT count(*) FROM rls_demo WHERE owner_name=current_user' 1
check_equal 'Bob tidak lihat Alice' "SET ROLE lab_bob; SELECT count(*) FROM rls_demo WHERE owner_name='lab_alice'" 0
check_equal 'jumlah baris demo tetap dua' 'SELECT count(*) FROM rls_demo' 2
check_equal 'extension pgvector aktif' "SELECT count(*) FROM pg_extension WHERE extname='vector'" 1
check_equal 'tetangga terdekat Docker' "SELECT judul FROM lab_embeddings ORDER BY embedding <-> '[1,0,0]' LIMIT 1" Docker

denied=$(sql "SET ROLE lab_bob; INSERT INTO rls_demo (owner_name,note) VALUES ('lab_alice','uji lintas pemilik')"); code=$?
if [[ $code -ne 0 && "$denied" == *'row-level security policy'* ]]; then
  printf 'PASS INSERT lintas pemilik ditolak\n'; ((passed+=1))
else
  printf 'FAIL INSERT lintas pemilik ditolak (got %q)\n' "$denied"; ((failed+=1))
fi
printf 'Lab 07: %s PASS, %s FAIL\n' "$passed" "$failed"
[[ $failed -eq 0 ]]
