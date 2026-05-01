#!/bin/bash

tpl() {
  local cmd="${1}"
  case "$cmd" in
    update)
      bash ~/project/project_path/data/template/scaffold.sh
      ;;
    stamp)
      [ -z "$2" ] && echo "usage: tpl stamp <target>" && return 1
      bash ~/project/project_path/data/template/scaffold.sh "$2"
      ;;
    show)
      cat ~/project/project_path/data/template/structure.txt | less
      ;;
    tree)
      tree ~/project/project_path \
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
