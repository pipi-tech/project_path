#!/bin/bash
[ -z "$2" ] && exit 0
DIR=~/project/project_path/data/log/terminal/input/who
mkdir -p "$DIR"

TS="$2"
PARENT_PID="${3:-$$}"
SESSION_ID="${XDG_SESSION_ID:-$$}"
TTY_VAL=$(tty 2>/dev/null || echo "no-tty")
DISPLAY_VAL="${DISPLAY:-no-display}"

USER_HASH=$(echo "$USER|$(hostname)|$TTY_VAL|$SESSION_ID|$TS|$DISPLAY_VAL" \
  | sha256sum | cut -d' ' -f1)

echo "$USER"                  > "$DIR/$TS.txt"
echo "hash=$USER_HASH"       >> "$DIR/$TS.txt"
echo "session=$SESSION_ID"   >> "$DIR/$TS.txt"
echo "tty=$TTY_VAL"          >> "$DIR/$TS.txt"
echo "display=$DISPLAY_VAL"  >> "$DIR/$TS.txt"
echo "ppid=$PARENT_PID"      >> "$DIR/$TS.txt"

echo "$USER_HASH" > "/tmp/pp_session_${PARENT_PID}.hash"
