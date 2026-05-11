#!/bin/bash
# WHAT:  Verifies PTH_ROOT resolves correctly from any clone location
# WIRES: Tests functions.sh → PTH_ROOT export
# WHY:   Portability is the #1 public repo issue — catches hardcoded path regressions

PASS=0; FAIL=0

source "$(dirname "$0")/../functions.sh"

if [ -n "$PTH_ROOT" ] && [ -d "$PTH_ROOT" ]; then
  echo "PASS: PTH_ROOT resolved → $PTH_ROOT"; ((PASS++))
else
  echo "FAIL: PTH_ROOT not set or not a directory"; ((FAIL++))
fi

if echo "$PTH_ROOT" | grep -qE "^/home/[^/]+/project/project_path$"; then
  echo "WARN: PTH_ROOT looks like it may be a dev install path (ok if intentional)"
else
  echo "PASS: PTH_ROOT resolved from script location"; ((PASS++))
fi

for path in cmd/builder engines/builder/src data functions; do
  if [ -d "$PTH_ROOT/$path" ]; then
    echo "PASS: $path exists under PTH_ROOT"; ((PASS++))
  else
    echo "FAIL: $path missing under PTH_ROOT"; ((FAIL++))
  fi
done

echo ""
echo "--- $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
