#!/bin/bash

LOCK=/tmp/master_log.lock
OUT=~/project/project_path/data/log/MasterLOGText/master_log.txt
LOG_BASE=~/project/project_path/data/log

mkdir -p ~/project/project_path/data/log/MasterLOGText

> "$OUT"

(
    flock -x 200

    echo "======================================================" >> "$OUT"
    echo "  MASTER LOG REGISTRY" >> "$OUT"
    echo "  generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUT"
    echo "  node: $(hostname)  user: $USER" >> "$OUT"
    echo "======================================================" >> "$OUT"
    echo "" >> "$OUT"

    echo "[ log structure ]" >> "$OUT"
    tree "$LOG_BASE" --noreport 2>/dev/null >> "$OUT"
    echo "" >> "$OUT"

    find "$LOG_BASE" -mindepth 1 -maxdepth 1 -type d \
    | grep -v "MasterSCRText\|MasterLOGText" \
    | sort \
    | parallel --jobs 4 --mutex "$LOCK" bash -c '
        DOMAIN={}
        NAME=$(basename "$DOMAIN")
        OUT=~/project/project_path/data/log/MasterLOGText/master_log.txt

        echo "" >> "$OUT"
        echo "===================( $NAME )====================" >> "$OUT"
        tree "$DOMAIN" --noreport 2>/dev/null >> "$OUT"
        echo "" >> "$OUT"

        find "$DOMAIN/input" -name "*.txt" 2>/dev/null \
        | sort -r \
        | head -20 \
        | while read -r f; do
            folder=$(echo "$f" | rev | cut -d/ -f2 | rev)
            echo "----( $folder/$(basename $f) )----" >> "$OUT"
            sed \
                -e "s|/home/[^/]*/|/home/<USER>/|g" \
                -e "s|$(hostname)|<NODE>|g" \
                "$f" >> "$OUT"
            echo "" >> "$OUT"
        done

        echo "===================( end $NAME )====================" >> "$OUT"
        echo "" >> "$OUT"
    '

) 200>"$LOCK"

echo "master log written: $OUT"
