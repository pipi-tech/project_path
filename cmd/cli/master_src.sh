#!/bin/bash

LOCK=/tmp/master_src.lock
OUT=~/project/project_path/data/log/MasterSCRText/master_src.txt
REG=~/project/project_path/data/registry.conf
BASE=~/project/project_path

mkdir -p ~/project/project_path/data/log/MasterSCRText

> "$OUT"

(
    flock -x 200

    echo "======================================================" >> "$OUT"
    echo "  MASTER SRC REGISTRY" >> "$OUT"
    echo "  generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUT"
    echo "  node: $(hostname)  user: $USER" >> "$OUT"
    echo "======================================================" >> "$OUT"
    echo "" >> "$OUT"

    echo "[ project_path structure ]" >> "$OUT"
    tree "$BASE" -I '__pycache__' --noreport 2>/dev/null >> "$OUT"
    echo "" >> "$OUT"

    grep -v "^#" "$REG" 2>/dev/null \
    | cut -d: -f1 \
    | xargs -I{} bash -c '
        PROJECT={}
        ROOT=$(grep "^$PROJECT:" '"$REG"' | cut -d: -f2 | sed "s|~|$HOME|")
        SRC_DIR="$ROOT/src"
        [ ! -d "$SRC_DIR" ] && exit 0
        echo "src: $SRC_DIR"
    ' \
    | sort \
    | parallel --jobs 4 --mutex "$LOCK" bash -c '
        SRC_DIR=$(echo {} | cut -d" " -f2)
        PROJECT=$(echo "$SRC_DIR" | rev | cut -d/ -f2 | rev)
        OUT=~/project/project_path/data/log/MasterSCRText/master_src.txt

        echo "" >> "$OUT"
        echo "===================( $PROJECT/src )====================" >> "$OUT"
        tree "$SRC_DIR" --noreport 2>/dev/null >> "$OUT"
        echo "" >> "$OUT"

        find "$SRC_DIR" -name "*.sh" -o -name "*.py" 2>/dev/null \
        | sort \
        | while read -r f; do
            echo "----( $(basename $f) )----" >> "$OUT"
            sed \
                -e "s|/home/[^/]*/|/home/<USER>/|g" \
                -e "s|$(hostname)|<NODE>|g" \
                -e "s|[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}|<DATE>|g" \
                "$f" >> "$OUT"
            echo "" >> "$OUT"
        done

        echo "===================( end $PROJECT )====================" >> "$OUT"
        echo "" >> "$OUT"
    '

    echo "[ project_path src ]" >> "$OUT"
    find "$BASE" -path "*/src/*.sh" -o -path "*/src/*.py" 2>/dev/null \
    | sort \
    | while read -r f; do
        rel=$(echo "$f" | sed "s|$BASE/||")
        echo "" >> "$OUT"
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
