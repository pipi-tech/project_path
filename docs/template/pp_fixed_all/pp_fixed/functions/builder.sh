#!/bin/bash
# WHAT:  User-facing build commands — build, deps, drift, fingerprint
# WIRES: Sourced by functions.sh → calls $PTH_ROOT/cmd/builder/ → engines/builder/src/
# WHY:   Interface layer — validates input, delegates execution to cmd/ which calls engines/

build() {
  local toml="${1:-$(pwd)/project.toml}"
  if [ ! -f "$toml" ]; then
    echo "no project.toml found in current directory"
    echo "usage: build <path/to/project.toml>"
    return 1
  fi
  bash "$PTH_ROOT/cmd/builder/build.sh" "$toml"
}

deps() {
  local cmd="$1"
  local dep="$2"
  local toml="${3:-$(pwd)/project.toml}"
  [ ! -f "$toml" ] && echo "no project.toml found — run from project root or pass toml path" && return 1

  case "$cmd" in
    compare)
      bash "$PTH_ROOT/cmd/builder/compare_deps.sh" "$toml"
      ;;
    add)
      [ -z "$dep" ] && echo "usage: deps add <dep> [toml]" && return 1
      bash "$PTH_ROOT/cmd/config/add_dep.sh" "$dep" "" "$toml"
      ;;
    add-only)
      [ -z "$dep" ] && echo "usage: deps add-only <dep> [toml]" && return 1
      bash "$PTH_ROOT/cmd/config/add_dep.sh" "$dep" "--toml" "$toml"
      ;;
    install)
      bash "$PTH_ROOT/cmd/config/add_dep.sh" "" "--install" "$toml"
      ;;
    *)
      echo "usage: deps [compare|add|add-only|install] <dep> [toml]"
      ;;
  esac
}

drift() {
  local toml="${1:-$(pwd)/project.toml}"
  [ ! -f "$toml" ] && echo "no project.toml found" && return 1
  source "$PTH_ROOT/engines/builder/src/read_toml.sh" "$toml"
  bash "$PTH_ROOT/cmd/builder/drift.sh"
}

fingerprint() {
  local toml="${1:-$(pwd)/project.toml}"
  [ ! -f "$toml" ] && echo "no project.toml found" && return 1
  source "$PTH_ROOT/engines/builder/src/read_toml.sh" "$toml"
  source "$PTH_ROOT/cmd/builder/fingerprint.sh" "$toml"
}
