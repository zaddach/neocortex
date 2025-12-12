CREATE USER openwebui WITH PASSWORD 'openwebui_password';
CREATE DATABASE openwebui_db OWNER openwebui;
GRANT ALL PRIVILEGES ON DATABASE openwebui_db TO openwebui;

CREATE USER rag WITH PASSWORD 'rag_password';
CREATE DATABASE rag_db OWNER rag;
GRANT ALL PRIVILEGES ON DATABASE rag_db TO rag;

\c rag_db

CREATE EXTENSION IF NOT EXISTS vector;