#!/bin/bash
# WHAT:  Template management commands — tpl update/stamp/show/tree
# WIRES: Sourced by functions.sh → calls data/template/scaffold.sh → reads data/template/structure.txt
# WHY:   Interface layer for project structure templating and cloning

tpl() {
  local cmd="${1}"
  case "$cmd" in
    update)
      bash "$PTH_ROOT/data/template/scaffold.sh"
      ;;
    stamp)
      [ -z "$2" ] && echo "usage: tpl stamp <target>" && return 1
      bash "$PTH_ROOT/data/template/scaffold.sh" "$2"
      ;;
    show)
      less "$PTH_ROOT/data/template/structure.txt"
      ;;
    tree)
      tree "$PTH_ROOT" \
        -I "__pycache__|.venv|env/|.git" \
        --dirsfirst \
        --noreport \
        2>/dev/null
      ;;
    *)
      echo "usage: tpl [update|stamp|show|tree]"
      ;;
  esac
}
