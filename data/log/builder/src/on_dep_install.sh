#!/bin/bash
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -z "$1" ] && exit 0
DIR="$SELF_DIR/../input/dep_install"
mkdir -p "$DIR"
echo "project=$1" > "$DIR/$2.txt"
echo "dep=$3" >> "$DIR/$2.txt"
echo "status=$4" >> "$DIR/$2.txt"
