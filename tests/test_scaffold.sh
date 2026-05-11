#!/bin/bash
# WHAT:  Verifies scaffold.sh created the expected data/log/ directory structure
# WIRES: Tests scaffold.sh output — checks data/ directories exist
# WHY:   Missing log directories cause silent failures at runtime — catch them early

PTH_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0; FAIL=0

required_dirs=(
  "data/log/terminal/input"
  "data/log/builder/input"
  "data/log/registry/input"
  "data/log/dep/input"
  "data/log/doc/input"
  "engines/builder/input"
)

for d in "${required_dirs[@]}"; do
  if [ -d "$PTH_ROOT/$d" ]; then
    echo "PASS: $d exists"; ((PASS++))
  else
    echo "FAIL: $d missing — run scaffold.sh"; ((FAIL++))
  fi
done

echo ""
echo "--- $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
