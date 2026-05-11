#!/bin/bash
# WHAT:  Combines terminal session input fragments (when/who/terminal/project) into a single session.log
# WIRES: Called after terminal log scripts run → reads data/log/terminal/input/ → writes data/log/terminal/output/session.log
# WHY:   Assembles the fragmented terminal event inputs into one readable session record

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/.." && pwd)"

LOG="$PTH_ROOT/data/log/terminal/output/session.log"
INPUT="$PTH_ROOT/data/log/terminal/input"

echo "---"                                >> "$LOG"
cat "$INPUT/when.txt"                     >> "$LOG"
cat "$INPUT/who.txt"                      >> "$LOG"
cat "$INPUT/terminal.txt"                 >> "$LOG"
echo "project: $(cat "$INPUT/project.txt")" >> "$LOG"
