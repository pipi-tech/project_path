#!/bin/bash
DIR=~/project/project_path/data/log/terminal/input/project
mkdir -p "$DIR"
echo "$1" > "$DIR/$2.txt"
