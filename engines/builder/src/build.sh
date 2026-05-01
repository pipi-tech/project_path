#!/bin/bash
TOML="$1"
[ -z "$TOML" ] && echo "usage: build.sh <path/to/project.toml>" && exit 1

${EDITOR:-nano} "$TOML"

SRC=~/project/project_path/builder/src
CMD_CFG=~/project/project_path/cmd/config
LOG=~/project/project_path/data/log/builder/src
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
PROJECT_ROOT=~/project/$PROJECT_NAME
cp "$TOML" "$PROJECT_ROOT/project.toml"
echo "toml saved: $PROJECT_ROOT/project.toml"

bash "$LOG/on_build_done.sh" "$PROJECT_NAME" "$TS" "$FINGERPRINT_HASH" ""

echo "--- resetting template"
cp "$CMD_CFG/template/blank.toml" \
   ~/project/project_path/builder/input/test.toml
echo "template reset"

echo "--- done: $PROJECT_NAME"
