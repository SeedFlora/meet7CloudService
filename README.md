# meet7CloudService — Lab 07 BaaS, RLS, dan pgvector

Praktikum COMP6991031 sesi 07. Kasus kerja: dua staf menyimpan catatan pada database yang sama, tetapi masing-masing hanya boleh membaca dan mengubah catatannya sendiri. Jalur wajib memakai PostgreSQL dan pgvector lokal melalui Docker Compose. Jalur Supabase memperlihatkan Auth, policy `auth.uid()`, dan Storage bila akun tersedia.

**Mulai dari [modul mahasiswa lengkap dengan kunci](MODUL_MAHASISWA.md).** Dosen memakai [panduan dosen](PANDUAN_DOSEN.md). Versi PDF berada di [modul mahasiswa](MODUL_MAHASISWA.pdf) dan [panduan dosen](PANDUAN_DOSEN.pdf); slide pada `slides/`. Gambar Docker, terminal, dan Adminer ada di `screenshots/`. Repo kelas: [SeedFlora/meet7CloudService](https://github.com/SeedFlora/meet7CloudService).

## Mulai cepat di laptop

Siapkan Docker Desktop/Engine. Dari root repo, salin contoh password menjadi file lokal yang diabaikan Git:

```powershell
Copy-Item .\secrets\db_password.example.txt .\secrets\db_password.txt
docker compose --profile debug up -d --wait
docker compose ps
Get-Content -Raw .\local-rls-demo.sql | docker compose exec -T db psql -v ON_ERROR_STOP=1 -U labadmin -d lab07
Get-Content -Raw .\vector-local-demo.sql | docker compose exec -T db psql -v ON_ERROR_STOP=1 -U labadmin -d lab07
& .\tests\challenge.ps1
```

Di Linux/Codespaces/Git Bash, gunakan `cp secrets/db_password.example.txt secrets/db_password.txt`, lalu jalankan dua file SQL dengan redirection `< file.sql` dan `bash tests/challenge.sh`. Buka Adminer di <http://127.0.0.1:8087/> untuk melihat tabel. Pilih **PostgreSQL**, server `db`, user `labadmin`, database `lab07`, dan isi password dari file lokal. Login sebagai pemilik tabel akan menampilkan kedua baris; bukti isolasi RLS harus memakai `SET ROLE lab_alice` dan `lab_bob` seperti di modul.

`vector-local-demo.sql` berisi vektor mainan tiga dimensi untuk memahami operator jarak; Lab 11 memakai embedding model untuk RAG. `schema.sql` dan `client-demo.mjs` adalah jalur Supabase opsional, bukan untuk database lokal ini. Jangan menaruh key rahasia atau password di Git.

Sesudah menyimpan bukti pribadi dan laporan, bersihkan container tanpa menghapus volume:

```powershell
docker compose --profile debug down
```

Rujukan: [RLS Supabase](https://supabase.com/docs/guides/database/postgres/row-level-security), [vector columns](https://supabase.com/docs/guides/ai/vector-columns), dan [pgvector](https://github.com/pgvector/pgvector).
