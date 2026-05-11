#!/bin/bash
# WHAT:  Launches the TUI dashboard
# WIRES: Sourced by functions.sh → calls cmd/tui/dashboard.py
# WHY:   Interface layer for the terminal UI — single command to launch the dashboard

tui() {
  python3 "$PTH_ROOT/cmd/tui/dashboard.py"
}
