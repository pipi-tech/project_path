#!/bin/bash
# WHAT:  Drift check interface wrapper — calls engines/builder/src/drift.sh
# WIRES: Called by functions/builder.sh → delegates to engines/builder/src/drift.sh
# WHY:   cmd/ is the stable interface; engines/ owns the drift detection logic

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../.." && pwd)"
bash "$PTH_ROOT/engines/builder/src/drift.sh" "$@"
