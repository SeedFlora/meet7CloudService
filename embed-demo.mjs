// Tambahan AI Lab 07 (opsional): embedding asli 384 dimensi tanpa GPU -> file SQL untuk pgvector.
// Sama di Windows, macOS, dan Linux (Node 20+):
//   npm install --no-save @huggingface/transformers@4.3.2
//   node embed-demo.mjs            -> menulis embed-demo.sql (UTF-8, tanpa akun dan tanpa token)
// Lalu jalankan embed-demo.sql dengan psql di container db (perintah ada di README).
// Unduhan pertama model q8 sekitar 118 MB; berikutnya memakai cache lokal.
import { writeFileSync } from 'node:fs'
import { pipeline } from '@huggingface/transformers'

const MODEL = process.env.EMBED_MODEL || 'Xenova/paraphrase-multilingual-MiniLM-L12-v2'
const OUTPUT = process.env.EMBED_SQL || 'embed-demo.sql'

// Katalog UMKM fiktif. Teks ASCII saja agar aman dibaca Get-Content di Windows PowerShell 5.1.
const DOCS = [
  'Keripik singkong pedas, harga murah, cocok untuk oleh-oleh',
  'Kopi arabika Gayo kemasan 250 gram, sangrai medium',
  'Jasa servis laptop dan instal ulang Windows di Bandung',
  'Batik tulis motif mega mendung, bahan katun',
  'Sambal bawang botol 200 ml tanpa pengawet',
  'Kursus pemrograman Python untuk pemula, kelas daring',
]
// Kata pada pertanyaan sengaja tidak ada di dokumen: terjangkau != murah, komputer jinjing != laptop.
const QUERIES = ['camilan yang terjangkau', 'perbaiki komputer jinjing']

const started = Date.now()
const extract = await pipeline('feature-extraction', MODEL, { dtype: 'q8' })
const loadedMs = Date.now() - started
const output = await extract([...DOCS, ...QUERIES], { pooling: 'mean', normalize: true })
const [rows, dims] = output.dims
if (dims !== 384) throw new Error(`Model menghasilkan ${dims} dimensi; tabel memakai vector(384)`)
const vectors = output.tolist()
const literal = (v) => `'[${v.map((x) => x.toFixed(6)).join(',')}]'`
const quote = (s) => `'${s.replaceAll("'", "''")}'`

const sql = [
  `-- Dibuat oleh embed-demo.mjs; model ${MODEL}; ${dims} dimensi; ${DOCS.length} dokumen.`,
  'BEGIN;',
  'CREATE EXTENSION IF NOT EXISTS vector;',
  'DROP TABLE IF EXISTS lab07_embedding_docs;',
  'CREATE TABLE lab07_embedding_docs (',
  '  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,',
  '  konten text NOT NULL,',
  '  embedding vector(384) NOT NULL',
  ');',
  'CREATE INDEX lab07_embedding_docs_hnsw ON lab07_embedding_docs USING hnsw (embedding vector_cosine_ops);',
  'INSERT INTO lab07_embedding_docs (konten, embedding) VALUES',
  DOCS.map((d, i) => `  (${quote(d)}, ${literal(vectors[i])})`).join(',\n') + ';',
]
QUERIES.forEach((q, k) => {
  const word = q.split(' ').at(-1)
  sql.push(
    `\\echo '== Kata kunci: konten ILIKE ''%${word}%'' =='`,
    `SELECT count(*) AS cocok_kata_kunci FROM lab07_embedding_docs WHERE konten ILIKE '%${word}%';`,
    `\\echo '== Semantik (<=> jarak cosine): ${q} =='`,
    `WITH q AS (SELECT ${literal(vectors[DOCS.length + k])}::vector(384) AS v)`,
    'SELECT konten, round((embedding <=> q.v)::numeric, 3) AS jarak',
    'FROM lab07_embedding_docs, q ORDER BY embedding <=> q.v LIMIT 3;',
  )
})
sql.push('COMMIT;')
writeFileSync(OUTPUT, sql.join('\n') + '\n', 'utf8')
console.log(`Model ${MODEL} siap dalam ${(loadedMs / 1000).toFixed(1)} s; embedding dims [${rows}, ${dims}]`)
console.log(`${OUTPUT} ditulis: ${DOCS.length} dokumen + ${QUERIES.length} pertanyaan uji`)
