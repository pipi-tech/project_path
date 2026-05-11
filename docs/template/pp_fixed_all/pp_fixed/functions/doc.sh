#!/bin/bash
# WHAT:  Documentation worker commands — init, ref, session, deps, log, edit, migrate
# WIRES: Sourced by functions.sh → calls engines/doc_worker/src/main.sh and docs/scaffold.sh
# WHY:   Interface layer for doc_worker engine — manages session tracking and auto-doc generation

_doc_worker="$PTH_ROOT/engines/doc_worker/src/main.sh"
_doc_scaffold="$PTH_ROOT/docs/scaffold.sh"
_doc_gen_ref="$PTH_ROOT/engines/doc_worker/src/gen_ref.sh"
_doc_reg="$PTH_ROOT/data/registry.conf"
_doc_sessions="/tmp/pp_doc_sessions"
mkdir -p "$_doc_sessions"

doc() {
  local cmd="${1:-help}"
  case "$cmd" in
    init)
      local name="${2:-$(basename "$(pwd)")}"
      local root="${3:-$(pwd)}"
      echo "=== doc init: $name ==="
      bash "$_doc_scaffold" "$name" "$root"
      bash "$_doc_worker" "$name" "$root" build_done
      bash "$_doc_worker" "$name" "$root" session_open
      local TS
      TS=$(date '+%Y-%m-%d_%H-%M-%S')
      echo "$name:$TS:$root" > "$_doc_sessions/current"
      echo "doc init done: $root/docs/"
      ;;
    ref)
      local name="${2:-$(basename "$(pwd)")}"
      local root="${3:-$(pwd)}"
      local TS
      TS=$(date '+%Y-%m-%d_%H-%M-%S')
      bash "$_doc_gen_ref" "$name" "$root" "$TS"
      ;;
    session)
      local sub="${2:-show}"
      case "$sub" in
        open)
          local name="${3:-$(basename "$(pwd)")}"
          local root="${4:-$(pwd)}"
          bash "$_doc_worker" "$name" "$root" session_open
          ;;
        close)
          local f="$_doc_sessions/current"
          if [ -f "$f" ]; then
            local data proj ts root
            data=$(cat "$f")
            proj=$(echo "$data" | cut -d: -f1)
            ts=$(echo "$data"   | cut -d: -f2)
            root=$(echo "$data" | cut -d: -f3-)
            bash "$_doc_worker" "$proj" "$root" session_close "$ts"
            rm -f "$f"
          else
            echo "no active session"
          fi
          ;;
        show)
          local f="$_doc_sessions/current"
          [ -f "$f" ] && cat "$f" || echo "no active session"
          ;;
      esac
      ;;
    deps)
      local dep="${2:-unknown}"
      local mgr="${3:-pip}"
      local name root
      name=$(basename "$(pwd)")
      root=$(pwd)
      bash "$_doc_worker" "$name" "$root" dep_install "$dep" "$mgr"
      ;;
    log)
      local name="${2:-$(basename "$(pwd)")}"
      local root
      root=$(grep -i "^$name:" "$_doc_reg" | cut -d: -f2 | sed "s|~|$HOME|")
      [ -z "$root" ] && root=$(pwd)
      ls -lt "$root/docs/log/" 2>/dev/null | head -10
      ;;
    edit)
      local name="${2:-$(basename "$(pwd)")}"
      local root
      root=$(grep -i "^$name:" "$_doc_reg" | cut -d: -f2 | sed "s|~|$HOME|")
      [ -z "$root" ] && root=$(pwd)
      local latest
      latest=$(ls -t "$root/docs/log/session_"*.txt 2>/dev/null | head -1)
      [ -z "$latest" ] && echo "no sessions found" && return 1
      ${EDITOR:-nano} "$latest"
      ;;
    migrate)
      echo "=== migrating all registered projects ==="
      grep -v "^#" "$_doc_reg" | while IFS=":" read -r n root env environment type; do
        root=$(echo "$root" | sed "s|~|$HOME|")
        [ -z "$n" ] || [ -z "$root" ] && continue
        [ ! -d "$root" ] && echo "  skip $n (dir not found)" && continue
        echo "  doc init: $n"
        local TS
        TS=$(date '+%Y-%m-%d_%H-%M-%S')
        bash "$_doc_scaffold" "$n" "$root" 2>/dev/null
        bash "$_doc_gen_ref"  "$n" "$root" "$TS" 2>/dev/null
        echo "  done: $n"
      done
      echo "migration complete"
      ;;
    *)
      echo "usage: doc [init|ref|session|deps|log|edit|migrate]"
      echo ""
      echo "  init [name] [root]      → scaffold + gen ref + open session"
      echo "  ref  [name] [root]      → regenerate ref/SCRIPTS.md"
      echo "  session open/close/show → manage current session"
      echo "  deps <dep> <mgr>        → log a dep install to changelog"
      echo "  log  [name]             → list session logs"
      echo "  edit [name]             → open latest session in editor"
      echo "  migrate                 → doc init all registered projects"
      ;;
  esac
}
