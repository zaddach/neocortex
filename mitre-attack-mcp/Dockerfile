FROM python:3.13-slim

RUN pip install mcpo https://github.com/stoyky/mitre-attack-mcp/archive/9ebd694bfc9869e81d5d1a3d3e7964e31a1e9087.zip
RUN adduser --home=/app user
WORKDIR /app

EXPOSE 80
USER user:user
ENTRYPOINT ["mcpo", "--port", "80", "--", "mitre-attack-mcp"]


