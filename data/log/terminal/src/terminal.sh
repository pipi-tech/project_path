#!/bin/bash
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SELF_DIR/../input/terminal"
mkdir -p "$DIR"
TTY_VAL=$(tty 2>/dev/null || echo "no-tty")
echo "TERM: $TERM" > "$DIR/$2.txt"
echo "TTY: $TTY_VAL" >> "$DIR/$2.txt"
echo "PPID: $PPID" >> "$DIR/$2.txt"
echo "SESSION: $XDG_SESSION_ID" >> "$DIR/$2.txt"
echo "DISPLAY: $DISPLAY" >> "$DIR/$2.txt"
