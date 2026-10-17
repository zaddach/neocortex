FROM python:3.13-slim

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y gcc && \
    pip install uv && \
    uv venv /app/.venv && \
    uv pip install --python /app/.venv/bin/python \
        "mcp<2" \
        https://github.com/zaddach/angrMCP/archive/80af15dc5d6abcc246504852ad426e1208abd30c.zip && \
    uv venv /app/bridge && \
    uv pip install --python /app/bridge/bin/python "fastmcp>=4,<5"

COPY mcp_http_bridge.py /app/mcp_http_bridge.py

EXPOSE 80
USER 65532:65532
# The bridge lives in its own venv: fastmcp 4 needs mcp 2.x, while angrMCP is
# written against the mcp 1.x API.
ENTRYPOINT ["/app/bridge/bin/python", "/app/mcp_http_bridge.py", "/app/.venv/bin/python", "-m", "angr_mcp"]