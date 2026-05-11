#!/bin/bash
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS=$(date '+%Y-%m-%d_%H-%M-%S')
DIR="$SELF_DIR/../input/when"
mkdir -p "$DIR"
echo "$TS" > "$DIR/$TS.txt"
