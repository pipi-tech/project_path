#!/bin/bash
DIR=~/project/project_path/data/log/terminal/input/terminal
mkdir -p "$DIR"
TTY_VAL=$(tty 2>/dev/null || echo "no-tty")
echo "TERM: $TERM" > "$DIR/$2.txt"
echo "TTY: $TTY_VAL" >> "$DIR/$2.txt"
echo "PPID: $PPID" >> "$DIR/$2.txt"
echo "SESSION: $XDG_SESSION_ID" >> "$DIR/$2.txt"
echo "DISPLAY: $DISPLAY" >> "$DIR/$2.txt"
