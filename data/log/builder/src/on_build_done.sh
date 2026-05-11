#!/bin/bash
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -z "$1" ] && exit 0
DIR="$SELF_DIR/../input/build_done"
mkdir -p "$DIR"
echo "project=$1" > "$DIR/$2.txt"
echo "fingerprint=$3" >> "$DIR/$2.txt"
echo "uuid=$4" >> "$DIR/$2.txt"
echo "user=$USER" >> "$DIR/$2.txt"
