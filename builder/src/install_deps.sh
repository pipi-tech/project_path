#!/bin/bash
TOML="$1"
[ -z "$TOML" ] && echo "no toml provided" && exit 1

DEPS=$(grep "^requires" "$TOML" | cut -d'=' -f2 | tr -d '[]"' | tr ',' ' ')

[ -z "$DEPS" ] && echo "no dependencies found" && exit 0

echo "installing: $DEPS"
pip install $DEPS --break-system-packages
