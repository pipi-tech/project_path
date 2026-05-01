#!/bin/bash
BUILDER=~/project/project_path/builder
TEMPLATE=~/project/project_path/cmd/config/template/blank.toml
INPUT=$BUILDER/input/test.toml

new() {
  local name="$1"

  if [ -z "$name" ]; then
    echo "usage: new <project-name>"
    return 1
  fi

  if _proj_exists "$name"; then
    echo "project '$name' already exists"
    return 1
  fi

  echo "--- preparing template for: $name"
  cp "$TEMPLATE" "$INPUT"
  sed -i "s|^name.*=.*|name        = \"$name\"|" "$INPUT"

  echo "--- opening editor"
  bash "$BUILDER/src/build.sh" "$INPUT"

  echo "--- entering project"
  proj "$name"
}
