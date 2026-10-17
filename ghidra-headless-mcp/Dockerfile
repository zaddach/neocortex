FROM kalilinux/kali-rolling:latest

# `ghidra` pulls in a suitable JDK as a dependency. Install location is the
# Kali packaging convention; verify with `docker compose run ghidra-headless-mcp
# ls /usr/share/ghidra` if analysis fails to start.
#
# Python 3.13 rather than Kali's default python3: pyghidra pins JPype1==1.5.2,
# which has no wheel for newer Pythons and would otherwise need a C++
# toolchain to build from source.
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3.13 python3.13-venv ghidra && \
    rm -rf /var/lib/apt/lists/*

ENV GHIDRA_INSTALL_DIR=/usr/share/ghidra
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

WORKDIR /app
RUN python3.13 -m venv /app/.venv && \
    /app/.venv/bin/pip install --upgrade pip && \
    /app/.venv/bin/pip install \
        "fastmcp>=4,<5" \
        https://github.com/mrphrazer/ghidra-headless-mcp/archive/307b461cdbbedfbafb3771333f21875b745f940e.zip

COPY mcp_http_bridge.py /app/mcp_http_bridge.py

EXPOSE 80
ENTRYPOINT ["python3", "/app/mcp_http_bridge.py", "ghidra-headless-mcp", "--ghidra-install-dir", "/usr/share/ghidra"]
