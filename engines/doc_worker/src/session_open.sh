#!/bin/bash
PROJECT="$1"; PROJECT_ROOT="$2"; TS="$3"
[ -z "$PROJECT" ]      && echo "no project" && exit 1
[ -z "$PROJECT_ROOT" ] && echo "no project root" && exit 1
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PP_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"
LOG_SRC="$PP_ROOT/data/log/doc/src"
SESSION_FILE="$PROJECT_ROOT/docs/log/session_${TS}.txt"
mkdir -p "$(dirname "$SESSION_FILE")"
TTY_VAL=$(tty 2>/dev/null || echo "no-tty")
cat > "$SESSION_FILE" << HEADER
session: $TS
project: $PROJECT
user: $USER
node: $(hostname)
tty: $TTY_VAL

## what i did
> fill this in after the session

## commands run
> append manually or pipe history here

## notes
> decisions made, things to remember

## end
closed: (filled by session_close.sh)
duration: (filled by session_close.sh)
HEADER
echo "[$PROJECT] session opened: $SESSION_FILE"
echo "$SESSION_FILE"
bash "$LOG_SRC/on_session_open.sh" "$PROJECT" "$SESSION_FILE" "$TS"
