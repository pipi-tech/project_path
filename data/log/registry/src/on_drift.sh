#!/bin/bash
[ -z "$1" ] && exit 0
DIR=~/project/project_path/data/log/registry/input/drift
mkdir -p "$DIR"
echo "$USER :: $1 :: expected=$2 :: got=$3 :: $4" > "$DIR/$4.txt"
