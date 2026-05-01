#!/bin/bash
DEP="$1"
MODE="$2"
TOML="$3"

[ -z "$DEP" ] && echo "usage: add_dep.sh <dep> [--toml|--install] <project.toml>" && exit 1
[ -z "$TOML" ] && TOML="$(pwd)/project.toml"
[ ! -f "$TOML" ] && echo "toml not found: $TOML" && exit 1

CURRENT=$(grep "^requires" "$TOML" | cut -d'=' -f2 | tr -d '[]')
if [ -z "$CURRENT" ] || [ "$CURRENT" = " " ]; then
  NEW="\"$DEP\""
else
  NEW="$CURRENT, \"$DEP\""
fi
sed -i "s|^requires.*=.*|requires    = [$NEW]|" "$TOML"
echo "  added to toml: $DEP"

if [ "$MODE" != "--toml" ]; then
  echo "  installing: $DEP"
  pip install "$DEP" --break-system-packages
  echo "  ✓ installed: $DEP"
else
  echo "  skipped install — run with --install to install later"
fi
