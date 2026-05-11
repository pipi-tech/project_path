#!/bin/bash
# WHAT:  Project creation command — new <name> opens editor, builds, then enters project
# WIRES: Sourced by functions.sh → calls engines/builder/src/build.sh → then proj()
# WHY:   Interface layer for project creation — coordinates builder + proj entry in one command

new() {
  local name="$1"
  local template="$PTH_ROOT/cmd/config/template/blank.toml"
  local input="$PTH_ROOT/builder/input/test.toml"

  if [ -z "$name" ]; then
    echo "usage: new <project-name>"
    return 1
  fi

  if _proj_exists "$name"; then
    echo "project '$name' already exists"
    return 1
  fi

  echo "--- preparing template for: $name"
  cp "$template" "$input"
  sed -i "s|^name.*=.*|name        = \"$name\"|" "$input"

  echo "--- opening editor"
  bash "$PTH_ROOT/engines/builder/src/build.sh" "$input"

  echo "--- entering project"
  proj "$name"
}
