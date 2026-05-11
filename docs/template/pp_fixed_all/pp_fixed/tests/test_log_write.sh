#!/bin/bash
# WHAT:  Verifies the log event system can write to all expected input directories
# WIRES: Tests data/log/ write paths used by engines/builder/src/ and engines/doc_worker/src/
# WHY:   Log writes fail silently if dirs are missing — this surfaces missing structure before runtime

source "$(dirname "$0")/../functions.sh"
FAIL=0
TS=$(date '+%Y-%m-%d_%H-%M-%S')

# Test each log domain write
declare -A write_tests=(
  ["builder_build_start"]="data/log/builder/input/build_start/${TS}_test.txt"
  ["registry_registered"]="data/log/registry/input/registered/${TS}_test.txt"
  ["dep_install"]="data/log/dep/input/install/${TS}_test.txt"
  ["terminal_who"]="data/log/terminal/input/who/${TS}_test.txt"
)

for name in "${!write_tests[@]}"; do
  path="$PTH_ROOT/${write_tests[$name]}"
  dir=$(dirname "$path")
  if mkdir -p "$dir" && echo "test=true" > "$path" 2>/dev/null; then
    echo "PASS: write to $name"
    rm -f "$path"
  else
    echo "FAIL: cannot write to $name ($dir)"
    ((FAIL++))
  fi
done

echo ""
echo "--- $FAIL failed"
[ $FAIL -eq 0 ] && exit 0 || exit 1
