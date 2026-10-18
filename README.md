# Lab 07 — RLS dan pgvector lokal

**Kebijakan kelas:** Lab ini latihan formatif, tanpa tugas, nilai, atau penyerahan terpisah. Satu proyek besar dikerjakan oleh kelompok **3 orang**, dengan presentasi checkpoint minggu 7 (UTS) dan hasil akhir minggu 14 (UAS). Simpan hasil lab hanya bila berguna sebagai referensi atau bukti proses proyek. Baca [brief proyek kelompok](PROYEK_KELOMPOK.md). Bobot resmi tetap mengikuti RPS/LMS.

Pelajari pembatasan catatan Alice/Bob dan pencarian jarak vektor menggunakan PostgreSQL lokal. Seluruh praktik inti berjalan di laptop melalui Docker Desktop dan PowerShell. Tidak ada akun cloud atau instalasi Node untuk jalur ini.

## Mulai

Ikuti [modul langkah demi langkah](MODUL_MAHASISWA.md) atau [PDF](MODUL_MAHASISWA.pdf). Modul menjelaskan folder kerja, fungsi perintah, hasil yang diharapkan, screenshot acuan, dan pembahasan.

Untuk salinan baru, buka PowerShell di folder tempat menyimpan proyek:

```powershell
git clone https://github.com/SeedFlora/meet7CloudService.git meet7CloudService-local
Set-Location .\meet7CloudService-local
Copy-Item .\.env.example .\.env
docker version
docker compose config --quiet
docker compose --profile debug up -d --wait
docker compose ps
```

Hasil: `db` healthy dan `adminer` berjalan. Adminer tersedia di <http://127.0.0.1:8087/>. Password lokal berada pada `POSTGRES_PASSWORD` di `.env`; file secret terpisah tidak diperlukan. Jangan menimpa `.env` pada clone lama yang sudah memiliki data: password harus tetap sama dengan password saat volume pertama dibuat.

Jalankan SQL dari folder yang sama:

```powershell
Get-Content -Raw .\local-rls-demo.sql | docker compose exec -T db psql -v ON_ERROR_STOP=1 -U labadmin -d lab07
Get-Content -Raw .\vector-local-demo.sql | docker compose exec -T db psql -v ON_ERROR_STOP=1 -U labadmin -d lab07
```

SQL pertama membuktikan RLS per role. SQL kedua mengurutkan Docker, Container, Database menurut jarak vektor. Baca penjelasan hasil pada modul sebelum lanjut.

## Materi pendamping

- [Teori Supabase](slides/Teori_Pertemuan_07.pptx)
- [Slide praktik lokal](slides/LAB07_RLS_pgvector_Bukti_Live.pptx)
- [Proyek kelompok](PROYEK_KELOMPOK.md)

Jalur Supabase Auth, RLS `auth.uid()`, dan Storage ada di bagian tambahan modul. Jalur itu memerlukan proyek milik peserta dan terpisah dari database lokal. `schema.sql` khusus Supabase; `local-rls-demo.sql` khusus lokal.

Selesai praktik, jalankan `docker compose --profile debug down`. Volume tetap tersimpan. Laporan, screenshot pribadi, checker, dan push ke repo pribadi merupakan latihan tambahan.
