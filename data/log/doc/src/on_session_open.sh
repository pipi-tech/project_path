#!/bin/bash
[ -z "$1" ] && exit 0
PROJECT="$1"; SESSION_FILE="$2"; TS="$3"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PP_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"
DIR="$PP_ROOT/data/log/doc/input/session"
mkdir -p "$DIR"
cat > "$DIR/${PROJECT}_open_${TS}.txt" << ENTRY
project=$PROJECT
session_file=$SESSION_FILE
ts=$TS
user=$USER
node=$(hostname)
tty=$(tty 2>/dev/null || echo no-tty)
event=session_open
ENTRY
