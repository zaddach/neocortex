#!/usr/bin/env bash
# Back up the data of every Docker volume in this compose project.
#
# Usage: scripts/backup.sh [-o DIR] [--include-ollama] [--hot]
#
# Writes DIR/neocortex-<timestamp>/<volume>.tar.gz plus SHA256SUMS and
# MANIFEST. By default the running containers are stopped for the duration
# (neo4j, hindsight's embedded Postgres and cognee's SQLite are not safe to
# copy while running) and started again afterwards, also on failure.
#
#   -o DIR            where to put backups (default: ./backups)
#   --include-ollama  also back up the downloaded models (large; they can be
#                     re-pulled, so they are skipped by default)
#   --hot             do not stop anything. Faster, but the copy of the
#                     databases may be inconsistent.
#
# The archives contain credentials (e.g. the neo4j and cognee databases), so
# they are written readable by the current user only.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

OUT_ROOT=./backups
INCLUDE_OLLAMA=0
HOT=0
while [ $# -gt 0 ]; do
  case $1 in
    -o) OUT_ROOT=${2:?-o needs a directory}; shift 2 ;;
    --include-ollama) INCLUDE_OLLAMA=1; shift ;;
    --hot) HOT=1; shift ;;
    -h|--help) sed -n '2,/^set -/p' "$0" | sed '$d; s/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown argument: $1 (see --help)" ;;
  esac
done

mkdir -p "$OUT_ROOT"
DEST=$(cd "$OUT_ROOT" && pwd)/neocortex-$(date +%Y%m%d-%H%M%S)
umask 077
mkdir "$DEST"

trap restart_stack EXIT
if [ "$HOT" = 1 ]; then
  log "warning: --hot, databases are copied while running"
else
  stop_stack
fi

: >"$DEST/MANIFEST"
count=0
while read -r vol; do
  [ -n "$vol" ] || continue
  if [ "$vol" = ollama ] && [ "$INCLUDE_OLLAMA" = 0 ]; then
    log "Skipping ollama (models can be re-pulled; use --include-ollama)"
    continue
  fi
  log "Backing up $vol ..."
  docker run --rm \
    -v "${PROJECT}_${vol}:/data:ro" -v "$DEST:/backup" \
    -e "HOST_UID=$(id -u)" -e "HOST_GID=$(id -g)" \
    "$BACKUP_IMAGE" sh -c '
      set -e
      tar -C /data --numeric-owner -czf "/backup/'"$vol"'.tar.gz" .
      chown "$HOST_UID:$HOST_GID" "/backup/'"$vol"'.tar.gz"
      chmod 600 "/backup/'"$vol"'.tar.gz"'
  printf '%s\t%s\n' "$vol" "$(du -h "$DEST/$vol.tar.gz" | cut -f1)" >>"$DEST/MANIFEST"
  count=$((count + 1))
done < <(project_volumes)

[ "$count" -gt 0 ] || die "no volumes found for project '$PROJECT'"

( cd "$DEST" && sha256sum -- *.tar.gz >SHA256SUMS )
{
  printf 'created\t%s\nproject\t%s\nhot\t%s\n' "$(date -Is)" "$PROJECT" "$HOT"
} >>"$DEST/MANIFEST"

log "Backup written to $DEST"
cat "$DEST/MANIFEST" >&2
echo "$DEST"
