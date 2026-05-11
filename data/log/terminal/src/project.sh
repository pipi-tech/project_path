#!/bin/bash
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="$SELF_DIR/../input/project"
mkdir -p "$DIR"
echo "$1" > "$DIR/$2.txt"
