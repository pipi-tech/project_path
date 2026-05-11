#!/bin/bash
# WHAT:  Generates master source registry — snapshot of all project src files
# WIRES: Called by functions/cli.sh (msrc) → reads data/registry.conf → writes data/MasterSCRText/master_src.txt
# WHY:   Audit tool — one file with the full state of all source across all registered projects

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../.." && pwd)"

LOCK=/tmp/master_src.lock
OUT="$PTH_ROOT/data/MasterSCRText/master_src.txt"
REG="$PTH_ROOT/data/registry.conf"
BASE="$PTH_ROOT"

mkdir -p "$PTH_ROOT/data/MasterSCRText"
> "$OUT"

(
    flock -x 200

    echo "======================================================" >> "$OUT"
    echo "  MASTER SRC REGISTRY"                                  >> "$OUT"
    echo "  generated: $(date '+%Y-%m-%d %H:%M:%S')"             >> "$OUT"
    echo "  node: <NODE>  user: <USER>"                           >> "$OUT"
    echo "======================================================" >> "$OUT"
    echo ""                                                        >> "$OUT"

    echo "[ project_path structure ]" >> "$OUT"
    tree "$BASE" -I '__pycache__|.venv|.git' --noreport 2>/dev/null >> "$OUT"
    echo "" >> "$OUT"

    echo "[ project_path src ]" >> "$OUT"
    find "$BASE" -path "*/src/*.sh" -o -path "*/src/*.py" 2>/dev/null \
    | sort \
    | while read -r f; do
        rel=$(echo "$f" | sed "s|$BASE/||")
        echo ""                                        >> "$OUT"
        echo "===================( $rel )====================" >> "$OUT"
        sed \
            -e "s|/home/[^/]*/|/home/<USER>/|g" \
            -e "s|$(hostname)|<NODE>|g" \
            -e "s|[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}|<DATE>|g" \
            "$f" >> "$OUT"
        echo "===================( end )====================" >> "$OUT"
    done

) 200>"$LOCK"

echo "master src written: $OUT"
