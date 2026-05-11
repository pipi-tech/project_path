#!/bin/bash
# WHAT:  Compares expected deps from toml vs installed pip packages
# WIRES: Called by engines/builder/src/build.sh → reads project.toml
# WHY:   Validation step — surface missing deps before they cause runtime failures
TOML="$1"
[ -z "$TOML" ] && echo "no toml provided" && exit 1

EXPECTED=$(grep "^requires" "$TOML" | cut -d'=' -f2 | tr -d '[]" ' | tr ',' '\n' | sort)
INSTALLED=$(pip freeze 2>/dev/null | cut -d'=' -f1 | tr '[:upper:]' '[:lower:]' | sort)

echo "--- dep comparison"
while IFS= read -r dep; do
  [ -z "$dep" ] && continue
  if echo "$INSTALLED" | grep -qi "^$dep$"; then
    echo "  ✓ $dep"
  else
    echo "  ✗ $dep MISSING"
  fi
done <<< "$EXPECTED"
