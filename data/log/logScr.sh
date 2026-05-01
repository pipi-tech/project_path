#!/bin/bash
[ -z "$1" ] && exit 0
TS=$(date '+%Y-%m-%d_%H-%M-%S')
PROJECT="$1"
PARENT_PID="${2:-$$}"
LOG_BASE=~/project/project_path/data/log
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
