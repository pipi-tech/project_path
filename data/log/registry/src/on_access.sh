#!/bin/bash
[ -z "$1" ] && exit 0
DIR=~/project/project_path/data/log/registry/input/accessed
mkdir -p "$DIR"
echo "$USER :: $1 :: $2" > "$DIR/$2.txt"
