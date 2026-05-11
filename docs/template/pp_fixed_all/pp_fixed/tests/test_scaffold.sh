#!/bin/bash
# WHAT:  Verifies scaffold.sh creates the required data/log/ directory structure
# WIRES: Tests scaffold.sh → data/log/*
# WHY:   Fresh install must not silently break logging — missing dirs cause silent failures

source "$(dirname "$0")/../functions.sh"
FAIL=0

required_dirs=(
  "data/log/terminal/input/who"
  "data/log/terminal/input/when"
  "data/log/builder/input/build_done"
  "data/log/builder/input/build_start"
  "data/log/builder/input/build_step"
  "data/log/registry/input/registered"
  "data/log/registry/input/drift"
  "data/log/dep/input/install"
  "data/log/dep/input/before"
  "data/log/dep/input/after"
  "data/log/dep/input/diff"
  "data/log/doc/src"
)

for d in "${required_dirs[@]}"; do
  if [ -d "$PTH_ROOT/$d" ]; then
    echo "PASS: $d exists"
  else
    echo "FAIL: $d missing — run scaffold.sh first"; ((FAIL++))
  fi
done

echo ""
echo "--- $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
