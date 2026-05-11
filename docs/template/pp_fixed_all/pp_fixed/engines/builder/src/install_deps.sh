#!/bin/bash
# WHAT:  Installs pip packages declared in project.toml requires field
# WIRES: Called by engines/builder/src/build.sh → reads project.toml → runs pip install
# WHY:   Reproducible installs — drives deps from the toml declaration, not manual pip
TOML="$1"
[ -z "$TOML" ] && echo "no toml provided" && exit 1

DEPS=$(grep "^requires" "$TOML" | cut -d'=' -f2 | tr -d '[]"' | tr ',' ' ')

[ -z "$DEPS" ] && echo "no dependencies found" && exit 0

echo "installing: $DEPS"
pip install $DEPS --break-system-packages
