#!/bin/bash
[ -z "$1" ] && exit 0
PROJECT="$1"; REF_FILE="$2"; SCRIPT_COUNT="$3"; TS="$4"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PP_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"
DIR="$PP_ROOT/data/log/doc/input/ref"
mkdir -p "$DIR"
cat > "$DIR/${PROJECT}_${TS}.txt" << ENTRY
project=$PROJECT
ref_file=$REF_FILE
scripts_documented=$SCRIPT_COUNT
ts=$TS
user=$USER
node=$(hostname)
event=ref_gen
ENTRY
