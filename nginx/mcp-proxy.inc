# Shared settings for proxying streamable-HTTP MCP endpoints, which keep
# long-lived connections open and stream SSE-style chunks over them.
proxy_http_version 1.1;
# The MCP servers' DNS-rebinding guards only accept "localhost:*" (with a
# port) and answer 421 to anything else, so clients reaching the stack by LAN
# address or hostname are presented to the backends as localhost.
proxy_set_header Host localhost:80;
proxy_set_header Connection "";
proxy_buffering off;
proxy_read_timeout 3600s;
proxy_send_timeout 3600s;
