#!/bin/bash
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
