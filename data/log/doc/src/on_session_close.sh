#!/bin/bash
[ -z "$1" ] && exit 0
PROJECT="$1"; SESSION_FILE="$2"; DURATION="$3"; TS="$4"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PP_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"
DIR="$PP_ROOT/data/log/doc/input/session"
mkdir -p "$DIR"
cat > "$DIR/${PROJECT}_close_${TS}.txt" << ENTRY
project=$PROJECT
session_file=$SESSION_FILE
duration_seconds=$DURATION
ts=$TS
user=$USER
node=$(hostname)
event=session_close
ENTRY
