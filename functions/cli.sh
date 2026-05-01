#!/bin/bash

msrc() {
  bash ~/project/project_path/cmd/cli/master_src.sh
}

mlog() {
  bash ~/project/project_path/cmd/cli/master_log.sh
}

aptlist() {
  local cmd="${1:-manual}"
  case "$cmd" in
    manual)
      echo "=== manually installed ==="
      apt-mark showmanual | sort | column
      ;;
    all)
      apt list --installed 2>/dev/null \
      | grep -v "^Listing" \
      | awk -F'/' '{print $1}' \
      | sort | column
      ;;
    search)
      [ -z "$2" ] && echo "usage: aptlist search <term>" && return 1
      apt list --installed 2>/dev/null \
      | grep -i "$2" | awk -F'/' '{print $1}'
      ;;
    snap)
      snap list 2>/dev/null
      ;;
    pip)
      pip list 2>/dev/null
      ;;
    all-managers)
      echo "=== apt (manual) ===" && apt-mark showmanual | sort | column
      echo "=== snap ===" && snap list 2>/dev/null
      echo "=== pip ===" && pip list 2>/dev/null
      echo "=== cargo ===" && cargo install --list 2>/dev/null
      echo "=== flatpak ===" && flatpak list 2>/dev/null
      ;;
    *)
      echo "usage: aptlist [manual|all|search <term>|snap|pip|all-managers]"
      ;;
  esac
}
