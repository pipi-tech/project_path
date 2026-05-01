#!/bin/bash
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
