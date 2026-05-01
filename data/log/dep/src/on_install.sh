#!/bin/bash
[ -z "$1" ] && exit 0
PROJECT="$1"
TS="$2"
MANAGER="$3"
PACKAGE="$4"
PARENT_PID="${5:-$$}"
DIR=~/project/project_path/data/log/dep/input/install
mkdir -p "$DIR"

SESSION_HASH=$(cat "/tmp/pp_session_${PARENT_PID}.hash" 2>/dev/null || echo "no-session")

echo "project=$PROJECT"          > "$DIR/$TS.txt"
echo "ts=$TS"                   >> "$DIR/$TS.txt"
echo "user=$USER"               >> "$DIR/$TS.txt"
echo "session_hash=$SESSION_HASH" >> "$DIR/$TS.txt"
echo "manager=$MANAGER"         >> "$DIR/$TS.txt"
echo "package=$PACKAGE"         >> "$DIR/$TS.txt"
echo "node=$(hostname)"         >> "$DIR/$TS.txt"
