FROM golang:1.25-alpine AS builder

LABEL io.modelcontextprotocol.server.name="io.github.neo4j/mcp"

WORKDIR /build

ARG GIT_BRANCH=main

ADD https://github.com/neo4j/mcp/raw/refs/heads/${GIT_BRANCH}/go.mod ./
ADD https://github.com/neo4j/mcp/raw/refs/heads/${GIT_BRANCH}/go.sum ./

RUN go mod download

RUN wget -O - https://github.com/neo4j/mcp/archive/refs/heads/main.tar.gz | tar xz --strip-components=1

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -C cmd/neo4j-mcp -a -installsuffix cgo \
    -o ../../neo4j-mcp

# Runtime stage
FROM python:3.13-slim

WORKDIR /app

# Copy binary from builder
COPY --from=builder /build/neo4j-mcp /app/neo4j-mcp

RUN pip install mcpo

# Run as non-root user (UID 65532 is a standard non-root user ID)
USER 65532:65532
EXPOSE 80

# Set entrypoint
ENTRYPOINT ["mcpo", "--host", "0.0.0.0", "--port", "80", "--", "/app/neo4j-mcp"]