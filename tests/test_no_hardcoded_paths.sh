#!/bin/bash
# WHAT:  Scans all .sh and .py files for hardcoded ~/project/project_path or /home/<user> paths
# WIRES: Tests entire codebase — catches portability regressions in any script
# WHY:   Hardcoded paths are the single biggest blocker for public use — this must never regress

PTH_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

sh_matches=$(grep -r "~/project/project_path" --include="*.sh" "$PTH_ROOT" 2>/dev/null \
  | grep -v ".git" | grep -v "docs/template/pp_fixed_all" | grep -v "tests/test_no_hardcoded_paths.sh")

py_matches=$(grep -r "/home/maven" --include="*.py" "$PTH_ROOT" 2>/dev/null \
  | grep -v ".git" | grep -v "__pycache__" | grep -v "docs/template/pp_fixed_all")

if [ -z "$sh_matches" ] && [ -z "$py_matches" ]; then
  echo "PASS: no hardcoded paths found"
else
  [ -n "$sh_matches" ] && echo "FAIL: hardcoded paths in .sh files:" && echo "$sh_matches" && FAIL=1
  [ -n "$py_matches" ] && echo "FAIL: hardcoded paths in .py files:" && echo "$py_matches" && FAIL=1
fi

echo ""
echo "--- $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
