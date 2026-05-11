#!/bin/bash
# WHAT:  Parses project.toml and exports PROJECT_NAME, PROJECT_TYPE, PROJECT_ENV, PROJECT_PYTHON
# WIRES: Sourced by build.sh and functions/builder.sh → exports env vars used by all build steps
# WHY:   Single toml parse point — all downstream scripts read exported vars, never re-parse
TOML="$1"
[ -z "$TOML" ] && echo "no toml provided" && exit 1
[ ! -f "$TOML" ] && echo "toml not found: $TOML" && exit 1

get_val() {
  grep "^$1" "$TOML" | cut -d'=' -f2 | tr -d ' "' 
}

PROJECT_NAME=$(get_val "name")
PROJECT_TYPE=$(get_val "domain")
PROJECT_ENV=$(get_val "env")
PROJECT_PYTHON=$(get_val "python")

export PROJECT_NAME PROJECT_TYPE PROJECT_ENV PROJECT_PYTHON
