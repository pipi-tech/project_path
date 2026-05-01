#!/bin/bash
REG_CONF=~/project/project_path/data/registry.conf
REG_LOG=~/project/project_path/data/registry.txt

reg() {
  local cmd="$1"
  local name="$2"
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
      find ~/project/project_path/data/log/terminal/input/who \
        -name "*.txt" | sort -r | head -20 \
      | xargs -I{} bash -c 'echo "--- {} ---" && cat "{}"'
      ;;
    find)
      [ -z "$2" ] && echo "usage: session find <hash>" && return 1
      echo "=== terminal ==="
      grep -r "$2" ~/project/project_path/data/log/terminal/input/ 2>/dev/null
      echo "=== dep ==="
      grep -r "$2" ~/project/project_path/data/log/dep/input/ 2>/dev/null
      echo "=== registry ==="
      grep -r "$2" ~/project/project_path/data/log/registry/input/ 2>/dev/null
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
