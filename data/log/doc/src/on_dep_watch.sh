#!/bin/bash
[ -z "$1" ] && exit 0
PROJECT="$1"; DEP="$2"; MANAGER="$3"; ACTION="$4"; TS="$5"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PP_ROOT="$(cd "$SELF_DIR/../../.." && pwd)"
DIR="$PP_ROOT/data/log/doc/input/dep"
mkdir -p "$DIR"
cat > "$DIR/${PROJECT}_${TS}.txt" << ENTRY
project=$PROJECT
dep=$DEP
manager=$MANAGER
action=$ACTION
ts=$TS
user=$USER
node=$(hostname)
event=dep_watch
ENTRY
