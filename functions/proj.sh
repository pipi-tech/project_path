#!/bin/bash
# WHAT:  Project entry and session management — proj, reg, session commands
# WIRES: Sourced by functions.sh → reads data/registry.conf → calls engines/doc_worker/src/main.sh
# WHY:   Core navigation layer — entering a project activates venv and opens a tracked session

PROJECT_PATHS=("$HOME/project")
REG_CONF="$PTH_ROOT/data/registry.conf"
DOC_WORKER="$PTH_ROOT/engines/doc_worker/src/main.sh"
SESSION_STORE=/tmp/pp_doc_sessions
mkdir -p "$SESSION_STORE"

_reg_lookup() {
  [ ! -f "$REG_CONF" ] && return 1
  grep -i "^$1:" "$REG_CONF" | head -1
}

_proj_exists() {
  [ -n "$(_reg_lookup "$1")" ] && return 0
  for base in "${PROJECT_PATHS[@]}"; do
    [ -d "$base/$1" ] && return 0
  done
  return 1
}

_proj_core() {
  local name="$1"
  if [ -z "$name" ]; then
    echo "Available projects:"
    if [ -f "$REG_CONF" ]; then
      grep -v "^#" "$REG_CONF" | while IFS=":" read -r n root env environment type; do
        echo "  $n  ($root) [$type]"
      done
    else
      for base in "${PROJECT_PATHS[@]}"; do
        [ -d "$base" ] && for d in "$base"/*/; do
          [ -d "$d" ] && echo "  $(basename "$d")  ($base)"
        done
      done
    fi
    return 0
  fi

  local entry root env
  entry=$(_reg_lookup "$name")

  if [ -n "$entry" ]; then
    root=$(echo "$entry" | cut -d: -f2 | sed "s|~|$HOME|")
    env=$(echo "$entry"  | cut -d: -f3)
  else
    for base in "${PROJECT_PATHS[@]}"; do
      [ -d "$base/$name" ] && root="$base/$name" && break
    done
  fi

  [ -z "$root" ] && echo "Project '$name' not found." && return 1

  local prev="$SESSION_STORE/current"
  if [ -f "$prev" ]; then
    local prev_data prev_proj prev_ts prev_root
    prev_data=$(cat "$prev")
    prev_proj=$(echo "$prev_data" | cut -d: -f1)
    prev_ts=$(echo "$prev_data"   | cut -d: -f2)
    prev_root=$(echo "$prev_data" | cut -d: -f3-)
    bash "$DOC_WORKER" "$prev_proj" "$prev_root" session_close "$prev_ts" 2>/dev/null
    rm -f "$prev"
  fi

  cd "$root" || return 1

  if [ "$env" != "none" ] && [ -f "$root/$env/bin/activate" ]; then
    source "$root/$env/bin/activate"
    echo "venv: $env ($(python --version))"
  elif [ -f "$root/.venv/bin/activate" ]; then
    source "$root/.venv/bin/activate"
    echo "venv: .venv ($(python --version))"
  elif [ -f "$root/env/bin/activate" ]; then
    source "$root/env/bin/activate"
    echo "venv: env/"
  else
    echo "no venv found"
  fi

  echo "---"
  ls

  local TS
  TS=$(date '+%Y-%m-%d_%H-%M-%S')
  bash "$DOC_WORKER" "$name" "$root" session_open 2>/dev/null
  echo "$name:$TS:$root" > "$prev"
}

proj() {
  if [ -z "$1" ]; then _proj_core; return 0; fi
  if ! _proj_exists "$1"; then echo "Project '$1' not found." && return 1; fi
  bash "$PTH_ROOT/data/log/logScr.sh" "$1" "$$" 2>/dev/null || true
  _proj_core "$1"
}
