#!/bin/bash
TS=$(date '+%Y-%m-%d_%H-%M-%S')
DIR=~/project/project_path/data/log/terminal/input/when
mkdir -p "$DIR"
echo "$TS" > "$DIR/$TS.txt"
