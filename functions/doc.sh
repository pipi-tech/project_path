#!/bin/bash
DOC_WORKER=~/project/project_path/engines/doc_worker/src/main.sh
DOC_SCAFFOLD=~/project/project_path/docs/scaffold.sh
GEN_REF=~/project/project_path/engines/doc_worker/src/gen_ref.sh

doc() {
  local cmd="${1:-help}"
  case "$cmd" in
    init)
      local name="${2:-$(basename $(pwd))}"
      local root="${3:-$(pwd)}"
      echo "=== doc init: $name ==="
      bash "$DOC_SCAFFOLD" "$name" "$root"
      bash "$DOC_WORKER" "$name" "$root" build_done
      bash "$DOC_WORKER" "$name" "$root" session_open
      local TS=$(date '+%Y-%m-%d_%H-%M-%S')
      echo "$name:$TS:$root" > /tmp/pp_doc_sessions/current
      echo "doc init done: $root/docs/"
      ;;
    ref)
      local name="${2:-$(basename $(pwd))}"
      local root="${3:-$(pwd)}"
      local TS=$(date '+%Y-%m-%d_%H-%M-%S')
      bash "$GEN_REF" "$name" "$root" "$TS"
      ;;
    session)
      local sub="${2:-show}"
      case "$sub" in
        open)
          local name="${3:-$(basename $(pwd))}"
          local root="${4:-$(pwd)}"
          bash "$DOC_WORKER" "$name" "$root" session_open
          ;;
        close)
          local f=/tmp/pp_doc_sessions/current
          if [ -f "$f" ]; then
            local data=$(cat "$f")
            local proj=$(echo "$data" | cut -d: -f1)
            local ts=$(echo "$data" | cut -d: -f2)
            local root=$(echo "$data" | cut -d: -f3-)
            bash "$DOC_WORKER" "$proj" "$root" session_close "$ts"
            rm -f "$f"
          else
            echo "no active session"
          fi
          ;;
        show)
          local f=/tmp/pp_doc_sessions/current
          [ -f "$f" ] && cat "$f" || echo "no active session"
          ;;
      esac
      ;;
    deps)
      local dep="${2:-unknown}"
      local mgr="${3:-pip}"
      local name=$(basename $(pwd))
      local root=$(pwd)
      bash "$DOC_WORKER" "$name" "$root" dep_install "$dep" "$mgr"
      ;;
    log)
      local name="${2:-$(basename $(pwd))}"
      local root=$(grep -i "^$name:" ~/project/project_path/data/registry.conf \
        | cut -d: -f2 | sed "s|~|$HOME|")
      [ -z "$root" ] && root=$(pwd)
      ls -lt "$root/docs/log/" 2>/dev/null | head -10
      ;;
    edit)
      local name="${2:-$(basename $(pwd))}"
      local root=$(grep -i "^$name:" ~/project/project_path/data/registry.conf \
        | cut -d: -f2 | sed "s|~|$HOME|")
      [ -z "$root" ] && root=$(pwd)
      local latest=$(ls -t "$root/docs/log/session_"*.txt 2>/dev/null | head -1)
      [ -z "$latest" ] && echo "no sessions found" && return 1
      ${EDITOR:-nano} "$latest"
      ;;
    migrate)
      echo "=== migrating all registered projects ==="
      grep -v "^#" ~/project/project_path/data/registry.conf | while IFS=":" read -r n root env environment type; do
        root=$(echo "$root" | sed "s|~|$HOME|")
        [ -z "$n" ] || [ -z "$root" ] && continue
        [ ! -d "$root" ] && echo "  skip $n (dir not found)" && continue
        echo "  doc init: $n"
        bash "$DOC_SCAFFOLD" "$n" "$root" 2>/dev/null
        local TS=$(date '+%Y-%m-%d_%H-%M-%S')
        bash "$GEN_REF" "$n" "$root" "$TS" 2>/dev/null
        echo "  done: $n"
      done
      echo "migration complete"
      ;;
    *)
      echo "usage: doc [init|ref|session|deps|log|edit|migrate]"
      echo ""
      echo "  init [name] [root]     → scaffold + gen ref + open session"
      echo "  ref  [name] [root]     → regenerate ref/SCRIPTS.md"
      echo "  session open/close/show→ manage current session"
      echo "  deps <dep> <mgr>       → log a dep install to changelog"
      echo "  log  [name]            → list session logs"
      echo "  edit [name]            → open latest session in editor"
      echo "  migrate                → doc init all registered projects"
      ;;
  esac
}
