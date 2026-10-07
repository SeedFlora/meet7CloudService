-- Opsional di Supabase SQL Editor. Lab 11 memakai pgvector untuk RAG lokal.
CREATE EXTENSION IF NOT EXISTS vector;
SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';
