#!/bin/bash
# scaffold.sh — dynamic project_path template
# usage: bash scaffold.sh           → update structure snapshot
#        bash scaffold.sh <target>  → stamp structure into target dir

BASE=~/project/project_path
TEMPLATE_DIR="$BASE/data/template"
STRUCTURE="$TEMPLATE_DIR/structure.txt"
IGNORE="__pycache__|.venv|env/|.git|node_modules|*.pyc"

update_snapshot() {
  echo "updating structure snapshot..."
  echo "# project_path structure" > "$STRUCTURE"
  echo "# generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$STRUCTURE"
  echo "# node: $(hostname)" >> "$STRUCTURE"
  echo "" >> "$STRUCTURE"
  tree "$BASE" \
    -I "$IGNORE" \
    --noreport \
    --dirsfirst \
    2>/dev/null >> "$STRUCTURE"
  echo "" >> "$STRUCTURE"
  echo "# src files" >> "$STRUCTURE"
  find "$BASE" \( -path "*/.venv" -o -path "*/__pycache__" \) -prune \
    -o -name "*.sh" -print \
    -o -name "*.py" -print \
    -o -name "*.toml" -print \
    -o -name "*.conf" -print \
    2>/dev/null | sort >> "$STRUCTURE"
  echo "snapshot saved: $STRUCTURE"
}

stamp_target() {
  TARGET="$1"
  [ -z "$TARGET" ] && echo "usage: scaffold.sh <target>" && exit 1
  echo "stamping: $TARGET"

  grep "^[│├└]" "$STRUCTURE" 2>/dev/null \
  | sed 's/[│├└── ]//g' \
  | grep "/" \
  | while read -r path; do
      mkdir -p "$TARGET/$path"
    done

  find "$BASE" -name "*.sh" \
    ! -path "*/.venv/*" \
    ! -path "*/__pycache__/*" \
    | while read -r f; do
        rel=$(echo "$f" | sed "s|$BASE/||")
        dir=$(dirname "$TARGET/$rel")
        mkdir -p "$dir"
        sed \
          -e "s|/home/[^/]*/project/project_path|$TARGET|g" \
          -e "s|$(hostname)|<NODE>|g" \
          -e "s|$USER|<USER>|g" \
          "$f" > "$TARGET/$rel"
        chmod +x "$TARGET/$rel"
      done

  echo "stamped: $TARGET"
}

if [ -z "$1" ]; then
  update_snapshot
else
  stamp_target "$1"
fi
