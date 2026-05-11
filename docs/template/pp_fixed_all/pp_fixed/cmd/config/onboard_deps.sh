#!/bin/bash
# WHAT:  Copies pkg_classes.conf into a project root as .dep_classes.conf
# WIRES: Called by functions/config.sh (onboard) → reads cmd/config/pkg_classes.conf
# WHY:   Gives each project a local copy of the dep classification map to customize

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$(pwd)}"
CLASSES="$SELF_DIR/pkg_classes.conf"
TARGET="$PROJECT_ROOT/.dep_classes.conf"

[ ! -f "$CLASSES" ] && echo "no base pkg_classes.conf found" && exit 1

cp "$CLASSES" "$TARGET"
echo "onboarded dep classes → $TARGET"
echo "packages pre-classified: $(grep -v '^#' "$TARGET" | grep -v '^$' | wc -l)"
