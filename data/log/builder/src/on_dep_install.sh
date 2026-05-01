#!/bin/bash
[ -z "$1" ] && exit 0
DIR=~/project/project_path/data/log/builder/input/dep_install
mkdir -p "$DIR"
echo "project=$1" > "$DIR/$2.txt"
echo "dep=$3" >> "$DIR/$2.txt"
echo "status=$4" >> "$DIR/$2.txt"
