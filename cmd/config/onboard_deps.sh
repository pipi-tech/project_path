#!/bin/bash
# WHAT:  Copies pkg_classes.conf into a project directory as .dep_classes.conf
# WIRES: Called by cmd/config/migrate_toml.sh and functions/config.sh (onboard) → reads cmd/config/pkg_classes.conf
# WHY:   Each project gets its own copy of the classification map so it can be customized per-project

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../.." && pwd)"

PROJECT_ROOT="${1:-$(pwd)}"
CLASSES="$PTH_ROOT/cmd/config/pkg_classes.conf"
TARGET="$PROJECT_ROOT/.dep_classes.conf"

[ ! -f "$CLASSES" ] && echo "no base pkg_classes.conf found" && exit 1

cp "$CLASSES" "$TARGET"
echo "onboarded dep classes → $TARGET"
echo "packages pre-classified: $(grep -v '^#' "$TARGET" | grep -v '^$' | wc -l)"
