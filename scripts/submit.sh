#!/usr/bin/env bash
# Upload binaries to the shared `malware` volume so angr-mcp and
# ghidra-headless-mcp can open them at /malware/<name>.
#
# Usage: scripts/submit.sh [-d subdir] [-f] FILE...
#   -d subdir   store under /malware/<subdir>/
#   -f          overwrite an existing sample of the same name
# Environment: NEOCORTEX_URL (default http://localhost:${NEOCORTEX_PORT:-8080})
set -euo pipefail

base=${NEOCORTEX_URL:-http://localhost:${NEOCORTEX_PORT:-8080}}
subdir= force=0
while getopts ':d:fh' opt; do
  case $opt in
    d) subdir=${OPTARG#/}; subdir=${subdir%/} ;;
    f) force=1 ;;
    h) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "usage: $0 [-d subdir] [-f] FILE..." >&2; exit 2 ;;
  esac
done
shift $((OPTIND - 1))
[ $# -gt 0 ] || { echo "usage: $0 [-d subdir] [-f] FILE..." >&2; exit 2; }

rc=0
for file in "$@"; do
  if [ ! -f "$file" ]; then echo "skip: $file is not a file" >&2; rc=1; continue; fi
  rel=${subdir:+$subdir/}$(basename "$file")
  # Percent-encode everything but unreserved characters and '/'.
  enc=$(python3 -c 'import sys,urllib.parse as u; print(u.quote(sys.argv[1]))' "$rel")
  url=$base/samples/$enc
  if [ "$force" = 0 ] && [ "$(curl -s -o /dev/null -w '%{http_code}' -I "$url")" = 200 ]; then
    echo "skip: /malware/$rel already exists (use -f to overwrite)" >&2; rc=1; continue
  fi
  if code=$(curl -sS -o /dev/null -w '%{http_code}' -T "$file" "$url") && [[ $code == 20* ]]; then
    echo "/malware/$rel  sha256=$(sha256sum "$file" | cut -d' ' -f1)"
  else
    echo "error: upload of $file failed (HTTP ${code:-?})" >&2; rc=1
  fi
done
exit $rc
