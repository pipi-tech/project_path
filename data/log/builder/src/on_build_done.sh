#!/bin/bash
[ -z "$1" ] && exit 0
DIR=~/project/project_path/data/log/builder/input/build_done
mkdir -p "$DIR"
echo "project=$1" > "$DIR/$2.txt"
echo "fingerprint=$3" >> "$DIR/$2.txt"
echo "uuid=$4" >> "$DIR/$2.txt"
echo "user=$USER" >> "$DIR/$2.txt"
