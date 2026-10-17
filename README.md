# neocortex

A set of dockerized MCP servers for reverse engineering and vulnerability discovery, meant to be used directly from the Claude CLI running on the host (outside Docker).

## MCP servers

- **angr-mcp** — binary analysis / symbolic execution via [angr](https://github.com/zaddach/angrMCP).
- **ghidra-headless-mcp** — headless Ghidra analysis via [mrphrazer/ghidra-headless-mcp](https://github.com/mrphrazer/ghidra-headless-mcp). Runs on a Kali base image that packages Ghidra; `GHIDRA_INSTALL_DIR` is assumed to be `/usr/share/ghidra` (Kali's packaging convention) — verify with `docker compose run ghidra-headless-mcp ls /usr/share/ghidra` if analysis fails to start.
- **cognee-mcp** — knowledge-graph memory for analysis findings, via the official [cognee-mcp](https://github.com/topoteretes/cognee) image, using the local Ollama instance for both LLM and embeddings (no external API key needed). It shares its storage volumes with the `cognee` REST API server, so memories added over MCP show up in the `cognee-ui` web UI and vice versa. Cognee's graph lives in a `neo4j` container (Community edition, so cognee runs in single-user mode with `ENABLE_BACKEND_ACCESS_CONTROL=false`: all datasets share one graph). Set `NEO4J_PASSWORD` to change the default password; do so before the first start, as Neo4j only reads it when it creates its data volume.
- **hindsight** — agent memory (retain / recall / reflect) from [vectorize-io/hindsight](https://github.com/vectorize-io/hindsight), using Ollama for the LLM and its built-in local embedding model. The one container runs the API, the MCP server and a web control plane, with an embedded Postgres in the `hindsight_data` volume.

Each of these speaks native MCP over streamable HTTP. An nginx gateway (`mcp-gateway`) fronts all of them, and the reverse proxy below publishes it under `/mcp/` on port **8080**, so the Claude CLI can reach them without joining the Docker network:

| Path | Backend |
|---|---|
| `http://localhost:8080/mcp/angr/` | angr-mcp |
| `http://localhost:8080/mcp/ghidra/` | ghidra-headless-mcp |
| `http://localhost:8080/mcp/cognee/` | cognee-mcp |
| `http://localhost:8080/mcp/hindsight/<bank>/` | hindsight, memory bank `<bank>` (created on first use) |

## Web UIs and REST APIs

A second nginx, `reverse-proxy`, exposes every web frontend and REST API on one host port, **8080** (override with `NEOCORTEX_PORT`). It uses name-based virtual hosts under `*.localhost`, which browsers resolve to `127.0.0.1` with no `/etc/hosts` changes; this matters because the Cognee and Hindsight UIs are Next.js apps that can't be served from a sub-path. Open <http://localhost:8080> for a page linking to all of them:

| URL | Backend |
|---|---|
| `http://localhost:8080/filebrowser/` (also `files.localhost`) | filebrowser, for the `malware` volume |
| `http://cognee.localhost:8080` | cognee-ui, plus the cognee API under `/api/v1/` on the same origin |
| `http://cognee-api.localhost:8080/docs` | cognee REST API |
| `http://hindsight.localhost:8080` | hindsight control plane |
| `http://hindsight-api.localhost:8080/docs` | hindsight REST API |
| `http://neo4j.localhost:8080` | Neo4j browser for cognee's graph (log in as `neo4j` with `NEO4J_PASSWORD`, default `neocortex-neo4j`; connect to `neo4j.localhost:8080`) |
| `http://ollama.localhost:8080` | Ollama API |
| `http://localhost:8080/mcp/` | the MCP servers listed above |

The Cognee UI logs in as cognee's default user with the password from `COGNEE_DEFAULT_USER_PASSWORD` (default `default_password`). Non-browser clients such as `curl` may not resolve `*.localhost`; use `curl --resolve cognee.localhost:8080:127.0.0.1 ...` or send a `Host:` header.

## Setup

```sh
docker compose up
```

brings up `ollama`, the MCP servers, the web UIs, the `mcp-gateway` and the `reverse-proxy`. The `ollama-model-init` service pulls the models cognee and hindsight need (`qwen3.5:9b` for the LLM, `nomic-embed-text` for cognee's embeddings) into Ollama on first start and then exits; `cognee` and `hindsight` wait for it to finish before starting. Re-run `docker compose up ollama-model-init` any time to re-pull (e.g. after switching `LLM_MODEL`/`EMBEDDING_MODEL` in `x-cognee-env` or `HINDSIGHT_API_LLM_MODEL`).

## Claude CLI

The project ships a `.mcp.json` pointing at the gateway paths above (`http://localhost:8080/mcp/...`, with hindsight on the `neocortex` bank), so running `claude` from this repo picks up all four MCP servers automatically — confirm with `claude mcp list`. Samples placed in the `malware` Docker volume (browsable/uploadable via the file browser at <http://localhost:8080/filebrowser/>) are visible to `angr-mcp` and `ghidra-headless-mcp` at `/malware`.

## Resources
- https://osintteam.blog/mcp-as-your-malware-analysis-assistant-75c177b2788f
- [FatalSec: Build an AI-Powered Reverse Engineering Lab with Ghidra](https://www.youtube.com/watch?v=WOsVlzEXxJk&pp=ygUKZ2hpZHJhIG1jcA%3D%3D)
- [OALabs: Automated AI Reverse Engineering with MCP for IDA and Ghidra (Live VIBE RE)](https://www.youtube.com/watch?v=iFxNuk3kxhk)
- [Raptor](https://github.com/gadievron/raptor)