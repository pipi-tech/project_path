#!/bin/bash
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -z "$1" ] && exit 0
DIR="$SELF_DIR/../input/drift"
mkdir -p "$DIR"
echo "$USER :: $1 :: expected=$2 :: got=$3 :: $4" > "$DIR/$4.txt"
