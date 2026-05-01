#!/bin/bash
[ -z "$1" ] && exit 0
DIR=~/project/project_path/data/log/builder/input/build_start
mkdir -p "$DIR"
echo "project=$1" > "$DIR/$2.txt"
echo "toml=$3" >> "$DIR/$2.txt"
echo "user=$USER" >> "$DIR/$2.txt"
echo "node=$(hostname)" >> "$DIR/$2.txt"
