#!/usr/bin/env bash
# Restore volumes from a backup made by scripts/backup.sh.
#
# Usage: scripts/restore.sh [-y] BACKUP_DIR [VOLUME ...]
#
# Restores every archive in BACKUP_DIR, or only the named volumes. The
# contents of each restored volume are REPLACED. Running containers are
# stopped first and started again afterwards. Volumes that do not exist yet
# are created with the labels docker compose expects.
#
#   -y   do not ask for confirmation
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

YES=0
if [ "${1:-}" = -y ]; then YES=1; shift; fi
BACKUP=${1:?usage: restore.sh [-y] BACKUP_DIR [VOLUME ...]}
shift
BACKUP=$(cd "$BACKUP" && pwd)

if [ $# -gt 0 ]; then
  VOLUMES=("$@")
else
  mapfile -t VOLUMES < <(cd "$BACKUP" && ls -- *.tar.gz | sed 's/\.tar\.gz$//')
fi
for vol in "${VOLUMES[@]}"; do
  [ -f "$BACKUP/$vol.tar.gz" ] || die "no archive for '$vol' in $BACKUP"
done

log "Verifying checksums ..."
( cd "$BACKUP" && sha256sum --check --quiet --ignore-missing SHA256SUMS ) >&2 \
  || die "checksum mismatch, refusing to restore"

if [ "$YES" = 0 ]; then
  read -r -p "Replace the contents of ${VOLUMES[*]} in project '$PROJECT'? [y/N] " answer
  [ "$answer" = y ] || die "aborted"
fi

trap restart_stack EXIT
stop_stack

for vol in "${VOLUMES[@]}"; do
  full=${PROJECT}_${vol}
  if ! docker volume inspect "$full" >/dev/null 2>&1; then
    docker volume create \
      --label "com.docker.compose.project=$PROJECT" \
      --label "com.docker.compose.volume=$vol" "$full" >/dev/null
  fi
  log "Restoring $vol ..."
  docker run --rm -v "$full:/data" -v "$BACKUP:/backup:ro" "$BACKUP_IMAGE" sh -c '
    set -e
    find /data -mindepth 1 -delete
    tar -C /data --numeric-owner -xzf "/backup/'"$vol"'.tar.gz"'
done
log "Restored: ${VOLUMES[*]}"
