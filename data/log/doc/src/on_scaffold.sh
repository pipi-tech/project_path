#!/bin/bash
[ -z "$1" ] && exit 0
PROJECT="$1"; DEST="$2"; TS="$3"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PP_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"
DIR="$PP_ROOT/data/log/doc/input/scaffold"
mkdir -p "$DIR"
cat > "$DIR/${PROJECT}_${TS}.txt" << ENTRY
project=$PROJECT
dest=$DEST
ts=$TS
user=$USER
node=$(hostname)
event=scaffold
ENTRY
