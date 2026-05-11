#!/bin/bash
# WHAT:  Ensures builder/src/ has been removed and engines/builder/src/ is the only copy
# WIRES: Tests structural invariant — builder/src/ should not exist
# WHY:   Catches accidental re-introduction of the duplicate builder directory

FAIL=0

PTH_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ -d "$PTH_ROOT/builder/src" ]; then
  echo "FAIL: builder/src/ still exists — should be removed, engines/builder/src/ is canonical"
  ((FAIL++))
else
  echo "PASS: builder/src/ removed correctly"
fi

if [ -d "$PTH_ROOT/engines/builder/src" ]; then
  echo "PASS: engines/builder/src/ exists"
else
  echo "FAIL: engines/builder/src/ missing"
  ((FAIL++))
fi

echo ""
echo "--- $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
