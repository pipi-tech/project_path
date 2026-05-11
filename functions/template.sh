#!/bin/bash
# WHAT:  Template commands — update snapshot, stamp target, show, tree
# WIRES: Sourced by functions.sh → calls data/template/scaffold.sh
# WHY:   Interface for the template system — captures and clones project_path structure

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
