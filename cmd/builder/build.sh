#!/bin/bash
TOML="$1"
[ -z "$TOML" ] && echo "usage: build.sh <path/to/project.toml>" && exit 1

${EDITOR:-nano} "$TOML"

SRC=~/project/project_path/builder/src
CMD_CFG=~/project/project_path/cmd/config

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
PROJECT_ROOT=~/project/$PROJECT_NAME
cp "$TOML" "$PROJECT_ROOT/project.toml"
echo "toml saved: $PROJECT_ROOT/project.toml"

echo "--- done: $PROJECT_NAME"

echo "--- resetting template"
cp ~/project/project_path/cmd/config/template/blank.toml \
   ~/project/project_path/builder/input/test.toml
echo "template reset"
