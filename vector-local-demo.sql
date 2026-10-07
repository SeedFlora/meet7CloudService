-- Vektor tiga dimensi ini hanya data mainan untuk memahami operator jarak.
-- Embedding model nyata dan RAG dipraktikkan pada Lab 11.
CREATE EXTENSION IF NOT EXISTS vector;
DROP TABLE IF EXISTS lab_embeddings;
CREATE TABLE lab_embeddings (
  id integer PRIMARY KEY,
  judul text NOT NULL,
  embedding vector(3) NOT NULL
);
INSERT INTO lab_embeddings (id, judul, embedding) VALUES
  (1, 'Docker', '[1,0,0]'),
  (2, 'Container', '[0.9,0.1,0]'),
  (3, 'Database', '[0,0,1]');
SELECT judul, round((embedding <-> '[1,0,0]')::numeric, 3) AS jarak
FROM lab_embeddings ORDER BY embedding <-> '[1,0,0]' LIMIT 3;
