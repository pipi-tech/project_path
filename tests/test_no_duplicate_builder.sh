#!/bin/bash
# WHAT:  Verifies root builder/ has been removed and engines/builder/src is the canonical location
# WIRES: Tests repo structure — ensures the duplicate is gone
# WHY:   Two copies of build.sh caused confusion; engines/ is the single source of truth

PTH_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0; FAIL=0

if [ -d "$PTH_ROOT/builder/src" ]; then
  echo "FAIL: root builder/src/ still exists — should have been deleted"; ((FAIL++))
else
  echo "PASS: root builder/ is gone"; ((PASS++))
fi

if [ -d "$PTH_ROOT/engines/builder/src" ]; then
  echo "PASS: engines/builder/src/ exists"; ((PASS++))
else
  echo "FAIL: engines/builder/src/ missing"; ((FAIL++))
fi

if [ -f "$PTH_ROOT/engines/builder/input/test.toml" ]; then
  echo "PASS: engines/builder/input/test.toml exists"; ((PASS++))
else
  echo "FAIL: engines/builder/input/test.toml missing"; ((FAIL++))
fi

echo ""
echo "--- $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
