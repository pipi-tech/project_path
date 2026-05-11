#!/bin/bash
# WHAT:  Registry and session query commands — reg, session, gitpush
# WIRES: Sourced by functions.sh → reads data/registry.conf and data/registry.txt → reads data/log/terminal/
# WHY:   Interface layer for registry queries and session state — no writes, read-only audit commands

reg() {
  local cmd="$1"
  local name="$2"
  local REG_CONF="$PTH_ROOT/data/registry.conf"
  local REG_LOG="$PTH_ROOT/data/registry.txt"
  case "$cmd" in
    list)
      grep -v "^#" "$REG_CONF" | while IFS=":" read -r n root env environment type; do
        echo "$n :: $root :: $type :: $environment"
      done
      ;;
    show)
      [ -z "$name" ] && echo "usage: reg show <project>" && return 1
      grep -i "^$name:" "$REG_CONF"
      ;;
    history)
      [ -z "$name" ] && cat "$REG_LOG" || grep "$name" "$REG_LOG"
      ;;
    remove)
      [ -z "$name" ] && echo "usage: reg remove <project>" && return 1
      sed -i "/^$name:/d" "$REG_CONF"
      echo "removed: $name"
      ;;
    *)
      echo "usage: reg [list|show|history|remove] <project>"
      ;;
  esac
}

session() {
  local cmd="${1:-show}"
  local HASH_FILE="/tmp/pp_session_$$.hash"
  local LOG_BASE="$PTH_ROOT/data/log"

  case "$cmd" in
    show)
      if [ -f "$HASH_FILE" ]; then
        HASH=$(cat "$HASH_FILE")
      else
        HASH=$(ls /tmp/pp_session_*.hash 2>/dev/null \
          | xargs grep -l "" 2>/dev/null \
          | head -1 \
          | xargs cat 2>/dev/null || echo "no active session")
      fi
      echo "user:    $USER"
      echo "node:    $(hostname)"
      echo "hash:    $HASH"
      echo "pid:     $$"
      echo "tty:     $(tty 2>/dev/null || echo no-tty)"
      echo "session: ${XDG_SESSION_ID:-unknown}"
      ;;
    history)
      echo "=== session history ==="
      find "$LOG_BASE/terminal/input/who" \
        -name "*.txt" 2>/dev/null | sort -r | head -20 \
      | xargs -I{} bash -c 'echo "--- {} ---" && cat "{}"'
      ;;
    find)
      [ -z "$2" ] && echo "usage: session find <hash>" && return 1
      echo "=== terminal ==="
      grep -r "$2" "$LOG_BASE/terminal/input/" 2>/dev/null
      echo "=== dep ==="
      grep -r "$2" "$LOG_BASE/dep/input/" 2>/dev/null
      echo "=== registry ==="
      grep -r "$2" "$LOG_BASE/registry/input/" 2>/dev/null
      ;;
    active)
      echo "=== active sessions ==="
      ls /tmp/pp_session_*.hash 2>/dev/null | while read -r f; do
        pid=$(basename "$f" | sed 's/pp_session_//' | sed 's/\.hash//')
        hash=$(cat "$f")
        if kill -0 "$pid" 2>/dev/null; then
          echo "LIVE  pid=$pid hash=${hash:0:16}..."
        else
          echo "DEAD  pid=$pid hash=${hash:0:16}..."
        fi
      done
      ;;
    clean)
      echo "cleaning dead sessions..."
      ls /tmp/pp_session_*.hash 2>/dev/null | while read -r f; do
        pid=$(basename "$f" | sed 's/pp_session_//' | sed 's/\.hash//')
        if ! kill -0 "$pid" 2>/dev/null; then
          rm -f "$f"
          echo "removed dead session: pid=$pid"
        fi
      done
      ;;
    *)
      echo "usage: session [show|history|find <hash>|active|clean]"
      ;;
  esac
}

gitpush() {
  local msg="${1:-auto: session close $(date '+%Y-%m-%d %H:%M')}"
  local branch
  branch=$(git branch --show-current 2>/dev/null || echo "main")
  git add . 2>/dev/null
  git commit -m "$msg" 2>/dev/null
  git push origin "$branch" 2>/dev/null && echo "pushed: $branch" || echo "push failed or nothing to push"
}
