#!/bin/bash
# WHAT:  Generates master log registry — snapshot of all recent log events across domains
# WIRES: Called by functions/cli.sh (mlog) → reads data/log/*/ → writes data/MasterLOGText/master_log.txt
# WHY:   Audit tool — one file to see the full event history across all log domains

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PTH_ROOT="$(cd "$SELF_DIR/../.." && pwd)"

LOCK=/tmp/master_log.lock
OUT="$PTH_ROOT/data/MasterLOGText/master_log.txt"
LOG_BASE="$PTH_ROOT/data/log"

mkdir -p "$PTH_ROOT/data/MasterLOGText"
> "$OUT"

(
    flock -x 200

    echo "======================================================" >> "$OUT"
    echo "  MASTER LOG REGISTRY"                                  >> "$OUT"
    echo "  generated: $(date '+%Y-%m-%d %H:%M:%S')"             >> "$OUT"
    echo "  node: <NODE>  user: <USER>"                           >> "$OUT"
    echo "======================================================" >> "$OUT"
    echo "" >> "$OUT"

    echo "[ log structure ]" >> "$OUT"
    tree "$LOG_BASE" --noreport 2>/dev/null >> "$OUT"
    echo "" >> "$OUT"

    find "$LOG_BASE" -mindepth 1 -maxdepth 1 -type d \
    | grep -v "MasterSCRText\|MasterLOGText" \
    | sort \
    | while read -r DOMAIN; do
        NAME=$(basename "$DOMAIN")
        echo ""                                              >> "$OUT"
        echo "===================( $NAME )====================" >> "$OUT"
        tree "$DOMAIN" --noreport 2>/dev/null               >> "$OUT"
        echo ""                                              >> "$OUT"

        find "$DOMAIN/input" -name "*.txt" 2>/dev/null \
        | sort -r \
        | head -20 \
        | while read -r f; do
            folder=$(echo "$f" | rev | cut -d/ -f2 | rev)
            echo "----( $folder/$(basename "$f") )----"     >> "$OUT"
            sed \
                -e "s|/home/[^/]*/|/home/<USER>/|g" \
                -e "s|$(hostname)|<NODE>|g" \
                "$f"                                        >> "$OUT"
            echo ""                                         >> "$OUT"
        done

        echo "===================( end $NAME )====================" >> "$OUT"
        echo "" >> "$OUT"
    done

) 200>"$LOCK"

echo "master log written: $OUT"
