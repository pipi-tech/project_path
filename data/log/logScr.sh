#!/bin/bash
# WHAT:  Fires all log domain src/*.sh scripts in parallel for a given project/session
# WIRES: Called by functions/proj.sh (proj) → runs data/log/*/src/*.sh in parallel
# WHY:   Single entry point that triggers all log domains simultaneously when a session opens

[ -z "$1" ] && exit 0
TS=$(date '+%Y-%m-%d_%H-%M-%S')
PROJECT="$1"
PARENT_PID="${2:-$$}"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_BASE="$SELF_DIR"
PIPE=$(mktemp -u)
mkfifo "$PIPE"

for domain in "$LOG_BASE"/*/; do
  if [ -d "$domain/src" ]; then
    for script in "$domain/src"/*.sh; do
      [ -f "$script" ] && echo "$script $PROJECT $TS $PARENT_PID"
    done
  fi
done > "$PIPE" &

cat "$PIPE" | xargs -P4 -I{} bash -c '{}'
rm -f "$PIPE"
