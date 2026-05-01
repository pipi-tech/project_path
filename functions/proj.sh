#!/bin/bash
PROJECT_PATHS=(~/project)
REG_CONF=~/project/project_path/data/registry.conf
DOC_WORKER=~/project/project_path/engines/doc_worker/src/main.sh
SESSION_STORE=/tmp/pp_doc_sessions
mkdir -p "$SESSION_STORE"

_reg_lookup() {
  [ ! -f "$REG_CONF" ] && return 1
  grep -i "^$1:" "$REG_CONF" | head -1
}

_proj_exists() {
  [ -n "$(_reg_lookup $1)" ] && return 0
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
          [ -d "$d" ] && echo "  $(basename $d)  ($base)"
        done
      done
    fi
    return 0
  fi

  local entry=$(_reg_lookup "$name")
  local root env

  if [ -n "$entry" ]; then
    root=$(echo "$entry" | cut -d: -f2 | sed "s|~|$HOME|")
    env=$(echo "$entry" | cut -d: -f3)
  else
    for base in "${PROJECT_PATHS[@]}"; do
      [ -d "$base/$name" ] && root="$base/$name" && break
    done
  fi

  [ -z "$root" ] && echo "Project '$name' not found." && return 1

  local prev="$SESSION_STORE/current"
  if [ -f "$prev" ]; then
    local prev_data=$(cat "$prev")
    local prev_proj=$(echo "$prev_data" | cut -d: -f1)
    local prev_ts=$(echo "$prev_data" | cut -d: -f2)
    local prev_root=$(echo "$prev_data" | cut -d: -f3-)
    bash "$DOC_WORKER" "$prev_proj" "$prev_root" session_close "$prev_ts" 2>/dev/null
    rm -f "$prev"
  fi

  cd "$root"

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

  local TS=$(date '+%Y-%m-%d_%H-%M-%S')
  bash "$DOC_WORKER" "$name" "$root" session_open 2>/dev/null
  echo "$name:$TS:$root" > "$prev"
}

proj() {
  if [ -z "$1" ]; then _proj_core; return 0; fi
  if ! _proj_exists "$1"; then echo "Project '$1' not found." && return 1; fi
  bash ~/project/project_path/data/log/logScr.sh "$1" "$$"
  _proj_core "$1"
}
