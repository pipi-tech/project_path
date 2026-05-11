#!/bin/bash
# WHAT:  Project configuration commands — domains, classify, migrate, onboard
# WIRES: Sourced by functions.sh → calls $PTH_ROOT/cmd/config/
# WHY:   Interface layer for project.toml management and log domain configuration

domains() {
  local cmd="${1:-show}"
  local toml="${2:-$(pwd)/project.toml}"

  case "$cmd" in
    set)
      [ ! -f "$toml" ] && echo "no project.toml found" && return 1
      bash "$PTH_ROOT/cmd/config/set_log_domains.sh" "$toml"
      ;;
    show)
      [ ! -f "$toml" ] && echo "no project.toml found" && return 1
      grep "^active" "$toml" || echo "no active domains set"
      ;;
    types)
      cat "$PTH_ROOT/cmd/config/type_registry.conf"
      ;;
    add-type)
      local t="$2"
      [ -z "$t" ] && echo "usage: domains add-type <type>" && return 1
      echo "$t:terminal,registry" >> "$PTH_ROOT/cmd/config/type_registry.conf"
      echo "added type: $t"
      ;;
    *)
      echo "usage: domains [set|show|types|add-type]"
      ;;
  esac
}

classify() {
  local toml="${1:-$(pwd)/project.toml}"
  local mgr="${2:-pip}"
  [ ! -f "$toml" ] && echo "no project.toml found" && return 1
  bash "$PTH_ROOT/cmd/config/classify_deps.sh" "$toml" "$mgr"
}

migrate() {
  local toml="${1:-$(pwd)/project.toml}"
  [ ! -f "$toml" ] && echo "no project.toml found" && return 1
  bash "$PTH_ROOT/cmd/config/migrate_toml.sh" "$toml"
}

onboard() {
  local toml="${1:-$(pwd)/project.toml}"
  local mgr="${2:-pip}"
  bash "$PTH_ROOT/cmd/config/onboard_deps.sh" "$toml" "$mgr"
}

pkg_managers() {
  local cmd="${1:-list}"
  local mgr="$2"

  local MGR_LOG="$PTH_ROOT/data/log/dep/input/managers"
  mkdir -p "$MGR_LOG"

  case "$cmd" in
    list)
      echo "=== package managers ==="
      for f in "$MGR_LOG"/*.txt 2>/dev/null; do
        [ -f "$f" ] && echo "  $(basename $f .txt): $(wc -l < $f) entries"
      done
      ;;
    detect)
      echo "=== detected managers ==="
      command -v pip   >/dev/null 2>&1 && echo "  pip:   $(pip --version 2>/dev/null | cut -d' ' -f1-2)"
      command -v npm   >/dev/null 2>&1 && echo "  npm:   $(npm --version 2>/dev/null)"
      command -v cargo >/dev/null 2>&1 && echo "  cargo: $(cargo --version 2>/dev/null)"
      command -v apt   >/dev/null 2>&1 && echo "  apt:   available"
      command -v conda >/dev/null 2>&1 && echo "  conda: $(conda --version 2>/dev/null)"
      ;;
    classify)
      [ -z "$mgr" ] && echo "usage: pkg_managers classify <manager>" && return 1
      classify "$(pwd)/project.toml" "$mgr"
      ;;
    *)
      echo "usage: pkg_managers [list|detect|classify <mgr>]"
      ;;
  esac
}
