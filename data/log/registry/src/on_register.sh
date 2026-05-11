#!/bin/bash
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -z "$1" ] && exit 0
DIR="$SELF_DIR/../input/registered"
mkdir -p "$DIR"
echo "$USER :: $1 :: $2" > "$DIR/$2.txt"
