#!/bin/bash
# WHAT:  TUI launcher — opens the Textual dashboard
# WIRES: Sourced by functions.sh → calls cmd/tui/dashboard.py
# WHY:   Interface layer for the TUI — keeps python path resolution in one place

tui() {
  python3 "$PTH_ROOT/cmd/tui/dashboard.py"
}
