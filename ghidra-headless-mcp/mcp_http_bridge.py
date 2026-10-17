#!/usr/bin/env python3
"""Expose a stdio MCP server as a streamable-HTTP MCP endpoint at /mcp.

Usage: mcp_http_bridge.py <command> [args...]
"""
import os
import sys

from fastmcp.server import create_proxy


def main() -> None:
    command, *args = sys.argv[1:]
    proxy = create_proxy(
        {"mcpServers": {"backend": {"command": command, "args": args}}},
        # Negotiate with the stdio backend on its own terms instead of
        # mirroring the HTTP client's protocol era, which it may not speak.
        mode="auto",
        name="mcp-http-bridge",
    )
    proxy.run(
        transport="http",
        host="0.0.0.0",
        port=int(os.environ.get("PORT", "80")),
    )


if __name__ == "__main__":
    main()
