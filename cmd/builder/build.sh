#!/bin/bash
# WHAT:  Thin interface wrapper — calls engines/builder/src/build.sh with toml path
# WIRES: Called by functions/builder.sh → delegates to engines/builder/src/build.sh
# WHY:   cmd/ layer provides a stable interface; engines/ can evolve without functions/ knowing

TOML="$1"
[ -z "$TOML" ] && echo "usage: build.sh <path/to/project.toml>" && exit 1

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../.." && pwd)"

bash "$PTH_ROOT/engines/builder/src/build.sh" "$TOML"
