#!/bin/bash
# WHAT:  Scans all .sh files for hardcoded ~/project/project_path paths
# WIRES: Tests entire codebase — catches portability regressions in any script
# WHY:   Hardcoded paths are the single biggest blocker for public use — this must never regress

PTH_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

matches=$(grep -r "~/project/project_path" --include="*.sh" "$PTH_ROOT" 2>/dev/null | grep -v ".git")

if [ -z "$matches" ]; then
  echo "PASS: no hardcoded paths found"
else
  echo "FAIL: hardcoded paths found:"
  echo "$matches"
  FAIL=1
fi

echo ""
echo "--- $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
