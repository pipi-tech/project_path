#!/bin/bash
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -z "$1" ] && exit 0
DIR="$SELF_DIR/../input/drift"
mkdir -p "$DIR"
echo "project=$1" > "$DIR/$2.txt"
echo "stored=$3" >> "$DIR/$2.txt"
echo "current=$4" >> "$DIR/$2.txt"
