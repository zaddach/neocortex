FROM crystaldba/postgres-mcp

RUN pip install mcpo

EXPOSE 80
ENTRYPOINT ["mcpo", "--port", "80", "--", "/app/docker-entrypoint.sh", "postgres-mcp"]