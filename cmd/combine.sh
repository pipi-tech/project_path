#!/bin/bash
# WHAT:  Combines terminal input fragments into a single session log file
# WIRES: Reads data/log/terminal/input/ → writes data/log/terminal/output/session.log
# WHY:   Terminal log fragments are written separately; this combines them into one readable record

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/.." && pwd)"

LOG="$PTH_ROOT/data/log/terminal/output/session.log"
INPUT="$PTH_ROOT/data/log/terminal/input"

echo "---" >> "$LOG"
cat "$INPUT/when.txt" >> "$LOG"
cat "$INPUT/who.txt" >> "$LOG"
cat "$INPUT/terminal.txt" >> "$LOG"
echo "project: $(cat "$INPUT/project.txt")" >> "$LOG"
