$ErrorActionPreference = 'Continue'
$script:passed = 0
$script:failed = 0

function Invoke-LabSql([string]$query) {
    $out = & docker compose exec -T db psql -qAt -v ON_ERROR_STOP=1 -U labadmin -d lab07 -c $query 2>&1 | Out-String
    return @{ Text = $out.Trim(); Code = $LASTEXITCODE }
}

function Check-Equal([string]$name, [string]$query, [string]$expected) {
    $result = Invoke-LabSql $query
    if ($result.Code -eq 0 -and $result.Text -eq $expected) {
        Write-Host "PASS $name"
        $script:passed++
    } else {
        Write-Host "FAIL $name (got '$($result.Text)'; exit $($result.Code))"
        $script:failed++
    }
}

Check-Equal 'PostgreSQL 16+' "SELECT current_setting('server_version_num')::int >= 160000" 't'
Check-Equal 'dua role demo' "SELECT count(*) FROM pg_roles WHERE rolname IN ('lab_alice','lab_bob')" '2'
Check-Equal 'RLS aktif' "SELECT relrowsecurity FROM pg_class WHERE relname='rls_demo'" 't'
Check-Equal 'Alice hanya lihat miliknya' 'SET ROLE lab_alice; SELECT count(*) FROM rls_demo WHERE owner_name=current_user' '1'
Check-Equal 'Bob hanya lihat miliknya' 'SET ROLE lab_bob; SELECT count(*) FROM rls_demo WHERE owner_name=current_user' '1'
Check-Equal 'Bob tidak lihat Alice' "SET ROLE lab_bob; SELECT count(*) FROM rls_demo WHERE owner_name='lab_alice'" '0'
Check-Equal 'jumlah baris demo tetap dua' 'SELECT count(*) FROM rls_demo' '2'
Check-Equal 'extension pgvector aktif' "SELECT count(*) FROM pg_extension WHERE extname='vector'" '1'
Check-Equal 'tetangga terdekat Docker' "SELECT judul FROM lab_embeddings ORDER BY embedding <-> '[1,0,0]' LIMIT 1" 'Docker'

$denied = Invoke-LabSql "SET ROLE lab_bob; INSERT INTO rls_demo (owner_name,note) VALUES ('lab_alice','uji lintas pemilik')"
if ($denied.Code -ne 0 -and $denied.Text -match 'row-level security policy') {
    Write-Host 'PASS INSERT lintas pemilik ditolak'
    $script:passed++
} else {
    Write-Host "FAIL INSERT lintas pemilik ditolak (got '$($denied.Text)')"
    $script:failed++
}

Write-Host "Lab 07: $script:passed PASS, $script:failed FAIL"
if ($script:failed -gt 0) { exit 1 }
