#!/bin/bash
# WHAT:  CLI utility commands — msrc, mlog, master reference generators
# WIRES: Sourced by functions.sh → calls $PTH_ROOT/cmd/cli/
# WHY:   Interface layer for CLI tools that generate master reference files

msrc() {
  bash "$PTH_ROOT/cmd/cli/master_src.sh"
}

mlog() {
  bash "$PTH_ROOT/cmd/cli/master_log.sh"
}
