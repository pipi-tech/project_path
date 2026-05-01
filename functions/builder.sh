#!/bin/bash
CMD_BUILDER=~/project/project_path/cmd/builder
CMD_CONFIG=~/project/project_path/cmd/config
BUILDER_INPUT=~/project/project_path/builder/input/test.toml

build() {
  local toml="${1:-$(pwd)/project.toml}"
  if [ ! -f "$toml" ]; then
    echo "no project.toml found in current directory"
    echo "usage: build <path/to/project.toml>"
    return 1
  fi
  bash "$CMD_BUILDER/build.sh" "$toml"
}

deps() {
  local cmd="$1"
  local dep="$2"
  local toml="${3:-$(pwd)/project.toml}"
  [ ! -f "$toml" ] && echo "no project.toml found — run from project root or pass toml path" && return 1

  case "$cmd" in
    compare)
      bash "$CMD_BUILDER/compare_deps.sh" "$toml"
      ;;
    add)
      [ -z "$dep" ] && echo "usage: deps add <dep> [toml]" && return 1
      bash "$CMD_CONFIG/add_dep.sh" "$dep" "" "$toml"
      ;;
    add-only)
      [ -z "$dep" ] && echo "usage: deps add-only <dep> [toml]" && return 1
      bash "$CMD_CONFIG/add_dep.sh" "$dep" "--toml" "$toml"
      ;;
    install)
      bash "$CMD_CONFIG/add_dep.sh" "" "--install" "$toml"
      ;;
    *)
      echo "usage: deps [compare|add|add-only|install] <dep> [toml]"
      ;;
  esac
}

drift() {
  local toml="${1:-$(pwd)/project.toml}"
  [ ! -f "$toml" ] && echo "no project.toml found" && return 1
  source ~/project/project_path/builder/src/read_toml.sh "$toml"
  bash "$CMD_BUILDER/drift.sh"
}

fingerprint() {
  local toml="${1:-$(pwd)/project.toml}"
  [ ! -f "$toml" ] && echo "no project.toml found" && return 1
  source ~/project/project_path/builder/src/read_toml.sh "$toml"
  source "$CMD_BUILDER/fingerprint.sh" "$toml"
}
