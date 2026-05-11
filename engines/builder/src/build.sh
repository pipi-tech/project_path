#!/bin/bash
# WHAT:  Full build pipeline — reads toml, stamps folders, installs deps, fingerprints, registers, logs each step
# WIRES: Called by cmd/builder/build.sh → calls read_toml, stamp_folders, install_deps, gen_fingerprint, compare_deps, drift, register (all in this dir)
# WHY:   Execution layer — this is where build actually runs; cmd/ is just the interface that calls here

TOML="$1"
[ -z "$TOML" ] && echo "usage: build.sh <path/to/project.toml>" && exit 1

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"
SRC="$SELF_DIR"
CMD_CFG="$PTH_ROOT/cmd/config"
LOG="$PTH_ROOT/data/log/builder/src"
TS=$(date '+%Y-%m-%d_%H-%M-%S')

echo "--- reading toml"
source "$SRC/read_toml.sh" "$TOML"

bash "$LOG/on_build_start.sh" "$PROJECT_NAME" "$TS" "$TOML"

echo "--- stamping folders"
bash "$SRC/stamp_folders.sh"
bash "$LOG/on_build_step.sh" "$PROJECT_NAME" "$TS" "stamp_folders" "done"

echo "--- setting log domains"
bash "$CMD_CFG/set_log_domains.sh" "$TOML"
bash "$LOG/on_build_step.sh" "$PROJECT_NAME" "$TS" "set_log_domains" "done"

echo "--- installing deps"
bash "$SRC/install_deps.sh" "$TOML"
bash "$LOG/on_build_step.sh" "$PROJECT_NAME" "$TS" "install_deps" "done"

echo "--- generating fingerprint"
source "$SRC/gen_fingerprint.sh" "$TOML"
bash "$LOG/on_build_step.sh" "$PROJECT_NAME" "$TS" "gen_fingerprint" "done"

echo "--- comparing deps"
bash "$SRC/compare_deps.sh" "$TOML"
bash "$LOG/on_build_step.sh" "$PROJECT_NAME" "$TS" "compare_deps" "done"

echo "--- checking drift"
bash "$SRC/drift.sh"
bash "$LOG/on_build_step.sh" "$PROJECT_NAME" "$TS" "drift_check" "done"

echo "--- registering"
bash "$SRC/register.sh" "$TOML"
bash "$LOG/on_build_step.sh" "$PROJECT_NAME" "$TS" "register" "done"

echo "--- moving toml to project root"
PROJECT_ROOT="${PROJECT_SAVE_PATH:-$HOME/project}/$PROJECT_NAME"
cp "$TOML" "$PROJECT_ROOT/project.toml"
echo "toml saved: $PROJECT_ROOT/project.toml"

bash "$LOG/on_build_done.sh" "$PROJECT_NAME" "$TS" "$FINGERPRINT_HASH" ""

echo "--- resetting template"
cp "$CMD_CFG/template/blank.toml" \
   "$PTH_ROOT/engines/builder/input/test.toml"
echo "template reset"

echo "--- done: $PROJECT_NAME"
