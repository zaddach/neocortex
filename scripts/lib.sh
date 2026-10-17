# Shared helpers for backup.sh and restore.sh. Source this; do not run it.

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Small image with busybox tar, used to read/write volumes.
BACKUP_IMAGE=${BACKUP_IMAGE:-alpine:3}

PROJECT=$(docker compose config --format json | python3 -c 'import json,sys; print(json.load(sys.stdin)["name"])')
DECLARED_SERVICES=$(docker compose config --services)

log() { printf '%s\n' "$*" >&2; }
die() { log "error: $*"; exit 1; }

# Containers of this project that are currently running, split into services
# declared in docker-compose.yaml and orphans (e.g. left over from an older
# compose file). Sets RUNNING_SERVICES, RUNNING_ORPHANS (container names).
RUNNING_SERVICES=()
RUNNING_ORPHANS=()
STOPPED=0

list_running() {
  RUNNING_SERVICES=()
  RUNNING_ORPHANS=()
  local name service
  while IFS=$'\t' read -r name service; do
    [ -n "$name" ] || continue
    if grep -qx -- "$service" <<<"$DECLARED_SERVICES"; then
      RUNNING_SERVICES+=("$service")
    else
      RUNNING_ORPHANS+=("$name")
    fi
  done < <(docker ps --filter "label=com.docker.compose.project=$PROJECT" \
             --format '{{.Names}}\t{{.Label "com.docker.compose.service"}}')
}

# Stop everything that is running, remembering what to bring back.
stop_stack() {
  list_running
  local names
  names=$(docker ps --filter "label=com.docker.compose.project=$PROJECT" --format '{{.Names}}')
  if [ -n "$names" ]; then
    log "Stopping: $(tr '\n' ' ' <<<"$names")"
    # shellcheck disable=SC2086
    docker stop -t 60 $names >/dev/null
  fi
  STOPPED=1
}

# Start back what stop_stack stopped. `up --no-recreate` honours depends_on,
# so e.g. cognee waits for neo4j to be healthy.
restart_stack() {
  [ "$STOPPED" = 1 ] || return 0
  STOPPED=0
  if [ ${#RUNNING_SERVICES[@]} -gt 0 ]; then
    log "Starting: ${RUNNING_SERVICES[*]}"
    docker compose up -d --no-recreate --no-build "${RUNNING_SERVICES[@]}" >&2
  fi
  if [ ${#RUNNING_ORPHANS[@]} -gt 0 ]; then
    log "Starting orphans: ${RUNNING_ORPHANS[*]}"
    docker start "${RUNNING_ORPHANS[@]}" >/dev/null
  fi
}

# Volumes of this project as "<short name>" lines (the name used in the
# compose file, without the project prefix).
project_volumes() {
  docker volume ls --filter "label=com.docker.compose.project=$PROJECT" \
    --format '{{.Label "com.docker.compose.volume"}}'
}
