#!/bin/bash
# WHAT:  Thin interface wrapper — calls engines/builder/src/build.sh with toml path
# WIRES: Called by functions/builder.sh → delegates to engines/builder/src/build.sh
# WHY:   cmd/ layer provides a stable interface; engines/ can evolve without functions/ knowing

TOML="$1"
[ -z "$TOML" ] && echo "usage: build.sh <path/to/project.toml>" && exit 1

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../.." && pwd)"
SRC="$PTH_ROOT/engines/builder/src"
CMD_CFG="$PTH_ROOT/cmd/config"

${EDITOR:-nano} "$TOML"

echo "--- reading toml"
source "$SRC/read_toml.sh" "$TOML"

echo "--- stamping folders"
bash "$SRC/stamp_folders.sh"

echo "--- setting log domains"
bash "$CMD_CFG/set_log_domains.sh" "$TOML"

echo "--- installing deps"
bash "$SRC/install_deps.sh" "$TOML"

echo "--- generating fingerprint"
source "$SRC/gen_fingerprint.sh" "$TOML"

echo "--- comparing deps"
bash "$SRC/compare_deps.sh" "$TOML"

echo "--- checking drift"
bash "$SRC/drift.sh"

echo "--- registering"
bash "$SRC/register.sh" "$TOML"

echo "--- moving toml to project root"
PROJECT_ROOT="$HOME/project/$PROJECT_NAME"
cp "$TOML" "$PROJECT_ROOT/project.toml"
echo "toml saved: $PROJECT_ROOT/project.toml"

echo "--- resetting template"
cp "$CMD_CFG/template/blank.toml" \
   "$PTH_ROOT/builder/input/test.toml"
echo "template reset"

echo "--- done: $PROJECT_NAME"
