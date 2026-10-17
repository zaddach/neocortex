# Shared settings for proxying streamable-HTTP MCP endpoints, which keep
# long-lived connections open and stream SSE-style chunks over them.
proxy_http_version 1.1;
# $http_host keeps the port: the MCP servers' DNS-rebinding guards match
# "localhost:*" and reject a bare "localhost".
proxy_set_header Host $http_host;
proxy_set_header Connection "";
proxy_buffering off;
proxy_read_timeout 3600s;
proxy_send_timeout 3600s;
