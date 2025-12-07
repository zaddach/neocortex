FROM python:3.13-slim

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

RUN pip install uv && \
    uv venv /app/.venv && \
    uv pip install --python /app/.venv/bin/python \
        mcpo \
        https://github.com/zaddach/angrMCP/archive/80af15dc5d6abcc246504852ad426e1208abd30c.zip

EXPOSE 80
USER 65532:65532
ENTRYPOINT ["mcpo", "--port", "80", "--", "python", "-m", "angr_mcp"]