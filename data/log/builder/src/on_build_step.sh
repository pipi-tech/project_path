#!/bin/bash
[ -z "$1" ] && exit 0
DIR=~/project/project_path/data/log/builder/input/build_step
mkdir -p "$DIR"
echo "project=$1" > "$DIR/$2.txt"
echo "step=$3" >> "$DIR/$2.txt"
echo "status=$4" >> "$DIR/$2.txt"
